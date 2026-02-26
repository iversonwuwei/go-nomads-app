import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sunriseSunset,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
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
        Icon(FontAwesomeIcons.solidSun, color: Colors.orange, size: 20.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            l10n.sunrise,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSunsetRow(String time) {
    return Row(
      children: [
        Icon(FontAwesomeIcons.solidMoon, color: Color(0xFF5B6FD8), size: 20.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            l10n.sunset,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dataSource,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            dataSource ?? 'OpenWeatherMap',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${l10n.timezone}: $timezone',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
