import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

class AuthStepShell extends StatelessWidget {
  final IconData icon;
  final String description;
  final Widget child;
  final Color? accentColor;

  const AuthStepShell({
    super.key,
    required this.icon,
    required this.description,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.cityPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Center(
          child: Container(
            width: AppUiTokens.authIconBadgeSize,
            height: AppUiTokens.authIconBadgeSize,
            decoration: BoxDecoration(
              color: effectiveAccent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppUiTokens.authIconSize, color: effectiveAccent),
          ),
        ),
        SizedBox(height: 24.h),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 320.w),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ),
        SizedBox(height: 28.h),
        child,
      ],
    );
  }
}
