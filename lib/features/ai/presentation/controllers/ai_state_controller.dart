import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/application/use_cases/ai_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:df_admin_mobile/services/database/digital_nomad_guide_dao.dart';
import 'package:df_admin_mobile/services/database_service.dart';
import 'package:get/get.dart';

/// AI功能状态控制器
///
/// 管理:
/// - 旅行计划生成 (标准和流式)
/// - 数字游民指南生成 (标准和流式)
/// - 旅行计划检索
/// - 本地缓存管理
class AiStateController extends GetxController {
  // Use Cases
  final GenerateTravelPlanUseCase _generateTravelPlanUseCase;
  final GenerateTravelPlanStreamUseCase _generateTravelPlanStreamUseCase;
  final GetTravelPlanByIdUseCase _getTravelPlanByIdUseCase;
  final GenerateDigitalNomadGuideUseCase _generateDigitalNomadGuideUseCase;
  final GenerateDigitalNomadGuideStreamUseCase
      _generateDigitalNomadGuideStreamUseCase;

  // Database DAO
  DigitalNomadGuideDao? _guideDao;

  AiStateController(
    this._generateTravelPlanUseCase,
    this._generateTravelPlanStreamUseCase,
    this._getTravelPlanByIdUseCase,
    this._generateDigitalNomadGuideUseCase,
    this._generateDigitalNomadGuideStreamUseCase,
  );

  @override
  void onInit() {
    super.onInit();
    _initializeDao();
  }

  /// 初始化 DAO
  Future<void> _initializeDao() async {
    try {
      final db = await Get.find<DatabaseService>().database;
      _guideDao = DigitalNomadGuideDao(db);
    } catch (e) {
      print('⚠️ Failed to initialize DigitalNomadGuideDao: $e');
    }
  }

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
  final _currentGuide = Rx<DigitalNomadGuide?>(null);
  final _guideError = Rx<String?>(null);
  final _isLoadingGuide = false.obs; // 从本地加载中
  final _isGuideFromCache = false.obs; // 是否来自缓存

  // ==================== Getters ====================

  // 旅行计划
  bool get isGeneratingTravelPlan => _isGeneratingTravelPlan.value;
  int get travelPlanGenerationProgress => _travelPlanGenerationProgress.value;
  String get travelPlanGenerationMessage => _travelPlanGenerationMessage.value;
  TravelPlan? get currentTravelPlan => _currentTravelPlan.value;
  String? get travelPlanError => _travelPlanError.value;

  // 数字游民指南
  bool get isGeneratingGuide => _isGeneratingGuide.value;
  int get guideGenerationProgress => _guideGenerationProgress.value;
  String get guideGenerationMessage => _guideGenerationMessage.value;
  DigitalNomadGuide? get currentGuide => _currentGuide.value;
  String? get guideError => _guideError.value;
  bool get isLoadingGuide => _isLoadingGuide.value;
  bool get isGuideFromCache => _isGuideFromCache.value;

  // ==================== 业务方法 ====================

  /// 加载城市指南 (本地优先)
  ///
  /// 流程:
  /// 1. 先从 sqlite 读取本地缓存
  /// 2. 如果本地有且未过期，直接返回
  /// 3. 否则从服务端获取并缓存
  Future<DigitalNomadGuide?> loadCityGuide({
    required String cityId,
    required String cityName,
    bool forceRefresh = false,
    int maxCacheDays = 30,
  }) async {
    try {
      _isLoadingGuide.value = true;
      _guideError.value = null;

      // 确保 DAO 已初始化
      if (_guideDao == null) {
        await _initializeDao();
      }

      if (_guideDao == null) {
        throw Exception('Failed to initialize guide DAO');
      }

      // 如果不强制刷新，先尝试从本地加载
      if (!forceRefresh) {
        final cachedGuide = await _guideDao!.getGuide(cityId);
        if (cachedGuide != null) {
          final isExpired = await _guideDao!.isGuideExpired(
            cityId,
            maxDays: maxCacheDays,
          );

          if (!isExpired) {
            print('✅ 从本地缓存加载城市指南: $cityName');
            _currentGuide.value = cachedGuide;
            _isGuideFromCache.value = true;
            _isLoadingGuide.value = false;
            return cachedGuide;
          } else {
            print('⚠️ 本地指南已过期，需要重新生成');
          }
        }
      }

      // 本地无缓存或已过期，使用流式方式生成
      _isGuideFromCache.value = false;
      await generateDigitalNomadGuideStream(
        cityId: cityId,
        cityName: cityName,
      );

      _isLoadingGuide.value = false;
      return _currentGuide.value;
    } catch (e) {
      _guideError.value = e.toString();
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

  /// 生成数字游民指南 (标准方式)
  Future<DigitalNomadGuide?> generateDigitalNomadGuide({
    required String cityId,
    required String cityName,
  }) async {
    _isGeneratingGuide.value = true;
    _guideError.value = null;

    final result = await _generateDigitalNomadGuideUseCase.execute(
      GenerateDigitalNomadGuideParams(
        cityId: cityId,
        cityName: cityName,
      ),
    );

    return result.fold(
      onSuccess: (guide) {
        _currentGuide.value = guide;
        _isGeneratingGuide.value = false;
        return guide;
      },
      onFailure: (exception) {
        _guideError.value = exception.message;
        _isGeneratingGuide.value = false;
        return null;
      },
    );
  }

  /// 生成数字游民指南 (流式方式)
  Future<void> generateDigitalNomadGuideStream({
    required String cityId,
    required String cityName,
  }) async {
    _isGeneratingGuide.value = true;
    _guideGenerationProgress.value = 0;
    _guideGenerationMessage.value = '';
    _guideError.value = null;

    final result = await _generateDigitalNomadGuideStreamUseCase.execute(
      GenerateDigitalNomadGuideStreamParams(
        cityId: cityId,
        cityName: cityName,
        onProgress: (message, progress) {
          _guideGenerationMessage.value = message;
          _guideGenerationProgress.value = progress;
        },
        onData: (guide) async {
          _currentGuide.value = guide;
          _isGeneratingGuide.value = false;
          _guideGenerationProgress.value = 100;
          _isGuideFromCache.value = false;

          // 🔥 生成成功后自动保存到本地 sqlite
          try {
            if (_guideDao != null) {
              await _guideDao!.saveGuide(guide);
              print('✅ 城市指南已保存到本地缓存: $cityName');
            }
          } catch (e) {
            print('⚠️ 保存指南到本地失败: $e');
            // 保存失败不影响主流程
          }
        },
        onError: (error) {
          _guideError.value = error;
          _isGeneratingGuide.value = false;
        },
      ),
    );

    // 如果execute本身失败(不是SSE事件中的失败)
    result.fold(
      onSuccess: (_) {
        // SSE流正常启动,实际结果通过回调处理
      },
      onFailure: (exception) {
        _guideError.value = exception.message;
        _isGeneratingGuide.value = false;
      },
    );
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
    _isGuideFromCache.value = false;
  }

  /// 删除本地缓存的指南
  Future<void> deleteCachedGuide(String cityId) async {
    try {
      if (_guideDao != null) {
        await _guideDao!.deleteGuide(cityId);
        if (_currentGuide.value?.cityId == cityId) {
          _currentGuide.value = null;
          _isGuideFromCache.value = false;
        }
        print('✅ 已删除本地缓存的城市指南');
      }
    } catch (e) {
      print('⚠️ 删除本地指南失败: $e');
    }
  }

  /// 清除所有本地缓存的指南
  Future<void> clearAllCachedGuides() async {
    try {
      if (_guideDao != null) {
        await _guideDao!.deleteAll();
        _currentGuide.value = null;
        _isGuideFromCache.value = false;
        print('✅ 已清除所有本地缓存的城市指南');
      }
    } catch (e) {
      print('⚠️ 清除本地指南失败: $e');
    }
  }
}
