import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/application/use_cases/ai_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:get/get.dart';

/// AI功能状态控制器
///
/// 管理:
/// - 旅行计划生成 (标准和流式)
/// - 数字游民指南生成 (标准和流式)
/// - 数字游民指南从后端加载
/// - 旅行计划检索
class AiStateController extends GetxController {
  // Use Cases
  final GenerateTravelPlanUseCase _generateTravelPlanUseCase;
  final GenerateTravelPlanStreamUseCase _generateTravelPlanStreamUseCase;
  final GetTravelPlanByIdUseCase _getTravelPlanByIdUseCase;
  final GenerateDigitalNomadGuideUseCase _generateDigitalNomadGuideUseCase;
  final GenerateDigitalNomadGuideStreamUseCase
      _generateDigitalNomadGuideStreamUseCase;
  final GetDigitalNomadGuideUseCase _getDigitalNomadGuideUseCase;

  AiStateController(
    this._generateTravelPlanUseCase,
    this._generateTravelPlanStreamUseCase,
    this._getTravelPlanByIdUseCase,
    this._generateDigitalNomadGuideUseCase,
    this._generateDigitalNomadGuideStreamUseCase,
    this._getDigitalNomadGuideUseCase,
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
  final _currentGuide = Rx<DigitalNomadGuide?>(null);
  final _guideError = Rx<String?>(null);
  final _isLoadingGuide = false.obs; // 从后端API加载中

  // ==================== Getters ====================

  // 旅行计划
  bool get isGeneratingTravelPlan => _isGeneratingTravelPlan.value;
  int get travelPlanGenerationProgress => _travelPlanGenerationProgress.value;
  String get travelPlanGenerationMessage => _travelPlanGenerationMessage.value;
  TravelPlan? get currentTravelPlan => _currentTravelPlan.value;
  String? get travelPlanError => _travelPlanError.value;

  // 数字游民指南
  bool get isGeneratingGuide => _isGeneratingGuide.value;
  RxBool get isGeneratingGuideRx => _isGeneratingGuide; // 暴露 Rx 对象用于监听
  int get guideGenerationProgress => _guideGenerationProgress.value;
  String get guideGenerationMessage => _guideGenerationMessage.value;
  DigitalNomadGuide? get currentGuide => _currentGuide.value;
  String? get guideError => _guideError.value;
  bool get isLoadingGuide => _isLoadingGuide.value;

  // ==================== 业务方法 ====================

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
      print('📖 [loadCityGuide] 从后端API加载: cityId=$cityId, cityName=$cityName');
      _isLoadingGuide.value = true;
      _guideError.value = null;

      // 调用UseCase从后端获取指南
      final result = await _getDigitalNomadGuideUseCase.execute(cityId);

      return result.fold(
        onSuccess: (guide) {
          if (guide != null) {
            print('✅ [loadCityGuide] 从后端加载成功: $cityName');
            _currentGuide.value = guide;
            _isLoadingGuide.value = false;
            return guide;
          } else {
            print('📭 [loadCityGuide] 后端无数据,需要生成');
            _currentGuide.value = null;
            _isLoadingGuide.value = false;
            return null;
          }
        },
        onFailure: (failure) {
          print('⚠️ [loadCityGuide] 后端无数据或加载失败: ${failure.message}');
          _guideError.value = failure.message;
          _currentGuide.value = null;
          _isLoadingGuide.value = false;
          return null;
        },
      );
    } catch (e) {
      print('❌ [loadCityGuide] 加载失败: $e');
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
    print('🎯 [Controller] generateDigitalNomadGuideStream 开始');
    print('   cityId: $cityId');
    print('   cityName: $cityName');
    
    _isGeneratingGuide.value = true;
    _guideGenerationProgress.value = 0;
    _guideGenerationMessage.value = '';
    _guideError.value = null;
    _currentGuide.value = null; // 清空之前的结果

    print('✅ [Controller] 初始状态设置完成: isGenerating=true, progress=0');

    try {
      // 调用异步生成方法，该方法会等待任务完成才返回
      await _generateDigitalNomadGuideStreamUseCase.execute(
        GenerateDigitalNomadGuideStreamParams(
          cityId: cityId,
          cityName: cityName,
          onProgress: (message, progress) {
            print('📊 [Controller] 收到进度: $progress% - $message');
            _guideGenerationMessage.value = message;
            _guideGenerationProgress.value = progress;
          },
          onData: (guide) async {
            print('✅ [Controller] 收到完成事件');
            print('   guide.cityName: ${guide.cityName}');
            
            _currentGuide.value = guide;
            _guideGenerationProgress.value = 100;
            _guideGenerationMessage.value = '生成完成！';
            
            // 延迟一下再设置 false，确保 UI 能看到 100%
            await Future.delayed(const Duration(milliseconds: 500));
            _isGeneratingGuide.value = false;

            print('✅ [Controller] 城市指南生成成功: $cityName');
          },
          onError: (error) {
            print('❌ [Controller] 收到错误: $error');
            _guideError.value = error;
            _isGeneratingGuide.value = false;
          },
        ),
      );
      
      print('✅ [Controller] generateDigitalNomadGuideStream 执行完成');

      // 方法返回后，如果状态还是 true，说明被中途取消或异常
      if (_isGeneratingGuide.value) {
        print('⚠️ [Controller] 任务结束但状态异常，重置状态');
        _isGeneratingGuide.value = false;
      }
    } catch (e, stackTrace) {
      print('❌ [Controller] generateDigitalNomadGuideStream 异常: $e');
      print('   StackTrace: $stackTrace');
      _guideError.value = e.toString();
      _isGeneratingGuide.value = false;
    }
  }

  /// 后台生成数字游民指南 (不阻塞UI, 完成后通知用户)
  ///
  /// 此方法会在后台运行生成过程,用户可以继续使用应用
  /// 生成完成后会显示 Toast 通知用户结果
  Future<void> generateDigitalNomadGuideInBackground({
    required String cityId,
    required String cityName,
  }) async {
    // 🔒 设置生成状态 - 禁用按钮
    _isGeneratingGuide.value = true;
    _guideError.value = null;

    // 显示开始生成的提示
    Get.snackbar(
      '🤖 开始生成',
      '正在后台为"$cityName"生成数字游民指南...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    // 后台执行生成任务
    _generateDigitalNomadGuideStreamUseCase.execute(
      GenerateDigitalNomadGuideStreamParams(
        cityId: cityId,
        cityName: cityName,
        onProgress: (message, progress) {
          // 后台模式不更新UI进度
          print('📊 后台生成进度 [$progress%]: $message');
        },
        onData: (guide) async {
          // 生成成功
          _currentGuide.value = guide;

          // ✅ 后端会自动保存到Supabase
          print('✅ 城市指南后台生成成功: $cityName (后端已自动保存)');

          // 显示成功通知
          Get.snackbar(
            '✅ 生成成功',
            '"$cityName"的数字游民指南已生成完成!',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
            backgroundColor: Get.theme.colorScheme.primaryContainer,
          );

          // 🔓 完成 - 解锁按钮
          _isGeneratingGuide.value = false;
        },
        onError: (error) {
          // 生成失败
          print('❌ 后台生成失败: $error');

          // 显示失败通知
          Get.snackbar(
            '❌ 生成失败',
            '"$cityName"的指南生成失败: $error',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
            backgroundColor: Get.theme.colorScheme.errorContainer,
          );

          // 🔓 失败 - 解锁按钮
          _isGeneratingGuide.value = false;
        },
      ),
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
    
    super.onClose();
  }
}
