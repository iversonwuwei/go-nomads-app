import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

/// 城市信息摘要卡片 (评分、评论数、收藏按钮)
class CityInfoSummaryCard extends StatelessWidget {
  final String cityId;
  final double overallScore;
  final int reviewCount;

  const CityInfoSummaryCard({
    super.key,
    required this.cityId,
    required this.overallScore,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final scoreLabel = isEnglish ? 'Score' : l10n.scores;
    final reviewLabel = isEnglish ? 'Reviews' : l10n.reviews;
    final footerText = isEnglish ? 'Contributed by the nomad community' : '由数字游民社区贡献';

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 10.w,
                  children: [
                    _InfoPill(
                      icon: FontAwesomeIcons.star,
                      iconColor: Colors.amber[700]!,
                      label: scoreLabel,
                      value: overallScore.toStringAsFixed(1),
                    ),
                    _InfoPill(
                      icon: FontAwesomeIcons.solidMessage,
                      iconColor: Colors.blueGrey[700]!,
                      label: reviewLabel,
                      value: '$reviewCount',
                    ),
                  ],
                ),
              ),
              _FavoriteButton(cityId: cityId),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            footerText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.sp,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14.r),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 收藏按钮组件
class _FavoriteButton extends StatelessWidget {
  final String cityId;

  const _FavoriteButton({required this.cityId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cityController = Get.find<CityDetailStateController>();
      final isFavorited = cityController.isFavorited.value;
      final isToggling = cityController.isTogglingFavorite.value;

      return Container(
        decoration: BoxDecoration(
          color: isFavorited ? AppColors.cityPrimary.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: isToggling
            ? SizedBox(
                width: 48.w,
                height: 48.h,
                child: Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.cityPrimary),
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: Icon(
                  FontAwesomeIcons.heart,
                  color: isFavorited ? AppColors.cityPrimary : Colors.grey[700],
                  size: 22.r,
                ),
                onPressed: () => cityController.toggleFavorite(),
              ),
      );
    });
  }
}
