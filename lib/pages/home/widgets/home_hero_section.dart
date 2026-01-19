import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
                horizontal: isMobile ? 24 : 48,
                vertical: isMobile ? 40 : 60,
              ),
              child: Column(
                children: [
                  // Logo和标题区域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.earthAmericas,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.goNomad,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 42,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 24 : 32),

                  // 副标题
                  Text(
                    l10n.joinGlobalCommunity,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.livingTravelingWorld,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: isMobile ? 32 : 40),

                  // 服务卡片
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
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // 第一行: Cities + Coworkings
            Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.city,
                    title: l10n.cities,
                    color: const Color(0xFFFF4458),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
                    isCompact: isVerySmall,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.building,
                    title: l10n.coworks,
                    color: const Color(0xFF6366F1),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.coworking)),
                    isCompact: isVerySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第二行: Meetups + Innovation
            Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.userGroup,
                    title: l10n.meetups,
                    color: const Color(0xFF10B981),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.meetupsList)),
                    isCompact: isVerySmall,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ServiceCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.lightbulb,
                    title: l10n.innovation,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.innovation)),
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
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.city,
                title: l10n.cities,
                color: const Color(0xFFFF4458),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.building,
                title: l10n.coworks,
                color: const Color(0xFF6366F1),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.coworking)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.userGroup,
                title: l10n.meetups,
                color: const Color(0xFF10B981),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.meetupsList)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                isMobile: false,
                icon: FontAwesomeIcons.lightbulb,
                title: l10n.innovation,
                color: const Color(0xFF8B5CF6),
                onTap: () => controller.checkLoginAndNavigate(() => Get.toNamed(AppRoutes.innovation)),
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
          vertical: isCompact ? 16 : (isMobile ? 20 : 24),
          horizontal: isCompact ? 12 : (isMobile ? 16 : 20),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 10 : 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isCompact ? 28 : (isMobile ? 32 : 36),
              ),
            ),
            SizedBox(height: isCompact ? 8 : (isMobile ? 12 : 14)),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 12 : (isMobile ? 13 : 15),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature['text']!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 15 : 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0.2,
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
