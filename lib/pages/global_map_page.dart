import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// 使用 flutter_map 显示基础全球地图页面
class GlobalMapPage extends StatefulWidget {
  const GlobalMapPage({super.key});

  @override
  State<GlobalMapPage> createState() => _GlobalMapPageState();
}

class _GlobalMapPageState extends State<GlobalMapPage> {
  final MapController _mapController = MapController();
  bool _isLoading = true;
  String? _errorMessage;

  // 可用的瓦片源配置（优先国内可访问源）
  final Map<String, Map<String, String>> _tileSources = {
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

  String _selectedTileSource = 'gaode-road'; // 默认使用高德标准（国内可访问）

  @override
  void initState() {
    super.initState();
    // 模拟加载完成
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _showTileSourceSelector() {
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
              ..._tileSources.entries.map((entry) {
                final isSelected = _selectedTileSource == entry.key;
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
                    setState(() {
                      _selectedTileSource = entry.key;
                    });
                    Navigator.pop(context);
                  },
                );
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
            onPressed: _showTileSourceSelector,
            tooltip: '切换地图样式',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地图主体
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(30.0, 105.0), // 默认中国中心
              initialZoom: 4,
              minZoom: 2,
              maxZoom: 18,
              onMapReady: () {
                debugPrint('🗺️ 地图加载完成');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _tileSources[_selectedTileSource]!['url']!,
                userAgentPackageName: 'com.digitalfuture.df_admin_mobile',
                maxZoom: 18,
                minZoom: 2,
              ),
            ],
          ),

          // 加载指示器
          if (_isLoading)
            Container(
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
            ),

          // 错误提示
          if (_errorMessage != null)
            Container(
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
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isLoading = true;
                        });
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),

          // 缩放控制按钮
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildZoomButton(
                  icon: Icons.remove,
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                ),
              ],
            ),
          ),

          // 当前地图样式标签
          Positioned(
            left: 16,
            bottom: 32,
            child: Container(
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
                    _tileSources[_selectedTileSource]!['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
