import 'dart:async';
import 'dart:io';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';

/// 高德地图位置选择器页面
/// 使用高德地图官方 SDK (amap_map_fluttify)
class AmapLocationPickerPage extends StatefulWidget {
  final String? initialLocation;

  const AmapLocationPickerPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<AmapLocationPickerPage> createState() => _AmapLocationPickerPageState();
}

class _AmapLocationPickerPageState extends State<AmapLocationPickerPage> {
  AmapController? _mapController;
  
  // 地图中心位置
  LatLng _centerPosition = LatLng(39.909187, 116.397451); // 默认北京天安门
  
  // 选中的位置信息
  String _selectedAddress = 'Tap on map to select location';
  String _selectedCity = '';
  String _selectedProvince = '';
  LatLng? _selectedLatLng;
  
  bool _isLoading = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _checkSimulatorAndInit();
  }
  
  /// 检查是否为模拟器并初始化
  Future<void> _checkSimulatorAndInit() async {
    // 检测是否在 iOS 模拟器上运行
    bool isSimulator = false;
    if (Platform.isIOS) {
      // iOS 模拟器检测
      isSimulator = !kReleaseMode && defaultTargetPlatform == TargetPlatform.iOS;
    }
    
    if (isSimulator) {
      print('⚠️ 检测到 iOS 模拟器环境');
      print('⚠️ 高德地图在模拟器上可能无法正常显示');
      
      // 显示提示
      if (mounted) {
        Get.snackbar(
          '模拟器提示',
          '高德地图在 iOS 模拟器上可能无法正常显示\n建议使用真机测试',
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    }
    
    await _initMap();
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// 初始化地图
  Future<void> _initMap() async {
    // 自动获取当前位置
    await _getCurrentLocation();
  }

  /// 获取当前位置（使用 Geolocator）
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      // 检查定位权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // 获取当前位置
        Position position = await Geolocator.getCurrentPosition();

        if (mounted) {
          setState(() {
            _centerPosition = LatLng(position.latitude, position.longitude);
            _selectedLatLng = _centerPosition;
            _selectedAddress =
                'Current Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
            _isLocating = false;
          });

          // 移动地图到当前位置
          await _mapController?.setCenterCoordinate(_centerPosition, animated: true);
          await _mapController?.setZoomLevel(15, animated: true);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLocating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
        Get.snackbar(
          'Error',
          'Failed to get current location: $e',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// 地图点击事件
  Future<void> _onMapTap(LatLng latLng) async {
    setState(() {
      _selectedLatLng = latLng;
      _isLoading = true;
    });

    // 逆地理编码获取地址
    await _getAddressFromLatLng(latLng);
  }

  /// 通过经纬度获取地址（逆地理编码）
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      // 使用高德地图的逆地理编码功能
      final reGeocode = await AmapSearch.instance.searchReGeocode(latLng);
      
      setState(() {
        _selectedAddress = reGeocode.formatAddress ?? 'Selected Location';
        // reGeocode 对象可能没有 city 和 province 属性，使用 formatAddress
        _selectedCity = '';
        _selectedProvince = '';
        _isLoading = false;
      });
    } catch (e) {
      print('Geocoding error: $e');
      // 降级处理，显示坐标
      setState(() {
        _selectedAddress = 'Selected: ${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
        _selectedCity = '';
        _selectedProvince = '';
        _isLoading = false;
      });
    }
  }

  /// 确认选择
  void _confirmSelection() {
    if (_selectedLatLng == null) {
      Get.snackbar(
        'Error',
        'Please select a location on the map',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 构建完整的位置描述
    String locationDescription = _selectedAddress;
    if (_selectedCity.isNotEmpty) {
      locationDescription = '$_selectedAddress, $_selectedCity';
    }
    if (_selectedProvince.isNotEmpty && _selectedCity != _selectedProvince) {
      locationDescription = '$_selectedAddress, $_selectedCity, $_selectedProvince';
    }

    // 返回选中的位置
    Get.back(result: {
      'address': locationDescription,
      'latitude': _selectedLatLng!.latitude,
      'longitude': _selectedLatLng!.longitude,
      'city': _selectedCity,
      'province': _selectedProvince,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Color(0xFFFF4458),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 高德地图
          AmapView(
            onMapCreated: (controller) async {
              _mapController = controller;
              
              print('✅ 高德地图控制器创建成功');
              print('📍 初始位置: ${_centerPosition.latitude}, ${_centerPosition.longitude}');
              
              // 设置初始位置
              await controller.setCenterCoordinate(_centerPosition, animated: false);
              await controller.setZoomLevel(15, animated: false);
              
              print('✅ 地图位置和缩放级别设置完成');
              
              // 监听地图点击事件
              controller.setMapClickedListener((latLng) async {
                print('🖱️ 地图点击: ${latLng.latitude}, ${latLng.longitude}');
                await _onMapTap(latLng);
              });
              
              print('✅ 地图点击监听器设置完成');
            },
            mapType: MapType.Standard,
            showZoomControl: false,
            showCompass: false,
            showScaleControl: false,
            centerCoordinate: _centerPosition,
            zoomLevel: 15,
            markers: _selectedLatLng != null
                ? [
                    MarkerOption(
                      coordinate: _selectedLatLng!,
                      widget: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Color(0xFFFF4458),
                        ),
                      ),
                    ),
                  ]
                : [],
          ),

          // 顶部位置信息卡片
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFFF4458),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 右下角控制按钮
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 定位按钮
                FloatingActionButton.small(
                  heroTag: 'locate',
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: _isLocating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF4458),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.my_location,
                          color: Color(0xFFFF4458),
                        ),
                ),
                const SizedBox(height: 12),
                
                // 放大按钮
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () async {
                    final currentZoom = await _mapController?.getZoomLevel();
                    if (currentZoom != null) {
                      await _mapController?.setZoomLevel(currentZoom + 1, animated: true);
                    }
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(
                    Icons.add,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // 缩小按钮
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () async {
                    final currentZoom = await _mapController?.getZoomLevel();
                    if (currentZoom != null) {
                      await _mapController?.setZoomLevel(currentZoom - 1, animated: true);
                    }
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(
                    Icons.remove,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
