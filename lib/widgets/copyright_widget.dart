import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';

/// 统一版权信息组件
/// 用于在各个页面底部显示版权信息，保持品牌一致性
class CopyrightWidget extends StatelessWidget {
  /// 内边距
  final EdgeInsets? padding;
  
  /// 文字颜色
  final Color? textColor;
  
  /// 字体大小
  final double? fontSize;
  
  /// 是否使用较大的上边距（用于页面底部）
  final bool useTopMargin;

  const CopyrightWidget({
    super.key,
    this.padding,
    this.textColor,
    this.fontSize,
    this.useTopMargin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
        vertical: useTopMargin ? 32.h : 16.h,
        horizontal: 16.w,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '© 大连素辉软件科技有限公司 All Rights Reserved',
              style: TextStyle(
                fontSize: fontSize?.sp ?? 10.sp,
                color: textColor ?? AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '辽ICP备2026001591号',
              style: TextStyle(
                fontSize: fontSize?.sp ?? 10.sp,
                color: textColor ?? AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}