import '../../../../core/application/use_case.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/iweather_repository.dart';

/// 获取城市天气 Use Case
class GetCityWeatherUseCase extends UseCase<Weather, GetCityWeatherParams> {
  final IWeatherRepository _repository;

  GetCityWeatherUseCase(this._repository);

  @override
  Future<Result<Weather>> execute(GetCityWeatherParams params) async {
    return await _repository.getCityWeather(
      params.cityId,
      includeForecast: params.includeForecast,
      days: params.days,
    );
  }
}

/// 获取城市天气参数
class GetCityWeatherParams extends UseCaseParams {
  final String cityId;
  final bool includeForecast;
  final int days;

  const GetCityWeatherParams({
    required this.cityId,
    this.includeForecast = true,
    this.days = 7,
  });
}
