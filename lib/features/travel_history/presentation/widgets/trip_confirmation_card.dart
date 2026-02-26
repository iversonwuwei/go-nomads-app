import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../domain/entities/candidate_trip.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题行
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.cityPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.flight_land,
                      color: AppColors.cityPrimary,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.travelDetected,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          trip.displayName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 关闭按钮
                  IconButton(
                    icon: Icon(Icons.close, size: 20.r),
                    color: AppColors.textTertiary,
                    onPressed: onDismiss,
                    tooltip: l10n.dismiss,
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // 旅行信息
              _buildInfoRow(
                Icons.calendar_today,
                _formatDateRange(trip.arrivalTime, trip.departureTime),
              ),
              SizedBox(height: 8.h),
              _buildInfoRow(
                Icons.schedule,
                l10n.durationDays(trip.durationDays.toString()),
              ),
              SizedBox(height: 8.h),
              _buildInfoRow(
                Icons.place,
                l10n.distanceFromHome(trip.distanceFromHome.toStringAsFixed(0)),
              ),

              SizedBox(height: 16.h),

              // 提示文本
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16.r,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10n.saveTravelQuestion,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDismiss,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Text(
                        l10n.ignore,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: Icon(Icons.check, size: 18.r),
                      label: Text(l10n.saveTravel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cityPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
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
        Icon(icon, size: 16.r, color: AppColors.textTertiary),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
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
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.cityPrimary.withValues(alpha: 0.95),
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.flight_land,
                  color: Colors.white,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.travelDetectedBanner(trip.displayName),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        l10n.tapToSave,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onConfirm,
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 20.r),
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
    final l10n = AppLocalizations.of(context)!;
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 64.r,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.noPendingTrips,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: trips.length,
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
