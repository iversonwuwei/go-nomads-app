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
              case 3: // 设置
                // 设置页面 - 可以跳转到语言设置或其他设置页
                Get.toNamed(AppRoutes.languageSettings);
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
              label: '设置',
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
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // 主阴影 - 更强的深度
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          // 辅助阴影 - 增加立体感
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 图标
                      Icon(
                        item.icon,
                        size: 24,
                        color: isSelected
                            ? const Color(0xFF2196F3) // 蓝色
                            : const Color(0xFF9E9E9E), // 灰色
                      ),
                      const SizedBox(height: 2),
                      // 文字标签
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF2196F3) // 蓝色
                              : const Color(0xFF9E9E9E), // 灰色
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // 底部指示器
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isSelected ? 28 : 0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3), // 蓝色指示器
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
