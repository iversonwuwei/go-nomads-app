import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:df_admin_mobile/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// HotelListPage 控制器
class HotelListPageController extends GetxController {
  final String? cityId;
  final String? cityName;
  final String? countryName;

  HotelListPageController({
    this.cityId,
    this.cityName,
    this.countryName,
  });

  final RxBool isLoading = false.obs;
  final RxList<Hotel> hotels = <Hotel>[].obs;
  final RxBool canManageHotels = false.obs;

  // 搜索条件
  final RxString searchQuery = ''.obs;

  late final HotelRepository _hotelRepository;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _hotelRepository = HotelRepository(HttpService());
    // 异步加载数据,不阻塞页面显示
    Future.microtask(() {
      loadHotels();
      _checkPermissions();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// 公开的刷新方法，供外部调用
  void refresh() {
    loadHotels();
  }

  Future<void> _checkPermissions() async {
    // 检查用户是否为管理员或版主
    final isAdmin = await TokenStorageService().isAdmin();
    canManageHotels.value = isAdmin;
    log('🏨 Hotel管理权限: isAdmin=$isAdmin, canManage=${canManageHotels.value}');
  }

  // 加载酒店数据
  Future<void> loadHotels() async {
    isLoading.value = true;
    try {
      log('🏨 HotelListPage - cityId: $cityId, cityName: $cityName');

      List<Hotel> loadedHotels = [];

      // 如果有城市ID，加载该城市的酒店
      if (cityId != null) {
        log('🏨 正在加载城市 ID $cityId 的酒店...');
        final result = await _hotelRepository.getHotelsByCity(cityId!);

        result.fold(
          onSuccess: (data) {
            loadedHotels = data;
            log('🏨 找到 ${loadedHotels.length} 个酒店');
          },
          onFailure: (exception) {
            // 酒店服务暂未实现，静默处理错误，显示空状态
            log('⚠️ 酒店服务暂不可用: ${exception.message}');
          },
        );
      } else {
        // 加载所有酒店
        final result = await _hotelRepository.getHotels();

        result.fold(
          onSuccess: (data) {
            loadedHotels = data;
            log('🏨 找到 ${loadedHotels.length} 个酒店');
          },
          onFailure: (exception) {
            // 酒店服务暂未实现，静默处理错误，显示空状态
            log('⚠️ 酒店服务暂不可用: ${exception.message}');
          },
        );
      }

      // 如果有搜索查询，过滤结果
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        loadedHotels = loadedHotels.where((hotel) {
          final name = hotel.name.toLowerCase();
          final description = hotel.description.toLowerCase();
          return name.contains(query) || description.contains(query);
        }).toList();
      }

      // 按评分排序
      loadedHotels.sort((a, b) => b.rating.compareTo(a.rating));

      hotels.value = loadedHotels;
    } catch (e) {
      // 酒店服务暂未实现，静默处理错误，显示空状态
      log('⚠️ 酒店服务暂不可用: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 更新搜索查询
  void updateSearchQuery(String value) {
    searchQuery.value = value;
    if (value.isEmpty || value.length >= 3) {
      loadHotels();
    }
  }

  /// 清除搜索
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadHotels();
  }

  /// 导航到添加酒店页面
  Future<void> navigateToAddHotel() async {
    log('🏨 [HotelList] navigateToAddHotel - cityId: $cityId, cityName: $cityName, countryName: $countryName');
    final result = await Get.toNamed(AppRoutes.addHotel, arguments: {
      'cityId': cityId,
      'cityName': cityName,
      'countryName': countryName,
    });
    if (result == true) {
      log('🏨 [HotelList] 酒店创建成功，刷新列表');
      loadHotels();
    }
  }

  /// 更新酒店列表中的酒店
  void updateHotelInList(Hotel updatedHotel) {
    final index = hotels.indexWhere((h) => h.id == updatedHotel.id);
    if (index != -1) {
      hotels[index] = updatedHotel;
    }
  }
}
