import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/profile_controller.dart';
import 'package:go_nomads_app/pages/profile/widgets/badges_section_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/login_notice_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/logout_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/membership_card_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/nomad_stats_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/profile_header_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/skills_interests_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/social_links_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/travel_history_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/travel_plans_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:get/get.dart';

/// Profile 页面 - 使用 GetView 模式
///
/// 展示用户个人资料、会员信息、旅行计划等
class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保控制器已注册
    _ensureControllerRegistered();

    return const _ProfilePageContent();
  }

  /// 确保控制器已注册
  void _ensureControllerRegistered() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
  }
}

/// Profile 页面内容组件
class _ProfilePageContent extends GetView<ProfileController> {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          // 加载中状态
          if (controller.isPageLoading || controller.isLoadingUser) {
            return const ProfileSkeleton();
          }

          final user = controller.currentUser;

          // 未登录或数据为空
          if (user == null) {
            return const ProfileSkeleton();
          }

          return _ProfileContentView(
            onLogout: () => _showLogoutDialog(context, l10n),
          );
        }),
      ),
    );
  }

  /// 显示退出登录确认对话框
  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
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
              controller.logout();
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
}

/// Profile 内容视图
class _ProfileContentView extends GetView<ProfileController> {
  final VoidCallback onLogout;

  const _ProfileContentView({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: isMobile ? 24 : 32,
              ),
              child: _ProfileSections(
                isMobile: isMobile,
                l10n: l10n,
                onLogout: onLogout,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile 各个区块组合
class _ProfileSections extends GetView<ProfileController> {
  final bool isMobile;
  final AppLocalizations l10n;
  final VoidCallback onLogout;

  const _ProfileSections({
    required this.isMobile,
    required this.l10n,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser;
      if (user == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 登录提示（未登录时显示）
          if (!controller.isLoggedIn) LoginNoticeWidget(isMobile: isMobile),

          // 用户头像和基本信息
          ProfileHeaderWidget(user: user, isMobile: isMobile),
          const SizedBox(height: 24),

          // 会员卡片
          const MembershipCardWidget(),
          const SizedBox(height: 32),

          // 旅行计划
          TravelPlansWidget(isMobile: isMobile),
          const SizedBox(height: 32),

          // Nomad 统计
          NomadStatsWidget(isMobile: isMobile),
          const SizedBox(height: 32),

          // 徽章
          BadgesSectionWidget(badges: user.badges, isMobile: isMobile),
          const SizedBox(height: 32),

          // 技能和兴趣
          SkillsInterestsWidget(user: user, isMobile: isMobile),
          const SizedBox(height: 32),

          // 旅行历史
          TravelHistoryWidget(
            latestTrip: user.latestTravelHistory,
            isMobile: isMobile,
          ),
          const SizedBox(height: 32),

          // 社交链接
          SocialLinksWidget(
            links: user.socialLinks,
            isMobile: isMobile,
            title: l10n.connect,
          ),
          const SizedBox(height: 48),

          // 退出登录按钮
          LogoutWidget(onLogout: onLogout),
        ],
      );
    });
  }
}
