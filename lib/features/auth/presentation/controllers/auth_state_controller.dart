import 'dart:developer';

import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/auth/application/use_cases/auth_database_use_cases.dart';
import 'package:df_admin_mobile/features/auth/application/use_cases/auth_use_cases.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_token.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_database_repository.dart';
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_repository.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/signalr_service.dart';
import 'package:df_admin_mobile/services/social_login_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// 认证状态控制器
class AuthStateController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final AutoRefreshTokenUseCase _autoRefreshTokenUseCase;
  final SocialLoginUseCase _socialLoginUseCase;

  // 数据库相关 Use Cases
  final SaveTokenToDatabaseUseCase _saveTokenToDatabaseUseCase;
  final CheckLoginStatusWithDatabaseUseCase _checkLoginStatusWithDatabaseUseCase;

  // 社交登录服务
  final SocialLoginService _socialLoginService;

  AuthStateController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required AutoRefreshTokenUseCase autoRefreshTokenUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required SaveTokenToDatabaseUseCase saveTokenToDatabaseUseCase,
    required CheckLoginStatusWithDatabaseUseCase checkLoginStatusWithDatabaseUseCase,
    required SocialLoginService socialLoginService,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        _autoRefreshTokenUseCase = autoRefreshTokenUseCase,
        _socialLoginUseCase = socialLoginUseCase,
        _saveTokenToDatabaseUseCase = saveTokenToDatabaseUseCase,
        _checkLoginStatusWithDatabaseUseCase = checkLoginStatusWithDatabaseUseCase,
        _socialLoginService = socialLoginService;

  // 状态
  final Rx<AuthUser?> currentUser = Rx<AuthUser?>(null);
  final Rx<AuthToken?> currentToken = Rx<AuthToken?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 优先从数据库恢复登录状态
    _checkLoginStatusWithDatabase();
    // 立即加载 token 到内存
    _loadTokenToMemory();
  }

  /// 从存储加载 token 到内存（用于同步检查过期状态）
  Future<void> _loadTokenToMemory() async {
    final authRepository = Get.find<IAuthRepository>();
    final result = await authRepository.getPersistedToken();

    result.fold(
      onSuccess: (token) {
        currentToken.value = token;
        log('📥 Token 已加载到内存: expiresAt=${token?.expiresAt}');
      },
      onFailure: (_) {
        currentToken.value = null;
        log('⚠️ 加载 Token 失败');
      },
    );
  }

  /// 检查登录状态 (优先从数据库)
  Future<void> _checkLoginStatusWithDatabase() async {
    final result = await _checkLoginStatusWithDatabaseUseCase.execute(NoParams());
    result.fold(
      onSuccess: (isAuth) async {
        isAuthenticated.value = isAuth;
        if (isAuth) {
          // ✅ 加载并刷新用户信息(会更新本地缓存的角色)
          await _loadCurrentUser();
          _autoRefreshToken();

          // 加入 SignalR 用户通知组（应用启动时恢复登录状态）
          if (currentUser.value != null) {
            await _joinSignalRUserGroup(currentUser.value!.id);
          }
        }
      },
      onFailure: (_) => isAuthenticated.value = false,
    );
  }

  /// 加载当前用户
  Future<void> _loadCurrentUser() async {
    final result = await _getCurrentUserUseCase.execute(NoParams());
    result.fold(
      onSuccess: (user) => currentUser.value = user,
      onFailure: (_) => currentUser.value = null,
    );
  }

  /// 刷新当前用户信息 (公共方法)
  Future<bool> refreshCurrentUser() async {
    final result = await _getCurrentUserUseCase.execute(NoParams());
    return result.fold(
      onSuccess: (user) {
        currentUser.value = user;
        return true;
      },
      onFailure: (_) {
        currentUser.value = null;
        return false;
      },
    );
  }

  /// 自动刷新令牌
  Future<void> _autoRefreshToken() async {
    final result = await _autoRefreshTokenUseCase.execute(NoParams());
    result.fold(
      onSuccess: (token) => currentToken.value = token,
      onFailure: (_) => currentToken.value = null,
    );
  }

  /// 手动刷新令牌（公共方法，供 Middleware 使用）
  Future<bool> refreshToken() async {
    final result = await _autoRefreshTokenUseCase.execute(NoParams());
    return result.fold(
      onSuccess: (token) {
        currentToken.value = token;
        return true;
      },
      onFailure: (_) {
        currentToken.value = null;
        return false;
      },
    );
  }

  /// 验证 Token 是否有效（检查是否过期）
  Future<bool> validateToken() async {
    try {
      // 从 Repository 获取持久化的 token
      final authRepository = Get.find<IAuthRepository>();
      final isAuth = await authRepository.isAuthenticated();

      log('🔍 Token 验证结果: $isAuth');

      if (!isAuth) {
        // Token 无效或过期，清除认证状态
        isAuthenticated.value = false;
        currentUser.value = null;
        currentToken.value = null;
        return false;
      }

      return true;
    } catch (e) {
      log('❌ Token 验证异常: $e');
      return false;
    }
  }

  /// 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;

    final result = await _loginUseCase.execute(
      LoginParams(email: email, password: password),
    );

    isLoading.value = false;

    return result.fold(
      onSuccess: (token) async {
        currentToken.value = token;
        isAuthenticated.value = true;

        // 设置 HttpService 的认证 token
        final httpService = Get.find<HttpService>();
        httpService.setAuthToken(token.accessToken);

        // 加载当前用户
        await _loadCurrentUser();

        // 保存到数据库 (如果用户已加载)
        if (currentUser.value != null) {
          await _saveTokenToDatabaseUseCase.execute(
            SaveTokenToDatabaseParams(
              token: token,
              user: currentUser.value!,
            ),
          );

          // 设置用户ID到 HttpService
          httpService.setUserId(currentUser.value!.id);

          // 加入 SignalR 用户通知组
          await _joinSignalRUserGroup(currentUser.value!.id);
        }

        return true;
      },
      onFailure: (error) {
        AppToast.error(error.message);
        return false;
      },
    );
  }

  /// 加入 SignalR 用户通知组
  Future<void> _joinSignalRUserGroup(String userId) async {
    try {
      final signalRService = SignalRService();
      if (signalRService.isConnected) {
        await signalRService.joinUserGroup(userId);
        log('✅ 登录成功后已加入 SignalR 用户通知组: user-$userId');
      } else {
        log('⚠️ SignalR 未连接，稍后将在连接时加入用户组');
      }
    } catch (e) {
      log('❌ 加入 SignalR 用户通知组失败: $e');
    }
  }

  /// 注册
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
  }) async {
    isLoading.value = true;

    final result = await _registerUseCase.execute(
      RegisterParams(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone,
      ),
    );

    isLoading.value = false;

    return result.fold(
      onSuccess: (token) async {
        currentToken.value = token;
        isAuthenticated.value = true;

        // 设置 HttpService 的认证 token
        final httpService = Get.find<HttpService>();
        httpService.setAuthToken(token.accessToken);

        // 加载当前用户
        await _loadCurrentUser();

        // 保存到数据库 (如果用户已加载)
        if (currentUser.value != null) {
          await _saveTokenToDatabaseUseCase.execute(
            SaveTokenToDatabaseParams(
              token: token,
              user: currentUser.value!,
            ),
          );

          // 设置用户ID到 HttpService
          httpService.setUserId(currentUser.value!.id);

          // 加入 SignalR 用户通知组
          await _joinSignalRUserGroup(currentUser.value!.id);
        }

        return true;
      },
      onFailure: (error) {
        AppToast.error(error.message);
        return false;
      },
    );
  }

  /// 社交登录 (微信、支付宝、QQ 等)
  /// [type] 社交平台类型
  Future<bool> socialLogin(SocialLoginType type) async {
    isLoading.value = true;

    try {
      // 1. 调用 SDK 获取授权码
      final sdkResult = await _socialLoginService.login(type);

      if (!sdkResult.success) {
        isLoading.value = false;
        if (sdkResult.errorMessage != null) {
          AppToast.error(sdkResult.errorMessage!);
        }
        return false;
      }

      // 2. 将授权信息发送给后端换取 token
      final provider = _mapSocialLoginTypeToProvider(type);
      final result = await _socialLoginUseCase.execute(
        SocialLoginParams(
          provider: provider,
          code: sdkResult.code,
          accessToken: sdkResult.accessToken,
          openId: sdkResult.openId,
        ),
      );

      isLoading.value = false;

      return result.fold(
        onSuccess: (token) async {
          currentToken.value = token;
          isAuthenticated.value = true;

          // 设置 HttpService 的认证 token
          final httpService = Get.find<HttpService>();
          httpService.setAuthToken(token.accessToken);

          // 加载当前用户
          await _loadCurrentUser();

          // 保存到数据库 (如果用户已加载)
          if (currentUser.value != null) {
            await _saveTokenToDatabaseUseCase.execute(
              SaveTokenToDatabaseParams(
                token: token,
                user: currentUser.value!,
              ),
            );

            // 设置用户ID到 HttpService
            httpService.setUserId(currentUser.value!.id);

            // 加入 SignalR 用户通知组
            await _joinSignalRUserGroup(currentUser.value!.id);
          }

          log('✅ 社交登录成功: $type');
          return true;
        },
        onFailure: (error) {
          log('❌ 社交登录失败: ${error.message}');
          AppToast.error(error.message);
          return false;
        },
      );
    } catch (e) {
      isLoading.value = false;
      log('❌ 社交登录异常: $e');
      AppToast.error('社交登录失败: $e');
      return false;
    }
  }

  /// 手机号验证码登录
  /// [phone] 手机号（含国际区号，如 +8613800138000）
  /// [code] 验证码
  Future<bool> loginWithPhone({
    required String phone,
    required String code,
  }) async {
    isLoading.value = true;

    try {
      log('📱 手机号登录: $phone');

      final httpService = Get.find<HttpService>();
      final response = await httpService.post(
        '/auth/login/phone',
        data: {
          'phoneNumber': phone,
          'code': code,
        },
      );

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? '登录失败');
      }

      final authData = data['data'];
      final accessToken = authData['accessToken'];
      final refreshToken = authData['refreshToken'];
      final userData = authData['user'];

      // 创建 AuthToken
      final token = AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      currentToken.value = token;
      isAuthenticated.value = true;

      // 设置 HttpService 的认证 token
      httpService.setAuthToken(accessToken);

      // 构建用户对象
      final user = AuthUser(
        id: userData['id'],
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'],
        avatar: userData['avatar'],
        role: userData['role'] ?? 'user',
      );

      currentUser.value = user;

      // 保存到数据库
      await _saveTokenToDatabaseUseCase.execute(
        SaveTokenToDatabaseParams(
          token: token,
          user: user,
        ),
      );

      // 设置用户 ID
      httpService.setUserId(user.id);

      // 加入 SignalR 用户通知组
      await _joinSignalRUserGroup(user.id);

      isLoading.value = false;
      log('✅ 手机号登录成功: ${user.name}');
      return true;
    } catch (e) {
      isLoading.value = false;
      log('❌ 手机号登录失败: $e');
      rethrow;
    }
  }

  /// 将 SocialLoginType 映射为 SocialAuthProvider
  SocialAuthProvider _mapSocialLoginTypeToProvider(SocialLoginType type) {
    switch (type) {
      case SocialLoginType.wechat:
        return SocialAuthProvider.wechat;
      case SocialLoginType.alipay:
        return SocialAuthProvider.alipay;
      case SocialLoginType.qq:
        return SocialAuthProvider.qq;
      case SocialLoginType.apple:
        return SocialAuthProvider.apple;
      case SocialLoginType.google:
        return SocialAuthProvider.google;
    }
  }

  /// 登出
  Future<void> logout() async {
    isLoading.value = true;

    // 先删除数据库中的 token
    final httpService = Get.find<HttpService>();
    final userId = currentUser.value?.id;
    if (userId != null) {
      // 删除当前用户的 token (不等待结果)
      await Get.find<IAuthDatabaseRepository>().deleteTokenByUserId(userId);
    }

    final result = await _logoutUseCase.execute(NoParams());

    isLoading.value = false;

    result.fold(
      onSuccess: (_) {
        // 清除 HttpService 状态
        httpService.clearAuthToken();
        httpService.clearUserId();

        currentUser.value = null;
        currentToken.value = null;
        isAuthenticated.value = false;
        AppToast.success('已退出登录');
      },
      onFailure: (error) {
        // 即使失败也清除本地状态
        httpService.clearAuthToken();
        httpService.clearUserId();

        currentUser.value = null;
        currentToken.value = null;
        isAuthenticated.value = false;
      },
    );
  }

  /// 更新用户资料
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    isLoading.value = true;

    final result = await _updateUserProfileUseCase.execute(
      UpdateUserProfileParams(
        name: name,
        phone: phone,
        avatar: avatar,
      ),
    );

    isLoading.value = false;

    return result.fold(
      onSuccess: (user) {
        currentUser.value = user;
        AppToast.success('用户资料已更新');
        return true;
      },
      onFailure: (error) {
        AppToast.error(error.message);
        return false;
      },
    );
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  @override
  void onClose() {
    // 注意: AuthStateController 通常是全局单例(permanent: true)
    // 不会被 GetX 销毁,所以这里不需要清理数据
    // 如果需要清理,应该调用 logout() 方法
    super.onClose();
  }
}
