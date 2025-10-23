import '../config/api_config.dart';
import 'http_service.dart';

/// 认证服务类
class AuthService {
  final HttpService _httpService = HttpService();
  
  /// 登录
  /// 
  /// 参数:
  /// - [username] 用户名或邮箱
  /// - [password] 密码
  /// 
  /// 返回: Map 包含 token, user 等信息
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // 保存 token
        if (data['token'] != null) {
          _httpService.setAuthToken(data['token']);
          // TODO: 持久化保存 token 到本地存储
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
  /// - [username] 用户名
  /// - [email] 邮箱
  /// - [password] 密码
  /// - [confirmPassword] 确认密码
  /// 
  /// 返回: Map 包含注册结果
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.registerEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
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
      _httpService.clearAuthToken();
      // TODO: 清除本地存储的 token
    } catch (e) {
      // 即使请求失败也清除本地 token
      _httpService.clearAuthToken();
      rethrow;
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
        final newToken = data['token'] as String?;
        
        if (newToken != null) {
          _httpService.setAuthToken(newToken);
          // TODO: 持久化保存新 token
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
    return _httpService.authToken != null && 
           _httpService.authToken!.isNotEmpty;
  }
  
  /// 设置 Token (从本地存储恢复时使用)
  void setToken(String token) {
    _httpService.setAuthToken(token);
  }
}
