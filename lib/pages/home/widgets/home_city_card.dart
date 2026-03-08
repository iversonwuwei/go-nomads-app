import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 城市卡片组件（网格视图）
class HomeCityCard extends StatelessWidget {
  final City city;
  final VoidCallback? onReturnFromDetail;

  const HomeCityCard({
    super.key,
    required this.city,
    this.onReturnFromDetail,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, l10n),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景图片
            _buildBackgroundImage(),
            // 内容层
            _buildContent(isMobile, l10n: l10n),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, AppLocalizations l10n) {
    log('🏙️ City card tapped: ${city.name}');

    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning(
        l10n.pleaseLoginToCreateMeetup,
        title: l10n.loginRequired,
      );
      Get.toNamed(AppRoutes.login);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPage(
          cityId: city.id,
          cityName: city.name,
          cityImages: city.landscapeImageUrls ?? [],
          cityImage: city.imageUrl?.toString() ?? '',
          overallScore: (city.overallScore as num?)?.toDouble() ?? 0.0,
          reviewCount: (city.reviewCount as num?)?.toInt() ?? 0,
        ),
      ),
    ).then((_) {
      log('🔙 从 CityDetailPage 返回');
      onReturnFromDetail?.call();
    });
  }

  Widget _buildBackgroundImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: city.displayImageUrl,
            fit: BoxFit.cover,
            // 限制缓存尺寸，避免解码原始大图
            memCacheWidth: 900,
            memCacheHeight: 900,
            placeholder: (_, __) => Container(color: Colors.grey[200]),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: const Icon(FontAwesomeIcons.image, color: Colors.white70),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile, {required AppLocalizations l10n}) {
    return Stack(
      children: [
        // 顶部信息
        _buildTopRow(isMobile),
        // 底部城市信息
        _buildBottomInfo(isMobile, l10n: l10n),
      ],
    );
  }

  Widget _buildTopRow(bool isMobile) {
    return Positioned(
      top: 8.h,
      left: 8.w,
      right: 8.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 版主状态徽章
          _buildModeratorBadge(isMobile),
          SizedBox(width: 3.w),
          // 右侧按钮组
          _buildTopRightButtons(isMobile),
        ],
      ),
    );
  }

  Widget _buildModeratorBadge(bool isMobile) {
    final l10n = AppLocalizations.of(Get.context!)!;
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 6,
          vertical: isMobile ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: city.moderatorId != null
              ? const Color(0xFF10B981).withValues(alpha: 0.9)
              : Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              city.moderatorId != null ? FontAwesomeIcons.userCheck : FontAwesomeIcons.userXmark,
              color: Colors.white,
              size: isMobile ? 8 : 10,
            ),
            SizedBox(width: isMobile ? 2 : 4),
            Flexible(
              child: Text(
                city.moderatorId != null ? l10n.moderatorAssigned : l10n.moderatorPending,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 8 : 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRightButtons(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 刷新图片按钮（管理员或城市版主可见）
        Obx(() {
          final authController = Get.find<AuthStateController>();
          final user = authController.currentUser.value;
          final isAdmin = user?.role.toLowerCase() == 'admin';
          final isCityModerator =
              city.isCurrentUserModerator || (city.moderatorId != null && city.moderatorId == user?.id);
          if (!isAdmin && !isCityModerator) return const SizedBox.shrink();

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GenerateImageButton(
                cityId: city.id,
                cityName: city.name,
                isMobile: isMobile,
              ),
              SizedBox(width: isMobile ? 3 : 6),
            ],
          );
        }),
        // 网络评分
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 3 : 6,
            vertical: isMobile ? 2 : 3,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.wifi,
                color: Colors.white,
                size: isMobile ? 7 : 10,
              ),
              SizedBox(width: isMobile ? 1 : 3),
              Text(
                city.displayInternetScore.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 7 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(bool isMobile, {required AppLocalizations l10n}) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 城市名
            Text(
              city.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 2 : 4),
            // 国家
            Text(
              city.displayCountry,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isMobile ? 12 : 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 4 : 8),
            // 综合得分
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.star,
                  color: const Color(0xFFFBBF24),
                  size: isMobile ? 16 : 18,
                ),
                SizedBox(width: isMobile ? 3 : 4),
                Text(
                  city.displayOverallScore.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: isMobile ? 3 : 4),
                Text(
                  l10n.overallScore,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 4 : 8),
            // 数字游民核心指标 - Coworking & Meetup 数量
            Row(
              children: [
                // Coworking 数量
                _buildStatChip(
                  icon: FontAwesomeIcons.laptop,
                  value: '${city.coworkingCount ?? 0}',
                  color: Colors.blue,
                  isMobile: isMobile,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                // Meetup 数量
                _buildStatChip(
                  icon: FontAwesomeIcons.userGroup,
                  value: '${city.meetupCount ?? 0}',
                  color: Colors.purple,
                  isMobile: isMobile,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                // 月均花费
                if (city.averageCost != null && city.averageCost! > 0) ...[
                  _buildStatChip(
                    icon: FontAwesomeIcons.dollarSign,
                    value: '\$${city.averageCost!.toInt()}',
                    color: Colors.green,
                    isMobile: isMobile,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计小标签
  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 6,
        vertical: isMobile ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isMobile ? 10 : 12),
          SizedBox(width: isMobile ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 生成城市图片按钮组件
class _GenerateImageButton extends StatelessWidget {
  final String cityId;
  final String cityName;
  final bool isMobile;

  const _GenerateImageButton({
    required this.cityId,
    required this.cityName,
    required this.isMobile,
  });

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  Future<void> _generateImages() async {
    final cityController = Get.find<CityStateController>();

    if (cityController.isGeneratingImages(cityId)) return;

    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning(_l10n.pleaseLogin, title: _l10n.loginRequired);
      Get.toNamed(AppRoutes.login);
      return;
    }

    final user = authController.currentUser.value;
    final isAdmin = user?.role.toLowerCase() == 'admin';

    // 检查是否为该城市的版主
    bool isCityModerator = false;
    try {
      final city = cityController.cities.firstWhereOrNull((c) => c.id == cityId) ??
          cityController.recommendedCities.firstWhereOrNull((c) => c.id == cityId) ??
          cityController.popularCities.firstWhereOrNull((c) => c.id == cityId);
      if (city != null) {
        isCityModerator = city.isCurrentUserModerator || (city.moderatorId != null && city.moderatorId == user?.id);
      }
    } catch (_) {}

    if (!isAdmin && !isCityModerator) {
      AppToast.warning(_l10n.dataServicePermissionDenied, title: _l10n.dataServicePermissionDenied);
      return;
    }

    AppToast.info(
      _l10n.dataServiceImageTaskCreated(cityName),
      title: _l10n.dataServiceTaskCreated,
    );

    final result = await cityController.generateCityImages(cityId);

    result.fold(
      onSuccess: (data) {
        final taskData = data['data'] as Map<String, dynamic>?;
        final taskId = taskData?['taskId'] as String? ?? '';
        log('🖼️ Image generation task created: taskId=$taskId');
      },
      onFailure: (exception) {
        AppToast.error(exception.message, title: _l10n.dataServiceTaskCreationFailed);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityController = Get.find<CityStateController>();

    return Obx(() {
      final isGenerating = cityController.isGeneratingImages(cityId);

      return GestureDetector(
        onTap: isGenerating ? null : _generateImages,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 4 : 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: isGenerating
              ? SizedBox(
                  width: isMobile ? 12 : 16,
                  height: isMobile ? 12 : 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  FontAwesomeIcons.arrowsRotate,
                  color: Colors.white,
                  size: isMobile ? 10 : 14,
                ),
        ),
      );
    });
  }
}
