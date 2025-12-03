import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';

/// 认证中间件 - 用于保护需要登录才能访问的页面
///
/// **工作原理：**
/// 1. 检查 AuthStateController 的 isAuthenticated 状态
/// 2. 如果未登录，重定向到登录页面
/// 3. 如果已登录，允许访问目标页面
///
/// **白名单路由（不使用此 middleware）：**
/// - `/login` - 登录页
/// - `/register` - 注册页
///
/// **所有其他路由（包括首页）都需要认证**
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      // 获取 AuthStateController
      final authController = Get.find<AuthStateController>();

      // 1️⃣ 检查是否已登录
      if (!authController.isAuthenticated.value) {
        log('⚠️ AuthMiddleware: 未登录，重定向到登录页面 (from: $route)');
        return const RouteSettings(name: AppRoutes.login);
      }

      // 2️⃣ 检查 Token 是否存在且未过期
      final token = authController.currentToken.value;

      if (token == null) {
        log('⚠️ AuthMiddleware: Token 为空，重定向到登录页面 (from: $route)');
        // 清除无效的登录状态
        authController.isAuthenticated.value = false;
        authController.currentUser.value = null;
        return const RouteSettings(name: AppRoutes.login);
      }

      // 3️⃣ 检查 Token 是否过期
      if (token.isExpired) {
        log('⚠️ AuthMiddleware: Token 已过期，重定向到登录页面 (from: $route)');
        log('   ExpiresAt: ${token.expiresAt}');
        log('   Current: ${DateTime.now()}');

        // 清除过期的认证状态
        authController.isAuthenticated.value = false;
        authController.currentUser.value = null;
        authController.currentToken.value = null;

        // 异步清除存储的 token
        authController.logout();

        return const RouteSettings(name: AppRoutes.login);
      }

      // ✅ Token 有效，允许访问
      log('✅ AuthMiddleware: Token 有效，允许访问 $route');
      log('   ExpiresAt: ${token.expiresAt}');
      return null;
    } catch (e) {
      // AuthStateController 未就绪，重定向到登录页
      log('⚠️ AuthMiddleware: 发生异常，重定向到登录页面 (error: $e)');
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}
