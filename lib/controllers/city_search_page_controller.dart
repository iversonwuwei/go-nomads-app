import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// CitySearchPage 控制器
class CitySearchPageController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // 筛选条件
  final RxString selectedRegion = 'All'.obs;
  final Rx<RangeValues> priceRange = const RangeValues(0, 5000).obs;
  final RxDouble minInternetSpeed = 0.0.obs;
  final RxString selectedClimate = 'All'.obs;

  final List<String> regions = [
    'All',
    'Asia',
    'Europe',
    'North America',
    'South America',
    'Africa',
    'Oceania',
  ];

  final List<String> climates = [
    'All',
    'Tropical',
    'Dry',
    'Temperate',
    'Continental',
    'Polar',
  ];

  void setRegion(String region) {
    selectedRegion.value = region;
  }

  void setPriceRange(RangeValues values) {
    priceRange.value = values;
  }

  void setMinInternetSpeed(double value) {
    minInternetSpeed.value = value;
  }

  void setClimate(String climate) {
    selectedClimate.value = climate;
  }

  void resetFilters() {
    selectedRegion.value = 'All';
    priceRange.value = const RangeValues(0, 5000);
    minInternetSpeed.value = 0;
    selectedClimate.value = 'All';
    searchController.clear();
  }

  void clearSearch() {
    searchController.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
