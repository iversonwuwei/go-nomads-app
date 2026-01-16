import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city_list/city_list_controller.dart';
import 'package:df_admin_mobile/pages/city_detail/city_detail.dart';
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _navigateToDetail(context, city),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 城市图片
              _buildImageSection(city),
              // 城市信息
              _buildInfoSection(city),
            ],
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
          cityImage: city.imageUrl ?? 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
          overallScore: city.overallScore ?? 0.0,
          reviewCount: city.reviewCount ?? 0,
        ),
      ),
    );
  }

  Widget _buildImageSection(City city) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: city.imageUrl != null && city.imageUrl!.isNotEmpty
                ? Image.network(
                    city.imageUrl!,
                    fit: BoxFit.cover,
                    // 添加 key 确保图片 URL 变化时重新加载
                    key: ValueKey(city.imageUrl),
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(FontAwesomeIcons.imagePortrait, size: 48),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(FontAwesomeIcons.imagePortrait, size: 48),
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
      ],
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

  Widget _buildInfoSection(City city) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 城市名和国家
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.locationDot,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          city.country ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 评分
              _buildScoreBadge(city),
            ],
          ),
          const SizedBox(height: 12),
          // 指标标签
          _buildInfoChips(city),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(City city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4458).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            FontAwesomeIcons.star,
            size: 16,
            color: Color(0xFFFF4458),
          ),
          const SizedBox(width: 4),
          Text(
            (city.overallScore ?? 0.0).toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF4458),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips(City city) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 💰 月均花费
          _InfoChip(
            icon: FontAwesomeIcons.dollarSign,
            label: city.averageCost != null && city.averageCost! > 0 ? '\$${city.averageCost!.toInt()}/mo' : '\$0/mo',
            color: city.averageCost != null && city.averageCost! > 0 ? Colors.green : Colors.grey,
          ),
          // 📶 网络评分
          if (city.internetScore != null && city.internetScore! > 0) ...[
            const SizedBox(width: 8),
            _InfoChip(
              icon: FontAwesomeIcons.wifi,
              label: city.internetScore!.toStringAsFixed(1),
              color: _getScoreColor(city.internetScore!),
            ),
          ],
          // 🛡️ 安全评分
          if (city.safetyScore != null && city.safetyScore! > 0) ...[
            const SizedBox(width: 8),
            _InfoChip(
              icon: FontAwesomeIcons.shield,
              label: city.safetyScore!.toStringAsFixed(1),
              color: _getScoreColor(city.safetyScore!),
            ),
          ],
          // 👥 社区活跃度
          if (city.communityScore != null && city.communityScore! > 0) ...[
            const SizedBox(width: 8),
            _InfoChip(
              icon: FontAwesomeIcons.peopleGroup,
              label: city.communityScore!.toStringAsFixed(1),
              color: _getScoreColor(city.communityScore!),
            ),
          ],
          // 💻 Coworking 空间数量
          const SizedBox(width: 8),
          _InfoChip(
            icon: FontAwesomeIcons.laptop,
            label: '${city.coworkingCount ?? 0}',
            color: (city.coworkingCount ?? 0) > 0 ? Colors.blue : Colors.grey,
          ),
          // 🎉 Meetup 数量
          const SizedBox(width: 8),
          _InfoChip(
            icon: FontAwesomeIcons.userGroup,
            label: '${city.meetupCount ?? 0}',
            color: (city.meetupCount ?? 0) > 0 ? Colors.purple : Colors.grey,
          ),
          // 💬 评论数量
          if (city.reviewCount != null && city.reviewCount! > 0) ...[
            const SizedBox(width: 8),
            _InfoChip(
              icon: FontAwesomeIcons.comments,
              label: '${city.reviewCount}',
              color: Colors.teal,
            ),
          ],
          // 👤 版主状态
          const SizedBox(width: 8),
          _InfoChip(
            icon: city.hasModerator ? FontAwesomeIcons.userShield : FontAwesomeIcons.userSlash,
            label: city.hasModerator ? 'Mod' : 'No Mod',
            color: city.hasModerator ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }
}

/// 信息标签组件
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
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
