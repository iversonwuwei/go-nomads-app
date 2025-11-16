import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_option.dart';

import '../../domain/repositories/ilocation_repository.dart';

/// 根据 ID 获取城市信息的 Use Case
class GetCityByIdUseCase {
  final ILocationRepository _repository;

  GetCityByIdUseCase(this._repository);

  Future<Result<CityOption>> execute(GetCityByIdParams params) async {
    return await _repository.getCityById(params.cityId);
  }
}

/// GetCityById Use Case 参数
class GetCityByIdParams {
  final String cityId;

  const GetCityByIdParams({required this.cityId});
}
