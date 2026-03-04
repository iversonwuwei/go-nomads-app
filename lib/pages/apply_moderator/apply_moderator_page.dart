import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/apply_moderator/apply_moderator_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 申请成为版主页面 - GetView 重构版
class ApplyModeratorPage extends GetView<ApplyModeratorController> {
  const ApplyModeratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.moderatorCardApplyModerator),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 城市信息卡片
              _buildCityCard(),
              SizedBox(height: 32.h),

              // 版主职责说明
              _buildResponsibilitiesCard(),
              SizedBox(height: 32.h),

              // 申请原因输入
              _buildReasonInput(l10n),
              SizedBox(height: 32.h),

              // 提交按钮
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard() {
    final city = controller.city;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: city.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(city.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: city.imageUrl == null ? AppColors.accent.withValues(alpha: 0.1) : null,
            ),
            child: city.imageUrl == null
                ? Icon(
                    FontAwesomeIcons.city,
                    color: AppColors.accent,
                    size: 24.r,
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  city.country ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilitiesCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.userShield,
                color: AppColors.accent,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Text(
                '版主职责',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildResponsibilityItem('审核和管理用户提交的内容'),
          _buildResponsibilityItem('维护城市信息的准确性和时效性'),
          _buildResponsibilityItem('回答社区成员的问题'),
          _buildResponsibilityItem('组织线下活动和聚会'),
          _buildResponsibilityItem('处理不当内容和用户举报'),
        ],
      ),
    );
  }

  Widget _buildResponsibilityItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            margin: EdgeInsets.only(top: 6.h),
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonInput(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '申请原因 *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.reasonController,
          maxLines: 6,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: l10n.applyModeratorReasonHint,
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.accent, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(16.w),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入申请原因';
            }
            if (value.trim().length < 20) {
              return '申请原因至少需要 20 个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value ? null : controller.submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: controller.isSubmitting.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    '提交申请',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ));
  }
}
