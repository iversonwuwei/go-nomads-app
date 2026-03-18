import 'dart:developer';
import 'dart:io';

import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:go_nomads_app/controllers/amap_global_page_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                child: AppLoadingWidget(
                  fullScreen: true,
                  title: 'Loading map...',
                  subtitle: '正在加载地图',
                  icon: Icons.public_rounded,
                  accentColor: Colors.white,
                ),
              ),
            );
          }),

          // 错误提示
          Obx(() {
            if (controller.errorMessage.value == null) return const SizedBox.shrink();
            return Positioned(
              bottom: 100.h,
              left: 20.w,
              right: 20.w,
              child: _buildErrorBanner(controller),
            );
          }),

          // 右下角控制按钮
          Positioned(
            bottom: 24.h,
            right: 16.w,
            child: _buildControlButtons(controller),
          ),

          // 左下角统计信息
          Positioned(
            bottom: 24.h,
            left: 16.w,
            child: Obx(() => _buildStatsCard(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(AmapGlobalPageController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    if (!Platform.isIOS && !Platform.isAndroid) {
      return Center(child: Text(l10n.amapGlobalMapOnlyMobile));
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
          left: 16.w,
          right: 16.w,
          bottom: 12.h,
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
                SizedBox(width: 8.w),
                Text(
                  l10n.amapGlobalTitle,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                  onPressed: controller.loadCities,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildSummaryChip('$totalCities', l10n.cities),
                SizedBox(width: 8.w),
                _buildSummaryChip('$totalCountries', l10n.countries),
              ],
            ),
            SizedBox(height: 12.h),
            _buildSearchField(controller, l10n),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryChip(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12.r, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSearchField(AmapGlobalPageController controller, AppLocalizations l10n) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12.r, offset: const Offset(0, 4)),
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
                  : IconButton(icon: Icon(Icons.close, size: 18.r), onPressed: controller.clearSearch),
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
        SizedBox(height: 12.h),
        _buildMapButton(icon: Icons.zoom_in, onPressed: () => controller.changeZoom(1)),
        SizedBox(height: 12.h),
        _buildMapButton(icon: Icons.zoom_out, onPressed: () => controller.changeZoom(-1)),
        SizedBox(height: 12.h),
        _buildMapButton(icon: Icons.explore, onPressed: controller.resetToWorld),
      ],
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Icon(icon, color: AppColors.textPrimary, size: 22.r),
        ),
      ),
    );
  }

  Widget _buildStatsCard(AmapGlobalPageController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final cities = controller.citiesWithCoordinates;
    if (cities.isEmpty) return const SizedBox.shrink();

    final regionStats = controller.getRegionStats();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12.r, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.amapGlobalByRegion,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          SizedBox(height: 8.h),
          ...regionStats.entries.take(4).map((e) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(color: controller.getRegionColor(e.key), shape: BoxShape.circle),
                    ),
                    SizedBox(width: 8.w),
                    Text([e.key, e.value.toString()].join(': '),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(AmapGlobalPageController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          SizedBox(width: 12.w),
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
