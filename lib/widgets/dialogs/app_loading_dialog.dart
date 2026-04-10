import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';
import 'package:go_nomads_app/widgets/double_spin_loader.dart';

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

    Get.bottomSheet(
      PopScope(
        canPop: barrierDismissible,
        child: AppBottomDrawer(
          title: title,
          subtitle: subtitle,
          maxHeightFactor: 0.38,
          showHandle: barrierDismissible,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: DoubleSpinLoader(
                size: 42.w,
                color1: indicatorColor ?? AppColors.cityPrimary,
                color2: const Color(0xFF4ECDC4),
                trackColor: AppColors.borderLight,
              ),
            ),
          ),
        ),
      ),
      isDismissible: barrierDismissible,
      enableDrag: barrierDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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

    Get.bottomSheet(
      PopScope(
        canPop: barrierDismissible,
        child: AppBottomDrawer(
          maxHeightFactor: 0.26,
          showHandle: barrierDismissible,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: DoubleSpinLoader(
                size: 44.w,
                color1: indicatorColor ?? AppColors.cityPrimary,
                color2: const Color(0xFF4ECDC4),
                trackColor: AppColors.borderLight,
              ),
            ),
          ),
        ),
      ),
      isDismissible: barrierDismissible,
      enableDrag: barrierDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// 关闭加载对话框
  static void hide() {
    if (!_isShowing) {
      return;
    }

    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
    }

    _isShowing = false;
  }

  /// 检查对话框是否正在显示
  static bool get isShowing => _isShowing;
}
