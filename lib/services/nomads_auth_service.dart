import 'package:get/get.dart';

import '../config/api_config.dart';
import '../controllers/user_state_controller.dart';
import '../models/api_response_meta.dart';
import '../models/login_response_model.dart';
import '../services/database/token_dao.dart';
import 'http_service.dart';

/// Nomads 后端认证服务
/// 用于与后端 /api/Users/login 接口交互
class NomadsAuthService {
  final HttpService _httpService = HttpService();
  final TokenDao _tokenDao = TokenDao();

  /// 登录
  ///
  /// 参数:
  /// - [email] 用户邮箱
  /// - [password] 密码
  ///
  /// 返回: LoginResponse 包含成功标志、token 和用户信息
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 开始调用后端登录接口...');
      print('   接口: ${ApiConfig.loginEndpoint}');
      print('   邮箱: $email');

      final response = await _httpService.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ 后端响应状态码: ${response.statusCode}');
      print('✅ 后端响应数据: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final meta =
            response.extra[HttpService.apiResponseMetaKey] as ApiResponseMeta?;
        final rawData = response.data;

        if (rawData is! Map<String, dynamic>) {
          throw HttpException('登录返回数据格式异常', response.statusCode);
        }

        final loginData = LoginData.fromJson(rawData);
        final loginResponse = LoginResponse(
          success: meta?.success ?? true,
          message: meta?.message ?? '登录成功',
          data: loginData,
          errors: meta?.errors ?? const [],
        );

        // 登录成功，保存 token
        print('🎉 登录成功！');
        print('   用户: ${loginData.user.name}');
        if (loginData.accessToken.isNotEmpty) {
          final previewLength = loginData.accessToken.length >= 20
              ? 20
              : loginData.accessToken.length;
          print(
              '   Token: ${loginData.accessToken.substring(0, previewLength)}...');
        }

        // 设置 HttpService 的认证 token
        _httpService.setAuthToken(loginData.accessToken);
        
        // 设置用户ID到 HttpService（用于 X-User-Id header）
        _httpService.setUserId(loginData.user.id);

        // 持久化保存 token 到 SQLite
        await _saveTokenToDatabase(loginData);

        return loginResponse;
      }

      throw HttpException('登录请求失败', response.statusCode);
    } catch (e) {
      print('❌ 登录异常: $e');
      rethrow;
    }
  }

  /// 保存 Token 到数据库
  Future<void> _saveTokenToDatabase(LoginData data) async {
    try {
      print('💾 开始保存 token 到数据库...');

      await _tokenDao.saveToken(
        userId: data.user.id,
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        tokenType: data.tokenType,
        expiresIn: data.expiresIn,
        userName: data.user.name,
        userEmail: data.user.email,
      );

      print('✅ Token 已保存到 SQLite');
      print('   用户: ${data.user.name} (${data.user.email})');
    } catch (e) {
      print('⚠️ 保存 token 失败: $e');
      // 不抛出异常，因为登录本身已经成功
    }
  }

  /// 从数据库恢复 Token
  ///
  /// 用于应用启动时恢复登录状态
  Future<bool> restoreToken() async {
    try {
      print('🔄 尝试从数据库恢复 token...');

      final tokenData = await _tokenDao.getLatestToken();
      if (tokenData == null) {
        print('ℹ️ 数据库中没有保存的 token');
        return false;
      }

      final userId = tokenData['user_id'] as String;

      // 检查是否过期
      final isExpired = await _tokenDao.isTokenExpired(userId);
      if (isExpired) {
        print('⚠️ Token 已过期，尝试使用 refresh_token 刷新...');
        final refreshed = await refreshToken(userId);
        if (refreshed) {
          print('✅ Token 刷新成功，登录状态已恢复');
          return true;
        } else {
          print('❌ Token 刷新失败');
          return false;
        }
      }

      // 恢复 token 到 HttpService
      final accessToken = tokenData['access_token'] as String;
      _httpService.setAuthToken(accessToken);
      
      // 恢复用户ID到 HttpService
      _httpService.setUserId(userId);

      // 恢复 UserStateController 状态
      _restoreUserState(tokenData);

      print('✅ Token 已恢复');
      print('   用户ID: $userId');
      return true;
    } catch (e) {
      print('❌ 恢复 token 失败: $e');
      return false;
    }
  }

  /// 登出
  ///
  /// 清除本地保存的 token
  Future<void> logout() async {
    try {
      print('🚪 开始登出...');

      // 清除 HttpService 的 token
      _httpService.clearAuthToken();
      _httpService.clearUserId();

      // 删除数据库中的所有 token
      await _tokenDao.deleteAllTokens();

      // 清除 UserStateController 状态
      try {
        final userStateController = Get.find<UserStateController>();
        userStateController.logout();
      } catch (e) {
        print('⚠️ UserStateController 未找到，跳过状态清除');
      }

      print('✅ 登出成功');
    } catch (e) {
      print('❌ 登出失败: $e');
      rethrow;
    }
  }

  /// 检查是否已登录（同步方法，只检查内存）
  /// 注意：这个方法只检查内存中的 token，不查询数据库
  /// 如果需要从数据库恢复 token，请使用 checkLoginStatus()
  bool isLoggedIn() {
    return _httpService.authToken != null && _httpService.authToken!.isNotEmpty;
  }

  /// 检查登录状态（异步方法，优先从 SQLite 获取）
  ///
  /// 验证流程：
  /// 1. 先检查内存中是否有 token
  /// 2. 如果没有，尝试从 SQLite 数据库恢复
  /// 3. 如果数据库中有且未过期，恢复到内存
  /// 4. 返回最终的登录状态
  Future<bool> checkLoginStatus() async {
    try {
      // 1. 先检查内存中的 token
      if (_httpService.authToken != null &&
          _httpService.authToken!.isNotEmpty) {
        print('✅ 内存中存在 token');
        return true;
      }

      print('🔍 内存中没有 token，尝试从 SQLite 获取...');

      // 2. 从数据库获取最近的 token
      final tokenData = await _tokenDao.getLatestToken();
      if (tokenData == null) {
        print('❌ SQLite 中没有保存的 token');
        return false;
      }

      final userId = tokenData['user_id'] as String;
      print('📦 从 SQLite 找到 token，用户ID: $userId');

      // 3. 检查 token 是否过期
      final isExpired = await _tokenDao.isTokenExpired(userId);
      if (isExpired) {
        print('⏰ Token 已过期，尝试使用 refresh_token 刷新...');
        final refreshed = await refreshToken(userId);
        if (refreshed) {
          print('✅ Token 刷新成功，登录状态已恢复');
          return true;
        } else {
          print('❌ Token 刷新失败，需要重新登录');
          return false;
        }
      }

      // 4. Token 有效，恢复到内存
      final accessToken = tokenData['access_token'] as String;
      _httpService.setAuthToken(accessToken);
      _httpService.setUserId(userId); // 使用前面已定义的 userId
      print('✅ Token 已从 SQLite 恢复到内存');

      // 5. 同时恢复 UserStateController 状态
      _restoreUserState(tokenData);

      return true;
    } catch (e) {
      print('❌ 检查登录状态失败: $e');
      return false;
    }
  }

  /// 恢复用户状态到 UserStateController
  void _restoreUserState(Map<String, dynamic> tokenData) {
    try {
      final userId = tokenData['user_id'] as String;
      final userName = tokenData['user_name'] as String?;
      final userEmail = tokenData['user_email'] as String?;

      if (userName != null && userName.isNotEmpty) {
        // 尝试获取 UserStateController
        try {
          final userStateController = Get.find<UserStateController>();

          // 使用 user_id 作为 accountId（这里需要转换为 int）
          // 如果 user_id 是字符串格式的 ID，我们使用 hashCode 作为临时解决方案
          final accountId = userId.hashCode.abs();

          userStateController.login(
            accountId,
            userName,
            email: userEmail,
          );

          print('✅ UserStateController 状态已恢复');
          print('   用户: $userName ($userEmail)');
        } catch (e) {
          print('⚠️ UserStateController 未找到，跳过状态恢复: $e');
        }
      } else {
        print('⚠️ Token 数据中没有用户信息，无法恢复 UserStateController');
      }
    } catch (e) {
      print('⚠️ 恢复 UserStateController 失败: $e');
    }
  }

  /// 获取当前 Token
  String? get currentToken => _httpService.authToken;

  /// 刷新 Token
  ///
  /// 使用 refresh_token 获取新的 access_token
  ///
  /// 参数:
  /// - [userId] 用户ID（可选），如果不提供则从数据库获取最新的 token
  ///
  /// 返回:
  /// - true: 刷新成功
  /// - false: 刷新失败
  Future<bool> refreshToken([String? userId]) async {
    try {
      print('🔄 开始刷新 token...');

      // 获取 token 数据
      Map<String, dynamic>? tokenData;
      if (userId != null) {
        tokenData = await _tokenDao.getTokenByUserId(userId);
      } else {
        tokenData = await _tokenDao.getLatestToken();
      }

      if (tokenData == null) {
        print('❌ 找不到用户的 token');
        return false;
      }

      final refreshToken = tokenData['refresh_token'] as String?;
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ refresh_token 不存在');
        return false;
      }

      print('📤 调用刷新 token 接口...');
      print('   接口: ${ApiConfig.refreshTokenEndpoint}');
      final refreshPreviewLength =
          refreshToken.length >= 20 ? 20 : refreshToken.length;
      print(
          '   refreshToken: ${refreshToken.substring(0, refreshPreviewLength)}...');

      // 调用后端刷新 token 接口 (GET 方法，使用 query parameters)
      final response = await _httpService.get(
        ApiConfig.refreshTokenEndpoint,
        queryParameters: {
          'refreshToken': refreshToken,
        },
      );

      print('✅ 后端响应状态码: ${response.statusCode}');
      print('✅ 后端响应数据: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final meta =
            response.extra[HttpService.apiResponseMetaKey] as ApiResponseMeta?;
        final rawData = response.data;

        if (rawData is! Map<String, dynamic>) {
          print('❌ Token 刷新失败：返回数据格式异常');
          return false;
        }

        final loginData = LoginData.fromJson(rawData);

        print('🎉 Token 刷新成功！');
        final previewLength = loginData.accessToken.length >= 20
            ? 20
            : loginData.accessToken.length;
        if (previewLength > 0) {
          print(
              '   新 Token: ${loginData.accessToken.substring(0, previewLength)}...');
        }

        // 设置新的 access_token
        _httpService.setAuthToken(loginData.accessToken);
        
        // 设置用户ID
        _httpService.setUserId(loginData.user.id);

        // 更新数据库中的 token
        await _saveTokenToDatabase(loginData);

        if (meta != null && !meta.success) {
          print('⚠️ Token 刷新返回非成功标识: ${meta.message}');
        }

        return true;
      }

      print('❌ 刷新请求失败，状态码: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ 刷新 token 异常: $e');
      return false;
    }
  }
}
