import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'weather_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 日出日落信息卡片
class SunriseSunsetCard extends StatelessWidget {
  const SunriseSunsetCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.timezoneOffset,
    required this.l10n,
  });

  final DateTime sunrise;
  final DateTime sunset;
  final int? timezoneOffset;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final sunriseTime = WeatherUtils.formatWeatherTime(sunrise, timezoneOffset);
    final sunsetTime = WeatherUtils.formatWeatherTime(sunset, timezoneOffset);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sunriseSunset,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSunriseRow(sunriseTime),
          SizedBox(height: 12.h),
          _buildSunsetRow(sunsetTime),
        ],
      ),
    );
  }

  Widget _buildSunriseRow(String time) {
    return Row(
      children: [
        Icon(FontAwesomeIcons.solidSun, color: AppColors.travelAmber, size: 20.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            l10n.sunrise,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSunsetRow(String time) {
    return Row(
      children: [
        Icon(FontAwesomeIcons.solidMoon, color: AppColors.travelSky, size: 20.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            l10n.sunset,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 数据源信息卡片
class DataSourceCard extends StatelessWidget {
  const DataSourceCard({
    super.key,
    required this.dataSource,
    required this.timezoneOffset,
    required this.l10n,
  });

  final String? dataSource;
  final int? timezoneOffset;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final timezone = WeatherUtils.formatTimezone(timezoneOffset);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dataSource,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            dataSource ?? 'OpenWeatherMap',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${l10n.timezone}: $timezone',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
