import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Token 持久化服务
/// 使用 SharedPreferences 保存与清除认证信息
class TokenStorageService {
  TokenStorageService._internal();
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;

  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _tokenExpiresAtKey = 'token_expires_at';

  /// 保存访问令牌和刷新令牌
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.authTokenKey, accessToken);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(ApiConfig.refreshTokenKey, refreshToken);
    } else {
      await prefs.remove(ApiConfig.refreshTokenKey);
    }

    // 保存过期时间
    if (expiresAt != null) {
      await prefs.setString(_tokenExpiresAtKey, expiresAt.toIso8601String());
    } else {
      await prefs.remove(_tokenExpiresAtKey);
    }
  }

  /// 保存用户信息
  Future<void> saveUserInfo({
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userEmailKey, userEmail);
    await prefs.setString(_userRoleKey, userRole);
  }

  /// 读取本地保存的访问令牌
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.authTokenKey);
  }

  /// 读取本地保存的刷新令牌
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.refreshTokenKey);
  }

  /// 读取用户角色
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// 读取用户ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// 读取用户名称
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// 读取用户邮箱
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// 读取 Token 过期时间
  Future<DateTime?> getTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAtString = prefs.getString(_tokenExpiresAtKey);
    if (expiresAtString == null) return null;

    try {
      return DateTime.parse(expiresAtString);
    } catch (e) {
      print('⚠️ 解析 token 过期时间失败: $e');
      return null;
    }
  }

  /// 检查用户是否为管理员
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  /// 清除本地保存的令牌和用户信息
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.authTokenKey);
    await prefs.remove(ApiConfig.refreshTokenKey);
    await prefs.remove(_tokenExpiresAtKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }
}
