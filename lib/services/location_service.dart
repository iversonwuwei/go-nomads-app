import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/widgets/app_toast.dart';

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
    if (!hasPermission.value) {
      final granted = await checkPermission();
      if (!granted) return null;
    }

    try {
      isLoading.value = true;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      currentPosition.value = position;
      isLoading.value = false;

      return position;
    } catch (e) {
      isLoading.value = false;
      AppToast.error(
        '无法获取您的位置信息: $e',
        title: '获取位置失败',
      );
      return null;
    }
  }

  /// 持续监听位置变化
  Stream<Position> watchPosition() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

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
