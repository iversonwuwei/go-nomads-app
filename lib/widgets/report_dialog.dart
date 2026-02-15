import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/report_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

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
      _ReportBottomSheet(
        contentType: contentType,
        targetId: targetId,
        targetName: targetName,
        reasons: reasons,
        l10n: l10n,
      ),
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
      _selectedReasonId == null
          ? null
          : widget.reasons.firstWhere((r) => r.id == _selectedReasonId);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖动条
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.circleExclamation, size: 20, color: Color(0xFFFF4458)),
                  const SizedBox(width: 10),
                  Text(
                    widget.l10n.report,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.targetName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.targetName!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            const Divider(height: 16),
            // 举报原因列表（可滚动，防止小屏溢出）
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: widget.reasons
                    .map((reason) => _buildReasonItem(reason))
                    .toList(),
              ),
            ),
            const Divider(height: 1),
            // 底部按钮区域：取消 + 确认
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.l10n.cancel,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 确认按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_selectedReasonId == null || _isSubmitting)
                          ? null
                          : _onConfirm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFFF4458),
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        disabledForegroundColor: const Color(0xFFBBBBBB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.l10n.confirm,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isSelected ? const Color(0xFFFFF0F1) : null,
        child: Row(
          children: [
            Icon(
              reason.icon,
              size: 20,
              color: isSelected ? const Color(0xFFFF4458) : const Color(0xFF666666),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                reason.label,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? const Color(0xFFFF4458) : const Color(0xFF333333),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(FontAwesomeIcons.circleCheck, size: 18, color: Color(0xFFFF4458))
            else
              const Icon(FontAwesomeIcons.circle, size: 18, color: Color(0xFFDDDDDD)),
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
