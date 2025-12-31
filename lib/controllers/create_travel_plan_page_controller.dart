import 'dart:developer';

import 'package:df_admin_mobile/services/amap_poi_service.dart';
import 'package:df_admin_mobile/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

      // 添加超时机制，防止无限等待
      final position =
          await locationService.getCurrentLocation().timeout(const Duration(seconds: 10), onTimeout: () => null);

      if (position == null) {
        log('❌ 无法获取位置或超时，使用默认值');
        departureLocation.value = '';
        isLoadingLocation.value = false;
        return;
      }

      log('📍 获取到位置: ${position.latitude}, ${position.longitude}');

      // 使用高德逆地理编码获取地址，同样添加超时
      final geoResult = await AmapPoiService.instance
          .reverseGeocode(
            latitude: position.latitude,
            longitude: position.longitude,
          )
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (geoResult != null) {
        departureLocation.value =
            geoResult.shortAddress.isNotEmpty ? geoResult.shortAddress : geoResult.formattedAddress;
        log('✅ 逆地理编码成功: ${departureLocation.value}');
      } else {
        departureLocation.value = '';
        log('❌ 逆地理编码失败或超时');
      }
    } catch (e) {
      log('❌ 获取位置异常: $e');
      departureLocation.value = '';
    } finally {
      isLoadingLocation.value = false;
    }
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
