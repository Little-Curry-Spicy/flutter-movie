import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

/// 本地存储服务类
/// 使用 SharedPreferences 存储用户 token 和用户信息
class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  static StorageService get instance => _instance;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_info';

  /// 保存 token
  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      return false;
    }
  }

  SharedPreferences? _prefs;
  
  /// 初始化 SharedPreferences（在应用启动时调用）
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取 token（同步方法，需要先调用 init）
  String? getToken() {
    if (_prefs == null) return null;
    return _prefs!.getString(_tokenKey);
  }

  /// 异步获取 token
  Future<String?> getTokenAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// 保存用户信息
  Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      return await prefs.setString(_userKey, userJson);
    } catch (e) {
      return false;
    }
  }

  /// 获取用户信息（同步方法，需要先调用 init）
  User? getUser() {
    if (_prefs == null) return null;
    final userJson = _prefs!.getString(_userKey);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// 异步获取用户信息
  Future<User?> getUserAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null || userJson.isEmpty) {
        return null;
      }
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// 清除所有存储的数据
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      // 忽略错误
    }
  }
}

