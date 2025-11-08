import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/auth/presentation/controllers/auth_state_controller.dart';
import '../features/user/presentation/controllers/user_state_controller.dart';
import '../routes/app_routes.dart';

/// 认证中间件 - 用于保护需要登录才能访问的页面
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    print('🔒 AuthMiddleware: 检查路由 $route 的访问权限');

    // 检查 AuthStateController 的登录状态
    // 注意：在应用启动时，AuthStateController.onInit() 已经从 SQLite 恢复了 token
    try {
      final authController = Get.find<AuthStateController>();
      final isAuthenticated = authController.isAuthenticated.value;
      print('   认证状态: ${isAuthenticated ? "已登录" : "未登录"}');

      // 如果未登录，重定向到登录页
      if (!isAuthenticated) {
        print('❌ 用户未登录，重定向到登录页');
        print('   原始目标: $route');
        return const RouteSettings(name: AppRoutes.login);
      }

      // 检查用户状态控制器（兼容旧逻辑）
      try {
        final userStateController = Get.find<UserStateController>();
        print('   用户登录状态: ${userStateController.isLoggedIn}');
        print('   当前账户ID: ${userStateController.currentAccountId}');

        if (!userStateController.isLoggedIn) {
          print('⚠️ 用户状态控制器显示未登录，但 AuthStateController 显示已登录');
          // 这里可以选择重新同步用户状态
        }
      } catch (e) {
        print('⚠️ 无法获取用户状态控制器: $e');
      }

      print('✅ 认证验证通过，允许访问');
      return null; // 返回 null 表示允许访问
    } catch (e) {
      print('❌ 无法获取 AuthStateController: $e');
      print('   重定向到登录页');
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}

/// 认证守卫 Widget
/// 用于包装需要认证的页面，支持异步 token 恢复
class AuthGuard extends StatefulWidget {
  final Widget child;
  final String redirectTo;
  final Widget? loadingWidget;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo = AppRoutes.login,
    this.loadingWidget,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('🔐 AuthGuard: 开始检查认证状态...');

    try {
      // 从 AuthStateController 获取认证状态
      // AuthStateController.onInit() 已经从 SQLite 恢复了 token
      final authController = Get.find<AuthStateController>();
      final isLoggedIn = authController.isAuthenticated.value;

      if (mounted) {
        setState(() {
          _isAuthenticated = isLoggedIn;
          _isChecking = false;
        });

        if (!isLoggedIn) {
          print('❌ 认证失败，跳转到登录页');
          Get.offAllNamed(widget.redirectTo);
        } else {
          print('✅ 认证成功');
        }
      }
    } catch (e) {
      print('❌ 无法获取 AuthStateController: $e');
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isChecking = false;
        });
        Get.offAllNamed(widget.redirectTo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return widget.loadingWidget ??
          const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Redirecting to login...'),
        ),
      );
    }

    return widget.child;
  }
}

/// 简单的认证检查函数
/// 用于在页面的 initState 中调用
Future<bool> checkAuthAndRedirect() async {
  try {
    final authController = Get.find<AuthStateController>();
    final isLoggedIn = authController.isAuthenticated.value;

    // 如果未登录，跳转到登录页
    if (!isLoggedIn) {
      print('❌ 认证失败，跳转到登录页');
      Get.offAllNamed(AppRoutes.login);
      return false;
    }

    print('✅ 认证成功');
    return true;
  } catch (e) {
    print('❌ 无法获取 AuthStateController: $e');
    Get.offAllNamed(AppRoutes.login);
    return false;
  }
}
