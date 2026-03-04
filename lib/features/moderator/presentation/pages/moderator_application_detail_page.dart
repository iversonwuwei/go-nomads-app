import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/moderator/domain/entities/moderator_application.dart';
import 'package:go_nomads_app/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:go_nomads_app/features/moderator/infrastructure/repositories/moderator_application_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// 版主申请详情页面（管理员审核使用）
class ModeratorApplicationDetailPage extends StatefulWidget {
  final String applicationId;

  const ModeratorApplicationDetailPage({
    super.key,
    required this.applicationId,
  });

  @override
  State<ModeratorApplicationDetailPage> createState() => _ModeratorApplicationDetailPageState();
}

class _ModeratorApplicationDetailPageState extends State<ModeratorApplicationDetailPage> {
  late IModeratorApplicationRepository _repository;
  ModeratorApplication? _application;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    log('📝 ModeratorApplicationDetailPage initState');
    log('   applicationId: "${widget.applicationId}"');
    _initRepository();
    _loadApplication();
  }

  void _initRepository() {
    if (!Get.isRegistered<IModeratorApplicationRepository>()) {
      Get.put<IModeratorApplicationRepository>(ModeratorApplicationRepository());
    }
    _repository = Get.find<IModeratorApplicationRepository>();
  }

  Future<void> _loadApplication() async {
    log('📝 _loadApplication called with id: "${widget.applicationId}"');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final application = await _repository.getApplicationById(widget.applicationId);
      log('📝 Application loaded: ${application.id}');
      setState(() {
        _application = application;
        _isLoading = false;
      });
    } catch (e) {
      log('❌ _loadApplication error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.confirmApprove),
        content: Text(l10n.confirmApproveMessage(_application?.userName ?? l10n.unknownUser)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processApplication('approve');
    }
  }

  Future<void> _handleReject() async {
    final l10n = AppLocalizations.of(context)!;
    String? rejectionReason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final reasonController = TextEditingController();

        return AlertDialog(
          title: Text(l10n.rejectApplication),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.confirmRejectMessage(_application?.userName ?? l10n.unknownUser)),
                SizedBox(height: 16.h),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: l10n.rejectReasonOptional,
                    hintText: l10n.enterRejectReason,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                  onChanged: (value) {
                    rejectionReason = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                rejectionReason = reasonController.text;
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(l10n.confirmReject),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _processApplication(
        'reject',
        rejectionReason: rejectionReason?.isNotEmpty == true ? rejectionReason : null,
      );
    }
  }

  Future<void> _handleRevoke() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.confirmRevoke),
        content: Text(
            '${l10n.confirmRevokeMessage(_application?.userName ?? l10n.unknownUser)}\n\n${l10n.revokePermissionWarning}'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: Text(l10n.confirmRevoke),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);

      try {
        await _repository.revokeModerator(widget.applicationId);
        AppToast.success(l10n.moderatorRevoked);

        // 通过 DataEventBus 广播城市更新事件
        if (_application != null) {
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'city',
            entityId: _application!.cityId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.updated,
            metadata: {'reason': 'moderator_revoked'},
          ));
          log('📡 [ModeratorApplication] 已发送版主撤销事件: cityId=${_application!.cityId}');
        }

        Get.back(result: true);
      } catch (e) {
        AppToast.error(l10n.revokeFailed(e.toString()));
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processApplication(String action, {String? rejectionReason}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isProcessing = true);

    try {
      await _repository.handleApplication(
        applicationId: widget.applicationId,
        action: action,
        rejectionReason: rejectionReason,
      );

      final message = action == 'approve' ? l10n.applicationApproved : l10n.applicationRejected;
      AppToast.success(message);

      // 通过 DataEventBus 广播城市更新事件，通知所有页面刷新版主信息
      if (_application != null) {
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'city',
          entityId: _application!.cityId,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: DataChangeType.updated,
          metadata: {'reason': 'moderator_application_$action'},
        ));
        log('📡 [ModeratorApplication] 已发送城市版主更新事件: cityId=${_application!.cityId}, action=$action');
      }

      // 返回上一页
      Get.back(result: true);
    } catch (e) {
      AppToast.error(l10n.operationFailedWithError(e.toString()));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(l10n.moderatorApplicationDetail),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const UserProfileSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.circleExclamation, size: 56.r, color: AppColors.iconSecondary),
            SizedBox(height: 16.h),
            Text(
              l10n.loadFailed,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              _error!,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadApplication,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_application == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.inbox, size: 56.r, color: AppColors.iconSecondary),
            SizedBox(height: 16.h),
            Text(
              l10n.applicationNotExists,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 申请状态卡片
          _buildStatusCard(),
          SizedBox(height: 16.h),

          // 申请人信息
          _buildApplicantCard(),
          SizedBox(height: 16.h),

          // 申请城市
          _buildCityCard(),
          SizedBox(height: 16.h),

          // 申请理由
          _buildReasonCard(),
          SizedBox(height: 24.h),

          // 操作按钮（仅待处理状态显示）
          if (_application!.isPending) _buildActionButtons(),

          // 撤销版主按钮（仅已通过状态显示）
          if (_application!.isApproved) _buildRevokeButton(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final l10n = AppLocalizations.of(context)!;
    final app = _application!;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (app.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = FontAwesomeIcons.hourglassHalf;
        statusText = l10n.moderatorStatusPending;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = FontAwesomeIcons.circleCheck;
        statusText = l10n.moderatorStatusApproved;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = FontAwesomeIcons.circleXmark;
        statusText = l10n.moderatorStatusRejected;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = FontAwesomeIcons.circleQuestion;
        statusText = app.status;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(statusIcon, color: statusColor, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.applicationTime(_formatDateTime(app.createdAt)),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (app.processedAt != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      l10n.processTime(_formatDateTime(app.processedAt!)),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard() {
    final l10n = AppLocalizations.of(context)!;
    final app = _application!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.applicantInfo,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                SafeCircleAvatar(
                  imageUrl: app.userAvatar,
                  radius: 28,
                  placeholder: FaIcon(FontAwesomeIcons.user, size: 24.r),
                  errorWidget: FaIcon(FontAwesomeIcons.user, size: 24.r),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.userName ?? l10n.unknownUser,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'ID: ${app.userId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityCard() {
    final l10n = AppLocalizations.of(context)!;
    final app = _application!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.applicationCity,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.city,
                    color: AppColors.accent,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    app.cityName ?? l10n.unknownCity,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonCard() {
    final l10n = AppLocalizations.of(context)!;
    final app = _application!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.applicationReason,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                app.reason.isNotEmpty ? app.reason : l10n.noReasonProvided,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: app.reason.isNotEmpty ? Colors.black87 : Colors.grey[500],
                  height: 1.5,
                ),
              ),
            ),

            // 如果被拒绝，显示拒绝原因
            if (app.isRejected && app.rejectionReason != null) ...[
              SizedBox(height: 16.h),
              Text(
                l10n.rejectReason,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  app.rejectionReason!,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.red[800],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _handleReject,
            icon: _isProcessing
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FaIcon(FontAwesomeIcons.xmark, size: 18.r),
            label: Text(l10n.reject),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isProcessing ? null : _handleApprove,
            icon: _isProcessing
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : FaIcon(FontAwesomeIcons.check, size: 18.r),
            label: Text(l10n.approve),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevokeButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isProcessing ? null : _handleRevoke,
        icon: _isProcessing
            ? SizedBox(
                width: 18.w,
                height: 18.h,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FaIcon(FontAwesomeIcons.userSlash, size: 18.r),
        label: Text(l10n.revokeModeratorStatus),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
