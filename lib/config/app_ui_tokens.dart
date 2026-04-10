import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppUiTokens {
  AppUiTokens._();

  static double radiusSm = 10.r;
  static double radiusMd = 12.r;
  static double radiusLg = 16.r;
  static double radiusXl = 28.r;

  static double buttonHeight = 52.h;
  static double inputHeight = 56.h;
  static double authIconBadgeSize = 72.w;
  static double authIconSize = 34.r;

  static EdgeInsets pagePadding = EdgeInsets.all(24.w);
  static EdgeInsets cardPadding = EdgeInsets.all(20.w);

  static List<BoxShadow> softTopSheetShadow = [
    BoxShadow(
      color: const Color(0x1F0F172A),
      blurRadius: 32.r,
      offset: const Offset(0, -8),
    ),
  ];

  static List<BoxShadow> softFloatingShadow = [
    BoxShadow(
      color: const Color(0x1A0F172A),
      blurRadius: 16.r,
      offset: const Offset(0, 6),
    ),
  ];
}
