import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/city_detail_page.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景图片
            _buildBackgroundImage(),
            // 内容层
            _buildContent(isMobile),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(city.displayImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
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
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Stack(
      children: [
        // 顶部信息
        _buildTopRow(isMobile),
        // 底部城市信息
        _buildBottomInfo(isMobile),
      ],
    );
  }

  Widget _buildTopRow(bool isMobile) {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 版主状态徽章
          _buildModeratorBadge(isMobile),
          const SizedBox(width: 3),
          // 右侧按钮组
          _buildTopRightButtons(isMobile),
        ],
      ),
    );
  }

  Widget _buildModeratorBadge(bool isMobile) {
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
          borderRadius: BorderRadius.circular(4),
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
            Text(
              city.moderatorId != null ? '已指定版主' : '待指定版主',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 8 : 10,
                fontWeight: FontWeight.w600,
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
        // 刷新图片按钮（仅管理员可见）
        Obx(() {
          final authController = Get.find<AuthStateController>();
          final user = authController.currentUser.value;
          final isAdmin = user?.role.toLowerCase() == 'admin';
          if (!isAdmin) return const SizedBox.shrink();

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
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📡', style: TextStyle(fontSize: isMobile ? 7 : 10)),
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

  Widget _buildBottomInfo(bool isMobile) {
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
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
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
                  '综合得分',
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
        borderRadius: BorderRadius.circular(4),
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

  Future<void> _generateImages() async {
    final cityController = Get.find<CityStateController>();

    if (cityController.isGeneratingImages(cityId)) return;

    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning('Please login to generate images', title: 'Login Required');
      Get.toNamed(AppRoutes.login);
      return;
    }

    final user = authController.currentUser.value;
    if (user?.role.toLowerCase() != 'admin') {
      AppToast.warning('Only administrators can generate images', title: 'Permission Denied');
      return;
    }

    AppToast.info(
      'AI image generation task created for $cityName.\nYou will be notified when complete.',
      title: 'Task Created',
    );

    final result = await cityController.generateCityImages(cityId);

    result.fold(
      onSuccess: (data) {
        final taskData = data['data'] as Map<String, dynamic>?;
        final taskId = taskData?['taskId'] as String? ?? '';
        log('🖼️ Image generation task created: taskId=$taskId');
      },
      onFailure: (exception) {
        AppToast.error(exception.message, title: 'Task Creation Failed');
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
            borderRadius: BorderRadius.circular(4),
          ),
          child: isGenerating
              ? SizedBox(
                  width: isMobile ? 12 : 16,
                  height: isMobile ? 12 : 16,
                  child: const CircularProgressIndicator(
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
