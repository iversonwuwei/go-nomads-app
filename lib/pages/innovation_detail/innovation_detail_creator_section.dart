import 'package:go_nomads_app/controllers/innovation_detail_page_controller.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Innovation Detail Creator Section
/// 创意项目详情页 - 创建者信息区块
class InnovationDetailCreatorSection extends StatelessWidget {
  final String controllerTag;

  const InnovationDetailCreatorSection({
    super.key,
    required this.controllerTag,
  });

  InnovationDetailPageController get _c =>
      Get.find<InnovationDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppUiTokens.softFloatingShadow,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.cityPrimaryLight,
                backgroundImage: _c.project.userAvatar != null &&
                        _c.project.userAvatar!.isNotEmpty
                    ? NetworkImage(_c.project.userAvatar!)
                    : null,
                child: _c.project.userAvatar == null ||
                        _c.project.userAvatar!.isEmpty
                    ? Text(
                        (_c.project.userName ?? '?').isNotEmpty
                            ? (_c.project.userName ?? '?').substring(0, 1)
                            : '?',
                        style: TextStyle(
                          color: AppColors.cityPrimary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _c.project.userName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${l10n.createdAt} ${_c.formatDate(_c.project.createdAt)}',
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
        ));
  }
}
