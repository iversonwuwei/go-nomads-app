import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bottom_nav_controller.dart';
import '../controllers/user_state_controller.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';

/// 全局底部导航布局包装器
/// 包装任意页面内容，在底部显示导航栏
class BottomNavLayout extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;

  const BottomNavLayout({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController(), permanent: true);
    final userStateController = Get.find<UserStateController>();
    final l10n = AppLocalizations.of(context)!;

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

        return _ModernBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            // AI助手需要特殊处理 (索引 2)
            if (index == 2) {
              if (userStateController.isLoggedIn) {
                // 已登录，跳转到AI聊天页面
                Get.toNamed(AppRoutes.aiChat);
              } else {
                // 未登录，跳转到登录页
                print('🔒 需要登录才能使用AI助手');
                Get.toNamed(AppRoutes.login);
              }
              return; // 不改变当前索引
            }

            // 其他标签页正常切换
            controller.changeTab(index);

            // 根据索引跳转到对应页面
            switch (index) {
              case 0: // 主页
                Get.offAllNamed(AppRoutes.home);
                break;
              case 1: // Profile
                Get.toNamed(AppRoutes.profile);
                break;
              case 3: // 编辑资料
                Get.toNamed(AppRoutes.profileEdit);
                break;
            }
          },
          items: [
            _NavBarItem(
              icon: Icons.home,
              label: l10n.home,
            ),
            _NavBarItem(
              icon: Icons.person,
              label: 'Profile',
            ),
            _NavBarItem(
              icon: Icons.memory,
              label: 'AI助手',
            ),
            _NavBarItem(
              icon: Icons.settings,
              label: '编辑',
            ),
          ],
        );
      }),
    );
  }
}

/// 导航栏项目数据模型
class _NavBarItem {
  final IconData icon;
  final String label;

  _NavBarItem({
    required this.icon,
    required this.label,
  });
}

/// 现代化底部导航栏组件
class _ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<_NavBarItem> items;

  const _ModernBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度信息用于响应式布局
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据屏幕宽度计算响应式尺寸
    // 基准: 390px (iPhone 14 标准尺寸)
    final scaleFactor = (screenWidth / 390).clamp(0.85, 1.3);

    // 紧凑的导航栏尺寸 - 只包裹图标,更小更透明
    final iconSize = (30 * scaleFactor).clamp(28.0, 34.0); // 更大
    final navBarHeight = (48 * scaleFactor).clamp(42.0, 54.0); // 更小
    final indicatorSize = (44 * scaleFactor).clamp(40.0, 50.0); // 用于选中背景/容器高度
    final borderRadius = (36 * scaleFactor).clamp(30.0, 40.0); // 更圆
    final horizontalMargin = (14 * scaleFactor).clamp(10.0, 18.0); // 更窄
    final bottomMargin = (18 * scaleFactor).clamp(12.0, 22.0); // 更窄

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
          // 更强更立体的阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 48,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.10),
            blurRadius: 0,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 56, sigmaY: 56), // 更强毛玻璃
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.36), // 更透明
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
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
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = currentIndex == index;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onTap(index),
                          borderRadius: BorderRadius.circular(28 * scaleFactor),
                          splashColor:
                              const Color(0xFF2196F3).withOpacity(0.10),
                          highlightColor:
                              const Color(0xFF2196F3).withOpacity(0.05),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: indicatorSize,
                              height: navBarHeight * 0.9, // 保证垂直居中
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2196F3).withOpacity(0.13)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(18 * scaleFactor),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF2196F3)
                                              .withOpacity(0.10),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                item.icon,
                                size: iconSize,
                                color: isSelected
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ),
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
  }
}
