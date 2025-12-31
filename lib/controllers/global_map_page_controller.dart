import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

/// 全球地图页面控制器
class GlobalMapPageController extends GetxController {
  final MapController mapController = MapController();
  
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxString selectedTileSource = 'gaode-road'.obs;

  // 可用的瓦片源配置（优先国内可访问源）
  final Map<String, Map<String, String>> tileSources = {
    'gaode-road': {
      'name': '高德标准',
      'url': 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
    },
    'gaode-satellite': {
      'name': '高德卫星',
      'url': 'https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}',
    },
    'tianditu-vec': {
      'name': '天地图矢量',
      'url':
          'https://t0.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=YOUR_KEY',
    },
    'osm-standard': {
      'name': 'OpenStreetMap',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
    'cartodb-voyager': {
      'name': 'CartoDB Voyager',
      'url': 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    },
  };

  @override
  void onInit() {
    super.onInit();
    // 模拟加载完成
    Future.delayed(const Duration(milliseconds: 500), () {
      isLoading.value = false;
    });
  }

  void setTileSource(String source) {
    selectedTileSource.value = source;
  }

  void onMapReady() {
    isLoading.value = false;
  }

  void zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(
      mapController.camera.center,
      currentZoom + 1,
    );
  }

  void zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(
      mapController.camera.center,
      currentZoom - 1,
    );
  }

  void retry() {
    errorMessage.value = null;
    isLoading.value = true;
  }
}
