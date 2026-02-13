import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail.dart';

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
      // 直接访问 controller.cities 列表，让 GetX 能追踪到列表变化
      // 注意：必须在 Obx 内部直接访问 RxList，否则响应式更新不会触发
      final city = controller.cities.firstWhereOrNull((c) => c.id == cityId);

      if (city == null) {
        return const SizedBox.shrink();
      }

      log('🏙️ City: ${city.name}, imageUrl: ${city.imageUrl?.substring(0, city.imageUrl!.length > 50 ? 50 : city.imageUrl!.length) ?? "null"}...');

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _navigateToDetail(context, city),
            onLongPress: () => _handleLongPress(context, city),
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
      fit: StackFit.expand,
      children: [
        // 背景图片 - 填充整个卡片
        Positioned.fill(
          child: city.imageUrl != null && city.imageUrl!.isNotEmpty
              ? Image.network(
                  city.imageUrl!,
                  fit: BoxFit.cover,
                  key: ValueKey(city.imageUrl),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(FontAwesomeIcons.imagePortrait, size: 36, color: Colors.grey),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(FontAwesomeIcons.imagePortrait, size: 36, color: Colors.grey),
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
        // 右上角：关注按钮（纯图标）
        Positioned(
          top: 6,
          right: 6,
          child: _CityFollowButton(cityId: city.id),
        ),
        // 左上角：评分徽章 + 版主图标
        Positioned(
          top: 6,
          left: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildScoreBadge(city.overallScore ?? 0.0),
              const SizedBox(width: 4),
              _buildModeratorBadge(city.hasModerator),
            ],
          ),
        ),
        // 底部信息面板
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildHeroInfoPanel(city),
        ),
        // 管理员/版主蒙层提示
        _buildAdminOverlay(city),
        // 图片生成中蒙层
        _buildGeneratingOverlay(city),
      ],
    );
  }

  /// 评分徽章 - 左上角，与底部指标同款样式
  Widget _buildScoreBadge(double score) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4458).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FontAwesomeIcons.solidStar, size: 9, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 版主徽章 - 左上角评分旁，与评分同款样式
  Widget _buildModeratorBadge(bool hasModerator) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: (hasModerator ? const Color(0xFF4ADE80) : Colors.grey)
            .withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Icon(
        hasModerator
            ? FontAwesomeIcons.userShield
            : FontAwesomeIcons.userSlash,
        size: 10,
        color: Colors.white,
      ),
    );
  }

  /// 底部信息面板 - 一目了然的紧凑布局
  Widget _buildHeroInfoPanel(City city) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 城市名称
          Text(
            city.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (city.country != null && city.country!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.locationDot,
                  size: 9,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    city.country!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 5),
          // 指标 Wrap：始终显示全部图标+默认值，异步加载后自动更新
          Wrap(
            spacing: 4,
            runSpacing: 3,
            children: [
              // 月均花费
              _MetricChip(
                icon: FontAwesomeIcons.dollarSign,
                value: city.averageCost != null && city.averageCost! > 0
                    ? '${city.averageCost!.toInt()}'
                    : '-',
              ),
              // 网络评分
              _MetricChip(
                icon: FontAwesomeIcons.wifi,
                value: city.internetScore != null && city.internetScore! > 0
                    ? city.internetScore!.toStringAsFixed(1)
                    : '-',
              ),
              // 安全评分
              _MetricChip(
                icon: FontAwesomeIcons.shield,
                value: city.safetyScore != null && city.safetyScore! > 0
                    ? city.safetyScore!.toStringAsFixed(1)
                    : '-',
              ),
              // 评论数
              _MetricChip(
                icon: FontAwesomeIcons.comments,
                value: city.reviewCount != null && city.reviewCount! > 0
                    ? '${city.reviewCount}'
                    : '0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 长按处理 - 管理员/版主可更新图片
  void _handleLongPress(BuildContext context, City city) {
    final authController = Get.find<AuthStateController>();
    final user = authController.currentUser.value;
    if (user == null) return;

    final isAdmin = user.role.toLowerCase() == 'admin';
    final isModerator = city.moderatorId != null &&
        city.moderatorId == user.id;

    if (!isAdmin && !isModerator) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(FontAwesomeIcons.image,
                size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            const Text('更新城市图片',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          '是否为「${city.name}」重新生成城市图片？',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              controller.generateCityImages(city.id, city.name);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 14),
            label: const Text('更新'),
          ),
        ],
      ),
    );
  }

  /// 管理员/版主蒙层提示 - 提示长按可更新图片
  Widget _buildAdminOverlay(City city) {
    return Obx(() {
      final authController = Get.find<AuthStateController>();
      final user = authController.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      final isAdmin = user.role.toLowerCase() == 'admin';
      final isModerator = city.moderatorId != null &&
          city.moderatorId == user.id;

      if (!isAdmin && !isModerator) return const SizedBox.shrink();

      // 正在生成时不显示提示
      if (controller.generatingImageCityIds.contains(city.id)) {
        return const SizedBox.shrink();
      }

      return Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.fingerprint,
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '长按更新图片',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 图片生成中蒙层
  Widget _buildGeneratingOverlay(City city) {
    return Obx(() {
      if (!controller.generatingImageCityIds.contains(city.id)) {
        return const SizedBox.shrink();
      }

      return Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '图片生成中...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
            ),
          ),
          ),
        ),
      );
    });
  }
}

/// 统一指标 Chip - 图标 + 数值，大小和样式一致
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetricChip({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 9,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 关注按钮 - 与评分/版主徽章统一的药丸样式
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
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: isFollowed
                ? const Color(0xFFEF4444).withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Icon(
            isFollowed ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
            size: 10,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}


