/// 天气信息模型
class WeatherModel {
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
  final WeatherForecastModel? forecast;

  WeatherModel({
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

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
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
          ? WeatherForecastModel.fromJson(
              json['forecast'] as Map<String, dynamic>,
            )
          : json['forecast'] is Map
              ? WeatherForecastModel.fromJson(
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
}

class WeatherForecastModel {
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final int? timezoneOffset;
  final DateTime generatedAt;
  final List<DailyWeatherModel> daily;

  WeatherForecastModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneOffset,
    required this.generatedAt,
    required this.daily,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    final dailyData = json['daily'];
    List<DailyWeatherModel> dailyList = [];
    if (dailyData is List) {
      dailyList = dailyData
          .map((item) => item is Map<String, dynamic>
              ? DailyWeatherModel.fromJson(item)
              : DailyWeatherModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
          .toList();
    }

    return WeatherForecastModel(
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
}

class DailyWeatherModel {
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

  DailyWeatherModel({
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

  factory DailyWeatherModel.fromJson(Map<String, dynamic> json) {
    return DailyWeatherModel(
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
}
