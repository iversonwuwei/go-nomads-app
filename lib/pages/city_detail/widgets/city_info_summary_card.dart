import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_detail_state_controller.dart';
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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 评分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.star,
                      color: Colors.amber[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      overallScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($reviewCount)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'From digital nomads',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 收藏按钮
          _FavoriteButton(cityId: cityId),
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
