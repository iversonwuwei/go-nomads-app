import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../features/ai/presentation/controllers/ai_state_controller.dart';
import '../../../../features/city/infrastructure/models/city_detail_dto.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/safe_network_image.dart';
import '../../city_detail_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Neighborhoods Tab - GetView 实现
///
/// 显示附近城市列表，支持 AI 生成
class NeighborhoodsTab extends GetView<CityDetailController> {
  const NeighborhoodsTab({
    super.key,
    required this.tag,
    required this.onGeneratePressed,
    required this.onCheckPermission,
  });

  @override
  final String? tag;
  final VoidCallback onGeneratePressed;
  final Future<bool> Function() onCheckPermission;

  @override
  Widget build(BuildContext context) {
    final aiController = Get.find<AiStateController>();

    // 初始化加载逻辑
    _initializeData(aiController);

    return Obx(() {
      final cities = aiController.nearbyCities;

      // 优先显示附近城市内容(如果有且是当前城市的)
      if (cities.isNotEmpty && cities.first.sourceCityId == controller.cityId) {
        return _NearbyCitiesContent(
          tag: tag ?? '',
          cities: cities,
          onGeneratePressed: onGeneratePressed,
          onCheckPermission: onCheckPermission,
        );
      }

      // 显示加载或生成状态
      if (aiController.isLoadingNearbyCities || aiController.isGeneratingNearbyCities) {
        return _LoadingState(controller: aiController);
      }

      // 显示空状态
      return _EmptyState(
        onGeneratePressed: onGeneratePressed,
        onCheckPermission: onCheckPermission,
        isGenerating: aiController.isGeneratingNearbyCities,
      );
    });
  }

  void _initializeData(AiStateController aiController) {
    // 只在首次加载或城市变化时请求数据
    if (!controller.hasInitializedNearbyCities.value ||
        controller.lastNearbyCitiesLoadedCityId.value != controller.cityId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentCities = aiController.nearbyCities;

        // 如果是不同城市,先清空旧数据
        if (currentCities.isNotEmpty && currentCities.first.sourceCityId != controller.cityId) {
          aiController.resetNearbyCitiesState();
        }

        // 只在未加载过且控制器空闲时才加载
        if (!aiController.isGeneratingNearbyCities && !aiController.isLoadingNearbyCities) {
          final shouldLoad = currentCities.isEmpty || currentCities.first.sourceCityId != controller.cityId;
          if (shouldLoad) {
            aiController.loadNearbyCities(cityId: controller.cityId);
          }
        }

        // 标记已初始化
        controller.hasInitializedNearbyCities.value = true;
        controller.lastNearbyCitiesLoadedCityId.value = controller.cityId;
      });
    }
  }
}

/// 加载状态组件
class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.controller});

  final AiStateController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text(
            controller.isGeneratingNearbyCities ? '🤖 AI 正在生成附近城市...' : '📍 正在加载附近城市...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          if (controller.isGeneratingNearbyCities) ...[
            SizedBox(height: 12.h),
            Obx(() => Text(
                  controller.nearbyCitiesGenerationMessage,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                )),
            SizedBox(height: 8.h),
            Obx(() => Text(
                  '${controller.nearbyCitiesGenerationProgress}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4458),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// 空状态组件
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onGeneratePressed,
    required this.onCheckPermission,
    required this.isGenerating,
  });

  final VoidCallback onGeneratePressed;
  final Future<bool> Function() onCheckPermission;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.mapLocationDot,
              size: 60.r,
              color: Colors.grey,
            ),
            SizedBox(height: 12.h),
            Text(
              '暂无附近城市',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Text(
              '发现 100 公里内的 4 个相邻城市',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: isGenerating
                  ? null
                  : () async {
                      if (!await onCheckPermission()) return;
                      onGeneratePressed();
                    },
              icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
              label: const Text('AI 生成附近城市'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 附近城市内容组件
class _NearbyCitiesContent extends GetView<CityDetailController> {
  const _NearbyCitiesContent({
    required this.tag,
    required this.cities,
    required this.onGeneratePressed,
    required this.onCheckPermission,
  });

  @override
  final String? tag;
  final List<NearbyCityDto> cities;
  final VoidCallback onGeneratePressed;
  final Future<bool> Function() onCheckPermission;

  @override
  Widget build(BuildContext context) {
    final aiController = Get.find<AiStateController>();

    return RefreshIndicator(
      onRefresh: () => aiController.loadNearbyCities(cityId: controller.cityId),
      child: ListView(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 96.h),
        children: [
          _buildActionBar(aiController),
          SizedBox(height: 16.h),
          ...cities.map((city) => _NearbyCityCard(city: city)),
        ],
      ),
    );
  }

  Widget _buildActionBar(AiStateController aiController) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.cloudArrowUp,
            color: Colors.green,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '☁️ 从后端加载',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.green[800],
              ),
            ),
          ),
          Row(
            children: [
              Obx(() => TextButton.icon(
                    onPressed: aiController.isGeneratingNearbyCities || aiController.isLoadingNearbyCities
                        ? null
                        : () => aiController.loadNearbyCities(cityId: controller.cityId),
                    icon: Icon(FontAwesomeIcons.arrowsRotate, size: 18.r),
                    label: const Text('刷新'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      disabledForegroundColor: Colors.grey[400],
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    ),
                  )),
              SizedBox(width: 4.w),
              Obx(() => TextButton.icon(
                    onPressed: aiController.isGeneratingNearbyCities || aiController.isLoadingNearbyCities
                        ? null
                        : () async {
                            if (!await onCheckPermission()) return;
                            onGeneratePressed();
                          },
                    icon: Icon(FontAwesomeIcons.wandMagicSparkles, size: 18.r),
                    label: const Text('AI 生成'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      disabledForegroundColor: Colors.grey[400],
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

/// 附近城市卡片
class _NearbyCityCard extends StatelessWidget {
  const _NearbyCityCard({required this.city});

  final NearbyCityDto city;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => _navigateToCityDetail(),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCityImage(),
            _buildCityInfo(),
          ],
        ),
      ),
    );
  }

  void _navigateToCityDetail() {
    if (city.targetCityId != null && city.targetCityId!.isNotEmpty) {
      Get.toNamed(
        AppRoutes.cityDetail,
        arguments: {
          'cityId': city.targetCityId,
          'cityName': city.name,
          'cityImage': city.imageUrl ?? '',
        },
      );
    }
  }

  Widget _buildCityImage() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      child: city.imageUrl != null && city.imageUrl!.isNotEmpty
          ? SafeNetworkImage(
              imageUrl: city.imageUrl!,
              height: 140.h,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 140.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[300]!, Colors.grey[200]!],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.city, size: 40.r, color: Colors.grey[400]),
                  SizedBox(height: 8.h),
                  Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCityInfo() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCityHeader(),
          SizedBox(height: 8.h),
          _buildTravelTime(),
          if (city.highlights.isNotEmpty) _buildHighlights(),
          if (city.nomadFeatures != null) _buildNomadFeatures(),
        ],
      ),
    );
  }

  Widget _buildCityHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city.name,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                city.country,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        _buildDistanceBadge(),
      ],
    );
  }

  Widget _buildDistanceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4458).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTransportIcon(city.transportation), size: 14.r, color: const Color(0xFFFF4458)),
          SizedBox(width: 6.w),
          Text(
            '${city.distance.toStringAsFixed(0)} km',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF4458),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelTime() {
    return Row(
      children: [
        Icon(FontAwesomeIcons.clock, size: 14.r, color: Colors.grey),
        SizedBox(width: 6.w),
        Text(
          _formatTravelTime(city.travelTimeMinutes),
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHighlights() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.w,
        children: city.highlights.take(3).map((highlight) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              highlight,
              style: TextStyle(fontSize: 12.sp, color: Colors.blue[700]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNomadFeatures() {
    final features = city.nomadFeatures!;
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        children: [
          if (features.internetSpeedMbps != null) ...[
            Icon(FontAwesomeIcons.wifi, size: 12.r, color: Colors.green),
            SizedBox(width: 4.w),
            Text(
              '${features.internetSpeedMbps} Mbps',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(width: 16.w),
          ],
          if (features.monthlyCostUsd != null) ...[
            Icon(FontAwesomeIcons.dollarSign, size: 12.r, color: Colors.orange),
            SizedBox(width: 4.w),
            Text(
              '\$${features.monthlyCostUsd!.toStringAsFixed(0)}/mo',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getTransportIcon(String transportation) {
    switch (transportation.toLowerCase()) {
      case 'car':
      case 'driving':
        return FontAwesomeIcons.car;
      case 'train':
      case 'rail':
        return FontAwesomeIcons.train;
      case 'bus':
        return FontAwesomeIcons.bus;
      case 'plane':
      case 'flight':
        return FontAwesomeIcons.plane;
      case 'ferry':
      case 'boat':
        return FontAwesomeIcons.ferry;
      default:
        return FontAwesomeIcons.route;
    }
  }

  String _formatTravelTime(int minutes) {
    if (minutes < 60) return '$minutes 分钟';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours 小时';
    return '$hours 小时 $mins 分钟';
  }
}
