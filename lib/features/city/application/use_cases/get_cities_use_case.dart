import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';

/// 获取城市列表用例 (Application Layer)
class GetCitiesUseCase {
  final ICityRepository _repository;

  GetCitiesUseCase(this._repository);

  /// 执行用例
  Future<GetCitiesResult> execute({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? countryId,
  }) async {
    try {
      final result = await _repository.getCities(
        page: page,
        pageSize: pageSize,
        search: search,
        countryId: countryId,
      );

      // 处理 Result<List<City>>
      return switch (result) {
        Success(:final data) => GetCitiesResult.success(data),
        Failure(:final exception) => GetCitiesResult.failure(exception.message),
      };
    } catch (e) {
      return GetCitiesResult.failure('获取城市列表失败: ${e.toString()}');
    }
  }
}

/// 用例执行结果
class GetCitiesResult {
  final bool isSuccess;
  final List<City>? cities;
  final String? errorMessage;

  GetCitiesResult._({
    required this.isSuccess,
    this.cities,
    this.errorMessage,
  });

  factory GetCitiesResult.success(List<City> cities) {
    return GetCitiesResult._(
      isSuccess: true,
      cities: cities,
    );
  }

  factory GetCitiesResult.failure(String errorMessage) {
    return GetCitiesResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
