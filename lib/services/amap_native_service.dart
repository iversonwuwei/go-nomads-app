import 'dart:async';

import 'package:flutter/services.dart';

import '../config/amap_native_config.dart';

/// 高德地图原生服务
/// 通过 Platform Channel 与 iOS 原生代码通信
class AmapNativeService {
  // 私有构造函数
  AmapNativeService._();

  // 单例
  static final AmapNativeService instance = AmapNativeService._();

  // Platform Channel
  static const MethodChannel _channel = MethodChannel(AmapNativeConfig.channelName);

  /// 打开地图选择器
  /// 
  /// 返回值:
  /// {
  ///   'latitude': double,
  ///   'longitude': double,
  ///   'address': String,
  ///   'city': String?,
  ///   'province': String?
  /// }
  Future<Map<String, dynamic>?> openMapPicker({
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    try {
      final Map<String, dynamic> arguments = {};
      
      if (initialLatitude != null && initialLongitude != null) {
        arguments['initialLatitude'] = initialLatitude;
        arguments['initialLongitude'] = initialLongitude;
      }

      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        AmapNativeConfig.methodOpenMapPicker,
        arguments.isEmpty ? null : arguments,
      );

      if (result == null) {
        print('⚠️ 地图选择器返回 null');
        return null;
      }

      // 转换类型
      return {
        'latitude': result['latitude'] as double,
        'longitude': result['longitude'] as double,
        'address': result['address'] as String? ?? '',
        'city': result['city'] as String?,
        'province': result['province'] as String?,
      };
    } on PlatformException catch (e) {
      print('❌ 打开地图选择器失败: ${e.message}');
      print('   Code: ${e.code}');
      print('   Details: ${e.details}');
      return null;
    } catch (e) {
      print('❌ 未知错误: $e');
      return null;
    }
  }

  /// 获取当前位置
  /// 
  /// 返回值:
  /// {
  ///   'latitude': double,
  ///   'longitude': double,
  ///   'address': String?,
  /// }
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        AmapNativeConfig.methodGetCurrentLocation,
      );

      if (result == null) {
        print('⚠️ 获取当前位置返回 null');
        return null;
      }

      return {
        'latitude': result['latitude'] as double,
        'longitude': result['longitude'] as double,
        'address': result['address'] as String?,
      };
    } on PlatformException catch (e) {
      print('❌ 获取当前位置失败: ${e.message}');
      return null;
    } catch (e) {
      print('❌ 未知错误: $e');
      return null;
    }
  }

  /// 测试 Platform Channel 连接
  Future<bool> testConnection() async {
    try {
      final result = await _channel.invokeMethod<String>('test');
      print('✅ Platform Channel 连接成功: $result');
      return true;
    } catch (e) {
      print('❌ Platform Channel 连接失败: $e');
      return false;
    }
  }
}
