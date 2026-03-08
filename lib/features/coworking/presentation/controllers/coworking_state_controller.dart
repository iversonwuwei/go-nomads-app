import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/coworking/application/use_cases/coworking_use_cases.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/verification_eligibility.dart';
import 'package:go_nomads_app/features/coworking/infrastructure/services/signalr_coworking_service.dart';

/// Coworking State Controller V2
///
/// 使用新的数据同步框架优化版本
///
/// 改进点：
/// 1. 继承 PaginatedRefreshableController，统一分页和刷新逻辑
/// 2. 使用 hybrid 刷新策略：时间过期 + 事件驱动
/// 3. 自动订阅数据变更事件
/// 4. 统一的加载状态管理
/// 5. 保留筛选、排序和 SignalR 实时更新功能
class CoworkingStateController extends PaginatedRefreshableController {
  // ==================== Dependencies ====================
  final GetCoworkingSpacesByCityUseCase _getCoworkingSpacesByCityUseCase;
  final GetCoworkingByIdUseCase _getCoworkingByIdUseCase;
  final GetCityCoworkingCountUseCase _getCityCoworkingCountUseCase;
  final SubmitCoworkingVerificationUseCase _submitCoworkingVerificationUseCase;
  final CheckVerificationEligibilityUseCase _checkVerificationEligibilityUseCase;

  CoworkingStateController({
    required GetCoworkingSpacesByCityUseCase getCoworkingSpacesByCityUseCase,
    required GetCoworkingByIdUseCase getCoworkingByIdUseCase,
    required GetCityCoworkingCountUseCase getCityCoworkingCountUseCase,
    required SubmitCoworkingVerificationUseCase submitCoworkingVerificationUseCase,
    required CheckVerificationEligibilityUseCase checkVerificationEligibilityUseCase,
  })  : _getCoworkingSpacesByCityUseCase = getCoworkingSpacesByCityUseCase,
        _getCoworkingByIdUseCase = getCoworkingByIdUseCase,
        _getCityCoworkingCountUseCase = getCityCoworkingCountUseCase,
        _submitCoworkingVerificationUseCase = submitCoworkingVerificationUseCase,
        _checkVerificationEligibilityUseCase = checkVerificationEligibilityUseCase;

  // ==================== 继承配置 ====================

  @override
  String get entityType => 'coworking_list';

  @override
  RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;

  @override
  Duration? get customCacheDuration => const Duration(minutes: 3);

  @override
  int get pageSize => 20;

  // ==================== SignalR 服务 ====================
  SignalRCoworkingService? _signalRService;
  StreamSubscription<VerificationVotesUpdate>? _votesSubscription;
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  // ==================== 状态管理 ====================

  /// Coworking 空间列表
  final RxList<CoworkingSpace> coworkingSpaces = <CoworkingSpace>[].obs;

  /// 筛选后的空间列表
  final RxList<CoworkingSpace> filteredSpaces = <CoworkingSpace>[].obs;

  /// 选中的筛选条件
  final RxList<String> selectedFilters = <String>[].obs;

  /// 当前选中的 Coworking 空间（详情）
  final Rx<CoworkingSpace?> currentCoworking = Rx<CoworkingSpace?>(null);

  /// 详情加载状态
  final RxBool isLoadingDetail = false.obs;

  /// Coworking 数量
  final RxInt coworkingCount = 0.obs;

  /// 当前城市ID
  final RxString currentCityId = ''.obs;

  /// 正在验证中的 Coworking ID 集合
  final RxSet<String> verifyingCoworkingIds = <String>{}.obs;

  /// 实时验证人数缓存
  final RxMap<String, int> realtimeVerificationVotes = <String, int>{}.obs;

  // ==================== 兼容性属性 ====================

  /// 兼容旧页面的加载状态
  RxBool get isLoadingSpaces => isLoading;
  bool get hasMoreData => hasMore.value;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
  }

  @override
  void onClose() {
    _votesSubscription?.cancel();
    _signalRService?.disconnect();
    _dataChangedSubscription?.cancel();

    // 清空状态
    coworkingSpaces.clear();
    filteredSpaces.clear();
    selectedFilters.clear();
    currentCoworking.value = null;
    coworkingCount.value = 0;
    realtimeVerificationVotes.clear();
    verifyingCoworkingIds.clear();
    currentCityId.value = '';

    super.onClose();
  }

  // ==================== 数据加载实现 ====================

  @override
  Future<PaginatedResult> loadPageData(int page, int pageSize) async {
    // 如果城市ID为空，返回空结果（避免自动刷新时抛出异常）
    if (currentCityId.value.isEmpty) {
      log('⏭️ Coworking 加载跳过: 城市ID未设置');
      return PaginatedResult(items: [], totalCount: 0, hasMore: false);
    }

    log('🏢 加载 Coworking 列表: 城市=${currentCityId.value}, 页码=$page');

    final result = await _getCoworkingSpacesByCityUseCase.execute(
      GetCoworkingSpacesByCityParams(
        cityId: currentCityId.value,
        page: page,
        pageSize: pageSize,
      ),
    );

    return result.fold(
      onSuccess: (spaces) {
        log('✅ 成功加载 ${spaces.length} 个 Coworking 空间');
        return PaginatedResult(
          items: spaces,
          totalCount: spaces.length,
          hasMore: spaces.length >= pageSize,
        );
      },
      onFailure: (exception) {
        log('❌ 加载 Coworking 失败: ${exception.message}');
        throw exception;
      },
    );
  }

  @override
  Future<void> onPageLoaded(List<dynamic> items, {required bool isRefresh}) async {
    final spaces = items.cast<CoworkingSpace>();

    if (isRefresh) {
      coworkingSpaces.clear();
    }

    coworkingSpaces.addAll(spaces);
    _applyFilters();

    // 订阅 SignalR 更新
    await subscribeCoworkingList(spaces);

    log('📊 当前 Coworking 总数: ${coworkingSpaces.length}');
  }

  // ==================== 私有方法 ====================

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('coworking', _handleDataChanged);
    DataEventBus.instance.on('coworking_list', _handleDataChanged);
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    if (event.entityType == 'coworking' || event.entityType == 'coworking_list') {
      log('🔔 收到 Coworking 数据变更通知: ${event.changeType}');

      switch (event.changeType) {
        case DataChangeType.created:
          refresh();
          break;
        case DataChangeType.updated:
          if (event.entityId != null) {
            _refreshSingleCoworking(event.entityId!);
          }
          break;
        case DataChangeType.deleted:
          if (event.entityId != null) {
            coworkingSpaces.removeWhere((s) => s.id == event.entityId);
            filteredSpaces.removeWhere((s) => s.id == event.entityId);
          }
          break;
        case DataChangeType.invalidated:
          refresh();
          break;
      }
    }
  }

  /// 刷新单个 Coworking
  Future<void> _refreshSingleCoworking(String id) async {
    try {
      final result = await _getCoworkingByIdUseCase.execute(
        GetCoworkingByIdParams(id: id),
      );

      result.fold(
        onSuccess: (space) => _replaceCoworking(space),
        onFailure: (e) => log('⚠️ 刷新 Coworking 失败: ${e.message}'),
      );
    } catch (e) {
      log('⚠️ 刷新 Coworking 异常: $e');
    }
  }

  // ==================== SignalR 方法 ====================

  /// 初始化 SignalR 连接
  Future<void> initSignalR() async {
    if (_signalRService != null) return;

    try {
      _signalRService = Get.put(SignalRCoworkingService());
      await _signalRService!.connect();

      _votesSubscription = _signalRService!.onVerificationVotesUpdated.listen(_handleVotesUpdate);
      log('✅ Coworking SignalR 初始化成功');
    } catch (e) {
      log('❌ Coworking SignalR 初始化失败: $e');
    }
  }

  /// 处理验证人数更新
  void _handleVotesUpdate(VerificationVotesUpdate update) {
    log('📊 收到验证人数更新: ${update.coworkingId} -> ${update.verificationVotes}');

    realtimeVerificationVotes[update.coworkingId] = update.verificationVotes;

    // 更新列表中的数据
    final listIndex = coworkingSpaces.indexWhere((s) => s.id == update.coworkingId);
    if (listIndex != -1) {
      coworkingSpaces[listIndex] = coworkingSpaces[listIndex].copyWith(
        verificationVotes: update.verificationVotes,
        isVerified: update.isVerified,
      );
      coworkingSpaces.refresh(); // 触发 Obx 更新
    }

    // 更新筛选列表
    final filteredIndex = filteredSpaces.indexWhere((s) => s.id == update.coworkingId);
    if (filteredIndex != -1) {
      filteredSpaces[filteredIndex] = filteredSpaces[filteredIndex].copyWith(
        verificationVotes: update.verificationVotes,
        isVerified: update.isVerified,
      );
      filteredSpaces.refresh(); // 触发 Obx 更新
    }

    // 更新当前详情
    if (currentCoworking.value?.id == update.coworkingId) {
      currentCoworking.value = currentCoworking.value!.copyWith(
        verificationVotes: update.verificationVotes,
        isVerified: update.isVerified,
      );
    }
  }

  /// 订阅 Coworking 列表的验证人数更新
  Future<void> subscribeCoworkingList(List<CoworkingSpace> spaces) async {
    if (_signalRService == null) {
      await initSignalR();
    }
    final ids = spaces.map((s) => s.id).toList();
    await _signalRService?.subscribeCoworkings(ids);
  }

  /// 订阅单个 Coworking
  Future<void> subscribeCoworking(String coworkingId) async {
    if (_signalRService == null) {
      await initSignalR();
    }
    await _signalRService?.subscribeCoworking(coworkingId);
  }

  /// 取消所有订阅
  Future<void> unsubscribeAll() async {
    await _signalRService?.unsubscribeAll();
  }

  /// 获取实时验证人数
  int getVerificationVotes(CoworkingSpace space) {
    return realtimeVerificationVotes[space.id] ?? space.verificationVotes;
  }

  // ==================== 公共业务方法 ====================

  /// 加载城市的 Coworking 空间列表
  Future<void> loadCoworkingSpacesByCity(
    String cityId, {
    bool refresh = false,
  }) async {
    // 检查是否切换了城市
    final isNewCity = currentCityId.value != cityId;

    // 如果切换了城市，立即清空旧数据并设置加载状态
    if (isNewCity) {
      log('🗑️ 切换城市，清空旧数据: ${currentCityId.value} -> $cityId');
      _clearCoworkingData();
      currentCityId.value = cityId;
      // 立即设置加载状态，避免显示 "无数据"
      isLoading.value = true;
    }

    // 防止重复加载（在设置加载状态之后检查）
    if (!isNewCity && isLoading.value) {
      log('⏸️ Coworking加载中,跳过重复请求');
      return;
    }

    // 如果不是刷新模式,且不是新城市,且已有数据,直接返回缓存
    if (!refresh && !isNewCity && coworkingSpaces.isNotEmpty) {
      log('✅ 使用Coworking缓存数据,跳过请求');
      return;
    }

    try {
      if (refresh || isNewCity) {
        await forceRefresh();
      } else {
        await initialLoad();
      }
    } finally {
      // When switching city we set isLoading manually to avoid flashing empty state.
      // forceRefresh() internally toggles isRefreshing, so we must reset isLoading here.
      if (isNewCity) {
        isLoading.value = false;
      }
    }
  }

  /// 清空 Coworking 数据（切换城市时调用）
  void _clearCoworkingData() {
    coworkingSpaces.clear();
    filteredSpaces.clear();
    realtimeVerificationVotes.clear();
    // 重置分页状态
    currentPage.value = 1;
    hasMore.value = true;
  }

  /// 兼容旧页面的方法名
  Future<void> loadCoworkingsByCity(
    String cityId, {
    String? cityName,
    bool refresh = false,
  }) async {
    await loadCoworkingSpacesByCity(cityId, refresh: refresh);
  }

  /// 加载更多（使用基类方法）
  Future<void> loadMoreCoworkingSpaces() async {
    await loadMore();
  }

  /// 加载 Coworking 空间详情
  Future<void> loadCoworkingDetail(String id) async {
    if (isLoadingDetail.value) return;

    isLoadingDetail.value = true;
    errorMessage.value = '';

    try {
      final result = await _getCoworkingByIdUseCase.execute(
        GetCoworkingByIdParams(id: id),
      );

      result.fold(
        onSuccess: (space) {
          currentCoworking.value = space;
          log('✅ 成功加载 Coworking 详情: ${space.name}');
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
          log('❌ 加载 Coworking 详情失败: ${exception.message}');
        },
      );
    } catch (e) {
      errorMessage.value = '加载详情失败: $e';
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// 加载城市的 Coworking 数量
  Future<void> loadCityCoworkingCount(String cityId) async {
    try {
      final result = await _getCityCoworkingCountUseCase.execute(
        GetCityCoworkingCountParams(cityId: cityId),
      );

      result.fold(
        onSuccess: (count) => coworkingCount.value = count,
        onFailure: (_) => coworkingCount.value = 0,
      );
    } catch (e) {
      coworkingCount.value = 0;
    }
  }

  /// 更新列表中的单个 Coworking（用于缓存同步）
  void updateCoworkingInList(CoworkingSpace updatedSpace) {
    _replaceCoworking(updatedSpace);
  }

  void _replaceCoworking(CoworkingSpace updated) {
    final listIndex = coworkingSpaces.indexWhere((s) => s.id == updated.id);
    if (listIndex != -1) {
      coworkingSpaces[listIndex] = updated;
    }

    final filteredIndex = filteredSpaces.indexWhere((s) => s.id == updated.id);
    if (filteredIndex != -1) {
      filteredSpaces[filteredIndex] = updated;
    }

    if (currentCoworking.value?.id == updated.id) {
      currentCoworking.value = updated;
    }

    // 强制刷新列表，确保 UI 更新
    coworkingSpaces.refresh();
    filteredSpaces.refresh();

    _applyFilters();
  }

  // ==================== 筛选和排序 ====================

  /// 切换筛选条件
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    _applyFilters();
  }

  /// 清空筛选条件
  void clearFilters() {
    selectedFilters.clear();
    _applyFilters();
  }

  /// 应用筛选条件
  void _applyFilters() {
    if (selectedFilters.isEmpty) {
      filteredSpaces.assignAll(coworkingSpaces);
    } else {
      filteredSpaces.assignAll(
        coworkingSpaces.where((space) {
          for (final filter in selectedFilters) {
            switch (filter) {
              case 'WiFi':
                if (!space.amenities.hasWifi) return false;
                break;
              case '24/7':
                if (!space.amenities.has24HourAccess) return false;
                break;
              case 'Meeting Rooms':
              case '会议室':
                if (!space.amenities.hasMeetingRoom) return false;
                break;
              case 'Coffee':
                if (!space.amenities.hasCoffee) return false;
                break;
              default:
                final amenities = space.amenities.getAvailableAmenities();
                if (!amenities.any(
                  (amenity) => amenity.toLowerCase() == filter.toLowerCase(),
                )) {
                  return false;
                }
            }
          }
          return true;
        }),
      );
    }
  }

  /// 按评分排序
  void sortByRating() {
    final list = List<CoworkingSpace>.from(filteredSpaces);
    list.sort((a, b) => b.spaceInfo.rating.compareTo(a.spaceInfo.rating));
    filteredSpaces.assignAll(list);
  }

  /// 按价格排序
  void sortByPrice() {
    final list = List<CoworkingSpace>.from(filteredSpaces);
    list.sort((a, b) {
      final aPrice = a.lowestPrice == 0 ? double.infinity : a.lowestPrice;
      final bPrice = b.lowestPrice == 0 ? double.infinity : b.lowestPrice;
      return aPrice.compareTo(bPrice);
    });
    filteredSpaces.assignAll(list);
  }

  /// 按距离排序
  void sortByDistance() {
    // TODO: 实现距离排序,需要获取用户当前位置
  }

  // ==================== 验证功能 ====================

  /// 检查用户是否有资格验证
  Future<Result<VerificationEligibility>> checkVerificationEligibility(String coworkingId) async {
    if (coworkingId.isEmpty) {
      return Result.failure(
        ValidationException('Coworking 空间ID不能为空', code: 'INVALID_ID'),
      );
    }

    return _checkVerificationEligibilityUseCase.execute(
      CheckVerificationEligibilityParams(coworkingId: coworkingId),
    );
  }

  /// 提交 Coworking 认证
  Future<Result<CoworkingSpace>> submitVerification(String coworkingId) async {
    if (coworkingId.isEmpty) {
      return Result.failure(
        ValidationException('Coworking 空间ID不能为空', code: 'INVALID_ID'),
      );
    }

    if (verifyingCoworkingIds.contains(coworkingId)) {
      return Result.failure(
        ValidationException('正在提交认证，请稍候', code: 'VERIFYING'),
      );
    }

    verifyingCoworkingIds.add(coworkingId);
    errorMessage.value = '';

    try {
      final result = await _submitCoworkingVerificationUseCase.execute(
        SubmitCoworkingVerificationParams(coworkingId: coworkingId),
      );

      result.fold(
        onSuccess: (space) {
          _replaceCoworking(space);

          // 通知其他组件验证状态变更
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'coworking_verification',
            entityId: coworkingId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.updated,
          ));
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
        },
      );

      return result;
    } finally {
      verifyingCoworkingIds.remove(coworkingId);
    }
  }

  /// 清空数据
  void clearCoworkingData() {
    coworkingSpaces.clear();
    filteredSpaces.clear();
    selectedFilters.clear();
    currentCoworking.value = null;
    coworkingCount.value = 0;
    errorMessage.value = '';
    verifyingCoworkingIds.clear();
    realtimeVerificationVotes.clear();
    currentCityId.value = '';
  }
}
