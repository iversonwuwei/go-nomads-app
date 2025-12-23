import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/travel_history_controller.dart';
import '../widgets/trip_confirmation_card.dart';
import '../../domain/entities/candidate_trip.dart';

/// 旅行历史页面
class TravelHistoryPage extends GetView<TravelHistoryController> {
  const TravelHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('travel_history'.tr),
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
                tooltip: controller.isAutoDetectionEnabled.value ? 'auto_detection_on'.tr : 'auto_detection_off'.tr,
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
                    const Icon(Icons.home, size: 20),
                    const SizedBox(width: 8),
                    Text('set_home_location'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_data',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'clear_all_data'.tr,
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
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              // 常住地信息卡片
              if (controller.homeLocation.value != null)
                SliverToBoxAdapter(
                  child: _buildHomeLocationCard(),
                ),

              // 待确认的旅行
              if (controller.pendingTrips.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    'pending_confirmation'.tr,
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
                  'confirmed_trips'.tr,
                  count: controller.confirmedTrips.length,
                ),
              ),

              if (controller.confirmedTrips.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = controller.confirmedTrips[index];
                      return _buildTripHistoryCard(trip);
                    },
                    childCount: controller.confirmedTrips.length,
                  ),
                ),

              // 底部安全区域
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHomeLocationCard() {
    final home = controller.homeLocation.value!;
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.home,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'home_location'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    home.cityName ??
                        'location_coordinates'.trParams({
                          'lat': home.latitude.toStringAsFixed(4),
                          'lon': home.longitude.toStringAsFixed(4),
                        }),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (home.confidence > 0)
                    Text(
                      'confidence'.trParams({'percent': home.confidence.toString()}),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            // 信心度指示器
            SizedBox(
              width: 40,
              height: 40,
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
                    style: const TextStyle(
                      fontSize: 10,
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cityPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 12,
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

  Widget _buildTripHistoryCard(CandidateTrip trip) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 如果有 cityId，跳转到城市详情页面
          if (trip.cityId != null && trip.cityId!.isNotEmpty) {
            Get.toNamed(
              AppRoutes.cityDetail,
              arguments: {
                'cityId': trip.cityId,
                'cityName': trip.cityName ?? '',
                'cityImage': '',
              },
            );
          } else {
            // 如果没有 cityId，显示提示
            Get.snackbar(
              '提示',
              '该旅行记录尚未关联城市信息',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 目的地图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cityPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.place,
                  color: AppColors.cityPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // 旅行信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(trip.arrivalTime)} - ${dateFormat.format(trip.departureTime)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // 天数
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      trip.durationDays.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'days'.tr,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'no_travel_history'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'travel_history_empty_hint'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => controller.isAutoDetectionEnabled.value
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cityPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.cityPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'auto_detection_active'.tr,
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
                  label: Text('enable_auto_detection'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cityPrimary,
                  ),
                )),
        ],
      ),
    );
  }
}
