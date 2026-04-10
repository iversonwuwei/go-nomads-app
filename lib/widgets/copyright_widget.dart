import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/services/app_config_service.dart';

/// 统一版权信息组件
/// 用于在各个页面底部显示版权信息，保持品牌一致性
class CopyrightWidget extends StatefulWidget {
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
  State<CopyrightWidget> createState() => _CopyrightWidgetState();
}

class _CopyrightWidgetState extends State<CopyrightWidget> {
  static const _defaultCopyright = '© 大连素辉软件科技有限公司 All Rights Reserved';
  static const _defaultIcpRecord = '辽ICP备2026001591号';

  late final Future<PublicBrandingCopy> _brandingCopyFuture;

  @override
  void initState() {
    super.initState();
    _brandingCopyFuture = AppConfigService().getPublicBrandingCopy();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PublicBrandingCopy>(
      future: _brandingCopyFuture,
      builder: (context, snapshot) {
        final copy = snapshot.data;
        final copyrightText = copy?.footerCopyright ?? _defaultCopyright;
        final icpRecordText = copy?.footerIcpRecord ?? _defaultIcpRecord;

        return Padding(
          padding: widget.padding ??
              EdgeInsets.symmetric(
                vertical: widget.useTopMargin ? 32.h : 16.h,
                horizontal: 16.w,
              ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  copyrightText,
                  style: TextStyle(
                    fontSize: widget.fontSize?.sp ?? 10.sp,
                    color: widget.textColor ?? AppColors.textTertiary,
                    letterSpacing: 0.5.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  icpRecordText,
                  style: TextStyle(
                    fontSize: widget.fontSize?.sp ?? 10.sp,
                    color: widget.textColor ?? AppColors.textTertiary,
                    letterSpacing: 0.5.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
