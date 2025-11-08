import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/domain/repositories/iai_repository.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_detail.dart'
    as city_entity;
import 'package:df_admin_mobile/features/city/infrastructure/models/city_detail_dto.dart'
    as city_dto;
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart'
    as entity;
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:get/get.dart';

/// AI服务Repository实现
///
/// 使用HttpService调用后端AI API
class AiRepository implements IAiRepository {
  final HttpService _httpService = Get.find();

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
      print('🤖 正在生成AI旅行计划...');
      print('   城市: $cityName, 天数: $duration');

      // 处理自定义预算格式
      String finalBudget = budget;
      String? finalCurrency = currency;
      double? finalCustomBudget = customBudget;

      if (budget.contains(':')) {
        final parts = budget.split(':');
        if (parts.length == 2) {
          finalCurrency = parts[0];
          final amount = double.tryParse(parts[1]);
          if (amount != null) {
            finalCustomBudget = amount;
            finalBudget =
                amount < 3000 ? 'low' : (amount < 10000 ? 'medium' : 'high');
          }
        }
      }

      final response = await _httpService.post(
        '/ai/travel-plan',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          'cityImage': cityImage,
          'duration': duration,
          'budget': finalBudget,
          'travelStyle': travelStyle,
          'interests': interests,
          if (departureLocation != null) 'departureLocation': departureLocation,
          if (finalCustomBudget != null)
            'customBudget': finalCustomBudget.toString(),
          if (finalCurrency != null) 'currency': finalCurrency,
          if (selectedAttractions != null)
            'selectedAttractions': selectedAttractions,
        },
      );

      // 使用响应数据 (TODO: 实现完整的转换逻辑)
      print('✅ API响应: ${response.statusCode}');

      // TODO: 实现从响应到 entity.TravelPlan 的转换
      // 暂时返回错误，等待完整的 DTO 迁移
      return Result.failure(
        UnknownException('TravelPlan DTO conversion not yet implemented'),
      );
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
      // TODO: 需要实现从 legacy model 到 DTO 的转换
      // 暂时直接返回错误，等待 AI service 迁移到 DDD
      return Result.failure(
        UnknownException('Legacy model conversion not implemented'),
      );
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<entity.TravelPlan>> getTravelPlanById(String planId) async {
    try {
      // TODO: 需要实现从 legacy model 到 DTO 的转换
      // 暂时直接返回错误，等待 AI service 迁移到 DDD
      return Result.failure(
        UnknownException('Legacy model conversion not implemented'),
      );
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
      final response = await _httpService.post(
        '/ai/digital-nomad-guide',
        data: {'cityId': cityId, 'cityName': cityName},
      );

      final guideData = response.data as Map<String, dynamic>;
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
      // TODO: 实现流式响应 (需要 HttpService 支持 SSE)
      return Result.failure(
        UnknownException('Stream API not yet implemented'),
      );
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }
}
