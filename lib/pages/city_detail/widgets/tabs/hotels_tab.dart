import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/city/presentation/controllers/city_detail_state_controller.dart';
import '../../../hotel_list/hotel_list_page.dart';
import '../../city_detail_controller.dart';

/// Hotels Tab - GetView 实现
///
/// 显示城市的酒店列表，直接使用 HotelListPage 组件
class HotelsTab extends GetView<CityDetailController> {
  const HotelsTab({super.key, required String tag}) : _tag = tag;

  final String _tag;

  @override
  String? get tag => _tag;

  @override
  Widget build(BuildContext context) {
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;

    return HotelListPage(
      cityId: controller.cityId,
      cityName: controller.cityName,
      countryName: city?.country,
      latitude: city?.latitude,
      longitude: city?.longitude,
    );
  }
}
