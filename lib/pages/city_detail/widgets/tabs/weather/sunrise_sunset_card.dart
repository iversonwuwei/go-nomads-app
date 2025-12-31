import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'weather_utils.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sunriseSunset,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSunriseRow(sunriseTime),
          const SizedBox(height: 12),
          _buildSunsetRow(sunsetTime),
        ],
      ),
    );
  }

  Widget _buildSunriseRow(String time) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.solidSun, color: Colors.orange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.sunrise,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSunsetRow(String time) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.solidMoon, color: Color(0xFF5B6FD8), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.sunset,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dataSource,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dataSource ?? 'OpenWeatherMap',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.timezone}: $timezone',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
