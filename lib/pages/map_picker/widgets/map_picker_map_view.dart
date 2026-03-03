import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 地图视图组件（含中心标记和定位按钮）
/// Map view widget with center pin (高德地图风格) and relocate FAB
class MapPickerMapView extends GetView<MapPickerController> {
  const MapPickerMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 加载中状态
      if (controller.isLoadingLocation.value && !controller.isInitialized.value) {
        return Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                ),
                SizedBox(height: 16.h),
                Text(
                  '正在获取您的位置... / Getting your location...',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      // 地图已初始化
      if (!controller.isInitialized.value) {
        return const SizedBox.shrink();
      }

      return Stack(
        children: [
          // 地图
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.mapCenter.value,
              initialZoom: controller.currentZoom.value,
              minZoom: 2,
              maxZoom: 18,
              onTap: controller.onMapTap,
              onPositionChanged: controller.onMapPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: MapPickerController.tileUrl,
                userAgentPackageName: 'com.gonomads.app',
                maxZoom: 18,
                minZoom: 2,
              ),
            ],
          ),

          // 中心标记（固定在地图中央，高德地图风格）
          const Center(
            child: _CenterPinMarker(),
          ),

          // 重新定位按钮
          Positioned(
            right: 16.w,
            bottom: 200.h,
            child: _RelocateButton(),
          ),
        ],
      );
    });
  }
}

/// 固定在地图中心的标记图标（高德地图风格）
/// 地图拖动时标记不动，地图停止后播放弹跳动画
class _CenterPinMarker extends GetView<MapPickerController> {
  const _CenterPinMarker();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          // 向上偏移，使图标底部对准地图中心点
          offset: Offset(0, -25 + (controller.bounceAnimation.value)),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.locationDot,
            size: 50.r,
            color: Color(0xFFFF4458),
          ),
          Container(
            width: 20.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ],
      ),
    );
  }
}

/// 重新定位到当前位置的按钮
class _RelocateButton extends GetView<MapPickerController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingLocation.value;
      return FloatingActionButton.small(
        heroTag: 'map_picker_relocate',
        backgroundColor: Colors.white,
        onPressed: isLoading ? null : controller.relocateToMyPosition,
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                ),
              )
            : Icon(
                FontAwesomeIcons.locationCrosshairs,
                size: 18.r,
                color: Color(0xFFFF4458),
              ),
      );
    });
  }
}
