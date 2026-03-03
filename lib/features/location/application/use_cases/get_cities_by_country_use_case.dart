import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_option.dart';

import 'package:go_nomads_app/features/location/domain/repositories/ilocation_repository.dart';

/// 根据国家获取城市列表 Use Case
class GetCitiesByCountryUseCase {
  final ILocationRepository _repository;

  GetCitiesByCountryUseCase(this._repository);

  Future<Result<List<CityOption>>> execute(GetCitiesByCountryParams params) async {
    return await _repository.getCitiesByCountry(
      countryId: params.countryId,
      forceRefresh: params.forceRefresh,
    );
  }
}

/// Use Case 参数
class GetCitiesByCountryParams {
  final String countryId;
  final bool forceRefresh;

  GetCitiesByCountryParams({
    required this.countryId,
    this.forceRefresh = false,
  });
}
