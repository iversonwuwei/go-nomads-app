import 'dart:developer';

import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller_v2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// AmapGlobalPage 控制器
class AmapGlobalPageController extends GetxController {
  final searchController = TextEditingController();
  final RxString searchKeyword = ''.obs;
  final RxBool isLoading = true.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  CityStateControllerV2? _cityControllerCache;
  CityStateControllerV2 get cityController {
    _cityControllerCache ??= Get.find<CityStateControllerV2>();
    return _cityControllerCache!;
  }

  List<City> get filteredCities {
    final cities = cityController.cities;
    if (searchKeyword.value.trim().isEmpty) return cities;
    final keyword = searchKeyword.value.toLowerCase();
    return cities.where((city) {
      return city.name.toLowerCase().contains(keyword) ||
          (city.nameEn?.toLowerCase().contains(keyword) ?? false) ||
          (city.country?.toLowerCase().contains(keyword) ?? false);
    }).toList();
  }

  List<City> get citiesWithCoordinates {
    return filteredCities.where((city) {
      return city.latitude != null && city.longitude != null;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCities();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadCities() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      if (cityController.cities.isEmpty) {
        await cityController.loadInitialCities(refresh: true);
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  void updateSearchKeyword(String value) {
    searchKeyword.value = value;
  }

  void clearSearch() {
    searchKeyword.value = '';
    searchController.clear();
  }

  void clearError() {
    errorMessage.value = null;
  }

  void centerToUserLocation() {
    log('📍 Center to user location');
  }

  void changeZoom(int delta) {
    log('🔍 Change zoom: $delta');
  }

  void resetToWorld() {
    log('🌍 Reset to world view');
  }

  Color getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'asia':
        return Colors.red;
      case 'europe':
        return Colors.blue;
      case 'north america':
        return Colors.green;
      case 'south america':
        return Colors.orange;
      case 'africa':
        return Colors.purple;
      case 'oceania':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Map<String, int> getRegionStats() {
    final regionStats = <String, int>{};
    for (final city in citiesWithCoordinates) {
      final region = city.region ?? 'Other';
      regionStats[region] = (regionStats[region] ?? 0) + 1;
    }
    return regionStats;
  }
}
