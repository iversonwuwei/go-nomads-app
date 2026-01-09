import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/sync/data_sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 数据刷新策略
enum RefreshStrategy {
  /// 首次加载后不自动刷新，需手动刷新
  manual,

  /// 基于时间的自动刷新（数据过期后自动刷新）
  timeBasedAuto,

  /// 事件驱动刷新（监听数据变更事件）
  eventDriven,

  /// 混合模式（时间 + 事件）
  hybrid,

  /// 总是从服务器获取最新数据
  alwaysFresh,
}

/// 数据加载状态
enum LoadState {
  initial, // 初始状态
  loading, // 加载中
  loaded, // 已加载
  refreshing, // 刷新中
  error, // 错误
  empty, // 空数据
}

/// 可刷新 Controller 基类
///
/// 提供统一的数据同步和刷新能力，子类只需关注具体的数据加载逻辑
///
/// 使用方法:
/// ```dart
/// class MyCityController extends RefreshableController {
///   @override
///   String get entityType => 'city_list';
///
///   @override
///   RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;
///
///   @override
///   Future<void> loadData() async {
///     // 实现数据加载逻辑
///   }
/// }
/// ```
abstract class RefreshableController extends GetxController {
  // ==================== 抽象属性 ====================

  /// 实体类型标识（用于版本管理和事件监听）
  String get entityType;

  /// 实体ID（可选，用于单个实体的精确管理）
  String? get entityId => null;

  /// 刷新策略
  RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;

  /// 缓存有效期（覆盖默认值）
  Duration? get customCacheDuration => null;

  // ==================== 状态 ====================

  /// 加载状态
  final Rx<LoadState> loadState = LoadState.initial.obs;

  /// 是否正在加载
  final RxBool isLoading = false.obs;

  /// 是否正在刷新
  final RxBool isRefreshing = false.obs;

  /// 错误信息
  final RxnString errorMessage = RxnString();

  /// 上次加载时间
  final Rxn<DateTime> lastLoadTime = Rxn<DateTime>();

  /// 数据版本
  final RxInt dataVersion = 0.obs;

  // ==================== 内部状态 ====================

  /// 数据同步服务
  DataSyncService get _syncService => DataSyncService.instance;

  /// 事件订阅
  StreamSubscription<DataChangedEvent>? _eventSubscription;

  /// 自动刷新定时器
  Timer? _autoRefreshTimer;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    _initSync();
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  /// 初始化同步
  void _initSync() {
    // 注册版本
    _syncService.registerVersion(entityType, entityId: entityId);

    // 设置自定义缓存时间
    if (customCacheDuration != null) {
      _syncService.setCacheDuration(entityType, customCacheDuration!);
    }

    // 根据策略设置
    switch (refreshStrategy) {
      case RefreshStrategy.eventDriven:
      case RefreshStrategy.hybrid:
        _setupEventListener();
        if (refreshStrategy == RefreshStrategy.hybrid) {
          _setupAutoRefresh();
        }
        break;
      case RefreshStrategy.timeBasedAuto:
        _setupAutoRefresh();
        break;
      case RefreshStrategy.manual:
      case RefreshStrategy.alwaysFresh:
        // 不需要额外设置
        break;
    }

    log('✅ [$runtimeType] 初始化同步完成 (策略: ${refreshStrategy.name})');
  }

  /// 设置事件监听
  void _setupEventListener() {
    _eventSubscription = DataEventBus.instance.on(entityType, (event) {
      log('📬 [$runtimeType] 收到数据变更事件: ${event.changeType.name}');

      if (event.changeType == DataChangeType.invalidated || event.changeType == DataChangeType.updated) {
        // 数据失效或更新，触发刷新
        if (!isRefreshing.value) {
          refresh();
        }
      }
    });
  }

  /// 设置自动刷新定时器
  void _setupAutoRefresh() {
    final duration = customCacheDuration ?? const Duration(minutes: 5);

    // 设置定期检查
    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: duration.inSeconds ~/ 2),
      (_) => _checkAndRefresh(),
    );
  }

  /// 检查并刷新（如果数据过期）
  Future<void> _checkAndRefresh() async {
    if (_syncService.isDataStale(entityType, entityId: entityId)) {
      if (!isLoading.value && !isRefreshing.value) {
        log('⏰ [$runtimeType] 数据过期，触发自动刷新');
        await refresh();
      }
    }
  }

  // ==================== 数据加载方法 ====================

  /// 子类实现的数据加载方法
  @protected
  Future<void> loadData();

  /// 初始加载
  Future<void> initialLoad({bool forceRefresh = false}) async {
    // 如果已有数据且不强制刷新，检查是否需要刷新
    if (!forceRefresh && loadState.value == LoadState.loaded) {
      if (refreshStrategy == RefreshStrategy.alwaysFresh) {
        return refresh();
      }

      if (!_syncService.isDataStale(entityType, entityId: entityId)) {
        log('📦 [$runtimeType] 使用缓存数据');
        return;
      }
    }

    // 防止重复加载
    if (isLoading.value) {
      log('⏭️ [$runtimeType] 跳过重复加载');
      return;
    }

    await _doLoad(isRefresh: false);
  }

  /// 刷新数据
  @override
  Future<void> refresh() async {
    // 防止重复刷新
    if (isRefreshing.value) {
      log('⏭️ [$runtimeType] 跳过重复刷新');
      return;
    }

    await _doLoad(isRefresh: true);
  }

  /// 强制刷新（忽略缓存）
  Future<void> forceRefresh() async {
    _syncService.invalidateCache(entityType, entityId: entityId);
    await refresh();
  }

  /// 执行加载
  Future<void> _doLoad({required bool isRefresh}) async {
    final loadType = isRefresh ? '刷新' : '加载';
    log('🔄 [$runtimeType] 开始$loadType数据...');

    try {
      if (isRefresh) {
        isRefreshing.value = true;
        loadState.value = LoadState.refreshing;
      } else {
        isLoading.value = true;
        loadState.value = LoadState.loading;
      }
      errorMessage.value = null;

      await loadData();

      // 标记数据为新鲜
      _syncService.markAsFresh(entityType, entityId: entityId);
      lastLoadTime.value = DateTime.now();
      dataVersion.value = _syncService.getVersion(entityType, entityId: entityId)?.version ?? 0;

      loadState.value = LoadState.loaded;
      log('✅ [$runtimeType] $loadType完成 (v${dataVersion.value})');
    } catch (e, stackTrace) {
      log('❌ [$runtimeType] $loadType失败: $e');
      if (kDebugMode) {
        log('StackTrace: $stackTrace');
      }

      errorMessage.value = e.toString();
      loadState.value = LoadState.error;

      // 不再 rethrow - 状态已更新，UI 层通过观察 loadState 和 errorMessage 处理错误
      // 这样调用者不需要额外的 try-catch，错误会通过响应式状态传递给 UI
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ==================== 工具方法 ====================

  /// 数据是否过期
  bool get isDataStale => _syncService.isDataStale(entityType, entityId: entityId);

  /// 是否需要加载
  bool get needsLoad => loadState.value == LoadState.initial || isDataStale;

  /// 使相关数据缓存失效
  void invalidateRelatedData(List<String> entityTypes) {
    _syncService.invalidateCaches(entityTypes);
  }

  /// 通知数据已更新（供子类调用）
  @protected
  void notifyDataUpdated({Map<String, dynamic>? metadata}) {
    _syncService.updateVersion(entityType, entityId: entityId);
  }

  /// 发送自定义事件
  @protected
  void emitEvent(DataChangeType changeType, {Map<String, dynamic>? metadata}) {
    DataEventBus.instance.emit(DataChangedEvent(
      entityType: entityType,
      entityId: entityId,
      version: dataVersion.value,
      changeType: changeType,
      metadata: metadata,
    ));
  }
}

/// 带分页的可刷新 Controller
abstract class PaginatedRefreshableController extends RefreshableController {
  // ==================== 分页状态 ====================

  /// 当前页码
  final RxInt currentPage = 1.obs;

  /// 每页大小
  int get pageSize => 20;

  /// 是否有更多数据
  final RxBool hasMore = true.obs;

  /// 是否正在加载更多
  final RxBool isLoadingMore = false.obs;

  /// 总条数
  final RxInt totalCount = 0.obs;

  // ==================== 抽象方法 ====================

  /// 子类实现的分页加载方法
  @protected
  Future<PaginatedResult> loadPageData(int page, int pageSize);

  // ==================== 重写方法 ====================

  @override
  Future<void> loadData() async {
    // 首次加载或刷新时，重置分页状态
    currentPage.value = 1;
    hasMore.value = true;

    final result = await loadPageData(currentPage.value, pageSize);

    totalCount.value = result.totalCount;
    hasMore.value = result.hasMore;

    // 处理数据（子类需要将数据存储到自己的列表中）
    await onPageLoaded(result.items, isRefresh: true);
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) {
      return;
    }

    isLoadingMore.value = true;

    try {
      final nextPage = currentPage.value + 1;
      final result = await loadPageData(nextPage, pageSize);

      currentPage.value = nextPage;
      hasMore.value = result.hasMore;

      await onPageLoaded(result.items, isRefresh: false);

      log('✅ [$runtimeType] 加载更多完成 (第${currentPage.value}页)');
    } catch (e) {
      log('❌ [$runtimeType] 加载更多失败: $e');
      rethrow;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 页面数据加载完成回调
  ///
  /// [items] 加载的数据
  /// [isRefresh] 是否是刷新（true时清空旧数据，false时追加）
  @protected
  Future<void> onPageLoaded(List<dynamic> items, {required bool isRefresh});
}

/// 分页结果
class PaginatedResult {
  final List<dynamic> items;
  final int totalCount;
  final bool hasMore;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.hasMore,
  });

  factory PaginatedResult.fromItems(List<dynamic> items, {int? pageSize}) {
    return PaginatedResult(
      items: items,
      totalCount: items.length,
      hasMore: pageSize != null && items.length >= pageSize,
    );
  }
}

/// 带详情缓存的可刷新 Controller
abstract class DetailRefreshableController<T> extends RefreshableController {
  // ==================== 状态 ====================

  /// 当前详情数据
  final Rxn<T> currentDetail = Rxn<T>();

  /// 缓存的详情数据
  final RxMap<String, T> _detailCache = <String, T>{}.obs;

  /// 当前加载的实体ID
  String? _currentEntityId;

  @override
  String? get entityId => _currentEntityId;

  // ==================== 抽象方法 ====================

  /// 子类实现的详情加载方法
  @protected
  Future<T> loadDetailData(String id);

  // ==================== 方法 ====================

  @override
  Future<void> loadData() async {
    if (_currentEntityId == null) return;

    final detail = await loadDetailData(_currentEntityId!);
    currentDetail.value = detail;
    _detailCache[_currentEntityId!] = detail;
  }

  /// 加载详情
  Future<void> loadDetail(String id, {bool forceRefresh = false}) async {
    _currentEntityId = id;

    // 检查缓存
    if (!forceRefresh && _detailCache.containsKey(id)) {
      if (!_syncService.isDataStale(entityType, entityId: id)) {
        currentDetail.value = _detailCache[id];
        log('📦 [$runtimeType] 使用缓存详情: $id');
        return;
      }
    }

    await initialLoad(forceRefresh: forceRefresh);
  }

  /// 清除详情缓存
  void clearDetailCache({String? id}) {
    if (id != null) {
      _detailCache.remove(id);
    } else {
      _detailCache.clear();
    }
  }

  /// 更新缓存中的详情
  void updateCachedDetail(String id, T detail) {
    _detailCache[id] = detail;
    if (_currentEntityId == id) {
      currentDetail.value = detail;
    }
    _syncService.updateVersion(entityType, entityId: id);
  }
}
