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
  // 高德地图瓦片 - 使用多个服务器提高加载速度
  static const _tileUrl =
      'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';
  static const _subdomains = ['1', '2', '3', '4'];

  // POI 数据
  Map<String, List<PoiResult>> _poiData = {};
  bool _isLoadingPoi = false;

  // 用户位置
  LatLng? _userLocation;
  // ignore: unused_field - 留待后续实现位置加载状态
  bool _isLoadingLocation = true;
  String? _currentCityName;

  final MapController _mapController = MapController();
  final ScrollController _listScrollController = ScrollController();
  late LatLng _initialCenter;
  String _selectedFilter = 'All';
  String? _selectedVenueName;

  // 是否只显示选中项（从地图点击触发）
  bool _showOnlySelected = false;

  // 地图是否已初始化（位置已获取）
  bool _isInitialized = false;

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

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
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
          // 即使获取失败也标记为已初始化，使用默认位置
          if (mounted) {
            setState(() {
              _isInitialized = true;
              _isLoadingLocation = false;
            });
          }
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
          _isInitialized = true;
        });
        // 加载周边 POI（不阻塞）
        _loadNearbyPoi(lat, lng);
      }
    } catch (e) {
      debugPrint('❌ 获取位置失败: $e');
      // 即使出错也标记为已初始化
      if (mounted) {
        setState(() => _isInitialized = true);
      }
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

  void _selectVenue(PoiResult venue, {bool moveCamera = true, bool fromMap = false}) {
    setState(() {
      _selectedVenueName = venue.name;
      // 从地图点击时，只显示选中项
      if (fromMap) {
        _showOnlySelected = true;
      }
    });
    if (moveCamera) {
      _mapController.move(LatLng(venue.latitude, venue.longitude), 15);
    }
  }

  /// 显示全部列表
  void _showAllVenues() {
    setState(() => _showOnlySelected = false);
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
    // 还未初始化时显示加载指示器
    if (!_isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.grey[200],
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
      );
    }

    final venues = _filteredVenues;

    // POI 标记
    final markers = venues.map((venue) {
      final venueLatLng = LatLng(venue.latitude, venue.longitude);
      final isSelected = venue.name == _selectedVenueName;
      return Marker(
        width: 50,
        height: 50,
        point: venueLatLng,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _selectVenue(venue, moveCamera: false, fromMap: true),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _markerIcon(venue.type),
                color: _markerColor(venue.type),
                size: isSelected ? 24 : 20,
              ),
              Icon(
                FontAwesomeIcons.locationDot,
                color: isSelected ? _markerColor(venue.type) : Colors.grey[700],
                size: isSelected ? 24 : 20,
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
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                subdomains: _subdomains,
                userAgentPackageName: 'df_admin_mobile',
                tileProvider: NetworkTileProvider(),
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
          // 缩放控制按钮
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                _zoomButton(
                  icon: FontAwesomeIcons.plus,
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom < 18) {
                      _mapController.move(_mapController.camera.center, currentZoom + 1);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _zoomButton(
                  icon: FontAwesomeIcons.minus,
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom > 3) {
                      _mapController.move(_mapController.camera.center, currentZoom - 1);
                    }
                  },
                ),
              ],
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

  /// 缩放按钮
  Widget _zoomButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 16, color: Colors.grey[700]),
        ),
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
    final allVenues = _filteredVenues;
    final selectedName = _selectedVenueName;

    // 获取选中的场地
    final selectedVenue = selectedName != null ? allVenues.firstWhereOrNull((v) => v.name == selectedName) : null;

    // 如果只显示选中项且有选中的场地
    final displayVenues = (_showOnlySelected && selectedVenue != null) ? [selectedVenue] : allVenues;

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
                if (_showOnlySelected && selectedVenue != null) ...[
                  // 显示"返回列表"按钮
                  GestureDetector(
                    onTap: _showAllVenues,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FontAwesomeIcons.chevronLeft, size: 12, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(
                            '${l10n.all} (${allVenues.length})',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    '${allVenues.length} ${l10n.venues}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
                if (_isLoadingPoi) ...[
                  const SizedBox(width: 8),
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: displayVenues.isEmpty
                ? Center(child: Text(_isLoadingPoi ? l10n.loading : l10n.noData))
                : ListView.builder(
                    controller: _listScrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: displayVenues.length,
                    itemBuilder: (context, index) {
                      final venue = displayVenues[index];
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4458).withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标 - 选中时添加边框
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? _markerColor(venue.type).withValues(alpha: 0.2)
                    : _markerColor(venue.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: _markerColor(venue.type), width: 2) : null,
              ),
              child: Icon(_markerIcon(venue.type), color: _markerColor(venue.type), size: 22),
            ),
            const SizedBox(width: 12),
            // 内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 第一行：名称 + 类型标签
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _markerColor(venue.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          venue.typeName,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _markerColor(venue.type)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 第二行：完整地址（最多2行）
                  Text(
                    venue.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 第三行：评分和距离
                  Row(
                    children: [
                      if (venue.rating != null) ...[
                        Icon(FontAwesomeIcons.solidStar, size: 11, color: Colors.amber[700]),
                        const SizedBox(width: 3),
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (venue.formattedDistance.isNotEmpty) ...[
                        Icon(FontAwesomeIcons.locationArrow, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          venue.formattedDistance,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
