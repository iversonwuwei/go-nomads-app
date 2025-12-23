import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../domain/entities/candidate_trip.dart';

/// 旅行确认卡片
/// 用于非侵入式地提醒用户确认检测到的旅行
class TripConfirmationCard extends StatelessWidget {
  final CandidateTrip trip;
  final VoidCallback? onConfirm;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const TripConfirmationCard({
    super.key,
    required this.trip,
    this.onConfirm,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题行
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cityPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flight_land,
                      color: AppColors.cityPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'travel_detected'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          trip.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 关闭按钮
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.textTertiary,
                    onPressed: onDismiss,
                    tooltip: 'dismiss'.tr,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 旅行信息
              _buildInfoRow(
                Icons.calendar_today,
                _formatDateRange(trip.arrivalTime, trip.departureTime),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.schedule,
                'duration_days'.trParams({'days': trip.durationDays.toString()}),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.place,
                'distance_from_home'
                    .trParams({'km': trip.distanceFromHome.toStringAsFixed(0)}),
              ),

              const SizedBox(height: 16),

              // 提示文本
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'save_travel_question'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDismiss,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Text(
                        'ignore'.tr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text('save_travel'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cityPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final dateFormat = DateFormat('MM/dd');
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return dateFormat.format(start);
    }
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }
}

/// 旅行确认通知横幅（用于在页面顶部显示）
class TripConfirmationBanner extends StatelessWidget {
  final CandidateTrip trip;
  final VoidCallback? onConfirm;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const TripConfirmationBanner({
    super.key,
    required this.trip,
    this.onConfirm,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cityPrimary.withValues(alpha: 0.95),
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.flight_land,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'travel_detected_banner'
                            .trParams({'city': trip.displayName}),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'tap_to_save'.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onConfirm,
                  child: Text(
                    'save'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 待确认旅行列表
class PendingTripsListView extends StatelessWidget {
  final List<CandidateTrip> trips;
  final Function(CandidateTrip trip)? onConfirm;
  final Function(CandidateTrip trip)? onDismiss;
  final Function(CandidateTrip trip)? onTap;

  const PendingTripsListView({
    super.key,
    required this.trips,
    this.onConfirm,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'no_pending_trips'.tr,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: trips.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripConfirmationCard(
          trip: trip,
          onConfirm: onConfirm != null ? () => onConfirm!(trip) : null,
          onDismiss: onDismiss != null ? () => onDismiss!(trip) : null,
          onTap: onTap != null ? () => onTap!(trip) : null,
        );
      },
    );
  }
}
