// Legacy import removed - old weather_model.dart no longer exists
// import '../../../../models/weather_model.dart' as legacy;
import '../../domain/entities/weather.dart';

// ============================================================
// 类型别名 - 用于向后兼容旧代码
// ============================================================
typedef WeatherModel = WeatherDto;

/// Weather DTO - 基础设施层数据传输对象
/// 负责JSON序列化和与领域实体的转换
class WeatherDto {
  final double temperature;
  final double feelsLike;
  final double? tempMin;
  final double? tempMax;
  final double? latitude;
  final double? longitude;
  final String weather;
  final String weatherDescription;
  final String weatherIcon;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final String? windDirectionDescription;
  final double? windGust;
  final int pressure;
  final int? seaLevelPressure;
  final int? groundLevelPressure;
  final int visibility;
  final int cloudiness;
  final double? rain1h;
  final double? rain3h;
  final double? snow1h;
  final double? snow3h;
  final DateTime sunrise;
  final DateTime sunset;
  final int? timezoneOffset;
  final double? uvIndex;
  final int? airQualityIndex;
  final String? dataSource;
  final DateTime updatedAt;
  final DateTime timestamp;
  final WeatherForecastDto? forecast;

  WeatherDto({
    required this.temperature,
    required this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.latitude,
    this.longitude,
    required this.weather,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    this.windDirectionDescription,
    this.windGust,
    required this.pressure,
    this.seaLevelPressure,
    this.groundLevelPressure,
    required this.visibility,
    required this.cloudiness,
    this.rain1h,
    this.rain3h,
    this.snow1h,
    this.snow3h,
    required this.sunrise,
    required this.sunset,
    this.timezoneOffset,
    this.uvIndex,
    this.airQualityIndex,
    this.dataSource,
    required this.updatedAt,
    required this.timestamp,
    this.forecast,
  });

  factory WeatherDto.fromJson(Map<String, dynamic> json) {
    return WeatherDto(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0.0,
      tempMin: (json['tempMin'] as num?)?.toDouble(),
      tempMax: (json['tempMax'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      weather: json['weather'] as String? ?? '',
      weatherDescription: json['weatherDescription'] as String? ?? '',
      weatherIcon: json['weatherIcon'] as String? ?? '',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['windDirection'] as num?)?.toInt() ?? 0,
      windDirectionDescription: json['windDirectionDescription'] as String?,
      windGust: (json['windGust'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toInt() ?? 0,
      seaLevelPressure: (json['seaLevelPressure'] as num?)?.toInt(),
      groundLevelPressure: (json['groundLevelPressure'] as num?)?.toInt(),
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
      cloudiness: (json['cloudiness'] as num?)?.toInt() ?? 0,
      rain1h: (json['rain1h'] as num?)?.toDouble(),
      rain3h: (json['rain3h'] as num?)?.toDouble(),
      snow1h: (json['snow1h'] as num?)?.toDouble(),
      snow3h: (json['snow3h'] as num?)?.toDouble(),
      sunrise: json['sunrise'] != null
          ? DateTime.parse(json['sunrise'] as String)
          : DateTime.now(),
      sunset: json['sunset'] != null
          ? DateTime.parse(json['sunset'] as String)
          : DateTime.now(),
      timezoneOffset: (json['timezoneOffset'] as num?)?.toInt(),
      uvIndex: (json['uvIndex'] as num?)?.toDouble(),
      airQualityIndex: (json['airQualityIndex'] as num?)?.toInt(),
      dataSource: json['dataSource'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      forecast: json['forecast'] is Map<String, dynamic>
          ? WeatherForecastDto.fromJson(
              json['forecast'] as Map<String, dynamic>,
            )
          : json['forecast'] is Map
              ? WeatherForecastDto.fromJson(
                  Map<String, dynamic>.from(json['forecast'] as Map),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'latitude': latitude,
      'longitude': longitude,
      'weather': weather,
      'weatherDescription': weatherDescription,
      'weatherIcon': weatherIcon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'windDirectionDescription': windDirectionDescription,
      'windGust': windGust,
      'pressure': pressure,
      'seaLevelPressure': seaLevelPressure,
      'groundLevelPressure': groundLevelPressure,
      'visibility': visibility,
      'cloudiness': cloudiness,
      'rain1h': rain1h,
      'rain3h': rain3h,
      'snow1h': snow1h,
      'snow3h': snow3h,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'timezoneOffset': timezoneOffset,
      'uvIndex': uvIndex,
      'airQualityIndex': airQualityIndex,
      'dataSource': dataSource,
      'updatedAt': updatedAt.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      if (forecast != null) 'forecast': forecast!.toJson(),
    };
  }

  /// 转换为领域实体
  Weather toDomain() {
    return Weather(
      temperature: temperature,
      feelsLike: feelsLike,
      tempMin: tempMin,
      tempMax: tempMax,
      weather: weather,
      weatherDescription: weatherDescription,
      weatherIcon: weatherIcon,
      humidity: humidity,
      windSpeed: windSpeed,
      windDirection: windDirection,
      windGust: windGust,
      pressure: pressure,
      visibility: visibility,
      cloudiness: cloudiness,
      rain1h: rain1h,
      rain3h: rain3h,
      snow1h: snow1h,
      snow3h: snow3h,
      sunrise: sunrise,
      sunset: sunset,
      uvIndex: uvIndex,
      airQualityIndex: airQualityIndex,
      updatedAt: updatedAt,
      timestamp: timestamp,
      forecast: forecast?.toDomain(),
    );
  }

  /* Legacy model removed - fromLegacyModel method disabled
  /// 从旧模型转换 (兼容性)
  factory WeatherDto.fromLegacyModel(legacy.WeatherModel model) {
    return WeatherDto(
      temperature: model.temperature,
      feelsLike: model.feelsLike,
      tempMin: model.tempMin,
      tempMax: model.tempMax,
      latitude: model.latitude,
      longitude: model.longitude,
      weather: model.weather,
      weatherDescription: model.weatherDescription,
      weatherIcon: model.weatherIcon,
      humidity: model.humidity,
      windSpeed: model.windSpeed,
      windDirection: model.windDirection,
      windDirectionDescription: model.windDirectionDescription,
      windGust: model.windGust,
      pressure: model.pressure,
      seaLevelPressure: model.seaLevelPressure,
      groundLevelPressure: model.groundLevelPressure,
      visibility: model.visibility,
      cloudiness: model.cloudiness,
      rain1h: model.rain1h,
      rain3h: model.rain3h,
      snow1h: model.snow1h,
      snow3h: model.snow3h,
      sunrise: model.sunrise,
      sunset: model.sunset,
      timezoneOffset: model.timezoneOffset,
      uvIndex: model.uvIndex,
      airQualityIndex: model.airQualityIndex,
      dataSource: model.dataSource,
      updatedAt: model.updatedAt,
      timestamp: model.timestamp,
      forecast: model.forecast != null
          ? WeatherForecastDto.fromLegacyModel(model.forecast!)
          : null,
    );
  }
  */
}

/// WeatherForecast DTO
class WeatherForecastDto {
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final int? timezoneOffset;
  final DateTime generatedAt;
  final List<DailyWeatherDto> daily;

  WeatherForecastDto({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneOffset,
    required this.generatedAt,
    required this.daily,
  });

  factory WeatherForecastDto.fromJson(Map<String, dynamic> json) {
    final dailyData = json['daily'];
    List<DailyWeatherDto> dailyList = [];
    if (dailyData is List) {
      dailyList = dailyData
          .map((item) => item is Map<String, dynamic>
              ? DailyWeatherDto.fromJson(item)
              : DailyWeatherDto.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
          .toList();
    }

    return WeatherForecastDto(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timezone: json['timezone'] as String?,
      timezoneOffset: (json['timezoneOffset'] as num?)?.toInt(),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
      daily: dailyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'timezoneOffset': timezoneOffset,
      'generatedAt': generatedAt.toIso8601String(),
      'daily': daily.map((day) => day.toJson()).toList(),
    };
  }

  /// 转换为领域实体
  WeatherForecast toDomain() {
    return WeatherForecast(
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      timezoneOffset: timezoneOffset,
      generatedAt: generatedAt,
      daily: daily.map((d) => d.toDomain()).toList(),
    );
  }

  /* Legacy model removed - fromLegacyModel method disabled
  /// 从旧模型转换
  factory WeatherForecastDto.fromLegacyModel(
      legacy.WeatherForecastModel model) {
    return WeatherForecastDto(
      latitude: model.latitude,
      longitude: model.longitude,
      timezone: model.timezone,
      timezoneOffset: model.timezoneOffset,
      generatedAt: model.generatedAt,
      daily:
          model.daily.map((d) => DailyWeatherDto.fromLegacyModel(d)).toList(),
    );
  }
  */
}

/// DailyWeather DTO
class DailyWeatherDto {
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime? moonrise;
  final DateTime? moonset;
  final double? moonPhase;
  final double tempDay;
  final double tempNight;
  final double tempMin;
  final double tempMax;
  final double? tempEvening;
  final double? tempMorning;
  final double feelsLikeDay;
  final double feelsLikeNight;
  final double? feelsLikeEvening;
  final double? feelsLikeMorning;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDirection;
  final String? windDirectionDescription;
  final double? windGust;
  final int cloudiness;
  final double probabilityOfPrecipitation;
  final double? rainVolume;
  final double? snowVolume;
  final double uvIndex;
  final double? dewPoint;
  final String? summary;
  final String weather;
  final String weatherDescription;
  final String weatherIcon;

  DailyWeatherDto({
    required this.date,
    required this.sunrise,
    required this.sunset,
    this.moonrise,
    this.moonset,
    this.moonPhase,
    required this.tempDay,
    required this.tempNight,
    required this.tempMin,
    required this.tempMax,
    this.tempEvening,
    this.tempMorning,
    required this.feelsLikeDay,
    required this.feelsLikeNight,
    this.feelsLikeEvening,
    this.feelsLikeMorning,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    this.windDirectionDescription,
    this.windGust,
    required this.cloudiness,
    required this.probabilityOfPrecipitation,
    this.rainVolume,
    this.snowVolume,
    required this.uvIndex,
    this.dewPoint,
    this.summary,
    required this.weather,
    required this.weatherDescription,
    required this.weatherIcon,
  });

  factory DailyWeatherDto.fromJson(Map<String, dynamic> json) {
    return DailyWeatherDto(
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      sunrise: json['sunrise'] != null
          ? DateTime.parse(json['sunrise'] as String)
          : DateTime.now(),
      sunset: json['sunset'] != null
          ? DateTime.parse(json['sunset'] as String)
          : DateTime.now(),
      moonrise: json['moonrise'] != null
          ? DateTime.parse(json['moonrise'] as String)
          : null,
      moonset: json['moonset'] != null
          ? DateTime.parse(json['moonset'] as String)
          : null,
      moonPhase: (json['moonPhase'] as num?)?.toDouble(),
      tempDay: (json['tempDay'] as num?)?.toDouble() ?? 0,
      tempNight: (json['tempNight'] as num?)?.toDouble() ?? 0,
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 0,
      tempEvening: (json['tempEvening'] as num?)?.toDouble(),
      tempMorning: (json['tempMorning'] as num?)?.toDouble(),
      feelsLikeDay: (json['feelsLikeDay'] as num?)?.toDouble() ?? 0,
      feelsLikeNight: (json['feelsLikeNight'] as num?)?.toDouble() ?? 0,
      feelsLikeEvening: (json['feelsLikeEvening'] as num?)?.toDouble(),
      feelsLikeMorning: (json['feelsLikeMorning'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      pressure: (json['pressure'] as num?)?.toInt() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      windDirection: (json['windDirection'] as num?)?.toInt() ?? 0,
      windDirectionDescription: json['windDirectionDescription'] as String?,
      windGust: (json['windGust'] as num?)?.toDouble(),
      cloudiness: (json['cloudiness'] as num?)?.toInt() ?? 0,
      probabilityOfPrecipitation:
          (json['probabilityOfPrecipitation'] as num?)?.toDouble() ?? 0,
      rainVolume: (json['rainVolume'] as num?)?.toDouble(),
      snowVolume: (json['snowVolume'] as num?)?.toDouble(),
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0,
      dewPoint: (json['dewPoint'] as num?)?.toDouble(),
      summary: json['summary'] as String?,
      weather: json['weather'] as String? ?? '',
      weatherDescription: json['weatherDescription'] as String? ?? '',
      weatherIcon: json['weatherIcon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'moonrise': moonrise?.toIso8601String(),
      'moonset': moonset?.toIso8601String(),
      'moonPhase': moonPhase,
      'tempDay': tempDay,
      'tempNight': tempNight,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'tempEvening': tempEvening,
      'tempMorning': tempMorning,
      'feelsLikeDay': feelsLikeDay,
      'feelsLikeNight': feelsLikeNight,
      'feelsLikeEvening': feelsLikeEvening,
      'feelsLikeMorning': feelsLikeMorning,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'windDirectionDescription': windDirectionDescription,
      'windGust': windGust,
      'cloudiness': cloudiness,
      'probabilityOfPrecipitation': probabilityOfPrecipitation,
      'rainVolume': rainVolume,
      'snowVolume': snowVolume,
      'uvIndex': uvIndex,
      'dewPoint': dewPoint,
      'summary': summary,
      'weather': weather,
      'weatherDescription': weatherDescription,
      'weatherIcon': weatherIcon,
    };
  }

  /// 转换为领域实体
  DailyWeather toDomain() {
    return DailyWeather(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
      moonrise: moonrise,
      moonset: moonset,
      moonPhase: moonPhase,
      tempDay: tempDay,
      tempNight: tempNight,
      tempMin: tempMin,
      tempMax: tempMax,
      tempEvening: tempEvening,
      tempMorning: tempMorning,
      feelsLikeDay: feelsLikeDay,
      feelsLikeNight: feelsLikeNight,
      feelsLikeEvening: feelsLikeEvening,
      feelsLikeMorning: feelsLikeMorning,
      humidity: humidity,
      pressure: pressure,
      windSpeed: windSpeed,
      windDirection: windDirection,
      windDirectionDescription: windDirectionDescription,
      windGust: windGust,
      cloudiness: cloudiness,
      probabilityOfPrecipitation: probabilityOfPrecipitation,
      rainVolume: rainVolume,
      snowVolume: snowVolume,
      uvIndex: uvIndex,
      dewPoint: dewPoint,
      summary: summary,
      weather: weather,
      weatherDescription: weatherDescription,
      weatherIcon: weatherIcon,
    );
  }

  /* Legacy model removed - fromLegacyModel method disabled
  /// 从旧模型转换
  factory DailyWeatherDto.fromLegacyModel(legacy.DailyWeatherModel model) {
    return DailyWeatherDto(
      date: model.date,
      sunrise: model.sunrise,
      sunset: model.sunset,
      moonrise: model.moonrise,
      moonset: model.moonset,
      moonPhase: model.moonPhase,
      tempDay: model.tempDay,
      tempNight: model.tempNight,
      tempMin: model.tempMin,
      tempMax: model.tempMax,
      tempEvening: model.tempEvening,
      tempMorning: model.tempMorning,
      feelsLikeDay: model.feelsLikeDay,
      feelsLikeNight: model.feelsLikeNight,
      feelsLikeEvening: model.feelsLikeEvening,
      feelsLikeMorning: model.feelsLikeMorning,
      humidity: model.humidity,
      pressure: model.pressure,
      windSpeed: model.windSpeed,
      windDirection: model.windDirection,
      windDirectionDescription: model.windDirectionDescription,
      windGust: model.windGust,
      cloudiness: model.cloudiness,
      probabilityOfPrecipitation: model.probabilityOfPrecipitation,
      rainVolume: model.rainVolume,
      snowVolume: model.snowVolume,
      uvIndex: model.uvIndex,
      dewPoint: model.dewPoint,
      summary: model.summary,
      weather: model.weather,
      weatherDescription: model.weatherDescription,
      weatherIcon: model.weatherIcon,
    );
  }
  */
}
