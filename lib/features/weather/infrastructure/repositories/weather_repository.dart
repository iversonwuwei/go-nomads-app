import '../../../../core/domain/result.dart';
import '../../../city/domain/repositories/i_city_repository.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/iweather_repository.dart';
import '../models/weather_dto.dart';

/// Weather Repository 实现 (Infrastructure Layer)
///
/// 负责从 API 获取天气数据并转换为领域实体
class WeatherRepository implements IWeatherRepository {
  final ICityRepository _cityRepository;

  WeatherRepository(this._cityRepository);

  @override
  Future<Result<Weather>> getCityWeather(
    String cityId, {
    bool includeForecast = true,
    int days = 7,
  }) async {
    try {
      // 调用 CityRepository 获取天气数据
      final result = await _cityRepository.getCityWeather(
        cityId,
        includeForecast: includeForecast,
        days: days,
      );

      return switch (result) {
        Success(:final data) => data == null
            ? Failure(NotFoundException('城市 $cityId 的天气数据不存在'))
            : Success(WeatherDto.fromJson(data).toDomain()),
        Failure(:final exception) => Failure(exception),
      };
    } catch (e) {
      return Failure(
        UnknownException('获取城市天气失败: ${e.toString()}'),
      );
    }
  }
}
