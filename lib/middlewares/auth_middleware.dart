import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_state_controller.dart';
import '../routes/app_routes.dart';
import '../services/nomads_auth_service.dart';

/// 认证中间件 - 用于保护需要登录才能访问的页面
class AuthMiddleware extends GetMiddleware {
  final NomadsAuthService _authService = NomadsAuthService();

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    print('🔒 AuthMiddleware: 检查路由 $route 的访问权限');

    // 检查 token 是否存在（同步检查内存中的 token）
    // 注意：在应用启动时，AppInitService 已经从 SQLite 恢复了 token
    // 所以这里直接检查内存中的 token 即可
    final hasToken = _authService.isLoggedIn();
    print('   Token 状态: ${hasToken ? "有效" : "无效"}');

    // 如果没有 token，重定向到登录页
    if (!hasToken) {
      print('❌ Token 不存在，重定向到登录页');
      print('   原始目标: $route');
      return const RouteSettings(name: AppRoutes.login);
    }

    // 检查用户状态控制器（兼容旧逻辑）
    try {
      final userStateController = Get.find<UserStateController>();
      print('   用户登录状态: ${userStateController.isLoggedIn}');
      print('   当前账户ID: ${userStateController.currentAccountId}');

      if (!userStateController.isLoggedIn) {
        print('⚠️ 用户状态控制器显示未登录，但 token 存在');
        // 这里可以选择重新同步用户状态或跳转登录
      }
    } catch (e) {
      print('⚠️ 无法获取用户状态控制器: $e');
    }

    print('✅ Token 验证通过，允许访问');
    return null; // 返回 null 表示允许访问
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
  final NomadsAuthService _authService = NomadsAuthService();
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('🔐 AuthGuard: 开始检查认证状态...');

    // 使用新的 checkLoginStatus 方法
    // 该方法会：
    // 1. 检查内存中的 token
    // 2. 如果内存中没有，从 SQLite 查询
    // 3. 验证 token 是否过期
    // 4. 如果有效，自动恢复到内存
    final isLoggedIn = await _authService.checkLoginStatus();

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
///
/// 使用 checkLoginStatus 方法进行完整的认证检查：
/// 1. 检查内存中的 token
/// 2. 如果内存中没有，从 SQLite 数据库查询
/// 3. 验证 token 是否过期
/// 4. 如果有效，自动恢复到内存中
Future<bool> checkAuthAndRedirect() async {
  final authService = NomadsAuthService();

  // 使用新的 checkLoginStatus 方法进行完整检查
  final isLoggedIn = await authService.checkLoginStatus();

  // 如果未登录，跳转到登录页
  if (!isLoggedIn) {
    print('❌ 认证失败，跳转到登录页');
    Get.offAllNamed(AppRoutes.login);
    return false;
  }

  print('✅ 认证成功');
  return true;
}
