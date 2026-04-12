import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

class CoworkingDetailContactSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailContactSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final contact = _c.space.value.contactInfo;
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contactInfo,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 16.h),
            if (contact.phone.isNotEmpty) _buildPhoneCard(context, l10n, contact.phone),
            if (contact.phone.isNotEmpty && contact.email.isNotEmpty) SizedBox(height: 12.h),
            if (contact.email.isNotEmpty) _buildEmailCard(l10n, contact.email),
            if ((contact.phone.isNotEmpty || contact.email.isNotEmpty) && contact.hasWebsite) SizedBox(height: 12.h),
            if (contact.hasWebsite) _buildWebsiteCard(l10n, contact.website),
          ],
        ),
      );
    });
  }

  Widget _buildPhoneCard(BuildContext context, AppLocalizations l10n, String phone) {
    return InkWell(
      onTap: () => _c.makePhoneCall(context, phone),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.travelSky.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(FontAwesomeIcons.phone, color: Colors.white, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.phone, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  SizedBox(height: 2.h),
                  Text(
                    phone,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.cityPrimaryLight,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.phone, color: AppColors.cityPrimary, size: 16.r),
                  SizedBox(width: 4.w),
                  Text(
                    l10n.call,
                    style: TextStyle(color: AppColors.cityPrimary, fontWeight: FontWeight.w600, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailCard(AppLocalizations l10n, String email) {
    return InkWell(
      onTap: () => _c.launchURL('mailto:$email'),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.cityPrimaryLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(FontAwesomeIcons.envelope, color: AppColors.cityPrimary, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.email, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  SizedBox(height: 2.h),
                  Text(
                    email,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(FontAwesomeIcons.arrowRight, size: 16.r, color: AppColors.cityPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteCard(AppLocalizations l10n, String website) {
    return InkWell(
      onTap: () => _c.launchURL(website),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.travelMint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(FontAwesomeIcons.globe, color: AppColors.travelMint, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.website, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  SizedBox(height: 2.h),
                  Text(
                    website,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(FontAwesomeIcons.arrowRight, size: 16.r, color: AppColors.travelMint),
          ],
        ),
      ),
    );
  }
}
