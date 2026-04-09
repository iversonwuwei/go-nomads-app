import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_quota_service.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/repositories/i_migration_workspace_repository.dart';
import 'package:go_nomads_app/features/migration_workspace/infrastructure/repositories/migration_workspace_repository.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/travel_plan/travel_plan_page.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/openclaw_research_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/async_task_progress_dialog.dart';

/// 旅行计划页面控制器
///
/// 管理:
/// - 旅行计划加载状态
/// - 进度显示
/// - 数据缓存
class TravelPlanPageController extends GetxController with GetSingleTickerProviderStateMixin {
  static const Map<String, _TravelPlanReplanPreset> _replanPresets = {
    'remote-work': _TravelPlanReplanPreset(
      objective: 'work',
      request: '请把路线调成更适合远程工作，优先稳定共享办公、通勤效率和白天专注时段。',
      signals: ['coworking', 'transit', 'budget'],
    ),
    'save-budget': _TravelPlanReplanPreset(
      objective: 'hybrid',
      request: '请在不破坏整体体验的前提下压缩预算，优先降低住宿、交通和高溢价安排。',
      signals: ['budget', 'transit'],
    ),
    'more-explore': _TravelPlanReplanPreset(
      objective: 'explore',
      request: '请把路线调成更偏城市探索，增加街区漫游、本地活动和代表性地点。',
      signals: ['events', 'weather'],
    ),
    'weather-safe': _TravelPlanReplanPreset(
      objective: 'hybrid',
      request: '请按天气更稳妥地重排，把受天气影响大的项目做备选并优化当天动线。',
      signals: ['weather', 'transit'],
    ),
  };

  static const Map<String, _TravelPlanReplanPreset> _dayReplanPresets = {
    'lighter-day': _TravelPlanReplanPreset(
      objective: 'hybrid',
      request: '请把这一天调得更轻松，减少奔波和过密安排，保留1到2个真正值得去的点。',
      signals: ['weather', 'transit'],
    ),
    'work-first': _TravelPlanReplanPreset(
      objective: 'work',
      request: '请把这一天改成白天工作优先，保留稳定办公地点和高效率通勤，晚上再安排轻量活动。',
      signals: ['coworking', 'transit', 'budget'],
    ),
    'local-explore': _TravelPlanReplanPreset(
      objective: 'explore',
      request: '请把这一天改成更偏本地探索，减少打卡式景点，增加街区漫游、小店和在地体验。',
      signals: ['events', 'weather'],
    ),
    'rain-backup': _TravelPlanReplanPreset(
      objective: 'hybrid',
      request: '请为这一天按可能的雨天或高温情况重排，优先室内备选、短距离动线和天气兜底方案。',
      signals: ['weather', 'transit'],
    ),
  };

  // 构造函数参数
  final TravelPlan? initialPlan;
  final TravelPlan? baselinePlan;
  final String? planId;
  final String? cityId;
  final String? cityName;
  final int? duration;
  final String? budget;
  final String? travelStyle;
  final List<String>? interests;
  final String? departureLocation;
  final DateTime? departureDate;
  final TravelPlanSummary? initialWorkspaceSummary;

  TravelPlanPageController({
    this.initialPlan,
    this.baselinePlan,
    this.planId,
    this.cityId,
    this.cityName,
    this.duration,
    this.budget,
    this.travelStyle,
    this.interests,
    this.departureLocation,
    this.departureDate,
    this.initialWorkspaceSummary,
  });

  late final IMigrationWorkspaceRepository _workspaceRepository = Get.isRegistered<IMigrationWorkspaceRepository>()
      ? Get.find<IMigrationWorkspaceRepository>()
      : MigrationWorkspaceRepository(
          Get.isRegistered<HttpService>() ? Get.find<HttpService>() : HttpService(),
        );

  // ==================== 可观察状态 ====================

  /// 当前旅行计划
  final Rx<TravelPlan?> plan = Rx<TravelPlan?>(null);

  /// 当前迁移工作台摘要
  final Rx<TravelPlanSummary?> workspaceSummary = Rx<TravelPlanSummary?>(null);

  /// 是否正在加载
  final RxBool isLoading = true.obs;

  /// 是否正在保存工作台
  final RxBool isSavingWorkspace = false.obs;

  /// 进度消息
  final RxString progressMessage = '正在准备...'.obs;

  /// 进度值 (0-100)
  final RxInt progressValue = 0.obs;

  /// OpenClaw 研究结果
  final Rx<OpenClawResearchBrief?> researchBrief = Rx<OpenClawResearchBrief?>(null);

  // ==================== 动画控制器 ====================

  late AnimationController shimmerController;

  // ==================== GetX 监听器 ====================

  final List<Worker> _workers = [];

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();

    workspaceSummary.value = initialWorkspaceSummary;

    // 初始化动画控制器
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 初始化数据
    _initializeData();
  }

  @override
  void onClose() {
    shimmerController.dispose();

    // 取消所有 GetX 监听器
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();

    // 确保关闭任何残留的对话框
    AsyncTaskProgressDialog.dismiss();

    super.onClose();
  }

  // ==================== 私有方法 ====================

  /// 初始化数据
  void _initializeData() {
    if (initialPlan != null) {
      // 直接使用传入的计划
      plan.value = initialPlan;
      isLoading.value = false;
    } else if (planId != null) {
      // 从数据库加载已保存的旅行计划
      _loadPlanFromDatabase();
    } else {
      // 异步生成新计划
      _generatePlanAsync();
    }
  }

  /// 从数据库加载已保存的旅行计划
  Future<void> _loadPlanFromDatabase() async {
    final aiController = Get.find<AiStateController>();

    try {
      isLoading.value = true;
      progressMessage.value = '正在加载旅行计划...';
      progressValue.value = 50;

      final result = await aiController.getTravelPlanDetail(planId!);

      if (result != null) {
        plan.value = result;
        isLoading.value = false;
      } else {
        isLoading.value = false;
        AppToast.error(_l10n.travelPlanUnableToLoad);
        Get.back();
      }
    } catch (e) {
      log('❌ 加载旅行计划失败: $e');
      isLoading.value = false;
      AppToast.error(_l10n.travelPlanLoadFailedWithError(e.toString()));
      Get.back();
    }
  }

  /// 使用异步任务生成旅行计划
  Future<void> _generatePlanAsync() async {
    final aiController = Get.find<AiStateController>();

    // 检查 AI 配额
    final canUse = await AiQuotaService().checkAndUseAI(featureName: '旅行计划生成');
    if (!canUse) {
      Get.back();
      return;
    }

    try {
      isLoading.value = true;
      progressMessage.value = _initialProgressMessage;
      progressValue.value = 0;

      final effectiveInterests = await _prepareOpenClawResearch();

      // 设置 GetX 监听器
      _setupListeners(aiController);

      // 使用异步任务方式生成
      await aiController.generateTravelPlanStream(
        cityId: cityId ?? '',
        cityName: cityName ?? '',
        cityImage: '',
        duration: duration ?? 7,
        budget: budget ?? 'medium',
        travelStyle: travelStyle ?? 'culture',
        interests: effectiveInterests,
        departureLocation: departureLocation,
        departureDate: departureDate,
      );
    } catch (e) {
      log('❌ 生成旅行计划失败: $e');
      isLoading.value = false;
      AppToast.error(_l10n.travelPlanGenerateErrorWithError(e.toString()));
      Get.back();
    }
  }

  Future<void> saveWorkspaceState({
    required TravelPlanSummary plan,
    required String stage,
    String? focusNote,
    List<MigrationChecklistItem> checklist = const [],
    List<MigrationTimelineItem> timeline = const [],
  }) async {
    if (isSavingWorkspace.value) {
      return;
    }

    try {
      isSavingWorkspace.value = true;

      final result = await _workspaceRepository.savePlanState(
        planId: plan.id,
        stage: stage,
        focusNote: focusNote,
        checklist: checklist,
        timeline: timeline,
      );

      result.fold(
        onSuccess: (data) {
          final updatedPlan = data.plans.cast<TravelPlanSummary?>().firstWhere(
                (item) => item?.id == plan.id,
                orElse: () => null,
              );
          workspaceSummary.value = updatedPlan ??
              _mergeWorkspaceSummary(
                source: plan,
                stage: stage,
                focusNote: focusNote,
                checklist: checklist,
                timeline: timeline,
              );
          AppToast.success(_l10n.saveSuccess);
        },
        onFailure: (exception) {
          AppToast.error(_l10n.operationFailedWithError(exception.message));
        },
      );
    } catch (error) {
      log('❌ 保存迁移工作台失败: $error');
      AppToast.error(_l10n.operationFailedWithError(error.toString()));
    } finally {
      isSavingWorkspace.value = false;
    }
  }

  TravelPlanSummary _mergeWorkspaceSummary({
    required TravelPlanSummary source,
    required String stage,
    String? focusNote,
    required List<MigrationChecklistItem> checklist,
    required List<MigrationTimelineItem> timeline,
  }) {
    final completedTaskCount = checklist.where((item) => item.isCompleted).length;

    return TravelPlanSummary(
      id: source.id,
      cityId: source.cityId,
      cityName: source.cityName,
      cityImage: source.cityImage,
      duration: source.duration,
      budgetLevel: source.budgetLevel,
      travelStyle: source.travelStyle,
      status: source.status,
      departureDate: source.departureDate,
      createdAt: source.createdAt,
      migrationStage: stage,
      focusNote: focusNote,
      completedTaskCount: completedTaskCount,
      totalTaskCount: checklist.length,
      checklist: checklist,
      timeline: timeline,
    );
  }

  /// 设置 GetX 监听器
  void _setupListeners(AiStateController aiController) {
    // 清理之前的监听器
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();

    // 监听进度更新
    _workers.add(ever(aiController.travelPlanGenerationProgressRx, (progress) {
      progressValue.value = progress;
    }));

    // 监听进度消息更新
    _workers.add(ever(aiController.travelPlanGenerationMessageRx, (message) {
      progressMessage.value = message;
    }));

    // 监听任务完成，获取计划
    _workers.add(ever(aiController.currentTravelPlanRx, (result) {
      if (result != null) {
        plan.value = result;
        isLoading.value = false;
        AppToast.success(_l10n.travelPlanGeneratedSuccess);
      }
    }));

    // 监听错误
    _workers.add(ever(aiController.travelPlanErrorRx, (error) {
      if (error != null) {
        isLoading.value = false;
        AppToast.error(_l10n.travelPlanGenerateFailedWithError(error.toString()));
        Get.back();
      }
    }));
  }

  // ==================== 公开方法 ====================

  /// 获取出发地（优先使用计划中的，其次使用传入的）
  String? get effectiveDepartureLocation => plan.value?.departureLocation ?? departureLocation;

  List<String> get _effectiveInterestHints => plan.value?.metadata.interests ?? interests ?? const [];

  bool get shouldRunOpenClawResearch => planningModeKey == 'research' || researchSignalKeys.isNotEmpty;

  String get planningModeKey => _extractHintValue('openclaw_mode') ?? 'balanced';

  String get planningObjectiveKey => _extractHintValue('openclaw_goal') ?? 'hybrid';

  List<String> get researchSignalKeys => _effectiveInterestHints
      .where((item) => item.startsWith('openclaw_signal:'))
      .map((item) => item.split(':').last)
      .toList();

  bool get showsOpenClawResearchCard => planningModeKey == 'research' || researchSignalKeys.isNotEmpty;

  String get planningModeLabel {
    switch (planningModeKey) {
      case 'quick':
        return '快速草案';
      case 'research':
        return 'OpenClaw 研究增强';
      default:
        return '平衡规划';
    }
  }

  String get planningModeDescription {
    switch (planningModeKey) {
      case 'quick':
        return '优先更快给出成型路线，适合先确认节奏与大方向。';
      case 'research':
        return '把 OpenClaw 当成研究层，优先整理实时天气、活动、共享办公和预算校验等信号。';
      default:
        return '在出图速度、预算控制和目的地体验之间做平衡。';
    }
  }

  String get planningObjectiveLabel {
    switch (planningObjectiveKey) {
      case 'work':
        return '远程工作优先';
      case 'explore':
        return '城市探索优先';
      default:
        return '工作与玩平衡';
    }
  }

  String get replanScopeKey => _extractHintValue('openclaw_replan_scope') ?? 'trip';

  int? get replanTargetDay {
    final raw = _extractHintValue('openclaw_replan_day');
    return raw == null ? null : int.tryParse(raw);
  }

  String? get replanPeriodKey => _extractHintValue('openclaw_replan_period');

  String get replanScopeLabel {
    switch (replanScopeKey) {
      case 'day':
        return replanTargetDay == null ? '单天重排' : '第$replanTargetDay天';
      case 'day-period':
        final dayLabel = replanTargetDay == null ? '单天时段' : '第$replanTargetDay天';
        return '$dayLabel${_periodLabel(replanPeriodKey) ?? '局部时段'}';
      default:
        return '整趟行程';
    }
  }

  String get replanScopeDescription {
    switch (replanScopeKey) {
      case 'day':
        return '这次研究与生成主要围绕单天节奏重排，而不是重做整趟路线。';
      case 'day-period':
        return '这次研究与生成只聚焦一个时段，其他天与其他时段尽量保持稳定。';
      default:
        return '这次研究与生成面向整趟路线的整体取舍。';
    }
  }

  String? get currentReplanRequest => _extractHintValue('openclaw_replan');

  String? get currentReplanActivities => _extractHintValue('openclaw_day_activities');

  bool get hasReplanSummary => (currentReplanRequest ?? '').isNotEmpty;

  List<String> get activeResearchSignalLabels => researchSignalLabels;

  List<ReplanStrategyHighlight> get replanStrategyHighlights {
    final highlights = <ReplanStrategyHighlight>[];

    switch (planningObjectiveKey) {
      case 'work':
        highlights.add(
          const ReplanStrategyHighlight(
            text: '这次调整优先保护稳定办公环境、低干扰时段和可控通勤。',
            sourceKeys: ['objective', 'coworking', 'transit'],
          ),
        );
        break;
      case 'explore':
        highlights.add(
          const ReplanStrategyHighlight(
            text: '这次调整优先放大在地体验、街区漫游和更有代表性的探索节奏。',
            sourceKeys: ['objective', 'events'],
          ),
        );
        break;
      default:
        highlights.add(
          const ReplanStrategyHighlight(
            text: '这次调整会在工作效率、旅行体验和预算压力之间做平衡取舍。',
            sourceKeys: ['objective', 'budget'],
          ),
        );
        break;
    }

    switch (replanScopeKey) {
      case 'day-period':
        highlights.add(
          const ReplanStrategyHighlight(
            text: '这次只动一个时段，其他天和其他时段尽量保持稳定，避免整趟计划被过度重写。',
            sourceKeys: ['scope'],
          ),
        );
        break;
      case 'day':
        highlights.add(
          const ReplanStrategyHighlight(
            text: '这次只围绕单天节奏重排，整趟路线的大框架会尽量延续。',
            sourceKeys: ['scope'],
          ),
        );
        break;
      default:
        highlights.add(
          const ReplanStrategyHighlight(
            text: '这次是整趟行程级调整，会一起考虑路线顺序、预算和整体体验连贯性。',
            sourceKeys: ['scope', 'transit'],
          ),
        );
        break;
    }

    if (researchSignalKeys.contains('coworking')) {
      highlights.add(
        const ReplanStrategyHighlight(
          text: '研究层会额外关注共享办公可用性、停留舒适度和工作窗口。',
          sourceKeys: ['coworking'],
        ),
      );
    }
    if (researchSignalKeys.contains('events')) {
      highlights.add(
        const ReplanStrategyHighlight(
          text: '研究层会额外关注本地活动和夜间体验，避免错过更适合当前时段的内容。',
          sourceKeys: ['events'],
        ),
      );
    }
    if (researchSignalKeys.contains('weather')) {
      highlights.add(
        const ReplanStrategyHighlight(
          text: '研究层会额外校对天气风险，把室内备选、体感和天气波动纳入决策。',
          sourceKeys: ['weather'],
        ),
      );
    }
    if (researchSignalKeys.contains('transit')) {
      highlights.add(
        const ReplanStrategyHighlight(
          text: '研究层会额外压低折返和跨区移动，优先更顺路的动线。',
          sourceKeys: ['transit'],
        ),
      );
    }
    if (researchSignalKeys.contains('budget')) {
      highlights.add(
        const ReplanStrategyHighlight(
          text: '研究层会额外约束高溢价安排，优先保留性价比更高的活动组合。',
          sourceKeys: ['budget'],
        ),
      );
    }

    return highlights.take(4).toList();
  }

  List<ReplanImpactPreview> get replanImpactPreviews {
    final previews = <ReplanImpactPreview>[];
    final periodLabel = _periodLabel(replanPeriodKey);

    if (replanScopeKey == 'day-period') {
      previews.add(
        ReplanImpactPreview(
          title: '影响范围',
          detail: '本次会优先调整${replanTargetDay == null ? '当前目标日' : '第$replanTargetDay天'}${periodLabel ?? '当前时段'}的活动密度和动线。',
          sourceKeys: const ['scope'],
        ),
      );
    } else if (replanScopeKey == 'day') {
      previews.add(
        ReplanImpactPreview(
          title: '影响范围',
          detail: '本次会优先调整${replanTargetDay == null ? '当前目标日' : '第$replanTargetDay天'}的节奏安排，但尽量保留整趟路线框架。',
          sourceKeys: const ['scope'],
        ),
      );
    } else {
      previews.add(
        const ReplanImpactPreview(
          title: '影响范围',
          detail: '本次会从整趟路线层面重排顺序、预算与体验取舍，不只改某一个局部节点。',
          sourceKeys: ['scope', 'transit'],
        ),
      );
    }

    if (researchSignalKeys.contains('transit')) {
      previews.add(
        const ReplanImpactPreview(
          title: '动线变化',
          detail: '更可能减少折返、跨区跳跃和高摩擦通勤，把活动压回更顺路的串联。',
          sourceKeys: ['transit'],
        ),
      );
    }

    if (researchSignalKeys.contains('weather')) {
      previews.add(
        const ReplanImpactPreview(
          title: '天气兜底',
          detail: '更可能替换掉高天气风险节点，并补进室内备选或体感更稳的安排。',
          sourceKeys: ['weather'],
        ),
      );
    }

    if (researchSignalKeys.contains('events')) {
      previews.add(
        const ReplanImpactPreview(
          title: '活动偏移',
          detail: '更可能把路线往本地活动、夜间体验或更贴合当下时段的内容上拉。',
          sourceKeys: ['events'],
        ),
      );
    }

    if (researchSignalKeys.contains('coworking')) {
      previews.add(
        const ReplanImpactPreview(
          title: '工作窗口',
          detail: '更可能保留稳定办公点、可专注时段和工作前后的低成本通勤。',
          sourceKeys: ['coworking', 'objective'],
        ),
      );
    }

    if (researchSignalKeys.contains('budget')) {
      previews.add(
        const ReplanImpactPreview(
          title: '预算取舍',
          detail: '更可能压缩高溢价活动与不必要移动，把预算留给更关键的体验节点。',
          sourceKeys: ['budget'],
        ),
      );
    }

    return previews.take(4).toList();
  }

  String? get actualReplanDiffHeadline {
    final items = actualReplanDiffItems;
    if (items.isEmpty) {
      return null;
    }

    final replacementCount = items.where((item) => item.kind == ReplanActualDiffKind.replaced).length;
    final addedCount = items.where((item) => item.kind == ReplanActualDiffKind.added).length;
    final removedCount = items.where((item) => item.kind == ReplanActualDiffKind.removed).length;
    final dayCount = items.where((item) => item.kind == ReplanActualDiffKind.dayChanged).length;

    final summaryParts = <String>[];
    if (replacementCount > 0) {
      summaryParts.add('替换$replacementCount处');
    }
    if (addedCount > 0) {
      summaryParts.add('新增$addedCount项');
    }
    if (removedCount > 0) {
      summaryParts.add('删减$removedCount项');
    }
    if (dayCount > 0) {
      summaryParts.add('主题调整$dayCount天');
    }

    if (summaryParts.isEmpty) {
      return '目标范围内没有明显结构变化，当前更像细节微调。';
    }

    return '相对上一版，当前方案在目标范围内${summaryParts.join('，')}。';
  }

  List<ReplanActualDiffItem> get actualReplanDiffItems {
    final previousPlan = baselinePlan;
    final currentPlan = plan.value;
    if (previousPlan == null || currentPlan == null || !hasReplanSummary) {
      return const [];
    }

    final previousDays = _daysForScope(previousPlan, replanTargetDay);
    final currentDays = _daysForScope(currentPlan, replanTargetDay);

    final items = <ReplanActualDiffItem>[];
    final previousDayMap = {for (final day in previousDays) day.day: day};

    for (final day in currentDays) {
      final oldDay = previousDayMap[day.day];
      if (oldDay == null) {
        continue;
      }

      if (_normalizeText(oldDay.theme) != _normalizeText(day.theme)) {
        items.add(
          ReplanActualDiffItem(
            title: '第${day.day}天主题调整',
            detail: '从“${oldDay.theme}”改为“${day.theme}”。',
            kind: ReplanActualDiffKind.dayChanged,
          ),
        );
      }
    }

    final previousRefs = _activityRefsForScope(previousPlan, replanTargetDay, replanPeriodKey);
    final currentRefs = _activityRefsForScope(currentPlan, replanTargetDay, replanPeriodKey);

    final previousBySlot = {for (final item in previousRefs) item.slotKey: item};
    final currentBySlot = {for (final item in currentRefs) item.slotKey: item};
    final consumedPreviousIds = <String>{};
    final consumedCurrentIds = <String>{};

    for (final entry in currentBySlot.entries) {
      final oldItem = previousBySlot[entry.key];
      final newItem = entry.value;
      if (oldItem == null) {
        continue;
      }
      if (oldItem.signature == newItem.signature) {
        consumedPreviousIds.add(oldItem.uniqueKey);
        consumedCurrentIds.add(newItem.uniqueKey);
        continue;
      }

      consumedPreviousIds.add(oldItem.uniqueKey);
      consumedCurrentIds.add(newItem.uniqueKey);
      items.add(
        ReplanActualDiffItem(
          title: _scopeChangeTitle(newItem.day, newItem.periodKey),
          detail:
              '把 ${oldItem.activity.name} 调整为 ${newItem.activity.name}${_locationSuffix(newItem.activity.location)}。',
          kind: ReplanActualDiffKind.replaced,
        ),
      );
    }

    final remainingPrevious = previousRefs.where((item) => !consumedPreviousIds.contains(item.uniqueKey)).toList();
    final remainingCurrent = currentRefs.where((item) => !consumedCurrentIds.contains(item.uniqueKey)).toList();

    final previousSignatureCounts = <String, int>{};
    for (final item in remainingPrevious) {
      previousSignatureCounts[item.signature] = (previousSignatureCounts[item.signature] ?? 0) + 1;
    }

    final currentSignatureCounts = <String, int>{};
    for (final item in remainingCurrent) {
      currentSignatureCounts[item.signature] = (currentSignatureCounts[item.signature] ?? 0) + 1;
    }

    final comparableSignatures = {...previousSignatureCounts.keys, ...currentSignatureCounts.keys};
    for (final signature in comparableSignatures) {
      final overlap = _min(previousSignatureCounts[signature] ?? 0, currentSignatureCounts[signature] ?? 0);
      if (overlap == 0) {
        continue;
      }
      previousSignatureCounts[signature] = (previousSignatureCounts[signature] ?? 0) - overlap;
      currentSignatureCounts[signature] = (currentSignatureCounts[signature] ?? 0) - overlap;
    }

    for (final item in remainingCurrent) {
      final remaining = currentSignatureCounts[item.signature] ?? 0;
      if (remaining <= 0) {
        continue;
      }
      currentSignatureCounts[item.signature] = remaining - 1;
      items.add(
        ReplanActualDiffItem(
          title: _scopeChangeTitle(item.day, item.periodKey),
          detail: '新增 ${item.activity.name}${_locationSuffix(item.activity.location)}。',
          kind: ReplanActualDiffKind.added,
        ),
      );
    }

    for (final item in remainingPrevious) {
      final remaining = previousSignatureCounts[item.signature] ?? 0;
      if (remaining <= 0) {
        continue;
      }
      previousSignatureCounts[item.signature] = remaining - 1;
      items.add(
        ReplanActualDiffItem(
          title: _scopeChangeTitle(item.day, item.periodKey),
          detail: '移除 ${item.activity.name}${_locationSuffix(item.activity.location)}。',
          kind: ReplanActualDiffKind.removed,
        ),
      );
    }

    if (items.isEmpty) {
      return const [
        ReplanActualDiffItem(
          title: '实际变化',
          detail: '目标范围内没有明显结构变化，当前更像顺序、表述或细节上的微调。',
          kind: ReplanActualDiffKind.unchanged,
        ),
      ];
    }

    return items.take(6).toList();
  }

  List<String> strategySourceLabels(List<String> keys) {
    return keys.map(_strategySourceLabel).toSet().toList();
  }

  String _strategySourceLabel(String key) {
    switch (key) {
      case 'objective':
        return '目标';
      case 'scope':
        return '范围';
      default:
        return _researchSignalLabel(key);
    }
  }

  bool isHighlightedDay(DailyItinerary dayItinerary) {
    if (replanScopeKey == 'trip') {
      return false;
    }

    return replanTargetDay == dayItinerary.day;
  }

  String? highlightedPeriodKeyForDay(DailyItinerary dayItinerary) {
    if (!isHighlightedDay(dayItinerary) || replanScopeKey != 'day-period') {
      return null;
    }

    return replanPeriodKey;
  }

  List<String> availablePeriodKeysForDay(DailyItinerary dayItinerary) {
    const orderedKeys = ['morning', 'afternoon', 'evening'];
    final available = orderedKeys.where((key) {
      return dayItinerary.activities.any((activity) => _matchesPeriod(activity.time, key));
    }).toList();

    return available.isEmpty ? orderedKeys : available;
  }

  List<PlannedActivity> previewActivitiesForScope(DailyItinerary dayItinerary, String? targetPeriod) {
    return _activitiesForScope(dayItinerary, targetPeriod);
  }

  String periodLabelOrDefault(String? key) => _periodLabel(key) ?? '全天';

  List<String> get researchSignalLabels => researchSignalKeys.map(_researchSignalLabel).toList();

  String? get openClawSummary => researchBrief.value?.summary ?? _extractHintValue('openclaw_summary');

  List<String> get openClawInsights {
    if (researchBrief.value != null) {
      return researchBrief.value!.insights;
    }

    return _extractMultiHints('openclaw_insight');
  }

  List<String> get openClawChecks {
    if (researchBrief.value != null) {
      return researchBrief.value!.checks;
    }

    return _extractMultiHints('openclaw_check');
  }

  String get effectiveCityId => plan.value?.destination.cityId ?? cityId ?? '';

  String get effectiveCityName => plan.value?.destination.cityName ?? cityName ?? '';

  int get effectiveDuration => plan.value?.metadata.duration ?? duration ?? 7;

  String get effectiveBudgetKey => budget ?? plan.value?.metadata.budgetLevel.name ?? 'medium';

  String get effectiveTravelStyleKey => travelStyle ?? plan.value?.metadata.style.name ?? 'culture';

  DateTime? get effectiveDepartureDate => plan.value?.departureDate ?? departureDate;

  bool get canReplan => effectiveCityId.isNotEmpty && effectiveCityName.isNotEmpty;

  String get _initialProgressMessage {
    switch (planningModeKey) {
      case 'quick':
        return '快速模式：正在压缩偏好并准备草案...';
      case 'research':
        return 'OpenClaw 研究增强：正在整理实时信号与任务重点...';
      default:
        return '平衡模式：正在连接 AI 服务并组合路线策略...';
    }
  }

  String? _extractHintValue(String prefix) {
    for (final item in _effectiveInterestHints) {
      if (item.startsWith('$prefix:')) {
        return item.substring(prefix.length + 1);
      }
    }
    return null;
  }

  List<String> _extractMultiHints(String prefix) {
    return _effectiveInterestHints
        .where((item) => item.startsWith('$prefix:'))
        .map((item) => item.substring(prefix.length + 1).trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<List<String>> _prepareOpenClawResearch() async {
    final baseInterests = [...(interests ?? const <String>[])];

    if (!shouldRunOpenClawResearch) {
      return baseInterests;
    }

    progressMessage.value = 'OpenClaw 研究增强：正在连接研究代理...';
    progressValue.value = 8;

    final brief = await OpenClawResearchService().researchTravelPlan(
      cityName: cityName ?? '',
      duration: duration ?? 7,
      budget: budget ?? 'medium',
      travelStyle: travelStyle ?? 'culture',
      planningMode: planningModeKey,
      planningObjective: planningObjectiveKey,
      researchSignals: researchSignalKeys,
      interests: baseInterests.where((item) => !item.startsWith('openclaw_')).toList(),
      departureLocation: departureLocation,
      departureDate: departureDate,
    );

    if (brief == null) {
      progressMessage.value = 'OpenClaw 当前不可用，已回退到常规 AI 规划...';
      progressValue.value = 12;
      return baseInterests;
    }

    researchBrief.value = brief;
    progressMessage.value = 'OpenClaw 已完成预研究，正在交给 AI 生成路线...';
    progressValue.value = 15;

    return [
      ...baseInterests,
      ...brief.toInterestHints(),
    ];
  }

  void replanWithPreset(String presetKey) {
    final preset = _replanPresets[presetKey];
    if (preset == null) {
      AppToast.error('暂不支持这个重规划动作');
      return;
    }

    _navigateToReplannedPage(
      customRequest: preset.request,
      objective: preset.objective,
      signals: preset.signals,
    );
  }

  void replanWithPrompt(String prompt) {
    final normalized = prompt.trim();
    if (normalized.isEmpty) {
      AppToast.error('请先输入你想调整的方向');
      return;
    }

    _navigateToReplannedPage(
      customRequest: normalized,
      objective: planningObjectiveKey,
      signals: researchSignalKeys.isEmpty ? const ['events', 'weather'] : researchSignalKeys,
    );
  }

  void replanDayWithPreset(DailyItinerary dayItinerary, String presetKey) {
    replanDayPeriodWithPreset(dayItinerary, presetKey, targetPeriod: null);
  }

  void replanDayPeriodWithPreset(
    DailyItinerary dayItinerary,
    String presetKey, {
    String? targetPeriod,
  }) {
    final preset = _resolveDayPresetForScope(presetKey, targetPeriod);
    if (preset == null) {
      AppToast.error('暂不支持这个按天重排动作');
      return;
    }

    _navigateToReplannedPage(
      customRequest: _composeDaySpecificRequest(dayItinerary, preset.request, targetPeriod: targetPeriod),
      objective: preset.objective,
      signals: preset.signals,
      targetDay: dayItinerary,
      targetPeriod: targetPeriod,
    );
  }

  _TravelPlanReplanPreset? _resolveDayPresetForScope(String presetKey, String? targetPeriod) {
    final base = _dayReplanPresets[presetKey];
    if (base == null || targetPeriod == null) {
      return base;
    }

    switch (presetKey) {
      case 'lighter-day':
        switch (targetPeriod) {
          case 'morning':
            return const _TravelPlanReplanPreset(
              objective: 'hybrid',
              request: '请把这个上午调得更轻一点，减少赶场和跨区移动，优先保留顺路且恢复成本低的安排。',
              signals: ['transit', 'budget'],
            );
          case 'afternoon':
            return const _TravelPlanReplanPreset(
              objective: 'hybrid',
              request: '请把这个下午调得更松弛，降低活动密度，给休息、吃饭和临时调整留出缓冲。',
              signals: ['weather', 'transit'],
            );
          case 'evening':
            return const _TravelPlanReplanPreset(
              objective: 'hybrid',
              request: '请把这个晚上收得更轻松，少折返、少排队，优先低压力且容易返程的安排。',
              signals: ['transit', 'budget'],
            );
        }
        return base;
      case 'work-first':
        switch (targetPeriod) {
          case 'morning':
            return const _TravelPlanReplanPreset(
              objective: 'work',
              request: '请把这个上午改成深度工作优先，优先稳定共享办公、低干扰环境和准时进入专注时段。',
              signals: ['coworking', 'transit'],
            );
          case 'afternoon':
            return const _TravelPlanReplanPreset(
              objective: 'work',
              request: '请把这个下午改成工作块优先，保留持续办公能力，同时兼顾午后通勤和补给便利。',
              signals: ['coworking', 'budget', 'transit'],
            );
          case 'evening':
            return const _TravelPlanReplanPreset(
              objective: 'work',
              request: '请把这个晚上改成低负担收尾模式，优先处理轻量工作、安静环境和第二天恢复节奏。',
              signals: ['coworking', 'budget'],
            );
        }
        return base;
      case 'local-explore':
        switch (targetPeriod) {
          case 'morning':
            return const _TravelPlanReplanPreset(
              objective: 'explore',
              request: '请把这个上午改成更适合慢速在地探索，优先咖啡馆、街区散步和低门槛体验。',
              signals: ['weather', 'transit'],
            );
          case 'afternoon':
            return const _TravelPlanReplanPreset(
              objective: 'explore',
              request: '请把这个下午改成更偏本地探索，优先街区漫游、小店停留和有代表性的在地体验。',
              signals: ['events', 'weather'],
            );
          case 'evening':
            return const _TravelPlanReplanPreset(
              objective: 'explore',
              request: '请把这个晚上改成更有夜间氛围的本地体验，优先夜市、夜景散步和本地活动。',
              signals: ['events', 'transit'],
            );
        }
        return base;
      case 'rain-backup':
        switch (targetPeriod) {
          case 'morning':
            return const _TravelPlanReplanPreset(
              objective: 'hybrid',
              request: '请给这个上午做天气兜底，优先室内备选、短动线和受天气影响小的安排。',
              signals: ['weather', 'transit'],
            );
          case 'afternoon':
            return const _TravelPlanReplanPreset(
              objective: 'hybrid',
              request: '请给这个下午做天气兜底，重点规避暴晒、阵雨和高体力活动带来的波动。',
              signals: ['weather', 'budget', 'transit'],
            );
          case 'evening':
            return const _TravelPlanReplanPreset(
              objective: 'hybrid',
              request: '请给这个晚上做天气兜底，优先室内夜间备选、返程方便和安全稳定的节奏。',
              signals: ['weather', 'transit', 'events'],
            );
        }
        return base;
      default:
        return base;
    }
  }

  void replanDayWithPrompt(DailyItinerary dayItinerary, String prompt) {
    replanDayPeriodWithPrompt(dayItinerary, prompt, targetPeriod: null);
  }

  void replanDayPeriodWithPrompt(
    DailyItinerary dayItinerary,
    String prompt, {
    String? targetPeriod,
  }) {
    final normalized = prompt.trim();
    if (normalized.isEmpty) {
      AppToast.error('请先输入这一天要怎么调整');
      return;
    }

    _navigateToReplannedPage(
      customRequest: _composeDaySpecificRequest(dayItinerary, normalized, targetPeriod: targetPeriod),
      objective: planningObjectiveKey,
      signals: researchSignalKeys.isEmpty ? const ['weather', 'events'] : researchSignalKeys,
      targetDay: dayItinerary,
      targetPeriod: targetPeriod,
    );
  }

  void _navigateToReplannedPage({
    required String customRequest,
    required String objective,
    required List<String> signals,
    DailyItinerary? targetDay,
    String? targetPeriod,
  }) {
    if (!canReplan) {
      AppToast.error('当前行程缺少城市信息，无法重规划');
      return;
    }

    final nextInterests = _buildReplanInterests(
      customRequest: customRequest,
      objective: objective,
      signals: signals,
      targetDay: targetDay,
      targetPeriod: targetPeriod,
    );

    Get.off(
      () => TravelPlanPage(
        instanceTag: 'travel_plan_${DateTime.now().microsecondsSinceEpoch}',
        baselinePlan: plan.value,
        cityId: effectiveCityId,
        cityName: effectiveCityName,
        duration: effectiveDuration,
        budget: effectiveBudgetKey,
        travelStyle: effectiveTravelStyleKey,
        interests: nextInterests,
        departureLocation: effectiveDepartureLocation,
        departureDate: effectiveDepartureDate,
      ),
      transition: Transition.rightToLeft,
    );
  }

  List<String> _buildReplanInterests({
    required String customRequest,
    required String objective,
    required List<String> signals,
    DailyItinerary? targetDay,
    String? targetPeriod,
  }) {
    final preserved = _effectiveInterestHints.where((item) {
      return !item.startsWith('openclaw_summary:') &&
          !item.startsWith('openclaw_insight:') &&
          !item.startsWith('openclaw_check:') &&
          !item.startsWith('openclaw_replan:') &&
          !item.startsWith('openclaw_replan_scope:') &&
          !item.startsWith('openclaw_replan_day:') &&
          !item.startsWith('openclaw_replan_period:') &&
          !item.startsWith('openclaw_day_theme:') &&
          !item.startsWith('openclaw_day_activities:') &&
          !item.startsWith('openclaw_mode:') &&
          !item.startsWith('openclaw_goal:') &&
          !item.startsWith('openclaw_signal:');
    }).toList();

    final scopedActivities = _activitiesForScope(targetDay, targetPeriod);
    final dayActivities = scopedActivities.map((item) => item.name).take(4).join(' / ');

    return [
      ...preserved,
      'openclaw_mode:research',
      'openclaw_goal:$objective',
      ...signals.toSet().map((signal) => 'openclaw_signal:$signal'),
      'openclaw_replan_scope:${targetDay == null ? 'trip' : (targetPeriod == null ? 'day' : 'day-period')}',
      if (targetDay != null) 'openclaw_replan_day:${targetDay.day}',
      if (targetPeriod != null) 'openclaw_replan_period:$targetPeriod',
      if (targetDay != null) 'openclaw_day_theme:${targetDay.theme}',
      if (dayActivities.isNotEmpty) 'openclaw_day_activities:$dayActivities',
      'openclaw_replan:$customRequest',
      if ((openClawSummary ?? '').isNotEmpty) 'openclaw_summary:${openClawSummary!}',
      ...openClawInsights.take(2).map((item) => 'openclaw_insight:$item'),
      ...openClawChecks.take(2).map((item) => 'openclaw_check:$item'),
    ];
  }

  String _composeDaySpecificRequest(
    DailyItinerary dayItinerary,
    String request, {
    String? targetPeriod,
  }) {
    final scopedActivities = _activitiesForScope(dayItinerary, targetPeriod);
    final activities = scopedActivities.map((item) => item.name).take(4).join('、');
    final notes = dayItinerary.notes?.trim();
    final periodLabel = _periodLabel(targetPeriod);
    final buffer = StringBuffer()
      ..write('请只重排第${dayItinerary.day}天')
      ..write(periodLabel == null ? '。' : '的$periodLabel。')
      ..write('当前主题是“${dayItinerary.theme}”。');

    if (activities.isNotEmpty) {
      buffer.write(periodLabel == null ? '当前活动包括：$activities。' : '当前$periodLabel活动包括：$activities。');
    }

    if (notes != null && notes.isNotEmpty) {
      buffer.write('当前备注：$notes。');
    }

    buffer.write(request);
    return buffer.toString();
  }

  List<PlannedActivity> _activitiesForScope(DailyItinerary? dayItinerary, String? targetPeriod) {
    if (dayItinerary == null) {
      return const [];
    }

    if (targetPeriod == null) {
      return dayItinerary.activities;
    }

    final filtered = dayItinerary.activities.where((item) => _matchesPeriod(item.time, targetPeriod)).toList();
    return filtered.isEmpty ? dayItinerary.activities : filtered;
  }

  List<DailyItinerary> _daysForScope(TravelPlan sourcePlan, int? targetDay) {
    if (targetDay == null) {
      return sourcePlan.dailyItineraries;
    }

    return sourcePlan.dailyItineraries.where((item) => item.day == targetDay).toList();
  }

  List<_ScopedActivityRef> _activityRefsForScope(
    TravelPlan sourcePlan,
    int? targetDay,
    String? targetPeriod,
  ) {
    final refs = <_ScopedActivityRef>[];
    for (final day in _daysForScope(sourcePlan, targetDay)) {
      final scopedActivities = _activitiesForScope(day, targetPeriod);
      for (final activity in scopedActivities) {
        final periodKey = targetPeriod ?? _inferPeriodKey(activity.time);
        refs.add(
          _ScopedActivityRef(
            day: day.day,
            periodKey: periodKey,
            activity: activity,
          ),
        );
      }
    }
    return refs;
  }

  String _scopeChangeTitle(int day, String? periodKey) {
    final periodLabel = _periodLabel(periodKey);
    return periodLabel == null ? '第$day天调整' : '第$day天$periodLabel调整';
  }

  String _locationSuffix(String location) {
    final normalized = location.trim();
    if (normalized.isEmpty) {
      return '';
    }
    return ' @ $normalized';
  }

  String _inferPeriodKey(String rawTime) {
    for (final key in const ['morning', 'afternoon', 'evening']) {
      if (_matchesPeriod(rawTime, key)) {
        return key;
      }
    }
    return 'day';
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }

  int _min(int left, int right) => left < right ? left : right;

  bool _matchesPeriod(String rawTime, String targetPeriod) {
    final normalized = rawTime.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    if (normalized.contains('上午') || normalized.contains('早上') || normalized.contains('morning')) {
      return targetPeriod == 'morning';
    }
    if (normalized.contains('下午') || normalized.contains('午后') || normalized.contains('afternoon')) {
      return targetPeriod == 'afternoon';
    }
    if (normalized.contains('晚上') ||
        normalized.contains('夜间') ||
        normalized.contains('傍晚') ||
        normalized.contains('evening') ||
        normalized.contains('night')) {
      return targetPeriod == 'evening';
    }

    final match = RegExp(r'(\d{1,2})[:：]?(\d{2})?').firstMatch(normalized);
    final hour = int.tryParse(match?.group(1) ?? '');
    if (hour == null) {
      return false;
    }

    if (hour < 12) {
      return targetPeriod == 'morning';
    }
    if (hour < 18) {
      return targetPeriod == 'afternoon';
    }
    return targetPeriod == 'evening';
  }

  String? _periodLabel(String? targetPeriod) {
    switch (targetPeriod) {
      case 'morning':
        return '上午';
      case 'afternoon':
        return '下午';
      case 'evening':
        return '晚上';
      default:
        return null;
    }
  }

  String _researchSignalLabel(String key) {
    switch (key) {
      case 'weather':
        return '实时天气';
      case 'events':
        return '本周活动';
      case 'coworking':
        return '共享办公';
      case 'transit':
        return '交通换乘';
      case 'visa':
        return '签证与入境';
      case 'budget':
        return '预算校验';
      default:
        return key;
    }
  }
}

class _TravelPlanReplanPreset {
  final String objective;
  final String request;
  final List<String> signals;

  const _TravelPlanReplanPreset({
    required this.objective,
    required this.request,
    required this.signals,
  });
}

class ReplanStrategyHighlight {
  final String text;
  final List<String> sourceKeys;

  const ReplanStrategyHighlight({
    required this.text,
    required this.sourceKeys,
  });
}

class ReplanImpactPreview {
  final String title;
  final String detail;
  final List<String> sourceKeys;

  const ReplanImpactPreview({
    required this.title,
    required this.detail,
    required this.sourceKeys,
  });
}

enum ReplanActualDiffKind {
  replaced,
  added,
  removed,
  dayChanged,
  unchanged,
}

class ReplanActualDiffItem {
  final String title;
  final String detail;
  final ReplanActualDiffKind kind;

  const ReplanActualDiffItem({
    required this.title,
    required this.detail,
    required this.kind,
  });
}

class _ScopedActivityRef {
  final int day;
  final String? periodKey;
  final PlannedActivity activity;

  const _ScopedActivityRef({
    required this.day,
    required this.periodKey,
    required this.activity,
  });

  String get signature => '${_normalize(activity.name)}|${_normalize(activity.time)}|${_normalize(activity.location)}';

  String get slotKey => '$day|${_normalize(activity.time)}';

  String get uniqueKey => '$slotKey|$signature';

  static String _normalize(String value) => value.trim().toLowerCase();
}
