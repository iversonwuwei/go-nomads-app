import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 统计数据部分组件
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
          Text(
            'Nomad Stats',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 12.w;
              final cardWidth = isMobile
                  ? (constraints.maxWidth - spacing) / 2
                  : 150.0;
              return Wrap(
                spacing: spacing,
                runSpacing: 12.w,
                children: [
                  _StatCard(
                    emoji: '🌍',
                    value: (stats?.countriesVisited ?? 0).toString(),
                    label: 'Countries',
                    cardWidth: cardWidth,
                  ),
                  _StatCard(
                    emoji: '🏙️',
                    value: (stats?.citiesLived ?? 0).toString(),
                    label: l10n.cities,
                    cardWidth: cardWidth,
                  ),
                  _StatCard(
                    emoji: '📅',
                    value: (stats?.daysNomading ?? 0).toString(),
                    label: 'Days nomading',
                    cardWidth: cardWidth,
                  ),
                  _ClickableStatCard(
                    emoji: '🤝',
                    value: (stats?.activeMeetups ?? 0).toString(),
                    label: 'Meetups',
                    cardWidth: cardWidth,
                    onTap: () => Get.toNamed(AppRoutes.myMeetups),
                  ),
                  _StatCard(
                    emoji: '✈️',
                    value: (stats?.tripsCompleted ?? 0).toString(),
                    label: 'Trips',
                    cardWidth: cardWidth,
                  ),
                  _ClickableStatCard(
                    emoji: '❤️',
                    value: (stats?.favoriteCitiesCount ?? favoriteCityCount).toString(),
                    label: 'Favorites',
                    cardWidth: cardWidth,
                    onTap: () => Get.toNamed(AppRoutes.favorites),
                  ),
                ],
              );
            },
          ),
        ],
      );
    });
  }
}

/// 统计卡片
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final double cardWidth;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 32.sp)),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Color(0xFF6b7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 可点击的统计卡片
class _ClickableStatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final double cardWidth;
  final VoidCallback? onTap;

  const _ClickableStatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.cardWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Color(0xFF6b7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right,
                    size: 14.r,
                    color: Color(0xFF6b7280),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
