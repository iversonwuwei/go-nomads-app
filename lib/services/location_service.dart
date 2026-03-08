import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/permission_purpose_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 位置服务类
/// 提供位置权限管理和位置获取功能
class LocationService extends GetxService {
  // 当前位置
  final Rx<Position?> currentPosition = Rx<Position?>(null);

  // 位置权限状态
  final RxBool hasPermission = false.obs;

  // 是否正在获取位置
  final RxBool isLoading = false.obs;

  /// 是否已向用户展示过位置权限用途说明
  static const String _locationPurposeShownKey = 'location_permission_purpose_shown';

  /// 初始化位置服务
  /// 初始化时仅检查当前权限状态，不主动请求权限
  Future<LocationService> init() async {
    await _checkCurrentPermissionStatus();
    return this;
  }

  /// 仅检查当前权限状态，不触发权限请求
  Future<void> _checkCurrentPermissionStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        hasPermission.value = false;
        return;
      }

      final permission = await Geolocator.checkPermission();
      hasPermission.value = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      log('⚠️ LocationService: 检查权限状态异常 - $e');
      hasPermission.value = false;
    }
  }

  /// 检查并请求位置权限
  ///
  /// 隐私合规要求：在请求系统权限之前，先通过显著方式告知用户
  /// 申请该权限的目的（城市推荐、附近活动、共享办公空间、地图导航等）。
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

    // 如果权限已被授予，直接返回
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      hasPermission.value = true;
      return true;
    }

    // 如果权限被永久拒绝，提示用户手动开启
    if (permission == LocationPermission.deniedForever) {
      AppToast.warning(
        '请在设置中手动开启位置权限',
        title: '位置权限被永久拒绝',
      );
      hasPermission.value = false;
      return false;
    }

    // 权限未授予（denied 状态）：先展示用途说明，再请求系统权限
    await _showPurposeDialogIfNeeded();

    // 展示用途说明后，发起系统权限请求
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      AppToast.warning(
        '请授予位置权限以使用此功能',
        title: '位置权限被拒绝',
      );
      hasPermission.value = false;
      return false;
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

  /// 在请求系统权限前，展示权限用途说明对话框
  ///
  /// 向用户说明为什么需要此权限（Apple Review Guideline 5.1.1 合规）。
  /// 对话框只有"继续"按钮，阅读后直接进入系统权限弹窗。
  Future<void> _showPurposeDialogIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShownBefore = prefs.getBool(_locationPurposeShownKey) ?? false;

      if (hasShownBefore) {
        log('📋 再次展示位置权限用途说明');
      }

      await PermissionPurposeDialog.showLocationPermissionPurpose();

      // 记录已展示过
      await prefs.setBool(_locationPurposeShownKey, true);
    } catch (e) {
      log('⚠️ 展示权限用途说明对话框失败: $e');
      // 如果对话框展示失败，仍然允许继续请求权限
    }
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
