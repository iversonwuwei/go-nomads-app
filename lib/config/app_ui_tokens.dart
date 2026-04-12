import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppUiTokens {
  AppUiTokens._();

  static double radiusSm = 10.r;
  static double radiusMd = 14.r;
  static double radiusLg = 20.r;
  static double radiusXl = 28.r;
  static double radiusHero = 30.r;

  static double buttonHeight = 52.h;
  static double inputHeight = 52.h;
  static double authIconBadgeSize = 72.w;
  static double authIconSize = 34.r;

  static EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);
  static EdgeInsets cardPadding = EdgeInsets.all(18.w);
  static EdgeInsets sectionGap = EdgeInsets.only(top: 18.h);

  static List<BoxShadow> softTopSheetShadow = [
    BoxShadow(
      color: const Color(0x1F0F172A),
      blurRadius: 32.r,
      offset: const Offset(0, -8),
    ),
  ];

  static List<BoxShadow> softFloatingShadow = [
    BoxShadow(
      color: const Color(0x120F172A),
      blurRadius: 20.r,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> heroCardShadow = [
    BoxShadow(
      color: const Color(0x160F172A),
      blurRadius: 28.r,
      offset: const Offset(0, 14),
    ),
  ];
}
