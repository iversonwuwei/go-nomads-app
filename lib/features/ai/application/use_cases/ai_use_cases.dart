import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/domain/repositories/iai_repository.dart';
import 'package:df_admin_mobile/features/async_task/domain/entities/async_task.dart';
import 'package:df_admin_mobile/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:df_admin_mobile/features/city/infrastructure/models/city_detail_dto.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan_summary.dart';

// ==================== Use Case参数类 ====================

/// 生成旅行计划参数
class GenerateTravelPlanParams {
  final String cityId;
  final String cityName;
  final String cityImage;
  final int duration;
  final String budget;
  final String travelStyle;
  final List<String> interests;
  final String? departureLocation;
  final double? customBudget;
  final String? currency;
  final List<String>? selectedAttractions;

  const GenerateTravelPlanParams({
    required this.cityId,
    required this.cityName,
    required this.cityImage,
    required this.duration,
    required this.budget,
    required this.travelStyle,
    required this.interests,
    this.departureLocation,
    this.customBudget,
    this.currency,
    this.selectedAttractions,
  });
}

/// 生成旅行计划流式参数
class GenerateTravelPlanStreamParams {
  final String cityId;
  final String cityName;
  final String cityImage;
  final int duration;
  final String budget;
  final String travelStyle;
  final List<String> interests;
  final String? departureLocation;
  final double? customBudget;
  final String? currency;
  final List<String>? selectedAttractions;
  final Function(String message, int progress) onProgress;
  final Function(TravelPlan plan) onData;
  final Function(String error) onError;

  const GenerateTravelPlanStreamParams({
    required this.cityId,
    required this.cityName,
    required this.cityImage,
    required this.duration,
    required this.budget,
    required this.travelStyle,
    required this.interests,
    this.departureLocation,
    this.customBudget,
    this.currency,
    this.selectedAttractions,
    required this.onProgress,
    required this.onData,
    required this.onError,
  });
}

/// 获取旅行计划参数
class GetTravelPlanByIdParams {
  final String planId;

  const GetTravelPlanByIdParams({
    required this.planId,
  });
}

/// 生成数字游民指南流式参数
class GenerateDigitalNomadGuideStreamParams {
  final String cityId;
  final String cityName;
  final Function(AsyncTask task) onProgress;
  final Function(DigitalNomadGuide guide) onData;
  final Function(String error) onError;

  const GenerateDigitalNomadGuideStreamParams({
    required this.cityId,
    required this.cityName,
    required this.onProgress,
    required this.onData,
    required this.onError,
  });
}

/// 获取附近城市参数
class GetNearbyCitiesParams {
  final String cityId;

  const GetNearbyCitiesParams({
    required this.cityId,
  });
}

/// 生成附近城市流式参数
class GenerateNearbyCitiesStreamParams {
  final String cityId;
  final String cityName;
  final String? country;
  final int radiusKm;
  final int count;
  final Function(AsyncTask task) onProgress;
  final Function(List<NearbyCityDto> cities) onData;
  final Function(String error) onError;

  const GenerateNearbyCitiesStreamParams({
    required this.cityId,
    required this.cityName,
    this.country,
    this.radiusKm = 100,
    this.count = 4,
    required this.onProgress,
    required this.onData,
    required this.onError,
  });
}

// ==================== Use Cases ====================

/// 生成旅行计划 (标准方式)
class GenerateTravelPlanUseCase
    extends UseCase<TravelPlan, GenerateTravelPlanParams> {
  final IAiRepository _repository;

  GenerateTravelPlanUseCase(this._repository);

  @override
  Future<Result<TravelPlan>> execute(GenerateTravelPlanParams params) async {
    return await _repository.generateTravelPlan(
      cityId: params.cityId,
      cityName: params.cityName,
      cityImage: params.cityImage,
      duration: params.duration,
      budget: params.budget,
      travelStyle: params.travelStyle,
      interests: params.interests,
      departureLocation: params.departureLocation,
      customBudget: params.customBudget,
      currency: params.currency,
      selectedAttractions: params.selectedAttractions,
    );
  }
}

/// 生成旅行计划 (流式方式)
///
/// 注意: 这个Use Case返回Result<void>
/// 实际数据通过params中的回调函数返回
class GenerateTravelPlanStreamUseCase
    extends UseCase<void, GenerateTravelPlanStreamParams> {
  final IAiRepository _repository;

  GenerateTravelPlanStreamUseCase(this._repository);

  @override
  Future<Result<void>> execute(GenerateTravelPlanStreamParams params) async {
    return await _repository.generateTravelPlanStream(
      cityId: params.cityId,
      cityName: params.cityName,
      cityImage: params.cityImage,
      duration: params.duration,
      budget: params.budget,
      travelStyle: params.travelStyle,
      interests: params.interests,
      departureLocation: params.departureLocation,
      customBudget: params.customBudget,
      currency: params.currency,
      selectedAttractions: params.selectedAttractions,
      onProgress: params.onProgress,
      onData: params.onData,
      onError: params.onError,
    );
  }
}

/// 根据ID获取旅行计划
class GetTravelPlanByIdUseCase
    extends UseCase<TravelPlan, GetTravelPlanByIdParams> {
  final IAiRepository _repository;

  GetTravelPlanByIdUseCase(this._repository);

  @override
  Future<Result<TravelPlan>> execute(GetTravelPlanByIdParams params) async {
    return await _repository.getTravelPlanById(params.planId);
  }
}

/// 从后端获取数字游民指南
class GetDigitalNomadGuideUseCase extends UseCase<DigitalNomadGuide?, String> {
  final IAiRepository _repository;

  GetDigitalNomadGuideUseCase(this._repository);

  @override
  Future<Result<DigitalNomadGuide?>> execute(String cityId) async {
    return await _repository.getDigitalNomadGuideFromBackend(cityId);
  }
}

/// 生成数字游民指南 (流式方式)
///
/// 注意: 这个Use Case返回Result<void>
/// 实际数据通过params中的回调函数返回
class GenerateDigitalNomadGuideStreamUseCase
    extends UseCase<void, GenerateDigitalNomadGuideStreamParams> {
  final IAiRepository _repository;

  GenerateDigitalNomadGuideStreamUseCase(this._repository);

  @override
  Future<Result<void>> execute(
      GenerateDigitalNomadGuideStreamParams params) async {
    return await _repository.generateDigitalNomadGuideStream(
      cityId: params.cityId,
      cityName: params.cityName,
      onProgress: params.onProgress,
      onData: params.onData,
      onError: params.onError,
    );
  }
}

/// 获取用户旅行计划列表参数
class GetUserTravelPlansParams {
  final int page;
  final int pageSize;

  const GetUserTravelPlansParams({
    this.page = 1,
    this.pageSize = 20,
  });
}

/// 获取用户旅行计划列表
class GetUserTravelPlansUseCase extends UseCase<List<TravelPlanSummary>, GetUserTravelPlansParams> {
  final IAiRepository _repository;

  GetUserTravelPlansUseCase(this._repository);

  @override
  Future<Result<List<TravelPlanSummary>>> execute(GetUserTravelPlansParams params) async {
    return await _repository.getUserTravelPlans(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// 获取旅行计划详情参数
class GetTravelPlanDetailParams {
  final String planId;

  const GetTravelPlanDetailParams({required this.planId});
}

/// 获取旅行计划详情（从数据库）
class GetTravelPlanDetailUseCase extends UseCase<TravelPlan, GetTravelPlanDetailParams> {
  final IAiRepository _repository;

  GetTravelPlanDetailUseCase(this._repository);

  @override
  Future<Result<TravelPlan>> execute(GetTravelPlanDetailParams params) async {
    return await _repository.getTravelPlanDetail(params.planId);
  }
}

/// 从后端获取附近城市列表
class GetNearbyCitiesUseCase extends UseCase<List<NearbyCityDto>, String> {
  final IAiRepository _repository;

  GetNearbyCitiesUseCase(this._repository);

  @override
  Future<Result<List<NearbyCityDto>>> execute(String cityId) async {
    return await _repository.getNearbyCitiesFromBackend(cityId);
  }
}

/// 生成附近城市 (流式方式)
///
/// 注意: 这个Use Case返回Result<void>
/// 实际数据通过params中的回调函数返回
class GenerateNearbyCitiesStreamUseCase extends UseCase<void, GenerateNearbyCitiesStreamParams> {
  final IAiRepository _repository;

  GenerateNearbyCitiesStreamUseCase(this._repository);

  @override
  Future<Result<void>> execute(GenerateNearbyCitiesStreamParams params) async {
    return await _repository.generateNearbyCitiesStream(
      cityId: params.cityId,
      cityName: params.cityName,
      country: params.country,
      radiusKm: params.radiusKm,
      count: params.count,
      onProgress: params.onProgress,
      onData: params.onData,
      onError: params.onError,
    );
  }
}
