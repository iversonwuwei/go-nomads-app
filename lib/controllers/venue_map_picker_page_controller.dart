import 'package:df_admin_mobile/services/amap_poi_service.dart';
import 'package:df_admin_mobile/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

/// VenueMapPickerPage 控制器
class VenueMapPickerPageController extends GetxController {
  final String? cityName;

  VenueMapPickerPageController({this.cityName});

  // 高德地图瓦片 - 使用多个服务器提高加载速度
  static const tileUrl =
      'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';
  static const subdomains = ['1', '2', '3', '4'];

  // POI 数据
  final Rx<Map<String, List<PoiResult>>> poiData = Rx<Map<String, List<PoiResult>>>({});
  final RxBool isLoadingPoi = false.obs;

  // 用户位置
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final RxBool isLoadingLocation = true.obs;
  final RxString currentCityName = ''.obs;

  late final MapController mapController;
  final ScrollController listScrollController = ScrollController();
  late LatLng initialCenter;
  final RxString selectedFilter = 'All'.obs;
  final Rx<String?> selectedVenueName = Rx<String?>(null);

  // 是否只显示选中项（从地图点击触发）
  final RxBool showOnlySelected = false.obs;

  // 地图是否已初始化（位置已获取）
  final RxBool isInitialized = false.obs;

  // ========== 测试模式开关 ==========
  static const bool useTestLocation = true;

  // 测试坐标列表
  static const List<Map<String, dynamic>> testLocations = [
    {'name': '上海 - 陆家嘴', 'lat': 31.2397, 'lng': 121.4998},
    {'name': '北京 - 王府井', 'lat': 39.9139, 'lng': 116.4120},
    {'name': '广州 - 天河', 'lat': 23.1291, 'lng': 113.2644},
    {'name': '深圳 - 福田', 'lat': 22.5431, 'lng': 114.0579},
    {'name': '杭州 - 西湖', 'lat': 30.2590, 'lng': 120.1290},
    {'name': '成都 - 春熙路', 'lat': 30.6571, 'lng': 104.0668},
  ];
  static const int testLocationIndex = 0;

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    initialCenter = const LatLng(13.7563, 100.5018); // 默认曼谷
    // 延迟初始化，等待地图渲染完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeLocation();
    });
  }

  @override
  void onClose() {
    listScrollController.dispose();
    super.onClose();
  }

  /// 初始化：获取用户位置并加载周边 POI
  Future<void> initializeLocation() async {
    isLoadingLocation.value = true;

    try {
      double lat, lng;

      if (useTestLocation) {
        // 使用测试坐标
        final testLoc = testLocations[testLocationIndex];
        lat = testLoc['lat'] as double;
        lng = testLoc['lng'] as double;
        currentCityName.value = (testLoc['name'] as String).split(' - ').first;
        debugPrint('📍 使用测试位置: ${testLoc['name']} ($lat, $lng)');
      } else {
        // 使用真实定位
        final locationService = Get.find<LocationService>();
        final position = await locationService.getCurrentLocation();
        if (position == null) {
          debugPrint('❌ 无法获取位置');
          isInitialized.value = true;
          isLoadingLocation.value = false;
          return;
        }
        lat = position.latitude;
        lng = position.longitude;
      }

      final userLatLng = LatLng(lat, lng);
      userLocation.value = userLatLng;
      initialCenter = userLatLng;
      isInitialized.value = true;
      // 加载周边 POI（不阻塞）
      _loadNearbyPoi(lat, lng);
    } catch (e) {
      debugPrint('❌ 获取位置失败: $e');
      isInitialized.value = true;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// 加载周边 POI
  Future<void> _loadNearbyPoi(double lat, double lng) async {
    isLoadingPoi.value = true;
    debugPrint('🚀 开始加载周边 POI: lat=$lat, lng=$lng');

    try {
      final results = await AmapPoiService.instance.searchAllTypes(
        latitude: lat,
        longitude: lng,
        radius: 3000,
        limitPerType: 15,
      );

      debugPrint('📊 POI 加载结果:');
      results.forEach((type, list) {
        debugPrint('   - $type: ${list.length} 个');
      });

      poiData.value = results;
    } catch (e) {
      debugPrint('❌ 加载 POI 失败: $e');
    } finally {
      isLoadingPoi.value = false;
    }
  }

  /// 获取筛选后的 POI 列表
  List<PoiResult> get filteredVenues {
    if (selectedFilter.value == 'All') {
      return poiData.value.values.expand((list) => list).toList();
    }
    return poiData.value[selectedFilter.value] ?? [];
  }

  void onFilterChanged(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    selectedVenueName.value = null;
  }

  void selectVenue(PoiResult venue, {bool moveCamera = true, bool fromMap = false}) {
    selectedVenueName.value = venue.name;
    // 从地图点击时，只显示选中项
    if (fromMap) {
      showOnlySelected.value = true;
    }
    if (moveCamera) {
      mapController.move(LatLng(venue.latitude, venue.longitude), 15);
    }
  }

  /// 显示全部列表
  void showAllVenues() {
    showOnlySelected.value = false;
  }

  /// 确认选择
  Map<String, dynamic>? confirmSelection(String noSelectionTitle, String pleaseSelectVenue) {
    final name = selectedVenueName.value;
    if (name == null) {
      Get.snackbar(noSelectionTitle, pleaseSelectVenue);
      return null;
    }
    final venues = filteredVenues;
    final venue = venues.firstWhereOrNull((v) => v.name == name);
    if (venue == null) return null;

    return {
      'name': venue.name,
      'address': venue.address,
      'type': venue.typeName,
      'latitude': venue.latitude,
      'longitude': venue.longitude,
    };
  }

  Color markerColor(String type) {
    switch (type) {
      case 'restaurant':
        return const Color(0xFFFF6B6B);
      case 'cafe':
        return const Color(0xFF8B4513);
      case 'hotel':
        return const Color(0xFF8338EC);
      case 'shopping':
        return const Color(0xFFFF9500);
      case 'attraction':
        return const Color(0xFF34C759);
      default:
        return const Color(0xFFFF4458);
    }
  }
}
