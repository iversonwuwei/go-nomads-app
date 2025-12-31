import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/repositories/i_innovation_project_repository.dart';
import 'package:df_admin_mobile/features/innovation_project/presentation/controllers/innovation_project_state_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    // 延迟加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFullProject();
    });
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
          // 通知其他组件数据变更
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'innovation_project',
            entityId: projectId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.updated,
          ));
          
          isFollowed.value = isLiked;
          isToggling.value = false;
          _showSnackBar(
            context,
            isLiked ? '已关注项目' : '已取消关注',
            isLiked ? const Color(0xFF8B5CF6) : Colors.grey[700]!,
          );
          
        case Failure(exception: final error):
          // API 失败，回滚状态
          isFollowed.value = previousState;
          isToggling.value = false;
          _showSnackBar(context, '操作失败: ${error.message}', Colors.red[700]!);
      }
    } catch (e) {
      // 异常处理，回滚状态
      isFollowed.value = previousState;
      isToggling.value = false;
      _showSnackBar(context, '操作失败: $e', Colors.red[700]!);
    }
  }

  /// 跳转到编辑页面并处理返回
  Future<void> navigateToEdit(BuildContext context) async {
    final result = await Get.toNamed('/add-innovation', arguments: project);
    // 如果返回 true，说明编辑成功，刷新数据
    if (result == true) {
      loadFullProject();
    }
  }

  /// 创建发布者的 User 对象用于聊天
  User get creatorUser => User(
    id: project.userId.toString(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 15)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
