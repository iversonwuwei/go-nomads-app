import 'dart:developer';
import 'dart:io';

import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// 位置服务类
/// 提供位置权限管理和位置获取功能
class LocationService extends GetxService {
  // 当前位置
  final Rx<Position?> currentPosition = Rx<Position?>(null);

  // 位置权限状态
  final RxBool hasPermission = false.obs;

  // 是否正在获取位置
  final RxBool isLoading = false.obs;

  /// 初始化位置服务
  Future<LocationService> init() async {
    await checkPermission();
    return this;
  }

  /// 检查位置权限
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppToast.warning(
        '请在设置中启用位置服务',
        title: '位置服务未启用',
      );
      hasPermission.value = false;
      return false;
    }

    // 检查位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppToast.warning(
          '请授予位置权限以使用此功能',
          title: '位置权限被拒绝',
        );
        hasPermission.value = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppToast.warning(
        '请在设置中手动开启位置权限',
        title: '位置权限被永久拒绝',
      );
      hasPermission.value = false;
      return false;
    }

    hasPermission.value = true;
    return true;
  }

  /// 获取当前位置
  Future<Position?> getCurrentLocation() async {
    log('🔍 LocationService: 开始检查权限...');
    if (!hasPermission.value) {
      final granted = await checkPermission();
      if (!granted) {
        log('❌ LocationService: 权限未授予');
        return null;
      }
    }
    log('✅ LocationService: 权限已授予');

    try {
      isLoading.value = true;

      // 策略1: 先尝试获取上次已知位置（最快，使用缓存）
      log('📍 LocationService: 尝试获取上次已知位置...');
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        log('✅ LocationService: 使用上次已知位置 (${lastKnown.latitude}, ${lastKnown.longitude})');
        currentPosition.value = lastKnown;
        isLoading.value = false;
        return lastKnown;
      }
      log('⚠️ LocationService: 没有上次已知位置');

      // 策略2: 使用低精度快速定位（网络定位，不需要GPS）
      log('📡 LocationService: 尝试网络定位（低精度）...');
      late LocationSettings lowAccuracySettings;
      if (Platform.isAndroid) {
        lowAccuracySettings = AndroidSettings(
          accuracy: LocationAccuracy.low, // 使用网络定位
          distanceFilter: 100,
          forceLocationManager: true,
          timeLimit: const Duration(seconds: 15),
        );
      } else {
        lowAccuracySettings = const LocationSettings(
          accuracy: LocationAccuracy.low,
          distanceFilter: 100,
          timeLimit: Duration(seconds: 15),
        );
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: lowAccuracySettings,
        );
        log('✅ LocationService: 网络定位成功 (${position.latitude}, ${position.longitude})');
        currentPosition.value = position;
        isLoading.value = false;
        return position;
      } catch (e) {
        log('⚠️ LocationService: 网络定位失败 - $e');
      }

      // 策略3: 最后尝试高精度GPS定位
      log('🛰️ LocationService: 尝试GPS定位（高精度）...');
      late LocationSettings highAccuracySettings;
      if (Platform.isAndroid) {
        highAccuracySettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          forceLocationManager: true,
          timeLimit: const Duration(seconds: 30),
        );
      } else {
        highAccuracySettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          timeLimit: Duration(seconds: 30),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: highAccuracySettings,
      );
      log('✅ LocationService: GPS定位成功 (${position.latitude}, ${position.longitude})');

      currentPosition.value = position;
      isLoading.value = false;

      return position;
    } catch (e) {
      log('❌ LocationService: 所有定位方式都失败 - $e');
      isLoading.value = false;
      AppToast.error(
        '无法获取您的位置信息，请检查GPS是否开启',
        title: '获取位置失败',
      );
      return null;
    }
  }

  /// 持续监听位置变化
  Stream<Position> watchPosition() {
    // Android 使用原生 LocationManager，不依赖 Google Play Services
    late LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 计算两个位置之间的距离(米)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// 计算两个位置之间的距离(公里)
  double calculateDistanceInKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return calculateDistance(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000;
  }

  /// 格式化距离显示
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 打开应用设置
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// 打开位置服务设置
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// 获取位置信息摘要
  String getLocationSummary() {
    if (currentPosition.value == null) {
      return '位置未知';
    }

    final pos = currentPosition.value!;
    return '纬度: ${pos.latitude.toStringAsFixed(6)}, 经度: ${pos.longitude.toStringAsFixed(6)}';
  }
}
