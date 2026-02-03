import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/features/innovation_project/domain/repositories/i_innovation_project_repository.dart';
import 'package:go_nomads_app/features/innovation_project/presentation/controllers/innovation_project_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// Innovation Detail Page Controller
class InnovationDetailPageController extends GetxController {
  final InnovationProject initialProject;

  InnovationDetailPageController({required this.initialProject});

  // 完整项目数据
  final Rx<InnovationProject?> fullProject = Rx<InnovationProject?>(null);

  // 加载状态
  final RxBool isLoading = true.obs;

  // 关注状态
  final RxBool isFollowed = false.obs;

  // 防止重复点击
  final RxBool isToggling = false.obs;

  // 管理员状态
  final RxBool isAdmin = false.obs;

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  /// 获取当前显示的项目（优先使用完整数据）
  InnovationProject get project => fullProject.value ?? initialProject;

  /// 获取 InnovationProjectStateController
  InnovationProjectStateController? get _stateController {
    try {
      return Get.find<InnovationProjectStateController>();
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
    _checkAdminStatus();
    // 延迟加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFullProject();
    });
  }

  /// 检查管理员状态
  Future<void> _checkAdminStatus() async {
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final role = await tokenService.getUserRole();
      isAdmin.value = role == 'admin' || role == 'super_admin';
    }
  }

  /// 删除创新项目（管理员或所有者可删除）
  Future<bool> deleteInnovationProject() async {
    try {
      final projectId = project.uuid ?? project.id.toString();
      print('🗑️ [InnovationDetailPageController] 删除创新项目: $projectId');

      final repository = Get.find<IInnovationProjectRepository>();
      final result = await repository.deleteProject(projectId);

      return result.fold(
        onSuccess: (_) {
          print('✅ [InnovationDetailPageController] 创新项目删除成功');
          // 通知列表刷新
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'innovation_project',
            entityId: projectId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.deleted,
          ));
          return true;
        },
        onFailure: (error) {
          print('❌ [InnovationDetailPageController] 删除失败: ${error.message}');
          return false;
        },
      );
    } catch (e) {
      print('❌ [InnovationDetailPageController] 删除异常: $e');
      return false;
    }
  }

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    super.onClose();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('innovation_project', _handleDataChanged);
    print('✅ [InnovationDetailPageController] 数据变更监听器已设置');
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 只处理当前项目的变更
    final projectId = initialProject.uuid;
    if (event.entityId != projectId) {
      return;
    }

    // 忽略自己发出的事件（通过 source 判断）
    if (event.metadata?['source'] == 'detail') {
      return;
    }

    print('🔔 [创新项目详情] 收到数据变更通知: ${event.entityId} (${event.changeType}), metadata: ${event.metadata}');

    switch (event.changeType) {
      case DataChangeType.updated:
        // 项目数据更新，从事件 metadata 同步关注状态
        _syncFollowedStateFromEvent(event.metadata);
        break;
      case DataChangeType.deleted:
        // 项目被删除
        print('⚠️ [创新项目详情] 该项目已被删除');
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        loadFullProject();
        break;
      case DataChangeType.created:
        // 新建项目通常不影响详情页
        break;
    }
  }

  /// 从事件 metadata 同步关注状态
  void _syncFollowedStateFromEvent(Map<String, dynamic>? metadata) {
    if (metadata != null && metadata.containsKey('isFollowed')) {
      final newState = metadata['isFollowed'] as bool;
      if (isFollowed.value != newState) {
        isFollowed.value = newState;
        print('🔄 [创新项目详情] 从事件同步关注状态: ${initialProject.uuid} -> $newState');
      }
    }
  }

  /// 加载完整项目数据
  Future<void> loadFullProject() async {
    final controller = _stateController;
    final projectId = initialProject.uuid;
    print('📱 加载项目详情: projectId=$projectId, controller=${controller != null}');

    if (controller != null && projectId != null) {
      await controller.getProjectById(projectId);
      print('📱 API返回: currentProject=${controller.currentProject.value?.projectName}');

      fullProject.value = controller.currentProject.value;
      isLoading.value = false;
      // 从服务器数据初始化关注状态
      isFollowed.value = fullProject.value?.isLiked ?? false;
      print('📱 设置 fullProject: ${fullProject.value?.projectName}, isLiked: ${isFollowed.value}');
    } else {
      print('📱 跳过加载: controller=$controller, projectId=$projectId');
      isLoading.value = false;
    }
  }

  /// 切换关注状态
  Future<void> toggleFollow(BuildContext context) async {
    if (isToggling.value) return; // 防止重复点击

    final projectId = project.uuid;
    if (projectId == null) {
      _showSnackBar(context, '项目 ID 无效', Colors.red[700]!);
      return;
    }

    // 先乐观更新 UI
    final previousState = isFollowed.value;
    isFollowed.value = !previousState;
    isToggling.value = true;

    // 调用 API
    try {
      final repository = Get.find<IInnovationProjectRepository>();
      final result = await repository.toggleLike(projectId);

      switch (result) {
        case Success(data: final isLiked):
          // API 成功，更新为服务器返回的状态
          isFollowed.value = isLiked;

          // 通知其他组件数据变更（携带新的关注状态）
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'innovation_project',
            entityId: projectId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.updated,
            metadata: {'isFollowed': isLiked, 'source': 'detail'},
          ));
          isToggling.value = false;
          if (!context.mounted) return;
          _showSnackBar(
            context,
            isLiked ? '已关注项目' : '已取消关注',
            isLiked ? const Color(0xFF8B5CF6) : Colors.grey[700]!,
          );

        case Failure(exception: final error):
          // API 失败，回滚状态
          isFollowed.value = previousState;
          isToggling.value = false;
          if (!context.mounted) return;
          _showSnackBar(context, '操作失败: ${error.message}', Colors.red[700]!);
      }
    } catch (e) {
      // 异常处理，回滚状态
      isFollowed.value = previousState;
      isToggling.value = false;
      if (!context.mounted) return;
      _showSnackBar(context, '操作失败: $e', Colors.red[700]!);
    }
  }

  /// 跳转到编辑页面并处理返回
  Future<void> navigateToEdit(BuildContext context) async {
    await NavigationUtil.toNamedWithCallback<bool>(
      route: '/add-innovation',
      arguments: project,
      onResult: (result) {
        // 如果返回需要刷新，说明编辑成功，刷新数据
        if (result.needsRefresh) {
          loadFullProject();
        }
      },
    );
  }

  /// 创建发布者的 User 对象用于聊天
  User get creatorUser => User(
        // 使用 creatorUuid（创建者的真实 UUID）而不是 userId（hashCode）
        id: project.creatorUuid ?? project.userId.toString(),
        name: project.userName ?? 'Unknown',
        username: (project.userName ?? 'unknown').toLowerCase().replaceAll(' ', '_'),
        avatarUrl: project.userAvatar,
        stats: TravelStats(
          citiesVisited: 0,
          countriesVisited: 0,
          reviewsWritten: 0,
          photosShared: 0,
          totalDistanceTraveled: 0,
        ),
        joinedDate: DateTime.now(),
      );

  /// 格式化日期
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    if (backgroundColor == Colors.red) {
      AppToast.error(message);
    } else if (backgroundColor == Colors.green) {
      AppToast.success(message);
    } else {
      AppToast.info(message);
    }
  }
}
