import '../../../../core/domain/result.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/i_city_repository.dart';

/// 获取推荐城市用例
///
/// 注意：原本使用 CityDomainService 进行复杂的偏好匹配和评分
/// 现在简化为直接返回后端推荐的城市，偏好过滤由后端处理
class GetRecommendedCitiesUseCase {
  final ICityRepository _repository;

  GetRecommendedCitiesUseCase(this._repository);

  Future<GetRecommendedCitiesResult> execute({
    required Map<String, dynamic> userPreferences,
    String? countryId,
    int limit = 10,
  }) async {
    try {
      // 获取推荐城市列表
      // TODO: 如果需要客户端过滤，可以在这里添加基于 userPreferences 的简单过滤逻辑
      final result = await _repository.getRecommendedCities(
        countryId: countryId,
        limit: limit,
      );

      return switch (result) {
        Success(:final data) => GetRecommendedCitiesResult.success(data),
        Failure(:final exception) =>
          GetRecommendedCitiesResult.failure(exception.message),
      };
    } catch (e) {
      return GetRecommendedCitiesResult.failure('获取推荐城市失败: ${e.toString()}');
    }
  }
}

class GetRecommendedCitiesResult {
  final bool isSuccess;
  final List<City>? cities;
  final String? errorMessage;

  GetRecommendedCitiesResult._({
    required this.isSuccess,
    this.cities,
    this.errorMessage,
  });

  factory GetRecommendedCitiesResult.success(List<City> cities) {
    return GetRecommendedCitiesResult._(
      isSuccess: true,
      cities: cities,
    );
  }

  factory GetRecommendedCitiesResult.failure(String errorMessage) {
    return GetRecommendedCitiesResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
