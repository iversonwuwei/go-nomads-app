/// Weather Domain Entity
///
/// 纯粹的领域对象,不包含序列化逻辑
class Weather {
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
  final WeatherForecast? forecast;

  Weather({
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

  /// 获取风向描述
  String getWindDirectionText() {
    if (windDirectionDescription != null) return windDirectionDescription!;

    if (windDirection >= 337.5 || windDirection < 22.5) return '北风';
    if (windDirection >= 22.5 && windDirection < 67.5) return '东北风';
    if (windDirection >= 67.5 && windDirection < 112.5) return '东风';
    if (windDirection >= 112.5 && windDirection < 157.5) return '东南风';
    if (windDirection >= 157.5 && windDirection < 202.5) return '南风';
    if (windDirection >= 202.5 && windDirection < 247.5) return '西南风';
    if (windDirection >= 247.5 && windDirection < 292.5) return '西风';
    if (windDirection >= 292.5 && windDirection < 337.5) return '西北风';
    return '未知';
  }

  /// 判断是否需要更新(超过30分钟)
  bool needsUpdate() {
    return DateTime.now().difference(updatedAt).inMinutes > 30;
  }

  /// 获取天气状态描述
  String getWeatherStatus() {
    if (temperature < 0) return '严寒';
    if (temperature < 10) return '寒冷';
    if (temperature < 20) return '凉爽';
    if (temperature < 30) return '舒适';
    return '炎热';
  }
}

/// Weather Forecast Domain Entity
class WeatherForecast {
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final int? timezoneOffset;
  final DateTime generatedAt;
  final List<DailyWeather> daily;

  WeatherForecast({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneOffset,
    required this.generatedAt,
    required this.daily,
  });

  /// 获取未来N天的预报
  List<DailyWeather> getNextDays(int days) {
    return daily.take(days).toList();
  }

  /// 判断预报是否过期(超过6小时)
  bool isExpired() {
    return DateTime.now().difference(generatedAt).inHours > 6;
  }
}

/// Daily Weather Domain Entity
class DailyWeather {
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

  DailyWeather({
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

  /// 获取温差
  double getTemperatureRange() {
    return tempMax - tempMin;
  }

  /// 判断是否可能下雨
  bool isRainyDay() {
    return probabilityOfPrecipitation >= 0.5;
  }

  /// 获取UV等级描述
  String getUvIndexDescription() {
    if (uvIndex < 3) return '低';
    if (uvIndex < 6) return '中等';
    if (uvIndex < 8) return '高';
    if (uvIndex < 11) return '很高';
    return '极高';
  }
}
