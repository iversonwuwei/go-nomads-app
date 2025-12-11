import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/core/infrastructure/base_repository.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_token.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_repository.dart';
import 'package:df_admin_mobile/features/auth/infrastructure/models/auth_token_dto.dart';
import 'package:df_admin_mobile/features/auth/infrastructure/models/auth_user_dto.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';

import 'user_local_repository.dart';

/// 认证仓储实现
class AuthRepository extends BaseRepository implements IAuthRepository {
  final HttpService _httpService;
  final TokenStorageService _tokenStorage;
  final UserLocalRepository _userLocalRepo;

  AuthRepository({
    required HttpService httpService,
    required TokenStorageService tokenStorage,
    required UserLocalRepository userLocalRepo,
  })  : _httpService = httpService,
        _tokenStorage = tokenStorage,
        _userLocalRepo = userLocalRepo {
    // 设置 token 刷新回调
    _httpService.setTokenRefreshCallback(_handleTokenRefresh);
  }

  /// 处理 token 刷新请求
  Future<String?> _handleTokenRefresh() async {
    try {
      // 获取refresh token
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // 调用刷新接口
      final result = await this.refreshToken(refreshToken);

      return result.fold(
        onSuccess: (newToken) {
          // 刷新成功，返回新的 access token
          return newToken.accessToken;
        },
        onFailure: (_) {
          // 刷新失败
          return null;
        },
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Result<AuthToken>> login({
    required String email,
    required String password,
  }) async {
    return execute(() async {
      final response = await _httpService.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final tokenDto = AuthTokenDto.fromJson(data);
        final token = tokenDto.toDomain();

        // 自动设置HTTP服务的token
        _httpService.setAuthToken(token.accessToken);

        // 自动持久化token
        await persistToken(token);

        // 保存用户完整信息（使用 UserLocalRepository 协调存储）
        final userData = data['data']?['user'];
        if (userData != null) {
          final user = AuthUser(
            id: userData['id'] as String,
            name: userData['name'] as String,
            email: userData['email'] as String,
            phone: userData['phone'] as String?,
            avatar: userData['avatar'] as String?,
            role: userData['role'] as String? ?? 'user',
          );

          // 保存到 SharedPreferences + SQLite
          await _userLocalRepo.saveUser(user);
        }

        return token;
      } else {
        throw ServerException('登录失败');
      }
    });
  }

  @override
  Future<Result<AuthToken>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return execute(() async {
      final response = await _httpService.post(
        ApiConfig.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final tokenDto = AuthTokenDto.fromJson(data);
        final token = tokenDto.toDomain();

        // 自动设置HTTP服务的token
        _httpService.setAuthToken(token.accessToken);

        // 自动持久化token
        await persistToken(token);

        // 保存用户完整信息（使用 UserLocalRepository 协调存储）
        final userData = data['data']?['user'];
        if (userData != null) {
          final user = AuthUser(
            id: userData['id'] as String,
            name: userData['name'] as String,
            email: userData['email'] as String,
            phone: userData['phone'] as String?,
            avatar: userData['avatar'] as String?,
            role: userData['role'] as String? ?? 'user',
          );

          // 保存到 SharedPreferences + SQLite
          await _userLocalRepo.saveUser(user);
        }

        return token;
      } else {
        throw ServerException('注册失败');
      }
    });
  }

  @override
  Future<Result<void>> logout() async {
    return execute(() async {
      try {
        await _httpService.post(ApiConfig.logoutEndpoint);
      } catch (e) {
        // 即使API调用失败,也要清除本地token
        // Silently ignore logout API errors
      }

      // 清除HTTP服务的token
      _httpService.clearAuthToken();

      // 清除持久化的token
      await clearPersistedToken();

      // 清除用户数据（SharedPreferences + SQLite 可选清除）
      await _userLocalRepo.clearUserData();
    });
  }

  @override
  Future<Result<AuthToken>> refreshToken(String refreshToken) async {
    return execute(() async {
      final response = await _httpService.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final tokenDto = AuthTokenDto.fromJson(data);
        final token = tokenDto.toDomain();

        // 更新HTTP服务的token
        _httpService.setAuthToken(token.accessToken);

        // 更新持久化的token
        await persistToken(token);

        return token;
      } else {
        throw ServerException('刷新令牌失败');
      }
    });
  }

  @override
  Future<Result<AuthUser>> getCurrentUser() async {
    return execute(() async {
      final response = await _httpService.get(ApiConfig.userMeEndpoint);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final userDto = AuthUserDto.fromJson(data);
        final user = userDto.toDomain();

        // 更新本地缓存的用户信息(包括角色)
        await _userLocalRepo.saveUser(user);

        return user;
      } else {
        throw ServerException('获取用户信息失败');
      }
    });
  }

  @override
  Future<Result<AuthUser>> updateUserProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    return execute(() async {
      final response = await _httpService.put(
        ApiConfig.userUpdateMeEndpoint,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (avatar != null) 'avatar': avatar,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final userDto = AuthUserDto.fromJson(data);
        return userDto.toDomain();
      } else {
        throw ServerException('更新用户资料失败');
      }
    });
  }

  @override
  Future<Result<void>> persistToken(AuthToken token) async {
    return execute(() async {
      // 保存到 SharedPreferences/SQLite
      await _tokenStorage.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        expiresAt: token.expiresAt,
      );

      // 同时设置到 HttpService（用于向后兼容）
      // 注意：由于拦截器会动态从存储获取，这一步不是必需的，但保留以确保兼容性
      _httpService.setAuthToken(token.accessToken);
    });
  }

  @override
  Future<Result<AuthToken?>> getPersistedToken() async {
    return execute(() async {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) return null;

      final refreshToken = await _tokenStorage.getRefreshToken();
      final expiresAt = await _tokenStorage.getTokenExpiresAt();

      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
    });
  }

  @override
  Future<Result<void>> clearPersistedToken() async {
    return execute(() async {
      await _tokenStorage.clearTokens();
    });
  }

  @override
  Future<bool> isAuthenticated() async {
    final result = await getPersistedToken();
    return result.fold(
      onSuccess: (token) => token != null && !token.isExpired,
      onFailure: (_) => false,
    );
  }

  @override
  Future<Result<AuthToken>> socialLogin({
    required SocialAuthProvider provider,
    String? code,
    String? accessToken,
    String? openId,
  }) async {
    return execute(() async {
      // 构建请求数据
      final requestData = <String, dynamic>{
        'provider': provider.name, // wechat, alipay, qq, apple, google
      };

      if (code != null) requestData['code'] = code;
      if (accessToken != null) requestData['accessToken'] = accessToken;
      if (openId != null) requestData['openId'] = openId;

      final response = await _httpService.post(
        ApiConfig.socialLoginEndpoint,
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final tokenDto = AuthTokenDto.fromJson(data);
        final token = tokenDto.toDomain();

        // 自动设置HTTP服务的token
        _httpService.setAuthToken(token.accessToken);

        // 自动持久化token
        await persistToken(token);

        // 保存用户完整信息
        final userData = data['data']?['user'];
        if (userData != null) {
          final user = AuthUser(
            id: userData['id'] as String,
            name: userData['name'] as String,
            email: userData['email'] as String? ?? '',
            phone: userData['phone'] as String?,
            avatar: userData['avatar'] as String?,
            role: userData['role'] as String? ?? 'user',
          );

          await _userLocalRepo.saveUser(user);
        }

        return token;
      } else {
        throw ServerException('社交登录失败');
      }
    });
  }
}
