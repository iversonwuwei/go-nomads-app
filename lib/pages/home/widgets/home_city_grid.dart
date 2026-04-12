import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
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
        );
      }

      // 城市网格
      return _buildCityGrid(l10n);
    });
  }

  Widget _buildLoadingState(AppLocalizations l10n, bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n, loading: true),
        SizedBox(height: 16.h),
        GridView.builder(
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
        ),
      ],
    );
  }

  Widget _buildSectionHeader(AppLocalizations l10n, {bool loading = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                Container(
                  width: 130.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                )
              else
                Text(
                  l10n.citiesList,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              SizedBox(height: 4.h),
              if (loading)
                Container(
                  width: 190.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                )
              else
                Text(
                  l10n.startExploringCities,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (!loading)
          TextButton(
            onPressed: () => controller.checkLoginAndNavigate(
              () => Get.toNamed(AppRoutes.cityList),
            ),
            child: Text(l10n.seeAll),
          ),
      ],
    );
  }

  Widget _buildSkeletonCityCard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  // 国家
                  Container(
                    height: 12.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  // 标签行
                  Row(
                    children: [
                      Container(
                        height: 10.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        height: 10.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8.r),
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
        _buildSectionHeader(l10n),
        SizedBox(height: 16.h),
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
        icon: Icon(FontAwesomeIcons.city, size: 14.r),
        label: Text(l10n.viewAllCities),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

/// 城市空状态组件
class HomeCityEmptyState extends StatelessWidget {
  final bool isMobile;

  const HomeCityEmptyState({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 28,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 32,
          vertical: isMobile ? 30 : 36,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isMobile ? 72 : 82,
              height: isMobile ? 72 : 82,
              decoration: BoxDecoration(
                color: AppColors.cityPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                FontAwesomeIcons.city,
                size: isMobile ? 28 : 32,
                color: AppColors.cityPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 20 : 24),
            Text(
              l10n.noCitiesYet,
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.startExploringCities,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 28),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.cityList),
              icon: Icon(FontAwesomeIcons.circlePlus, size: 16.r),
              label: Text(l10n.browseCities),
            ),
          ],
        ),
      ),
    );
  }
}
