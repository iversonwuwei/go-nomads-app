import '../config/api_config.dart';
import 'http_service.dart';
import 'token_storage_service.dart';

/// 认证服务类
class AuthService {
  final HttpService _httpService = HttpService();
  final TokenStorageService _tokenStorageService = TokenStorageService();

  /// 登录
  ///
  /// 参数:
  /// - [email] 邮箱
  /// - [password] 密码
  ///
  /// 返回: Map 包含 token, user 等信息
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        final accessToken = _extractAccessToken(data);
        final refreshToken = _extractRefreshToken(data);

        if (accessToken != null) {
          _httpService.setAuthToken(accessToken);
          await _persistTokens(
              accessToken: accessToken, refreshToken: refreshToken);
        }

        return data;
      } else {
        throw HttpException('登录失败');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 注册
  ///
  /// 参数:
  /// - [username] 用户名 (后端使用此字段作为 Name)
  /// - [email] 邮箱
  /// - [password] 密码
  /// - [confirmPassword] 确认密码 (前端验证用，不发送到后端)
  /// - [phone] 手机号 (可选)
  ///
  /// 返回: Map 包含注册结果 {accessToken, refreshToken, user}
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
  }) async {
    // 前端验证密码确认
    if (password != confirmPassword) {
      throw HttpException('两次输入的密码不一致');
    }

    try {
      final response = await _httpService.post(
        ApiConfig.registerEndpoint,
        data: {
          'name': username, // 后端 RegisterDto 使用 'name' 字段
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // HttpService 拦截器已经解包了 ApiResponse
        // response.data 现在直接是 AuthResponseDto 对象
        final data = response.data as Map<String, dynamic>;
        
        // 如果注册成功后返回了 token，自动设置 token
        final accessToken = _extractAccessToken(data);
        if (accessToken != null) {
          _httpService.setAuthToken(accessToken);
          final refreshToken = _extractRefreshToken(data);
          await _persistTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        
        return data;
      } else {
        throw HttpException('注册失败');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _httpService.post(ApiConfig.logoutEndpoint);
    } finally {
      _httpService.clearAuthToken();
      await _clearPersistedTokens();
    }
  }

  /// 刷新 Token
  ///
  /// 参数:
  /// - [refreshToken] 刷新令牌
  ///
  /// 返回: 新的 token
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _httpService.post(
        ApiConfig.refreshTokenEndpoint,
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newToken = _extractAccessToken(data);
        final newRefreshToken = _extractRefreshToken(data) ?? refreshToken;

        if (newToken != null) {
          _httpService.setAuthToken(newToken);
          await _persistTokens(
              accessToken: newToken, refreshToken: newRefreshToken);
          return newToken;
        } else {
          throw HttpException('Token 刷新失败');
        }
      } else {
        throw HttpException('Token 刷新失败');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _httpService.get(
        ApiConfig.userProfileEndpoint,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('获取用户信息失败');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 更新用户信息
  ///
  /// 参数:
  /// - [data] 要更新的用户数据
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpService.put(
        ApiConfig.userUpdateEndpoint,
        data: data,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('更新用户信息失败');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    return _httpService.authToken != null && _httpService.authToken!.isNotEmpty;
  }

  /// 设置 Token (从本地存储恢复时使用)
  void setToken(String token) {
    _httpService.setAuthToken(token);
  }

  Future<void> _persistTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await _tokenStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (_) {
      // 忽略本地持久化异常，避免阻断主流程
    }
  }

  Future<void> _clearPersistedTokens() async {
    try {
      await _tokenStorageService.clearTokens();
    } catch (_) {
      // 忽略本地持久化异常，避免阻断主流程
    }
  }

  String? _extractAccessToken(Map<String, dynamic> payload) {
    return _extractToken(
        payload, const ['accessToken', 'token', 'access_token']);
  }

  String? _extractRefreshToken(Map<String, dynamic> payload) {
    return _extractToken(payload, const ['refreshToken', 'refresh_token']);
  }

  String? _extractToken(Map<String, dynamic> payload, List<String> candidates) {
    for (final key in candidates) {
      final value = payload[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final nestedData = payload['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedToken = _extractToken(nestedData, candidates);
      if (nestedToken != null) {
        return nestedToken;
      }
    }

    final attributes = payload['attributes'];
    if (attributes is Map<String, dynamic>) {
      final nestedToken = _extractToken(attributes, candidates);
      if (nestedToken != null) {
        return nestedToken;
      }
    }

    return null;
  }
}
