import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/share_button.dart';

/// 城市详情页 SliverAppBar，支持顶部图片左右滑动
class CityDetailAppBar extends StatefulWidget {
  final CityDetailController controller;
  final String cityName;
  final List<String> cityImages;
  final double overallScore; // 初始值，后续从 CityDetailStateController 获取
  final int reviewCount; // 初始值，后续从 CityDetailStateController 获取
  final VoidCallback onShare;

  const CityDetailAppBar({
    super.key,
    required this.controller,
    required this.cityName,
    required this.cityImages,
    required this.overallScore,
    required this.reviewCount,
    required this.onShare,
  });

  @override
  State<CityDetailAppBar> createState() => _CityDetailAppBarState();
}

class _CityDetailAppBarState extends State<CityDetailAppBar> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityController = Get.find<CityDetailStateController>();

    return Obx(() {
      final opacity = widget.controller.appBarOpacity.value;
      // 显式访问 currentCity.value 以确保在城市数据变化时重建整个 AppBar
      // 这是必要的，因为 FlexibleSpaceBar.background 可能会被 Flutter 缓存
      final _ = cityController.currentCity.value;

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
          SliverShareButton(
            opacity: opacity,
            onPressed: widget.onShare,
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: EdgeInsets.only(bottom: 16.h),
          title: _buildCollapsedTitle(opacity),
          background: _buildBackgroundWithOverlay(),
        ),
      );
    });
  }

  Widget _buildCollapsedTitle(double opacity) {
    // 从 opacity 0.6 开始渐显，到 0.9 完全显示
    final titleOpacity = ((opacity - 0.6) / 0.3).clamp(0.0, 1.0);

    if (titleOpacity <= 0) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: titleOpacity,
      child: Text(
        widget.cityName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          color: AppColors.cityPrimary,
          shadows: [],
        ),
      ),
    );
  }

  Widget _buildBackgroundWithOverlay() {
    // 优先从响应式 currentCity 获取最新图片（支持 SignalR 实时更新）
    // 回退到导航时传入的静态 cityImages
    final cityController = Get.find<CityDetailStateController>();
    final currentCity = cityController.currentCity.value;
    final List<String> liveImages;
    if (currentCity != null &&
        currentCity.landscapeImageUrls != null &&
        currentCity.landscapeImageUrls!.isNotEmpty) {
      liveImages = currentCity.landscapeImageUrls!;
    } else if (currentCity != null &&
        currentCity.imageUrl != null &&
        currentCity.imageUrl!.isNotEmpty) {
      liveImages = [currentCity.imageUrl!];
    } else {
      liveImages = widget.cityImages.isNotEmpty ? widget.cityImages : const [''];
    }
    final images = liveImages;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final url = images[index];
            return SafeNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        ),
        // 渐变遮罩 - 忽略手势让触摸事件穿透到 PageView
        IgnorePointer(
          child: Container(
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
        ),
        // 底部信息面板
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 20.h,
          child: _buildHeroInfoPanel(),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 6.h,
                  width: isActive ? 18 : 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isActive ? 0.9 : 0.4),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroInfoPanel() {
    // 使用 Stack 分离背景和内容，让手势可以穿透到 PageView
    // 关注按钮单独处理，允许点击
    final cityController = Get.find<CityDetailStateController>();

    return Obx(() {
      // 从 CityDetailStateController 获取响应式数据，如果没有则使用初始值
      final city = cityController.currentCity.value;
      final displayScore = city?.displayOverallScore ?? widget.overallScore;
      final displayReviewCount = city?.displayReviewCount ?? widget.reviewCount;

      debugPrint(
          '🔄 [CityDetailAppBar] Obx 重建: score=$displayScore, reviewCount=$displayReviewCount, cityOverallScore=${city?.overallScore}, cityReviewCount=${city?.reviewCount}');

      return Stack(
        children: [
          // 背景装饰 - 忽略手势让滑动穿透
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          // 内容区域
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  child: Text(
                    widget.cityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            IgnorePointer(
                              child: _StatPill(
                                label: '评分',
                                value: displayScore.toStringAsFixed(1),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            IgnorePointer(
                              child: _StatPill(
                                label: '评论',
                                value: '$displayReviewCount',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // 关注按钮不包裹 IgnorePointer，允许点击
                    _FavoriteButton(cityId: widget.controller.cityId),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _FavoriteButton extends StatelessWidget {
  final String cityId;

  const _FavoriteButton({required this.cityId});

  @override
  Widget build(BuildContext context) {
    final cityController = Get.find<CityDetailStateController>();

    return Obx(() {
      final isFavorited = cityController.isFavorited.value;
      final isToggling = cityController.isTogglingFavorite.value;

      return Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: isToggling
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Center(
                  child: SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? AppColors.cityPrimary : Colors.white,
                  size: 22.r,
                ),
                tooltip: isFavorited ? '已关注' : '关注',
                onPressed: () => cityController.toggleFavorite(),
              ),
      );
    });
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
