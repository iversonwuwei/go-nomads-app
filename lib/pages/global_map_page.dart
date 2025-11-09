import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/city/presentation/controllers/city_state_controller.dart';
import '../generated/app_localizations.dart';
import 'city_detail_page.dart';

/// 全球城市地图页面 - 显示所有城市位置和会员数量
class GlobalMapPage extends StatefulWidget {
  const GlobalMapPage({super.key});

  @override
  State<GlobalMapPage> createState() => _GlobalMapPageState();
}

class _GlobalMapPageState extends State<GlobalMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // 使用 DDD 的 CityStateController（延迟初始化）
  CityStateController? _cityControllerCache;
  CityStateController get _cityController {
    _cityControllerCache ??= Get.find<CityStateController>();
    return _cityControllerCache!;
  }

  // 搜索状态
  String _searchQuery = '';
  bool _isSearching = false;

  // 根据搜索查询筛选城市
  List<dynamic> get _filteredCities {
    if (_searchQuery.isEmpty) {
      return _cityController.cities.toList();
    }
    return _cityController.cities.where((city) {
      final cityName = city.name.toLowerCase();
      final countryName = city.country ?? ''.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return cityName.contains(searchLower) ||
          countryName.contains(searchLower);
    }).toList();
  }

  // 瓦片源选择
  String _selectedTileSource = 'amap-road'; // 默认使用高德标准地图

  // 可用的瓦片源配置
  final Map<String, Map<String, String>> _tileSources = {
    'amap-road': {
      'name': '高德标准地图',
      'url':
          'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
    },
    'amap-satellite': {
      'name': '高德卫星图',
      'url':
          'https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}',
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
      'url':
          'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
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

  @override
  void initState() {
    super.initState();
    // 城市数据由 CityStateController 管理
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 搜索城市
  void _searchCities(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  // 移动到城市位置
  void _moveToCity(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 10.0);
  }

  // 获取城市坐标（示例数据，实际应从数据库获取）
  LatLng _getCityCoordinates(String cityName) {
    // 这里应该从数据库获取真实坐标
    // 临时使用城市名称映射到坐标
    final Map<String, LatLng> cityCoords = {
      'Bangkok': LatLng(13.7563, 100.5018),
      'Chiang Mai': LatLng(18.7883, 98.9853),
      'Bali': LatLng(-8.3405, 115.0920),
      'Tokyo': LatLng(35.6762, 139.6503),
      'Seoul': LatLng(37.5665, 126.9780),
      'Singapore': LatLng(1.3521, 103.8198),
      'Ho Chi Minh': LatLng(10.8231, 106.6297),
      'Manila': LatLng(14.5995, 120.9842),
      'Kuala Lumpur': LatLng(3.1390, 101.6869),
      'Jakarta': LatLng(-6.2088, 106.8456),
      'Taipei': LatLng(25.0330, 121.5654),
      'Hong Kong': LatLng(22.3193, 114.1694),
      'Hanoi': LatLng(21.0285, 105.8542),
      'Phuket': LatLng(7.8804, 98.3923),
      'Da Nang': LatLng(16.0544, 108.2022),
      'Penang': LatLng(5.4164, 100.3327),
    };

    return cityCoords[cityName] ?? LatLng(0, 0);
  }

  // 获取会员数量(示例数据,实际应从数据库统计)
  int _getMemberCount(String cityName) {
    // 这里应该从数据库查询该城市的会员数量
    // 临时返回随机数量
    return (cityName.hashCode % 500) + 50;
  }

  // 显示瓦片源选择器
  void _showTileSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.layerGroup,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '选择地图瓦片源',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 可滚动的瓦片源列表
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: _tileSources.entries.map((entry) {
                        final isSelected = _selectedTileSource == entry.key;
                        return ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.map,
                            color: isSelected
                                ? const Color(0xFF1976D2)
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                          title: Text(
                            entry.value['name']!,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                                  isSelected ? const Color(0xFF1976D2) : null,
                            ),
                          ),
                          trailing: isSelected
                              ? const FaIcon(
                                  FontAwesomeIcons.circleCheck,
                                  color: Color(0xFF1976D2),
                                  size: 20,
                                )
                              : null,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedTileSource = entry.key;
                            });
                            Navigator.pop(context);
                            // 显示切换提示
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已切换到 ${entry.value['name']}'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // 地图主体
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(20, 100), // 亚洲中心
              initialZoom: 3.5,
              minZoom: 2.0,
              maxZoom: 16.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // 地图瓦片层
              TileLayer(
                urlTemplate: _tileSources[_selectedTileSource]!['url']!,
                userAgentPackageName: 'com.digitalfuture.df_admin_mobile',
                maxZoom: 18,
                minZoom: 2,
                // 禁用缓存以确保加载最新瓦片
                tileProvider: NetworkTileProvider(),
              ),

              // 城市标记层
              MarkerLayer(
                markers: _filteredCities.map((city) {
                  final coords = _getCityCoordinates(city.name);
                  final memberCount = _getMemberCount(city.name);

                  return Marker(
                    point: coords,
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        // 显示城市信息和导航选项
                        _showCityInfoSheet(
                          context,
                          city.name,
                          city.country ?? '' ?? '',
                          coords,
                          memberCount,
                          city,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 会员数量气泡
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4458),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$memberCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 位置图标
                          const FaIcon(
                            FontAwesomeIcons.locationDot,
                            color: Color(0xFFFF4458),
                            size: 28,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 顶部栏（返回按钮 + 搜索栏）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // 返回按钮
                  Container(
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
                    child: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
                      onPressed: () => Navigator.pop(context),
                      color: const Color(0xFFFF4458),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 搜索栏
                  Expanded(
                    child: Container(
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
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchCities,
                        decoration: InputDecoration(
                          hintText: l10n.searchCities,
                          prefixIcon: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: Color(0xFFFF4458),
                            size: 18,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.xmark,
                                      size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchCities('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 搜索结果列表（当正在搜索时显示）
          if (_isSearching && _filteredCities.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
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
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = _filteredCities[index];
                    final memberCount = _getMemberCount(city.name);

                    return ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.city,
                        color: Color(0xFFFF4458),
                        size: 20,
                      ),
                      title: Text(city.name),
                      subtitle: Text(city.country ?? ''),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$memberCount ${l10n.members}',
                          style: const TextStyle(
                            color: Color(0xFFFF4458),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        final coords = _getCityCoordinates(city.name);
                        _moveToCity(coords.latitude, coords.longitude);
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    );
                  },
                ),
              ),
            ),

          // 底部瓦片源选择器
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _showTileSourceSelector,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.layerGroup,
                          color: Color(0xFF1976D2),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _tileSources[_selectedTileSource]!['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 底部图例说明
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
                  const FaIcon(
                    FontAwesomeIcons.locationDot,
                    color: Color(0xFFFF4458),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredCities.length} ${l10n.cities}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 缩放按钮
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                // Zoom In 按钮
                Container(
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          currentZoom + 1,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: FaIcon(
                          FontAwesomeIcons.plus,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom Out 按钮
                Container(
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          currentZoom - 1,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: FaIcon(
                          FontAwesomeIcons.minus,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                      ),
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

  /// 显示城市信息和导航选项
  void _showCityInfoSheet(
    BuildContext context,
    String cityName,
    String country,
    LatLng coords,
    int memberCount,
    Map<String, dynamic> cityData,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市信息
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: Color(0xFFFF4458),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        country,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$memberCount ${l10n.members}',
                    style: const TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 操作按钮
            Row(
              children: [
                // 查看详情按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final cityId = cityData['id']?.toString();

                      // 验证 cityId 是否有效
                      if (cityId == null || cityId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('无法获取城市ID,请稍后重试'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CityDetailPage(
                            cityId: cityId,
                            cityName: cityName,
                            cityImage: cityData['image'],
                            overallScore:
                                (cityData['overall'] as num?)?.toDouble() ??
                                    0.0,
                            reviewCount: cityData['reviews'] ?? 0,
                          ),
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 18),
                    label: Text(l10n.viewDetails),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFFF4458)),
                      foregroundColor: const Color(0xFFFF4458),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 开始导航按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMapSelectionSheet(context, cityName, coords);
                    },
                    icon: const FaIcon(FontAwesomeIcons.diamondTurnRight,
                        size: 18),
                    label: Text(l10n.directions),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFF4458),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 显示地图选择器
  void _showMapSelectionSheet(
      BuildContext context, String locationName, LatLng coords) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 可滚动的地图列表区域
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // 标题
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.map,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          '选择导航应用',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  // 谷歌地图
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const FaIcon(FontAwesomeIcons.map,
                          color: Colors.blue, size: 20),
                    ),
                    title: const Text('谷歌地图'),
                    subtitle: const Text('Google Maps'),
                    trailing:
                        const FaIcon(FontAwesomeIcons.arrowRight, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _openGoogleMaps(locationName, coords);
                    },
                  ),
                  // 高德地图
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const FaIcon(FontAwesomeIcons.locationDot,
                          color: Colors.green, size: 20),
                    ),
                    title: const Text('高德地图'),
                    subtitle: const Text('Amap'),
                    trailing:
                        const FaIcon(FontAwesomeIcons.arrowRight, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _openAmap(locationName, coords);
                    },
                  ),
                  // 百度地图
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const FaIcon(FontAwesomeIcons.mapLocationDot,
                          color: Colors.orange, size: 20),
                    ),
                    title: const Text('百度地图'),
                    subtitle: const Text('Baidu Maps'),
                    trailing:
                        const FaIcon(FontAwesomeIcons.arrowRight, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _openBaiduMaps(locationName, coords);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // 固定在底部的取消按钮
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('取消'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 打开谷歌地图
  Future<void> _openGoogleMaps(String locationName, LatLng coords) async {
    final lat = coords.latitude;
    final lng = coords.longitude;
    final name = Uri.encodeComponent(locationName);

    // 尝试使用 Google Maps App URL Scheme
    final appUrl =
        Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving');
    // Web 版本作为备选
    final webUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name');

    try {
      // 直接尝试打开 App，不检查 canLaunchUrl
      final launched = await launchUrl(
        appUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // 如果 App 未能打开，使用浏览器打开 Web 版本
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // 打开 App 失败，尝试使用 Web 版本
      debugPrint('打开谷歌地图 App 失败: $e，尝试打开网页版');
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (webError) {
        debugPrint('打开谷歌地图网页版也失败: $webError');
      }
    }
  }

  /// 打开高德地图
  Future<void> _openAmap(String locationName, LatLng coords) async {
    final lat = coords.latitude;
    final lng = coords.longitude;
    final name = Uri.encodeComponent(locationName);

    // 高德地图 URL Scheme (根据平台使用不同的 scheme)
    Uri appUrl;
    if (Platform.isIOS) {
      appUrl = Uri.parse(
          'iosamap://navi?sourceApplication=applicationName&poiname=$name&lat=$lat&lon=$lng&dev=0&style=2');
    } else {
      appUrl = Uri.parse(
          'androidamap://navi?sourceApplication=applicationName&poiname=$name&lat=$lat&lon=$lng&dev=0&style=2');
    }

    // Web 版本作为备选
    final webUrl = Uri.parse(
        'https://uri.amap.com/navigation?to=$lng,$lat,$name&mode=car&coordinate=gaode');

    try {
      // 直接尝试打开 App，不检查 canLaunchUrl
      final launched = await launchUrl(
        appUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // 如果 App 未能打开，使用浏览器打开 Web 版本
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // 打开 App 失败，尝试使用 Web 版本
      debugPrint('打开高德地图 App 失败: $e，尝试打开网页版');
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (webError) {
        debugPrint('打开高德地图网页版也失败: $webError');
      }
    }
  }

  /// 打开百度地图
  Future<void> _openBaiduMaps(String locationName, LatLng coords) async {
    final lat = coords.latitude;
    final lng = coords.longitude;
    final name = Uri.encodeComponent(locationName);

    // 百度地图 URL Scheme
    final appUrl = Uri.parse(
        'baidumap://map/direction?destination=name:$name|latlng:$lat,$lng&mode=driving&coord_type=gcj02');
    // Web 版本作为备选
    final webUrl = Uri.parse(
        'https://api.map.baidu.com/direction?destination=name:$name|latlng:$lat,$lng&mode=driving&coord_type=gcj02&output=html');

    try {
      // 直接尝试打开 App，不检查 canLaunchUrl
      final launched = await launchUrl(
        appUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // 如果 App 未能打开，使用浏览器打开 Web 版本
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // 打开 App 失败，尝试使用 Web 版本
      debugPrint('打开百度地图 App 失败: $e，尝试打开网页版');
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (webError) {
        debugPrint('打开百度地图网页版也失败: $webError');
      }
    }
  }
}
