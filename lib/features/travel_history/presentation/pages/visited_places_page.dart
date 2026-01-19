import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/visited_place.dart';
import '../controllers/visited_places_controller.dart';

/// 访问地点列表页面
/// 两个卡片布局：城市信息卡片 + 访问地点列表卡片
class VisitedPlacesPage extends GetView<VisitedPlacesController> {
  const VisitedPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: _buildAppBar(theme),
      body: Obx(() {
        if (controller.isLoading.value && controller.isCityLoading.value) {
          return const ManageListSkeleton();
        }

        if (controller.error.value.isNotEmpty && controller.places.isEmpty) {
          return _buildErrorView(context, theme);
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              // 城市信息卡片
              SliverToBoxAdapter(
                child: _buildCityInfoCard(context, theme),
              ),

              // 间距
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // 访问地点列表卡片标题
              SliverToBoxAdapter(
                child: _buildVisitedPlacesHeader(theme),
              ),

              // 访问地点列表（无限滚动）
              _buildPlacesListSliver(context, theme),

              // 加载更多指示器
              _buildLoadMoreIndicator(theme),

              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ==================== AppBar ====================

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => Text(
            controller.tripTitle.value.isNotEmpty ? controller.tripTitle.value : 'Visited Places',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          )),
      actions: [
        if (controller.places.isNotEmpty)
          IconButton(
            icon: Icon(FontAwesomeIcons.map, size: 18, color: theme.colorScheme.onSurface),
            onPressed: () {
              AppToast.info('Map view will be available soon');
            },
          ),
      ],
    );
  }

  // ==================== 城市信息卡片 ====================

  Widget _buildCityInfoCard(BuildContext context, ThemeData theme) {
    return Obx(() {
      final citySummary = controller.citySummary.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: _buildCityImage(theme),
              ),
            ),

            // 城市信息内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 城市名称和国家
                  Text(
                    controller.tripTitle.value.isNotEmpty ? controller.tripTitle.value : 'Unknown City',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 城市实时信息行（天气、评分、花费、Coworking）
                  if (citySummary != null || controller.isCityLoading.value) _buildCityMetrics(theme),

                  // 旅行日期和停留时长
                  if (controller.travelDate.value != null || controller.totalDurationDays.value > 0) ...[
                    const SizedBox(height: 12),
                    _buildTravelDateInfo(theme),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCityImage(ThemeData theme) {
    final imageUrl = controller.cityImageUrl.value;

    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              FontAwesomeIcons.city,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              FontAwesomeIcons.city,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.city,
          size: 48,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildCityMetrics(ThemeData theme) {
    if (controller.isCityLoading.value && controller.citySummary.value == null) {
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final weather = controller.weather.value;
    final overallScore = controller.overallScore.value;
    final averageCost = controller.averageMonthlyCost.value;
    final coworkingCount = controller.coworkingSpaceCount.value;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // 温度
        if (weather != null)
          _buildMetricChip(
            theme,
            icon: FontAwesomeIcons.temperatureHalf,
            value: weather.formattedTemperature,
            iconColor: Colors.orange,
          ),

        // 天气
        if (weather != null && weather.condition.isNotEmpty)
          _buildMetricChip(
            theme,
            icon: _getWeatherIcon(weather.condition),
            value: weather.condition,
            iconColor: Colors.blue,
          ),

        // 评分
        if (overallScore != null)
          _buildMetricChip(
            theme,
            icon: FontAwesomeIcons.star,
            value: overallScore.toStringAsFixed(1),
            iconColor: Colors.amber,
          ),

        // 月均花费
        if (averageCost != null)
          _buildMetricChip(
            theme,
            icon: FontAwesomeIcons.dollarSign,
            value: '\$${averageCost.round()}/mo',
            iconColor: Colors.green,
          ),

        // 共享办公数量
        if (coworkingCount > 0)
          _buildMetricChip(
            theme,
            icon: FontAwesomeIcons.laptop,
            value: '$coworkingCount coworking',
            iconColor: Colors.purple,
          ),
      ],
    );
  }

  Widget _buildMetricChip(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelDateInfo(ThemeData theme) {
    final travelDate = controller.travelDate.value;
    final lastVisitDate = controller.lastVisitDate.value;
    final durationDays = controller.totalDurationDays.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.calendar,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _formatTravelDates(travelDate, lastVisitDate),
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (durationDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$durationDays days',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== 访问地点列表卡片 ====================

  Widget _buildVisitedPlacesHeader(ThemeData theme) {
    return Obx(() {
      if (controller.places.isEmpty && !controller.isLoading.value) {
        return _buildEmptyView(theme);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 列表标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Visited Places',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.totalCount.value} places',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 统计摘要
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.clock,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  controller.formattedTotalDuration,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  FontAwesomeIcons.solidStar,
                  size: 12,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  '${controller.highlightCount.value} highlights',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }

  IconData _getWeatherIcon(String weather) {
    final lower = weather.toLowerCase();
    if (lower.contains('sun') || lower.contains('clear')) return FontAwesomeIcons.sun;
    if (lower.contains('cloud')) return FontAwesomeIcons.cloud;
    if (lower.contains('rain')) return FontAwesomeIcons.cloudRain;
    if (lower.contains('snow')) return FontAwesomeIcons.snowflake;
    if (lower.contains('thunder') || lower.contains('storm')) return FontAwesomeIcons.cloudBolt;
    if (lower.contains('fog') || lower.contains('mist')) return FontAwesomeIcons.smog;
    return FontAwesomeIcons.cloudSun;
  }

  String _formatTravelDates(DateTime? startDate, DateTime? endDate) {
    final dateFormat = DateFormat('MMM d, yyyy');

    if (startDate == null) {
      return 'No date info';
    }

    final start = dateFormat.format(startDate);

    if (endDate != null) {
      final end = dateFormat.format(endDate);
      // 如果是同一天
      if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day) {
        return start;
      }
      return '$start - $end';
    }

    return '$start - Present';
  }

  // ==================== 访问地点列表（无限滚动）====================

  Widget _buildPlacesListSliver(BuildContext context, ThemeData theme) {
    return Obx(() {
      if (controller.places.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // 当滚动到接近底部时，触发加载更多
              if (index == controller.places.length - 3 && controller.hasMore.value) {
                controller.loadMore();
              }

              final place = controller.places[index];
              return _buildPlaceCard(context, theme, place, index);
            },
            childCount: controller.places.length,
          ),
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator(ThemeData theme) {
    return Obx(() {
      if (!controller.isLoadingMore.value) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    });
  }

  // ==================== 错误和空状态视图 ====================

  Widget _buildErrorView(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.circleExclamation,
            size: 64,
            color: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            controller.error.value,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.loadVisitedPlaces,
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.locationDot,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No visited places yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Places where you stayed for more than 40 minutes will appear here',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, ThemeData theme, VisitedPlace place, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPlaceDetails(context, theme, place, index),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 时间线指示器
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: place.isHighlight ? const Color(0xFFF59E0B) : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index < controller.places.length - 1)
                        Container(
                          width: 2,
                          height: 60,
                          color: theme.colorScheme.outlineVariant,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // 地点图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getPlaceColor(place.iconType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPlaceIcon(place.iconType),
                      color: _getPlaceColor(place.iconType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 地点信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                place.placeName ?? 'Unknown Place',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (place.isHighlight)
                              const Icon(
                                FontAwesomeIcons.solidStar,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                          ],
                        ),
                        if (place.placeType != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatPlaceType(place.placeType!),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.clock,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimeRange(place.arrivalTime, place.departureTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                place.formattedDuration,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 箭头
                  Icon(
                    FontAwesomeIcons.chevronRight,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPlaceIcon(String iconType) {
    switch (iconType) {
      case 'food':
        return FontAwesomeIcons.utensils;
      case 'hotel':
        return FontAwesomeIcons.bed;
      case 'nature':
        return FontAwesomeIcons.tree;
      case 'shopping':
        return FontAwesomeIcons.bagShopping;
      case 'culture':
        return FontAwesomeIcons.landmark;
      case 'work':
        return FontAwesomeIcons.briefcase;
      case 'entertainment':
        return FontAwesomeIcons.music;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  Color _getPlaceColor(String iconType) {
    switch (iconType) {
      case 'food':
        return const Color(0xFFEF4444);
      case 'hotel':
        return const Color(0xFF8B5CF6);
      case 'nature':
        return const Color(0xFF22C55E);
      case 'shopping':
        return const Color(0xFFF59E0B);
      case 'culture':
        return const Color(0xFF3B82F6);
      case 'work':
        return const Color(0xFF6366F1);
      case 'entertainment':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatPlaceType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
        .join(' ');
  }

  String _formatTimeRange(DateTime arrival, DateTime departure) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM d');

    if (arrival.day == departure.day) {
      return '${timeFormat.format(arrival)} - ${timeFormat.format(departure)}';
    } else {
      return '${dateFormat.format(arrival)} ${timeFormat.format(arrival)} - ${dateFormat.format(departure)} ${timeFormat.format(departure)}';
    }
  }

  void _showPlaceDetails(BuildContext context, ThemeData theme, VisitedPlace place, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlaceDetailsSheet(
        place: place,
        theme: theme,
        onToggleHighlight: () {
          controller.toggleHighlightAtIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _PlaceDetailsSheet extends StatelessWidget {
  final VisitedPlace place;
  final ThemeData theme;
  final VoidCallback onToggleHighlight;

  const _PlaceDetailsSheet({
    required this.place,
    required this.theme,
    required this.onToggleHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和精选按钮
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.placeName ?? 'Unknown Place',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onToggleHighlight,
                      icon: Icon(
                        place.isHighlight ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                        color: place.isHighlight ? const Color(0xFFF59E0B) : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                if (place.placeType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    place.placeType!.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // 时间信息
                _buildInfoRow(
                  theme,
                  icon: FontAwesomeIcons.clock,
                  label: 'Duration',
                  value: place.formattedDuration,
                ),

                const SizedBox(height: 12),

                _buildInfoRow(
                  theme,
                  icon: FontAwesomeIcons.calendar,
                  label: 'Arrival',
                  value: DateFormat('MMM d, yyyy HH:mm').format(place.arrivalTime),
                ),

                const SizedBox(height: 12),

                _buildInfoRow(
                  theme,
                  icon: FontAwesomeIcons.calendarCheck,
                  label: 'Departure',
                  value: DateFormat('MMM d, yyyy HH:mm').format(place.departureTime),
                ),

                if (place.address != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    theme,
                    icon: FontAwesomeIcons.locationDot,
                    label: 'Address',
                    value: place.address!,
                  ),
                ],

                if (place.notes != null && place.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: 在地图中查看
                          AppToast.info('View on map will be available soon');
                        },
                        icon: const Icon(FontAwesomeIcons.map, size: 16),
                        label: const Text('View on Map'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: 添加备注
                          Navigator.pop(context);
                        },
                        icon: const Icon(FontAwesomeIcons.pen, size: 16),
                        label: const Text('Add Notes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
