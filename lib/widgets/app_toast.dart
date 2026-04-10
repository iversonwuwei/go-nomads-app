import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';

/// Toast 类型
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// 现代化 Toast 组件
/// 用于替换 Get.snackbar,提供更好的用户体验
class AppToast {
  /// 显示成功 Toast
  static void success(String message, {String? title}) {
    _showToast(
      title: title ?? 'Success',
      message: message,
      type: ToastType.success,
    );
  }

  /// 显示错误 Toast
  static void error(String message, {String? title}) {
    _showToast(
      title: title ?? 'Error',
      message: message,
      type: ToastType.error,
    );
  }

  /// 显示警告 Toast
  static void warning(String message, {String? title}) {
    _showToast(
      title: title ?? 'Warning',
      message: message,
      type: ToastType.warning,
    );
  }

  /// 显示信息 Toast
  static void info(String message, {String? title}) {
    _showToast(
      title: title ?? 'Info',
      message: message,
      type: ToastType.info,
    );
  }

  /// 自定义 Toast
  static void custom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    final config = _ToastConfig(
      backgroundColor: backgroundColor ?? Colors.black87,
      textColor: textColor ?? Colors.white,
      icon: icon ?? AppIcons.info,
      indicatorColor: (backgroundColor ?? Colors.black87).withValues(alpha: 0.8),
      shadowColor: (backgroundColor ?? Colors.black87).withValues(alpha: 0.3),
    );

    _showToastContent(
      title: title,
      message: message,
      config: config,
      duration: duration,
    );
  }

  /// 内部方法：显示 Toast
  static void _showToast({
    required String title,
    required String message,
    required ToastType type,
    Duration? duration,
  }) {
    final config = _getToastConfig(type);
    _showToastContent(
      title: title,
      message: message,
      config: config,
      duration: duration,
    );
  }

  static void _showToastContent({
    required String title,
    required String message,
    required _ToastConfig config,
    Duration? duration,
  }) {
    final effectiveDuration = duration ?? const Duration(seconds: 3);
    final content = _buildToastContent(title, message, config);

    // 使用 addPostFrameCallback 确保在当前帧结束后显示 Toast
    // 这样可以避免在 widget 重建/销毁过程中访问 context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tryShowRawSnackbar(content, config, effectiveDuration)) {
        return;
      }
      _showFallbackSnackBar(content, config, effectiveDuration);
    });
  }

  static bool _tryShowRawSnackbar(
    Widget content,
    _ToastConfig config,
    Duration duration,
  ) {
    final overlayContext = Get.overlayContext ?? Get.key.currentContext ?? Get.context;
    if (overlayContext == null) {
      return false;
    }

    final overlay = Overlay.maybeOf(overlayContext, rootOverlay: true);
    if (overlay == null) {
      return false;
    }

    try {
      Get.rawSnackbar(
        backgroundColor: config.backgroundColor,
        messageText: content,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        snackPosition: SnackPosition.TOP,
        duration: duration,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
        animationDuration: const Duration(milliseconds: 500),
        boxShadows: [
          BoxShadow(
            color: config.shadowColor,
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      );
      return true;
    } catch (error) {
      debugPrint('AppToast: Get.rawSnackbar failed – $error');
      return false;
    }
  }

  static void _showFallbackSnackBar(
    Widget content,
    _ToastConfig config,
    Duration duration,
  ) {
    final context = Get.context ?? Get.key.currentContext;
    if (context == null) {
      debugPrint('AppToast: No context available for fallback toast.');
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('AppToast: No ScaffoldMessenger available for fallback toast.');
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: duration,
        content: DefaultTextStyle.merge(
          style: TextStyle(color: config.textColor),
          child: content,
        ),
      ),
    );
  }

  /// 构建 Toast 内容（居中对称设计）
  static Widget _buildToastContent(String title, String message, _ToastConfig config) {
    // 使用支持中文的字体族，优先使用系统默认字体
    String? fontFamily; // 使用系统默认字体以支持中文

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图标
        Icon(
          config.icon,
          color: config.textColor,
          size: 32.r,
        ),
        SizedBox(height: 8.h),
        // 标题
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: config.textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            fontFamilyFallback: const ['PingFang SC', 'Heiti SC', 'Microsoft YaHei', 'sans-serif'],
          ),
        ),
        SizedBox(height: 4.h),
        // 消息
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: config.textColor.withValues(alpha: 0.95),
            fontSize: 14.sp,
            height: 1.4,
            fontFamily: fontFamily,
            fontFamilyFallback: const ['PingFang SC', 'Heiti SC', 'Microsoft YaHei', 'sans-serif'],
          ),
        ),
      ],
    );
  }

  /// 获取 Toast 配置
  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          backgroundColor: AppColors.feedbackSuccess,
          textColor: Colors.white,
          icon: AppIcons.success,
          indicatorColor: AppColors.feedbackSuccessDark,
          shadowColor: AppColors.feedbackSuccess.withValues(alpha: 0.3),
        );
      case ToastType.error:
        return _ToastConfig(
          backgroundColor: AppColors.feedbackError,
          textColor: Colors.white,
          icon: AppIcons.error,
          indicatorColor: AppColors.feedbackErrorDark,
          shadowColor: AppColors.feedbackError.withValues(alpha: 0.3),
        );
      case ToastType.warning:
        return _ToastConfig(
          backgroundColor: AppColors.feedbackWarning,
          textColor: Colors.white,
          icon: AppIcons.warning,
          indicatorColor: AppColors.feedbackWarningDark,
          shadowColor: AppColors.feedbackWarning.withValues(alpha: 0.3),
        );
      case ToastType.info:
        return _ToastConfig(
          backgroundColor: AppColors.feedbackInfo,
          textColor: Colors.white,
          icon: AppIcons.info,
          indicatorColor: AppColors.feedbackInfoDark,
          shadowColor: AppColors.feedbackInfo.withValues(alpha: 0.3),
        );
    }
  }
}

/// Toast 配置类
class _ToastConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color indicatorColor;
  final Color shadowColor;

  _ToastConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.indicatorColor,
    required this.shadowColor,
  });
}
