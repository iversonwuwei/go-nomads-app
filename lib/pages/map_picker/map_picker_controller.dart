import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/amap_poi_service.dart';
import 'package:go_nomads_app/services/location_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// 地图选点控制器
/// Map picker controller - 高德地图风格的中心点选取交互
class MapPickerController extends GetxController
    with GetTickerProviderStateMixin {
  // ============ 常量 ============
  static const _defaultCenter = LatLng(39.909187, 116.397451); // 北京
  static const _userAgent = 'go-nomads-app/1.0 (map-picker)';
  static const tileUrl =
      'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';

  // ============ 入参 ============
  late final double? initialLatitude;
  late final double? initialLongitude;
  late final String? searchQuery;
  late final String? country;
  late final String? city;

  // ============ 地图状态 ============
  final MapController mapController = MapController();
  final Rx<LatLng> mapCenter = _defaultCenter.obs;
  final RxDouble currentZoom = 15.0.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isLoadingLocation = true.obs;
  final RxBool isMapMoving = false.obs;

  // ============ 地址信息 ============
  final RxBool isReverseGeocoding = false.obs;
  final RxnString currentAddress = RxnString();
  final RxnString currentName = RxnString();
  final RxnString currentCity = RxnString();
  final RxnString currentProvince = RxnString();

  // ============ 搜索 ============
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final RxBool isSearching = false.obs;
  final RxList<MapPickerSearchResult> searchResults =
      <MapPickerSearchResult>[].obs;
  final RxBool hasMoreResults = true.obs;
  final RxBool isLoadingMore = false.obs;
  final ScrollController searchScrollController = ScrollController();
  int _searchPage = 1;
  String _lastQuery = '';
  Worker? _searchDebounce;
  final RxString _searchKeyword = ''.obs;

  // ============ 动画 ============
  late final AnimationController bounceController;
  late final Animation<double> bounceAnimation;

  // ============ 防抖 ============
  Timer? _mapIdleTimer;

  // ============ 生命周期 ============

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    _initBounceAnimation();
    _setupSearchDebounce();
    _setupSearchScrollListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeMap();
    });
  }

  @override
  void onClose() {
    bounceController.dispose();
    searchTextController.dispose();
    searchFocusNode.dispose();
    searchScrollController.dispose();
    _mapIdleTimer?.cancel();
    _searchDebounce?.dispose();
    super.onClose();
  }

  // ============ 初始化方法 ============

  /// 从 Get.arguments 解析入参
  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    initialLatitude = args['initialLatitude'] as double?;
    initialLongitude = args['initialLongitude'] as double?;
    searchQuery = args['searchQuery'] as String?;
    country = args['country'] as String?;
    city = args['city'] as String?;
  }

  /// 初始化弹跳动画
  void _initBounceAnimation() {
    bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -30.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -30.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 80,
      ),
    ]).animate(bounceController);
  }

  /// 设置搜索防抖
  void _setupSearchDebounce() {
    _searchDebounce = debounce(
      _searchKeyword,
      (String keyword) => _performSearch(keyword, reset: true),
      time: const Duration(milliseconds: 400),
    );
  }

  /// 设置搜索结果列表的滚动加载
  void _setupSearchScrollListener() {
    searchScrollController.addListener(() {
      if (searchScrollController.position.pixels >=
              searchScrollController.position.maxScrollExtent - 80 &&
          !isLoadingMore.value &&
          hasMoreResults.value) {
        loadMoreResults();
      }
    });
  }

  // ============ 地图初始化 ============

  /// 初始化地图：按优先级确定初始位置
  /// 1. 传入坐标 → 2. 城市/国家名称地理编码 → 3. GPS 真实位置 → 4. 默认北京
  Future<void> initializeMap() async {
    isLoadingLocation.value = true;

    LatLng position;
    double zoom;

    // 优先使用传入的坐标
    if (initialLatitude != null && initialLongitude != null) {
      position = LatLng(initialLatitude!, initialLongitude!);
      zoom = 15.0;
      debugPrint('📍 使用传入坐标: $initialLatitude, $initialLongitude');
    }
    // 其次根据城市/国家名称定位
    else if (city != null || country != null) {
      final result = await _geocodeByLocation(city, country);
      if (result != null) {
        position = result;
        zoom = city != null ? 12.0 : 6.0;
        debugPrint('📍 根据地区定位: $city, $country');
      } else {
        position = _defaultCenter;
        zoom = 12.0;
        debugPrint('📍 地区定位失败，使用默认位置');
      }
    }
    // 最后尝试 GPS 定位（给真机 10 秒超时）
    else {
      final gpsPosition = await _getCurrentPosition();
      position = gpsPosition ?? _defaultCenter;
      zoom = gpsPosition != null ? 15.0 : 12.0;
    }

    mapCenter.value = position;
    currentZoom.value = zoom;
    isInitialized.value = true;
    isLoadingLocation.value = false;

    // 立即用入参设置底部卡片的初始显示（避免显示空白或默认数据）
    if (city != null && city!.isNotEmpty) {
      currentCity.value = city;
    }
    if (country != null && country!.isNotEmpty) {
      currentProvince.value = country;
    }

    final hasSearchQuery = (searchQuery ?? '').trim().isNotEmpty;

    if (hasSearchQuery) {
      // 有搜索查询时：先用查询文本作为临时显示，再正向地理编码定位
      // 不调用 _reverseGeocode 避免竞态覆盖
      final trimmedQuery = searchQuery!.trim();
      currentAddress.value = trimmedQuery;
      currentName.value = trimmedQuery;
      searchTextController.text = trimmedQuery;
      await _geocodeAddress(trimmedQuery);
    } else {
      // 无搜索查询时：对初始位置进行逆地理编码获取地址
      _reverseGeocode(position);
    }
  }

  /// 获取 GPS 当前位置，超时 10 秒
  Future<LatLng?> _getCurrentPosition() async {
    try {
      final locationService = Get.find<LocationService>();
      // 使用 10 秒超时（而非旧版 3 秒），给真机 GPS 足够时间
      final position = await locationService
          .getCurrentLocation()
          .timeout(const Duration(seconds: 10), onTimeout: () => null);

      if (position != null) {
        debugPrint(
            '📍 获取到真实位置: ${position.latitude}, ${position.longitude}');
        return LatLng(position.latitude, position.longitude);
      }
      debugPrint('📍 GPS 定位超时或无结果');
    } catch (e) {
      debugPrint('❌ 获取位置失败: $e');
    }
    return null;
  }

  // ============ 地图事件 ============

  /// 地图位置改变时回调（用户手势拖动触发）
  /// 通过 500ms 防抖检测地图停止，然后触发逆地理编码
  void onMapPositionChanged(MapCamera camera, bool hasGesture) {
    mapCenter.value = camera.center;
    currentZoom.value = camera.zoom;

    if (hasGesture) {
      isMapMoving.value = true;
      _mapIdleTimer?.cancel();
      _mapIdleTimer = Timer(const Duration(milliseconds: 500), () {
        isMapMoving.value = false;
        bounceController.forward(from: 0.0);
        _reverseGeocode(camera.center);
      });
    }
  }

  /// 地图点击 - 移动到点击位置
  void onMapTap(TapPosition tapPosition, LatLng point) {
    mapController.move(point, currentZoom.value);
    mapCenter.value = point;
    bounceController.forward(from: 0.0);
    _reverseGeocode(point);
  }

  // ============ 逆地理编码 ============

  /// 高德逆地理编码：坐标 → 地址
  Future<void> _reverseGeocode(LatLng target) async {
    isReverseGeocoding.value = true;

    try {
      final result = await AmapPoiService.instance.reverseGeocode(
        latitude: target.latitude,
        longitude: target.longitude,
      );

      if (result != null) {
        currentAddress.value = result.formattedAddress.isNotEmpty
            ? result.formattedAddress
            : result.detailedAddress;
        currentName.value = result.shortAddress.isNotEmpty
            ? result.shortAddress
            : result.formattedAddress;
        currentCity.value =
            (result.city?.isNotEmpty ?? false) ? result.city : null;
        currentProvince.value =
            (result.province?.isNotEmpty ?? false) ? result.province : null;
      } else {
        _setCoordinateAddress(target);
      }
    } catch (e) {
      debugPrint('❌ 逆地理编码失败: $e');
      _setCoordinateAddress(target);
    } finally {
      isReverseGeocoding.value = false;
    }
  }

  /// 将坐标设为地址（逆地理编码失败时的回退）
  void _setCoordinateAddress(LatLng target) {
    currentAddress.value =
        '${target.latitude.toStringAsFixed(6)}, ${target.longitude.toStringAsFixed(6)}';
    currentName.value = currentAddress.value;
    currentCity.value = null;
    currentProvince.value = null;
  }

  // ============ 正向地理编码 ============

  /// 高德正向地理编码：地址 → 坐标
  Future<void> _geocodeAddress(String address) async {
    isSearching.value = true;

    try {
      final result = await AmapPoiService.instance.geocode(
        address: address,
        city: city,
      );

      if (result != null) {
        final target = LatLng(result.latitude, result.longitude);
        mapCenter.value = target;
        mapController.move(target, 15.0);
        searchResults.clear();
        bounceController.forward(from: 0.0);
        debugPrint(
            '📍 正向地理编码成功: ${result.formattedAddress} → ${result.latitude}, ${result.longitude}');
        // 对定位到的坐标进行逆地理编码，获取完整的 city/province 等结构化地址
        await _reverseGeocode(target);
      } else {
        debugPrint('📍 正向地理编码失败，回退到搜索');
        await _performSearch(address, autoSelectFirst: true, reset: true);
      }
    } catch (e) {
      debugPrint('❌ 正向地理编码失败: $e');
      await _performSearch(address, autoSelectFirst: true, reset: true);
    } finally {
      isSearching.value = false;
    }
  }

  /// 根据城市/国家名称进行地理编码（使用 Nominatim）
  Future<LatLng?> _geocodeByLocation(
      String? cityName, String? countryName) async {
    final queryParts = <String>[];
    if (cityName != null && cityName.isNotEmpty) queryParts.add(cityName);
    if (countryName != null && countryName.isNotEmpty) {
      queryParts.add(countryName);
    }
    if (queryParts.isEmpty) return null;

    final query = queryParts.join(', ');
    debugPrint('🔍 根据地区搜索坐标: $query');

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'jsonv2',
        'limit': '1',
        'q': query,
        'addressdetails': '1',
      });

      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        debugPrint('❌ 地理编码请求失败: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isEmpty) {
        debugPrint('❌ 未找到地区: $query');
        return null;
      }

      final first = data.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat']?.toString() ?? '');
      final lon = double.tryParse(first['lon']?.toString() ?? '');

      if (lat != null && lon != null) {
        debugPrint('✅ 找到地区坐标: $lat, $lon');
        final address = first['address'] as Map<String, dynamic>?;
        currentAddress.value = first['display_name'] as String? ?? '';
        currentName.value =
            (first['name'] as String?) ?? currentAddress.value;
        final cityCandidate = (address?['city'] ??
                address?['town'] ??
                address?['state'])
            ?.toString();
        final provinceCandidate = (address?['state'] ??
                address?['region'] ??
                address?['country'])
            ?.toString();
        currentCity.value =
            cityCandidate?.isNotEmpty == true ? cityCandidate : null;
        currentProvince.value =
            provinceCandidate?.isNotEmpty == true ? provinceCandidate : null;
        return LatLng(lat, lon);
      }
    } catch (e) {
      debugPrint('❌ 地理编码失败: $e');
    }
    return null;
  }

  // ============ 搜索 ============

  /// 搜索输入变化（带 400ms 防抖）
  void onSearchChanged(String value) {
    _searchKeyword.value = value;
    if (value.trim().isEmpty) {
      searchResults.clear();
    }
  }

  /// 键盘搜索提交
  void onSearchSubmitted(String value) {
    _performSearch(value, autoSelectFirst: true, reset: true);
  }

  /// 清空搜索
  void clearSearch() {
    searchTextController.clear();
    searchResults.clear();
    _searchKeyword.value = '';
    _lastQuery = '';
  }

  /// 执行 POI 搜索
  Future<void> _performSearch(
    String rawQuery, {
    bool autoSelectFirst = false,
    bool reset = true,
  }) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      searchResults.clear();
      hasMoreResults.value = true;
      _searchPage = 1;
      _lastQuery = '';
      return;
    }

    if (reset) {
      _searchPage = 1;
      hasMoreResults.value = true;
      searchResults.clear();
      _lastQuery = query;
    }

    isSearching.value = true;
    isLoadingMore.value = false;

    try {
      final result = await AmapPoiService.instance.searchByKeyword(
        keyword: query,
        city: city,
        page: _searchPage,
        pageSize: 20,
      );

      final mapped = result.items
          .map((poi) => MapPickerSearchResult(
                location: LatLng(poi.latitude, poi.longitude),
                title: poi.name,
                subtitle: poi.address.isNotEmpty
                    ? poi.address
                    : (poi.businessArea ?? ''),
              ))
          .toList();

      if (reset) {
        searchResults.value = mapped;
      } else {
        searchResults.addAll(mapped);
      }
      hasMoreResults.value = result.hasMore;

      if (autoSelectFirst && mapped.isNotEmpty) {
        selectSearchResult(mapped.first);
      }
    } catch (e) {
      debugPrint('❌ 搜索失败: $e');
    } finally {
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  /// 加载更多搜索结果
  Future<void> loadMoreResults() async {
    if (_lastQuery.isEmpty || !hasMoreResults.value || isLoadingMore.value) {
      return;
    }

    isLoadingMore.value = true;
    _searchPage += 1;

    try {
      final result = await AmapPoiService.instance.searchByKeyword(
        keyword: _lastQuery,
        city: city,
        page: _searchPage,
        pageSize: 20,
      );

      final mapped = result.items
          .map((poi) => MapPickerSearchResult(
                location: LatLng(poi.latitude, poi.longitude),
                title: poi.name,
                subtitle: poi.address.isNotEmpty
                    ? poi.address
                    : (poi.businessArea ?? ''),
              ))
          .toList();

      searchResults.addAll(mapped);
      hasMoreResults.value = result.hasMore;
    } catch (_) {
      // 静默处理分页加载失败
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 选择搜索结果 - 移动地图到该位置并逆地理编码
  void selectSearchResult(MapPickerSearchResult result) {
    searchResults.clear();
    searchFocusNode.unfocus();
    mapCenter.value = result.location;
    mapController.move(result.location, 15.0);
    bounceController.forward(from: 0.0);
    _reverseGeocode(result.location);
  }

  // ============ 重新定位 ============

  /// 重新定位到用户当前 GPS 位置
  Future<void> relocateToMyPosition() async {
    isLoadingLocation.value = true;
    final position = await _getCurrentPosition();
    isLoadingLocation.value = false;

    if (position != null) {
      mapCenter.value = position;
      mapController.move(position, 15.0);
      bounceController.forward(from: 0.0);
      _reverseGeocode(position);
    } else {
      AppToast.warning(AppLocalizations.of(Get.context!)!.failedToGetLocation);
    }
  }

  // ============ 确认选择 ============

  /// 确认按钮是否可用
  bool get canConfirm =>
      (currentAddress.value ?? '').isNotEmpty && !isReverseGeocoding.value;

  /// 确认选择 - 将选中位置信息返回上一页
  void confirmSelection() {
    Get.back(result: {
      'latitude': mapCenter.value.latitude,
      'longitude': mapCenter.value.longitude,
      'address': currentAddress.value ?? '',
      'name': currentName.value ?? '',
      'city': currentCity.value ?? '',
      'province': currentProvince.value ?? '',
    });
  }
}

/// 搜索结果数据模型
class MapPickerSearchResult {
  final LatLng location;
  final String title;
  final String subtitle;

  const MapPickerSearchResult({
    required this.location,
    required this.title,
    required this.subtitle,
  });
}
