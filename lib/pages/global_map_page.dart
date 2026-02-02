import 'package:go_nomads_app/controllers/global_map_page_controller.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '选择地图样式',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
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
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('全球地图'),
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
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '加载地图中...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.retry,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // 缩放控制按钮
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onTap: controller.zoomIn,
                ),
                const SizedBox(height: 8),
                _buildZoomButton(
                  icon: Icons.remove,
                  onTap: controller.zoomOut,
                ),
              ],
            ),
          ),

          // 当前地图样式标签
          Positioned(
            left: 16,
            bottom: 32,
            child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map, size: 16, color: Color(0xFFFF4458)),
                  const SizedBox(width: 8),
                  Text(
                    controller.tileSources[controller.selectedTileSource.value]!['name']!,
                    style: const TextStyle(
                      fontSize: 12,
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
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFFFF4458)),
        ),
      ),
    );
  }
}
