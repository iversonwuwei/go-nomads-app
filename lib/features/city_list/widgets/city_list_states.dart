import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 城市列表错误状态组件
class CityListErrorState extends GetView<CityListController> {
  const CityListErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.circleExclamation,
                size: 64.r,
                color: Color(0xFFFF4458),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.loadFailed,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() => Text(
                  controller.errorMessage.value?.isNotEmpty == true
                      ? controller.errorMessage.value!
                      : l10n.networkError,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => controller.loadCities(refresh: true),
              icon: Icon(FontAwesomeIcons.arrowsRotate, size: 18.r),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 城市列表空状态组件
class CityListEmptyState extends GetView<CityListController> {
  const CityListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.magnifyingGlass,
                size: 64.r,
                color: Color(0xFFFF4458),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.noCitiesFound,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.tryAdjustingFilters,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: controller.clearSearch,
              icon: Icon(FontAwesomeIcons.arrowsRotate, size: 18.r),
              label: Text(l10n.clearFilters),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 城市列表加载更多指示器组件
class CityListLoadingIndicator extends GetView<CityListController> {
  const CityListLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoadingMore.value) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '加载更多城市...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
