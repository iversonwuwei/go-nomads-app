import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../features/weather/presentation/controllers/weather_state_controller.dart';
import '../../../city_detail_controller.dart';
import 'five_day_forecast.dart';
import 'sunrise_sunset_card.dart';
import 'weather_main_card.dart';
import 'weather_metric_card.dart';
import 'weather_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Weather Tab - GetView 实现
class WeatherTab extends GetView<CityDetailController> {
  const WeatherTab({super.key, required String tag}) : weatherTag = tag;

  final String weatherTag;

  @override
  String? get tag => weatherTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weatherController = Get.find<WeatherStateController>();

    return Obx(() {
      // 显示加载状态
      if (weatherController.isLoading.value) {
        return const WeatherTabSkeleton();
      }

      final weather = weatherController.weather.value;
      if (weather == null) {
        return _WeatherEmptyState(
          cityId: controller.cityId,
          l10n: l10n,
        );
      }

      return _WeatherContent(
        weatherTag: weatherTag,
        l10n: l10n,
      );
    });
  }
}

/// 空状态组件
class _WeatherEmptyState extends StatelessWidget {
  const _WeatherEmptyState({
    required this.cityId,
    required this.l10n,
  });

  final String cityId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final weatherController = Get.find<WeatherStateController>();

    return RefreshIndicator(
      onRefresh: () => weatherController.loadCityWeather(cityId, forceRefresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    l10n.noData,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 天气内容组件
class _WeatherContent extends GetView<CityDetailController> {
  const _WeatherContent({
    required String weatherTag,
    required this.l10n,
  }) : _weatherTag = weatherTag;

  final String _weatherTag;
  final AppLocalizations l10n;

  @override
  String? get tag => _weatherTag;

  @override
  Widget build(BuildContext context) {
    final weatherController = Get.find<WeatherStateController>();
    final weather = weatherController.weather.value!;

    // 构建天气指标数据
    final metrics = _buildMetrics(weather);

    return RefreshIndicator(
      onRefresh: () => weatherController.loadCityWeather(controller.cityId, forceRefresh: true),
      child: ListView(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h, bottom: 96.h),
        children: [
          // 主天气卡片
          WeatherMainCard(
            weather: weather,
            cityName: controller.cityName,
            l10n: l10n,
          ),
          SizedBox(height: 24.h),

          // 天气指标网格
          WeatherMetricsGrid(metrics: metrics),
          SizedBox(height: 24.h),

          // 日出日落卡片
          SunriseSunsetCard(
            sunrise: weather.sunrise,
            sunset: weather.sunset,
            timezoneOffset: weather.timezoneOffset,
            l10n: l10n,
          ),

          // 5天预报
          if (weather.forecast?.daily.isNotEmpty == true) ...[
            SizedBox(height: 32.h),
            FiveDayForecast(
              forecast: weather.forecast!,
              l10n: l10n,
            ),
          ],

          SizedBox(height: 16.h),

          // 数据源卡片
          DataSourceCard(
            dataSource: weather.dataSource,
            timezoneOffset: weather.timezoneOffset,
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  List<WeatherMetricData> _buildMetrics(dynamic weather) {
    final windSpeedKmh = WeatherUtils.formatWindSpeed(weather.windSpeed);
    final visibilityKm = WeatherUtils.formatVisibility(weather.visibility);
    final windSubtitle = weather.windDirectionDescription?.isNotEmpty == true
        ? weather.windDirectionDescription!
        : '${weather.windDirection}°';

    final metrics = <WeatherMetricData>[
      WeatherMetricData(
        icon: FontAwesomeIcons.temperatureHalf,
        label: l10n.feelsLike,
        value: '${weather.feelsLike.toStringAsFixed(1)}°C',
      ),
      WeatherMetricData(
        icon: FontAwesomeIcons.droplet,
        label: l10n.humidity,
        value: '${weather.humidity}%',
      ),
      WeatherMetricData(
        icon: FontAwesomeIcons.wind,
        label: l10n.wind,
        value: '$windSpeedKmh km/h',
        subtitle: windSubtitle,
      ),
      WeatherMetricData(
        icon: FontAwesomeIcons.gaugeHigh,
        label: l10n.pressure,
        value: '${weather.pressure} hPa',
      ),
      WeatherMetricData(
        icon: FontAwesomeIcons.cloud,
        label: l10n.cloudiness,
        value: '${weather.cloudiness}%',
      ),
      WeatherMetricData(
        icon: FontAwesomeIcons.eye,
        label: l10n.visibility,
        value: '$visibilityKm km',
      ),
    ];

    // 空气质量指数
    if (weather.airQualityIndex != null) {
      metrics.add(
        WeatherMetricData(
          icon: FontAwesomeIcons.lungs,
          label: l10n.airQuality,
          value: '${weather.airQualityIndex}',
          subtitle: WeatherUtils.describeAqi(weather.airQualityIndex!, l10n),
        ),
      );
    }

    // 紫外线指数
    if (weather.uvIndex != null) {
      metrics.add(
        WeatherMetricData(
          icon: FontAwesomeIcons.sun,
          label: l10n.uvIndex,
          value: weather.uvIndex!.toStringAsFixed(1),
          iconColor: Colors.amber[700],
        ),
      );
    }

    return metrics;
  }
}
