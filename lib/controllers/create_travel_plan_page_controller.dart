import 'dart:convert';
import 'dart:developer';

import 'package:df_admin_mobile/services/amap_poi_service.dart';
import 'package:df_admin_mobile/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CreateTravelPlanPageController extends GetxController {
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
  }

  @override
  void onClose() {
    customBudgetController.dispose();
    super.onClose();
  }

  /// 获取当前位置并逆向解析地址
  Future<void> _loadCurrentLocation() async {
    isLoadingLocation.value = true;

    try {
      final locationService = Get.find<LocationService>();

      log('📍 开始获取位置... (最多等待60秒)');

      // 增加超时时间，首次GPS定位可能需要较长时间
      final position =
          await locationService.getCurrentLocation().timeout(const Duration(seconds: 60), onTimeout: () {
        log('⏱️ 定位超时（60秒）');
        return null;
      });

      if (position == null) {
        log('❌ 无法获取位置或超时，使用默认值');
        departureLocation.value = '';
        isLoadingLocation.value = false;
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
        departureLocation.value =
            geoResult.shortAddress.isNotEmpty ? geoResult.shortAddress : geoResult.formattedAddress;
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
      log('❌ 获取位置异常: $e');
      departureLocation.value = '';
    } finally {
      isLoadingLocation.value = false;
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
