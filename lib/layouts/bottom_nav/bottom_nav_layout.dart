import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/layouts/bottom_nav/bottom_nav_controller.dart';
import 'package:go_nomads_app/layouts/bottom_nav/widgets/modern_bottom_nav_bar.dart';

/// 全局底部导航布局包装器 - GetView 标准实现
/// 包装任意页面内容，在底部显示导航栏
class BottomNavLayout extends GetView<BottomNavController> {
  final Widget child;
  final bool showBottomNav;

  const BottomNavLayout({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 确保控制器已初始化（如果还没有的话）
    _ensureControllerInitialized();

    // 根据当前路由更新选中的标签索引
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateIndexByRoute();
    });

    // 如果不显示底部导航，直接返回子组件
    if (!showBottomNav) {
      return child;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Obx(() {
        // 如果底部导航不可见，返回空容器
        if (!controller.isBottomNavVisible.value) {
          return const SizedBox.shrink();
        }

        return ModernBottomNavBar(
          items: [
            NavBarItem(
              icon: FontAwesomeIcons.house,
              label: l10n.home,
            ),
            NavBarItem(
              icon: FontAwesomeIcons.solidCommentDots,
              label: '消息',
              badge: controller.imUnreadCount.value,
            ),
            NavBarItem(
              icon: FontAwesomeIcons.wandMagicSparkles,
              label: l10n.aiChat,
            ),
            NavBarItem(
              icon: FontAwesomeIcons.route,
              label: l10n.aiTravelPlanner,
            ),
            NavBarItem(
              icon: FontAwesomeIcons.solidBell,
              label: '通知',
              badge: controller.unreadCount.value,
            ),
            const NavBarItem(
              icon: FontAwesomeIcons.user,
              label: '我的',
            ),
          ],
        );
      }),
    );
  }

  /// 确保控制器已初始化
  void _ensureControllerInitialized() {
    if (!Get.isRegistered<BottomNavController>()) {
      Get.put<BottomNavController>(BottomNavController(), permanent: true);
    }
  }
}
