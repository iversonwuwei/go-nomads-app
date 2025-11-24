import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';

/// 搜索城市用例
class SearchCitiesUseCase {
  final ICityRepository _repository;

  SearchCitiesUseCase(this._repository);

  Future<SearchCitiesResult> execute({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // 输入验证
      if (query.trim().isEmpty) {
        return SearchCitiesResult.failure('搜索关键词不能为空');
      }

      final result = await _repository.searchCities(
        name: query.trim(),
        pageNumber: page,
        pageSize: pageSize,
      );

      return switch (result) {
        Success(:final data) => SearchCitiesResult.success(data),
        Failure(:final exception) =>
          SearchCitiesResult.failure(exception.message),
      };
    } catch (e) {
      return SearchCitiesResult.failure('搜索城市失败: ${e.toString()}');
    }
  }
}

class SearchCitiesResult {
  final bool isSuccess;
  final List<City>? cities;
  final String? errorMessage;

  SearchCitiesResult._({
    required this.isSuccess,
    this.cities,
    this.errorMessage,
  });

  factory SearchCitiesResult.success(List<City> cities) {
    return SearchCitiesResult._(
      isSuccess: true,
      cities: cities,
    );
  }

  factory SearchCitiesResult.failure(String errorMessage) {
    return SearchCitiesResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
