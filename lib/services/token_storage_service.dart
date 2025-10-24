import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Token 持久化服务
/// 使用 SharedPreferences 保存与清除认证信息
class TokenStorageService {
  TokenStorageService._internal();
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;

  /// 保存访问令牌和刷新令牌
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.authTokenKey, accessToken);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(ApiConfig.refreshTokenKey, refreshToken);
    } else {
      await prefs.remove(ApiConfig.refreshTokenKey);
    }
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

  /// 清除本地保存的令牌
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.authTokenKey);
    await prefs.remove(ApiConfig.refreshTokenKey);
  }
}
