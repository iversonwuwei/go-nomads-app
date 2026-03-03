import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/features/innovation_project/domain/repositories/i_innovation_project_repository.dart';
import 'package:go_nomads_app/features/innovation_project/presentation/controllers/innovation_project_state_controller.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 创意项目列表页面控制器
class InnovationListPageController extends GetxController with WidgetsBindingObserver {
  late final InnovationProjectStateController? stateController;
  final RxBool controllerInitialized = false.obs;

  // 关注状态管理 - 用项目ID作为key
  final RxMap<String, bool> followedProjects = <String, bool>{}.obs;

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initController();
    _setupDataChangeListeners();

    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProjects(forceRefresh: true);
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    super.onClose();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('innovation_project', _handleDataChanged);
    log('✅ [InnovationListPageController] 数据变更监听器已设置');
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 忽略自己发出的事件（通过 source 判断）
    if (event.metadata?['source'] == 'list') {
      return;
    }

    log('🔔 [创新项目列表] 收到数据变更通知: ${event.entityId} (${event.changeType}), metadata: ${event.metadata}');

    switch (event.changeType) {
      case DataChangeType.created:
        // 新建项目，刷新列表
        loadProjects(forceRefresh: true);
        break;
      case DataChangeType.updated:
        // 项目更新，从 metadata 同步关注状态
        if (event.entityId != null && event.metadata != null) {
          _syncFollowStateFromEvent(event.entityId!, event.metadata!);
        }
        break;
      case DataChangeType.deleted:
        // 项目删除，从列表中移除
        if (event.entityId != null) {
          followedProjects.remove(event.entityId);
        }
        loadProjects(forceRefresh: true);
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        loadProjects(forceRefresh: true);
        break;
    }
  }

  /// 从事件 metadata 同步关注状态
  void _syncFollowStateFromEvent(String projectId, Map<String, dynamic> metadata) {
    if (metadata.containsKey('isFollowed')) {
      final isFollowed = metadata['isFollowed'] as bool;
      followedProjects[projectId] = isFollowed;
      log('🔄 [创新项目列表] 从事件同步关注状态: $projectId -> $isFollowed');
    }
  }

  // 上次恢复时间，避免频繁刷新
  DateTime? _lastResumeRefreshTime;
  static const _minResumeInterval = Duration(seconds: 30);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从后台恢复时刷新数据（最小间隔 30 秒避免频繁刷新）
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (_lastResumeRefreshTime == null ||
          now.difference(_lastResumeRefreshTime!) >= _minResumeInterval) {
        _lastResumeRefreshTime = now;
        loadProjects(forceRefresh: true);
      }
    }
  }

  /// 初始化 controller
  void _initController() {
    try {
      stateController = Get.find<InnovationProjectStateController>();
      controllerInitialized.value = true;
    } catch (e) {
      log('❌ InnovationProjectStateController 未注册: $e');
      controllerInitialized.value = false;
    }
  }

  /// 加载项目列表
  Future<void> loadProjects({bool forceRefresh = false}) async {
    if (controllerInitialized.value && stateController != null) {
      log('📱 开始加载项目列表...');
      await stateController!.getProjects(forceRefresh: forceRefresh);
      log('📱 加载完成，项目数量: ${stateController!.projects.length}');
      if (stateController!.errorMessage.value != null) {
        log('❌ 加载错误: ${stateController!.errorMessage.value}');
      }
    } else {
      log('❌ Controller 未初始化，无法加载数据');
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadProjects(forceRefresh: true);
  }

  /// 获取显示的项目列表
  List<InnovationProject> get displayProjects {
    if (controllerInitialized.value && stateController != null && stateController!.projects.isNotEmpty) {
      return stateController!.projects;
    }
    return _fallbackProjects;
  }

  /// 静态示例数据（作为备用）
  List<InnovationProject> get _fallbackProjects => [
        InnovationProject(
          id: 1,
          uuid: 'fallback-1',
          userId: 1,
          projectName: '智课通',
          elevatorPitch: '我们是面向大学生的AI学习伙伴，像私人tutor一样个性化辅导，但完全自动化且价格更低。',
          problem: '大学生备考四六级时缺乏个性化练习和及时反馈，导致复习效率低下、通过率不高。',
          solution: '我们开发了一款基于AI的备考App，能根据用户错题自动推荐学习路径，并生成每日训练计划，提升学习效率30%以上。',
          targetAudience: '主要用户：一二线城市的大二至大四本科生\n次要用户：考研学生、语言培训机构\n用户画像：年龄18-24岁，手机使用频繁，愿意为提分付费',
          productType: '微信小程序 + 后台管理系统',
          keyFeatures: '智能错题分析与知识点定位\n个性化每日学习任务推送\n模拟考试+成绩预测\n语音口语练习与评分\n学习进度可视化报告',
          competitiveAdvantage: '竞品A：题库大但无个性化推荐 → 我们有AI自适应引擎\n竞品B：价格高 → 我们采用订阅制，性价比更高\n我们的优势：团队有教育+AI背景，已获得某高校试点合作',
          businessModel: '基础功能免费，高级功能月费19元，支持学期/年费套餐',
          marketOpportunity: '中国大学生人数超3000万，每年四六级考生约1000万人次，备考工具市场规模预计2025年达50亿元。',
          currentStatus: '已完成MVP原型\n正在进行小范围内测（50名用户）\n已注册公司，申请软件著作权\n寻求种子轮融资50万元，用于产品迭代和推广',
          team: [
            TeamMember(name: '张三', role: 'CEO', description: '前腾讯产品经理，5年互联网经验'),
            TeamMember(name: '李四', role: 'CTO', description: '计算机硕士，擅长AI算法开发'),
          ],
          ask: '需要技术合伙人一起开发后端\n寻求天使投资50万，出让10%股权\n希望接入某平台API资源',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          userName: '张三',
        ),
      ];

  /// 获取项目的关注状态
  bool isProjectFollowed(String projectId, InnovationProject project) {
    return followedProjects.containsKey(projectId) ? followedProjects[projectId]! : project.isLiked;
  }

  /// 切换关注状态
  Future<void> toggleFollow(BuildContext context, String projectId) async {
    // 先乐观更新 UI
    final previousState = followedProjects[projectId] ?? false;
    followedProjects[projectId] = !previousState;

    // 调用 API
    try {
      final repository = Get.find<IInnovationProjectRepository>();
      final result = await repository.toggleLike(projectId);

      switch (result) {
        case Success(data: final isLiked):
          // API 成功，更新为服务器返回的状态
          followedProjects[projectId] = isLiked;
          // 显示提示
          AppToast.success(isLiked ? '已关注该项目' : '已取消关注');
          
          // 发送数据变更事件，通知其他页面（携带新的关注状态）
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'innovation_project',
            entityId: projectId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.updated,
            metadata: {'isFollowed': isLiked, 'source': 'list'},
          ));
          log('📤 [创新项目列表] 发送关注状态变更事件: $projectId -> $isLiked');

        case Failure(exception: final error):
          // API 失败，回滚状态
          followedProjects[projectId] = previousState;
          AppToast.error('操作失败: ${error.message}');
      }
    } catch (e) {
      // 异常处理，回滚状态
      followedProjects[projectId] = previousState;
      AppToast.error('操作失败: $e');
    }
  }

  /// 格式化日期
  String formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return '今天';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}周前';
    return '${(diff.inDays / 30).floor()}个月前';
  }
}
