import 'dart:developer';
import 'dart:io';

import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:go_nomads_app/controllers/amap_global_page_controller.dart';

/// 高德地图全球页面 - 展示全球城市分布
/// 使用原生 Platform View 嵌入高德地图
class AmapGlobalPage extends StatelessWidget {
  const AmapGlobalPage({super.key});

  static const String _viewType = 'amap_global_view';
  static const String _tag = 'AmapGlobalPage';

  AmapGlobalPageController _useController() {
    if (Get.isRegistered<AmapGlobalPageController>(tag: _tag)) {
      return Get.find<AmapGlobalPageController>(tag: _tag);
    }
    return Get.put(AmapGlobalPageController(), tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // 地图层
          Obx(() => _buildMapView(controller)),

          // 顶部面板
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopPanel(context, controller, l10n),
          ),

          // 加载指示器
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            return const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            );
          }),

          // 错误提示
          Obx(() {
            if (controller.errorMessage.value == null) return const SizedBox.shrink();
            return Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildErrorBanner(controller),
            );
          }),

          // 右下角控制按钮
          Positioned(
            bottom: 24,
            right: 16,
            child: _buildControlButtons(controller),
          ),

          // 左下角统计信息
          Positioned(
            bottom: 24,
            left: 16,
            child: Obx(() => _buildStatsCard(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(AmapGlobalPageController controller) {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return const Center(child: Text('地图仅支持 iOS 和 Android 平台'));
    }

    final citiesData = controller.citiesWithCoordinates
        .map((city) => {
              'id': city.id,
              'name': city.displayName,
              'latitude': city.latitude,
              'longitude': city.longitude,
              'country': city.country ?? '',
              'score': city.overallScore ?? 0.0,
            })
        .toList();

    final creationParams = {
      'cities': citiesData,
      'initialZoom': 4.0,
      'centerLatitude': 35.0,
      'centerLongitude': 105.0,
    };

    if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return AndroidView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  void _onPlatformViewCreated(int viewId) {
    log('🗺️ AMap Platform View created with id: $viewId');
  }

  Widget _buildTopPanel(BuildContext context, AmapGlobalPageController controller, AppLocalizations l10n) {
    return Obx(() {
      final totalCities = controller.citiesWithCoordinates.length;
      final totalCountries =
          controller.citiesWithCoordinates.map((c) => c.country).where((c) => c != null && c.isNotEmpty).toSet().length;

      return Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xCCFFFFFF), Color(0x00FFFFFF)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Global Nomads',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                  onPressed: controller.loadCities,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryChip('$totalCities', 'Cities'),
                const SizedBox(width: 8),
                _buildSummaryChip('$totalCountries', 'Countries'),
              ],
            ),
            const SizedBox(height: 12),
            _buildSearchField(controller, l10n),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSearchField(AmapGlobalPageController controller, AppLocalizations l10n) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.searchCities,
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: controller.searchKeyword.value.isEmpty
                  ? null
                  : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: controller.clearSearch),
            ),
            onChanged: controller.updateSearchKeyword,
          ),
        ));
  }

  Widget _buildControlButtons(AmapGlobalPageController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMapButton(icon: Icons.my_location, onPressed: controller.centerToUserLocation),
        const SizedBox(height: 12),
        _buildMapButton(icon: Icons.zoom_in, onPressed: () => controller.changeZoom(1)),
        const SizedBox(height: 12),
        _buildMapButton(icon: Icons.zoom_out, onPressed: () => controller.changeZoom(-1)),
        const SizedBox(height: 12),
        _buildMapButton(icon: Icons.explore, onPressed: controller.resetToWorld),
      ],
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }

  Widget _buildStatsCard(AmapGlobalPageController controller) {
    final cities = controller.citiesWithCoordinates;
    if (cities.isEmpty) return const SizedBox.shrink();

    final regionStats = controller.getRegionStats();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('By Region',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          ...regionStats.entries.take(4).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: controller.getRegionColor(e.key), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(AmapGlobalPageController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => Text(
                  controller.errorMessage.value ?? 'Unknown error',
                  style: TextStyle(color: Colors.red.shade700),
                )),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: controller.clearError),
        ],
      ),
    );
  }
}
