import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 通用加载对话框
///
/// 使用方法:
/// ```dart
/// // 显示加载对话框（带文字）
/// AppLoadingDialog.show(
///   title: '正在加载...',
///   subtitle: '请稍候',
/// );
///
/// // 显示简单加载对话框（仅指示器）
/// AppLoadingDialog.showSimple();
///
/// // 关闭加载对话框
/// AppLoadingDialog.hide();
/// ```
class AppLoadingDialog {
  static bool _isShowing = false;

  /// 显示加载对话框（带标题和副标题）
  ///
  /// [title] 主标题，例如 "正在加载..."
  /// [subtitle] 副标题，例如 "请稍候"
  /// [barrierDismissible] 是否可以点击背景关闭，默认 false
  /// [indicatorColor] 进度指示器颜色，默认使用 AppColors.cityPrimary
  static void show({
    required String title,
    String? subtitle,
    bool barrierDismissible = false,
    Color? indicatorColor,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: barrierDismissible,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20.r,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: indicatorColor ?? AppColors.cityPrimary,
                  strokeWidth: 3.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
    );
  }

  /// 显示简单加载对话框（仅进度指示器，无文字）
  ///
  /// [barrierDismissible] 是否可以点击背景关闭，默认 false
  /// [indicatorColor] 进度指示器颜色，默认使用 AppColors.cityPrimary
  static void showSimple({
    bool barrierDismissible = false,
    Color? indicatorColor,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: barrierDismissible,
        child: Center(
          child: CircularProgressIndicator(
            color: indicatorColor ?? AppColors.cityPrimary,
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// 关闭加载对话框
  static void hide() {
    if (_isShowing && Get.isDialogOpen == true) {
      Get.back();
      _isShowing = false;
    }
  }

  /// 检查对话框是否正在显示
  static bool get isShowing => _isShowing;
}
