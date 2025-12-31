import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/features/weather/domain/entities/weather.dart';
import 'weather_utils.dart';

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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMainInfo(description),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildMiniInfoRow(),
          const SizedBox(height: 16),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      height: 0.95,
                      letterSpacing: -2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 天气描述
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              // 城市名称
              if (cityName.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.locationDot,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cityName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FaIcon(
            WeatherUtils.getWeatherIcon(
              weather.weatherIcon,
              isNight: weather.weatherIcon.endsWith('n'),
            ),
            color: Colors.white,
            size: 64,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
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
          width: 1,
          height: 40,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        _WeatherMiniInfo(
          icon: FontAwesomeIcons.droplet,
          label: l10n.humidity,
          value: '${weather.humidity}%',
        ),
        Container(
          width: 1,
          height: 40,
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
        fontSize: 12,
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
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
