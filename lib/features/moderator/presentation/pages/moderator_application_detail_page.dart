import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/moderator/domain/entities/moderator_application.dart';
import 'package:go_nomads_app/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:go_nomads_app/features/moderator/infrastructure/repositories/moderator_application_repository.dart';
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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认通过'),
        content: Text('确定要通过 ${_application?.userName ?? "该用户"} 的版主申请吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processApplication('approve');
    }
  }

  Future<void> _handleReject() async {
    String? rejectionReason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final reasonController = TextEditingController();

        return AlertDialog(
          title: const Text('拒绝申请'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('确定要拒绝 ${_application?.userName ?? "该用户"} 的版主申请吗？'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: '拒绝原因（可选）',
                    hintText: '请输入拒绝原因...',
                    border: OutlineInputBorder(),
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
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                rejectionReason = reasonController.text;
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('确认拒绝'),
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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认撤销'),
        content: Text('确定要撤销 ${_application?.userName ?? "该用户"} 的版主资格吗？\n\n此操作将移除该用户在此城市的所有版主权限。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('确认撤销'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);

      try {
        await _repository.revokeModerator(widget.applicationId);
        AppToast.success('已撤销版主资格');

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
        AppToast.error('撤销失败: $e');
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processApplication(String action, {String? rejectionReason}) async {
    setState(() => _isProcessing = true);

    try {
      await _repository.handleApplication(
        applicationId: widget.applicationId,
        action: action,
        rejectionReason: rejectionReason,
      );

      final message = action == 'approve' ? '已通过申请' : '已拒绝申请';
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
      AppToast.error('操作失败: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('版主申请详情'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const UserProfileSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.circleExclamation, size: 56, color: AppColors.iconSecondary),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadApplication,
              child: const Text('重试'),
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
            FaIcon(FontAwesomeIcons.inbox, size: 56, color: AppColors.iconSecondary),
            const SizedBox(height: 16),
            Text(
              '申请不存在',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 申请状态卡片
          _buildStatusCard(),
          const SizedBox(height: 16),

          // 申请人信息
          _buildApplicantCard(),
          const SizedBox(height: 16),

          // 申请城市
          _buildCityCard(),
          const SizedBox(height: 16),

          // 申请理由
          _buildReasonCard(),
          const SizedBox(height: 24),

          // 操作按钮（仅待处理状态显示）
          if (_application!.isPending) _buildActionButtons(),

          // 撤销版主按钮（仅已通过状态显示）
          if (_application!.isApproved) _buildRevokeButton(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final app = _application!;
    Color statusColor;
    IconData statusIcon;

    switch (app.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = FontAwesomeIcons.hourglassHalf;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = FontAwesomeIcons.circleCheck;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = FontAwesomeIcons.circleXmark;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = FontAwesomeIcons.circleQuestion;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '申请时间: ${_formatDateTime(app.createdAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (app.processedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '处理时间: ${_formatDateTime(app.processedAt!)}',
                      style: TextStyle(
                        fontSize: 14,
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
    final app = _application!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '申请人信息',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SafeCircleAvatar(
                  imageUrl: app.userAvatar,
                  radius: 28,
                  placeholder: const FaIcon(FontAwesomeIcons.user, size: 24),
                  errorWidget: const FaIcon(FontAwesomeIcons.user, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.userName ?? '未知用户',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${app.userId}',
                        style: TextStyle(
                          fontSize: 12,
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
    final app = _application!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '申请管理的城市',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.city,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    app.cityName ?? '未知城市',
                    style: const TextStyle(
                      fontSize: 18,
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
    final app = _application!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '申请理由',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                app.reason.isNotEmpty ? app.reason : '未填写申请理由',
                style: TextStyle(
                  fontSize: 15,
                  color: app.reason.isNotEmpty ? Colors.black87 : Colors.grey[500],
                  height: 1.5,
                ),
              ),
            ),

            // 如果被拒绝，显示拒绝原因
            if (app.isRejected && app.rejectionReason != null) ...[
              const SizedBox(height: 16),
              Text(
                '拒绝原因',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  app.rejectionReason!,
                  style: TextStyle(
                    fontSize: 15,
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _handleReject,
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const FaIcon(FontAwesomeIcons.xmark, size: 18),
            label: const Text('拒绝'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isProcessing ? null : _handleApprove,
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const FaIcon(FontAwesomeIcons.check, size: 18),
            label: const Text('通过'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevokeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isProcessing ? null : _handleRevoke,
        icon: _isProcessing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const FaIcon(FontAwesomeIcons.userSlash, size: 18),
        label: const Text('撤销版主资格'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
