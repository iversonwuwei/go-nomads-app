import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

/// 高德地图服务 - 封装与原生层的通信
class AmapService {
  static const MethodChannel _channel = MethodChannel('com.gonomads.df_admin_mobile/amap');

  static AmapService? _instance;

  AmapService._();

  static AmapService get instance {
    _instance ??= AmapService._();
    return _instance!;
  }

  /// 测试 Platform Channel 连接
  Future<String> testConnection() async {
    try {
      final result = await _channel.invokeMethod<String>('test');
      return result ?? 'No response';
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  /// 打开原生地图选择器
  Future<Map<String, dynamic>?> openMapPicker({
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'openMapPicker',
        {
          'initialLatitude': initialLatitude,
          'initialLongitude': initialLongitude,
        },
      );
      return result?.cast<String, dynamic>();
    } on PlatformException catch (e) {
      log('❌ openMapPicker error: ${e.message}');
      return null;
    }
  }

  /// 获取当前位置
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getCurrentLocation');
      return result?.cast<String, dynamic>();
    } on PlatformException catch (e) {
      log('❌ getCurrentLocation error: ${e.message}');
      return null;
    }
  }

  /// 检查是否支持原生地图
  bool get isSupported => Platform.isIOS || Platform.isAndroid;
}
