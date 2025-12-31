import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Weather Tab 相关的工具方法
class WeatherUtils {
  WeatherUtils._();

  /// 根据 OpenWeatherMap 图标代码获取对应的 FontAwesome 图标
  ///
  /// OpenWeatherMap 图标代码格式: 01d, 01n, 02d, 02n, etc.
  /// 最后一个字符 'd' 表示白天, 'n' 表示夜晚
  static IconData getWeatherIcon(String weatherIcon, {bool isNight = false}) {
    final code = weatherIcon.replaceAll(RegExp(r'[dn]$'), '');

    switch (code) {
      case '01': // clear sky
        return isNight ? FontAwesomeIcons.moon : FontAwesomeIcons.sun;
      case '02': // few clouds
        return isNight ? FontAwesomeIcons.cloudMoon : FontAwesomeIcons.cloudSun;
      case '03': // scattered clouds
        return FontAwesomeIcons.cloud;
      case '04': // broken clouds
        return FontAwesomeIcons.cloudSun;
      case '09': // shower rain
        return FontAwesomeIcons.cloudShowersHeavy;
      case '10': // rain
        return isNight ? FontAwesomeIcons.cloudMoonRain : FontAwesomeIcons.cloudSunRain;
      case '11': // thunderstorm
        return FontAwesomeIcons.cloudBolt;
      case '13': // snow
        return FontAwesomeIcons.snowflake;
      case '50': // mist
        return FontAwesomeIcons.smog;
      default:
        return FontAwesomeIcons.cloudSun;
    }
  }

  /// 格式化天气时间
  static String formatWeatherTime(
    DateTime utc,
    int? offsetSeconds, {
    String pattern = 'HH:mm',
  }) {
    final localized = applyTimezoneOffset(utc, offsetSeconds);
    return DateFormat(pattern).format(localized);
  }

  /// 应用时区偏移
  static DateTime applyTimezoneOffset(DateTime utc, int? offsetSeconds) {
    final offset = Duration(seconds: offsetSeconds ?? 0);
    final adjusted = utc.add(offset);
    return DateTime.fromMillisecondsSinceEpoch(
      adjusted.millisecondsSinceEpoch,
      isUtc: false,
    );
  }

  /// 格式化时区显示
  static String formatTimezone(int? offsetSeconds) {
    if (offsetSeconds == null) {
      return 'UTC';
    }

    final totalMinutes = offsetSeconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes.abs() % 60;
    final sign = offsetSeconds >= 0 ? '+' : '-';

    return 'UTC$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// 格式化日期名称（今天、明天、或星期几）
  static String formatDayName(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return l10n.today;
    } else if (difference == 1) {
      return l10n.tomorrow;
    } else {
      final weekday = date.weekday;
      switch (weekday) {
        case DateTime.monday:
          return l10n.monday;
        case DateTime.tuesday:
          return l10n.tuesday;
        case DateTime.wednesday:
          return l10n.wednesday;
        case DateTime.thursday:
          return l10n.thursday;
        case DateTime.friday:
          return l10n.friday;
        case DateTime.saturday:
          return l10n.saturday;
        case DateTime.sunday:
          return l10n.sunday;
        default:
          return DateFormat('EEE').format(date);
      }
    }
  }

  /// 描述空气质量指数
  static String describeAqi(int aqi, AppLocalizations l10n) {
    if (aqi <= 50) return l10n.aqiGood;
    if (aqi <= 100) return l10n.aqiModerate;
    if (aqi <= 150) return l10n.aqiUnhealthySensitive;
    if (aqi <= 200) return l10n.aqiUnhealthy;
    if (aqi <= 300) return l10n.aqiVeryUnhealthy;
    return l10n.aqiHazardous;
  }

  /// 获取空气质量对应的颜色
  static Color getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  /// 将风速从 m/s 转换为 km/h
  static String formatWindSpeed(double windSpeedMs, {int decimals = 1}) {
    return (windSpeedMs * 3.6).toStringAsFixed(decimals);
  }

  /// 将能见度从 m 转换为 km
  static String formatVisibility(int visibilityM, {int decimals = 1}) {
    return (visibilityM / 1000).toStringAsFixed(decimals);
  }

  /// 格式化天气描述（首字母大写）
  static String formatWeatherDescription(String description, String fallback) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) return fallback;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}
