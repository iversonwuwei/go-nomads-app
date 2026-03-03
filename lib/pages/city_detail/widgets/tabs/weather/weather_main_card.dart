import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/features/weather/domain/entities/weather.dart';
import 'weather_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 主天气卡片 - 显示当前温度、天气描述、城市名等
class WeatherMainCard extends StatelessWidget {
  const WeatherMainCard({
    super.key,
    required this.weather,
    required this.cityName,
    required this.l10n,
  });

  final Weather weather;
  final String cityName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final description = WeatherUtils.formatWeatherDescription(
      weather.weatherDescription,
      weather.weather,
    );
    final timezone = WeatherUtils.formatTimezone(weather.timezoneOffset);
    final updatedAt = WeatherUtils.formatWeatherTime(
      weather.updatedAt,
      weather.timezoneOffset,
      pattern: 'MMM d, HH:mm',
    );

    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.4),
            blurRadius: 24.r,
            offset: const Offset(0, 12),
            spreadRadius: 4.r,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMainInfo(description),
          SizedBox(height: 20.h),
          _buildDivider(),
          SizedBox(height: 20.h),
          _buildMiniInfoRow(),
          SizedBox(height: 16.h),
          _buildUpdateTime(timezone, updatedAt),
        ],
      ),
    );
  }

  Widget _buildMainInfo(String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 温度显示
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.temperature.toStringAsFixed(0),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 72.sp,
                      fontWeight: FontWeight.bold,
                      height: 0.95,
                      letterSpacing: -2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      '°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // 天气描述
              Text(
                description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3.sp,
                ),
              ),
              SizedBox(height: 6.h),
              // 城市名称
              if (cityName.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.locationDot,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      cityName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // 天气图标
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: FaIcon(
            WeatherUtils.getWeatherIcon(
              weather.weatherIcon,
              isNight: weather.weatherIcon.endsWith('n'),
            ),
            color: Colors.white,
            size: 64.r,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _WeatherMiniInfo(
          icon: FontAwesomeIcons.temperatureHalf,
          label: l10n.feelsLike,
          value: '${weather.feelsLike.toStringAsFixed(0)}°',
        ),
        Container(
          width: 1.w,
          height: 40.h,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        _WeatherMiniInfo(
          icon: FontAwesomeIcons.droplet,
          label: l10n.humidity,
          value: '${weather.humidity}%',
        ),
        Container(
          width: 1.w,
          height: 40.h,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        _WeatherMiniInfo(
          icon: FontAwesomeIcons.wind,
          label: l10n.wind,
          value: '${WeatherUtils.formatWindSpeed(weather.windSpeed, decimals: 0)} km/h',
        ),
      ],
    );
  }

  Widget _buildUpdateTime(String timezone, String updatedAt) {
    return Text(
      '$timezone • ${l10n.updated} $updatedAt',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// 迷你天气信息组件
class _WeatherMiniInfo extends StatelessWidget {
  const _WeatherMiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 24.r,
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
