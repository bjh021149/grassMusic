import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sidebarx/sidebarx.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Models
import 'package:audioplayer_lyric_app/models/user_playlist.dart';
import 'package:audioplayer_lyric_app/models/auth_model.dart';
//import './models/music.dart';
// Providers
import './providers/audioplayers_playlist_provider.dart';
import './providers/auth_provider.dart';
import './providers/user_playlist_provider.dart';

// Services
import './services/netease_api.dart';

// Screens

import './screens/audioplayers_playlist_screen.dart';
import './screens/user_profile_display.dart';
import './screens/login_screen.dart';
import './screens/user_playlist_screen.dart';
import './screens/playlist_detail_screen.dart';
import './screens/display_song.dart';
import './widgets/lyrics_plugin.dart';
import 'widgets/lrc_lyrics_plugin.dart';

Future<void> _initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(LoginResultAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(BindingAdapter());
  await Hive.openBox<LoginResult>('loginBox');

  Hive.registerAdapter(UserPlaylistAdapter());
  await Hive.openBox<UserPlaylist>('user_playlists');
  await Hive.openBox('user_playlists_meta');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive for local storage
    await _initializeHive();

    // Initialize shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Create API instance with dependencies
    final api = NeteaseMusicApi(prefs);

    runApp(
      MultiProvider(
        providers: [
          Provider<NeteaseMusicApi>.value(value: api),
          ChangeNotifierProvider(
            create: (context) => AudioPlaylistProvider(api),
          ),
          ChangeNotifierProvider(create: (context) => AuthProvider(api)),
          ChangeNotifierProxyProvider<AuthProvider, UserPlaylistProvider>(
            create:
                (context) =>
                    UserPlaylistProvider(api, context.read<AuthProvider>()),
            update:
                (context, authProvider, previous) =>
                    previous ?? UserPlaylistProvider(api, authProvider),
          ),
        ],
        child: const MusicPlayerApp(),
      ),
    );
  } catch (e) {
    // Global error handling for initialization
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('初始化失败: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

/// Main application wrapper
class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        //返回第一屏 PlayerHomeScreen(),
        '/': (context) => const PlayerHomeScreen(),
        '/playlists': (context) => const UserPlaylistScreen(),
        '/playlist/detail':
            (context) => PlaylistDetailScreen(
              playlistId: ModalRoute.of(context)!.settings.arguments.toString(),
            ),
        '/audioplayerlist': (context) => const AudioPlaylistScreen(),
      },
    );
  }
}

/// Main player screen
class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  // ignore: unused_field
  double _sliderValue = 0;
  final SidebarXController _sidebarController = SidebarXController(
    selectedIndex: 0,
    extended: true,
  );
  bool _isExtended = true;
  bool _isSmallScreen = false;
  DateTime? _lastTap;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
      _checkScreenSize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Provider.of<AuthProvider>(context, listen: false).checkLoginStatus();
  }

  void _showAuthDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content:
                authProvider.isLoggedIn
                    ? UserProfileDrawer(
                      authProvider: authProvider,
                      onCloseDrawer: () {
                        Navigator.of(context).pop();
                      },
                    )
                    : LoginForm(
                      authProvider: authProvider,
                      onSuccess: () {
                        Navigator.of(context).pop();
                      },
                    ),
          ),
    );
  }

  void _checkScreenSize() {
    final newSize = MediaQuery.of(context).size.width < 600;
    if (newSize != _isSmallScreen) {
      setState(() {
        _isSmallScreen = newSize;
        if (_isSmallScreen) {
          _startAutoHideTimer();
        } else {
          _autoHideTimer?.cancel();
        }
      });
    }
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isSmallScreen && _sidebarController.extended) {
        setState(() {
          _sidebarController.setExtended(false);
        });
      }
    });
  }

  void _handleDoubleTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) < Duration(milliseconds: 300)) {
      setState(() {
        _sidebarController.setExtended(!_sidebarController.extended);
        if (_sidebarController.extended) {
          _startAutoHideTimer();
        }
      });
    }
    _lastTap = now;
  }
  /*bool _getIsSmallScreen(BuildContext context) {
    if (!kIsWeb) {
      return false;
    } else {
      return true;
    }
  }*/

  AppBar _buildAppBar(BuildContext context, AuthProvider authProvider) {
    return AppBar(
      title: const Text('Music Player', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      backgroundColor: Colors.deepPurple,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.playlist_play, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/audioplayerlist'),
          tooltip: '播放列表',
        ),
        IconButton(
          icon: const Icon(Icons.library_music, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/playlists'),
          tooltip: '我的歌单',
        ),
        IconButton(
          icon:
              authProvider.isLoggedIn && authProvider.user != null
                  ? CircleAvatar(
                    backgroundImage: NetworkImage(authProvider.user!.avatarUrl),
                    radius: 16,
                  )
                  : const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () => _showAuthDialog(context),
          tooltip: authProvider.isLoggedIn ? '用户资料' : '登录',
        ),
      ],
    );
  }

  Widget _buildSideBar(BuildContext context, AuthProvider authProvider) {
    return SidebarX(
      controller: _sidebarController,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: Colors.white.withOpacity(0.2),
        textStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.9),
          size: 24,
        ),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(color: Color(0xFF2A2D3E)),
      ),
      headerBuilder: (context, extended) {
        return authProvider.isLoggedIn && authProvider.user != null
            ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: extended ? 40 : 30,
                    backgroundImage: NetworkImage(authProvider.user!.avatarUrl),
                  ),
                  if (extended) ...[
                    const SizedBox(height: 10),
                    Text(
                      authProvider.user!.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${authProvider.user!.userId}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            )
            : SizedBox(
              height: extended ? 120 : 60,
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  size: extended ? 60 : 40,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            );
      },
      footerDivider: Divider(color: Colors.white.withOpacity(0.3), height: 1),
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: '首页',
          onTap:
              () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              ),
        ),
        SidebarXItem(
          icon: Icons.playlist_play,
          label: '播放列表',
          onTap: () => Navigator.pushNamed(context, '/audioplayerlist'),
        ),
        SidebarXItem(
          icon: Icons.library_music,
          label: '我的歌单',
          onTap: () => Navigator.pushNamed(context, '/playlists'),
        ),
        SidebarXItem(
          icon: authProvider.isLoggedIn ? Icons.person : Icons.login,
          label: authProvider.isLoggedIn ? '用户资料' : '登录',
          onTap: () => _showAuthDialog(context),
        ),
      ],
    );
  }

  Widget _buildLyricsSection(AudioPlaylistProvider audioState) {
    return Expanded(
      flex: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              minHeight: 200, // 最小高度保证
              maxHeight: constraints.maxHeight * 0.7, // 最大高度限制
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildLyricsContent(audioState),
          );
        },
      ),
    );
  }

  Widget _buildLyricsContent(AudioPlaylistProvider audioState) {
    return Consumer<AudioPlaylistProvider>(
      builder: (context, audioState, child) {
        if (audioState.hasWordByWord) {
          return LyricsWidget(
            lyrics: audioState.processedYrcLyric['lyrics'] ?? '',
            position: audioState.currentPosition,
            duration: audioState.duration,
            isLyricChanged: audioState.isLyricChanged,
            playerState: audioState.playerState,
          );
        } else if (audioState.hasLrc) {
          return LrcLyricsWidget(
            lrcText: audioState.processedLyric['lyrics'] ?? '',
            position: audioState.currentPosition,
            duration: audioState.duration,
            isLyricChanged: audioState.isLyricChanged,
          );
        }
        return const Center(
          child: Text('暂无歌词', style: TextStyle(color: Colors.white70)),
        );
      },
    );
  }

  Widget _buildSongInfoSection(AudioPlaylistProvider audioState) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<AudioPlaylistProvider>(
              builder: (context, audioState, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child:
                      audioState.currentSong.id.isNotEmpty
                          ? DisplaySong(
                            key: ValueKey(audioState.currentSong.id),
                            song: audioState.currentSong,
                            imageSize: 150,
                            titleStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            artistStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                            showDuration: false,
                          )
                          : const Center(
                            child: Text(
                              '没有正在播放的歌曲',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildProgressBar(audioState),
            const SizedBox(height: 20),
            _buildControlButtons(audioState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(AudioPlaylistProvider audioState) {
    // 确保duration不为零
    final maxDuration = audioState.duration.inMilliseconds.toDouble();
    final currentPos = audioState.currentPosition.inMilliseconds.toDouble();

    // 边界检查
    final clampedValue = currentPos.clamp(0.0, maxDuration);
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            // ignore: deprecated_member_use
            inactiveTrackColor: const Color.fromARGB(62, 237, 233, 233),
            thumbColor: Colors.white,
            // ignore: deprecated_member_use
            overlayColor: const Color.fromARGB(35, 255, 255, 255),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            min: 0,
            max: maxDuration,
            value: clampedValue,
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
              audioState.seek(value);
            },
            onChangeEnd: (value) {
              audioState.seek(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(audioState.currentPosition),
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                _formatDuration(audioState.duration),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(AudioPlaylistProvider audioState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 36),
          color: Colors.white,
          onPressed: audioState.previous,
        ),
        const SizedBox(width: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: IconButton(
            icon: Icon(
              audioState.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 36,
            ),
            color: Colors.deepPurple,
            onPressed: () {
              if (audioState.isPlaying) {
                audioState.pause();
              } else {
                audioState.play();
              }
            },
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 36),
          color: Colors.white,
          onPressed: audioState.next,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final audioState = Provider.of<AudioPlaylistProvider>(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: _isSmallScreen ? _handleDoubleTap : null,
      onTap:
          _isSmallScreen
              ? () {
                if (_sidebarController.extended) {
                  _startAutoHideTimer();
                }
              }
              : null,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(30, 219, 218, 222),
        appBar: !isSmallScreen ? _buildAppBar(context, authProvider) : null,
        drawer: isSmallScreen ? _buildSideBar(context, authProvider) : null,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                "http://192.168.1.6:5244/d/music/0/bg5.jpg?sign=WMTz88SzsCOZz-spqA6IfVazRXAFjXeX4UKDAIf257Y=:0",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Color.fromRGBO(222, 222, 222, 0.4)),
              ),
            ),
            Row(
              children: [
                if (isSmallScreen) _buildSideBar(context, authProvider),
                Expanded(
                  child: Column(
                    children: [
                      _buildLyricsSection(audioState),
                      _buildSongInfoSection(audioState),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
