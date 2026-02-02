import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      icon: FontAwesomeIcons.star,
                      iconColor: Colors.amber[700]!,
                      label: '评分',
                      value: overallScore.toStringAsFixed(1),
                    ),
                    _InfoPill(
                      icon: FontAwesomeIcons.solidMessage,
                      iconColor: Colors.blueGrey[700]!,
                      label: '评论',
                      value: '$reviewCount',
                    ),
                  ],
                ),
              ),
              _FavoriteButton(cityId: cityId),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '由数字游民社区贡献',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: isToggling
            ? const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
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
                  size: 22,
                ),
                onPressed: () => cityController.toggleFavorite(),
              ),
      );
    });
  }
}
