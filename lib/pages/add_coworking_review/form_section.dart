import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/add_coworking_review_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 表单区域组件（日期、标题、内容）
class FormSection extends StatelessWidget {
  final String controllerTag;

  const FormSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCoworkingReviewPageController>(tag: controllerTag);

    return Column(
      children: [
        // Visit Date
        _buildVisitDateSection(context, controller),
        SizedBox(height: 24.h),

        // Title Input
        _buildTitleInput(context, controller),
        SizedBox(height: 24.h),

        // Content Input
        _buildContentInput(context, controller),
      ],
    );
  }

  /// 访问日期区域
  Widget _buildVisitDateSection(BuildContext context, AddCoworkingReviewPageController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => InkWell(
          onTap: () => controller.selectVisitDate(context),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.calendar, color: AppColors.textSecondary, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.visitDateOptional,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (controller.visitDate.value != null)
                        Text(
                          '${controller.visitDate.value!.year}-${controller.visitDate.value!.month.toString().padLeft(2, '0')}-${controller.visitDate.value!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        )
                      else
                        Text(
                          l10n.whenDidYouVisit,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(FontAwesomeIcons.chevronRight, color: AppColors.textSecondary),
              ],
            ),
          ),
        ));
  }

  /// 标题输入
  Widget _buildTitleInput(BuildContext context, AddCoworkingReviewPageController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.heading, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              l10n.reviewTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              l10n.required,
              style: TextStyle(
                color: const Color(0xFFFF4458),
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.titleController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: l10n.sumUpExperience,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFFF4458),
                width: 2.w,
              ),
            ),
          ),
          validator: (value) {
            final l10n = AppLocalizations.of(context)!;
            if (value == null || value.trim().isEmpty) {
              return l10n.pleaseEnterTitle;
            }
            if (value.trim().length < 5) {
              return l10n.titleMinLength;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 内容输入
  Widget _buildContentInput(BuildContext context, AddCoworkingReviewPageController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.penToSquare, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              l10n.yourExperience,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              l10n.required,
              style: TextStyle(
                color: const Color(0xFFFF4458),
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.contentController,
          maxLength: 1000,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: l10n.coworkingExperienceHint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFFF4458),
                width: 2.w,
              ),
            ),
          ),
          validator: (value) {
            final l10n = AppLocalizations.of(context)!;
            if (value == null || value.trim().isEmpty) {
              return l10n.pleaseShareExperience;
            }
            if (value.trim().length < 20) {
              return l10n.reviewMinLength;
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// 指南区域组件
class GuidelinesSection extends StatelessWidget {
  const GuidelinesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.circleInfo, color: Colors.blue[700], size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                l10n.reviewGuidelines,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${l10n.coworkingGuidelineHonest}\n'
            '${l10n.coworkingGuidelineFocus}\n'
            '${l10n.coworkingGuidelineMention}\n'
            '${l10n.coworkingGuidelineRespectful}',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.blue[900],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
