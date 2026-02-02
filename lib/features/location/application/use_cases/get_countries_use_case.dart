import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/country/domain/entities/country_option.dart';

import 'package:go_nomads_app/features/location/domain/repositories/ilocation_repository.dart';

/// 获取国家列表 Use Case
class GetCountriesUseCase {
  final ILocationRepository _repository;

  GetCountriesUseCase(this._repository);

  Future<Result<List<CountryOption>>> execute({
    bool forceRefresh = false,
  }) async {
    return await _repository.getCountries(forceRefresh: forceRefresh);
  }
}

/// Use Case 参数
class GetCountriesParams {
  final bool forceRefresh;

  GetCountriesParams({this.forceRefresh = false});
}
