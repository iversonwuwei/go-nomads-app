import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

/// 登录页面常量
class LoginConstants {
  // 品牌色
  static const Color primaryColor = AppColors.cityPrimary;
  static const Color wechatGreen = Color(0xFF09BB07);
  static const Color qqBlue = Color(0xFF12B7F5);
  static const Color googleRed = Color(0xFFDB4437);
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color phoneGreen = Color(0xFF4CAF50);

  // 尺寸
  static double inputBorderRadius = AppUiTokens.radiusMd;
  static double buttonBorderRadius = AppUiTokens.radiusMd;
  static double cardBorderRadius = AppUiTokens.radiusLg;
  static double iconSize = 28.0;
  static double logoSize = 80.0;

  // 间距
  static EdgeInsets pagePadding = AppUiTokens.pagePadding;
  static const double verticalSpacing = 20.0;
  static const double sectionSpacing = 24.0;
}
