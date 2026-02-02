import 'package:go_nomads_app/features/moderator/domain/entities/moderator_application.dart';

/// 版主申请仓储接口
abstract class IModeratorApplicationRepository {
  /// 申请成为版主
  Future<void> applyForModerator({
    required String cityId,
    required String reason,
  });

  /// 获取我的申请列表
  Future<List<ModeratorApplication>> getMyApplications();

  /// 获取待处理申请列表（管理员使用）
  Future<List<ModeratorApplication>> getPendingApplications({
    int page = 1,
    int pageSize = 20,
  });

  /// 处理申请（管理员使用）
  Future<void> handleApplication({
    required String applicationId,
    required String action, // 'approve' or 'reject'
    String? rejectionReason,
  });

  /// 获取申请详情
  Future<ModeratorApplication> getApplicationById(String id);

  /// 获取申请统计（管理员使用）
  Future<Map<String, int>> getStatistics();

  /// 撤销版主资格（管理员使用）
  Future<void> revokeModerator(String applicationId);

  /// 发起版主转让
  Future<void> initiateTransfer({
    required String cityId,
    required String toUserId,
    String? message,
  });
}
