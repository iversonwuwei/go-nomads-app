import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:df_admin_mobile/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:get/get.dart';

/// 酒店详情页控制器
class HotelDetailPageController extends GetxController {
  final int hotelId;

  HotelDetailPageController({required this.hotelId});

  final HotelRepository _hotelRepository = HotelRepository(HttpService());
  final RxBool isLoading = true.obs;
  final Rxn<Hotel> hotel = Rxn<Hotel>();
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHotel();
  }

  Future<void> loadHotel() async {
    isLoading.value = true;
    error.value = '';

    final result = await _hotelRepository.getHotelById(hotelId.toString());

    result.onSuccess((h) {
      hotel.value = h;
      log('🏨 加载酒店详情成功: ${h.name}');
    }).onFailure((exception) {
      error.value = exception.message;
      log('❌ 加载酒店详情失败: ${exception.message}');
    });

    isLoading.value = false;
  }
}
