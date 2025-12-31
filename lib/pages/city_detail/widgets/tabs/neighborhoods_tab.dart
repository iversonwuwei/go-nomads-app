import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../features/ai/presentation/controllers/ai_state_controller.dart';
import '../../../../features/city/infrastructure/models/city_detail_dto.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/safe_network_image.dart';
import '../../city_detail_controller.dart';

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
          const SizedBox(height: 16),
          Text(
            controller.isGeneratingNearbyCities ? '🤖 AI 正在生成附近城市...' : '📍 正在加载附近城市...',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (controller.isGeneratingNearbyCities) ...[
            const SizedBox(height: 12),
            Obx(() => Text(
                  controller.nearbyCitiesGenerationMessage,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 8),
            Obx(() => Text(
                  '${controller.nearbyCitiesGenerationProgress}%',
                  style: const TextStyle(
                    fontSize: 14,
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
            const Icon(
              FontAwesomeIcons.mapLocationDot,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              '暂无附近城市',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '发现 100 公里内的 4 个相邻城市',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        children: [
          _buildActionBar(aiController),
          const SizedBox(height: 16),
          ...cities.map((city) => _NearbyCityCard(city: city)),
        ],
      ),
    );
  }

  Widget _buildActionBar(AiStateController aiController) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.cloudArrowUp,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '☁️ 从后端加载',
              style: TextStyle(
                fontSize: 13,
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
                    icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
                    label: const Text('刷新'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      disabledForegroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  )),
              const SizedBox(width: 4),
              Obx(() => TextButton.icon(
                    onPressed: aiController.isGeneratingNearbyCities || aiController.isLoadingNearbyCities
                        ? null
                        : () async {
                            if (!await onCheckPermission()) return;
                            onGeneratePressed();
                          },
                    icon: const Icon(FontAwesomeIcons.wandMagicSparkles, size: 18),
                    label: const Text('AI 生成'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      disabledForegroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToCityDetail(),
        borderRadius: BorderRadius.circular(12),
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: city.imageUrl != null && city.imageUrl!.isNotEmpty
          ? SafeNetworkImage(
              imageUrl: city.imageUrl!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 140,
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
                  Icon(FontAwesomeIcons.city, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 14,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCityHeader(),
          const SizedBox(height: 8),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                city.country,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4458).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTransportIcon(city.transportation), size: 14, color: const Color(0xFFFF4458)),
          const SizedBox(width: 6),
          Text(
            '${city.distance.toStringAsFixed(0)} km',
            style: const TextStyle(
              fontSize: 13,
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
        const Icon(FontAwesomeIcons.clock, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          _formatTravelTime(city.travelTimeMinutes),
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHighlights() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: city.highlights.take(3).map((highlight) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              highlight,
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNomadFeatures() {
    final features = city.nomadFeatures!;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (features.internetSpeedMbps != null) ...[
            const Icon(FontAwesomeIcons.wifi, size: 12, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              '${features.internetSpeedMbps} Mbps',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
          ],
          if (features.monthlyCostUsd != null) ...[
            const Icon(FontAwesomeIcons.dollarSign, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              '\$${features.monthlyCostUsd!.toStringAsFixed(0)}/mo',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
