import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/layouts/bottom_nav/bottom_nav_controller.dart';

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
    final isCompact = items.length >= 6;

    // 紧凑的导航栏尺寸
    final iconSize = ((isCompact ? 20 : 22) * scaleFactor).clamp(18.0, 24.0);
    final navBarHeight = ((isCompact ? 62 : 68) * scaleFactor).clamp(58.0, 74.0);
    final borderRadius = (36 * scaleFactor).clamp(30.0, 40.0);
    final horizontalMargin = ((isCompact ? 10 : 14) * scaleFactor).clamp(8.0, 18.0);
    final bottomMargin = (18 * scaleFactor).clamp(12.0, 22.0);

    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      final inboxUnreadCount = controller.totalInboxUnreadCount;

      // 动态更新 items 中的 badge
      final updatedItems = items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        // 收件箱页面（索引3）显示聚合未读数量
        if (index == 3) {
          return NavBarItem(
            icon: item.icon,
            label: item.label,
            badge: inboxUnreadCount,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: AppUiTokens.softFloatingShadow,
          border: Border.all(color: AppColors.borderLight),
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
                    scaleFactor: scaleFactor,
                    isCompact: isCompact,
                  ),
                );
              }),
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
  final double scaleFactor;
  final bool isCompact;

  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.iconSize,
    required this.navBarHeight,
    required this.scaleFactor,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final badgeText = item.badge > 99 ? '99+' : '${item.badge}';
    final hasWideBadge = badgeText.length > 1;
    final badgeHeight = ((isCompact ? 15 : 17) * scaleFactor).clamp(14.0, 19.0);
    final badgeMinWidth = hasWideBadge ? ((isCompact ? 22 : 24) * scaleFactor).clamp(20.0, 28.0) : badgeHeight;
    final badgeHorizontalPadding = ((isCompact ? 4 : 5) * scaleFactor).clamp(3.0, 6.0);
    final badgeBorderWidth = ((isCompact ? 1.2 : 1.5) * scaleFactor).clamp(1.0, 1.6);
    final badgeOffset = ((isCompact ? 3.5 : 6) * scaleFactor).clamp(3.0, 7.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28.r * scaleFactor),
        splashColor: AppColors.cityPrimary.withValues(alpha: 0.08),
        highlightColor: AppColors.cityPrimary.withValues(alpha: 0.04),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.cityPrimary.withValues(alpha: 0.10) : Colors.transparent,
              borderRadius: BorderRadius.circular(18.r * scaleFactor),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: iconSize,
                      color: isSelected ? AppColors.cityPrimary : AppColors.textTertiary,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? AppColors.cityPrimary : AppColors.textTertiary,
                        fontSize: ((isCompact ? 9.0 : 10.0) * scaleFactor).clamp(8.5, 11.0),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                if (item.badge > 0)
                  Positioned(
                    right: -badgeOffset + 10.w,
                    top: -badgeOffset + 2.h,
                    child: Container(
                      height: badgeHeight,
                      padding: EdgeInsets.symmetric(horizontal: badgeHorizontalPadding),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.cityPrimary,
                        borderRadius: BorderRadius.circular(badgeHeight / 2),
                        border: Border.all(color: Colors.white, width: badgeBorderWidth),
                      ),
                      constraints: BoxConstraints(
                        minWidth: badgeMinWidth,
                        minHeight: badgeHeight,
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ((isCompact ? 8.5 : 9.5) * scaleFactor).clamp(8.0, 10.5),
                          fontWeight: FontWeight.w700,
                          height: 1,
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
