import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/profile_controller.dart';
import 'package:go_nomads_app/pages/profile/widgets/badges_section_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/help_and_support_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/legal_info_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/login_notice_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/logout_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/membership_card_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/nomad_collaboration_profile_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/nomad_profile_snapshot_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/profile_header_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/travel_history_widget.dart';
import 'package:go_nomads_app/pages/profile/widgets/travel_plans_widget.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_hero_banner.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_section_header.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// Profile 页面 - 使用 GetView 模式
///
/// 展示用户个人资料、会员信息、旅行计划等
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAwareRefreshMixin<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
  }

  @override
  Future<void> onRouteResume() async {
    await _controller.onRouteResume();
  }

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageContent();
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
          final user = controller.currentUser;
          return AppLoadingSwitcher(
            isLoading: controller.isPageLoading || controller.isLoadingUser || user == null,
            loading: const ProfileSkeleton(),
            child: _ProfileContentView(
              onLogout: () => _showLogoutDialog(context, l10n),
            ),
          );
        }),
      ),
    );
  }

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFBFC),
            const Color(0xFFF6F8FC),
            const Color(0xFFF2F7FF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 16 : 24,
                      isMobile ? 18 : 28,
                      isMobile ? 16 : 24,
                      isMobile ? 32 : 40,
                    ),
                    child: _ProfileSections(
                      isMobile: isMobile,
                      l10n: l10n,
                      onLogout: onLogout,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInsightBoard extends StatelessWidget {
  final User user;
  final bool isMobile;
  final AppLocalizations l10n;

  const _ProfileInsightBoard({
    required this.user,
    required this.isMobile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final items = [
          _ProfileInsightItem(
              icon: Icons.workspace_premium_outlined, label: l10n.badges, value: user.badges.length.toString()),
          _ProfileInsightItem(
              icon: Icons.psychology_alt_outlined, label: l10n.skills, value: user.skills.length.toString()),
          _ProfileInsightItem(
              icon: Icons.favorite_border_rounded, label: l10n.interests, value: user.interests.length.toString()),
          _ProfileInsightItem(icon: Icons.link_rounded, label: l10n.connect, value: user.socialLinks.length.toString()),
        ];
        const spacing = 10.0;
        const columns = 2;
        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: cardWidth,
                  child: _ProfileInsightChip(
                    icon: item.icon,
                    label: item.label,
                    value: item.value,
                    compact: isMobile,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ProfileInsightItem {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInsightItem({
    required this.icon,
    required this.label,
    required this.value,
  });
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

          _ProfileCommandDeck(user: user, l10n: l10n),
          SizedBox(height: 16.h),
          if (isMobile)
            _ProfileMobileLayout(
              user: user,
              isMobile: isMobile,
              l10n: l10n,
              onLogout: onLogout,
            )
          else
            _ProfileDesktopLayout(
              user: user,
              isMobile: isMobile,
              l10n: l10n,
              onLogout: onLogout,
            ),
        ],
      );
    });
  }
}

class _ProfileMobileLayout extends StatelessWidget {
  final User user;
  final bool isMobile;
  final AppLocalizations l10n;
  final VoidCallback onLogout;

  const _ProfileMobileLayout({
    required this.user,
    required this.isMobile,
    required this.l10n,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileOverviewPanel(user: user, isMobile: isMobile, l10n: l10n),
        SizedBox(height: 16.h),
        const NomadProfileSnapshotWidget(),
        SizedBox(height: 16.h),
        _ProfileWorkspacePanel(isMobile: isMobile, l10n: l10n),
        SizedBox(height: 16.h),
        TravelHistoryWidget(
          latestTrip: user.latestTravelHistory,
          isMobile: isMobile,
        ),
        SizedBox(height: 16.h),
        const NomadCollaborationProfileWidget(),
        if (user.badges.isNotEmpty) ...[
          SizedBox(height: 16.h),
          CockpitPanel(
            child: BadgesSectionWidget(badges: user.badges, isMobile: isMobile),
          ),
        ],
        SizedBox(height: 16.h),
        _ProfileSupportPanel(l10n: l10n, onLogout: onLogout),
      ],
    );
  }
}

class _ProfileDesktopLayout extends StatelessWidget {
  final User user;
  final bool isMobile;
  final AppLocalizations l10n;
  final VoidCallback onLogout;

  const _ProfileDesktopLayout({
    required this.user,
    required this.isMobile,
    required this.l10n,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileOverviewPanel(user: user, isMobile: isMobile, l10n: l10n),
              SizedBox(height: 16.h),
              _ProfileWorkspacePanel(isMobile: isMobile, l10n: l10n),
              SizedBox(height: 16.h),
              const NomadProfileSnapshotWidget(),
              SizedBox(height: 16.h),
              TravelHistoryWidget(
                latestTrip: user.latestTravelHistory,
                isMobile: isMobile,
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NomadCollaborationProfileWidget(),
              if (user.badges.isNotEmpty) ...[
                SizedBox(height: 16.h),
                CockpitPanel(
                  child: BadgesSectionWidget(badges: user.badges, isMobile: isMobile),
                ),
              ],
              SizedBox(height: 16.h),
              _ProfileSupportPanel(l10n: l10n, onLogout: onLogout),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileOverviewPanel extends StatelessWidget {
  final User user;
  final bool isMobile;
  final AppLocalizations l10n;

  const _ProfileOverviewPanel({
    required this.user,
    required this.isMobile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CockpitSectionHeader(
            title: l10n.profileCockpitIdentityTitle,
            subtitle: isMobile ? '' : l10n.profileCockpitIdentitySubtitle,
          ),
          SizedBox(height: 16.h),
          if (isMobile) ...[
            ProfileHeaderWidget(user: user, isMobile: true),
            SizedBox(height: 16.h),
            _ProfileInsightBoard(user: user, isMobile: true, l10n: l10n),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: ProfileHeaderWidget(user: user, isMobile: false),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 4,
                  child: _ProfileInsightBoard(user: user, isMobile: false, l10n: l10n),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProfileWorkspacePanel extends StatelessWidget {
  final bool isMobile;
  final AppLocalizations l10n;

  const _ProfileWorkspacePanel({
    required this.isMobile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CockpitSectionHeader(
            title: l10n.profileCockpitOperationsTitle,
            subtitle: l10n.profileCockpitOperationsSubtitle,
          ),
          SizedBox(height: 16.h),
          const MembershipCardWidget(),
          SizedBox(height: 24.h),
          TravelPlansWidget(isMobile: isMobile),
        ],
      ),
    );
  }
}

class _ProfileSupportPanel extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onLogout;

  const _ProfileSupportPanel({
    required this.l10n,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CockpitSectionHeader(
            title: l10n.profileCockpitSupportTitle,
            subtitle: l10n.profileCockpitSupportSubtitle,
          ),
          SizedBox(height: 16.h),
          const HelpAndSupportWidget(),
          SizedBox(height: 16.h),
          const LegalInfoWidget(),
          SizedBox(height: 24.h),
          LogoutWidget(onLogout: onLogout),
        ],
      ),
    );
  }
}

class _ProfileInsightChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  const _ProfileInsightChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minWidth: 128.w, maxWidth: 176.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 34.w : 38.w,
            height: compact ? 34.h : 38.h,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: compact ? 16.r : 18.r,
              color: AppColors.cityPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 20.sp : 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCommandDeck extends GetView<ProfileController> {
  final User user;
  final AppLocalizations l10n;

  const _ProfileCommandDeck({
    required this.user,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final currentBase =
        [user.currentCity, user.currentCountry].whereType<String>().where((value) => value.isNotEmpty).join(', ');
    final metrics = isMobile
        ? [
            CockpitHeroMetric(
              icon: Icons.person_pin_circle_outlined,
              label:
                  '${l10n.profileCockpitCurrentBase}: ${currentBase.isEmpty ? l10n.communityCirclesFlexibleLabel : currentBase}',
            ),
            CockpitHeroMetric(
              icon: Icons.auto_awesome_rounded,
              label: '${l10n.profileCockpitExperience}: ${user.experienceLevel}',
            ),
          ]
        : [
            CockpitHeroMetric(
              icon: Icons.person_pin_circle_outlined,
              label:
                  '${l10n.profileCockpitCurrentBase}: ${currentBase.isEmpty ? l10n.communityCirclesFlexibleLabel : currentBase}',
            ),
            CockpitHeroMetric(
              icon: Icons.public_rounded,
              label: '${l10n.modularProfileStatCountries}: ${user.stats.countriesVisited}',
            ),
            CockpitHeroMetric(
              icon: Icons.location_city_rounded,
              label: '${l10n.cities}: ${user.stats.citiesVisited}',
            ),
            CockpitHeroMetric(
              icon: Icons.auto_awesome_rounded,
              label: '${l10n.profileCockpitExperience}: ${user.experienceLevel}',
            ),
          ];

    return CockpitHeroBanner(
      icon: Icons.dashboard_customize_rounded,
      title: l10n.profileCockpitTitle,
      subtitle: isMobile ? '' : l10n.profileCockpitSubtitle,
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF1F2), Color(0xFFF7FAFC), Color(0xFFEAF4FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          CockpitGlassIconButton(
            icon: Icons.refresh_rounded,
            iconColor: AppColors.textPrimary,
            onTap: controller.refreshData,
          ),
          CockpitGlassIconButton(
            icon: Icons.edit_outlined,
            iconColor: AppColors.textPrimary,
            onTap: () => Get.toNamed(AppRoutes.profileEdit),
          ),
        ],
      ),
      metrics: metrics,
    );
  }
}
