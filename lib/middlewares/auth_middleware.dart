import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_state_controller.dart';
import '../routes/app_routes.dart';

/// 认证中间件 - 用于保护需要登录才能访问的页面
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    print('🔒 AuthMiddleware: 检查路由 $route 的访问权限');

    // 获取用户状态控制器
    final userStateController = Get.find<UserStateController>();

    print('   当前登录状态: ${userStateController.isLoggedIn}');
    print('   当前账户ID: ${userStateController.currentAccountId}');

    // 如果未登录,重定向到登录页
    if (!userStateController.isLoggedIn) {
      print('❌ 用户未登录,重定向到登录页');
      print('   原始目标: $route');
      return const RouteSettings(name: AppRoutes.login);
    }

    print('✅ 用户已登录,允许访问');
    return null; // 返回 null 表示允许访问
  }
}
