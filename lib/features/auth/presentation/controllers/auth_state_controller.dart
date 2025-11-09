import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/application/use_case.dart';
import '../../../../core/domain/result.dart';
import '../../../../services/http_service.dart';
import '../../application/use_cases/auth_database_use_cases.dart';
import '../../application/use_cases/auth_use_cases.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/iauth_database_repository.dart';

/// 认证状态控制器
class AuthStateController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final AutoRefreshTokenUseCase _autoRefreshTokenUseCase;

  // 数据库相关 Use Cases
  final SaveTokenToDatabaseUseCase _saveTokenToDatabaseUseCase;
  final CheckLoginStatusWithDatabaseUseCase
      _checkLoginStatusWithDatabaseUseCase;

  AuthStateController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required AutoRefreshTokenUseCase autoRefreshTokenUseCase,
    required SaveTokenToDatabaseUseCase saveTokenToDatabaseUseCase,
    required CheckLoginStatusWithDatabaseUseCase
        checkLoginStatusWithDatabaseUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        _autoRefreshTokenUseCase = autoRefreshTokenUseCase,
        _saveTokenToDatabaseUseCase = saveTokenToDatabaseUseCase,
        _checkLoginStatusWithDatabaseUseCase =
            checkLoginStatusWithDatabaseUseCase;

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
  }

  /// 检查登录状态 (优先从数据库)
  Future<void> _checkLoginStatusWithDatabase() async {
    final result =
        await _checkLoginStatusWithDatabaseUseCase.execute(NoParams());
    result.fold(
      onSuccess: (isAuth) {
        isAuthenticated.value = isAuth;
        if (isAuth) {
          // ❌ 不在这里自动加载用户信息，避免 token 过期时发送 401 请求
          // _loadCurrentUser();
          _autoRefreshToken();
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
        }

        return true;
      },
      onFailure: (error) {
        Get.snackbar(
          '登录失败',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return false;
      },
    );
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
        }

        return true;
      },
      onFailure: (error) {
        Get.snackbar(
          '注册失败',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return false;
      },
    );
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
        Get.snackbar(
          '成功',
          '已退出登录',
          snackPosition: SnackPosition.BOTTOM,
        );
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
        Get.snackbar(
          '成功',
          '用户资料已更新',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      },
      onFailure: (error) {
        Get.snackbar(
          '更新失败',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return false;
      },
    );
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }
}
