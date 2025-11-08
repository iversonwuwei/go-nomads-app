import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/domain/repositories/iai_repository.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_detail.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart';

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

/// 生成数字游民指南参数
class GenerateDigitalNomadGuideParams {
  final String cityId;
  final String cityName;

  const GenerateDigitalNomadGuideParams({
    required this.cityId,
    required this.cityName,
  });
}

/// 生成数字游民指南流式参数
class GenerateDigitalNomadGuideStreamParams {
  final String cityId;
  final String cityName;
  final Function(String message, int progress) onProgress;
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

/// 生成数字游民指南 (标准方式)
class GenerateDigitalNomadGuideUseCase
    extends UseCase<DigitalNomadGuide, GenerateDigitalNomadGuideParams> {
  final IAiRepository _repository;

  GenerateDigitalNomadGuideUseCase(this._repository);

  @override
  Future<Result<DigitalNomadGuide>> execute(
      GenerateDigitalNomadGuideParams params) async {
    return await _repository.generateDigitalNomadGuide(
      cityId: params.cityId,
      cityName: params.cityName,
    );
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
