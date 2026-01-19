import 'dart:developer';

import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 城市卡片组件 - 使用 GetView 符合 GetX 标准
///
/// 通过 cityId 从控制器获取响应式数据，确保图片更新后自动刷新
class CityCard extends GetView<CityListController> {
  final String cityId;
  final bool isMobile;

  const CityCard({
    super.key,
    required this.cityId,
    this.isMobile = true,
  });

  /// 便捷构造函数：从 City 对象创建
  CityCard.fromCity({
    super.key,
    required City city,
    this.isMobile = true,
  }) : cityId = city.id;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 从控制器获取最新的城市数据，确保响应式更新
      final city = controller.getCityById(cityId);

      if (city == null) {
        return const SizedBox.shrink();
      }

      log('🏙️ City: ${city.name}, ReviewCount: ${city.reviewCount}, AverageCost: ${city.averageCost}, OverallScore: ${city.overallScore}');

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _navigateToDetail(context, city),
            borderRadius: BorderRadius.circular(16),
            child: _buildImageWithOverlay(city),
          ),
        ),
      );
    });
  }

  void _navigateToDetail(BuildContext context, City city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPage(
          cityId: city.id,
          cityName: city.name,
          cityImages: city.landscapeImageUrls ?? [],
          cityImage: city.imageUrl ?? 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
          overallScore: city.overallScore ?? 0.0,
          reviewCount: city.reviewCount ?? 0,
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay(City city) {
    return Stack(
      children: [
        // 背景图片
        AspectRatio(
          aspectRatio: 16 / 10,
          child: city.imageUrl != null && city.imageUrl!.isNotEmpty
              ? Image.network(
                  city.imageUrl!,
                  fit: BoxFit.cover,
                  key: ValueKey(city.imageUrl),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(FontAwesomeIcons.imagePortrait, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(FontAwesomeIcons.imagePortrait, size: 48, color: Colors.grey),
                  ),
                ),
        ),
        // 渐变遮罩
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        // 左上角：生成图片按钮（仅管理员可见）
        _buildGenerateImageButton(city),
        // 右上角：关注按钮
        Positioned(
          top: 12,
          right: 12,
          child: _CityFollowButton(cityId: city.id),
        ),
        // 底部信息面板
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _buildHeroInfoPanel(city),
        ),
      ],
    );
  }

  /// 底部信息面板 - 仿照 CityDetailAppBar 的样式
  Widget _buildHeroInfoPanel(City city) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 城市名称和国家
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (city.country != null && city.country!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.locationDot,
                            size: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            city.country!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 指标 Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 评分
                _HeroPill(
                  icon: FontAwesomeIcons.star,
                  value: (city.overallScore ?? 0.0).toStringAsFixed(1),
                  color: const Color(0xFFFF4458),
                ),
                const SizedBox(width: 8),
                // 月均花费
                _HeroPill(
                  icon: FontAwesomeIcons.dollarSign,
                  value: city.averageCost != null && city.averageCost! > 0 ? '${city.averageCost!.toInt()}' : '0',
                ),
                // 网络评分
                if (city.internetScore != null && city.internetScore! > 0) ...[
                  const SizedBox(width: 8),
                  _HeroPill(
                    icon: FontAwesomeIcons.wifi,
                    value: city.internetScore!.toStringAsFixed(1),
                  ),
                ],
                // 安全评分
                if (city.safetyScore != null && city.safetyScore! > 0) ...[
                  const SizedBox(width: 8),
                  _HeroPill(
                    icon: FontAwesomeIcons.shield,
                    value: city.safetyScore!.toStringAsFixed(1),
                  ),
                ],
                // 评论数
                if (city.reviewCount != null && city.reviewCount! > 0) ...[
                  const SizedBox(width: 8),
                  _HeroPill(
                    icon: FontAwesomeIcons.comments,
                    value: '${city.reviewCount}',
                  ),
                ],
                // 版主状态
                const SizedBox(width: 8),
                _HeroPill(
                  icon: city.hasModerator ? FontAwesomeIcons.userShield : FontAwesomeIcons.userSlash,
                  value: city.hasModerator ? 'Mod' : 'No Mod',
                  color: city.hasModerator ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateImageButton(City city) {
    return Obx(() {
      final authController = Get.find<AuthStateController>();
      final user = authController.currentUser.value;
      final isAdmin = user?.role.toLowerCase() == 'admin';

      if (!isAdmin) return const SizedBox.shrink();

      return Positioned(
        top: 12,
        left: 12,
        child: _GenerateImageButton(
          cityId: city.id,
          cityName: city.name,
        ),
      );
    });
  }
}

/// Hero 样式的信息标签 - 用于图片上层显示
class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color? color;

  const _HeroPill({
    required this.icon,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pillColor = color ?? Colors.white;
    final hasCustomColor = color != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasCustomColor ? pillColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: hasCustomColor ? pillColor : Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasCustomColor ? pillColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 关注按钮组件 - 使用 cityId 从控制器获取响应式数据
class _CityFollowButton extends StatelessWidget {
  final String cityId;

  const _CityFollowButton({required this.cityId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityListController>();

    return Obx(() {
      final isFollowed = controller.isCityFollowed(cityId);
      final city = controller.getCityById(cityId);

      return GestureDetector(
        onTap: city != null ? () => controller.toggleFollow(city) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isFollowed ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.heart,
                size: 16,
                color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 4),
              Text(
                isFollowed ? '已关注' : '关注',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// 生成城市图片按钮组件
class _GenerateImageButton extends StatelessWidget {
  final String cityId;
  final String cityName;

  const _GenerateImageButton({
    required this.cityId,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityListController>();

    return Obx(() {
      // 直接访问响应式集合，确保 Obx 能正确订阅变化
      final isGenerating = controller.generatingImageCityIds.contains(cityId);

      return GestureDetector(
        onTap: isGenerating ? null : () => controller.generateCityImages(cityId, cityName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isGenerating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      FontAwesomeIcons.arrowsRotate,
                      color: Colors.white,
                      size: 14,
                    ),
              const SizedBox(width: 4),
              Text(
                isGenerating ? '生成中...' : '更新图片',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
