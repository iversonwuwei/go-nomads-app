import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/pages/city_detail/city_detail_controller.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:df_admin_mobile/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 城市详情页 SliverAppBar
class CityDetailAppBar extends StatelessWidget {
  final CityDetailController controller;
  final String cityName;
  final String cityImage;
  final double overallScore;
  final int reviewCount;
  final VoidCallback onShare;
  final Widget? actionButton;

  const CityDetailAppBar({
    super.key,
    required this.controller,
    required this.cityName,
    required this.cityImage,
    required this.overallScore,
    required this.reviewCount,
    required this.onShare,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final opacity = controller.appBarOpacity.value;

      return SliverAppBar(
        expandedHeight: 350,
        floating: false,
        pinned: true,
        elevation: opacity > 0 ? 4 : 0,
        backgroundColor: Color.lerp(
          Colors.transparent,
          Colors.white,
          opacity,
        ),
        leading: SliverBackButton(opacity: opacity),
        actions: [
          if (actionButton != null) actionButton!,
          const SizedBox(width: 4),
          SliverShareButton(
            opacity: opacity,
            onPressed: onShare,
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: const EdgeInsets.only(bottom: 16),
          title: _buildTitle(opacity),
          background: _buildBackground(),
        ),
      );
    });
  }

  Widget _buildTitle(double opacity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: opacity > 0.5
            ? null
            : LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
        color: opacity > 0.5 ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        cityName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: opacity > 0.5 ? AppColors.cityPrimary : Colors.white,
          shadows: opacity > 0.5
              ? []
              : const [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black54,
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景图片
        SafeNetworkImage(
          imageUrl: cityImage,
          fit: BoxFit.cover,
          placeholder: Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        // 渐变遮罩
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// AppBar 操作按钮
class SliverActionButton extends StatelessWidget {
  final IconData icon;
  final double opacity;
  final VoidCallback? onPressed;
  final String? tooltip;

  const SliverActionButton({
    super.key,
    required this.icon,
    required this.opacity,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: opacity > 0.5 ? AppColors.cityPrimary : Colors.white,
        size: 20,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
