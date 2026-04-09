import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// Hero 区域组件 - Nomads.com 风格
class HomeHeroSection extends GetView<HomePageController> {
  final bool isMobile;

  const HomeHeroSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 18 : 40,
                vertical: isMobile ? 24 : 44,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          FontAwesomeIcons.compass,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.explore,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 18 : 24),

                  Text(
                    l10n.homeHeroTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 26 : 40,
                      fontWeight: FontWeight.w800,
                      height: 1.02,
                      letterSpacing: -0.8,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    l10n.homeHeroSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      letterSpacing: 0.2.sp,
                    ),
                  ),

                  SizedBox(height: isMobile ? 18 : 28),

                  _ServiceCardsGrid(isMobile: isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 服务卡片网格
class _ServiceCardsGrid extends GetView<HomePageController> {
  final bool isMobile;

  const _ServiceCardsGrid({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    final isVerySmall = screenWidth < 400;
    final useGridLayout = screenWidth < 768;

    if (useGridLayout) {
      // 2x2 网格布局
      return Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // 第一行: Cities + Coworkings
            Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.city,
                    title: l10n.exploreCities,
                    color: const Color(0xFFFF4458),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
                    isCompact: isVerySmall,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.mapLocationDot,
                    title: l10n.homeHeroMapView,
                    color: const Color(0xFF3B82F6),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.globalMap)),
                    isCompact: isVerySmall,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // 第二行: Migration + Meetups
            Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.route,
                    title: l10n.migrationWorkspace,
                    color: const Color(0xFF10B981),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.migrationWorkspace)),
                    isCompact: isVerySmall,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.userGroup,
                    title: l10n.meetups,
                    color: const Color(0xFFF59E0B),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.meetupsList)),
                    isCompact: isVerySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // 1x4 横向布局(桌面端)
      return Container(
        constraints: BoxConstraints(maxWidth: 860),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.city,
                title: l10n.exploreCities,
                color: const Color(0xFFFF4458),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.mapLocationDot,
                title: l10n.homeHeroMapView,
                color: const Color(0xFF3B82F6),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.globalMap)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.route,
                title: l10n.migrationWorkspace,
                color: const Color(0xFF10B981),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.migrationWorkspace)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.userGroup,
                title: l10n.meetups,
                color: const Color(0xFFF59E0B),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.meetupsList)),
              ),
            ),
          ],
        ),
      );
    }
  }
}

/// 服务卡片组件
class _ServiceCard extends StatelessWidget {
  final bool isMobile;
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isCompact;

  const _ServiceCard({
    required this.isMobile,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 12 : (isMobile ? 14 : 18),
          horizontal: isCompact ? 10 : (isMobile ? 12 : 16),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.14),
              color.withValues(alpha: 0.22),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.24),
              blurRadius: 16.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isCompact ? 22 : (isMobile ? 24 : 28),
              ),
            ),
            SizedBox(height: isCompact ? 6 : (isMobile ? 8 : 10)),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 11 : (isMobile ? 12 : 13),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 特性亮点列表
class HomeFeatureHighlights extends StatelessWidget {
  final bool isMobile;

  const HomeFeatureHighlights({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {'icon': '🏆', 'text': l10n.attendMeetupsInCities},
      {'icon': '❤️', 'text': l10n.meetNewPeople},
      {'icon': '📊', 'text': l10n.researchDestinations},
      {'icon': '🌍', 'text': l10n.keepTrackTravels},
      {'icon': '💬', 'text': l10n.joinCommunityChat},
    ];

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: features.map((feature) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  feature['icon']!,
                  style: TextStyle(fontSize: 18.sp),
                ),
                SizedBox(width: 8.w),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 220.w : 250.w),
                  child: Text(
                    feature['text']!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
