import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 法律信息入口组件（用于 Profile 页面，工信部/腾讯合规要求）
/// Legal info entry widget (Tencent app store compliance - permanent entry)
class LegalInfoWidget extends StatelessWidget {
  const LegalInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        children: [
          // 用户协议
          _LegalItem(
            icon: FontAwesomeIcons.fileContract,
            iconColor: const Color(0xFF4A90D9),
            bgColor: const Color(0xFFEBF3FB),
            title: l10n.termsAndConditions,
            onTap: () => Get.toNamed(AppRoutes.termsOfService),
          ),
          Divider(height: 1, indent: 60.w, endIndent: 16.w),
          // 隐私政策
          _LegalItem(
            icon: FontAwesomeIcons.shieldHalved,
            iconColor: const Color(0xFF52C41A),
            bgColor: const Color(0xFFEFF9EB),
            title: l10n.privacyPolicy,
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
        ],
      ),
    );
  }
}

/// 法律信息列表项
class _LegalItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final VoidCallback onTap;

  const _LegalItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: iconColor, size: 18.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                FontAwesomeIcons.chevronRight,
                color: AppColors.textSecondary,
                size: 12.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
