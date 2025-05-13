import 'package:flutter/material.dart';
//import '../models/auth.dart';
import '../services/netease_api.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:hive/hive.dart';
import '../models/auth_model.dart';

class AuthProvider with ChangeNotifier {
  final NeteaseMusicApi _api;
  LoginResult? _loginResult;

  String? _error;

  bool _isLoading = false;

  String _downloadPath = r'c:\Users\bjh02\Music\musiclibrary';

  AuthProvider(this._api);
  //getters
  LoginResult? get loginResult => _loginResult;
  Profile? get user => _loginResult?.profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _loginResult?.profile != null;
  String get downloadPath => _downloadPath;
  String getDownloadPath() {
    return _downloadPath;
  }

  Future<void> _initDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    _downloadPath =
        '${directory.path}/${_loginResult?.profile.nickname ?? 'MyMusic'}';
    notifyListeners();
  }

  Future<void> updateDownloadPath(String newPath) async {
    _downloadPath = newPath;
    notifyListeners();
  }

  Future<void> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _loginResult = await _api.loginByPhone(phone, password);

      await _initDownloadPath(); // 登录成功后初始化路径
      _error = null;
    } catch (e) {
      _loginResult = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (_loginResult != null) {}
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.clearAuthInfo();
      _loginResult = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
