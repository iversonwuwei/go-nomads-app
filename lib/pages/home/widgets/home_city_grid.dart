import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/pages/home/widgets/home_city_card.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 城市网格组件
class HomeCityGrid extends GetView<HomePageController> {
  final bool isMobile;

  const HomeCityGrid({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isLoading = controller.isLoadingCities;
      final cities = controller.localCities;

      // 加载中状态 - 使用 shimmer 骨架屏
      if (isLoading) {
        return _buildLoadingState(l10n, isMobile);
      }

      // 空状态
      if (cities.isEmpty) {
        return HomeCityEmptyState(
          isMobile: isMobile,
          isSearching: controller.searchController.text.trim().isNotEmpty,
          onClearSearch: controller.clearSearch,
        );
      }

      // 城市网格
      return _buildCityGrid(l10n);
    });
  }

  Widget _buildLoadingState(AppLocalizations l10n, bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;

    // 城市网格骨架屏
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 0.68 : 0.72,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.w,
      ),
      itemCount: isMobile ? 4 : 8,
      itemBuilder: (context, index) {
        return _buildSkeletonCityCard(isMobile);
      },
    );
  }

  Widget _buildSkeletonCityCard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              ),
            ),
          ),
          // 内容区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 城市名称
                  Container(
                    height: 16.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  // 国家
                  Container(
                    height: 12.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  // 标签行
                  Row(
                    children: [
                      Container(
                        height: 10.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        height: 10.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityGrid(AppLocalizations l10n) {
    final displayCities = controller.displayCities;
    final hasMore = controller.hasMoreCities;
    final crossAxisCount = isMobile ? 2 : 4;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 0.68 : 0.72,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.w,
          ),
          itemCount: displayCities.length,
          itemBuilder: (context, index) {
            return HomeCityCard(
              city: displayCities[index],
              onReturnFromDetail: controller.clearSearchOnReturn,
            );
          },
        ),
        if (hasMore) ...[
          SizedBox(height: 24.h),
          _buildViewAllButton(l10n),
        ],
      ],
    );
  }

  Widget _buildViewAllButton(AppLocalizations l10n) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => controller.checkLoginAndNavigate(
          () => Get.toNamed(AppRoutes.cityList),
        ),
        icon: Icon(
          FontAwesomeIcons.city,
          size: 20.r,
          color: Color(0xFFFF4458),
        ),
        label: Text(
          l10n.viewAllCities,
          style: TextStyle(
            color: Color(0xFFFF4458),
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          side: BorderSide(color: Color(0xFFFF4458), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}

/// 城市空状态组件
class HomeCityEmptyState extends StatelessWidget {
  final bool isMobile;
  final bool isSearching;
  final VoidCallback onClearSearch;

  const HomeCityEmptyState({
    super.key,
    required this.isMobile,
    required this.isSearching,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: isMobile ? 100 : 120,
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? FontAwesomeIcons.magnifyingGlass : FontAwesomeIcons.city,
              size: isMobile ? 50 : 60,
              color: const Color(0xFFFF4458),
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          // 标题
          Text(
            isSearching ? l10n.noCitiesFound : l10n.noCitiesYet,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          // 描述
          Text(
            isSearching ? l10n.tryDifferentKeyword : l10n.startExploringCities,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 40),
          // 按钮
          if (isSearching)
            ElevatedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(FontAwesomeIcons.xmark),
              label: Text(l10n.dataServiceClearSearch),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.cityList),
              icon: Icon(FontAwesomeIcons.circlePlus, size: 20.r),
              label: Text(
                l10n.browseCities,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 14 : 16,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
