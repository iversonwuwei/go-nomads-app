import 'dart:ui';

import 'package:go_nomads_app/layouts/bottom_nav/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 导航栏项目数据模型
class NavBarItem {
  final IconData icon;
  final String label;
  final int badge;

  const NavBarItem({
    required this.icon,
    required this.label,
    this.badge = 0,
  });
}

/// 现代化底部导航栏组件
class ModernBottomNavBar extends GetView<BottomNavController> {
  final List<NavBarItem> items;

  const ModernBottomNavBar({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度信息用于响应式布局
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据屏幕宽度计算响应式尺寸
    // 基准: 390px (iPhone 14 标准尺寸)
    final scaleFactor = (screenWidth / 390).clamp(0.85, 1.3);

    // 紧凑的导航栏尺寸
    final iconSize = (30 * scaleFactor).clamp(28.0, 34.0);
    final navBarHeight = (48 * scaleFactor).clamp(42.0, 54.0);
    final indicatorSize = (44 * scaleFactor).clamp(40.0, 50.0);
    final borderRadius = (36 * scaleFactor).clamp(30.0, 40.0);
    final horizontalMargin = (14 * scaleFactor).clamp(10.0, 18.0);
    final bottomMargin = (18 * scaleFactor).clamp(12.0, 22.0);

    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      final unreadCount = controller.unreadCount.value;

      // 动态更新 items 中的 badge
      final updatedItems = items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        // 消息会话页面（索引1）显示 IM 未读数量
        if (index == 1) {
          return NavBarItem(
            icon: item.icon,
            label: item.label,
            badge: controller.imUnreadCount.value,
          );
        }
        // 通知页面（索引3）显示通知未读数量
        if (index == 3) {
          return NavBarItem(
            icon: item.icon,
            label: item.label,
            badge: unreadCount,
          );
        }
        return item;
      }).toList();

      return Container(
        margin: EdgeInsets.fromLTRB(
          horizontalMargin,
          0,
          horizontalMargin,
          bottomMargin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 48.r,
              offset: const Offset(0, 12),
              spreadRadius: 2.r,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.10),
              blurRadius: 0,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.36),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: navBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(updatedItems.length, (index) {
                      final item = updatedItems[index];
                      final isSelected = currentIndex == index;
                      return Expanded(
                        child: _NavBarItemWidget(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => controller.onNavTap(index),
                          iconSize: iconSize,
                          navBarHeight: navBarHeight,
                          indicatorSize: indicatorSize,
                          scaleFactor: scaleFactor,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// 单个导航项组件
class _NavBarItemWidget extends StatelessWidget {
  final NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;
  final double navBarHeight;
  final double indicatorSize;
  final double scaleFactor;

  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.iconSize,
    required this.navBarHeight,
    required this.indicatorSize,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28.r * scaleFactor),
        splashColor: const Color(0xFF2196F3).withValues(alpha: 0.10),
        highlightColor: const Color(0xFF2196F3).withValues(alpha: 0.05),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: indicatorSize,
            height: navBarHeight * 0.9,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18.r * scaleFactor),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  item.icon,
                  size: iconSize,
                  color: isSelected
                      ? const Color(0xFF2196F3) // 选中：蓝色
                      : const Color(0xFF8E8E93), // 未选中：灰色
                ),
                if (item.badge > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4458),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.h,
                      ),
                      child: Text(
                        item.badge > 99 ? '99+' : '${item.badge}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
