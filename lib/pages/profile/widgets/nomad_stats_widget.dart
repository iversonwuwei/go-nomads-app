import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/widgets/profile_section_header.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 统计数据部分组件 (高级定制 Bento 网格风格)
class NomadStatsWidget extends StatelessWidget {
  final bool isMobile;

  const NomadStatsWidget({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<UserStateController>();

    return Obx(() {
      final stats = controller.nomadStats.value;
      final favoriteCityCount = controller.favoriteCityIds.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionHeader(
            title: l10n.profileNomadJourney,
          ),
          SizedBox(height: 16.h),

          // === Bento 布局 ===

          // 1. 核心数据 (深邃太空风)
          _BentoHeroCard(
            title: l10n.modularProfileStatDays,
            value: (stats?.daysNomading ?? 0).toString(),
            emoji: '🪐',
            gradient: const [Color(0xFF1a1a24), Color(0xFF322d44)],
            textColor: Colors.white,
          ),
          SizedBox(height: 12.h),

          // 2. 国家与城市对比
          Row(
            children: [
              Expanded(
                child: _BentoSquareCard(
                  title: l10n.modularProfileStatCountries,
                  value: (stats?.countriesVisited ?? 0).toString(),
                  emoji: '🌍',
                  gradient: const [Color(0xFF00c6ff), Color(0xFF0072ff)],
                  textColor: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _BentoSquareCard(
                  title: l10n.cities,
                  value: (stats?.citiesLived ?? 0).toString(),
                  emoji: '🏙️',
                  gradient: const [Colors.white, Colors.white],
                  textColor: const Color(0xFF1a1a1a),
                  isLight: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 3. 活动数据 (品牌红渐变)
          _BentoHeroCard(
            title: l10n.profileActiveMeetups,
            value: (stats?.activeMeetups ?? 0).toString(),
            emoji: '🤝',
            gradient: const [Color(0xFFFF4458), Color(0xFFFF758C)],
            textColor: Colors.white,
            onTap: () => Get.toNamed(AppRoutes.myMeetups),
            actionText: l10n.exploreNow,
          ),
          SizedBox(height: 12.h),

          // 4. 行程与喜欢
          Row(
            children: [
              Expanded(
                child: _BentoSquareCard(
                  title: l10n.modularProfileStatTrips,
                  value: (stats?.tripsCompleted ?? 0).toString(),
                  emoji: '✈️',
                  gradient: const [Colors.white, Colors.white],
                  textColor: const Color(0xFF1a1a1a),
                  isLight: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _BentoSquareCard(
                  title: l10n.favorites,
                  value: (stats?.favoriteCitiesCount ?? favoriteCityCount).toString(),
                  emoji: '❤️',
                  gradient: const [Color(0xFFFFF0F0), Color(0xFFFFE0E0)],
                  textColor: const Color(0xFFFF4458),
                  onTap: () => Get.toNamed(AppRoutes.favorites),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

/// 全宽 Hero 卡片
class _BentoHeroCard extends StatelessWidget {
  final String title;
  final String value;
  final String emoji;
  final List<Color> gradient;
  final Color textColor;
  final VoidCallback? onTap;
  final String? actionText;

  const _BentoHeroCard({
    required this.title,
    required this.value,
    required this.emoji,
    required this.gradient,
    required this.textColor,
    this.onTap,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.3),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -10.w,
              bottom: -20.h,
              child: Transform.rotate(
                angle: -0.15,
                child: Opacity(
                  opacity: 0.15,
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 100.sp, height: 1.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: textColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (actionText != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                actionText!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10.sp,
                                color: textColor,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 44.sp,
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 方形拼块
class _BentoSquareCard extends StatelessWidget {
  final String title;
  final String value;
  final String emoji;
  final List<Color> gradient;
  final Color textColor;
  final bool isLight;
  final VoidCallback? onTap;

  const _BentoSquareCard({
    required this.title,
    required this.value,
    required this.emoji,
    required this.gradient,
    required this.textColor,
    this.isLight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: isLight ? Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1.5) : null,
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  )
                ]
              : [
                  BoxShadow(
                    color: gradient.last.withValues(alpha: 0.3),
                    blurRadius: 12.r,
                    offset: Offset(0, 6.h),
                  )
                ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -10.w,
              bottom: -15.h,
              child: Transform.rotate(
                angle: -0.15,
                child: Opacity(
                  opacity: isLight ? 0.06 : 0.25,
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 80.sp, height: 1.0),
                  ),
                ),
              ),
            ),
            if (onTap != null)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 20.r,
                  color: isLight ? Colors.grey[400] : textColor.withValues(alpha: 0.5),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isLight ? Colors.grey[600] : textColor.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 34.sp,
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
