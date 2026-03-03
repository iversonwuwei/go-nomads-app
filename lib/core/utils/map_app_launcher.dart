import 'dart:io';

import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 地图应用类型
enum MapAppType {
  amap, // 高德地图
  baidu, // 百度地图
  tencent, // 腾讯地图
  apple, // 苹果地图
  google, // Google地图
}

/// 地图应用信息
class MapAppInfo {
  final MapAppType type;
  final String name;
  final IconData icon;
  final bool isAvailable;

  const MapAppInfo({
    required this.type,
    required this.name,
    required this.icon,
    this.isAvailable = true,
  });
}

/// 地图应用启动器
class MapAppLauncher {
  /// 获取可用的地图应用列表
  static List<MapAppInfo> getAvailableMapApps() {
    final List<MapAppInfo> apps = [
      const MapAppInfo(
        type: MapAppType.amap,
        name: '高德地图',
        icon: FontAwesomeIcons.mapLocationDot,
      ),
      const MapAppInfo(
        type: MapAppType.baidu,
        name: '百度地图',
        icon: FontAwesomeIcons.mapPin,
      ),
      const MapAppInfo(
        type: MapAppType.tencent,
        name: '腾讯地图',
        icon: FontAwesomeIcons.locationDot,
      ),
    ];

    // iOS 添加苹果地图
    if (Platform.isIOS) {
      apps.add(const MapAppInfo(
        type: MapAppType.apple,
        name: '苹果地图',
        icon: FontAwesomeIcons.apple,
      ));
    }

    // 添加 Google 地图
    apps.add(const MapAppInfo(
      type: MapAppType.google,
      name: 'Google地图',
      icon: FontAwesomeIcons.google,
    ));

    return apps;
  }

  /// 打开地图导航
  static Future<bool> openNavigation({
    required MapAppType mapType,
    required double latitude,
    required double longitude,
    required String destinationName,
  }) async {
    String url;
    final encodedName = Uri.encodeComponent(destinationName);

    switch (mapType) {
      case MapAppType.amap:
        // 高德地图
        url = 'androidamap://navi?sourceApplication=df_admin&lat=$latitude&lon=$longitude&dev=0&style=2';
        if (Platform.isIOS) {
          url = 'iosamap://navi?sourceApplication=df_admin&lat=$latitude&lon=$longitude&dev=0&style=2';
        }
        break;

      case MapAppType.baidu:
        // 百度地图
        url =
            'baidumap://map/direction?destination=latlng:$latitude,$longitude|name:$encodedName&coord_type=gcj02&mode=driving';
        break;

      case MapAppType.tencent:
        // 腾讯地图
        url = 'qqmap://map/routeplan?type=drive&to=$encodedName&tocoord=$latitude,$longitude&referer=df_admin';
        break;

      case MapAppType.apple:
        // 苹果地图
        url = 'http://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d';
        break;

      case MapAppType.google:
        // Google地图
        url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
        break;
    }

    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // 如果无法打开应用，尝试网页版
        return await _openWebFallback(mapType, latitude, longitude, destinationName);
      }
    } catch (e) {
      return await _openWebFallback(mapType, latitude, longitude, destinationName);
    }
  }

  /// 网页版回退
  static Future<bool> _openWebFallback(
    MapAppType mapType,
    double latitude,
    double longitude,
    String destinationName,
  ) async {
    String webUrl;
    final encodedName = Uri.encodeComponent(destinationName);

    switch (mapType) {
      case MapAppType.amap:
        webUrl = 'https://uri.amap.com/navigation?to=$longitude,$latitude,$encodedName&mode=car&src=df_admin';
        break;
      case MapAppType.baidu:
        webUrl =
            'https://api.map.baidu.com/direction?destination=latlng:$latitude,$longitude|name:$encodedName&coord_type=gcj02&mode=driving&output=html';
        break;
      case MapAppType.tencent:
        webUrl =
            'https://apis.map.qq.com/uri/v1/routeplan?type=drive&to=$encodedName&tocoord=$latitude,$longitude&referer=df_admin';
        break;
      case MapAppType.apple:
      case MapAppType.google:
        webUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
        break;
    }

    final uri = Uri.parse(webUrl);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }

  /// 显示地图选择对话框
  static Future<void> showMapSelectionDialog({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String destinationName,
  }) async {
    final apps = getAvailableMapApps();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // 标题
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  '选择地图应用',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Divider(height: 1),
              // 地图应用列表 - 使用 Flexible 包裹 ListView 确保可滚动
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...apps.map((app) => ListTile(
                          leading: FaIcon(app.icon, size: 24.r, color: Theme.of(context).primaryColor),
                          title: Text(app.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            Navigator.pop(context);
                            final success = await openNavigation(
                              mapType: app.type,
                              latitude: latitude,
                              longitude: longitude,
                              destinationName: destinationName,
                            );
                            if (!success && context.mounted) {
                              AppToast.error('无法打开${app.name}');
                            }
                          },
                        )),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // 取消按钮
              ListTile(
                title: Center(
                  child: Text(
                    '取消',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
