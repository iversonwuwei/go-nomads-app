import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/application/use_case.dart';
import 'package:go_nomads_app/core/auth/token_manager.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/application/use_cases/auth_database_use_cases.dart';
import 'package:go_nomads_app/features/auth/application/use_cases/auth_use_cases.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_token.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_user.dart';
import 'package:go_nomads_app/features/auth/domain/repositories/iauth_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/services/social_login_service.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

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

  // Token 自动刷新定时器
  Timer? _tokenRefreshTimer;
  static const Duration _tokenCheckInterval = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    // 优先从数据库恢复登录状态
    _checkLoginStatusWithDatabase();
    // 立即加载 token 到内存
    _loadTokenToMemory();
    // 启动 token 自动刷新检查
    _startTokenRefreshTimer();
  }

  @override
  void onClose() {
    _stopTokenRefreshTimer();
    super.onClose();
  }

  /// 启动 Token 自动刷新定时器
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(_tokenCheckInterval, (_) async {
      await _checkAndRefreshTokenIfNeeded();
    });
    log('🔄 Token 自动刷新定时器已启动（检查间隔: ${_tokenCheckInterval.inMinutes} 分钟）');
  }

  /// 停止 Token 自动刷新定时器
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    log('⏹️ Token 自动刷新定时器已停止');
  }

  /// 检查并在需要时刷新 Token
  Future<void> _checkAndRefreshTokenIfNeeded() async {
    if (!isAuthenticated.value) {
      return; // 未登录，跳过
    }

    final token = currentToken.value;
    if (token == null) {
      return;
    }

    log('🔍 检查 Token 状态: needsRefresh=${token.needsRefresh}, isExpired=${token.isExpired}');

    if (token.needsRefresh && token.hasValidRefreshToken) {
      log('🔄 Token 即将过期，开始自动刷新...');
      final success = await refreshToken();
      if (success) {
        log('✅ Token 自动刷新成功');
      } else {
        log('❌ Token 自动刷新失败');
      }
    }
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
  /// 返回登录是否成功，成功后用户信息将在后台加载
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

        // 设置 HttpService 的认证 token（必须立即执行）
        final httpService = Get.find<HttpService>();
        httpService.setAuthToken(token.accessToken);

        // ⭐ 优化：将后续操作放到后台执行，不阻塞页面跳转
        _completeLoginInBackground(token, httpService);

        return true;
      },
      onFailure: (error) {
        AppToast.error(error.message);
        return false;
      },
    );
  }

  /// 在后台完成登录后的数据加载
  Future<void> _completeLoginInBackground(AuthToken token, HttpService httpService) async {
    try {
      // 加载当前用户（从服务器获取最新信息）
      await _loadCurrentUser();

      // Token 已经在 AuthRepository.login() 中保存到 SQLite
      // 这里只需要设置 HttpService 的用户ID 和加入 SignalR 组
      if (currentUser.value != null) {
        // 设置用户ID到 HttpService
        httpService.setUserId(currentUser.value!.id);

        // 加入 SignalR 用户通知组
        await _joinSignalRUserGroup(currentUser.value!.id);
      }

      log('✅ 登录后台任务完成');
    } catch (e) {
      log('⚠️ 登录后台任务异常: $e');
    }
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
  /// 返回注册是否成功，成功后用户信息将在后台加载
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

        // 设置 HttpService 的认证 token（必须立即执行）
        final httpService = Get.find<HttpService>();
        httpService.setAuthToken(token.accessToken);

        // ⭐ 优化：将后续操作放到后台执行，不阻塞页面跳转
        _completeLoginInBackground(token, httpService);

        return true;
      },
      onFailure: (error) {
        AppToast.error(error.message);
        return false;
      },
    );
  }

  /// 社交登录 (微信、抖音、QQ 等)
  /// [type] 社交平台类型
  /// [onAuthSuccess] 可选回调，在第三方授权成功后、调用后端 API 前触发
  Future<bool> socialLogin(SocialLoginType type, {VoidCallback? onAuthSuccess}) async {
    try {
      // 1. 调用 SDK 获取授权码（此时会跳转到微信/QQ等APP）
      final sdkResult = await _socialLoginService.login(type);

      if (!sdkResult.success) {
        if (sdkResult.isCancelled) {
          // 用户取消授权，使用普通提示
          AppToast.info('用户取消授权');
        } else if (sdkResult.errorMessage != null) {
          // 真正的错误，使用错误提示
          AppToast.error(sdkResult.errorMessage!);
        }
        return false;
      }

      // ⭐ 授权成功，触发回调（此时才显示加载状态）
      onAuthSuccess?.call();
      isLoading.value = true;

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

          // ⭐ 优化：将后续操作放到后台执行，不阻塞页面跳转
          _completeSocialLoginInBackground(token, httpService);

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

  /// 在后台完成社交登录后的数据加载
  Future<void> _completeSocialLoginInBackground(AuthToken token, HttpService httpService) async {
    try {
      // 加载当前用户
      await _loadCurrentUser();

      // 保存到数据库 (如果用户已加载)
      if (currentUser.value != null) {
        // 保存 token 到 SharedPreferences（HttpService 拦截器需要）
        final tokenStorageService = TokenStorageService();
        await tokenStorageService.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
          expiresAt: token.expiresAt,
        );
        await tokenStorageService.saveUserInfo(
          userId: currentUser.value!.id,
          userName: currentUser.value!.name,
          userEmail: currentUser.value!.email,
          userRole: currentUser.value!.role,
        );
        log('✅ Token 已保存到 SharedPreferences');

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

      log('✅ 社交登录后台任务完成');
    } catch (e) {
      log('⚠️ 社交登录后台任务异常: $e');
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

      // HttpService 拦截器已经解包了 API 响应，response.data 直接就是 data 字段的内容
      final authData = response.data as Map<String, dynamic>;
      final accessToken = authData['accessToken'];
      final refreshToken = authData['refreshToken'];
      final userData = authData['user'] as Map<String, dynamic>;

      // 创建 AuthToken
      final token = AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      // 构建用户对象
      final user = AuthUser(
        id: userData['id'],
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'],
        avatar: userData['avatarUrl'] ?? userData['avatar'],
        role: userData['role'] ?? 'user',
      );

      // ⚠️ 重要：先保存 token 到 SharedPreferences（HttpService 拦截器需要）
      // 必须在设置 isAuthenticated.value = true 之前完成
      // 因为 UserStateController 监听 isAuthenticated 变化，会立即尝试加载用户数据
      final tokenStorageService = TokenStorageService();
      log('📝 [步骤1] 保存 Token 到 SharedPreferences...');
      log('   accessToken: ${accessToken.substring(0, 30)}...');
      await tokenStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: token.expiresAt,
      );
      await tokenStorageService.saveUserInfo(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userRole: user.role,
      );

      // 验证保存是否成功
      final savedToken = await tokenStorageService.getAccessToken();
      log('📝 验证保存结果: ${savedToken != null ? '成功' : '失败'}');
      if (savedToken != null) {
        log('   已保存的 token: ${savedToken.substring(0, 30)}...');
      }
      log('✅ Token 已保存到 SharedPreferences');

      // 设置 HttpService 的认证 token
      log('📝 [步骤2] 设置 HttpService 认证 token...');
      httpService.setAuthToken(accessToken);
      httpService.setUserId(user.id);

      // 保存到数据库
      log('📝 [步骤3] 保存 Token 到数据库...');
      try {
        await _saveTokenToDatabaseUseCase.execute(
          SaveTokenToDatabaseParams(
            token: token,
            user: user,
          ),
        );
      } catch (e) {
        log('⚠️ 保存 token 到数据库失败（不影响登录）: $e');
      }

      // ⚠️ 最后才设置认证状态，触发 UserStateController 监听器
      log('📝 [步骤4] 设置认证状态...');
      currentToken.value = token;
      currentUser.value = user;
      isAuthenticated.value = true;

      // 加入 SignalR 用户通知组（不阻塞登录流程）
      try {
        await _joinSignalRUserGroup(user.id);
      } catch (e) {
        log('⚠️ 加入 SignalR 组失败（不影响登录）: $e');
      }

      isLoading.value = false;
      log('✅ 手机号登录成功: ${user.name}');
      return true;
    } catch (e, stackTrace) {
      isLoading.value = false;
      log('❌ 手机号登录失败: $e');
      log('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 将 SocialLoginType 映射为 SocialAuthProvider
  SocialAuthProvider _mapSocialLoginTypeToProvider(SocialLoginType type) {
    switch (type) {
      case SocialLoginType.wechat:
        return SocialAuthProvider.wechat;
      case SocialLoginType.douyin:
        return SocialAuthProvider.douyin;
      case SocialLoginType.apple:
        return SocialAuthProvider.apple;
      case SocialLoginType.google:
        return SocialAuthProvider.google;
      case SocialLoginType.twitter:
        return SocialAuthProvider.twitter;
    }
  }

  /// 登出
  Future<void> logout() async {
    isLoading.value = true;
    log('🔐 [AuthStateController] 开始登出...');

    final userId = currentUser.value?.id;
    final tokenManager = TokenManager();

    try {
      // 1. 调用后端登出 API
      await _logoutUseCase.execute(NoParams());
      log('   ✅ 后端登出 API 调用完成');
    } catch (e) {
      // 即使 API 调用失败也继续清理本地状态
      log('   ⚠️ 后端登出 API 失败（不影响本地清理）: $e');
    }

    // 2. 使用 TokenManager 统一清除所有 Token 状态
    await tokenManager.clearToken(userId: userId);
    log('   ✅ TokenManager 清除完成');

    // 3. 清除控制器状态
    currentUser.value = null;
    currentToken.value = null;
    isAuthenticated.value = false;
    log('   ✅ 控制器状态已清除');

    // 4. 断开 SignalR 连接
    try {
      // SignalRService 是单例，直接使用工厂构造函数获取实例
      final signalRService = SignalRService();
      await signalRService.disconnect();
      log('   ✅ SignalR 已断开');
    } catch (e) {
      log('   ⚠️ SignalR 断开失败: $e');
    }

    isLoading.value = false;
    log('✅ [AuthStateController] 登出完成');
    AppToast.success('已退出登录');
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
}
