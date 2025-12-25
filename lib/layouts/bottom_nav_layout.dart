import 'dart:developer';
import 'dart:ui';

import 'package:df_admin_mobile/controllers/bottom_nav_controller.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 全局底部导航布局包装器
/// 包装任意页面内容，在底部显示导航栏
class BottomNavLayout extends StatefulWidget {
  final Widget child;
  final bool showBottomNav;

  const BottomNavLayout({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  State<BottomNavLayout> createState() => _BottomNavLayoutState();
}

class _BottomNavLayoutState extends State<BottomNavLayout> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController(), permanent: true);
    final l10n = AppLocalizations.of(context)!;

    // 根据当前路由更新选中的标签索引
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateIndexByRoute();
    });

    // 如果不显示底部导航，直接返回子组件
    if (!widget.showBottomNav) {
      return widget.child;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Obx(() {
        // 如果底部导航不可见，返回空容器
        if (!controller.isBottomNavVisible.value) {
          return const SizedBox.shrink();
        }

        return _ModernBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) async {
            log('🔘 Bottom Nav 点击: index=$index');

            // 首页不需要验证，直接跳转
            if (index == 0) {
              log('✅ 首页，无需验证');
              controller.changeTab(index);
              Get.offAllNamed(AppRoutes.home);
              return;
            }

            // 🔒 其他所有页面都需要验证 token（索引 1, 2, 3）
            log('🔒 检查认证状态...');

            // 统一使用 AuthStateController 检查认证状态
            final authController = Get.find<AuthStateController>();
            final isAuthenticated = authController.isAuthenticated.value;
            final currentToken = authController.currentToken.value;

            log('   isAuthenticated: $isAuthenticated');
            log('   currentToken: ${currentToken?.accessToken != null ? '${currentToken!.accessToken.substring(0, 20)}...' : 'null'}');
            log('   currentToken.isExpired: ${currentToken?.isExpired ?? 'N/A'}');

            if (!isAuthenticated || currentToken == null) {
              log('❌ 未认证或无 token，跳转登录页');
              Get.toNamed(AppRoutes.login);
              return;
            }

            // 检查 token 是否过期
            if (currentToken.isExpired) {
              log('❌ Token 已过期，跳转登录页');
              Get.toNamed(AppRoutes.login);
              return;
            }

            // 认证有效，允许跳转
            log('✅ 认证有效，允许跳转');
            controller.changeTab(index);

            // 根据索引跳转到对应页面
            switch (index) {
              case 1: // Profile
                log('   → Profile 页面');
                Get.toNamed(AppRoutes.profile);
                break;
              case 2: // 用户消息列表（系统消息、通知等）
                log('   → 用户消息列表页面');
                Get.toNamed(AppRoutes.notifications);
                break;
            }
          },
          items: [
            _NavBarItem(
              icon: FontAwesomeIcons.house,
              label: l10n.home,
            ),
            _NavBarItem(
              icon: FontAwesomeIcons.user,
              label: 'Profile',
            ),
            _NavBarItem(
              icon: FontAwesomeIcons.solidBell,
              label: '消息',
              badge: controller.unreadCount.value,
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
  final int badge;

  _NavBarItem({
    required this.icon,
    required this.label,
    this.badge = 0,
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
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 48,
            offset: const Offset(0, 12),
            spreadRadius: 2,
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
          filter: ImageFilter.blur(sigmaX: 56, sigmaY: 56), // 更强毛玻璃
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.36), // 更透明
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
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = currentIndex == index;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onTap(index),
                          borderRadius: BorderRadius.circular(28 * scaleFactor),
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
                                color: Colors.transparent, // 去掉背景色
                                borderRadius: BorderRadius.circular(18 * scaleFactor),
                                // 去掉阴影
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
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF4458),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          item.badge > 99 ? '99+' : '${item.badge}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
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
