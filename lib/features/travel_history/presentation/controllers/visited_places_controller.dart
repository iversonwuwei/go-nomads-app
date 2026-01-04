import 'dart:developer';

import 'package:get/get.dart';

import '../../data/dao/travel_history_dao.dart';
import '../../domain/entities/visited_place.dart';
import '../../services/visited_place_sync_service.dart';

/// 访问地点控制器
class VisitedPlacesController extends GetxController {
  final String travelHistoryId;
  final String? cityName;
  final String? countryName;

  late final TravelHistoryDao _dao;
  late final VisitedPlaceSyncService _syncService;

  /// 访问地点列表
  final places = <VisitedPlace>[].obs;

  /// 加载状态
  final isLoading = true.obs;

  /// 错误信息
  final error = ''.obs;

  /// 旅行标题
  final tripTitle = ''.obs;

  VisitedPlacesController({
    required this.travelHistoryId,
    this.cityName,
    this.countryName,
  });

  @override
  void onInit() {
    super.onInit();
    _initServices();
    _setTripTitle();
    loadVisitedPlaces();
  }

  void _initServices() {
    _dao = TravelHistoryDao();
    _syncService = VisitedPlaceSyncService.create(dao: _dao);
  }

  void _setTripTitle() {
    if (cityName != null && countryName != null) {
      tripTitle.value = '$cityName, $countryName';
    } else if (cityName != null) {
      tripTitle.value = cityName!;
    }
  }

  /// 加载访问地点
  Future<void> loadVisitedPlaces() async {
    isLoading.value = true;
    error.value = '';

    try {
      log('📍 加载访问地点 - travelHistoryId: $travelHistoryId');

      // 使用同步服务获取数据（优先本地，必要时从后端获取）
      final loadedPlaces = await _syncService.getVisitedPlaces(travelHistoryId);

      places.value = loadedPlaces;
      log('✅ 加载到 ${loadedPlaces.length} 个访问地点');
    } catch (e, stackTrace) {
      log('❌ 加载访问地点失败: $e');
      log('📍 堆栈: $stackTrace');
      error.value = 'Failed to load visited places';
    } finally {
      isLoading.value = false;
    }
  }

  /// 切换精选状态
  Future<void> toggleHighlight(VisitedPlace place) async {
    try {
      final updatedPlace = place.copyWith(isHighlight: !place.isHighlight);

      // 更新本地
      await _dao.updateVisitedPlace(updatedPlace);

      // 更新列表
      final index = places.indexWhere((p) => p.id == place.id);
      if (index >= 0) {
        places[index] = updatedPlace;
        places.refresh();
      }

      log('✅ 切换精选状态成功 - ${place.placeName}: ${!place.isHighlight}');

      // 触发后台同步
      _syncService.syncUnsyncedToBackend();
    } catch (e) {
      log('❌ 切换精选状态失败: $e');
      Get.snackbar(
        'Error',
        'Failed to update highlight status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadVisitedPlaces();
  }
}
