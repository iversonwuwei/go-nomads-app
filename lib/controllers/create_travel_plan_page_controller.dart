import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/services/amap_native_location_service.dart';
import 'package:go_nomads_app/services/amap_poi_service.dart';
import 'package:go_nomads_app/services/location_service.dart';
import 'package:http/http.dart' as http;

class CreateTravelPlanPageController extends GetxController {
  static const String controllerTag = 'create_travel_plan_page';

  final String cityId;
  final String cityName;

  CreateTravelPlanPageController({required this.cityId, required this.cityName});

  // State
  final RxInt duration = 7.obs;
  final RxString budget = 'medium'.obs;
  final RxString travelStyle = 'culture'.obs;
  final RxList<String> interests = <String>[].obs;
  final RxString departureLocation = ''.obs;
  final RxBool isLoadingLocation = true.obs;
  final Rx<DateTime?> departureDate = Rx<DateTime?>(null);
  final RxString selectedCurrency = 'USD'.obs;
  final RxList<String> selectedAttractions = <String>[].obs;

  final TextEditingController customBudgetController = TextEditingController();

  // 出发地搜索相关状态
  final TextEditingController departureSearchController = TextEditingController();
  final FocusNode departureFocusNode = FocusNode();
  final RxList<PoiResult> departureSuggestions = <PoiResult>[].obs;
  final RxBool isDepartureSearching = false.obs;
  final RxBool showDepartureSuggestions = false.obs;
  Timer? _departureSearchDebounce;

  // 根据城市名称获取景点列表
  List<Map<String, dynamic>> get cityAttractions => [
        {'name': '历史古迹', 'icon': FontAwesomeIcons.landmark, 'id': 'historic'},
        {'name': '博物馆', 'icon': FontAwesomeIcons.landmark, 'id': 'museum'},
        {'name': '公园绿地', 'icon': FontAwesomeIcons.tree, 'id': 'park'},
        {'name': '美食街区', 'icon': FontAwesomeIcons.utensils, 'id': 'food_district'},
        {'name': '购物中心', 'icon': FontAwesomeIcons.cartShopping, 'id': 'shopping_mall'},
        {'name': '艺术画廊', 'icon': FontAwesomeIcons.palette, 'id': 'art_gallery'},
        {'name': '观景台', 'icon': FontAwesomeIcons.mountain, 'id': 'viewpoint'},
        {'name': '海滩', 'icon': FontAwesomeIcons.umbrellaBeach, 'id': 'beach'},
        {'name': '寺庙教堂', 'icon': FontAwesomeIcons.placeOfWorship, 'id': 'temple'},
        {'name': '夜市', 'icon': FontAwesomeIcons.moon, 'id': 'night_market'},
        {'name': '主题乐园', 'icon': FontAwesomeIcons.cameraRetro, 'id': 'theme_park'},
        {'name': '水族馆', 'icon': FontAwesomeIcons.water, 'id': 'aquarium'},
      ];

  @override
  void onInit() {
    super.onInit();
    _loadCurrentLocation();

    // 监听出发地位置变化，同步到搜索框
    ever(departureLocation, (String value) {
      if (departureSearchController.text != value) {
        departureSearchController.text = value;
      }
    });

    // 监听焦点变化
    departureFocusNode.addListener(_onDepartureFocusChange);
  }

  @override
  void onClose() {
    customBudgetController.dispose();
    departureSearchController.dispose();
    departureFocusNode.removeListener(_onDepartureFocusChange);
    departureFocusNode.dispose();
    _departureSearchDebounce?.cancel();
    super.onClose();
  }

  void _onDepartureFocusChange() {
    if (!departureFocusNode.hasFocus) {
      // 延迟隐藏，以便用户可以点击建议项
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!departureFocusNode.hasFocus) {
          hideDepartureSuggestions();
        }
      });
    }
  }

  /// 出发地搜索文本变化处理
  void onDepartureSearchChanged(String value) {
    _departureSearchDebounce?.cancel();

    if (value.trim().isEmpty) {
      hideDepartureSuggestions();
      return;
    }

    _departureSearchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchDepartureAddress(value.trim());
    });
  }

  /// 搜索出发地地址
  Future<void> searchDepartureAddress(String keyword) async {
    if (keyword.isEmpty) return;

    isDepartureSearching.value = true;
    showDepartureSuggestions.value = true;

    try {
      final result = await AmapPoiService.instance.searchByKeyword(
        keyword: keyword,
        pageSize: 10,
      );

      departureSuggestions.value = result.items;
    } catch (e) {
      debugPrint('搜索地址失败: $e');
      departureSuggestions.clear();
    } finally {
      isDepartureSearching.value = false;
    }
  }

  /// 选择出发地建议
  void selectDepartureSuggestion(PoiResult poi) {
    final displayAddress = poi.address.isNotEmpty ? poi.address : poi.name;
    departureSearchController.text = displayAddress;
    departureLocation.value = displayAddress;
    hideDepartureSuggestions();
    departureFocusNode.unfocus();
  }

  /// 隐藏出发地建议列表
  void hideDepartureSuggestions() {
    showDepartureSuggestions.value = false;
  }

  /// 清除出发地搜索
  void clearDepartureSearch() {
    departureSearchController.clear();
    departureLocation.value = '';
    hideDepartureSuggestions();
  }

  /// 公开方法：重新获取当前位置
  /// 供 UI 组件调用（如点击定位按钮）
  Future<void> refreshCurrentLocation() async {
    await _loadCurrentLocation();
  }

  /// 获取当前位置并逆向解析地址
  /// 优先使用原生高德SDK（Android/iOS），其他平台回退到geolocator
  Future<void> _loadCurrentLocation() async {
    isLoadingLocation.value = true;

    try {
      // 整体兜底超时，避免在真机上出现长时间卡在 loading。
      await _loadCurrentLocationCore().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          log('⏱️ 获取当前位置整体超时（20秒），结束加载状态');
          departureLocation.value = '';
        },
      );
    } catch (e) {
      log('❌ 获取位置异常: $e');
      departureLocation.value = '';
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> _loadCurrentLocationCore() async {
    try {
      // Android/iOS 平台优先使用原生高德 SDK
      if (Platform.isAndroid || Platform.isIOS) {
        if (!Get.isRegistered<AmapNativeLocationService>()) {
          log('⚠️ 原生高德定位服务未注册，跳过原生定位');
        } else {
          final amapService = Get.find<AmapNativeLocationService>();
          final platformName = Platform.isAndroid ? 'Android' : 'iOS';
          log('📍 [$platformName] 使用原生高德 SDK 获取位置...');

          final location = await amapService.getCurrentLocation().timeout(
            const Duration(seconds: 12),
            onTimeout: () {
              log('⏱️ 原生高德定位超时（12秒）');
              return null;
            },
          );

          if (location != null) {
            // 检查原生高德 SDK 是否返回了有效的地址信息
            if (location.hasValidAddress) {
              // 原生高德 SDK 已包含逆地理编码结果
              // ⭐ 使用完整地址而非简短地址
              departureLocation.value = location.address.isNotEmpty ? location.address : location.shortAddress;
              log('✅ 原生高德定位成功（含地址）: ${departureLocation.value}');
              log('   详细地址: ${location.address}');
              log('   坐标: ${location.latitude}, ${location.longitude}');
              return;
            } else {
              // 定位成功但没有地址信息（可能在海外），需要额外的逆地理编码
              log('⚠️ 原生高德定位成功但无地址信息，尝试额外逆地理编码...');
              log('   坐标: ${location.latitude}, ${location.longitude}');
              await _reverseGeocodeWithFallback(location.latitude, location.longitude);
              return;
            }
          } else {
            log('⚠️ 原生高德定位失败: ${amapService.errorMessage.value}');
            // 继续尝试备用方案
          }
        }
      }

      // 其他平台或高德失败时，使用 geolocator + Web API
      await _loadCurrentLocationFallback();
    } catch (e) {
      log('❌ 获取位置异常: $e');
      departureLocation.value = '';
    }
  }

  /// 使用备用服务进行逆地理编码（当原生SDK只返回坐标时）
  Future<void> _reverseGeocodeWithFallback(double latitude, double longitude) async {
    // 先尝试高德 Web API（中国大陆）
    final geoResult = await AmapPoiService.instance
        .reverseGeocode(latitude: latitude, longitude: longitude)
        .timeout(const Duration(seconds: 5), onTimeout: () => null);

    if (geoResult != null && geoResult.formattedAddress.isNotEmpty) {
      // ⭐ 优先使用 formattedAddress（完整详细地址）
      departureLocation.value = geoResult.formattedAddress;
      log('✅ 高德 Web API 逆地理编码成功: ${departureLocation.value}');
      return;
    }

    // 高德失败，尝试 Nominatim（OpenStreetMap）
    log('⚠️ 高德 Web API 逆地理编码失败，尝试 Nominatim...');
    final nominatimResult = await _reverseGeocodeWithNominatim(latitude, longitude);
    if (nominatimResult != null && nominatimResult.isNotEmpty) {
      departureLocation.value = nominatimResult;
      log('✅ Nominatim 逆地理编码成功: ${departureLocation.value}');
      return;
    }

    // 都失败了，显示坐标
    departureLocation.value = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    log('⚠️ 所有逆地理编码服务失败，使用坐标: ${departureLocation.value}');
  }

  /// 备用定位方案：使用 geolocator + 高德 Web API / Nominatim
  Future<void> _loadCurrentLocationFallback() async {
    try {
      final locationService = Get.find<LocationService>();

      log('📍 [Fallback] 使用 geolocator 获取位置... (最多等待60秒)');

      final position = await locationService.getCurrentLocation().timeout(const Duration(seconds: 12), onTimeout: () {
        log('⏱️ 定位超时（12秒）');
        return null;
      });

      if (position == null) {
        log('❌ 无法获取位置或超时，使用默认值');
        departureLocation.value = '';
        return;
      }

      log('📍 获取到位置: ${position.latitude}, ${position.longitude}');

      // 先尝试高德逆地理编码（中国大陆）
      final geoResult = await AmapPoiService.instance
          .reverseGeocode(
            latitude: position.latitude,
            longitude: position.longitude,
          )
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (geoResult != null && geoResult.formattedAddress.isNotEmpty) {
        // ⭐ 优先使用 formattedAddress（完整详细地址）
        departureLocation.value = geoResult.formattedAddress;
        log('✅ 高德逆地理编码成功: ${departureLocation.value}');
      } else {
        // 高德失败，尝试使用 Nominatim（OpenStreetMap）作为备用
        log('⚠️ 高德逆地理编码失败，尝试 Nominatim...');
        final nominatimResult = await _reverseGeocodeWithNominatim(position.latitude, position.longitude);
        if (nominatimResult != null && nominatimResult.isNotEmpty) {
          departureLocation.value = nominatimResult;
          log('✅ Nominatim 逆地理编码成功: ${departureLocation.value}');
        } else {
          // 都失败了，显示坐标
          departureLocation.value = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          log('⚠️ 使用坐标作为出发地: ${departureLocation.value}');
        }
      }
    } catch (e) {
      log('❌ [Fallback] 获取位置异常: $e');
      departureLocation.value = '';
    }
  }

  /// 使用 Nominatim (OpenStreetMap) 进行逆地理编码
  /// 适用于全球范围，但请注意遵守使用限制
  Future<String?> _reverseGeocodeWithNominatim(double latitude, double longitude) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
        'addressdetails': '1',
        'accept-language': 'zh-CN,en', // 优先中文
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'GoNomads/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // 构建简短地址
          final parts = <String>[];
          if (address['suburb'] != null) parts.add(address['suburb'].toString());
          if (address['city'] != null) {
            parts.add(address['city'].toString());
          } else if (address['town'] != null) {
            parts.add(address['town'].toString());
          } else if (address['county'] != null) {
            parts.add(address['county'].toString());
          }
          if (address['country'] != null) parts.add(address['country'].toString());

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }

        // 使用 display_name 作为备用
        return data['display_name'] as String?;
      }
    } catch (e) {
      log('❌ Nominatim 逆地理编码失败: $e');
    }
    return null;
  }

  void setDuration(int value) => duration.value = value;

  void setBudget(String value) {
    budget.value = value;
    if (value != 'custom') {
      customBudgetController.clear();
    }
  }

  void setTravelStyle(String value) => travelStyle.value = value;

  void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
  }

  void toggleAttraction(String id) {
    if (selectedAttractions.contains(id)) {
      selectedAttractions.remove(id);
    } else {
      selectedAttractions.add(id);
    }
  }

  void setDepartureLocation(String value) {
    departureLocation.value = value;
    isLoadingLocation.value = false;
  }

  void clearDepartureLocation() => departureLocation.value = '';

  void setDepartureDate(DateTime? date) => departureDate.value = date;

  void clearDepartureDate() => departureDate.value = null;

  void setCurrency(String value) => selectedCurrency.value = value;

  void onCustomBudgetChanged(String value) {
    if (value.isNotEmpty) {
      budget.value = 'custom';
    }
  }

  /// 构建最终预算字符串
  String getFinalBudget() {
    if (customBudgetController.text.isNotEmpty) {
      return '${selectedCurrency.value}:${customBudgetController.text}';
    }
    return budget.value;
  }

  /// 合并兴趣和景点
  List<String> getAllInterests() {
    final allInterests = <String>[...interests];
    for (var attractionId in selectedAttractions) {
      allInterests.add('attraction:$attractionId');
    }
    return allInterests;
  }
}
