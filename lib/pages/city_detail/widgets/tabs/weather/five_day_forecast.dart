import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/features/weather/domain/entities/weather.dart';
import 'weather_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 5天天气预报组件
class FiveDayForecast extends StatelessWidget {
  const FiveDayForecast({
    super.key,
    required this.forecast,
    required this.l10n,
  });

  final WeatherForecast forecast;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (forecast.daily.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: forecast.daily.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (context, index) {
              final day = forecast.daily[index];
              final isToday = index == 0;
              final dayName = isToday ? l10n.today : WeatherUtils.formatDayName(day.date, l10n);

              return _ForecastDayCard(
                day: day,
                dayName: dayName,
                isToday: isToday,
                isLast: index == forecast.daily.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: AppColors.cityPrimary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            l10n.fiveDayForecast,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单日预报卡片
class _ForecastDayCard extends StatelessWidget {
  const _ForecastDayCard({
    required this.day,
    required this.dayName,
    required this.isToday,
    required this.isLast,
  });

  final DailyWeather day;
  final String dayName;
  final bool isToday;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: isLast ? 0 : 16),
      decoration: BoxDecoration(
        gradient: isToday
            ? const LinearGradient(
                colors: [Color(0xFFFFF5F2), Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, const Color(0xFFF8FAFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isToday ? AppColors.cityPrimaryLight : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 16.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDayLabel(),
            _buildWeatherIcon(),
            _buildTemperature(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayLabel() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: isToday ? AppColors.cityPrimaryLight : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        dayName,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: isToday ? AppColors.cityPrimary : AppColors.textPrimary,
          letterSpacing: 0.5.sp,
        ),
      ),
    );
  }

  Widget _buildWeatherIcon() {
    return FaIcon(
      WeatherUtils.getWeatherIcon(
        day.weatherIcon,
        isNight: false,
      ),
      color: isToday ? AppColors.cityPrimary : AppColors.travelAmber,
      size: 48.r,
    );
  }

  Widget _buildTemperature() {
    return Column(
      children: [
        // 最高温度
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day.tempMax.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: isToday ? AppColors.textPrimary : Colors.grey.shade900,
                height: 1.0,
              ),
            ),
            Text(
              '°',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isToday ? AppColors.cityPrimary : Colors.grey.shade700,
                height: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        // 最低温度
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              FontAwesomeIcons.arrowDown,
              size: 12.r,
              color: isToday ? AppColors.textSecondary : Colors.grey.shade500,
            ),
            SizedBox(width: 2.w),
            Text(
              day.tempMin.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isToday ? AppColors.textSecondary : Colors.grey.shade600,
              ),
            ),
            Text(
              '°',
              style: TextStyle(
                fontSize: 12.sp,
                color: isToday ? AppColors.textTertiary : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
