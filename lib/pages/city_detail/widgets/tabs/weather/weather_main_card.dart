import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
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
          colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF), Color(0xFFFFF7F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.heroCardShadow,
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
                      color: AppColors.textPrimary,
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
                        color: AppColors.cityPrimary,
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
                  color: AppColors.textPrimary,
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
                      color: AppColors.cityPrimary,
                      size: 16.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      cityName,
                      style: TextStyle(
                        color: AppColors.textSecondary,
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
            color: AppColors.cityPrimaryLight,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: FaIcon(
            WeatherUtils.getWeatherIcon(
              weather.weatherIcon,
              isNight: weather.weatherIcon.endsWith('n'),
            ),
            color: AppColors.cityPrimary,
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
            AppColors.borderLight.withValues(alpha: 0.0),
            AppColors.borderLight,
            AppColors.borderLight.withValues(alpha: 0.0),
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
        color: AppColors.textTertiary,
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
          color: AppColors.cityPrimary,
          size: 24.r,
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
