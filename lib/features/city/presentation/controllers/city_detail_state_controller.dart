import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/city/application/use_cases/city_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller_v2.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// 城市详情状态控制器 (Presentation Layer)
///
/// 负责管理城市详情的 UI 状态,通过 Use Cases 操作
///
/// 注意: 该控制器仅管理 City 基本信息和收藏状态
/// Weather, UserCityContent, Coworking 等使用独立的控制器/服务管理
class CityDetailStateController extends GetxController {
  // ==================== Dependencies ====================
  final GetCityByIdUseCase _getCityByIdUseCase;
  final ToggleCityFavoriteUseCase _toggleCityFavoriteUseCase;

  // ==================== Subscriptions ====================
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;
  StreamSubscription<DataChangedEvent>? _favoriteChangedSubscription;

  CityDetailStateController({
    required GetCityByIdUseCase getCityByIdUseCase,
    required ToggleCityFavoriteUseCase toggleCityFavoriteUseCase,
  })  : _getCityByIdUseCase = getCityByIdUseCase,
        _toggleCityFavoriteUseCase = toggleCityFavoriteUseCase;

  // ==================== State ====================

  // 城市数据
  final Rx<City?> currentCity = Rx<City?>(null);

  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  // 收藏状态
  final RxBool isFavorited = false.obs;
  final RxBool isTogglingFavorite = false.obs;

  // Tab 索引
  final RxInt currentTabIndex = 0.obs;

  // 缓存上一次加载的城市ID,避免重复加载
  String _lastLoadedCityId = '';

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    // 监听城市数据变更
    _dataChangedSubscription = DataEventBus.instance.on('city', _handleDataChanged);

    // 监听收藏状态变更（来自列表页面的变更）
    _favoriteChangedSubscription = DataEventBus.instance.on('city_favorite', _handleFavoriteChanged);

    log('✅ [CityDetailStateController] 数据变更监听器已设置');
  }

  /// 处理城市数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 只处理当前城市的变更
    if (currentCity.value == null || event.entityId != currentCity.value!.id) {
      return;
    }

    log('🔔 [城市详情] 收到数据变更通知: ${event.entityId} (${event.changeType})');

    switch (event.changeType) {
      case DataChangeType.updated:
        // 城市数据更新，重新加载详情
        loadCityDetail(event.entityId!, forceRefresh: true);
        break;
      case DataChangeType.deleted:
        // 城市被删除，清空当前数据
        currentCity.value = null;
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        loadCityDetail(event.entityId!, forceRefresh: true);
        break;
      case DataChangeType.created:
        // 新建城市通常不影响详情页
        break;
    }
  }

  /// 处理收藏状态变更事件（来自列表页面）
  void _handleFavoriteChanged(DataChangedEvent event) {
    // 只处理当前城市的收藏变更
    if (currentCity.value == null || event.entityId != currentCity.value!.id) {
      return;
    }

    final isFavorite = event.changeType == DataChangeType.created;

    log('🔔 [城市详情] 收到收藏状态变更: ${event.entityId} -> $isFavorite');

    // 更新本地状态
    isFavorited.value = isFavorite;
    if (currentCity.value != null) {
      currentCity.value = currentCity.value!.copyWith(isFavorite: isFavorite);
    }
  }

  // ==================== Public Methods ====================

  /// 初始化城市详情 (从 cityId 加载完整数据)
  Future<void> initCity(String cityId, String cityName) async {
    // 加载城市详情
    await loadCityDetail(cityId);
  }

  /// 加载城市详情
  Future<void> loadCityDetail(String cityId, {bool forceRefresh = false}) async {
    if (cityId.isEmpty) {
      return;
    }

    // 如果不是强制刷新且是相同城市且已有数据，尝试同步列表状态后返回
    if (!forceRefresh && cityId == _lastLoadedCityId && currentCity.value != null) {
      // 尝试从列表控制器同步收藏状态
      _syncFavoriteStateFromList(cityId);
      return;
    }

    _lastLoadedCityId = cityId;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;

    final result = await _getCityByIdUseCase.execute(
      GetCityByIdParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (city) {
        currentCity.value = city;
        isFavorited.value = city.isFavorite;
        isLoading.value = false;
        log('✅ [城市详情] 加载成功: ${city.name}, isFavorite: ${city.isFavorite}');
      },
      onFailure: (exception) {
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        AppToast.error(exception.message, title: '加载失败');
      },
    );
  }

  /// 从列表控制器同步收藏状态
  void _syncFavoriteStateFromList(String cityId) {
    try {
      // 尝试获取列表控制器中的最新状态
      final cityListController = Get.find<CityStateControllerV2>();
      final cityInList = cityListController.cities.firstWhereOrNull((c) => c.id == cityId);

      if (cityInList != null && currentCity.value != null) {
        // 如果列表中的收藏状态与详情不一致，同步更新
        if (cityInList.isFavorite != isFavorited.value) {
          log('🔄 [城市详情] 同步列表收藏状态: ${isFavorited.value} -> ${cityInList.isFavorite}');
          isFavorited.value = cityInList.isFavorite;
          currentCity.value = currentCity.value!.copyWith(isFavorite: cityInList.isFavorite);
        }
      }
    } catch (e) {
      // 列表控制器可能不存在，忽略
      log('⚠️ [城市详情] 同步状态失败: $e');
    }
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    if (currentCity.value == null) {
      return;
    }

    final cityId = currentCity.value!.id;

    if (isTogglingFavorite.value) {
      return;
    }

    isTogglingFavorite.value = true;
    final previousState = isFavorited.value;

    // 乐观更新 UI
    isFavorited.value = !previousState;

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (newState) {
        isFavorited.value = newState;

        // 更新 currentCity 的收藏状态
        if (currentCity.value != null) {
          currentCity.value = currentCity.value!.copyWith(isFavorite: newState);
        }

        // 通知其他组件收藏状态变更（如城市列表）
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'city_favorite',
          entityId: cityId,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: newState ? DataChangeType.created : DataChangeType.deleted,
          metadata: {'isFavorite': newState},
        ));
        log('✅ [城市详情] 收藏状态已同步: $cityId -> $newState');

        AppToast.success(
          newState ? '已添加到收藏' : '已取消收藏',
          title: '成功',
        );
        isTogglingFavorite.value = false;
      },
      onFailure: (exception) {
        // 操作失败,恢复之前的状态
        isFavorited.value = previousState;

        AppToast.error(exception.message, title: '操作失败');
        isTogglingFavorite.value = false;
      },
    );
  }

  /// 切换 Tab
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  /// 强制刷新城市详情
  Future<void> reload() async {
    if (currentCity.value != null) {
      await loadCityDetail(currentCity.value!.id);
    }
  }

  // ==================== Computed Properties ====================

  /// 当前城市ID
  String get currentCityId => currentCity.value?.id ?? '';

  /// 当前城市名称
  String get currentCityName => currentCity.value?.nameEn ?? '';

  /// 是否有城市数据
  bool get hasCity => currentCity.value != null;

  /// 是否正在加载
  bool get loading => isLoading.value;

  // ==================== Lifecycle ====================

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    _favoriteChangedSubscription?.cancel();
    _favoriteChangedSubscription = null;

    // 清理所有状态
    currentCity.value = null;
    isLoading.value = false;
    hasError.value = false;
    errorMessage.value = null;
    isFavorited.value = false;
    isTogglingFavorite.value = false;
    currentTabIndex.value = 0;

    // 清理缓存标记
    _lastLoadedCityId = '';

    super.onClose();
  }
}
