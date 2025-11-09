import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 认证中间件 - 用于保护需要登录才能访问的页面
/// 
/// **工作原理：**
/// GetX 的 middleware.redirect() 是同步方法，无法 await token 检查
///
/// **实际的验证架构：**
/// 1. Bottom Nav 点击时检查 token（异步，主要验证点）
/// 2. HTTP 请求返回 401 时清除并跳转登录（后端验证）
/// 3. Middleware 仅作为路由配置说明，不做实际验证
///
/// **白名单路由（不使用此 middleware）：**
/// - `/` (home) - 首页，支持匿名访问
/// - `/login` - 登录页
/// - `/register` - 注册页
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // ⚠️ redirect 方法不能是 async，无法直接检查 token
    // 真正的验证在：
    // 1. Bottom Nav 点击时异步检查 token
    // 2. HTTP 层收到 401 时跳转登录
    return null; // 允许访问，由其他层验证
  }
}
