import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/report_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

/// 举报内容类型
enum ReportContentType {
  /// 用户
  user,

  /// 聊天消息
  message,

  /// 聚会活动
  meetup,

  /// 创意项目
  innovationProject,

  /// 聊天室
  chatRoom,

  /// 城市
  city,
}

/// 举报原因
class ReportReason {
  final String id;
  final String label;
  final IconData icon;

  const ReportReason({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// 通用举报弹窗
/// 支持举报用户、消息、聚会活动、创意项目等
class ReportDialog {
  /// 显示举报弹窗
  static void show({
    required BuildContext context,
    required ReportContentType contentType,
    required String targetId,
    String? targetName,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final reasons = _getReportReasons(l10n);

    Get.bottomSheet(
      AppBottomDrawer(
        title: l10n.report,
        subtitle: targetName,
        maxHeightFactor: 0.76,
        child: _ReportBottomSheet(
          contentType: contentType,
          targetId: targetId,
          targetName: targetName,
          reasons: reasons,
          l10n: l10n,
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// 获取举报原因列表
  static List<ReportReason> _getReportReasons(AppLocalizations l10n) {
    return [
      ReportReason(
        id: 'spam',
        label: l10n.reportReasonSpam,
        icon: FontAwesomeIcons.envelopesBulk,
      ),
      ReportReason(
        id: 'harassment',
        label: l10n.reportReasonHarassment,
        icon: FontAwesomeIcons.handMiddleFinger,
      ),
      ReportReason(
        id: 'inappropriate',
        label: l10n.reportReasonInappropriate,
        icon: FontAwesomeIcons.triangleExclamation,
      ),
      ReportReason(
        id: 'fraud',
        label: l10n.reportReasonFraud,
        icon: FontAwesomeIcons.userSecret,
      ),
      ReportReason(
        id: 'violence',
        label: l10n.reportReasonViolence,
        icon: FontAwesomeIcons.shieldHalved,
      ),
      ReportReason(
        id: 'other',
        label: l10n.reportReasonOther,
        icon: FontAwesomeIcons.ellipsis,
      ),
    ];
  }
}

/// 举报底部弹窗 StatefulWidget
class _ReportBottomSheet extends StatefulWidget {
  final ReportContentType contentType;
  final String targetId;
  final String? targetName;
  final List<ReportReason> reasons;
  final AppLocalizations l10n;

  const _ReportBottomSheet({
    required this.contentType,
    required this.targetId,
    required this.targetName,
    required this.reasons,
    required this.l10n,
  });

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  String? _selectedReasonId;
  bool _isSubmitting = false;

  ReportReason? get _selectedReason =>
      _selectedReasonId == null ? null : widget.reasons.firstWhere((r) => r.id == _selectedReasonId);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: widget.reasons.map((reason) => _buildReasonItem(reason)).toList(),
          ),
        ),
        AppBottomDrawerActionRow(
          secondaryLabel: widget.l10n.cancel,
          onSecondaryPressed: () => Get.back(),
          primaryLabel: widget.l10n.confirm,
          onPrimaryPressed: _onConfirm,
          primaryEnabled: _selectedReasonId != null,
          primaryLoading: _isSubmitting,
        ),
      ],
    );
  }

  /// 构建举报原因选项（单选样式）
  Widget _buildReasonItem(ReportReason reason) {
    final isSelected = _selectedReasonId == reason.id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedReasonId = reason.id;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cityPrimaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.cityPrimary.withValues(alpha: 0.35) : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              reason.icon,
              size: 20.r,
              color: isSelected ? AppColors.cityPrimary : AppColors.textSecondary,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                reason.label,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isSelected ? AppColors.cityPrimary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(FontAwesomeIcons.circleCheck, size: 18.r, color: AppColors.cityPrimary)
            else
              Icon(FontAwesomeIcons.circle, size: 18.r, color: AppColors.border),
          ],
        ),
      ),
    );
  }

  /// 确认提交举报
  Future<void> _onConfirm() async {
    final reason = _selectedReason;
    if (reason == null) return;

    setState(() => _isSubmitting = true);

    final reportService = ReportService();
    final success = await reportService.submitReport(
      contentType: widget.contentType,
      targetId: widget.targetId,
      reasonId: reason.id,
      reasonLabel: reason.label,
      targetName: widget.targetName,
    );

    setState(() => _isSubmitting = false);

    Get.back();

    if (success) {
      AppToast.success(
        widget.l10n.reportSubmittedDesc,
        title: widget.l10n.reportSubmitted,
      );
    } else {
      AppToast.error(
        widget.l10n.reportFailedDesc,
        title: widget.l10n.reportFailed,
      );
    }
  }
}
