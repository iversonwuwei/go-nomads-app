import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

// POI 数据模型
class POI {
  final String name;
  final POIType type;
  final LatLng position;
  final IconData icon;

  POI({
    required this.name,
    required this.type,
    required this.position,
    required this.icon,
  });
}

// POI 类型
enum POIType {
  transit, // 交通
  accommodation, // 住宿
  restaurant, // 餐饮
}

// 地图应用信息
class MapAppInfo {
  final String name;
  final IconData icon;
  final Color color;
  final String url;
  final String? scheme;
  final String? webFallback;

  MapAppInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.url,
    this.scheme,
    this.webFallback,
  });
}

/// OSM Navigation Page Controller
class OSMNavigationPageController extends GetxController {
  final CoworkingSpace coworkingSpace;
  
  OSMNavigationPageController({required this.coworkingSpace});

  final MapController mapController = MapController();
  
  // 筛选状态
  final RxBool showTransit = true.obs;
  final RxBool showAccommodation = true.obs;
  final RxBool showRestaurant = true.obs;

  // 瓦片源选择
  final RxString selectedTileSource = 'amap-road'.obs;

  // 可用的瓦片源配置(与 GlobalMapPage 一致)
  final Map<String, Map<String, String>> tileSources = {
    'amap-road': {
      'name': '高德标准地图',
      'url': 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
    },
    'amap-satellite': {
      'name': '高德卫星图',
      'url': 'https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}',
    },
    'osm-standard': {
      'name': 'OSM 标准地图',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
    'osm-humanitarian': {
      'name': 'OSM 人道主义地图',
      'url': 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    },
    'cartodb-voyager': {
      'name': 'CartoDB 航海版',
      'url': 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    },
    'cartodb-positron': {
      'name': 'CartoDB 简洁版',
      'url': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    },
    'cartodb-dark': {
      'name': 'CartoDB 深色',
      'url': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    },
    'stamen-terrain': {
      'name': 'Stamen 地形图',
      'url': 'https://stamen-tiles.a.ssl.fastly.net/terrain/{z}/{x}/{y}.jpg',
    },
  };

  // 周边设施数据
  final RxList<POI> nearbyPOIs = <POI>[].obs;

  // 中心坐标
  LatLng get center => LatLng(
    coworkingSpace.location.latitude,
    coworkingSpace.location.longitude,
  );

  // 当前瓦片URL
  String get currentTileUrl => tileSources[selectedTileSource.value]!['url']!;
  
  // 当前瓦片名称
  String get currentTileName => tileSources[selectedTileSource.value]!['name']!;

  @override
  void onInit() {
    super.onInit();
    _loadNearbyPOIs();
  }

  void _loadNearbyPOIs() {
    // 模拟加载周边设施数据
    nearbyPOIs.value = [
      // 交通设施（示例）
      POI(
        name: '地铁站',
        type: POIType.transit,
        position: LatLng(center.latitude + 0.002, center.longitude + 0.002),
        icon: FontAwesomeIcons.trainSubway,
      ),
      POI(
        name: '公交站',
        type: POIType.transit,
        position: LatLng(center.latitude - 0.001, center.longitude + 0.001),
        icon: FontAwesomeIcons.bus,
      ),
      // 住宿设施（示例）
      POI(
        name: '附近酒店',
        type: POIType.accommodation,
        position: LatLng(center.latitude + 0.003, center.longitude - 0.002),
        icon: FontAwesomeIcons.hotel,
      ),
      POI(
        name: '青年旅舍',
        type: POIType.accommodation,
        position: LatLng(center.latitude - 0.002, center.longitude - 0.003),
        icon: FontAwesomeIcons.bed,
      ),
      // 餐饮设施（示例）
      POI(
        name: '咖啡厅',
        type: POIType.restaurant,
        position: LatLng(center.latitude + 0.001, center.longitude - 0.001),
        icon: FontAwesomeIcons.mugSaucer,
      ),
      POI(
        name: '餐厅',
        type: POIType.restaurant,
        position: LatLng(center.latitude - 0.002, center.longitude + 0.002),
        icon: FontAwesomeIcons.utensils,
      ),
    ];
  }

  // 切换筛选
  void toggleTransit() => showTransit.toggle();
  void toggleAccommodation() => showAccommodation.toggle();
  void toggleRestaurant() => showRestaurant.toggle();

  // 切换瓦片源
  void changeTileSource(String source) {
    selectedTileSource.value = source;
  }

  // 判断是否应该显示该类型的 POI
  bool shouldShowPOI(POIType type) {
    switch (type) {
      case POIType.transit:
        return showTransit.value;
      case POIType.accommodation:
        return showAccommodation.value;
      case POIType.restaurant:
        return showRestaurant.value;
    }
  }

  // 获取 POI 颜色
  Color getPOIColor(POIType type) {
    switch (type) {
      case POIType.transit:
        return Colors.blue;
      case POIType.accommodation:
        return Colors.purple;
      case POIType.restaurant:
        return Colors.orange;
    }
  }

  // 聚焦到指定位置
  void focusOnLocation(LatLng position) {
    mapController.move(position, 17.0);
  }

  // 回到中心
  void recenter() {
    mapController.move(center, 15.0);
  }

  // 放大
  void zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom + 1);
  }

  // 缩小
  void zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 1);
  }

  // 计算距离
  String calculateDistance(LatLng from, LatLng to, String Function(String) formatMeters, String Function(String) formatKilometers) {
    final distance = Distance();
    final meters = distance(from, to);
    if (meters < 1000) {
      return formatMeters(meters.toStringAsFixed(0));
    } else {
      return formatKilometers((meters / 1000).toStringAsFixed(1));
    }
  }

  // 地图应用配置
  List<MapAppInfo> getAvailableMapApps() {
    final lat = coworkingSpace.location.latitude;
    final lon = coworkingSpace.location.longitude;
    final name = Uri.encodeComponent(coworkingSpace.name);

    // 根据平台返回不同的地图应用列表
    if (GetPlatform.isIOS) {
      return [
        MapAppInfo(
          name: 'Apple 地图',
          icon: FontAwesomeIcons.apple,
          color: const Color(0xFF000000),
          url: 'http://maps.apple.com/?daddr=$lat,$lon&dirflg=d',
          scheme: 'maps://',
        ),
        MapAppInfo(
          name: 'Google 地图',
          icon: FontAwesomeIcons.google,
          color: const Color(0xFF4285F4),
          url: 'comgooglemaps://?daddr=$lat,$lon&directionsmode=driving',
          scheme: 'comgooglemaps://',
          webFallback: 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
        ),
        MapAppInfo(
          name: '高德地图',
          icon: FontAwesomeIcons.mapLocationDot,
          color: const Color(0xFF0078FF),
          url: 'iosamap://path?sourceApplication=appname&dlat=$lat&dlon=$lon&dname=$name&dev=0&t=0',
          scheme: 'iosamap://',
        ),
        MapAppInfo(
          name: '百度地图',
          icon: FontAwesomeIcons.mapPin,
          color: const Color(0xFF3385FF),
          url: 'baidumap://map/direction?destination=latlng:$lat,$lon|name:$name&mode=driving&coord_type=wgs84',
          scheme: 'baidumap://',
        ),
        MapAppInfo(
          name: '腾讯地图',
          icon: FontAwesomeIcons.locationDot,
          color: const Color(0xFF12B7F5),
          url: 'qqmap://map/routeplan?type=drive&tocoord=$lat,$lon&to=$name',
          scheme: 'qqmap://',
        ),
      ];
    } else {
      // Android
      return [
        MapAppInfo(
          name: 'Google 地图',
          icon: FontAwesomeIcons.google,
          color: const Color(0xFF4285F4),
          url: 'google.navigation:q=$lat,$lon&mode=d',
          scheme: 'google.navigation:',
          webFallback: 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
        ),
        MapAppInfo(
          name: '高德地图',
          icon: FontAwesomeIcons.mapLocationDot,
          color: const Color(0xFF0078FF),
          url: 'androidamap://route?sourceApplication=appname&dlat=$lat&dlon=$lon&dname=$name&dev=0&t=0',
          scheme: 'androidamap://',
        ),
        MapAppInfo(
          name: '百度地图',
          icon: FontAwesomeIcons.mapPin,
          color: const Color(0xFF3385FF),
          url: 'baidumap://map/direction?destination=latlng:$lat,$lon|name:$name&mode=driving&coord_type=wgs84',
          scheme: 'baidumap://',
        ),
        MapAppInfo(
          name: '腾讯地图',
          icon: FontAwesomeIcons.locationDot,
          color: const Color(0xFF12B7F5),
          url: 'qqmap://map/routeplan?type=drive&tocoord=$lat,$lon&to=$name&referer=appname',
          scheme: 'qqmap://',
        ),
      ];
    }
  }

  // 启动地图应用
  Future<void> launchMapApp(MapAppInfo app) async {
    final uri = Uri.parse(app.url);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!launched) {
        if (app.webFallback != null) {
          final webUri = Uri.parse(app.webFallback!);
          final webLaunched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
          if (!webLaunched) {
            AppToast.error('无法打开 ${app.name}，请确保已安装该应用');
          }
        } else {
          AppToast.error('无法打开 ${app.name}，请确保已安装该应用');
        }
      }
    } catch (e) {
      if (app.webFallback != null) {
        try {
          final webUri = Uri.parse(app.webFallback!);
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } catch (_) {
          AppToast.error('无法打开 ${app.name}，请确保已安装该应用');
        }
      } else {
        AppToast.error('无法打开 ${app.name}，请确保已安装该应用');
      }
    }
  }
}
