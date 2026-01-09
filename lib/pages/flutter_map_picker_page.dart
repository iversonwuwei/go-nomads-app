import 'dart:async';
import 'dart:convert';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/amap_poi_service.dart';
import 'package:df_admin_mobile/services/location_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// 使用 flutter_map 的地点选择器页面
/// 支持实时位置获取、地点搜索、反向地理编码
class FlutterMapPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? searchQuery;

  /// 国家名称（用于初始化时定位到该国家）
  final String? country;

  /// 城市名称（用于初始化时定位到该城市）
  final String? city;

  const FlutterMapPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.searchQuery,
    this.country,
    this.city,
  });

  @override
  State<FlutterMapPickerPage> createState() => _FlutterMapPickerPageState();
}

class _FlutterMapPickerPageState extends State<FlutterMapPickerPage> with SingleTickerProviderStateMixin {
  static const _defaultTarget = LatLng(39.909187, 116.397451); // 北京默认位置
  static const _userAgent = 'df-admin-mobile/1.0 (map picker)';

  // 模拟位置数据（用于模拟器测试）
  static const _mockLocations = [
    {'name': '北京市', 'lat': 39.909187, 'lng': 116.397451},
    {'name': '上海市', 'lat': 31.230416, 'lng': 121.473701},
    {'name': '广州市', 'lat': 23.129110, 'lng': 113.264385},
    {'name': '深圳市', 'lat': 22.543096, 'lng': 114.057865},
    {'name': '杭州市', 'lat': 30.274084, 'lng': 120.155070},
    {'name': '成都市', 'lat': 30.572815, 'lng': 104.066801},
  ];

  final MapController _mapController = MapController();
  LatLng _currentCenter = _defaultTarget; // 地图中心点
  LatLng _markerPosition = _defaultTarget; // 锚点/标记位置（只在点击时更新）
  double _currentZoom = 15.0;
  bool _isInitialized = false;

  // 弹跳动画控制器
  AnimationController? _bounceController;
  Animation<double>? _bounceAnimation;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _isReverseGeocoding = false;
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  bool _isUsingMockLocation = false; // 是否使用模拟位置

  String? _currentAddress;
  String? _currentCity;
  String? _currentProvince;
  String? _currentName;

  List<_SearchResult> _searchResults = const [];
  final ScrollController _searchScrollController = ScrollController();
  int _searchPage = 1;
  bool _hasMoreResults = true;
  bool _isLoadingMore = false;
  String _lastQuery = '';

  // 瓦片源配置（使用高德地图）
  final String _tileUrl =
      'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';

  @override
  void initState() {
    super.initState();

    // 初始化弹跳动画
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 使用弹性曲线实现 duangduang 效果
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -30.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -30.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 80,
      ),
    ]).animate(_bounceController!);

    _initializeMap();
    _searchScrollController.addListener(() {
      if (_searchScrollController.position.pixels >= _searchScrollController.position.maxScrollExtent - 80 &&
          !_isLoadingMore &&
          _hasMoreResults) {
        _loadMoreResults();
      }
    });
  }

  @override
  void dispose() {
    _bounceController?.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchScrollController.dispose();
    super.dispose();
  }

  /// 初始化地图
  Future<void> _initializeMap() async {
    setState(() {
      _isLoadingLocation = true;
    });

    LatLng initialPosition;
    double initialZoom;

    // 优先使用传入的坐标
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      initialPosition = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      initialZoom = 15.0;
      debugPrint('📍 使用传入的坐标: ${widget.initialLatitude}, ${widget.initialLongitude}');
    }
    // 其次尝试根据城市和国家定位
    else if (widget.city != null || widget.country != null) {
      final locationResult = await _geocodeByLocation(widget.city, widget.country);
      if (locationResult != null) {
        initialPosition = locationResult;
        initialZoom = widget.city != null ? 12.0 : 6.0; // 城市级别用12，国家级别用6
        debugPrint('📍 根据地区定位: ${widget.city ?? ''}, ${widget.country ?? ''}');
      } else {
        // 定位失败，使用默认位置
        _isUsingMockLocation = true;
        initialPosition = _defaultTarget;
        initialZoom = 12.0;
        debugPrint('📍 地区定位失败，使用默认位置');
      }
    }
    // 最后尝试获取当前位置
    else {
      try {
        final locationService = Get.find<LocationService>();

        // 使用超时机制，避免无限等待
        final position =
            await locationService.getCurrentLocation().timeout(const Duration(seconds: 3), onTimeout: () => null);

        if (position != null) {
          initialPosition = LatLng(position.latitude, position.longitude);
          initialZoom = 15.0;
          debugPrint('📍 获取到真实位置: ${position.latitude}, ${position.longitude}');
        } else {
          // 使用模拟位置（随机选择一个城市）
          _isUsingMockLocation = true;
          final mockIndex = DateTime.now().millisecond % _mockLocations.length;
          final mockLocation = _mockLocations[mockIndex];
          initialPosition = LatLng(
            mockLocation['lat'] as double,
            mockLocation['lng'] as double,
          );
          initialZoom = 12.0;
          debugPrint('📍 使用模拟位置: ${mockLocation['name']}');
        }
      } catch (e) {
        debugPrint('获取位置失败: $e');
        // 使用模拟位置（默认北京）
        _isUsingMockLocation = true;
        initialPosition = _defaultTarget;
        initialZoom = 12.0;
        debugPrint('📍 使用默认模拟位置: 北京');
      }
    }

    if (!mounted) return;

    setState(() {
      _currentCenter = initialPosition;
      _markerPosition = initialPosition; // 初始锚点位置
      _currentZoom = initialZoom;
      _isLoadingLocation = false;
      _isInitialized = true;
    });

    // 如果使用模拟位置，设置模拟地址信息
    if (_isUsingMockLocation) {
      _setMockAddress(_markerPosition);
    } else {
      // 初始化后立即进行反向地理编码
      await _reverseGeocode(_markerPosition);
    }

    // 如果有搜索查询（地址），使用高德地图 API 进行正向地理编码
    if ((widget.searchQuery ?? '').trim().isNotEmpty) {
      final query = widget.searchQuery!.trim();
      _searchController.text = query;

      // 使用高德地图 API 进行正向地理编码（对中国地址更准确）
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _geocodeAddress(query);
      });
    }
  }

  /// 使用高德地图 API 进行正向地理编码（地址 -> 坐标）
  Future<void> _geocodeAddress(String address) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // 首先尝试使用高德地图 API 进行地理编码
      final result = await AmapPoiService.instance.geocode(
        address: address,
        city: widget.city,
      );

      if (!mounted) return;

      if (result != null) {
        final target = LatLng(result.latitude, result.longitude);

        setState(() {
          _currentCenter = target;
          _markerPosition = target;
          _currentAddress = result.formattedAddress;
          _currentName = result.formattedAddress;
          _searchResults = const [];
        });

        _mapController.move(target, 15.0);

        // 播放弹跳动画
        _bounceController?.forward(from: 0.0);

        debugPrint('📍 高德地理编码成功: ${result.formattedAddress} -> ${result.latitude}, ${result.longitude}');
      } else {
        // 高德 API 失败时，回退到 Nominatim 搜索
        debugPrint('📍 高德地理编码失败，回退到 Nominatim 搜索');
        await _searchPlaces(address, autoSelectFirst: true);
      }
    } catch (e) {
      debugPrint('地理编码失败: $e');
      // 失败时回退到 Nominatim 搜索
      await _searchPlaces(address, autoSelectFirst: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  /// 根据城市和国家名称获取坐标
  Future<LatLng?> _geocodeByLocation(String? city, String? country) async {
    // 构建搜索查询
    final queryParts = <String>[];
    if (city != null && city.isNotEmpty) {
      queryParts.add(city);
    }
    if (country != null && country.isNotEmpty) {
      queryParts.add(country);
    }

    if (queryParts.isEmpty) {
      return null;
    }

    final query = queryParts.join(', ');
    debugPrint('🔍 根据地区搜索坐标: $query');

    try {
      final locale = Localizations.maybeLocaleOf(context);

      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'jsonv2',
        'limit': '1',
        'q': query,
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          if (locale != null) 'Accept-Language': locale.languageCode,
        },
      ).timeout(const Duration(seconds: 5));

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

        // 同时设置地址信息
        final address = first['address'] as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            _currentAddress = first['display_name'] as String? ?? '';
            _currentName = (first['name'] as String?) ?? _currentAddress;
            final cityCandidate = (address?['city'] ?? address?['town'] ?? address?['state'])?.toString();
            final provinceCandidate = (address?['state'] ?? address?['region'] ?? address?['country'])?.toString();
            _currentCity = cityCandidate?.isNotEmpty == true ? cityCandidate : null;
            _currentProvince = provinceCandidate?.isNotEmpty == true ? provinceCandidate : null;
          });
        }

        return LatLng(lat, lon);
      }
    } catch (e) {
      debugPrint('❌ 地理编码失败: $e');
    }

    return null;
  }

  /// 设置模拟地址信息
  void _setMockAddress(LatLng position) {
    // 根据位置找到最近的模拟城市
    String cityName = '北京市';
    String provinceName = '北京市';

    double minDistance = double.infinity;
    for (final mock in _mockLocations) {
      final lat = mock['lat'] as double;
      final lng = mock['lng'] as double;
      final distance = (position.latitude - lat).abs() + (position.longitude - lng).abs();
      if (distance < minDistance) {
        minDistance = distance;
        cityName = mock['name'] as String;
        // 根据城市名设置省份
        if (cityName == '北京市' || cityName == '上海市') {
          provinceName = cityName;
        } else if (cityName == '广州市' || cityName == '深圳市') {
          provinceName = '广东省';
        } else if (cityName == '杭州市') {
          provinceName = '浙江省';
        } else if (cityName == '成都市') {
          provinceName = '四川省';
        }
      }
    }

    // 显示坐标和最近城市
    final coordStr = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

    setState(() {
      _currentAddress = '$provinceName$cityName 附近（$coordStr）';
      _currentName = '$provinceName$cityName';
      _currentCity = cityName;
      _currentProvince = provinceName;
    });
  }

  /// 地图点击回调 - 只在点击时更新锚点位置
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _markerPosition = point;
    });

    // 播放弹跳动画
    _bounceController?.forward(from: 0.0);

    // 获取点击位置的地址信息
    if (_isUsingMockLocation) {
      _setMockAddress(point);
    } else {
      _reverseGeocode(point);
    }
  }

  /// 反向地理编码 - 使用高德地图 API
  Future<void> _reverseGeocode(LatLng target) async {
    if (!mounted) return;

    setState(() {
      _isReverseGeocoding = true;
    });

    try {
      // 使用高德 API 进行逆地理编码（国内访问更快更稳定）
      final result = await AmapPoiService.instance.reverseGeocode(
        latitude: target.latitude,
        longitude: target.longitude,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          // 优先使用 formattedAddress（高德返回的完整详细地址）
          // formattedAddress 通常包含省市区街道门牌号等完整信息
          _currentAddress = result.formattedAddress.isNotEmpty ? result.formattedAddress : result.detailedAddress;
          // name 使用简短地址供显示（用于标题等场景）
          _currentName = result.shortAddress.isNotEmpty ? result.shortAddress : result.formattedAddress;
          _currentCity = (result.city?.isNotEmpty ?? false) ? result.city : null;
          _currentProvince = (result.province?.isNotEmpty ?? false) ? result.province : null;
        });
      } else {
        // 高德 API 失败时，设置坐标作为地址显示
        setState(() {
          _currentAddress = '${target.latitude.toStringAsFixed(6)}, ${target.longitude.toStringAsFixed(6)}';
          _currentName = _currentAddress;
          _currentCity = null;
          _currentProvince = null;
        });
      }
    } catch (e) {
      debugPrint('反向地理编码失败: $e');
      if (mounted) {
        // 即使 API 失败，也设置坐标作为地址显示
        setState(() {
          _currentAddress = '${target.latitude.toStringAsFixed(6)}, ${target.longitude.toStringAsFixed(6)}';
          _currentName = _currentAddress;
          _currentCity = null;
          _currentProvince = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReverseGeocoding = false;
        });
      }
    }
  }

  /// 搜索输入变化
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchPlaces(value, autoSelectFirst: false, reset: true);
    });
  }

  /// 搜索地点
  Future<void> _searchPlaces(String rawQuery, {bool autoSelectFirst = false, bool reset = true}) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = const [];
        _hasMoreResults = true;
        _searchPage = 1;
        _lastQuery = '';
      });
      return;
    }

    if (reset) {
      _searchPage = 1;
      _hasMoreResults = true;
      _searchResults = const [];
      _lastQuery = query;
    }

    setState(() {
      _isSearching = true;
      _isLoadingMore = false;
    });

    try {
      final result = await AmapPoiService.instance.searchByKeyword(
        keyword: query,
        city: widget.city,
        page: _searchPage,
        pageSize: 20,
      );

      if (!mounted) return;

      final mapped = result.items
          .map((poi) => _SearchResult(
                location: poi.toLatLng(),
                title: poi.name,
                subtitle: poi.address.isNotEmpty ? poi.address : (poi.businessArea ?? ''),
              ))
          .toList();

      setState(() {
        _searchResults = reset ? mapped : [..._searchResults, ...mapped];
        _hasMoreResults = result.hasMore;
      });

      if (autoSelectFirst && mapped.isNotEmpty) {
        _moveCameraTo(mapped.first.location);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          e.toString(),
          title: AppLocalizations.of(context)?.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreResults() async {
    if (_lastQuery.isEmpty || !_hasMoreResults || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _searchPage += 1;
    });

    try {
      final result = await AmapPoiService.instance.searchByKeyword(
        keyword: _lastQuery,
        city: widget.city,
        page: _searchPage,
        pageSize: 20,
      );

      if (!mounted) return;

      final mapped = result.items
          .map((poi) => _SearchResult(
                location: poi.toLatLng(),
                title: poi.name,
                subtitle: poi.address.isNotEmpty ? poi.address : (poi.businessArea ?? ''),
              ))
          .toList();

      setState(() {
        _searchResults = [..._searchResults, ...mapped];
        _hasMoreResults = result.hasMore;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        _isLoadingMore = false;
      }
    }
  }

  /// 移动地图到指定位置并更新锚点
  Future<void> _moveCameraTo(LatLng target) async {
    setState(() {
      _searchResults = const [];
      _currentCenter = target;
      _markerPosition = target; // 搜索选择时也更新锚点
    });

    _mapController.move(target, 15.0);

    // 播放弹跳动画
    _bounceController?.forward(from: 0.0);

    if (_isUsingMockLocation) {
      _setMockAddress(target);
    } else {
      await _reverseGeocode(target);
    }
  }

  /// 确认选择
  void _confirmSelection() {
    final latitude = _markerPosition.latitude;
    final longitude = _markerPosition.longitude;

    Get.back(result: {
      'latitude': latitude,
      'longitude': longitude,
      'address': _currentAddress ?? '',
      'name': _currentName ?? '',
      'city': _currentCity ?? '',
      'province': _currentProvince ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final canConfirm = (_currentAddress ?? '').isNotEmpty && !_isReverseGeocoding;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(color: AppColors.backButtonDark),
        title: Text(
          l10n.selectLocation,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchCityOrCountry,
                prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(FontAwesomeIcons.xmark),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = const []);
                            },
                          )),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (value) => _searchPlaces(value, autoSelectFirst: true),
            ),
          ),

          // 地图区域
          Expanded(
            child: Stack(
              children: [
                // 加载指示器
                if (_isLoadingLocation)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '正在获取您的位置...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_isInitialized)
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentCenter,
                      initialZoom: _currentZoom,
                      minZoom: 2,
                      maxZoom: 18,
                      onTap: _onMapTap, // 点击地图更新锚点
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _tileUrl,
                        userAgentPackageName: 'com.digitalfuture.df_admin_mobile',
                        maxZoom: 18,
                        minZoom: 2,
                      ),
                      // 锚点标记层
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _markerPosition,
                            width: 50,
                            height: 80,
                            alignment: Alignment.topCenter,
                            child: AnimatedBuilder(
                              animation: _bounceAnimation ?? const AlwaysStoppedAnimation(0.0),
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _bounceAnimation?.value ?? 0),
                                  child: child,
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.locationDot,
                                    size: 50,
                                    color: Color(0xFFFF4458),
                                  ),
                                  // 阴影效果
                                  Container(
                                    width: 20,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                // 模拟位置提示
                if (_isUsingMockLocation)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.triangleExclamation,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '模拟器环境：使用模拟位置数据',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 搜索结果列表
                if (_searchResults.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: _isUsingMockLocation ? 60 : 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.separated(
                          controller: _searchScrollController,
                          shrinkWrap: true,
                          itemCount: _searchResults.length + (_hasMoreResults ? 1 : 0),
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.withValues(alpha: 0.15),
                          ),
                          itemBuilder: (context, index) {
                            if (index >= _searchResults.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('加载更多中...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              );
                            }

                            final result = _searchResults[index];
                            return InkWell(
                              onTap: () => _moveCameraTo(result.location),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF4458).withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        FontAwesomeIcons.locationDot,
                                        size: 16,
                                        color: Color(0xFFFF4458),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            result.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            result.subtitle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // 底部信息和确认按钮
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.selectedLocation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isReverseGeocoding)
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l10n.loading),
                                  ],
                                )
                              else
                                Text(
                                  // 优先显示名称，其次显示完整地址
                                  (_currentName ?? '').isNotEmpty
                                      ? _currentName!
                                      : ((_currentAddress ?? '').isNotEmpty
                                          ? _currentAddress!
                                          : l10n.pickLocationOnMap),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                              // 显示完整地址作为副标题（如果与名称不同）
                              if ((_currentAddress ?? '').isNotEmpty && _currentAddress != _currentName)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _currentAddress!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if ((_currentCity ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    [
                                      if ((_currentCity ?? '').isNotEmpty) _currentCity,
                                      if ((_currentProvince ?? '').isNotEmpty) _currentProvince,
                                    ].join(' · '),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canConfirm ? _confirmSelection : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFFF4458),
                              disabledBackgroundColor: Colors.grey[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.confirm,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜索结果数据类
class _SearchResult {
  final LatLng location;
  final String title;
  final String subtitle;

  const _SearchResult({
    required this.location,
    required this.title,
    required this.subtitle,
  });
}

extension _PoiResultLatLng on PoiResult {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
