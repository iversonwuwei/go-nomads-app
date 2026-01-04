import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/visited_place.dart';
import '../controllers/visited_places_controller.dart';

/// 访问地点列表页面
/// 展示某次旅行中用户停留超过40分钟的所有地点
class VisitedPlacesPage extends GetView<VisitedPlacesController> {
  const VisitedPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.tripTitle.value.isNotEmpty
                  ? controller.tripTitle.value
                  : 'Visited Places',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            )),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.places.isEmpty) return const SizedBox();
            return IconButton(
              icon: Icon(FontAwesomeIcons.map, color: theme.colorScheme.primary, size: 20),
              onPressed: () {
                // TODO: 打开地图视图
                Get.snackbar(
                  'Coming Soon',
                  'Map view will be available soon',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorView(context, theme);
        }

        if (controller.places.isEmpty) {
          return _buildEmptyView(context, theme);
        }

        return _buildPlacesList(context, theme);
      }),
    );
  }

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

  Widget _buildEmptyView(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.locationDot,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No visited places yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Places where you stayed for more than 40 minutes will appear here',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList(BuildContext context, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // 统计信息头部
        SliverToBoxAdapter(
          child: _buildStatsHeader(context, theme),
        ),

        // 地点列表
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final place = controller.places[index];
                return _buildPlaceCard(context, theme, place, index);
              },
              childCount: controller.places.length,
            ),
          ),
        ),

        // 底部间距
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.colorScheme.primary.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              theme,
              icon: FontAwesomeIcons.locationDot,
              value: '${controller.places.length}',
              label: 'Places',
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            _buildStatItem(
              theme,
              icon: FontAwesomeIcons.clock,
              value: _formatTotalDuration(),
              label: 'Total Time',
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            _buildStatItem(
              theme,
              icon: FontAwesomeIcons.star,
              value: '${controller.places.where((p) => p.isHighlight).length}',
              label: 'Highlights',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatTotalDuration() {
    final totalMinutes = controller.places.fold<int>(0, (sum, p) => sum + p.durationMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
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
            onTap: () => _showPlaceDetails(context, theme, place),
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
                          color: place.isHighlight
                              ? const Color(0xFFF59E0B)
                              : theme.colorScheme.primary,
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

  void _showPlaceDetails(BuildContext context, ThemeData theme, VisitedPlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlaceDetailsSheet(
        place: place,
        theme: theme,
        onToggleHighlight: () {
          controller.toggleHighlight(place);
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
                          Get.snackbar(
                            'Coming Soon',
                            'View on map will be available soon',
                            snackPosition: SnackPosition.BOTTOM,
                          );
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
