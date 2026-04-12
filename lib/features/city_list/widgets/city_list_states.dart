import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// 城市列表错误状态组件
class CityListErrorState extends GetView<CityListController> {
  const CityListErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Container(
          padding: EdgeInsets.all(28.w),
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
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.cityPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(
                  FontAwesomeIcons.circleExclamation,
                  size: 34.r,
                  color: AppColors.cityPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.loadFailed,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
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
                icon: Icon(FontAwesomeIcons.arrowsRotate, size: 16.r),
                label: Text(l10n.retry),
              ),
            ],
          ),
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
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppUiTokens.softFloatingShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.cityPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 34.r,
                  color: AppColors.cityPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.noCitiesFound,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
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
                icon: Icon(FontAwesomeIcons.arrowsRotate, size: 16.r),
                label: Text(l10n.clearFilters),
              ),
            ],
          ),
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
              const AppLoadingWidget(fullScreen: false),
              SizedBox(height: 8.h),
              Text(
                '加载更多城市...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
