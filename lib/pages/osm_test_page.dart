import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// 简单的 OSM 地图测试页面
/// 用于测试 OpenStreetMap 瓦片是否能正常加载
class OSMTestPage extends StatelessWidget {
  const OSMTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OSM 地图测试'),
        backgroundColor: Colors.blue,
      ),
      body: FlutterMap(
        options: MapOptions(
          // 北京天安门坐标
          initialCenter: const LatLng(39.9042, 116.4074),
          initialZoom: 13.0,
          minZoom: 5.0,
          maxZoom: 18.0,
          backgroundColor: Colors.lightBlue[50]!,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.df_admin_mobile',
            // 添加一些基本配置
            maxZoom: 19,
            tileBuilder: (context, tileWidget, tile) {
              // 打印瓦片加载日志
              print('Loading tile at zoom ${tile.coordinates.z}: ${tile.coordinates.x}, ${tile.coordinates.y}');
              return tileWidget;
            },
            errorTileCallback: (tile, error, stackTrace) {
              // 打印错误信息
              print('Error loading tile: $error');
              print('StackTrace: $stackTrace');
            },
          ),
          // 添加一个中心标记
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(39.9042, 116.4074),
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Text(
                      '测试标记',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('如果能看到这个按钮，说明页面已加载。检查控制台查看地图瓦片加载日志。'),
              duration: Duration(seconds: 3),
            ),
          );
        },
        icon: const Icon(Icons.info),
        label: const Text('检查日志'),
      ),
    );
  }
}
