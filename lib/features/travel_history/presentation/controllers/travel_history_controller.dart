import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/sync/data_sync_service.dart';
import 'package:go_nomads_app/features/user/domain/repositories/i_user_preferences_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

import '../../data/dao/travel_history_dao.dart';
import '../../domain/entities/entities.dart';
import '../../services/reverse_geocoding_service.dart';
import '../../services/travel_detection_service.dart';
import '../../services/travel_history_sync_service.dart';

/// 旅行历史控制器
/// 管理旅行历史页面的状态和业务逻辑
class TravelHistoryController extends GetxController {
  static const int _pageSize = 20;

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

  final RxInt visiblePendingCount = _pageSize.obs;
  final RxBool isLoadingMorePending = false.obs;
  final RxBool isLoadingMoreConfirmed = false.obs;
  final RxBool hasMorePending = false.obs;
  final RxBool hasMoreConfirmed = false.obs;
  final RxInt confirmedTotalCount = 0.obs;

  int _confirmedCurrentPage = 1;

  List<CandidateTrip> get displayPendingTrips => pendingTrips.take(visiblePendingCount.value).toList();
  List<CandidateTrip> get displayConfirmedTrips => confirmedTrips.toList();

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
      _syncPendingPagination();
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
      log('📂 开始加载旅行历史数据...');

      // 首先从后端同步数据
      await _syncWithBackend();

      // 真实分页加载已确认的旅行历史
      await _loadConfirmedTrips(reset: true);
      log('✅ 已加载 ${confirmedTrips.length}/${confirmedTotalCount.value} 条已确认旅行');

      // 刷新待确认的旅行
      await _detectionService.refreshPendingTrips();
      pendingTrips.value = _detectionService.pendingTrips;
      log('✅ 已加载 ${pendingTrips.length} 条待确认旅行');
      _resetPendingPagination();

      // 加载统计信息
      statistics.value = await _detectionService.getStatistics();

      // 为没有城市名的待确认旅行获取地理编码
      await _geocodePendingTrips();

      log('✅ 旅行历史数据加载完成');
    } catch (e, stackTrace) {
      log('❌ 加载旅行历史数据失败: $e');
      log('📍 堆栈: $stackTrace');
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
      await _loadConfirmedTrips(reset: true);

      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.success(l10n.syncCompleted);
    } catch (e) {
      log('❌ 同步失败: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.error(l10n.syncFailed);
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
      confirmedTotalCount.value += 1;
      _syncPendingPagination();
      hasMoreConfirmed.value = confirmedTrips.length < confirmedTotalCount.value;

      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.success(l10n.travelSaved);

      log('✅ 旅行已确认: ${trip.displayName}');

      // 异步同步到后端，同步完成后再通知刷新统计数据
      _syncService.confirmAndSync(confirmedTrip).then((synced) {
        if (synced) {
          log('✅ 旅行已同步到后端: ${trip.displayName}');
          _loadConfirmedTrips(reset: true);
        } else {
          log('⚠️ 旅行未能同步到后端，将在下次同步时重试: ${trip.displayName}');
        }
        // 无论同步是否成功，都通知刷新统计数据
        // 同步成功时后端有最新数据；失败时至少触发一次刷新尝试
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'travel_history',
          entityId: trip.id?.toString(),
          version: 1,
          changeType: DataChangeType.created,
        ));
      });
    } catch (e) {
      log('❌ 确认旅行失败: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.error(l10n.saveFailed);
    }
  }

  /// 忽略旅行
  Future<void> dismissTrip(CandidateTrip trip) async {
    if (trip.id == null) return;

    try {
      await _detectionService.dismissTrip(trip.id!);
      pendingTrips.removeWhere((t) => t.id == trip.id);
      _syncPendingPagination();

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
        final l10n = AppLocalizations.of(Get.context!)!;
        AppToast.error(l10n.locationUnavailable);
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

      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.success(l10n.homeLocationSet);

      log('🏠 常住地已设置');
    } catch (e) {
      log('❌ 设置常住地失败: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.error(l10n.setHomeFailed);
    } finally {
      isLoading.value = false;
    }
  }

  /// 删除旅行历史
  Future<void> deleteTripHistory(CandidateTrip trip) async {
    // TODO: 实现删除功能
    confirmedTrips.removeWhere((t) => t.id == trip.id);
    confirmedTotalCount.value = (confirmedTotalCount.value - 1).clamp(0, 1 << 31);
    hasMoreConfirmed.value = confirmedTrips.length < confirmedTotalCount.value;

    // 通知其他组件旅行历史已变更
    DataEventBus.instance.emit(DataChangedEvent(
      entityType: 'travel_history',
      entityId: trip.id?.toString(),
      version: 1,
      changeType: DataChangeType.deleted,
    ));
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    final l10n = AppLocalizations.of(Get.context!)!;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.confirmClear),
        content: Text(l10n.clearAllDataWarning),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) {
                Get.back(result: false);
              }
            },
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) {
                Get.back(result: true);
              }
            },
            child: Text(
              l10n.clear,
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
      _syncPendingPagination();
      confirmedTotalCount.value = 0;
      hasMoreConfirmed.value = false;
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

  Future<void> loadMorePendingTrips() async {
    if (isLoadingMorePending.value || !hasMorePending.value) {
      return;
    }

    isLoadingMorePending.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    visiblePendingCount.value = (visiblePendingCount.value + _pageSize).clamp(0, pendingTrips.length);
    hasMorePending.value = visiblePendingCount.value < pendingTrips.length;
    isLoadingMorePending.value = false;
  }

  Future<void> loadMoreConfirmedTrips() async {
    if (isLoadingMoreConfirmed.value || !hasMoreConfirmed.value) {
      return;
    }

    await _loadConfirmedTrips(reset: false);
  }

  void _resetPendingPagination() {
    visiblePendingCount.value = pendingTrips.length < _pageSize ? pendingTrips.length : _pageSize;
    hasMorePending.value = visiblePendingCount.value < pendingTrips.length;
  }

  void _syncPendingPagination() {
    if (pendingTrips.isEmpty) {
      visiblePendingCount.value = 0;
      hasMorePending.value = false;
      return;
    }

    if (visiblePendingCount.value == 0) {
      visiblePendingCount.value = pendingTrips.length < _pageSize ? pendingTrips.length : _pageSize;
    } else if (visiblePendingCount.value > pendingTrips.length) {
      visiblePendingCount.value = pendingTrips.length;
    }

    hasMorePending.value = visiblePendingCount.value < pendingTrips.length;
  }

  Future<void> _loadConfirmedTrips({required bool reset}) async {
    if (reset) {
      _confirmedCurrentPage = 1;
      hasMoreConfirmed.value = true;
    }

    isLoadingMoreConfirmed.value = !reset;

    try {
      final result = await _syncService.fetchTravelHistoryPage(
        page: _confirmedCurrentPage,
        pageSize: _pageSize,
        isConfirmed: true,
      );

      if (reset) {
        confirmedTrips.assignAll(result.items);
      } else {
        confirmedTrips.addAll(
          result.items.where((item) => confirmedTrips.every((existing) => !_isSameConfirmedTrip(existing, item))),
        );
      }

      confirmedTotalCount.value = result.totalCount;
      hasMoreConfirmed.value = result.hasMore;
      if (result.items.isNotEmpty) {
        _confirmedCurrentPage = result.page + 1;
      }

      if (reset && result.items.isEmpty && result.totalCount == 0) {
        final localConfirmedTrips = await _detectionService.getConfirmedTrips();
        confirmedTrips.assignAll(localConfirmedTrips);
        confirmedTotalCount.value = localConfirmedTrips.length;
        hasMoreConfirmed.value = false;
      }
    } catch (e) {
      log('❌ 加载已确认旅行历史分页失败: $e');
      if (reset) {
        final localConfirmedTrips = await _detectionService.getConfirmedTrips();
        confirmedTrips.assignAll(localConfirmedTrips);
        confirmedTotalCount.value = localConfirmedTrips.length;
        hasMoreConfirmed.value = false;
      }
    } finally {
      isLoadingMoreConfirmed.value = false;
    }
  }

  bool _isSameConfirmedTrip(CandidateTrip left, CandidateTrip right) {
    if (left.backendId != null && right.backendId != null) {
      return left.backendId == right.backendId;
    }

    return left.cityName == right.cityName && left.arrivalTime == right.arrivalTime;
  }
}
