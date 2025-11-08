import '../../../../core/domain/result.dart';
import '../../../../services/cities_api_service.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/iweather_repository.dart';
import '../models/weather_dto.dart';

/// Weather Repository 实现 (Infrastructure Layer)
///
/// 负责从 API 获取天气数据并转换为领域实体
class WeatherRepository implements IWeatherRepository {
  final CitiesApiService _apiService;

  WeatherRepository({CitiesApiService? apiService})
      : _apiService = apiService ?? CitiesApiService();

  @override
  Future<Result<Weather>> getCityWeather(
    String cityId, {
    bool includeForecast = true,
    int days = 7,
  }) async {
    try {
      final data = await _apiService.getCityWeather(
        cityId,
        includeForecast: includeForecast,
        days: days,
      );

      if (data == null) {
        return Result.failure(
          NotFoundException('Weather data not found for city: $cityId'),
        );
      }

      // 将 DTO 转换为 Entity
      final weatherDto = WeatherDto.fromJson(data);
      final weather = _toEntity(weatherDto);

      return Result.success(weather);
    } catch (e) {
      return Result.failure(
        NetworkException('Failed to fetch weather data: ${e.toString()}'),
      );
    }
  }

  /// 将 DTO 转换为 Entity
  Weather _toEntity(WeatherDto dto) {
    return Weather(
      temperature: dto.temperature,
      feelsLike: dto.feelsLike,
      tempMin: dto.tempMin,
      tempMax: dto.tempMax,
      latitude: dto.latitude,
      longitude: dto.longitude,
      weather: dto.weather,
      weatherDescription: dto.weatherDescription,
      weatherIcon: dto.weatherIcon,
      humidity: dto.humidity,
      windSpeed: dto.windSpeed,
      windDirection: dto.windDirection,
      windDirectionDescription: dto.windDirectionDescription,
      windGust: dto.windGust,
      pressure: dto.pressure,
      seaLevelPressure: dto.seaLevelPressure,
      groundLevelPressure: dto.groundLevelPressure,
      visibility: dto.visibility,
      cloudiness: dto.cloudiness,
      rain1h: dto.rain1h,
      rain3h: dto.rain3h,
      snow1h: dto.snow1h,
      snow3h: dto.snow3h,
      sunrise: dto.sunrise,
      sunset: dto.sunset,
      timezoneOffset: dto.timezoneOffset,
      uvIndex: dto.uvIndex,
      airQualityIndex: dto.airQualityIndex,
      dataSource: dto.dataSource,
      updatedAt: dto.updatedAt,
      timestamp: dto.timestamp,
      forecast: dto.forecast != null ? _toForecastEntity(dto.forecast!) : null,
    );
  }

  /// 将 ForecastDto 转换为 Entity
  WeatherForecast _toForecastEntity(WeatherForecastDto dto) {
    return WeatherForecast(
      latitude: dto.latitude,
      longitude: dto.longitude,
      timezone: dto.timezone,
      timezoneOffset: dto.timezoneOffset,
      generatedAt: dto.generatedAt,
      daily:
          dto.daily.map((dailyDto) => _toDailyWeatherEntity(dailyDto)).toList(),
    );
  }

  /// 将 DailyWeatherDto 转换为 Entity
  DailyWeather _toDailyWeatherEntity(DailyWeatherDto dto) {
    return DailyWeather(
      date: dto.date,
      sunrise: dto.sunrise,
      sunset: dto.sunset,
      moonrise: dto.moonrise,
      moonset: dto.moonset,
      moonPhase: dto.moonPhase,
      tempDay: dto.tempDay,
      tempNight: dto.tempNight,
      tempMin: dto.tempMin,
      tempMax: dto.tempMax,
      tempEvening: dto.tempEvening,
      tempMorning: dto.tempMorning,
      feelsLikeDay: dto.feelsLikeDay,
      feelsLikeNight: dto.feelsLikeNight,
      feelsLikeEvening: dto.feelsLikeEvening,
      feelsLikeMorning: dto.feelsLikeMorning,
      humidity: dto.humidity,
      pressure: dto.pressure,
      windSpeed: dto.windSpeed,
      windDirection: dto.windDirection,
      windDirectionDescription: dto.windDirectionDescription,
      windGust: dto.windGust,
      cloudiness: dto.cloudiness,
      probabilityOfPrecipitation: dto.probabilityOfPrecipitation,
      rainVolume: dto.rainVolume,
      snowVolume: dto.snowVolume,
      uvIndex: dto.uvIndex,
      dewPoint: dto.dewPoint,
      summary: dto.summary,
      weather: dto.weather,
      weatherDescription: dto.weatherDescription,
      weatherIcon: dto.weatherIcon,
    );
  }
}
