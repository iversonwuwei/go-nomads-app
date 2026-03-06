import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
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
        final showInitialLoading = controller.isLoading.value && controller.isCityLoading.value;

        final content = controller.error.value.isNotEmpty && controller.places.isEmpty
            ? _buildErrorView(context, theme)
            : RefreshIndicator(
                onRefresh: controller.refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildCityInfoCard(context, theme),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 16.h),
                    ),
                    SliverToBoxAdapter(
                      child: _buildVisitedPlacesHeader(theme),
                    ),
                    _buildPlacesListSliver(context, theme),
                    _buildLoadMoreIndicator(theme),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 24.h),
                    ),
                  ],
                ),
              );

        return AppLoadingSwitcher(
          isLoading: showInitialLoading,
          loading: const ManageListSkeleton(),
          child: content,
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
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          )),
      actions: [
        if (controller.places.isNotEmpty)
          IconButton(
            icon: Icon(FontAwesomeIcons.map, size: 18.r, color: theme.colorScheme.onSurface),
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
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 16.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: SizedBox(
                height: 160.h,
                width: double.infinity,
                child: _buildCityImage(theme),
              ),
            ),

            // 城市信息内容
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 城市名称和国家
                  Text(
                    controller.tripTitle.value.isNotEmpty ? controller.tripTitle.value : 'Unknown City',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // 城市实时信息行（天气、评分、花费、Coworking）
                  if (citySummary != null || controller.isCityLoading.value) _buildCityMetrics(theme),

                  // 旅行日期和停留时长
                  if (controller.travelDate.value != null || controller.totalDurationDays.value > 0) ...[
                    SizedBox(height: 12.h),
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
              size: 48.r,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              FontAwesomeIcons.city,
              size: 48.r,
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
          size: 48.r,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildCityMetrics(ThemeData theme) {
    if (controller.isCityLoading.value && controller.citySummary.value == null) {
      return Center(
        child: SizedBox(
          height: 20.h,
          width: 20.w,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final weather = controller.weather.value;
    final overallScore = controller.overallScore.value;
    final averageCost = controller.averageMonthlyCost.value;
    final coworkingCount = controller.coworkingSpaceCount.value;

    return Wrap(
      spacing: 12.w,
      runSpacing: 8.w,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: iconColor),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.calendar,
            size: 14.r,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              _formatTravelDates(travelDate, lastVisitDate),
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (durationDays > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$durationDays days',
                style: TextStyle(
                  fontSize: 12.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${controller.totalCount.value} places',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // 统计摘要
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.clock,
                  size: 12.r,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 4.w),
                Text(
                  controller.formattedTotalDuration,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(
                  FontAwesomeIcons.solidStar,
                  size: 12.r,
                  color: const Color(0xFFF59E0B),
                ),
                SizedBox(width: 4.w),
                Text(
                  '${controller.highlightCount.value} highlights',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: SizedBox(
              width: 24.w,
              height: 24.h,
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
            size: 64.r,
            color: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
          SizedBox(height: 16.h),
          Text(
            controller.error.value,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: controller.loadVisitedPlaces,
            icon: Icon(FontAwesomeIcons.arrowsRotate, size: 18.r),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.locationDot,
              size: 40.r,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No visited places yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Places where you stayed for more than 40 minutes will appear here',
            style: TextStyle(
              fontSize: 13.sp,
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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPlaceDetails(context, theme, place, index),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // 时间线指示器
                  Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: place.isHighlight ? const Color(0xFFF59E0B) : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index < controller.places.length - 1)
                        Container(
                          width: 2.w,
                          height: 60.h,
                          color: theme.colorScheme.outlineVariant,
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),

                  // 地点图标
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: _getPlaceColor(place.iconType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _getPlaceIcon(place.iconType),
                      color: _getPlaceColor(place.iconType),
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),

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
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (place.isHighlight)
                              Icon(
                                FontAwesomeIcons.solidStar,
                                size: 14.r,
                                color: Color(0xFFF59E0B),
                              ),
                          ],
                        ),
                        if (place.placeType != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            _formatPlaceType(place.placeType!),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.clock,
                              size: 12.r,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatTimeRange(place.arrivalTime, place.departureTime),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                place.formattedDuration,
                                style: TextStyle(
                                  fontSize: 11.sp,
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
                    size: 14.r,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(24.w),
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
                          fontSize: 22.sp,
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
                  SizedBox(height: 4.h),
                  Text(
                    place.placeType!.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5.sp,
                    ),
                  ),
                ],

                SizedBox(height: 16.h),

                // 时间信息
                _buildInfoRow(
                  theme,
                  icon: FontAwesomeIcons.clock,
                  label: 'Duration',
                  value: place.formattedDuration,
                ),

                SizedBox(height: 12.h),

                _buildInfoRow(
                  theme,
                  icon: FontAwesomeIcons.calendar,
                  label: 'Arrival',
                  value: DateFormat('MMM d, yyyy HH:mm').format(place.arrivalTime),
                ),

                SizedBox(height: 12.h),

                _buildInfoRow(
                  theme,
                  icon: FontAwesomeIcons.calendarCheck,
                  label: 'Departure',
                  value: DateFormat('MMM d, yyyy HH:mm').format(place.departureTime),
                ),

                if (place.address != null) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    theme,
                    icon: FontAwesomeIcons.locationDot,
                    label: 'Address',
                    value: place.address!,
                  ),
                ],

                if (place.notes != null && place.notes!.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    place.notes!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],

                SizedBox(height: 24.h),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: 在地图中查看
                          AppToast.info('View on map will be available soon');
                        },
                        icon: Icon(FontAwesomeIcons.map, size: 16.r),
                        label: const Text('View on Map'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: 添加备注
                          Navigator.pop(context);
                        },
                        icon: Icon(FontAwesomeIcons.pen, size: 16.r),
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
          size: 16.r,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
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
