import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

class AppStateSurface extends StatelessWidget {
  final Widget content;
  final EdgeInsetsGeometry padding;

  const AppStateSurface({
    super.key,
    required this.content,
    this.padding = const EdgeInsets.all(18),
  });

  factory AppStateSurface.loading({String? message}) {
    return AppStateSurface(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 18.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoadingWidget(fullScreen: false),
          if ((message ?? '').isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  factory AppStateSurface.message({
    required String message,
    Widget? action,
    EdgeInsetsGeometry? padding,
  }) {
    return AppStateSurface(
      padding: padding ?? const EdgeInsets.all(18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          if (action != null) ...[
            SizedBox(height: 14.h),
            action,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: content,
    );
  }
}
