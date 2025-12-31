import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/features/weather/domain/entities/weather.dart';
import 'weather_utils.dart';

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
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: forecast.daily.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.fiveDayForecast,
            style: const TextStyle(
              fontSize: 20,
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
      width: 140,
      margin: EdgeInsets.only(right: isLast ? 0 : 16),
      decoration: BoxDecoration(
        gradient: isToday
            ? const LinearGradient(
                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(24),
        border: isToday
            ? null
            : Border.all(
                color: Colors.grey.shade200,
                width: 1.5,
              ),
        boxShadow: [
          BoxShadow(
            color: isToday ? const Color(0xFFFF4458).withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.06),
            blurRadius: isToday ? 20 : 12,
            offset: Offset(0, isToday ? 8 : 4),
            spreadRadius: isToday ? 2 : 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isToday ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFFF4458).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        dayName,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isToday ? Colors.white : const Color(0xFFFF4458),
          letterSpacing: 0.5,
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
      color: isToday ? Colors.white : Colors.orange.shade600,
      size: 48,
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.grey.shade900,
                height: 1.0,
              ),
            ),
            Text(
              '°',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade700,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 最低温度
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              FontAwesomeIcons.arrowDown,
              size: 12,
              color: isToday ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade500,
            ),
            const SizedBox(width: 2),
            Text(
              day.tempMin.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600,
              ),
            ),
            Text(
              '°',
              style: TextStyle(
                fontSize: 12,
                color: isToday ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
