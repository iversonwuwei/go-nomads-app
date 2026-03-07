import 'package:go_nomads_app/controllers/global_map_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 使用 flutter_map 显示基础全球地图页面
class GlobalMapPage extends StatelessWidget {
  const GlobalMapPage({super.key});

  GlobalMapPageController get _controller {
    if (!Get.isRegistered<GlobalMapPageController>()) {
      Get.put(GlobalMapPageController());
    }
    return Get.find<GlobalMapPageController>();
  }

  void _showTileSourceSelector(BuildContext context) {
    final controller = _controller;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  '选择地图样式',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1),
              ...controller.tileSources.entries.map((entry) {
                return Obx(() {
                  final isSelected = controller.selectedTileSource.value == entry.key;
                  return ListTile(
                    leading: Icon(
                      Icons.map,
                      color: isSelected ? const Color(0xFFFF4458) : Colors.grey,
                    ),
                    title: Text(
                      entry.value['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFFF4458) : null,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFF4458)) : null,
                    onTap: () {
                      controller.setTileSource(entry.key);
                      Navigator.pop(context);
                    },
                  );
                });
              }),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.map),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: const AppBackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => _showTileSourceSelector(context),
            tooltip: '切换地图样式',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地图主体
          Obx(() => FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: const LatLng(30.0, 105.0), // 默认中国中心
              initialZoom: 4,
              minZoom: 2,
              maxZoom: 18,
              onMapReady: controller.onMapReady,
            ),
            children: [
              TileLayer(
                urlTemplate: controller.tileSources[controller.selectedTileSource.value]!['url']!,
                userAgentPackageName: 'com.digitalfuture.df_admin_mobile',
                maxZoom: 18,
                minZoom: 2,
              ),
            ],
          )),

          // 加载指示器
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.white.withValues(alpha: 0.8),
                  child: const AppLoadingWidget(
                    fullScreen: true,
                    title: '加载地图中',
                    subtitle: 'Loading map...',
                    icon: Icons.map_rounded,
                    accentColor: Color(0xFFFF4458),
                  ),
                )
              : const SizedBox.shrink()),

          // 错误提示
          Obx(() => controller.errorMessage.value != null
              ? Container(
                  color: Colors.white.withValues(alpha: 0.9),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.r,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          controller.errorMessage.value!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: controller.retry,
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // 缩放控制按钮
          Positioned(
            right: 16.w,
            bottom: 120.h,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onTap: controller.zoomIn,
                ),
                SizedBox(height: 8.h),
                _buildZoomButton(
                  icon: Icons.remove,
                  onTap: controller.zoomOut,
                ),
              ],
            ),
          ),

          // 当前地图样式标签
          Positioned(
            left: 16.w,
            bottom: 32.h,
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 16.r, color: Color(0xFFFF4458)),
                  SizedBox(width: 8.w),
                  Text(
                    controller.tileSources[controller.selectedTileSource.value]!['name']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 44.w,
          height: 44.h,
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFFFF4458)),
        ),
      ),
    );
  }
}
