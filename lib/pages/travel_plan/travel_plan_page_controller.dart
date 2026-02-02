import 'dart:developer';

import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_quota_service.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/async_task_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 旅行计划页面控制器
///
/// 管理:
/// - 旅行计划加载状态
/// - 进度显示
/// - 数据缓存
class TravelPlanPageController extends GetxController with GetSingleTickerProviderStateMixin {
  // 构造函数参数
  final TravelPlan? initialPlan;
  final String? planId;
  final String? cityId;
  final String? cityName;
  final int? duration;
  final String? budget;
  final String? travelStyle;
  final List<String>? interests;
  final String? departureLocation;
  final DateTime? departureDate;

  TravelPlanPageController({
    this.initialPlan,
    this.planId,
    this.cityId,
    this.cityName,
    this.duration,
    this.budget,
    this.travelStyle,
    this.interests,
    this.departureLocation,
    this.departureDate,
  });

  // ==================== 可观察状态 ====================

  /// 当前旅行计划
  final Rx<TravelPlan?> plan = Rx<TravelPlan?>(null);

  /// 是否正在加载
  final RxBool isLoading = true.obs;

  /// 进度消息
  final RxString progressMessage = '正在准备...'.obs;

  /// 进度值 (0-100)
  final RxInt progressValue = 0.obs;

  // ==================== 动画控制器 ====================

  late AnimationController shimmerController;

  // ==================== GetX 监听器 ====================

  final List<Worker> _workers = [];

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();

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
        AppToast.error('无法加载旅行计划');
        Get.back();
      }
    } catch (e) {
      log('❌ 加载旅行计划失败: $e');
      isLoading.value = false;
      AppToast.error('加载失败: $e');
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
      progressMessage.value = '正在连接 AI 服务...';
      progressValue.value = 0;

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
        interests: interests ?? [],
        departureLocation: departureLocation,
        departureDate: departureDate,
      );
    } catch (e) {
      log('❌ 生成旅行计划失败: $e');
      isLoading.value = false;
      AppToast.error('Error: $e');
      Get.back();
    }
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
        AppToast.success('Travel plan generated successfully!');
      }
    }));

    // 监听错误
    _workers.add(ever(aiController.travelPlanErrorRx, (error) {
      if (error != null) {
        isLoading.value = false;
        AppToast.error('Failed to generate: $error');
        Get.back();
      }
    }));
  }

  // ==================== 公开方法 ====================

  /// 获取出发地（优先使用计划中的，其次使用传入的）
  String? get effectiveDepartureLocation => plan.value?.departureLocation ?? departureLocation;
}
