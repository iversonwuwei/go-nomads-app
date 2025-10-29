import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../layouts/bottom_nav_layout.dart';

/// 底部导航中间件
/// 自动为所有页面包装底部导航栏（除了特定的排除页面）
class BottomNavMiddleware extends GetMiddleware {
  // 不需要底部导航的路由列表
  static final List<String> excludedRoutes = [
    '/login',
    '/register',
    '/ai-chat',
  ];

  @override
  RouteSettings? redirect(String? route) {
    // 不拦截路由，只在 onPageBuildStart 中包装页面
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page == null) return page;

    // 检查是否需要排除底部导航
    final shouldExclude = excludedRoutes.contains(page.name);

    if (shouldExclude) {
      // 不包装底部导航
      return page;
    }

    // 包装底部导航
    final originalPage = page.page;

    return page.copy(
      page: () {
        final widget = originalPage();
        // 如果页面已经是 BottomNavLayout，直接返回
        if (widget is BottomNavLayout) {
          return widget;
        }
        // 否则包装在 BottomNavLayout 中
        return BottomNavLayout(child: widget);
      },
    );
  }
}
