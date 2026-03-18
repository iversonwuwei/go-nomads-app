import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 页面生命周期中间件 - 用于 GetPage 路由
///
/// 确保每次进入页面时清理旧的页面级控制器，
/// 让 Binding 能够创建全新的控制器实例。
///
/// 使用方式:
/// ```dart
/// GetPage(
///   name: '/city-list',
///   page: () => const CityListPage(),
///   binding: CityListBinding(),
///   middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
/// )
/// ```
class PageLifecycleMiddleware extends GetMiddleware {
  /// 中间件优先级 - 在 AuthMiddleware (priority=0) 之后执行
  @override
  int? get priority => 10;

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page != null) {
      log('📄 [PageLifecycle] 准备加载页面: ${page.name}');
    }
    return super.onPageCalled(page);
  }

  @override
  Widget onPageBuilt(Widget page) {
    log('✅ [PageLifecycle] 页面构建完成: ${page.runtimeType}');
    return super.onPageBuilt(page);
  }

  @override
  void onPageDispose() {
    log('🧹 [PageLifecycle] 页面被销毁，控制器将被自动清理');
    super.onPageDispose();
  }
}
