# Flutter 数据刷新与同步优化方案

## 一、背景问题

现有系统存在以下数据同步问题：

1. **页面刷新机制不统一** - 每个页面都有自己的刷新逻辑，缺乏统一标准
2. **缓存导致数据滞后** - 虽然缓存提升了性能，但导致用户看到过期数据
3. **跨设备数据不同步** - 在一个设备上的操作，其他设备无法实时感知
4. **组件间数据不一致** - 同一数据在不同页面可能显示不同版本

## 二、解决方案架构

### 核心组件

```
┌─────────────────────────────────────────────────────────────────┐
│                     Application Layer                            │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ RefreshableCtrl  │  │ PaginatedCtrl    │  │ DetailCtrl    │ │
│  │ (列表控制器基类)  │  │ (分页控制器基类)  │  │ (详情控制器) │ │
│  └────────┬─────────┘  └────────┬─────────┘  └───────┬───────┘ │
└───────────┼─────────────────────┼─────────────────────┼─────────┘
            │                     │                     │
            ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Sync Layer                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ DataSyncService  │──│ DataCacheManager │──│ DataEventBus  │ │
│  │ (数据版本管理)    │  │ (内存缓存管理)    │  │ (事件总线)   │ │
│  └────────┬─────────┘  └──────────────────┘  └───────────────┘ │
│           │                                                      │
│  ┌────────▼─────────┐                                           │
│  │ DataSyncSignalR  │ ◄─── 实时推送 ◄─── 后端 SignalR Hub       │
│  │ (实时同步服务)    │                                           │
│  └──────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
```

### 刷新策略

| 策略 | 描述 | 适用场景 |
|------|------|----------|
| `manual` | 仅手动刷新 | 静态数据（如系统配置） |
| `timeBasedAuto` | 基于时间自动刷新 | 不常变化的数据 |
| `eventDriven` | 监听事件触发刷新 | 需要实时更新的数据 |
| `hybrid` | 时间 + 事件混合 | 大多数业务数据（推荐） |
| `alwaysFresh` | 总是请求最新 | 关键业务数据 |

## 三、使用指南

### 1. 基础用法：创建可刷新控制器

```dart
import 'package:df_admin_mobile/core/sync/sync.dart';

class CityListController extends PaginatedRefreshableController {
  // 实体类型标识
  @override
  String get entityType => 'city_list';
  
  // 刷新策略（混合模式：时间过期 + 事件触发）
  @override
  RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;
  
  // 自定义缓存有效期（可选）
  @override
  Duration? get customCacheDuration => const Duration(minutes: 3);
  
  // 数据存储
  final RxList<City> cities = <City>[].obs;
  
  // 实现分页加载
  @override
  Future<PaginatedResult> loadPageData(int page, int pageSize) async {
    final result = await _repository.getCities(page: page, pageSize: pageSize);
    return PaginatedResult(
      items: result.items,
      totalCount: result.totalCount,
      hasMore: result.items.length >= pageSize,
    );
  }
  
  // 处理加载完成的数据
  @override
  Future<void> onPageLoaded(List<dynamic> items, {required bool isRefresh}) async {
    if (isRefresh) {
      cities.clear();
    }
    cities.addAll(items.cast<City>());
  }
}
```

### 2. 详情页控制器

```dart
class CityDetailController extends DetailRefreshableController<City> {
  @override
  String get entityType => 'city_detail';
  
  @override
  Future<City> loadDetailData(String id) async {
    return await _repository.getCityById(id);
  }
  
  // 使用：加载详情
  // await controller.loadDetail(cityId);
  // 
  // 强制刷新
  // await controller.loadDetail(cityId, forceRefresh: true);
}
```

### 3. 页面中使用

```dart
class CityListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityListController>();
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.forceRefresh, // 下拉刷新
        child: Obx(() {
          // 根据加载状态显示不同 UI
          switch (controller.loadState.value) {
            case LoadState.loading:
              return const LoadingWidget();
            case LoadState.error:
              return ErrorWidget(
                message: controller.errorMessage.value,
                onRetry: controller.refresh,
              );
            case LoadState.loaded:
              return _buildList(controller);
            default:
              return const SizedBox();
          }
        }),
      ),
    );
  }
  
  Widget _buildList(CityListController controller) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 滚动到底部加载更多
        if (notification.metrics.pixels >= 
            notification.metrics.maxScrollExtent - 200) {
          controller.loadMore();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: controller.cities.length + 
                  (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.cities.length) {
            return const LoadingMoreWidget();
          }
          return CityCard(city: controller.cities[index]);
        },
      ),
    );
  }
}
```

### 4. 使用缓存管理器

```dart
final cache = DataCacheManager.instance;

// 缓存优先策略
final cities = await cache.getOrLoad<List<City>>(
  'city_list',
  loader: () => repository.getCities(),
  ttl: const Duration(minutes: 5),
  policy: CachePolicy.cacheFirst,
);

// 网络优先策略（先请求网络，失败时使用缓存）
final freshData = await cache.getOrLoad<City>(
  'city:$cityId',
  loader: () => repository.getCityById(cityId),
  policy: CachePolicy.networkFirst,
);

// Stale-While-Revalidate（先返回缓存，后台更新）
final data = await cache.getOrLoad<City>(
  'city:$cityId',
  loader: () => repository.getCityById(cityId),
  policy: CachePolicy.staleWhileRevalidate,
);
```

### 5. 使缓存失效

```dart
// 单个实体
DataSyncService.instance.invalidateCache('city_detail', entityId: cityId);

// 整个列表
DataSyncService.instance.invalidateCache('city_list');

// 相关联的所有数据
DataSyncService.instance.invalidateRelated('city');
```

### 6. 监听数据变更

```dart
class MyController extends GetxController {
  StreamSubscription? _subscription;
  
  @override
  void onInit() {
    super.onInit();
    
    // 监听城市数据变更
    _subscription = DataEventBus.instance.on('city', (event) {
      if (event.changeType == DataChangeType.updated) {
        // 数据已更新，刷新列表
        refresh();
      }
    });
  }
  
  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
```

### 7. 数据操作后通知

```dart
// 创建/更新数据后，通知其他组件
Future<void> createCity(City city) async {
  await repository.create(city);
  
  // 使列表缓存失效
  DataSyncService.instance.invalidateCache('city_list');
  
  // 发送事件通知
  DataEventBus.instance.emit(DataChangedEvent(
    entityType: 'city',
    entityId: city.id,
    version: 1,
    changeType: DataChangeType.created,
  ));
}
```

## 四、最佳实践

### 缓存时间建议

| 数据类型 | 建议缓存时间 | 原因 |
|---------|------------|------|
| 城市列表 | 5 分钟 | 数据相对稳定 |
| 城市详情 | 3 分钟 | 用户可能频繁切换 |
| 用户资料 | 10 分钟 | 自己的数据不常变 |
| 收藏列表 | 2 分钟 | 操作较频繁 |
| 通知列表 | 1 分钟 | 实时性要求高 |
| 天气数据 | 15 分钟 | API 限制 + 数据稳定 |

### 刷新时机

1. **页面进入时**
   ```dart
   @override
   void onInit() {
     super.onInit();
     initialLoad(); // 自动检查缓存，过期则刷新
   }
   ```

2. **下拉刷新**
   ```dart
   RefreshIndicator(
     onRefresh: controller.forceRefresh, // 强制刷新，忽略缓存
     child: ...
   )
   ```

3. **数据操作后**
   ```dart
   // 操作成功后使缓存失效
   await repository.updateCity(city);
   DataSyncService.instance.invalidateCache('city_list');
   DataSyncService.instance.invalidateCache('city_detail', entityId: city.id);
   ```

4. **从后台恢复**
   ```dart
   // 在 App 生命周期监听中
   @override
   void didChangeAppLifecycleState(AppLifecycleState state) {
     if (state == AppLifecycleState.resumed) {
       // 检查并刷新关键数据
       DataSyncService.instance.refreshIfStale('user_profile', 
         refreshAction: () => userController.loadCurrentUser(),
       );
     }
   }
   ```

### 性能优化

1. **避免重复请求**
   - 控制器内置防重复机制
   - 同一时间只允许一个加载请求

2. **智能分页**
   - 使用 `PaginatedRefreshableController`
   - 自动管理分页状态和加载更多

3. **批量操作**
   ```dart
   // 批量使缓存失效
   DataSyncService.instance.invalidateCaches([
     'city_list',
     'coworking_list',
     'favorites',
   ]);
   ```

## 五、跨设备同步

### 启用实时同步

```dart
// 在用户登录后连接
await DataSyncSignalRService.instance.connect(userId: currentUser.id);

// 订阅关注的实体
await DataSyncSignalRService.instance.subscribeEntity('city');
await DataSyncSignalRService.instance.subscribeEntity('coworking');
```

### 广播数据变更

```dart
// 当前设备更新数据后，通知其他设备
await DataSyncSignalRService.instance.broadcastChange(
  'city',
  entityId: cityId,
  changeType: 'updated',
  payload: {'name': 'New Name'},
);
```

## 六、迁移指南

### 从旧代码迁移

**旧代码：**
```dart
class OldCityController extends GetxController {
  final RxList<City> cities = <City>[].obs;
  final RxBool isLoading = false.obs;
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  Future<void> loadCities() async {
    if (isLoading.value) return;
    isLoading.value = true;
    
    try {
      final result = await repository.getCities(page: _currentPage);
      cities.value = result;
      _hasMoreData = result.length >= 20;
    } finally {
      isLoading.value = false;
    }
  }
}
```

**新代码：**
```dart
class NewCityController extends PaginatedRefreshableController {
  @override
  String get entityType => 'city_list';
  
  @override
  RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;
  
  final RxList<City> cities = <City>[].obs;
  
  @override
  Future<PaginatedResult> loadPageData(int page, int pageSize) async {
    final result = await repository.getCities(page: page, pageSize: pageSize);
    return PaginatedResult.fromItems(result, pageSize: pageSize);
  }
  
  @override
  Future<void> onPageLoaded(List<dynamic> items, {required bool isRefresh}) async {
    if (isRefresh) cities.clear();
    cities.addAll(items.cast<City>());
  }
}
```

## 七、常见问题

### Q1: 如何处理离线场景？
使用 `CachePolicy.networkFirst`，网络失败时自动回退到缓存。

### Q2: 如何强制获取最新数据？
调用 `controller.forceRefresh()` 或设置 `refreshStrategy: RefreshStrategy.alwaysFresh`

### Q3: 如何清空所有缓存？
```dart
DataCacheManager.instance.clear();
DataSyncService.instance.clearAll();
```

### Q4: 如何调试缓存状态？
```dart
// 获取缓存统计
final stats = DataCacheManager.instance.getStats();
print('缓存条目: ${stats['totalEntries']}');

// 获取同步状态
final syncSummary = DataSyncService.instance.getSyncSummary();
print('过期实体: ${syncSummary['staleEntities']}');
```
