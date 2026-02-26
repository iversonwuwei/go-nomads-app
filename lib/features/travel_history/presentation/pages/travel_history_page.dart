import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/candidate_trip.dart';
import '../../routes/travel_history_routes.dart';
import '../controllers/travel_history_controller.dart';
import '../widgets/trip_confirmation_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 旅行历史页面
class TravelHistoryPage extends GetView<TravelHistoryController> {
  const TravelHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.travelHistory),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 自动检测开关
          Obx(() => IconButton(
                icon: Icon(
                  controller.isAutoDetectionEnabled.value ? Icons.location_on : Icons.location_off,
                  color: controller.isAutoDetectionEnabled.value ? AppColors.cityPrimary : AppColors.textTertiary,
                ),
                onPressed: controller.toggleAutoDetection,
                tooltip: controller.isAutoDetectionEnabled.value ? l10n.autoDetectionOn : l10n.autoDetectionOff,
              )),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              switch (value) {
                case 'set_home':
                  controller.setHomeLocationFromCurrentPosition();
                  break;
                case 'clear_data':
                  controller.clearAllData();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'set_home',
                child: Row(
                  children: [
                    Icon(Icons.home, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(l10n.setHomeLocation),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_data',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20.r, color: Colors.red),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.clearAllData,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ManageListSkeleton();
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              // 常住地信息卡片
              if (controller.homeLocation.value != null)
                SliverToBoxAdapter(
                  child: _buildHomeLocationCard(context),
                ),

              // 待确认的旅行
              if (controller.pendingTrips.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    l10n.pendingConfirmation,
                    count: controller.pendingTrips.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = controller.pendingTrips[index];
                      return TripConfirmationCard(
                        trip: trip,
                        onConfirm: () => controller.confirmTrip(trip),
                        onDismiss: () => controller.dismissTrip(trip),
                      );
                    },
                    childCount: controller.pendingTrips.length,
                  ),
                ),
              ],

              // 已确认的旅行历史
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  l10n.confirmedTrips,
                  count: controller.confirmedTrips.length,
                ),
              ),

              if (controller.confirmedTrips.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = controller.confirmedTrips[index];
                      return _buildTripHistoryCard(context, trip);
                    },
                    childCount: controller.confirmedTrips.length,
                  ),
                ),

              // 底部安全区域
              SliverToBoxAdapter(
                child: SizedBox(height: 80.h),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHomeLocationCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final home = controller.homeLocation.value!;
    return Card(
      margin: EdgeInsets.all(16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.home,
                color: AppColors.accent,
                size: 28.r,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeLocation,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    home.cityName ??
                        l10n.locationCoordinates(
                          home.latitude.toStringAsFixed(4),
                          home.longitude.toStringAsFixed(4),
                        ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (home.confidence > 0)
                    Text(
                      l10n.confidence(home.confidence.toString()),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            // 信心度指示器
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: home.confidence / 100,
                    strokeWidth: 4,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                  Text(
                    '${home.confidence}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {int? count}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (count != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.cityPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cityPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripHistoryCard(BuildContext context, CandidateTrip trip) {
    final l10n = AppLocalizations.of(context)!;
    final monthFormat = DateFormat('MMM');
    final dayFormat = DateFormat('dd');

    // 计算旅行时长描述
    final duration = trip.departureTime.difference(trip.arrivalTime);
    final nights = duration.inDays;
    final durationText = nights > 0 ? '$nights ${l10n.nights}' : '${duration.inHours} ${l10n.hours}';

    // 获取国旗 emoji（如果有国家代码）
    String? flagEmoji;
    if (trip.countryCode != null && trip.countryCode!.length == 2) {
      final code = trip.countryCode!.toUpperCase();
      flagEmoji = String.fromCharCodes([
        0x1F1E6 + code.codeUnitAt(0) - 0x41,
        0x1F1E6 + code.codeUnitAt(1) - 0x41,
      ]);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 点击跳转到访问地点页面，与 profile 页面保持一致
            if (trip.backendId != null && trip.backendId!.isNotEmpty) {
              Get.toNamed(
                TravelHistoryRoutes.visitedPlaces,
                arguments: {
                  'travelHistoryId': trip.backendId,
                  'cityId': trip.cityId,
                  'cityName': trip.cityName ?? '',
                  'countryName': trip.countryName ?? '',
                },
              );
            } else {
              AppToast.info(
                l10n.travelHistoryNoCityLink,
                title: l10n.tip,
              );
            }
          },
          onLongPress: () {
            // 长按跳转到城市详情页面
            if (trip.cityId != null && trip.cityId!.isNotEmpty) {
              Get.toNamed(
                AppRoutes.cityDetail,
                arguments: {
                  'cityId': trip.cityId,
                  'cityName': trip.cityName ?? '',
                  'cityImage': '',
                },
              );
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：日期卡片
                Container(
                  width: 56.w,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cityPrimary,
                        AppColors.cityPrimary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        monthFormat.format(trip.arrivalTime).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1.sp,
                        ),
                      ),
                      Text(
                        dayFormat.format(trip.arrivalTime),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        trip.arrivalTime.year.toString(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                // 中间：旅行信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 城市名和国旗
                      Row(
                        children: [
                          if (flagEmoji != null) ...[
                            Text(
                              flagEmoji,
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Expanded(
                            child: Text(
                              trip.displayName,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // 国家名
                      if (trip.countryName != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          trip.countryName!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: 10.h),
                      // 旅行详情标签
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.w,
                        children: [
                          // 时长标签
                          _buildInfoChip(
                            icon: Icons.nights_stay_rounded,
                            label: durationText,
                            color: Colors.indigo,
                          ),
                          // 距离标签（如果有）
                          if (trip.distanceFromHome > 0)
                            _buildInfoChip(
                              icon: Icons.flight_rounded,
                              label: trip.distanceFromHome >= 1000
                                  ? '${(trip.distanceFromHome / 1000).toStringAsFixed(0)}k km'
                                  : '${trip.distanceFromHome.toStringAsFixed(0)} km',
                              color: Colors.teal,
                            ),
                          // 已同步标签
                          if (trip.isSyncedToBackend)
                            _buildInfoChip(
                              icon: Icons.cloud_done_rounded,
                              label: l10n.synced,
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 右侧：箭头指示
                Container(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[400],
                    size: 24.r,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 80.r,
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.noTravelHistory,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              l10n.travelHistoryEmptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Obx(() => controller.isAutoDetectionEnabled.value
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.cityPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.cityPrimary,
                        size: 16.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.autoDetectionActive,
                        style: const TextStyle(
                          color: AppColors.cityPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: controller.toggleAutoDetection,
                  icon: const Icon(Icons.location_off),
                  label: Text(l10n.enableAutoDetection),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cityPrimary,
                  ),
                )),
        ],
      ),
    );
  }
}
