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
import 'package:latlong2/latlong.dart';

/// Flutter-map implementation of the venue picker used by the meetup form.
class VenueMapPickerPage extends StatefulWidget {
  final String? cityName;

  const VenueMapPickerPage({super.key, this.cityName});

  @override
  State<VenueMapPickerPage> createState() => _VenueMapPickerPageState();
}

class _VenueMapPickerPageState extends State<VenueMapPickerPage> {
  static const _tileUrl =
      'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';

  // POI 数据
  Map<String, List<PoiResult>> _poiData = {};
  bool _isLoadingPoi = false;

  // 用户位置
  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  String? _currentCityName;

  final MapController _mapController = MapController();
  late LatLng _initialCenter;
  String _selectedFilter = 'All';
  String? _selectedVenueName;

  // ========== 测试模式开关 ==========
  // 设置为 true 使用测试坐标，false 使用真实定位
  static const bool _useTestLocation = true;

  // 测试坐标列表（可切换不同城市测试）
  static const List<Map<String, dynamic>> _testLocations = [
    {'name': '上海 - 陆家嘴', 'lat': 31.2397, 'lng': 121.4998},
    {'name': '北京 - 王府井', 'lat': 39.9139, 'lng': 116.4120},
    {'name': '广州 - 天河', 'lat': 23.1291, 'lng': 113.2644},
    {'name': '深圳 - 福田', 'lat': 22.5431, 'lng': 114.0579},
    {'name': '杭州 - 西湖', 'lat': 30.2590, 'lng': 120.1290},
    {'name': '成都 - 春熙路', 'lat': 30.6571, 'lng': 104.0668},
  ];
  // 选择测试位置索引 (0-5)
  static const int _testLocationIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialCenter = const LatLng(13.7563, 100.5018); // 默认曼谷
    // 延迟初始化，等待地图渲染完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  /// 初始化：获取用户位置并加载周边 POI
  Future<void> _initializeLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      double lat, lng;

      if (_useTestLocation) {
        // 使用测试坐标
        final testLoc = _testLocations[_testLocationIndex];
        lat = testLoc['lat'] as double;
        lng = testLoc['lng'] as double;
        _currentCityName = (testLoc['name'] as String).split(' - ').first;
        debugPrint('📍 使用测试位置: ${testLoc['name']} ($lat, $lng)');
      } else {
        // 使用真实定位
        final locationService = Get.find<LocationService>();
        final position = await locationService.getCurrentLocation();
        if (position == null) {
          debugPrint('❌ 无法获取位置');
          return;
        }
        lat = position.latitude;
        lng = position.longitude;
      }

      if (mounted) {
        final userLatLng = LatLng(lat, lng);
        setState(() {
          _userLocation = userLatLng;
          _initialCenter = userLatLng;
        });
        // 安全地移动地图
        try {
          _mapController.move(userLatLng, 14);
        } catch (_) {
          // 如果地图还未准备好，忽略错误，setState 已更新 _initialCenter
        }
        await _loadNearbyPoi(lat, lng);
      }
    } catch (e) {
      debugPrint('❌ 获取位置失败: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// 加载周边 POI
  Future<void> _loadNearbyPoi(double lat, double lng) async {
    setState(() => _isLoadingPoi = true);
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
      
      if (mounted) setState(() => _poiData = results);
    } catch (e) {
      debugPrint('❌ 加载 POI 失败: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPoi = false);
    }
  }

  /// 获取筛选后的 POI 列表
  List<PoiResult> get _filteredVenues {
    if (_selectedFilter == 'All') {
      return _poiData.values.expand((list) => list).toList();
    }
    return _poiData[_selectedFilter] ?? [];
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _selectedVenueName = null;
    });
  }

  void _selectVenue(PoiResult venue, {bool moveCamera = true}) {
    setState(() => _selectedVenueName = venue.name);
    if (moveCamera) {
      _mapController.move(LatLng(venue.latitude, venue.longitude), 15);
    }
  }

  void _confirmSelection() {
    final l10n = AppLocalizations.of(context)!;
    final name = _selectedVenueName;
    if (name == null) {
      AppToast.warning(l10n.pleaseSelectVenue, title: l10n.noSelection);
      return;
    }
    final venues = _filteredVenues;
    final venue = venues.firstWhereOrNull((v) => v.name == name);
    if (venue == null) return;

    Get.back(result: {
      'name': venue.name,
      'address': venue.address,
      'type': venue.typeName,
      'latitude': venue.latitude,
      'longitude': venue.longitude,
    });
  }

  Color _markerColor(String type) {
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

  IconData _markerIcon(String type) {
    switch (type) {
      case 'restaurant':
        return FontAwesomeIcons.utensils;
      case 'cafe':
        return FontAwesomeIcons.mugHot;
      case 'hotel':
        return FontAwesomeIcons.hotel;
      case 'shopping':
        return FontAwesomeIcons.bagShopping;
      case 'attraction':
        return FontAwesomeIcons.mountain;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(color: AppColors.backButtonDark),
        title: Text(
          l10n.selectVenue,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: Text(
              l10n.confirm,
              style: const TextStyle(
                color: Color(0xFFFF4458),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChips(l10n),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMap(l10n),
            ),
          ),
          Expanded(child: _buildVenueList(l10n)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = [
      {'key': 'All', 'label': l10n.all, 'icon': FontAwesomeIcons.layerGroup},
      {'key': 'hotel', 'label': l10n.hotels, 'icon': FontAwesomeIcons.hotel},
      {'key': 'cafe', 'label': 'Cafes', 'icon': FontAwesomeIcons.mugHot},
      {'key': 'restaurant', 'label': l10n.restaurants, 'icon': FontAwesomeIcons.utensils},
      {'key': 'shopping', 'label': 'Shopping', 'icon': FontAwesomeIcons.bagShopping},
      {'key': 'attraction', 'label': 'Attractions', 'icon': FontAwesomeIcons.mountain},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(filter['icon'] as IconData, size: 14),
                label: Text(filter['label'] as String),
                selected: isSelected,
                onSelected: (_) => _onFilterChanged(filter['key'] as String),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFFF4458) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMap(AppLocalizations l10n) {
    final venues = _filteredVenues;

    // POI 标记
    final markers = venues.map((venue) {
      final venueLatLng = LatLng(venue.latitude, venue.longitude);
      final isSelected = venue.name == _selectedVenueName;
      return Marker(
        width: 60,
        height: 60,
        point: venueLatLng,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _selectVenue(venue, moveCamera: false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _markerIcon(venue.type),
                color: _markerColor(venue.type),
                size: isSelected ? 32 : 26,
              ),
              Icon(
                FontAwesomeIcons.locationDot,
                color: isSelected ? _markerColor(venue.type) : Colors.grey[700],
                size: isSelected ? 30 : 24,
              ),
            ],
          ),
        ),
      );
    }).toList();

    // 用户位置标记
    if (_userLocation != null) {
      markers.add(Marker(
        width: 40,
        height: 40,
        point: _userLocation!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(FontAwesomeIcons.locationCrosshairs, color: Colors.blue, size: 20),
          ),
        ),
      ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'df_admin_mobile',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _mapBadge(
              icon: FontAwesomeIcons.city,
              text: _currentCityName ?? widget.cityName ?? l10n.currentLocation,
            ),
          ),
          // 位置加载指示器
          if (_isLoadingLocation)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFFFF4458)),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.loading}...',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _isLoadingPoi
                ? _mapBadge(icon: FontAwesomeIcons.spinner, text: l10n.loading)
                : _mapBadge(icon: FontAwesomeIcons.layerGroup, text: '${venues.length} ${l10n.venues}'),
          ),
        ],
      ),
    );
  }

  Widget _mapBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList(AppLocalizations l10n) {
    final venues = _filteredVenues;
    final selectedName = _selectedVenueName;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${venues.length} ${l10n.venues}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (_isLoadingPoi) ...[
                  const SizedBox(width: 8),
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: venues.isEmpty
                ? Center(child: Text(_isLoadingPoi ? l10n.loading : l10n.noData))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: venues.length,
                    itemBuilder: (context, index) {
                      final venue = venues[index];
                      final isSelected = selectedName == venue.name;
                      return _venueCard(venue, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _venueCard(PoiResult venue, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectVenue(venue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4458).withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _markerColor(venue.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_markerIcon(venue.type), color: _markerColor(venue.type), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venue.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(venue.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (venue.rating != null) ...[
                        Icon(FontAwesomeIcons.star, size: 12, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(venue.rating!.toString(), style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        const SizedBox(width: 12),
                      ],
                      if (venue.formattedDistance.isNotEmpty)
                        Text(venue.formattedDistance, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _markerColor(venue.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(venue.typeName,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _markerColor(venue.type))),
            ),
          ],
        ),
      ),
    );
  }
}
