import 'dart:developer';

import 'package:df_admin_mobile/services/database/token_dao.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:get/get.dart';

/// Token 数据结构
class TokenData {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime? expiresAt;
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const TokenData({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
    this.expiresAt,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get needsRefresh {
    if (expiresAt == null) return false;
    // 提前5分钟刷新
    final refreshTime = expiresAt!.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(refreshTime);
  }

  @override
  String toString() {
    return 'TokenData(userId: $userId, accessToken: ${accessToken.substring(0, 10)}..., expiresAt: $expiresAt)';
  }
}

/// 统一的 Token 管理器
/// 
/// 作为 Token 操作的 Single Source of Truth
/// 负责协调 SharedPreferences、SQLite、内存状态的一致性
class TokenManager {
  TokenManager._internal();
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;

  final TokenStorageService _tokenStorage = TokenStorageService();
  final TokenDao _tokenDao = TokenDao();

  // 内存中的 Token 缓存
  TokenData? _cachedToken;

  /// 获取 HttpService (延迟获取避免循环依赖)
  HttpService? get _httpService {
    try {
      return Get.find<HttpService>();
    } catch (e) {
      log('⚠️ [TokenManager] HttpService 未注册: $e');
      return null;
    }
  }

  /// 当前 Token 数据 (只读)
  TokenData? get currentToken => _cachedToken;

  /// 是否已认证
  bool get isAuthenticated => _cachedToken != null && !_cachedToken!.isExpired;

  /// 当前用户ID
  String? get currentUserId => _cachedToken?.userId;

  /// 当前 AccessToken
  String? get accessToken => _cachedToken?.accessToken;

  // ==================== 核心操作 ====================

  /// 保存 Token (统一入口)
  /// 
  /// 会同步写入:
  /// 1. SharedPreferences (用于 HttpService 拦截器快速获取)
  /// 2. SQLite (用于持久化和恢复)
  /// 3. 内存缓存
  /// 4. HttpService 状态
  Future<void> saveToken(TokenData tokenData) async {
    log('📝 [TokenManager] 保存 Token: userId=${tokenData.userId}');
    
    try {
      // 1. 保存到 SharedPreferences (最先，因为 HttpService 拦截器依赖它)
      await _tokenStorage.saveTokens(
        accessToken: tokenData.accessToken,
        refreshToken: tokenData.refreshToken,
        expiresAt: tokenData.expiresAt,
      );
      
      // 保存用户信息到 SharedPreferences
      if (tokenData.userName != null && tokenData.userEmail != null) {
        await _tokenStorage.saveUserInfo(
          userId: tokenData.userId,
          userName: tokenData.userName!,
          userEmail: tokenData.userEmail!,
          userRole: tokenData.userRole ?? 'user',
        );
      }
      log('   ✅ SharedPreferences 已保存');

      // 2. 保存到 SQLite
      await _tokenDao.saveToken(
        userId: tokenData.userId,
        accessToken: tokenData.accessToken,
        refreshToken: tokenData.refreshToken,
        tokenType: tokenData.tokenType,
        expiresIn: tokenData.expiresIn,
        userName: tokenData.userName ?? '',
        userEmail: tokenData.userEmail ?? '',
      );
      log('   ✅ SQLite 已保存');

      // 3. 更新内存缓存
      _cachedToken = tokenData;
      log('   ✅ 内存缓存已更新');

      // 4. 更新 HttpService 状态
      _httpService?.setAuthToken(tokenData.accessToken);
      _httpService?.setUserId(tokenData.userId);
      log('   ✅ HttpService 状态已更新');

      log('✅ [TokenManager] Token 保存完成');
    } catch (e) {
      log('❌ [TokenManager] 保存 Token 失败: $e');
      rethrow;
    }
  }

  /// 清除所有 Token (统一入口)
  /// 
  /// 会同步清除:
  /// 1. SharedPreferences
  /// 2. SQLite (指定用户或全部)
  /// 3. 内存缓存
  /// 4. HttpService 状态
  Future<void> clearToken({String? userId}) async {
    final targetUserId = userId ?? _cachedToken?.userId;
    log('🗑️ [TokenManager] 清除 Token: userId=$targetUserId');

    try {
      // 1. 清除 SharedPreferences
      await _tokenStorage.clearTokens();
      log('   ✅ SharedPreferences 已清除');

      // 2. 清除 SQLite
      if (targetUserId != null) {
        await _tokenDao.deleteTokenByUserId(targetUserId);
        log('   ✅ SQLite 用户 Token 已删除');
      } else {
        await _tokenDao.deleteAllTokens();
        log('   ✅ SQLite 所有 Token 已删除');
      }

      // 3. 清除内存缓存
      _cachedToken = null;
      log('   ✅ 内存缓存已清除');

      // 4. 清除 HttpService 状态
      _httpService?.clearAuthToken();
      _httpService?.clearUserId();
      log('   ✅ HttpService 状态已清除');

      log('✅ [TokenManager] Token 清除完成');
    } catch (e) {
      log('❌ [TokenManager] 清除 Token 失败: $e');
      // 即使失败也要尽量清除内存状态
      _cachedToken = null;
      _httpService?.clearAuthToken();
      _httpService?.clearUserId();
      rethrow;
    }
  }

  /// 从存储恢复 Token (应用启动时调用)
  /// 
  /// 优先级:
  /// 1. 先尝试从 SharedPreferences 恢复 (快速)
  /// 2. 如果失败，尝试从 SQLite 恢复
  /// 3. 验证 Token 是否过期
  Future<TokenData?> restoreToken() async {
    log('🔄 [TokenManager] 恢复 Token...');

    try {
      // 1. 尝试从 SharedPreferences 恢复
      final accessToken = await _tokenStorage.getAccessToken();
      final refreshToken = await _tokenStorage.getRefreshToken();
      final userId = await _tokenStorage.getUserId();
      final expiresAt = await _tokenStorage.getTokenExpiresAt();
      final userName = await _tokenStorage.getUserName();
      final userEmail = await _tokenStorage.getUserEmail();
      final userRole = await _tokenStorage.getUserRole();

      if (accessToken != null && accessToken.isNotEmpty && userId != null) {
        final tokenData = TokenData(
          userId: userId,
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
          expiresAt: expiresAt,
          userName: userName,
          userEmail: userEmail,
          userRole: userRole,
        );

        if (!tokenData.isExpired) {
          _cachedToken = tokenData;
          _httpService?.setAuthToken(accessToken);
          _httpService?.setUserId(userId);
          log('✅ [TokenManager] 从 SharedPreferences 恢复成功');
          return tokenData;
        } else {
          log('⚠️ [TokenManager] SharedPreferences 中的 Token 已过期');
        }
      }

      // 2. 尝试从 SQLite 恢复
      final dbToken = await _tokenDao.getLatestToken();
      if (dbToken != null) {
        final dbUserId = dbToken['user_id'] as String;
        final isExpired = await _tokenDao.isTokenExpired(dbUserId);
        
        if (!isExpired) {
          final tokenData = TokenData(
            userId: dbUserId,
            accessToken: dbToken['access_token'] as String,
            refreshToken: dbToken['refresh_token'] as String? ?? '',
            tokenType: dbToken['token_type'] as String? ?? 'Bearer',
            expiresIn: dbToken['expires_in'] as int? ?? 3600,
            expiresAt: dbToken['expires_at'] != null 
                ? DateTime.parse(dbToken['expires_at'] as String)
                : null,
            userName: dbToken['user_name'] as String?,
            userEmail: dbToken['user_email'] as String?,
          );

          // 同步回 SharedPreferences
          await _tokenStorage.saveTokens(
            accessToken: tokenData.accessToken,
            refreshToken: tokenData.refreshToken,
            expiresAt: tokenData.expiresAt,
          );
          if (tokenData.userName != null && tokenData.userEmail != null) {
            await _tokenStorage.saveUserInfo(
              userId: tokenData.userId,
              userName: tokenData.userName!,
              userEmail: tokenData.userEmail!,
              userRole: tokenData.userRole ?? 'user',
            );
          }

          _cachedToken = tokenData;
          _httpService?.setAuthToken(tokenData.accessToken);
          _httpService?.setUserId(tokenData.userId);
          log('✅ [TokenManager] 从 SQLite 恢复成功');
          return tokenData;
        } else {
          log('⚠️ [TokenManager] SQLite 中的 Token 已过期');
        }
      }

      log('ℹ️ [TokenManager] 没有有效的 Token 可恢复');
      return null;
    } catch (e) {
      log('❌ [TokenManager] 恢复 Token 失败: $e');
      return null;
    }
  }

  /// 更新 AccessToken (刷新后调用)
  Future<void> updateAccessToken({
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    if (_cachedToken == null) {
      log('⚠️ [TokenManager] 无法更新 Token: 当前无缓存 Token');
      return;
    }

    final newTokenData = TokenData(
      userId: _cachedToken!.userId,
      accessToken: accessToken,
      refreshToken: refreshToken ?? _cachedToken!.refreshToken,
      tokenType: _cachedToken!.tokenType,
      expiresIn: _cachedToken!.expiresIn,
      expiresAt: expiresAt ?? _cachedToken!.expiresAt,
      userName: _cachedToken!.userName,
      userEmail: _cachedToken!.userEmail,
      userRole: _cachedToken!.userRole,
    );

    await saveToken(newTokenData);
    log('✅ [TokenManager] AccessToken 已更新');
  }

  /// 检查并返回有效的 Token
  /// 如果过期返回 null
  Future<String?> getValidAccessToken() async {
    // 1. 先检查内存缓存
    if (_cachedToken != null && !_cachedToken!.isExpired) {
      return _cachedToken!.accessToken;
    }

    // 2. 尝试从存储恢复
    final restored = await restoreToken();
    if (restored != null && !restored.isExpired) {
      return restored.accessToken;
    }

    return null;
  }

  /// 检查 Token 是否需要刷新
  bool get needsRefresh => _cachedToken?.needsRefresh ?? false;

  /// 获取 RefreshToken (用于刷新)
  String? get refreshToken => _cachedToken?.refreshToken;

  /// 调试: 打印当前状态
  void debugPrintStatus() {
    log('========== TokenManager Status ==========');
    log('  isAuthenticated: $isAuthenticated');
    log('  currentUserId: $currentUserId');
    log('  cachedToken: $_cachedToken');
    log('==========================================');
  }
}
