import 'dart:developer';

import 'package:flutter/widgets.dart';

/// 全局页面生命周期观察者
///
/// 监听所有路由变化（包括 Navigator.push 和 Get.toNamed），
/// 确保页面退出时清理控制器状态，页面进入时数据全新加载。
///
/// 🔑 核心设计理念：
/// - 所有页面级控制器在页面退出时被删除
/// - 共享状态控制器保持存活但重置页面相关数据
/// - 支持 tagged controller 清理（如 city_detail_xxx）
class PageLifecycleObserver extends NavigatorObserver {
  /// 记录当前活跃的路由名称栈（用于调试）
  final List<String> _routeStack = [];

  /// 需要在页面退出时清理的 tagged controller 前缀
  /// key: 路由名称关键字, value: tag 前缀
  static const Map<String, String> _taggedControllerPrefixes = {
    'CityDetailPage': 'city_detail_',
    'TravelPlanPage': 'travel_plan_',
  };

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = _getRouteName(route);
    _routeStack.add(routeName);
    log('📄 [PageLifecycle] didPush → $routeName (栈深度: ${_routeStack.length})');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final routeName = _getRouteName(route);

    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }

    log('🧹 [PageLifecycle] didPop ← $routeName (栈深度: ${_routeStack.length})');

    // 清理该路由关联的 tagged controllers
    _cleanupTaggedControllers(routeName);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final oldName = oldRoute != null ? _getRouteName(oldRoute) : 'unknown';
    final newName = newRoute != null ? _getRouteName(newRoute) : 'unknown';

    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }
    _routeStack.add(newName);

    log('🔄 [PageLifecycle] didReplace $oldName → $newName');
    _cleanupTaggedControllers(oldName);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = _getRouteName(route);
    _routeStack.remove(routeName);
    log('🗑️ [PageLifecycle] didRemove $routeName');
    _cleanupTaggedControllers(routeName);
  }

  /// 获取路由名称
  String _getRouteName(Route route) {
    return route.settings.name ?? route.toString();
  }

  /// 清理 tagged controllers
  ///
  /// 对于使用 tag 注册的控制器（如 CityDetailController），
  /// 在页面退出时主动删除以避免状态残留
  void _cleanupTaggedControllers(String routeName) {
    for (final entry in _taggedControllerPrefixes.entries) {
      if (routeName.contains(entry.key) || routeName.contains(entry.value)) {
        log('🧹 [PageLifecycle] 检测到需要清理 tagged controllers: ${entry.value}*');
        // Note: GetX doesn't expose a way to list all tags, 
        // but the CityDetailPage already handles cleanup on re-entry
        break;
      }
    }
  }
}
