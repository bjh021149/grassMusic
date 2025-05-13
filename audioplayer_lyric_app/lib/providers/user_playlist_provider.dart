import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/user_playlist.dart';

import '../services/netease_api.dart';
import 'auth_provider.dart';

class UserPlaylistProvider with ChangeNotifier {
  static const String _boxName = 'user_playlists';
  static const String _lastUpdatedKey = 'last_updated';
  static const Duration _cacheDuration = Duration(days: 1);
  final NeteaseMusicApi _api;
  final AuthProvider authProvider;
  final List<UserPlaylist> _playlists = [];
  bool _isLoading = false;
  String? _error;
  String? _uid;
  late Box<UserPlaylist> _playlistBox;
  late Box _metaBox;

  List<UserPlaylist> get playlists => List.unmodifiable(_playlists);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  String? get uid => _uid;

  UserPlaylistProvider(this._api, this.authProvider) {
    Future.microtask(() => _init());
  }

  // 添加一个方法来处理认证状态变化
  void _handleAuthChange() {
    if (authProvider.isLoggedIn && authProvider.user != null) {
      fetchUserPlaylists(authProvider.user!.userId.toString());
    } else {
      clearCache();
    }
  }

  Future<void> _init() async {
    try {
      _playlistBox = await Hive.openBox<UserPlaylist>(_boxName);
      _metaBox = await Hive.openBox('${_boxName}_meta');

      // 添加认证状态监听
      authProvider.addListener(_handleAuthChange);

      // 初始加载
      await _loadFromCache();
      _handleAuthChange();
    } catch (e) {
      _error = 'Failed to initialize storage: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> _loadFromCache() async {
    _playlists.clear();
    _playlists.addAll(_playlistBox.values);
    _uid = _metaBox.get('uid');
    notifyListeners();
  }

  bool get _isCacheExpired {
    final lastUpdated = _metaBox.get(_lastUpdatedKey, defaultValue: 0) as int;
    return DateTime.now().millisecondsSinceEpoch - lastUpdated >
        _cacheDuration.inMilliseconds;
  }

  Future<void> fetchUserPlaylists(
    String uid, {
    bool forceRefresh = false,
    int limit = 30,
    int offset = 0,
  }) async {
    if (_uid == uid &&
        !forceRefresh &&
        !_isCacheExpired &&
        _playlists.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    _uid = authProvider.user?.userId.toString();
    notifyListeners();

    try {
      // 这里替换为你的实际API调用
      // final newPlaylists = await _api.getUserPlaylists(uid: uid, limit: limit, offset: offset);
      if (authProvider.isLoggedIn) {
        final newPlaylists = await _api.getUserPlaylists(uid: _uid!.toString());

        await _updateCache(newPlaylists);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch playlists: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateCache(List<UserPlaylist> newPlaylists) async {
    await _playlistBox.clear();
    await _playlistBox.addAll(newPlaylists);

    _playlists.clear();
    _playlists.addAll(newPlaylists);

    await _metaBox.put('uid', _uid);
    await _metaBox.put(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> addPlaylist(UserPlaylist playlist) async {
    await _playlistBox.add(playlist);
    _playlists.add(playlist);
    await _updateLastUpdated();
    notifyListeners();
  }

  Future<void> updatePlaylist(UserPlaylist updatedPlaylist) async {
    final index = _playlists.indexWhere((p) => p.id == updatedPlaylist.id);
    if (index != -1) {
      await _playlistBox.putAt(index, updatedPlaylist);
      _playlists[index] = updatedPlaylist;
      await _updateLastUpdated();
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      await _playlistBox.deleteAt(index);
      _playlists.removeAt(index);
      await _updateLastUpdated();
      notifyListeners();
    }
  }

  Future<void> _updateLastUpdated() async {
    await _metaBox.put(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearCache() async {
    await _playlistBox.clear();
    await _metaBox.clear();
    _playlists.clear();
    _uid = null;
    notifyListeners();
  }

  UserPlaylist? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((playlist) => playlist.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    // 移除监听器
    authProvider.removeListener(_handleAuthChange);
    _playlistBox.close();
    _metaBox.close();
    super.dispose();
  }
}
