import 'dart:developer';

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:go_nomads_app/services/location_service.dart';

/// 位置控制器
/// 用于在页面中管理位置相关的状态和逻辑
class LocationController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  // 当前位置
  Rx<Position?> get currentPosition => _locationService.currentPosition;
  
  // 是否有权限
  RxBool get hasPermission => _locationService.hasPermission;
  
  // 是否正在加载
  RxBool get isLoading => _locationService.isLoading;

  // 城市名称(需要反向地理编码,这里先用模拟数据)
  final RxString currentCity = '未知城市'.obs;
  
  // 国家名称
  final RxString currentCountry = '未知国家'.obs;

  // 定时器
  Timer? _locationTimer;
  
  // 是否正在自动更新
  final RxBool isAutoUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 页面初始化时获取位置
    getCurrentLocation();
  }

  @override
  void onClose() {
    // 页面关闭时停止定时器
    stopAutoUpdate();
    super.onClose();
  }

  /// 获取当前位置
  Future<void> getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      // 这里可以调用反向地理编码API获取城市名称
      // 暂时使用模拟数据
      await _getCityFromCoordinates(position.latitude, position.longitude);
    }
  }

  /// 刷新位置
  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  /// 从坐标获取城市信息(模拟实现,实际需要调用地理编码API)
  Future<void> _getCityFromCoordinates(double latitude, double longitude) async {
    // TODO: 集成真实的反向地理编码API
    // 这里使用模拟数据
    
    // 示例:根据经纬度大致判断区域
    if (latitude >= 39.0 && latitude <= 41.0 && longitude >= 115.0 && longitude <= 117.5) {
      currentCity.value = 'Beijing';
      currentCountry.value = 'China';
    } else if (latitude >= 31.0 && latitude <= 31.5 && longitude >= 121.0 && longitude <= 122.0) {
      currentCity.value = 'Shanghai';
      currentCountry.value = 'China';
    } else if (latitude >= 22.0 && latitude <= 23.0 && longitude >= 113.0 && longitude <= 114.5) {
      currentCity.value = 'Guangzhou';
      currentCountry.value = 'China';
    } else {
      currentCity.value = '未知城市';
      currentCountry.value = '未知国家';
    }
  }

  /// 计算到指定城市的距离
  double? calculateDistanceToCity(double cityLat, double cityLng) {
    final position = currentPosition.value;
    if (position == null) return null;

    return _locationService.calculateDistanceInKm(
      position.latitude,
      position.longitude,
      cityLat,
      cityLng,
    );
  }

  /// 格式化距离显示
  String formatDistance(double? distanceInKm) {
    if (distanceInKm == null) return '距离未知';
    
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)}m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  /// 获取位置摘要
  String getLocationSummary() {
    return _locationService.getLocationSummary();
  }

  /// 打开位置设置
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// 开始自动更新位置(每5秒一次)
  void startAutoUpdate() {
    if (isAutoUpdating.value) return;
    
    isAutoUpdating.value = true;
    
    // 立即获取一次位置
    getCurrentLocation();
    
    // 设置定时器,每5秒更新一次
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        // 输出坐标到控制台
        log('📍 位置更新 [${DateTime.now().toString().split('.')[0]}]:');
        log('   纬度: ${position.latitude.toStringAsFixed(6)}');
        log('   经度: ${position.longitude.toStringAsFixed(6)}');
        log('   精度: ±${position.accuracy.toStringAsFixed(1)}m');
        log('   海拔: ${position.altitude.toStringAsFixed(1)}m');
        log('   速度: ${position.speed.toStringAsFixed(1)}m/s');
        log('---');
        
        // 更新城市信息
        await _getCityFromCoordinates(position.latitude, position.longitude);
      }
    });
  }

  /// 停止自动更新位置
  void stopAutoUpdate() {
    if (_locationTimer != null) {
      _locationTimer!.cancel();
      _locationTimer = null;
    }
    isAutoUpdating.value = false;
    log('⏸️ 位置自动更新已停止');
  }
}
