import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      title: title ?? '✅ Success',
      message: message,
      type: ToastType.success,
    );
  }

  /// 显示错误 Toast
  static void error(String message, {String? title}) {
    _showToast(
      title: title ?? '❌ Error',
      message: message,
      type: ToastType.error,
    );
  }

  /// 显示警告 Toast
  static void warning(String message, {String? title}) {
    _showToast(
      title: title ?? '⚠️ Warning',
      message: message,
      type: ToastType.warning,
    );
  }

  /// 显示信息 Toast
  static void info(String message, {String? title}) {
    _showToast(
      title: title ?? 'ℹ️ Info',
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
      icon: icon ?? Icons.info_rounded,
      indicatorColor:
          (backgroundColor ?? Colors.black87).withValues(alpha: 0.8),
      shadowColor: (backgroundColor ?? Colors.black87).withValues(alpha: 0.3),
    );

    Get.rawSnackbar(
      backgroundColor: config.backgroundColor,
      messageText: _buildToastContent(title, message, config),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: duration ?? const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 500),
      boxShadows: [
        BoxShadow(
          color: config.shadowColor,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
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

    Get.rawSnackbar(
      backgroundColor: config.backgroundColor,
      messageText: _buildToastContent(title, message, config),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: duration ?? const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 500),
      boxShadows: [
        BoxShadow(
          color: config.shadowColor,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// 构建 Toast 内容（居中对称设计）
  static Widget _buildToastContent(
      String title, String message, _ToastConfig config) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图标
        Icon(
          config.icon,
          color: config.textColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        // 标题
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: config.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // 消息
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: config.textColor.withValues(alpha: 0.95),
            fontSize: 14,
            height: 1.4,
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
          backgroundColor: const Color(0xFF10B981), // Green
          textColor: Colors.white,
          icon: Icons.check_circle_rounded,
          indicatorColor: const Color(0xFF059669),
          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
        );
      case ToastType.error:
        return _ToastConfig(
          backgroundColor: const Color(0xFFEF4444), // Red
          textColor: Colors.white,
          icon: Icons.error_rounded,
          indicatorColor: const Color(0xFFDC2626),
          shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
        );
      case ToastType.warning:
        return _ToastConfig(
          backgroundColor: const Color(0xFFF59E0B), // Orange
          textColor: Colors.white,
          icon: Icons.warning_rounded,
          indicatorColor: const Color(0xFFD97706),
          shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        );
      case ToastType.info:
        return _ToastConfig(
          backgroundColor: const Color(0xFF3B82F6), // Blue
          textColor: Colors.white,
          icon: Icons.info_rounded,
          indicatorColor: const Color(0xFF2563EB),
          shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
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
