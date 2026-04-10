import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

class AppBottomDrawer extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final double maxHeightFactor;
  final EdgeInsetsGeometry contentPadding;
  final bool showHandle;

  const AppBottomDrawer({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.footer,
    this.maxHeightFactor = 0.9,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 12, 20, 20),
    this.showHandle = true,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    required Widget child,
    Widget? footer,
    double maxHeightFactor = 0.9,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.fromLTRB(20, 12, 20, 20),
    bool isDismissible = true,
    bool enableDrag = true,
    bool showHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomDrawer(
        title: title,
        subtitle: subtitle,
        footer: footer,
        maxHeightFactor: maxHeightFactor,
        contentPadding: contentPadding,
        showHandle: showHandle,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final hasHeader = hasTitle || hasSubtitle;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * maxHeightFactor,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppUiTokens.radiusXl)),
              boxShadow: AppUiTokens.softTopSheetShadow,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHandle) ...[
                    SizedBox(height: 10.h),
                    Container(
                      width: 44.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ],
                  if (hasHeader)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasTitle)
                            Text(
                              title!,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          if (hasSubtitle) ...[
                            SizedBox(height: 6.h),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.sp,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: contentPadding,
                      child: child,
                    ),
                  ),
                  if (footer != null)
                    Container(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      child: footer,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppBottomDrawerActionRow extends StatelessWidget {
  final String secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool primaryDestructive;
  final bool primaryLoading;
  final bool secondaryEnabled;
  final bool primaryEnabled;

  const AppBottomDrawerActionRow({
    super.key,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.primaryDestructive = false,
    this.primaryLoading = false,
    this.secondaryEnabled = true,
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: secondaryEnabled ? onSecondaryPressed : null,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(48.h),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                ),
              ),
              child: Text(secondaryLabel),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FilledButton(
              onPressed: primaryEnabled && !primaryLoading ? onPrimaryPressed : null,
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(48.h),
                backgroundColor: primaryDestructive ? AppColors.cityPrimaryDark : AppColors.cityPrimary,
                disabledBackgroundColor:
                    (primaryDestructive ? AppColors.cityPrimaryDark : AppColors.cityPrimary).withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                ),
              ),
              child: primaryLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
