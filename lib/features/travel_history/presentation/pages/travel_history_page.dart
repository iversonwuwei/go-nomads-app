import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/candidate_trip.dart';
import '../controllers/travel_history_controller.dart';
import '../widgets/trip_confirmation_card.dart';

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
                    const Icon(Icons.home, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.setHomeLocation),
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
          return const Center(child: CircularProgressIndicator());
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
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
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
                    l10n.homeLocation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    home.cityName ??
                        l10n.locationCoordinates(
                          home.latitude.toStringAsFixed(4),
                          home.longitude.toStringAsFixed(4),
                        ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (home.confidence > 0)
                    Text(
                      l10n.confidence(home.confidence.toString()),
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

  Widget _buildTripHistoryCard(BuildContext context, CandidateTrip trip) {
    final l10n = AppLocalizations.of(context)!;
    final monthFormat = DateFormat('MMM');
    final dayFormat = DateFormat('dd');
    
    // 计算旅行时长描述
    final duration = trip.departureTime.difference(trip.arrivalTime);
    final nights = duration.inDays;
    final durationText = nights > 0 
        ? '$nights ${l10n.nights}' 
        : '${duration.inHours} ${l10n.hours}';
    
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
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
              Get.snackbar(
                l10n.tip,
                l10n.travelHistoryNoCityLink,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：日期卡片
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cityPrimary,
                        AppColors.cityPrimary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        monthFormat.format(trip.arrivalTime).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        dayFormat.format(trip.arrivalTime),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        trip.arrivalTime.year.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
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
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              trip.displayName,
                              style: const TextStyle(
                                fontSize: 17,
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
                        const SizedBox(height: 2),
                        Text(
                          trip.countryName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // 旅行详情标签
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
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
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[400],
                    size: 24,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTravelHistory,
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
              l10n.travelHistoryEmptyHint,
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
