import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

/// 注册页面常量
class RegisterConstants {
  RegisterConstants._();

  /// 主题色
  static const Color primaryColor = AppColors.cityPrimary;

  /// 输入框圆角
  static double inputBorderRadius = AppUiTokens.radiusMd;

  /// 按钮圆角
  static double buttonBorderRadius = AppUiTokens.radiusMd;

  /// 页面内边距
  static EdgeInsets pagePadding = AppUiTokens.pagePadding;
}
