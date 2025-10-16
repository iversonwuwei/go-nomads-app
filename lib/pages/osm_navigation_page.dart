import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../models/coworking_space_model.dart';
import '../widgets/app_toast.dart';

// 地图瓦片源枚举
enum MapTileSource {
  cartoDB,      // CartoDB (默认)
  openStreetMap, // OpenStreetMap 官方
  amap,         // 高德地图
  mapbox,       // Mapbox
}

// 地图瓦片配置
class MapTileConfig {
  final String name;
  final String urlTemplate;
  final List<String>? subdomains;
  final int maxZoom;
  final bool requiresApiKey;
  final String? description;

  const MapTileConfig({
    required this.name,
    required this.urlTemplate,
    this.subdomains,
    this.maxZoom = 19,
    this.requiresApiKey = false,
    this.description,
  });
}

/// OpenStreetMap 导航页面
/// 显示 Coworking Space 位置和周边设施（交通、住宿、餐饮）
class OSMNavigationPage extends StatefulWidget {
  final CoworkingSpace coworkingSpace;

  const OSMNavigationPage({
    super.key,
    required this.coworkingSpace,
  });

  @override
  State<OSMNavigationPage> createState() => _OSMNavigationPageState();
}

class _OSMNavigationPageState extends State<OSMNavigationPage> {
  final MapController _mapController = MapController();
  bool _showTransit = true;
  bool _showAccommodation = true;
  bool _showRestaurant = true;
  MapTileSource _currentTileSource = MapTileSource.cartoDB; // 当前地图源

  // 地图瓦片配置映射
  static const Map<MapTileSource, MapTileConfig> _tileConfigs = {
    // CartoDB - 清晰美观，免费无限制（推荐）
    MapTileSource.cartoDB: MapTileConfig(
      name: 'CartoDB',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
      maxZoom: 20,
      description: '清晰美观 • 免费 • 速度快',
    ),
    // OpenStreetMap 官方
    MapTileSource.openStreetMap: MapTileConfig(
      name: 'OpenStreetMap',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      maxZoom: 19,
      description: '官方源 • 开源',
    ),
    // 高德地图 - 国内速度快，中文地名
    MapTileSource.amap: MapTileConfig(
      name: '高德地图',
      urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
      subdomains: ['1', '2', '3', '4'],
      maxZoom: 18,
      description: '国内快 • 中文标注',
    ),
    // Mapbox - 需要 API Key（这里使用演示 token）
    MapTileSource.mapbox: MapTileConfig(
      name: 'Mapbox',
      urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw',
      maxZoom: 22,
      requiresApiKey: true,
      description: '高质量 • 需要 Token',
    ),
  };

  // 模拟周边设施数据（实际应该从 API 获取）
  List<POI> _nearbyPOIs = [];

  @override
  void initState() {
    super.initState();
    _loadNearbyPOIs();
  }

  void _loadNearbyPOIs() {
    // 模拟加载周边设施数据
    // 实际应该调用 Overpass API 或其他 POI 数据源
    final center = LatLng(
      widget.coworkingSpace.latitude,
      widget.coworkingSpace.longitude,
    );

    _nearbyPOIs = [
      // 交通设施（示例）
      POI(
        name: '地铁站',
        type: POIType.transit,
        position: LatLng(center.latitude + 0.002, center.longitude + 0.002),
        icon: Icons.subway,
      ),
      POI(
        name: '公交站',
        type: POIType.transit,
        position: LatLng(center.latitude - 0.001, center.longitude + 0.001),
        icon: Icons.directions_bus,
      ),
      // 住宿设施（示例）
      POI(
        name: '附近酒店',
        type: POIType.accommodation,
        position: LatLng(center.latitude + 0.003, center.longitude - 0.002),
        icon: Icons.hotel,
      ),
      POI(
        name: '青年旅舍',
        type: POIType.accommodation,
        position: LatLng(center.latitude - 0.002, center.longitude - 0.003),
        icon: Icons.bed,
      ),
      // 餐饮设施（示例）
      POI(
        name: '咖啡厅',
        type: POIType.restaurant,
        position: LatLng(center.latitude + 0.001, center.longitude - 0.001),
        icon: Icons.local_cafe,
      ),
      POI(
        name: '餐厅',
        type: POIType.restaurant,
        position: LatLng(center.latitude - 0.002, center.longitude + 0.002),
        icon: Icons.restaurant,
      ),
    ];
  }

  // 打开系统地图应用
  Future<void> _openSystemMap() async {
    final lat = widget.coworkingSpace.latitude;
    final lon = widget.coworkingSpace.longitude;
    final name = Uri.encodeComponent(widget.coworkingSpace.name);

    // 尝试多个地图应用
    final urls = [
      // Apple Maps (iOS)
      'http://maps.apple.com/?q=$name&ll=$lat,$lon',
      // Google Maps (通用)
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
      // 高德地图 (Android)
      'androidamap://viewMap?sourceApplication=appname&lat=$lat&lon=$lon&dev=0',
    ];

    final l10n = AppLocalizations.of(context)!;

    for (final urlString in urls) {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // 如果都无法打开，显示提示
    if (mounted) {
      AppToast.error(l10n.noMapAppAvailable);
    }
  }

  // 切换地图源
  void _changeTileSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择地图源',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...MapTileSource.values.map((source) {
              final config = _tileConfigs[source]!;
              final isSelected = _currentTileSource == source;
              
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFFFF4458) : Colors.grey,
                ),
                title: Text(
                  config.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: config.description != null
                    ? Text(
                        config.description!,
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                trailing: config.requiresApiKey
                    ? const Icon(Icons.vpn_key, size: 16, color: Colors.orange)
                    : null,
                onTap: () {
                  setState(() {
                    _currentTileSource = source;
                  });
                  Navigator.pop(context);
                  
                  // 显示提示
                  AppToast.success('已切换到 ${config.name}');
                },
              );
            }),
            const SizedBox(height: 8),
            if (_tileConfigs[_currentTileSource]!.requiresApiKey)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mapbox 需要 API Token。当前使用演示 Token，可能有使用限制。',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final center = LatLng(
      widget.coworkingSpace.latitude,
      widget.coworkingSpace.longitude,
    );

    return Scaffold(
      backgroundColor: Colors.grey[200], // 添加背景色
      body: Stack(
        children: [
          // 地图层
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              backgroundColor: Colors.grey[300]!, // 地图背景色
            ),
            children: [
              // OpenStreetMap 瓦片层 - 使用动态配置
              TileLayer(
                urlTemplate: _tileConfigs[_currentTileSource]!.urlTemplate,
                subdomains: _tileConfigs[_currentTileSource]!.subdomains ?? const [],
                userAgentPackageName: 'com.example.df_admin_mobile',
                maxZoom: _tileConfigs[_currentTileSource]!.maxZoom.toDouble(),
              ),
              // 标记层 - 周边设施
              MarkerLayer(
                markers: _buildPOIMarkers(),
              ),
              // 标记层 - Coworking Space（置于顶层）
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4458),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.work,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            widget.coworkingSpace.name,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 顶部工具栏
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
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // 返回按钮
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 标题
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.coworkingSpace.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.coworkingSpace.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 右侧筛选按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            right: 16,
            child: Column(
              children: [
                // 地图源切换按钮
                _buildFilterButton(
                  icon: Icons.layers,
                  label: _tileConfigs[_currentTileSource]!.name,
                  isActive: false,
                  onTap: _changeTileSource,
                ),
                const SizedBox(height: 12),
                _buildFilterButton(
                  icon: Icons.directions_transit,
                  label: l10n.transit,
                  isActive: _showTransit,
                  onTap: () {
                    setState(() {
                      _showTransit = !_showTransit;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterButton(
                  icon: Icons.hotel,
                  label: l10n.accommodation,
                  isActive: _showAccommodation,
                  onTap: () {
                    setState(() {
                      _showAccommodation = !_showAccommodation;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterButton(
                  icon: Icons.restaurant,
                  label: l10n.restaurant,
                  isActive: _showRestaurant,
                  onTap: () {
                    setState(() {
                      _showRestaurant = !_showRestaurant;
                    });
                  },
                ),
              ],
            ),
          ),

          // 底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 回到中心按钮
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _mapController.move(center, 15.0);
                      },
                      icon: const Icon(Icons.my_location),
                      label: Text(l10n.recenter),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: Color(0xFFFF4458),
                          width: 2,
                        ),
                        foregroundColor: const Color(0xFFFF4458),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 出发按钮
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _openSystemMap,
                      icon: const Icon(Icons.navigation),
                      label: Text(l10n.startNavigation),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFF4458),
                        foregroundColor: Colors.white,
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建筛选按钮
  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? const Color(0xFFFF4458) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建 POI 标记
  List<Marker> _buildPOIMarkers() {
    final markers = <Marker>[];

    for (final poi in _nearbyPOIs) {
      // 根据筛选条件决定是否显示
      if (!_shouldShowPOI(poi.type)) continue;

      markers.add(
        Marker(
          point: poi.position,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _showPOIInfo(poi);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _getPOIColor(poi.type),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                poi.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // 判断是否应该显示该类型的 POI
  bool _shouldShowPOI(POIType type) {
    switch (type) {
      case POIType.transit:
        return _showTransit;
      case POIType.accommodation:
        return _showAccommodation;
      case POIType.restaurant:
        return _showRestaurant;
    }
  }

  // 获取 POI 颜色
  Color _getPOIColor(POIType type) {
    switch (type) {
      case POIType.transit:
        return Colors.blue;
      case POIType.accommodation:
        return Colors.purple;
      case POIType.restaurant:
        return Colors.orange;
    }
  }

  // 显示 POI 信息
  void _showPOIInfo(POI poi) {
    final distance = _calculateDistance(
      LatLng(
        widget.coworkingSpace.latitude,
        widget.coworkingSpace.longitude,
      ),
      poi.position,
    );
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部图标和类型标签
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getPOIColor(poi.type),
                      _getPOIColor(poi.type).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        poi.icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getPOITypeName(poi.type),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            poi.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 信息内容
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 距离信息卡片
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getPOIColor(poi.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.near_me,
                              color: _getPOIColor(poi.type),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '距离 ${widget.coworkingSpace.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  distance,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 位置坐标信息
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.location_on_outlined,
                            label: '经度',
                            value: poi.position.longitude.toStringAsFixed(6),
                            color: _getPOIColor(poi.type),
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.location_on_outlined,
                            label: '纬度',
                            value: poi.position.latitude.toStringAsFixed(6),
                            color: _getPOIColor(poi.type),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 快捷提示
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '点击地图上的标记可以查看更多周边设施',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 底部操作按钮
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '关闭',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // 可以添加导航到这个POI的功能
                          _focusOnLocation(poi.position);
                        },
                        icon: const Icon(Icons.my_location, size: 20),
                        label: const Text(
                          '在地图上查看',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _getPOIColor(poi.type),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建信息行
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
  
  // 聚焦到指定位置
  void _focusOnLocation(LatLng position) {
    _mapController.move(position, 17.0);
  }

  // 获取 POI 类型名称
  String _getPOITypeName(POIType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case POIType.transit:
        return l10n.transit;
      case POIType.accommodation:
        return l10n.accommodation;
      case POIType.restaurant:
        return l10n.restaurant;
    }
  }

  // 计算距离（简化版，实际应使用 Haversine 公式）
  String _calculateDistance(LatLng from, LatLng to) {
    final distance = Distance();
    final meters = distance(from, to);
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}米';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}公里';
    }
  }
}

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
