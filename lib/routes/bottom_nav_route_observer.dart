import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../layouts/bottom_nav/bottom_nav_controller.dart';

/// 路由观察者：保持底部导航栏图标选中状态与当前显示页面同步。
///
/// 当路由 push / pop / replace 时，自动调用
/// [BottomNavController.updateIndexByRoute] 更新 currentIndex。
class BottomNavRouteObserver extends NavigatorObserver {
  bool _syncScheduled = false;
  String? _lastSyncedRoute;

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _syncBottomNavIndex('didPop');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _syncBottomNavIndex('didPush');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _syncBottomNavIndex('didReplace');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _syncBottomNavIndex('didRemove');
  }

  void _syncBottomNavIndex(String trigger) {
    if (!Get.isRegistered<BottomNavController>() || _syncScheduled) return;

    _syncScheduled = true;

    // 延迟到下一帧，确保 Get.currentRoute 已更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!Get.isRegistered<BottomNavController>()) return;

      final controller = Get.find<BottomNavController>();
      if (controller.isClosed) return;

      final route = Get.currentRoute;
      if (route.isEmpty || route == _lastSyncedRoute) return;

      _lastSyncedRoute = route;
      log('🔄 BottomNavRouteObserver.$trigger → currentRoute=$route');
      controller.updateIndexByRoute(route: route);
    });
  }
}
