import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/services/app_config_service.dart';

/// 位置权限请求对话框
class LocationPermissionDialog extends StatefulWidget {
  const LocationPermissionDialog({super.key});

  @override
  State<LocationPermissionDialog> createState() => _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  static const _defaultTitle = '需要位置权限';
  static const _defaultDescription = '我们需要访问您的位置信息,以便为您推荐附近的城市和提供基于位置的服务';
  static const _defaultCancelButton = '取消';
  static const _defaultConfirmButton = '授予权限';

  late final Future<LocationPermissionUiCopy> _copyFuture;

  @override
  void initState() {
    super.initState();
    _copyFuture = AppConfigService().getLocationPermissionUiCopy();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return FutureBuilder<LocationPermissionUiCopy>(
      future: _copyFuture,
      builder: (context, snapshot) {
        final copy = snapshot.data;
        final title = copy?.dialogTitle ?? _defaultTitle;
        final description = copy?.dialogDescription ?? _defaultDescription;
        final cancelButton = copy?.dialogCancelButton ?? _defaultCancelButton;
        final confirmButton = copy?.dialogConfirmButton ?? _defaultConfirmButton;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.locationDot,
                    size: 40.r,
                    color: const Color(0xFFFF4458),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          cancelButton,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await controller.getCurrentLocation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4458),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          confirmButton,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 位置信息显示组件
class LocationInfoWidget extends StatefulWidget {
  const LocationInfoWidget({super.key});

  @override
  State<LocationInfoWidget> createState() => _LocationInfoWidgetState();
}

class _LocationInfoWidgetState extends State<LocationInfoWidget> {
  static const _defaultLoadingText = '正在获取位置...';
  static const _defaultDisabledText = '位置未启用';
  static const _defaultEnableActionText = '启用';

  late final Future<LocationPermissionUiCopy> _copyFuture;

  @override
  void initState() {
    super.initState();
    _copyFuture = AppConfigService().getLocationPermissionUiCopy();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return FutureBuilder<LocationPermissionUiCopy>(
      future: _copyFuture,
      builder: (context, snapshot) {
        final copy = snapshot.data;
        final loadingText = copy?.statusLoading ?? _defaultLoadingText;
        final disabledText = copy?.statusDisabled ?? _defaultDisabledText;
        final enableActionText = copy?.statusEnableAction ?? _defaultEnableActionText;

        return Obx(() {
          if (controller.isLoading.value) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    loadingText,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!controller.hasPermission.value || controller.currentPosition.value == null) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.locationDot,
                    color: const Color(0xFFFF4458),
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      disabledText,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.getCurrentLocation(),
                    child: Text(
                      enableActionText,
                      style: const TextStyle(color: Color(0xFFFF4458)),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    FontAwesomeIcons.locationDot,
                    color: const Color(0xFFFF4458),
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentCity.value,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        controller.currentCountry.value,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.arrowsRotate, size: 20.r),
                  color: AppColors.textSecondary,
                  onPressed: () => controller.refreshLocation(),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
