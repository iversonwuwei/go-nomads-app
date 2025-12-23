import 'dart:developer';

import 'package:df_admin_mobile/features/user/domain/repositories/i_user_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/entities.dart';
import '../../services/travel_detection_service.dart';
import '../../services/reverse_geocoding_service.dart';
import '../../services/travel_history_sync_service.dart';
import '../../data/dao/travel_history_dao.dart';

/// 旅行历史控制器
/// 管理旅行历史页面的状态和业务逻辑
class TravelHistoryController extends GetxController {
  late final TravelDetectionService _detectionService;
  late final ReverseGeocodingService _geocodingService;
  late final TravelHistoryDao _dao;
  late final TravelHistorySyncService _syncService;

  /// 是否正在加载
  final RxBool isLoading = false.obs;

  /// 是否正在同步
  final RxBool isSyncing = false.obs;

  /// 是否启用自动检测
  final RxBool isAutoDetectionEnabled = false.obs;

  /// 待确认的旅行
  final RxList<CandidateTrip> pendingTrips = <CandidateTrip>[].obs;

  /// 已确认的旅行历史
  final RxList<CandidateTrip> confirmedTrips = <CandidateTrip>[].obs;

  /// 常住地
  final Rx<HomeLocation?> homeLocation = Rx<HomeLocation?>(null);

  /// 统计信息
  final Rx<Map<String, dynamic>> statistics = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // 使用全局单例的 DAO 和 DetectionService
    if (Get.isRegistered<TravelHistoryDao>()) {
      _dao = Get.find<TravelHistoryDao>();
    } else {
      _dao = TravelHistoryDao();
    }
    await _dao.ensureTables();

    // 使用全局单例的 TravelDetectionService
    if (Get.isRegistered<TravelDetectionService>()) {
      _detectionService = Get.find<TravelDetectionService>();
      // 确保服务已初始化
      if (!_detectionService.isRunning.value && !_detectionService.isEnabled.value) {
        await _detectionService.init();
      }
    } else {
      _detectionService = TravelDetectionService(dao: _dao);
      await _detectionService.init();
    }

    _geocodingService = ReverseGeocodingService.instance;

    // 初始化同步服务
    _syncService = TravelHistorySyncService.create(dao: _dao);
    isSyncing.bindStream(_syncService.isSyncing.stream);

    // 绑定检测服务的状态
    isAutoDetectionEnabled.value = _detectionService.isEnabled.value;
    pendingTrips.value = _detectionService.pendingTrips;
    homeLocation.value = _detectionService.homeLocation.value;

    // 监听检测服务的变化
    ever(_detectionService.isEnabled, (enabled) {
      isAutoDetectionEnabled.value = enabled;
    });

    ever(_detectionService.pendingTrips, (trips) {
      pendingTrips.value = trips;
    });

    ever(_detectionService.homeLocation, (home) {
      homeLocation.value = home;
    });

    // 从后端加载自动检测状态
    await _loadAutoDetectionFromBackend();

    // 加载数据
    await loadData();
  }

  /// 从后端加载自动检测状态
  Future<void> _loadAutoDetectionFromBackend() async {
    try {
      if (!Get.isRegistered<IUserPreferencesRepository>()) {
        log('⚠️ IUserPreferencesRepository 未注册，跳过后端状态加载');
        return;
      }

      final preferencesRepo = Get.find<IUserPreferencesRepository>();
      final preferences = await preferencesRepo.getCurrentUserPreferences();
      
      if (preferences.autoTravelDetectionEnabled) {
        if (!_detectionService.isRunning.value) {
          await _detectionService.start();
          log('🔄 从后端恢复启动自动旅行检测');
        }
      } else {
        if (_detectionService.isRunning.value) {
          await _detectionService.stop();
          log('🔄 从后端恢复停止自动旅行检测');
        }
      }
      
      isAutoDetectionEnabled.value = _detectionService.isEnabled.value;
    } catch (e) {
      log('⚠️ 从后端加载自动检测状态失败: $e');
    }
  }

  /// 加载所有数据
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // 首先从后端同步数据
      await _syncWithBackend();

      // 加载已确认的旅行
      confirmedTrips.value = await _detectionService.getConfirmedTrips();

      // 刷新待确认的旅行
      await _detectionService.refreshPendingTrips();
      pendingTrips.value = _detectionService.pendingTrips;

      // 加载统计信息
      statistics.value = await _detectionService.getStatistics();

      // 为没有城市名的待确认旅行获取地理编码
      await _geocodePendingTrips();

      log('✅ 旅行历史数据加载完成');
    } catch (e) {
      log('❌ 加载旅行历史数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 与后端同步数据
  Future<void> _syncWithBackend() async {
    try {
      log('🔄 开始与后端同步旅行历史...');
      await _syncService.fullSync();
      log('✅ 后端同步完成');
    } catch (e) {
      log('⚠️ 后端同步失败，使用本地数据: $e');
    }
  }

  /// 手动同步
  Future<void> syncWithBackend() async {
    if (isSyncing.value) return;
    
    try {
      await _syncService.fullSync();
      
      // 重新加载数据
      confirmedTrips.value = await _detectionService.getConfirmedTrips();
      
      Get.snackbar(
        'success'.tr,
        'sync_completed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      log('❌ 同步失败: $e');
      Get.snackbar(
        'error'.tr,
        'sync_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 为待确认的旅行获取地理编码
  Future<void> _geocodePendingTrips() async {
    for (final trip in pendingTrips) {
      if (!trip.hasGeocodingInfo) {
        final result = await _geocodingService.reverseGeocode(
          trip.latitude,
          trip.longitude,
        );

        if (result != null) {
          final updatedTrip = trip.withGeocodingInfo(
            cityName: result.displayCityName,
            countryName: result.countryName,
          );
          await _dao.updateCandidateTrip(updatedTrip);

          // 更新列表
          final index = pendingTrips.indexWhere((t) => t.id == trip.id);
          if (index >= 0) {
            pendingTrips[index] = updatedTrip;
          }
        }
      }
    }
  }

  /// 启动/停止自动检测
  Future<void> toggleAutoDetection() async {
    if (isAutoDetectionEnabled.value) {
      await _detectionService.stop();
      isAutoDetectionEnabled.value = false;
      log('⏹️ 自动旅行检测已停止');
    } else {
      await _detectionService.start();
      isAutoDetectionEnabled.value = _detectionService.isRunning.value;
      log('🚀 自动旅行检测已启动');
    }
  }

  /// 确认旅行
  Future<void> confirmTrip(CandidateTrip trip) async {
    if (trip.id == null) return;

    try {
      await _detectionService.confirmTrip(trip.id!);

      // 移动到已确认列表
      pendingTrips.removeWhere((t) => t.id == trip.id);
      final confirmedTrip = trip.confirm();
      confirmedTrips.insert(0, confirmedTrip);

      Get.snackbar(
        'success'.tr,
        'travel_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      log('✅ 旅行已确认: ${trip.displayName}');

      // 异步同步到后端（不阻塞 UI）
      _syncService.confirmAndSync(confirmedTrip).then((synced) {
        if (synced) {
          log('✅ 旅行已同步到后端: ${trip.displayName}');
        } else {
          log('⚠️ 旅行未能同步到后端，将在下次同步时重试: ${trip.displayName}');
        }
      });
    } catch (e) {
      log('❌ 确认旅行失败: $e');
      Get.snackbar(
        'error'.tr,
        'save_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 忽略旅行
  Future<void> dismissTrip(CandidateTrip trip) async {
    if (trip.id == null) return;

    try {
      await _detectionService.dismissTrip(trip.id!);
      pendingTrips.removeWhere((t) => t.id == trip.id);

      log('❌ 旅行已忽略: ${trip.displayName}');
    } catch (e) {
      log('❌ 忽略旅行失败: $e');
    }
  }

  /// 设置常住地（当前位置）
  Future<void> setHomeLocationFromCurrentPosition() async {
    try {
      isLoading.value = true;

      // 使用 geolocator 获取当前位置
      final position = await Get.find<dynamic>().getCurrentLocation();
      if (position == null) {
        Get.snackbar(
          'error'.tr,
          'location_unavailable'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _detectionService.setHomeLocationManually(
        position.latitude,
        position.longitude,
      );

      // 获取地理编码信息
      final geocoding = await _geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (geocoding != null) {
        final home = homeLocation.value;
        if (home != null) {
          await _dao.saveHomeLocation(home.copyWith(
            cityName: geocoding.displayCityName,
            countryName: geocoding.countryName,
          ));
          homeLocation.value = await _dao.getHomeLocation();
        }
      }

      Get.snackbar(
        'success'.tr,
        'home_location_set'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      log('🏠 常住地已设置');
    } catch (e) {
      log('❌ 设置常住地失败: $e');
      Get.snackbar(
        'error'.tr,
        'set_home_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 删除旅行历史
  Future<void> deleteTripHistory(CandidateTrip trip) async {
    // TODO: 实现删除功能
    confirmedTrips.removeWhere((t) => t.id == trip.id);
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_clear'.tr),
        content: Text('clear_all_data_warning'.tr),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) {
                Get.back(result: false);
              }
            },
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) {
                Get.back(result: true);
              }
            },
            child: Text(
              'clear'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await _detectionService.clearAllData();
      pendingTrips.clear();
      confirmedTrips.clear();
      homeLocation.value = null;
      log('✅ 数据清除完成');
    }
  }

  /// 刷新数据
  @override
  Future<void> refresh() async {
    await loadData();
  }

  @override
  void onClose() {
    // 不停止检测服务，让它继续在后台运行
    super.onClose();
  }
}
