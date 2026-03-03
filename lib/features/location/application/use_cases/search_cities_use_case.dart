import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_option.dart';

import 'package:go_nomads_app/features/location/domain/repositories/ilocation_repository.dart';

/// 搜索城市 Use Case
class SearchCitiesUseCase {
  final ILocationRepository _repository;

  SearchCitiesUseCase(this._repository);

  Future<Result<List<CityOption>>> execute(SearchCitiesParams params) async {
    return await _repository.searchCities(
      query: params.query,
      countryId: params.countryId,
    );
  }
}

/// Use Case 参数
class SearchCitiesParams {
  final String query;
  final String? countryId;

  SearchCitiesParams({
    required this.query,
    this.countryId,
  });
}
