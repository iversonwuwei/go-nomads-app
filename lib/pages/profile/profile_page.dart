import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/profile/widgets/badges_section_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/login_notice_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/logout_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/membership_card_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/nomad_stats_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/profile_header_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/skills_interests_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/social_links_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/travel_history_widget.dart';
import 'package:df_admin_mobile/pages/profile/widgets/travel_plans_widget.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:get/get.dart';

/// Profile 页面 - 使用 GetView 模式重构
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAwareRefreshMixin<ProfilePage> {
  UserStateController get controller => Get.find<UserStateController>();
  AuthStateController get authController => Get.find<AuthStateController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    // 先检查 Token 是否存在
    if (!authController.isAuthenticated.value) {
      log('⚠️ 用户未登录，跳转到登录页');
      AppToast.info('Please login to view your profile', title: 'Login Required');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // 用户已认证，加载用户数据
    await controller.loadUserProfile();

    if (!mounted) return;

    if (controller.currentUser.value == null && controller.errorMessage.value.isNotEmpty) {
      log('⚠️ 加载用户数据失败，跳转到登录页');
      AppToast.info('Please login again', title: 'Session Expired');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // 加载用户统计数据
    controller.loadNomadStats();

    // 加载用户旅行计划
    _loadUserTravelPlans();
  }

  /// 加载用户旅行计划
  Future<void> _loadUserTravelPlans() async {
    try {
      final aiController = Get.find<AiStateController>();
      await aiController.loadUserTravelPlans(page: 1, pageSize: 1);
    } catch (e) {
      log('⚠️ 加载用户旅行计划失败: $e');
    }
  }

  /// 处理退出登录
  void _handleLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Get.dialog(
      AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF4458),
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  /// 执行退出登录操作
  Future<void> _performLogout() async {
    try {
      log('🚪 开始执行退出登录...');

      log('   当前登录状态: ${controller.isLoggedIn}');
      log('   当前用户: ${controller.currentUser.value?.name ?? "Unknown"}');
      log('   当前账户ID: ${controller.currentUser.value?.id ?? "0"}');

      await authController.logout();
      controller.clearUser();

      if (Get.isRegistered<NotificationStateController>()) {
        final notificationController = Get.find<NotificationStateController>();
        notificationController.clearNotifications();
      }

      log('✅ 用户状态已清除');
      log('   登录状态: ${controller.isLoggedIn}');

      AppToast.success(
        'You have been logged out successfully',
        title: 'Logout Success',
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      log('❌ 退出登录失败: $e');
      AppToast.error(
        'An error occurred during logout',
        title: 'Error',
      );
    }
  }

  @override
  Future<void> onRouteResume() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ProfileSkeleton();
          }

          final user = controller.currentUser.value;

          // 如果用户数据为空，检查是否需要跳转登录
          if (user == null) {
            if (!authController.isAuthenticated.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAllNamed(AppRoutes.login);
              });
            } else if (controller.errorMessage.value.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppToast.info('Please login again', title: 'Session Expired');
                Get.offAllNamed(AppRoutes.login);
              });
            }
            return const ProfileSkeleton();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadUserProfile();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 24 : 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Login Notice (if not logged in)
                        if (!controller.isLoggedIn) LoginNoticeWidget(isMobile: isMobile),

                        // Profile Header
                        ProfileHeaderWidget(user: user, isMobile: isMobile),
                        const SizedBox(height: 24),

                        // Membership Card
                        const MembershipCardWidget(),
                        const SizedBox(height: 32),

                        // My Travel Plans (AI Generated)
                        TravelPlansWidget(isMobile: isMobile),
                        const SizedBox(height: 32),

                        // Stats
                        NomadStatsWidget(isMobile: isMobile),
                        const SizedBox(height: 32),

                        // Badges
                        BadgesSectionWidget(badges: user.badges, isMobile: isMobile),
                        const SizedBox(height: 32),

                        // Skills & Interests
                        SkillsInterestsWidget(user: user, isMobile: isMobile),
                        const SizedBox(height: 32),

                        // Travel History
                        TravelHistoryWidget(latestTrip: user.latestTravelHistory, isMobile: isMobile),
                        const SizedBox(height: 32),

                        // Social Links
                        SocialLinksWidget(
                          links: user.socialLinks,
                          isMobile: isMobile,
                          title: l10n.connect,
                        ),

                        const SizedBox(height: 48),

                        // Logout
                        LogoutWidget(onLogout: () => _handleLogout(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
