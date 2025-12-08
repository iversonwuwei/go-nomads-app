import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/application/use_cases/ai_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:df_admin_mobile/features/city/infrastructure/models/city_detail_dto.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:get/get.dart';

/// AI功能状态控制器
///
/// 管理:
/// - 旅行计划生成 (标准和流式)
/// - 数字游民指南生成 (标准和流式)
/// - 数字游民指南从后端加载
/// - 旅行计划检索
/// - 附近城市生成和加载
/// - SignalR 实时更新订阅
class AiStateController extends GetxController {
  // Use Cases
  final GenerateTravelPlanUseCase _generateTravelPlanUseCase;
  final GenerateTravelPlanStreamUseCase _generateTravelPlanStreamUseCase;
  final GetTravelPlanByIdUseCase _getTravelPlanByIdUseCase;
  final GenerateDigitalNomadGuideStreamUseCase
      _generateDigitalNomadGuideStreamUseCase;
  final GetDigitalNomadGuideUseCase _getDigitalNomadGuideUseCase;
  final GetUserTravelPlansUseCase _getUserTravelPlansUseCase;
  final GetTravelPlanDetailUseCase _getTravelPlanDetailUseCase;
  final GetNearbyCitiesUseCase _getNearbyCitiesUseCase;
  final GenerateNearbyCitiesStreamUseCase _generateNearbyCitiesStreamUseCase;

  AiStateController(
    this._generateTravelPlanUseCase,
    this._generateTravelPlanStreamUseCase,
    this._getTravelPlanByIdUseCase,
    this._generateDigitalNomadGuideStreamUseCase,
    this._getDigitalNomadGuideUseCase,
    this._getUserTravelPlansUseCase,
    this._getTravelPlanDetailUseCase,
    this._getNearbyCitiesUseCase,
    this._generateNearbyCitiesStreamUseCase,
  );

  // ==================== 可观察状态 ====================

  // 旅行计划状态
  final _isGeneratingTravelPlan = false.obs;
  final _travelPlanGenerationProgress = 0.obs;
  final _travelPlanGenerationMessage = ''.obs;
  final _currentTravelPlan = Rx<TravelPlan?>(null);
  final _travelPlanError = Rx<String?>(null);

  // 数字游民指南状态
  final _isGeneratingGuide = false.obs;
  final _guideGenerationProgress = 0.obs;
  final _guideGenerationMessage = ''.obs;
  final _isGuideCompleted = false.obs; // 任务是否已完成（100%）
  final _currentGuide = Rx<DigitalNomadGuide?>(null);
  final _guideError = Rx<String?>(null);
  final _isLoadingGuide = false.obs; // 从后端API加载中

  // 用户旅行计划列表状态
  final _userTravelPlans = <TravelPlanSummary>[].obs;
  final _isLoadingUserPlans = false.obs;
  final _userPlansError = Rx<String?>(null);

  // 附近城市状态
  final _nearbyCities = <NearbyCityDto>[].obs;
  final _isLoadingNearbyCities = false.obs;
  final _isGeneratingNearbyCities = false.obs;
  final _nearbyCitiesGenerationProgress = 0.obs;
  final _nearbyCitiesGenerationMessage = ''.obs;
  final _isNearbyCitiesCompleted = false.obs;
  final _nearbyCitiesError = Rx<String?>(null);

  // ==================== Getters ====================

  // 旅行计划
  bool get isGeneratingTravelPlan => _isGeneratingTravelPlan.value;
  RxBool get isGeneratingTravelPlanRx => _isGeneratingTravelPlan;
  int get travelPlanGenerationProgress => _travelPlanGenerationProgress.value;
  RxInt get travelPlanGenerationProgressRx => _travelPlanGenerationProgress;
  String get travelPlanGenerationMessage => _travelPlanGenerationMessage.value;
  RxString get travelPlanGenerationMessageRx => _travelPlanGenerationMessage;
  TravelPlan? get currentTravelPlan => _currentTravelPlan.value;
  Rx<TravelPlan?> get currentTravelPlanRx => _currentTravelPlan;
  String? get travelPlanError => _travelPlanError.value;
  Rx<String?> get travelPlanErrorRx => _travelPlanError;

  // 数字游民指南
  bool get isGeneratingGuide => _isGeneratingGuide.value;
  RxBool get isGeneratingGuideRx => _isGeneratingGuide; // 暴露 Rx 对象用于监听
  int get guideGenerationProgress => _guideGenerationProgress.value;
  RxInt get guideGenerationProgressRx =>
      _guideGenerationProgress; // 暴露 Rx 对象用于监听进度
  String get guideGenerationMessage => _guideGenerationMessage.value;
  bool get isGuideCompleted => _isGuideCompleted.value;
  RxBool get isGuideCompletedRx => _isGuideCompleted; // 暴露完成状态
  DigitalNomadGuide? get currentGuide => _currentGuide.value;
  String? get guideError => _guideError.value;
  bool get isLoadingGuide => _isLoadingGuide.value;

  // 用户旅行计划列表
  List<TravelPlanSummary> get userTravelPlans => _userTravelPlans;
  RxList<TravelPlanSummary> get userTravelPlansRx => _userTravelPlans;
  bool get isLoadingUserPlans => _isLoadingUserPlans.value;
  RxBool get isLoadingUserPlansRx => _isLoadingUserPlans;
  String? get userPlansError => _userPlansError.value;
  TravelPlanSummary? get latestTravelPlan => _userTravelPlans.isNotEmpty ? _userTravelPlans.first : null;

  // 附近城市
  List<NearbyCityDto> get nearbyCities => _nearbyCities;
  RxList<NearbyCityDto> get nearbyCitiesRx => _nearbyCities;
  bool get isLoadingNearbyCities => _isLoadingNearbyCities.value;
  RxBool get isLoadingNearbyCitiesRx => _isLoadingNearbyCities;
  bool get isGeneratingNearbyCities => _isGeneratingNearbyCities.value;
  RxBool get isGeneratingNearbyCitiesRx => _isGeneratingNearbyCities;
  int get nearbyCitiesGenerationProgress => _nearbyCitiesGenerationProgress.value;
  RxInt get nearbyCitiesGenerationProgressRx => _nearbyCitiesGenerationProgress;
  String get nearbyCitiesGenerationMessage => _nearbyCitiesGenerationMessage.value;
  bool get isNearbyCitiesCompleted => _isNearbyCitiesCompleted.value;
  RxBool get isNearbyCitiesCompletedRx => _isNearbyCitiesCompleted;
  String? get nearbyCitiesError => _nearbyCitiesError.value;

  // ==================== 业务方法 ====================

  /// 获取用户旅行计划列表
  Future<List<TravelPlanSummary>> loadUserTravelPlans({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      log('📋 [loadUserTravelPlans] 加载用户旅行计划列表...');
      _isLoadingUserPlans.value = true;
      _userPlansError.value = null;

      final result = await _getUserTravelPlansUseCase.execute(
        GetUserTravelPlansParams(page: page, pageSize: pageSize),
      );

      return result.fold(
        onSuccess: (plans) {
          log('✅ [loadUserTravelPlans] 获取到 ${plans.length} 个旅行计划');
          _userTravelPlans.assignAll(plans);
          _isLoadingUserPlans.value = false;
          return plans;
        },
        onFailure: (failure) {
          log('❌ [loadUserTravelPlans] 加载失败: ${failure.message}');
          _userPlansError.value = failure.message;
          _isLoadingUserPlans.value = false;
          return [];
        },
      );
    } catch (e) {
      log('❌ [loadUserTravelPlans] 异常: $e');
      _userPlansError.value = e.toString();
      _isLoadingUserPlans.value = false;
      return [];
    }
  }

  /// 获取旅行计划详情（从数据库）
  Future<TravelPlan?> getTravelPlanDetail(String planId) async {
    try {
      log('📋 [getTravelPlanDetail] 获取旅行计划详情: planId=$planId');

      final result = await _getTravelPlanDetailUseCase.execute(
        GetTravelPlanDetailParams(planId: planId),
      );

      return result.fold(
        onSuccess: (plan) {
          log('✅ [getTravelPlanDetail] 获取成功');
          _currentTravelPlan.value = plan;
          return plan;
        },
        onFailure: (failure) {
          log('❌ [getTravelPlanDetail] 获取失败: ${failure.message}');
          _travelPlanError.value = failure.message;
          return null;
        },
      );
    } catch (e) {
      log('❌ [getTravelPlanDetail] 异常: $e');
      _travelPlanError.value = e.toString();
      return null;
    }
  }

  /// 加载城市指南 (从后端API获取)
  ///
  /// 新流程:
  /// 1. 从后端CityService API获取指南数据
  /// 2. 如果没有数据,返回null,用户可以点击生成按钮
  /// 3. 生成完成后,后端自动存储到Supabase
  Future<DigitalNomadGuide?> loadCityGuide({
    required String cityId,
    required String cityName,
  }) async {
    try {
      log('📖 [loadCityGuide] 从后端API加载: cityId=$cityId, cityName=$cityName');
      _isLoadingGuide.value = true;
      _guideError.value = null;

      // 调用UseCase从后端获取指南
      final result = await _getDigitalNomadGuideUseCase.execute(cityId);

      return result.fold(
        onSuccess: (guide) {
          if (guide != null) {
            log('✅ [loadCityGuide] 从后端加载成功: $cityName');
            _currentGuide.value = guide;
            _isLoadingGuide.value = false;
            return guide;
          } else {
            log('📭 [loadCityGuide] 后端无数据,需要生成');
            _currentGuide.value = null;
            _isLoadingGuide.value = false;
            return null;
          }
        },
        onFailure: (failure) {
          log('⚠️ [loadCityGuide] 后端无数据或加载失败: ${failure.message}');
          _guideError.value = failure.message;
          _currentGuide.value = null;
          _isLoadingGuide.value = false;
          return null;
        },
      );
    } catch (e) {
      log('❌ [loadCityGuide] 加载失败: $e');
      _guideError.value = e.toString();
      _currentGuide.value = null;
      _isLoadingGuide.value = false;
      return null;
    }
  }

  /// 生成旅行计划 (标准方式)
  Future<TravelPlan?> generateTravelPlan({
    required String cityId,
    required String cityName,
    required String cityImage,
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
  }) async {
    _isGeneratingTravelPlan.value = true;
    _travelPlanError.value = null;

    final result = await _generateTravelPlanUseCase.execute(
      GenerateTravelPlanParams(
        cityId: cityId,
        cityName: cityName,
        cityImage: cityImage,
        duration: duration,
        budget: budget,
        travelStyle: travelStyle,
        interests: interests,
        departureLocation: departureLocation,
        customBudget: customBudget,
        currency: currency,
        selectedAttractions: selectedAttractions,
      ),
    );

    return result.fold(
      onSuccess: (plan) {
        _currentTravelPlan.value = plan;
        _isGeneratingTravelPlan.value = false;
        return plan;
      },
      onFailure: (exception) {
        _travelPlanError.value = exception.message;
        _isGeneratingTravelPlan.value = false;
        return null;
      },
    );
  }

  /// 生成旅行计划 (流式方式)
  Future<void> generateTravelPlanStream({
    required String cityId,
    required String cityName,
    required String cityImage,
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
  }) async {
    _isGeneratingTravelPlan.value = true;
    _travelPlanGenerationProgress.value = 0;
    _travelPlanGenerationMessage.value = '';
    _travelPlanError.value = null;

    final result = await _generateTravelPlanStreamUseCase.execute(
      GenerateTravelPlanStreamParams(
        cityId: cityId,
        cityName: cityName,
        cityImage: cityImage,
        duration: duration,
        budget: budget,
        travelStyle: travelStyle,
        interests: interests,
        departureLocation: departureLocation,
        customBudget: customBudget,
        currency: currency,
        selectedAttractions: selectedAttractions,
        onProgress: (message, progress) {
          _travelPlanGenerationMessage.value = message;
          _travelPlanGenerationProgress.value = progress;
        },
        onData: (plan) {
          _currentTravelPlan.value = plan;
          _isGeneratingTravelPlan.value = false;
          _travelPlanGenerationProgress.value = 100;
        },
        onError: (error) {
          _travelPlanError.value = error;
          _isGeneratingTravelPlan.value = false;
        },
      ),
    );

    // 如果execute本身失败(不是SSE事件中的失败)
    result.fold(
      onSuccess: (_) {
        // SSE流正常启动,实际结果通过回调处理
      },
      onFailure: (exception) {
        _travelPlanError.value = exception.message;
        _isGeneratingTravelPlan.value = false;
      },
    );
  }

  /// 根据ID获取旅行计划
  Future<TravelPlan?> getTravelPlanById(String planId) async {
    final result = await _getTravelPlanByIdUseCase.execute(
      GetTravelPlanByIdParams(planId: planId),
    );

    return result.fold(
      onSuccess: (plan) {
        _currentTravelPlan.value = plan;
        return plan;
      },
      onFailure: (exception) {
        _travelPlanError.value = exception.message;
        return null;
      },
    );
  }

  /// 生成数字游民指南 (流式方式)
  Future<void> generateDigitalNomadGuideStream({
    required String cityId,
    required String cityName,
  }) async {
    log('🎯 [Controller] generateDigitalNomadGuideStream 开始');
    log('   cityId: $cityId');
    log('   cityName: $cityName');

    _isGeneratingGuide.value = true;
    _guideGenerationProgress.value = 0;
    _guideGenerationMessage.value = '';
    _guideError.value = null;

    // 保留当前指南，只有当生成成功时才更新，失败时保持旧数据

    log('✅ [Controller] 初始状态设置完成: isGenerating=true, progress=0');

    try {
      // 调用异步生成方法，该方法会等待任务完成才返回
      await _generateDigitalNomadGuideStreamUseCase.execute(
        GenerateDigitalNomadGuideStreamParams(
          cityId: cityId,
          cityName: cityName,
          onProgress: (task) {
            final message = task.progress.message ?? '处理中...';
            final progress = task.progress.percentage;
            final completed = task.progress.completed;
            log(
                '📊 [Controller] 收到进度: $progress% - $message - completed: $completed');
            _guideGenerationMessage.value = message;
            _guideGenerationProgress.value = progress;
            _isGuideCompleted.value = completed; // ✅ 更新完成状态
          },
          onData: (guide) async {
            log('✅ [Controller] 收到完成事件');
            log('   guide.cityName: ${guide.cityName}');

            _currentGuide.value = guide;
            _guideGenerationProgress.value = 100;
            _guideGenerationMessage.value = '生成完成！';

            // 延迟一下再设置 false，确保 UI 能看到 100%
            await Future.delayed(const Duration(milliseconds: 500));
            _isGeneratingGuide.value = false;

            log('✅ [Controller] 城市指南生成成功: $cityName');
          },
          onError: (error) {
            log('❌ [Controller] 收到错误: $error');
            _guideError.value = error;
            _isGeneratingGuide.value = false;
          },
        ),
      );

      log('✅ [Controller] generateDigitalNomadGuideStream 执行完成');

      // 方法返回后，如果状态还是 true，说明被中途取消或异常
      if (_isGeneratingGuide.value) {
        log('⚠️ [Controller] 任务结束但状态异常，重置状态');
        _isGeneratingGuide.value = false;
      }
    } catch (e, stackTrace) {
      log('❌ [Controller] generateDigitalNomadGuideStream 异常: $e');
      log('   StackTrace: $stackTrace');
      _guideError.value = e.toString();
      _isGeneratingGuide.value = false;
    }
  }

  // ==================== 附近城市方法 ====================

  /// 加载附近城市 (从后端API获取)
  Future<List<NearbyCityDto>> loadNearbyCities({
    required String cityId,
  }) async {
    try {
      log('📍 [loadNearbyCities] 从后端API加载: cityId=$cityId');
      _isLoadingNearbyCities.value = true;
      _nearbyCitiesError.value = null;

      final result = await _getNearbyCitiesUseCase.execute(cityId);

      return result.fold(
        onSuccess: (cities) {
          log('✅ [loadNearbyCities] 从后端加载成功: ${cities.length} 个城市');
          _nearbyCities.assignAll(cities);
          _isLoadingNearbyCities.value = false;
          return cities;
        },
        onFailure: (failure) {
          log('⚠️ [loadNearbyCities] 后端无数据或加载失败: ${failure.message}');
          _nearbyCitiesError.value = failure.message;
          _nearbyCities.clear();
          _isLoadingNearbyCities.value = false;
          return [];
        },
      );
    } catch (e) {
      log('❌ [loadNearbyCities] 加载失败: $e');
      _nearbyCitiesError.value = e.toString();
      _nearbyCities.clear();
      _isLoadingNearbyCities.value = false;
      return [];
    }
  }

  /// 生成附近城市 (流式方式)
  Future<void> generateNearbyCitiesStream({
    required String cityId,
    required String cityName,
    String? country,
    int radiusKm = 100,
    int count = 4,
  }) async {
    log('🎯 [Controller] generateNearbyCitiesStream 开始');
    log('   cityId: $cityId');
    log('   cityName: $cityName');
    log('   radiusKm: $radiusKm');
    log('   count: $count');

    _isGeneratingNearbyCities.value = true;
    _nearbyCitiesGenerationProgress.value = 0;
    _nearbyCitiesGenerationMessage.value = '';
    _nearbyCitiesError.value = null;

    log('✅ [Controller] 初始状态设置完成: isGenerating=true, progress=0');

    try {
      await _generateNearbyCitiesStreamUseCase.execute(
        GenerateNearbyCitiesStreamParams(
          cityId: cityId,
          cityName: cityName,
          country: country,
          radiusKm: radiusKm,
          count: count,
          onProgress: (task) {
            final message = task.progress.message ?? '处理中...';
            final progress = task.progress.percentage;
            final completed = task.progress.completed;
            log('📊 [Controller] 收到进度: $progress% - $message - completed: $completed');
            _nearbyCitiesGenerationMessage.value = message;
            _nearbyCitiesGenerationProgress.value = progress;
            _isNearbyCitiesCompleted.value = completed;
          },
          onData: (cities) async {
            log('✅ [Controller] 收到附近城市生成完成事件');
            log('   cities count: ${cities.length}');

            _nearbyCities.assignAll(cities);
            _nearbyCitiesGenerationProgress.value = 100;
            _nearbyCitiesGenerationMessage.value = '生成完成！';

            // 延迟一下再设置 false，确保 UI 能看到 100%
            await Future.delayed(const Duration(milliseconds: 500));
            _isGeneratingNearbyCities.value = false;

            log('✅ [Controller] 附近城市生成成功: $cityName');
          },
          onError: (error) {
            log('❌ [Controller] 收到错误: $error');
            _nearbyCitiesError.value = error;
            _isGeneratingNearbyCities.value = false;
          },
        ),
      );

      log('✅ [Controller] generateNearbyCitiesStream 执行完成');

      // 方法返回后，如果状态还是 true，说明被中途取消或异常
      if (_isGeneratingNearbyCities.value) {
        log('⚠️ [Controller] 任务结束但状态异常，重置状态');
        _isGeneratingNearbyCities.value = false;
      }
    } catch (e, stackTrace) {
      log('❌ [Controller] generateNearbyCitiesStream 异常: $e');
      log('   StackTrace: $stackTrace');
      _nearbyCitiesError.value = e.toString();
      _isGeneratingNearbyCities.value = false;
    }
  }

  /// 重置旅行计划状态
  void resetTravelPlanState() {
    _isGeneratingTravelPlan.value = false;
    _travelPlanGenerationProgress.value = 0;
    _travelPlanGenerationMessage.value = '';
    _currentTravelPlan.value = null;
    _travelPlanError.value = null;
  }

  /// 重置指南状态
  void resetGuideState() {
    _isGeneratingGuide.value = false;
    _guideGenerationProgress.value = 0;
    _guideGenerationMessage.value = '';
    _currentGuide.value = null;
    _guideError.value = null;
    _isLoadingGuide.value = false;
  }

  /// 重置附近城市状态
  void resetNearbyCitiesState() {
    _isGeneratingNearbyCities.value = false;
    _nearbyCitiesGenerationProgress.value = 0;
    _nearbyCitiesGenerationMessage.value = '';
    _nearbyCities.clear();
    _nearbyCitiesError.value = null;
    _isLoadingNearbyCities.value = false;
    _isNearbyCitiesCompleted.value = false;
  }

  @override
  void onClose() {
    // 清空所有响应式变量 - 旅行计划
    _isGeneratingTravelPlan.value = false;
    _travelPlanGenerationProgress.value = 0;
    _travelPlanGenerationMessage.value = '';
    _currentTravelPlan.value = null;
    _travelPlanError.value = null;

    // 清空所有响应式变量 - 数字游民指南
    _isGeneratingGuide.value = false;
    _guideGenerationProgress.value = 0;
    _guideGenerationMessage.value = '';
    _currentGuide.value = null;
    _guideError.value = null;
    _isLoadingGuide.value = false;

    // 清空所有响应式变量 - 附近城市
    _isGeneratingNearbyCities.value = false;
    _nearbyCitiesGenerationProgress.value = 0;
    _nearbyCitiesGenerationMessage.value = '';
    _nearbyCities.clear();
    _nearbyCitiesError.value = null;
    _isLoadingNearbyCities.value = false;
    _isNearbyCitiesCompleted.value = false;

    super.onClose();
  }
}
