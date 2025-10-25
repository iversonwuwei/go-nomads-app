/// 天气信息模型
class WeatherModel {
  final double temperature;
  final double feelsLike;
  final double? tempMin;
  final double? tempMax;
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

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    this.tempMin,
    this.tempMax,
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
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0.0,
      tempMin: (json['tempMin'] as num?)?.toDouble(),
      tempMax: (json['tempMax'] as num?)?.toDouble(),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'tempMin': tempMin,
      'tempMax': tempMax,
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
    };
  }
}
