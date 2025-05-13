// audioplayers_playlist_provider.dart
import 'dart:async';

import 'package:audioplayer_lyric_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/netease_api.dart';
import '../models/music.dart';

import '../services/persistdata/audio_downloader.dart';
//extension
//import '../extensions/lyrics_extension.dart';
import '../extensions/yrc_process.dart';
import '../extensions/remove_metadata_extention.dart';
import '../extensions/url_extension.dart';

class AudioPlaylistProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final NeteaseMusicApi _api;

  List<Song> _playlist = [];
  Song _currentSong = Song(
    id: '',
    name: '',
    artists: [], // 使用空列表而不是空Map
    album: Album(id: '', name: '', picUrl: ''), // 提供有效的Album对象
    duration: 0,
  );
  //int _currentIndex = -1;
  int _currentIndex = -1;
  PlayerState _playerState = PlayerState.stopped;
  bool _isShuffleEnabled = false;
  bool _isRepeatEnabled = false;
  bool _isListLoopEnabled = false;
  List<Song> _originalPlaylist = [];
  double _volume = 0.5;
  //double _progress = 0.0;
  //double _maxDuration = 0.0;
  Map<String, String> _lyric = {};
  Map<String, String> _processedLyric = {};
  Map<String, String> _processedTranslatedLyric = {};
  Map<String, String> _processedYrcLyric = {};
  bool _islyricChanged = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  RawLyricResponse _lyricData = RawLyricResponse(
    sgc: false,
    sfy: false,
    qfy: false,
    lrc: '',
    tlyric: '',
    klyric: '',
    yrc: '',
    romalrc: '',
    code: 0,
  );
  // Getters
  List<Song> get playlist => _playlist;
  Song get currentSong => _currentSong;

  PlayerState get playerState => _playerState;
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isRepeatEnabled => _isRepeatEnabled;
  bool get isListLoopEnabled => _isListLoopEnabled;
  double get volume => _volume;
  int get currentIndex => _currentIndex;
  //double get progress => _progress;
  //double get maxDuration => _maxDuration;
  Map<String, String> get lyric => _lyric;
  Map<String, String> get processedLyric => _processedLyric;
  Map<String, String> get processedTranslatedLyric => _processedTranslatedLyric;
  Map<String, String> get processedYrcLyric => _processedYrcLyric;
  bool get isLyricChanged => _islyricChanged;
  Duration get currentPosition => _currentPosition;
  Duration get duration => _duration;
  RawLyricResponse get lyricData => _lyricData;
  bool get hasLrc => _lyricData.hasLrc;
  bool get hasTranslation => _lyricData.hasTranslation;
  bool get hasWordByWord => _lyricData.hasWordByWord;
  AudioPlaylistProvider(this._api) {
    _setupAudioPlayerListeners();
    _audioPlayer.setVolume(_volume);
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _playerState = state;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _playerState = PlayerState.completed;
      _lyricsClear(); // Clear the lyrics when the song ends
      notifyListeners();
      if (_currentIndex != -1) {
        _playNext();
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
  }

  // Playlist management
  void addToPlaylist(Song song) {
    if (!_playlist.contains(song)) {
      _playlist.add(song.copyWith());

      if (_currentIndex == -1) {
        _currentIndex = 0;
      }
      notifyListeners();
    }
  }

  void addAllToPlaylist(List<Song> songs) {
    _playlist.addAll(songs.where((song) => !_playlist.contains(song)));
    if (_currentIndex == -1 && _playlist.isNotEmpty) {
      _currentIndex = 0;
    }
    notifyListeners();
  }

  void removeFromPlaylist(Song song) {
    final index = _playlist.indexOf(song);
    if (index != -1) {
      _playlist.removeAt(index);
      if (_currentIndex >= index && _currentIndex > 0) {
        _currentIndex--;
      }
      if (_playlist.isEmpty) {
        _currentIndex = -1;
      }
      notifyListeners();
    }
  }

  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = -1;
    _originalPlaylist.clear();
    _audioPlayer.stop();
    notifyListeners();
  }

  //==========================================playsong===================================
  //=====================================lyric===================================

  void _lyricStateNotifier() {
    _islyricChanged = true;

    notifyListeners();
    Timer(Duration(seconds: 5), () {
      _islyricChanged = false;
      notifyListeners();
    });
  }

  void _lyricsClear() {
    _processedLyric = {};
    _processedTranslatedLyric = {};
    _processedYrcLyric = {};
  }

  void _updateLyrics(RawLyricResponse lyricData) {
    _lyric = {
      'lyric': lyricData.lrc,
      'translatedLyric': lyricData.tlyric,
      'klyric': lyricData.klyric,
      'yrc': lyricData.yrc,
      'romalrc': lyricData.romalrc,
    };
    _processedLyric = lyricData.hasLrc ? lyricData.lrc.parsedLyrics() : {};
    _processedTranslatedLyric =
        lyricData.hasTranslation ? lyricData.tlyric.parsedLyrics() : {};
    _processedYrcLyric =
        lyricData.hasWordByWord
            ? lyricData.yrc.convertYrcLines().parsedLyrics()
            : {};
    _lyricStateNotifier();
    notifyListeners();

    //print(lyricData.yrc.convertYrcLines().parsedLyrics()['lyrics']);
    //int(lyricData.lrc.parsedLyrics()['lyrics']);
  }

  Future<void> _getSongLyric(String id) async {
    _lyricData = await _api.getLyricNew([id]);
    _updateLyrics(lyricData);
  }

  Future<void> _safePlay(String id) async {
    // Remove the mounted check
    await WidgetsBinding.instance.endOfFrame;
    try {
      final data = await _api.getSongUrlV2([id]);
      //debugPrint('audioUrl: ${data[0]}');

      //print('===============================');
      //print(data.toString());
      await _getSongLyric(id);
      if (data[0].isNotEmpty) {
        await _audioPlayer.play(UrlSource(data[0]));
      } else {
        debugPrint('Error: audioUrl is null');
      }
      _playerState = PlayerState.playing;

      notifyListeners();
      await _prefetchNextSong();
    } catch (e) {
      //print('Playback error: $e');
      _playerState = PlayerState.stopped;
      notifyListeners();
    }
  }

  Future<void> _prefetchNextSong() async {
    if (_playlist.isEmpty || _currentIndex == -1) return;

    final nextIndex = (_currentIndex + 1) % _playlist.length;
    final nextSong = _playlist[nextIndex];

    try {
      // 提前获取URL但不使用，只为填充缓存
      await _api.getSongUrlV1([nextSong.id]);
    } catch (e) {
      debugPrint('预加载失败: $e');
    }
  }

  // Playback control
  Future<void> playSong(Song song) async {
    final index = _playlist.indexOf(song);
    debugPrint('playSong index: $index');
    if (index != -1) {
      await _playAtIndex(index);
    } else {
      _currentSong = song;

      await _safePlay(song.id);
    }
  }

  Future<void> _playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      final song = _playlist[_currentIndex];
      _currentSong = song;

      try {
        await _safePlay(song.id);
      } catch (e) {
        debugPrint('Error playing song: $e');
        _playerState = PlayerState.stopped;
        notifyListeners();
      }

      _playerState = PlayerState.playing;
      notifyListeners();
    }
  }

  Future<void> play() async {
    if (_currentIndex != -1) {
      await _audioPlayer.resume();
    } else if (_playlist.isNotEmpty) {
      await _playAtIndex(0);
    }
  }

  //=========================downloadSong==========================
  Future<void> downloadSong(Song song) async {
    final url = await _api.getSongUrlV2([song.id]);
    String filename = url[0]
        .split('/')
        .last
        .split('?')
        .first
        .replaceAll('%20', ' ');
    String fileExtension = filename.ensureFileExtension().fileExtension!;
    String songName = song.name;
    filename =
        '$songName'
        '.$fileExtension';
    debugPrint('downloadfilename: $filename');
    final AuthProvider authProvider = AuthProvider(
      _api,
    ); // 创建AuthProvider实例并传递所需的参数
    final downloadPath = authProvider.getDownloadPath(); // 使用AuthProvider中的下载路径
    debugPrint('downloadPath: $downloadPath');
    if (url.isNotEmpty) {
      final audioDownloader = AudioDownloader();
      final file = await audioDownloader.downloadAudio(
        url[0],
        song.artists[0].name,
        song.album.name,
        filename,
        downloadPath, // 使用AuthProvider中的下载路径
      );
      if (file != null) {
        // 下载成功
        debugPrint('Downloaded: ${file.path}');
      } else {
        // 下载失败
        debugPrint('Download failed');
      }
    } else {
      debugPrint('Error: audioUrl is null');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _playerState = PlayerState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _playerState = PlayerState.stopped;

    notifyListeners();
  }

  Future<void> _playNext() async {
    if (_playlist.isEmpty) return;

    if (_isRepeatEnabled) {
      // 单曲循环模式
      await _playAtIndex(_currentIndex);
      return;
    }

    if (_isListLoopEnabled || _currentIndex < _playlist.length - 1) {
      // 使用取模运算实现循环
      final nextIndex = (_currentIndex + 1) % _playlist.length;
      await _playAtIndex(nextIndex);
    } else {
      // 既不循环也不重复，正常停止
      await stop();
    }
  }

  Future<void> next() async {
    await _playNext();
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    if (_isListLoopEnabled || _currentIndex > 0) {
      // 使用取模运算处理循环，注意处理负数的取模
      final prevIndex =
          (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _playAtIndex(prevIndex);
    }
  }

  // =============================Playback modes==========================================
  void toggleListLoop() {
    _isListLoopEnabled = !_isListLoopEnabled;
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;

    if (_isShuffleEnabled) {
      _originalPlaylist = List.from(_playlist);
      _playlist.shuffle();

      if (_currentIndex != -1) {
        final currentSong = _originalPlaylist[_currentIndex];
        _currentIndex = _playlist.indexOf(currentSong);
      }
    } else {
      if (_originalPlaylist.isNotEmpty) {
        _playlist = List.from(_originalPlaylist);

        if (_currentIndex != -1) {
          final currentSong = _playlist[_currentIndex];
          _currentIndex = _originalPlaylist.indexOf(currentSong);
        }
      }
    }

    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeatEnabled = !_isRepeatEnabled;
    notifyListeners();
  }

  // Volume and seek control
  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  // In AudioPlaylistProvider class
  Future<void> seek(double milliseconds) async {
    await _audioPlayer.seek(Duration(milliseconds: milliseconds.toInt()));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _playerState = PlayerState.disposed;
    super.dispose();
  }
}
