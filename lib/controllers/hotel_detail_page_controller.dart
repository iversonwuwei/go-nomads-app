import 'dart:async';
import 'dart:developer';

import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:get/get.dart';

/// 酒店详情页控制器
class HotelDetailPageController extends GetxController {
  final int hotelId;

  HotelDetailPageController({required this.hotelId});

  final HotelRepository _hotelRepository = HotelRepository(HttpService());
  final RxBool isLoading = true.obs;
  final Rxn<Hotel> hotel = Rxn<Hotel>();
  final RxString error = ''.obs;

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
    loadHotel();
  }

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    super.onClose();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('hotel', _handleDataChanged);
    log('✅ [HotelDetailPageController] 数据变更监听器已设置');
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 只处理当前酒店的变更
    if (event.entityId != hotelId.toString()) {
      return;
    }

    log('🔔 [酒店详情] 收到数据变更通知: ${event.entityId} (${event.changeType})');

    switch (event.changeType) {
      case DataChangeType.updated:
        // 酒店数据更新，重新加载详情
        loadHotel();
        break;
      case DataChangeType.deleted:
        // 酒店被删除
        log('⚠️ [酒店详情] 该酒店已被删除');
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        loadHotel();
        break;
      case DataChangeType.created:
        // 新建酒店通常不影响详情页
        break;
    }
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
