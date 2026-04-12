import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/innovation_detail_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Innovation Detail Bottom Bar
/// 创意项目详情页 - 底部操作栏
class InnovationDetailBottomBar extends StatelessWidget {
  final String controllerTag;
  final VoidCallback? onContact;

  const InnovationDetailBottomBar({
    super.key,
    required this.controllerTag,
    this.onContact,
  });

  InnovationDetailPageController get _c =>
      Get.find<InnovationDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: AppUiTokens.softTopSheetShadow,
      ),
      child: SafeArea(
        child: Obx(() {
          final isCreator = _c.project.canEdit;

          return Row(
            children: [
              // 关注按钮
              Expanded(
                flex: 1,
                child: _buildFollowButton(context, l10n),
              ),
              if (!isCreator) SizedBox(width: 12.w),
              // 联系按钮（非创建者才显示）
              if (!isCreator)
                Expanded(
                  flex: 2,
                  child: _buildContactButton(l10n),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, AppLocalizations l10n) {
    return Obx(() => OutlinedButton.icon(
          onPressed:
              _c.isToggling.value ? null : () => _c.toggleFollow(context),
          icon: Icon(
            _c.isFollowed.value
                ? FontAwesomeIcons.solidHeart
                : FontAwesomeIcons.heart,
            size: 20.r,
          ),
          label: Text(
            _c.isToggling.value
                ? l10n.loading
                : (_c.isFollowed.value ? l10n.following : l10n.follow),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _c.isFollowed.value
                ? AppColors.cityPrimary
                : AppColors.textSecondary,
            side: BorderSide(
              color: _c.isFollowed.value
                  ? AppColors.cityPrimary
                  : AppColors.border,
              width: 1.5,
            ),
            backgroundColor: _c.isFollowed.value ? AppColors.cityPrimaryLight : AppColors.surfaceElevated,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ));
  }

  Widget _buildContactButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: onContact,
      icon: Icon(FontAwesomeIcons.message, size: 20.r),
      label: Text(
        l10n.sendMessage,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
      ),
    );
  }
}
