import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tuple/tuple.dart';
// 在文件顶部
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';

import '../models/auth_model.dart';
import '../models/auth.dart';
import '../models/music.dart';
import '../models/user_playlist.dart';
import '../models/playlist_detail.dart';
// 仅非Web环境导入cookie管理包

// 在文件顶部添加新的模型类
class MusicAvailability {
  final bool success;
  final String message;

  MusicAvailability({required this.success, required this.message});

  factory MusicAvailability.fromJson(Map<String, dynamic> json) {
    return MusicAvailability(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class NeteaseMusicApi {
  static const String _baseUrl = 'http://192.168.1.4:3000';
  //final bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
  final Dio _dio;
  final SharedPreferences _prefs;

  final Map<String, Tuple2<String, DateTime>> _audioUrlCache = {};
  final Duration _urlCacheDuration = Duration(minutes: 5); // 缓存5分钟
  SharedPreferences get prefs => _prefs;
  // 非Web环境使用的CookieJar
  late final CookieJar? _cookieJar = !kIsWeb ? CookieJar() : null;
  NeteaseMusicApi(this._prefs)
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          contentType: 'application/x-www-form-urlencoded',
        ),
      ) {
    // 平台特定初始化
    if (!kIsWeb) {
      // 桌面端：使用CookieManager管理cookies
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // 公共拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _clearAuthInfo();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth methods
  AuthInfo _getAuthInfo() {
    return AuthInfo(
      musicU: _prefs.getString('netease_token') ?? '',
      userId: _prefs.getString('netease_userId') ?? '',
      csrf: _prefs.getString('netease_csrf') ?? '',
    );
  }

  Future<void> _setAuthInfo(AuthInfo authInfo) async {
    await _prefs.setString('netease_token', authInfo.musicU);
    await _prefs.setString('netease_userId', authInfo.userId);
    if (authInfo.csrf.isNotEmpty) {
      await _prefs.setString('netease_csrf', authInfo.csrf);
    }
  }

  Future<void> _clearAuthInfo() async {
    await _prefs.remove('netease_token');
    await _prefs.remove('netease_userId');
    await _prefs.remove('netease_csrf');
    if (!kIsWeb) {
      await _cookieJar!.deleteAll();
    }
  }

  Future<dynamic> _safeRequest(
    String endpoint, {
    Map<String, dynamic>? params,
    String method = 'GET',
    bool withCredentials = true,
    String? realIP,
  }) async {
    final cParams = params?.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );
    final rawData = await _cachedRequest(
      endpoint,
      params: cParams,
      method: method,
      withCredentials: withCredentials,
      realIP: realIP,
    );
    return rawData;
  }

  // Request wrapper with proper cookie handling
  Future<dynamic> _request(
    String endpoint, {
    Map<String, dynamic>? params,
    String method = 'GET',
    bool withCredentials = true,
    String? realIP,
  }) async {
    try {
      // Add timestamp to avoid caching for POST requests
      if (method == 'POST') {
        params ??= {};
        params['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Add realIP if provided
      if (realIP != null) {
        params ??= {};
        params['realIP'] = realIP;
      }

      // Prepare options
      Options options = Options(
        method: method,
        headers: await _createHeaders(),
        extra: {'withCredentials': withCredentials},
      );

      if (endpoint == '/song/url/v1') {
        options = Options(
          method: method,
          headers: await _createHeadersv1(),
          extra: {'withCredentials': withCredentials},
        );
      }

      final response = await _dio.request(
        endpoint,
        data: method == 'POST' ? params : null,
        queryParameters: method == 'GET' ? params : null,
        options: options,
      );

      // Handle cookies from response
      _handleResponseCookies(response.headers);

      /*Special handling for login endpoint
      if (endpoint == '/login/cellphone') {
        final Box<LoginResult> responseBox = Hive.box('loginBox');
        final result = response.data;

        if (result['code'] == 200) {
          final jsonResponse = jsonEncode(result);
          final loginResult = LoginResult.fromJson(jsonDecode(jsonResponse));
          await responseBox.put(endpoint, loginResult);

          return loginResult;
        } else {
          await _clearAuthInfo();
          throw Exception(result['msg']?.toString() ?? 'Login failed');
        }
      }*/

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Request failed: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    }
  }

  Future<Map<String, String>> _createHeaders() async {
    final authInfo = _getAuthInfo();
    final headers = <String, String>{};

    if (authInfo.csrf.isNotEmpty) {
      headers['X-CSRF-Token'] = authInfo.csrf;
    }

    return headers;
  }

  Future<Map<String, String>> _createHeadersv1() async {
    debugPrint('Ding');
    final authInfo = _getAuthInfo();
    final headers = <String, String>{};

    if (authInfo.csrf.isNotEmpty) {
      headers['X-CSRF-Token'] = authInfo.csrf;
    }

    // Add PC identifier if we have auth info
    if (authInfo.musicU.isNotEmpty && !kIsWeb) {
      // Get current cookies from CookieJar
      final uri = Uri.parse(_baseUrl);
      final cookies = await _cookieJar!.loadForRequest(uri);

      // Add or update the 'os' cookie
      cookies.add(Cookie('os', 'pc'));
      await _cookieJar.saveFromResponse(uri, cookies);
    }

    return headers;
  }

  void _handleResponseCookies(Headers headers) {
    final cookies = headers['set-cookie'];
    if (cookies != null) {
      final csrf = _extractCookie(cookies.join('; '), '__csrf');
      if (csrf != null) {
        _prefs.setString('netease_csrf', csrf);
      }
    }
  }

  String? _extractCookie(String? cookieStr, String key) {
    if (cookieStr == null || cookieStr.isEmpty) return null;
    final match = RegExp('$key=([^;]+)').firstMatch(cookieStr);
    return match?.group(1);
  }

  // API Methods
  Future<LoginResult> loginByPhone(String phone, String password) async {
    try {
      final response = await _safeRequest(
        '/login/cellphone',
        params: {'phone': phone, 'password': Uri.encodeComponent(password)},
        method: 'POST',
      );

      //debugPrint('Login raw response: ${response.toString()}');

      // 确保响应是 Map 类型
      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (response['code'] == 200) {
        // 处理 tokenJsonStr 字段（需要特殊处理）
        if (response['bindings'] is List) {
          for (var binding in response['bindings']) {
            if (binding['tokenJsonStr'] is String) {
              binding['tokenJsonStr'] = jsonDecode(binding['tokenJsonStr']);
            }
          }
        }

        // 创建登录结果对象
        final loginResult = LoginResult.fromJson(response);

        // 保存到 Hive
        final Box<LoginResult> responseBox = Hive.box('loginBox');
        await responseBox.put('/login/cellphone', loginResult);

        // 处理 cookie
        final cookie = loginResult.cookie;
        if (cookie.isEmpty) {
          throw Exception('Login successful but no cookie received');
        }

        final musicU = _extractCookie(cookie, 'MUSIC_U');
        final csrf = _extractCookie(cookie, '__csrf');
        //debugPrint(musicU!);
        if (musicU == null) {
          throw Exception('Failed to extract MUSIC_U');
        }

        // 保存认证信息
        await _setAuthInfo(
          AuthInfo(
            musicU: musicU,
            userId: loginResult.account.id.toString(),
            csrf: csrf ?? '',
          ),
        );

        return loginResult;
      } else {
        await _clearAuthInfo();
        throw Exception(response['msg']?.toString() ?? 'Login failed');
      }
    } catch (e) {
      await _clearAuthInfo();
      debugPrint('Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<List<Song>> getDailyRecommendSongs() async {
    final result = await _safeRequest('/recommend/songs');

    if (result['code'] == 200) {
      final dailySongs = result['data']['dailySongs'];
      if (dailySongs is List) {
        return dailySongs.map((e) => Song.fromJson(e)).toList();
      }
      throw Exception('Unexpected data format for daily songs');
    }
    throw Exception(result['msg'] ?? 'Failed to get recommendations');
  }

  Future<Map<String, String>> getLyric(List<String> songId) async {
    final result = await _safeRequest('/lyric', params: {'id': songId});

    if (result['code'] == 200) {
      return {
        'lyric': result['lrc']?['lyric'] ?? '', // 原始歌词
        'translatedLyric': result['tlyric']?['lyric'] ?? '', // 翻译歌词
        'klyric': result['klyric']?['lyric'] ?? '', // 卡拉OK歌词
        'romalrc': result['romalrc']?['lyric'] ?? '', // 拼音歌词
      };
    }
    throw Exception(result['msg'] ?? 'Failed to fetch lyrics');
  }

  Future<RawLyricResponse> getLyricNew(List<String> songId) async {
    final result = await _safeRequest('/lyric/new', params: {'id': songId});

    if (result['code'] == 200) {
      return RawLyricResponse(
        sgc: result['sgc'] ?? false,
        sfy: result['sfy'] ?? false,
        qfy: result['qfy'] ?? false,
        lrc: result['lrc']?['lyric'] ?? '', // 标准歌词文本
        tlyric: result['tlyric']?['lyric'] ?? '', // 翻译歌词文本
        klyric: result['klyric']?['lyric'] ?? '', // 卡拉OK歌词文本
        yrc: result['yrc']?['lyric'] ?? '', // 逐字歌词文本
        romalrc: result['romalrc']?['lyric'] ?? '', // 罗马音歌词文本
        code: 200,
      );
    }

    throw Exception(result['msg'] ?? 'Failed to fetch lyrics');
  }

  Future<List<UserPlaylist>> getUserPlaylists({
    required dynamic uid,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final result = await _safeRequest(
        '/user/playlist',
        params: {'uid': uid, 'limit': limit, 'offset': offset},
      );

      if (result['code'] == 200) {
        final playlists =
            (result['playlist'] ?? result['data']['playlist']) as List?;
        if (playlists != null) {
          return playlists.map((e) => UserPlaylist.fromJson(e)).toList();
        }
      }
      throw Exception(result['msg'] ?? 'Invalid playlist data format');
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }

  Future<List<String>> getPlaylistDetail(
    String playlistId, {
    int subscribersCount = 8,
  }) async {
    final result = await _safeRequest(
      '/playlist/detail',
      params: {'id': playlistId, 's': subscribersCount},
    );

    if (result['code'] == 200) {
      // 处理不完整的歌曲列表
      final playlist = result['playlist'];
      final trackIds =
          (playlist['trackIds'] as List)
              .map((e) => e['id'].toString())
              .toList();
      debugPrint(trackIds.toString());
      return trackIds;
    }
    throw Exception(result['msg'] ?? 'Failed to get playlist details');
  }

  Future<List<Song>> getSongsDetail(List<String> songIds) async {
    final result = await _safeRequest(
      '/song/detail',
      params: {'ids': songIds.join(',')},
    );
    //print(result['songs'][0].toString());
    if (result['code'] == 200) {
      return (result['songs'] as List).map((e) => Song.fromJson(e)).toList();
    }
    throw Exception(result['msg'] ?? 'Failed to get songs detail');
  }

  /* 新增带缓存的请求方法*/
  Future<Map<String, dynamic>> _cachedRequest(
    String endpoint, {
    Duration cacheDuration = const Duration(minutes: 10),
    Map<String, dynamic>? params,
    String method = 'GET',
    bool withCredentials = true,
    String? realIP,
  }) async {
    final cacheKey = '$endpoint${params?.toString() ?? ''}';
    final now = DateTime.now();

    // 尝试从缓存读取
    final cached = _prefs.getString(cacheKey);
    if (cached != null) {
      final data = jsonDecode(cached);
      final timestamp = DateTime.parse(data['timestamp']);
      if (now.difference(timestamp) < cacheDuration) {
        return data['response'];
      }
    }

    // 发起网络请求
    final rawData = await _request(
      endpoint,
      params: params,
      method: method,
      withCredentials: withCredentials,
      realIP: realIP,
    );

    // 更新缓存
    await _prefs.setString(
      cacheKey,
      jsonEncode({'timestamp': now.toIso8601String(), 'response': rawData}),
    );

    return rawData;
  }

  Future<List<Song>> getSongUrlV1(
    List<String> ids, {
    String level = 'hires',
  }) async {
    final result1 = await Future.wait(ids.map((id) => _checkMusic(id)));
    final avaibialIds = <String>[];
    for (int i = 0; i < ids.length; i++) {
      if (result1[i].success) {
        avaibialIds.add(ids[i]);
      }
    }

    final now = DateTime.now();
    final uncachedIds =
        avaibialIds.where((id) {
          return !_audioUrlCache.containsKey(id) ||
              now.difference(_audioUrlCache[id]!.item2) > _urlCacheDuration;
        }).toList();

    if (uncachedIds.isNotEmpty) {
      final result = await _safeRequest(
        '/song/url/v1',
        params: {'id': uncachedIds.join(','), 'level': level},
      );

      if (result['code'] == 200) {
        for (final item in result['data'] as List) {
          _audioUrlCache[item['id'].toString()] = Tuple2(
            item['url']?.toString() ?? '',
            now,
          );
        }
      }
    }

    return ids.map((id) {
      final cached = _audioUrlCache[id];
      return Song(
        id: id,
        name: '',
        artists: [],
        album: Album(id: '', name: '', picUrl: ''),
        duration: 0,
        audioUrl: cached?.item1,
      );
    }).toList();
  }

  Future<List<String>> getSongUrlV2(
    List<String> ids, {
    String level = 'hires',
  }) async {
    final result1 = await Future.wait(ids.map((id) => _checkMusic(id)));
    final avaibialIds = <String>[];
    for (int i = 0; i < ids.length; i++) {
      if (result1[i].success) {
        avaibialIds.add(ids[i]);
      }
    }

    final result = await _safeRequest(
      '/song/url/v1',
      params: {'id': avaibialIds.join(','), 'level': level},
    );

    if (result['code'] == 200) {
      return (result['data'] as List)
          .map(
            (e) =>
                Song(
                  id: e['id'].toString(),
                  name: '',
                  artists: [],
                  album: Album(id: '', name: '', picUrl: ''),
                  duration: 0,
                  audioUrl: e['url'],
                  size: e['size'].toString(),
                ).audioUrl.toString(),
          )
          .toList();
    }
    throw Exception(result['msg'] ?? 'Failed to get song URLs');
  }

  // 修改 getPlaylistDetailFull 方法
  Future<PlaylistDetail> getPlaylistDetailFull(
    String playlistId, {
    int initialLoadCount = 20, // 默认初始加载20首
  }) async {
    final result = await _safeRequest(
      '/playlist/detail',
      params: {'id': playlistId},
    );

    if (result['code'] == 200) {
      final playlist = result['playlist'];

      // 获取全部歌曲ID列表
      final allTrackIds =
          (playlist['trackIds'] as List)
              .map((e) => e['id'].toString())
              .toList();

      // 只加载初始数量的歌曲ID
      final initialTrackIds = allTrackIds.take(initialLoadCount).toList();

      // 获取初始歌曲详情
      final initialSongs = await getSongsDetail(initialTrackIds);

      // 获取初始歌曲URL
      //final initialSongsWithUrl = await getSongUrlV1(initialTrackIds);

      // 合并初始歌曲信息和URL
      final mergedInitialSongs = initialSongs.toList();

      return PlaylistDetail(
        id: playlist['id'].toString(),
        name: playlist['name'].toString(),
        coverImgUrl: playlist['coverImgUrl'].toString(),
        creator: UserProfile.fromJson(playlist['creator']),
        description: playlist['description']?.toString() ?? '',
        subscribed: playlist['subscribed'] ?? false,
        trackCount: playlist['trackCount'] ?? 0,
        playCount: playlist['playCount'] ?? 0,
        songs: mergedInitialSongs,
        allTrackIds: allTrackIds, // 保存全部歌曲ID供后续加载
        loadedTrackIds: initialTrackIds, // 已加载的歌曲ID
        createTime: DateTime.fromMillisecondsSinceEpoch(playlist['createTime']),
        updateTime: DateTime.fromMillisecondsSinceEpoch(playlist['updateTime']),
      );
    }
    throw Exception(result['msg'] ?? 'Failed to get playlist details');
  }

  // 添加加载更多歌曲的方法
  Future<List<Song>> loadMoreSongs(
    PlaylistDetail playlistDetail, {
    int loadCount = 20,
  }) async {
    // 获取未加载的歌曲ID
    final unloadedIds =
        playlistDetail.allTrackIds
            .where((id) => !playlistDetail.loadedTrackIds.contains(id))
            .take(loadCount)
            .toList();

    if (unloadedIds.isEmpty) return [];

    // 获取歌曲详情
    final songs = await getSongsDetail(unloadedIds);

    return songs.toList();
  }

  Future<Map<String, dynamic>> checkLoginStatus() async {
    try {
      final status = await _safeRequest('/login/status');
      if (status['code'] == 200 && status['profile'] != null) {
        return {
          'isLoggedIn': true,
          'profile': UserProfile.fromJson(status['profile']),
        };
      }
      return {'isLoggedIn': false, 'profile': null};
    } catch (e) {
      return {'isLoggedIn': false, 'profile': null};
    }
  }

  Future<MusicAvailability> _checkMusic(
    String songId, {
    int br = 999000,
  }) async {
    final result = await _safeRequest(
      '/check/music',
      params: {'id': songId, 'br': br},
    );
    return MusicAvailability.fromJson(result);
  }

  Future<void> clearAuthInfo() async => _clearAuthInfo();
}
