import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 高德定位结果
class AmapLocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String address;
  final String country;
  final String province;
  final String city;
  final String cityCode;
  final String district;
  final String adCode;
  final String street;
  final String streetNum;
  final String poiName;
  final String aoiName;
  final int locationType;
  final String description;
  final int errorCode;

  AmapLocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.address,
    required this.country,
    required this.province,
    required this.city,
    required this.cityCode,
    required this.district,
    required this.adCode,
    required this.street,
    required this.streetNum,
    required this.poiName,
    required this.aoiName,
    required this.locationType,
    required this.description,
    required this.errorCode,
  });

  factory AmapLocationResult.fromMap(Map<dynamic, dynamic> map) {
    return AmapLocationResult(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      country: map['country'] as String? ?? '',
      province: map['province'] as String? ?? '',
      city: map['city'] as String? ?? '',
      cityCode: map['cityCode'] as String? ?? '',
      district: map['district'] as String? ?? '',
      adCode: map['adCode'] as String? ?? '',
      street: map['street'] as String? ?? '',
      streetNum: map['streetNum'] as String? ?? '',
      poiName: map['poiName'] as String? ?? '',
      aoiName: map['aoiName'] as String? ?? '',
      locationType: map['locationType'] as int? ?? 0,
      description: map['description'] as String? ?? '',
      errorCode: map['errorCode'] as int? ?? -1,
    );
  }

  /// 获取简短地址（用于显示）
  String get shortAddress {
    // 优先使用 POI 名称
    if (poiName.isNotEmpty) {
      return city.isNotEmpty ? '$poiName, $city' : poiName;
    }
    // 使用 AOI 名称（区域兴趣点）
    if (aoiName.isNotEmpty) {
      return city.isNotEmpty ? '$aoiName, $city' : aoiName;
    }
    // 使用街道信息
    if (street.isNotEmpty) {
      final streetInfo = streetNum.isNotEmpty ? '$street$streetNum' : street;
      if (district.isNotEmpty) {
        return '$district $streetInfo';
      }
      return city.isNotEmpty ? '$streetInfo, $city' : streetInfo;
    }
    // 使用区县+城市
    if (district.isNotEmpty && city.isNotEmpty) {
      return '$city$district';
    }
    if (district.isNotEmpty) {
      return district;
    }
    // 使用城市
    if (city.isNotEmpty) {
      return province.isNotEmpty && province != city ? '$province$city' : city;
    }
    // 使用省份
    if (province.isNotEmpty) {
      return province;
    }
    // 使用完整地址
    if (address.isNotEmpty) {
      return address;
    }
    // 使用描述
    if (description.isNotEmpty) {
      return description;
    }
    // 返回坐标（作为最后的回退）
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  /// 检查是否有有效的地址信息（非坐标）
  bool get hasValidAddress {
    return poiName.isNotEmpty ||
        aoiName.isNotEmpty ||
        street.isNotEmpty ||
        district.isNotEmpty ||
        city.isNotEmpty ||
        province.isNotEmpty ||
        address.isNotEmpty ||
        description.isNotEmpty;
  }

  /// 获取定位类型描述
  String get locationTypeDescription {
    switch (locationType) {
      case 1:
        return 'GPS定位';
      case 2:
        return '前次定位缓存';
      case 4:
        return '缓存定位结果';
      case 5:
        return 'Wifi定位';
      case 6:
        return '基站定位';
      case 8:
        return '离线定位';
      case 9:
        return '最后位置缓存';
      default:
        return '未知';
    }
  }

  @override
  String toString() {
    return 'AmapLocationResult(lat: $latitude, lng: $longitude, address: $shortAddress, type: $locationTypeDescription)';
  }
}

/// 高德原生定位服务
/// 通过 MethodChannel 调用 Android/iOS 原生高德 SDK
class AmapNativeLocationService extends GetxService {
  static const _channel = MethodChannel('com.gonomads.df_admin_mobile/amap_location');

  // 状态
  final Rx<AmapLocationResult?> currentLocation = Rx<AmapLocationResult?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final RxString errorMessage = ''.obs;

  /// 初始化服务
  Future<AmapNativeLocationService> init() async {
    log('🗺️ AmapNativeLocationService: 初始化...');
    await checkPermission();
    return this;
  }

  /// 检查定位权限
  Future<bool> checkPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      log('⚠️ AmapNativeLocationService: 不支持的平台');
      hasPermission.value = false;
      return false;
    }

    try {
      final result = await _channel.invokeMethod('checkPermission');
      hasPermission.value = result['hasPermission'] as bool? ?? false;
      log('📍 AmapNativeLocationService: 权限状态 = ${hasPermission.value}');
      return hasPermission.value;
    } on PlatformException catch (e) {
      log('❌ AmapNativeLocationService: 检查权限失败 - ${e.message}');
      hasPermission.value = false;
      return false;
    }
  }

  /// 获取当前位置（单次定位）
  /// 使用高德原生 SDK 获取精准位置
  Future<AmapLocationResult?> getCurrentLocation() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      errorMessage.value = '不支持的平台';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      log('📍 AmapNativeLocationService: 开始定位...');

      final result = await _channel
          .invokeMethod('getCurrentLocation')
          .timeout(const Duration(seconds: 30));

      if (result == null) {
        errorMessage.value = '定位返回空结果';
        return null;
      }

      final location = AmapLocationResult.fromMap(result as Map);

      if (location.errorCode != 0) {
        errorMessage.value = '定位失败 (${location.errorCode})';
        return null;
      }

      currentLocation.value = location;
      log('✅ AmapNativeLocationService: 定位成功 - ${location.shortAddress}');
      log('   定位类型: ${location.locationTypeDescription}');
      log('   精度: ${location.accuracy}m');

      return location;
    } on PlatformException catch (e) {
      log('❌ AmapNativeLocationService: 定位失败 - ${e.code}: ${e.message}');
      errorMessage.value = e.message ?? '定位失败';
      return null;
    } on TimeoutException {
      log('⏱️ AmapNativeLocationService: 定位超时');
      errorMessage.value = '定位超时';
      return null;
    } catch (e) {
      log('❌ AmapNativeLocationService: 未知错误 - $e');
      errorMessage.value = '定位异常: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 开始连续定位
  Future<bool> startContinuousLocation() async {
    try {
      final result = await _channel.invokeMethod('startContinuousLocation');
      return result['success'] as bool? ?? false;
    } on PlatformException catch (e) {
      log('❌ AmapNativeLocationService: 启动连续定位失败 - ${e.message}');
      return false;
    }
  }

  /// 停止连续定位
  Future<bool> stopContinuousLocation() async {
    try {
      final result = await _channel.invokeMethod('stopContinuousLocation');
      return result['success'] as bool? ?? false;
    } on PlatformException catch (e) {
      log('❌ AmapNativeLocationService: 停止连续定位失败 - ${e.message}');
      return false;
    }
  }
}
