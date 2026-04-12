import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';

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

      final previewImageUrl = city.displayImageUrl;
      log('🏙️ City: ${city.name}, imageUrl: ${previewImageUrl.substring(0, previewImageUrl.length > 50 ? 50 : previewImageUrl.length)}...');

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: AppUiTokens.softFloatingShadow,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
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
          cityImage: city.displayImageUrl,
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
        Positioned.fill(
          child: SafeNetworkImage(
            imageUrl: city.displayImageUrl,
            fit: BoxFit.cover,
            key: ValueKey(city.displayImageUrl),
            errorWidget: Container(
              color: AppColors.surfaceMuted,
              child: Center(
                child: Icon(FontAwesomeIcons.imagePortrait, size: 36.r, color: AppColors.iconSecondary),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: _CityFollowButton(cityId: city.id),
        ),
        Positioned(
          top: 6.h,
          left: 6.w,
          child: _buildScoreBadge(city.overallScore ?? 0.0),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildHeroInfoPanel(city),
        ),
        _buildAdminOverlay(city),
        _buildGeneratingOverlay(city),
      ],
    );
  }

  /// 评分徽章 - 左上角，与底部指标同款样式
  Widget _buildScoreBadge(double score) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FontAwesomeIcons.solidStar, size: 9.r, color: const Color(0xFFFBBF24)),
          SizedBox(width: 3.w),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 底部信息面板 - 一目了然的紧凑布局
  Widget _buildHeroInfoPanel(City city) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 16.h, 10.w, 10.h),
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
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (city.country != null && city.country!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.locationDot,
                  size: 9.r,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    city.country!,
                    style: TextStyle(
                      fontSize: 11.sp,
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
          SizedBox(height: 5.h),
          // 指标 Wrap：始终显示全部图标+默认值，异步加载后自动更新
          Wrap(
            spacing: 4.w,
            runSpacing: 3.w,
            children: [
              // 月均花费
              _MetricChip(
                icon: FontAwesomeIcons.dollarSign,
                value: city.averageCost != null && city.averageCost! > 0 ? '${city.averageCost!.toInt()}' : '-',
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
                value: city.safetyScore != null && city.safetyScore! > 0 ? city.safetyScore!.toStringAsFixed(1) : '-',
              ),
              // 评论数
              _MetricChip(
                icon: FontAwesomeIcons.comments,
                value: city.reviewCount != null && city.reviewCount! > 0 ? '${city.reviewCount}' : '0',
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
    final isModerator = city.moderatorId != null && city.moderatorId == user.id;

    if (!isAdmin && !isModerator) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(FontAwesomeIcons.image, size: 18.r, color: Theme.of(context).primaryColor),
            SizedBox(width: 10.w),
            Text('更新城市图片', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          '是否为「${city.name}」重新生成城市图片？',
          style: TextStyle(fontSize: 14.sp),
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
            icon: Icon(FontAwesomeIcons.arrowsRotate, size: 14.r),
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
      final isModerator = city.moderatorId != null && city.moderatorId == user.id;

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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.fingerprint,
                      size: 10.r,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '长按更新图片',
                      style: TextStyle(
                        fontSize: 10.sp,
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
                  SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '图片生成中...',
                    style: TextStyle(
                      fontSize: 11.sp,
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
      height: 20.h,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
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
            size: 9.r,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          SizedBox(width: 3.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
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
          height: 20.h,
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: isFollowed ? const Color(0xFFEF4444).withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Icon(
            isFollowed ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
            size: 10.r,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}
