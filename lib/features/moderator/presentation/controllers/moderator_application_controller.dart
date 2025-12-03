import 'dart:developer';

import 'package:df_admin_mobile/features/moderator/domain/entities/moderator_application.dart';
import 'package:df_admin_mobile/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:get/get.dart';

/// 版主申请控制器
class ModeratorApplicationController extends GetxController {
  final IModeratorApplicationRepository _repository;

  ModeratorApplicationController(this._repository);

  // 加载状态
  final RxBool isLoading = false.obs;

  // 我的申请列表
  final RxList<ModeratorApplication> myApplications = <ModeratorApplication>[].obs;

  // 待处理申请列表（管理员使用）
  final RxList<ModeratorApplication> pendingApplications = <ModeratorApplication>[].obs;

  // 申请统计
  final RxMap<String, int> statistics = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyApplications();
  }

  /// 申请成为版主
  Future<void> applyForModerator({
    required String cityId,
    required String cityName,
    required String reason,
  }) async {
    try {
      isLoading.value = true;
      
      await _repository.applyForModerator(
        cityId: cityId,
        reason: reason,
      );

      // 注意：通知已由后端 ModeratorApplicationService 统一发送给管理员
      // 不需要在 Flutter 端重复发送

      // 重新加载申请列表
      await loadMyApplications();
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载我的申请列表
  Future<void> loadMyApplications() async {
    try {
      isLoading.value = true;
      final applications = await _repository.getMyApplications();
      myApplications.value = applications;
    } catch (e) {
      log('❌ 加载我的申请失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载待处理申请（管理员使用）
  Future<void> loadPendingApplications({int page = 1, int pageSize = 20}) async {
    try {
      isLoading.value = true;
      final applications = await _repository.getPendingApplications(
        page: page,
        pageSize: pageSize,
      );
      pendingApplications.value = applications;
    } catch (e) {
      log('❌ 加载待处理申请失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理申请（管理员使用）
  Future<void> handleApplication({
    required String applicationId,
    required String action, // 'approve' or 'reject'
    String? rejectionReason,
  }) async {
    try {
      isLoading.value = true;

      await _repository.handleApplication(
        applicationId: applicationId,
        action: action,
        rejectionReason: rejectionReason,
      );

      // 重新加载待处理列表
      await loadPendingApplications();
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取申请统计（管理员使用）
  Future<void> loadStatistics() async {
    try {
      final stats = await _repository.getStatistics();
      statistics.value = stats;
    } catch (e) {
      log('❌ 加载统计数据失败: $e');
    }
  }
}
