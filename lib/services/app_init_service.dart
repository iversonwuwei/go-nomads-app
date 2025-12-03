import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';

/// 应用启动初始化服务
/// 用于在应用启动时恢复用户登录状态
class AppInitService {
  static final AppInitService _instance = AppInitService._internal();
  factory AppInitService() => _instance;
  AppInitService._internal();

  bool _isInitialized = false;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化应用
  ///
  /// 在 main.dart 的 runApp 之前调用
  /// 主要功能：
  /// 1. 从 SQLite 恢复 token
  /// 2. 验证 token 是否过期
  /// 3. 如果有效则自动登录
  Future<void> initialize() async {
    if (_isInitialized) {
      log('ℹ️ AppInitService 已经初始化过了');
      return;
    }

    log('🚀 开始初始化应用...');

    try {
      // AuthStateController 会在 onInit 中自动从 SQLite 恢复登录状态
      // 这里只需要确保 AuthStateController 已经初始化
      try {
        final authController = Get.find<AuthStateController>();
        final isLoggedIn = authController.isAuthenticated.value;

        if (isLoggedIn) {
          log('✅ 用户登录状态已恢复');
        } else {
          log('ℹ️ 用户未登录或 token 已过期');
        }
      } catch (e) {
        log('⚠️ AuthStateController 未初始化: $e');
        log('ℹ️ 登录状态将在 AuthStateController 初始化后恢复');
      }

      _isInitialized = true;
      log('✅ 应用初始化完成');
    } catch (e) {
      log('❌ 应用初始化失败: $e');
      _isInitialized = true; // 即使失败也标记为已初始化
    }
  }

  /// 重置初始化状态（用于测试）
  void reset() {
    _isInitialized = false;
  }
}

/// 应用初始化包装器
/// 在应用启动时显示启动画面，同时进行初始化
class AppInitializer extends StatefulWidget {
  final Widget child;
  final Widget? splashScreen;

  const AppInitializer({
    super.key,
    required this.child,
    this.splashScreen,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await AppInitService().initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return widget.splashScreen ??
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
    }

    return widget.child;
  }
}
