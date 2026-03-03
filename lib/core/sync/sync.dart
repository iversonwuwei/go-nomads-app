/// 数据同步模块
///
/// 提供统一的数据同步、缓存管理和实时更新能力
///
/// 主要组件:
/// - [DataSyncService]: 数据版本管理和缓存控制
/// - [DataEventBus]: 事件总线，用于组件间通信
/// - [DataCacheManager]: 内存缓存管理
/// - [RefreshableController]: 可刷新控制器基类
/// - [DataSyncSignalRService]: 实时同步服务
///
/// 使用示例:
/// ```dart
/// // 1. 创建可刷新控制器
/// class MyCityController extends PaginatedRefreshableController {
///   @override
///   String get entityType => 'city_list';
///
///   @override
///   RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;
///
///   final RxList<City> cities = <City>[].obs;
///
///   @override
///   Future<PaginatedResult> loadPageData(int page, int pageSize) async {
///     final result = await repository.getCities(page, pageSize);
///     return PaginatedResult(
///       items: result.items,
///       totalCount: result.totalCount,
///       hasMore: result.hasMore,
///     );
///   }
///
///   @override
///   Future<void> onPageLoaded(List<dynamic> items, {required bool isRefresh}) async {
///     if (isRefresh) {
///       cities.clear();
///     }
///     cities.addAll(items.cast<City>());
///   }
/// }
///
/// // 2. 使用缓存
/// final cache = DataCacheManager.instance;
/// final cities = await cache.getOrLoad(
///   'city_list',
///   loader: () => repository.getCities(),
///   ttl: Duration(minutes: 5),
///   policy: CachePolicy.cacheFirst,
/// );
///
/// // 3. 监听数据变更
/// DataEventBus.instance.on('city', (event) {
///   if (event.changeType == DataChangeType.updated) {
///     controller.refresh();
///   }
/// });
///
/// // 4. 使缓存失效
/// DataSyncService.instance.invalidateCache('city_list');
/// ```
library;

export 'data_sync_service.dart';
export 'data_cache_manager.dart';
export 'refreshable_controller.dart';
export 'data_sync_signalr_service.dart';
