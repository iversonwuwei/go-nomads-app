import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/domain/repositories/iai_repository.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_detail.dart'
    as city_entity;
import 'package:df_admin_mobile/features/city/infrastructure/models/city_detail_dto.dart'
    as city_dto;
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart'
    as entity;
import 'package:df_admin_mobile/features/travel_plan/infrastructure/models/travel_plan_dto.dart';
import 'package:df_admin_mobile/models/travel_plan_model.dart' as legacy;
import 'package:df_admin_mobile/services/ai_api_service.dart';

/// AI服务Repository实现
///
/// 使用AiApiService调用后端AI API
class AiRepository implements IAiRepository {
  final AiApiService _apiService = AiApiService();

  @override
  Future<Result<entity.TravelPlan>> generateTravelPlan({
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
    try {
      // API返回legacy.TravelPlan
      final legacyPlan = await _apiService.generateTravelPlan(
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
      );

      // 转换: legacy.TravelPlan → TravelPlanDto → entity.TravelPlan
      final dto = TravelPlanDto.fromLegacyModel(legacyPlan);
      final entityPlan = dto.toDomain();

      return Result.success(entityPlan);
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<void>> generateTravelPlanStream({
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
    required Function(String message, int progress) onProgress,
    required Function(entity.TravelPlan plan) onData,
    required Function(String error) onError,
  }) async {
    try {
      await _apiService.generateTravelPlanStream(
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
        onProgress: onProgress,
        onData: (legacy.TravelPlan legacyPlan) {
          // 转换: legacy.TravelPlan → TravelPlanDto → entity.TravelPlan
          final dto = TravelPlanDto.fromLegacyModel(legacyPlan);
          final entityPlan = dto.toDomain();
          onData(entityPlan);
        },
        onError: onError,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<entity.TravelPlan>> getTravelPlanById(String planId) async {
    try {
      // API返回legacy.TravelPlan
      final legacyPlan = await _apiService.getTravelPlanById(planId);

      // 转换: legacy.TravelPlan → TravelPlanDto → entity.TravelPlan
      final dto = TravelPlanDto.fromLegacyModel(legacyPlan);
      final entityPlan = dto.toDomain();

      return Result.success(entityPlan);
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<city_entity.DigitalNomadGuide>> generateDigitalNomadGuide({
    required String cityId,
    required String cityName,
  }) async {
    try {
      final guideData = await _apiService.generateDigitalNomadGuide(
        cityId: cityId,
        cityName: cityName,
      );

      // API返回Map<String, dynamic>,需要转换为DigitalNomadGuide
      // 使用DigitalNomadGuideDto进行转换
      // dto.toDomain()返回entity.DigitalNomadGuide,因为city_detail_dto import的是as entity
      final dto = city_dto.DigitalNomadGuideDto.fromJson(guideData);
      final guide = dto.toDomain() as city_entity.DigitalNomadGuide;

      return Result.success(guide);
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<void>> generateDigitalNomadGuideStream({
    required String cityId,
    required String cityName,
    required Function(String message, int progress) onProgress,
    required Function(city_entity.DigitalNomadGuide guide) onData,
    required Function(String error) onError,
  }) async {
    try {
      await _apiService.generateDigitalNomadGuideStream(
        cityId: cityId,
        cityName: cityName,
        onProgress: onProgress,
        onData: onData,
        onError: onError,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }
}
