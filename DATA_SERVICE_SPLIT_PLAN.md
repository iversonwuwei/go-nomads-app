# Data Service Controller 域拆分计划

## 📊 文件分析概览

**目标文件**: `lib/controllers/data_service_controller.dart`  
**总行数**: 1205 行  
**复杂度**: ⚠️ 高（多域集成 + 复杂业务逻辑）  
**分析日期**: 2024年

---

## 🔍 1. 完整功能清单

### 1.1 API 服务集成 (3个)
```dart
final LocationApiService _locationApiService = LocationApiService();
final EventsApiService _eventsApiService = EventsApiService();
final CityApiService _cityApiService = CityApiService();
```

### 1.2 状态管理 (25+ 响应式属性)

**加载状态**:
- `isLoading` - 全局加载状态
- `isLoadingCities` - 城市加载状态
- `isLoadingMeetups` - 活动加载状态
- `isLoadingCountries` - 国家加载状态
- `hasError` - 错误标志
- `errorMessage` - 错误消息

**视图偏好**:
- `isGridView` - 网格/列表视图切换
- `sortBy` - 排序方式 (popular, cost, internet, safety)
- `searchQuery` - 搜索关键词

**数据集合**:
- `dataItems` - 城市数据列表
- `countries` - 国家列表 (CountryOption)
- `citiesByCountry` - 按国家分组的城市 (Map<String, List<CityOption>>)
- `cityLoadingStates` - 城市加载状态追踪 (Map<String, bool>)
- `meetups` - 活动列表
- `rsvpedMeetups` - 用户已RSVP的活动ID列表

**筛选条件** (Nomads.com 风格):
- `selectedRegions` - 选中的地区 (Asia, Europe, Americas, Africa, Oceania)
- `selectedCountries` - 选中的国家
- `selectedCities` - 选中的城市
- `minPrice` / `maxPrice` - 价格范围 (0-5000)
- `minInternet` - 最低网速
- `minRating` - 最低评分
- `maxAqi` - 最大空气质量指数 (0-500)
- `selectedClimates` - 气候类型 (Hot, Warm, Mild, Cool, Cold)

**常量**:
- `meetupTypes` - 活动类型列表 (Drinks, Coworking, Dinner, Activity, Workshop, Networking)

### 1.3 核心方法清单 (按域分类)

#### 🌍 **地理位置相关** (Location Domain)
```dart
// 数据获取
List<String> get availableCities          // 获取可用城市列表
List<String> get availableCountries       // 获取可用国家列表
List<String> getCitiesByCountry(String)   // 根据国家获取城市
String getCountryByCity(String)           // 根据城市获取国家

// API 调用
Future<void> loadCountries({forceRefresh})
Future<List<CityOption>> loadCitiesByCountry(String, {forceRefresh})

// 辅助方法
String _guessRegion(String country)       // 根据国家猜测地区
```

#### 🏙️ **城市数据管理** (City Domain - 扩展)
```dart
// 城市数据加载
Future<void> refreshCities()              // 刷新城市列表
Future<void> searchCities(String)         // 搜索城市
Future<void> _loadCitiesFromApi()         // 从 CityApiService 加载

// 数据转换
String _guessClimate(double?)             // 根据温度猜测气候
String _getAqiLevel(int?)                 // 获取 AQI 等级

// 筛选和排序
List<Map<String, dynamic>> get filteredItems  // 应用所有筛选条件
void _sortItems()                         // 按 sortBy 排序
void changeSortBy(String)                 // 更改排序方式
void toggleView()                         // 切换网格/列表视图
void updateSearchQuery(String)            // 更新搜索关键词

// 筛选条件管理
void resetFilters()                       // 重置所有筛选
bool get hasActiveFilters                 // 检查是否有活动筛选
```

#### 🎉 **活动/Meetup 管理** (Events Domain - 新建)
```dart
// 活动数据加载
Future<void> refreshMeetups()             // 刷新活动列表
Future<void> _loadMeetupsFromApi()        // 从 EventsApiService 加载
String _guessMeetupType(String)           // 根据标题猜测活动类型

// 活动交互
void toggleRSVP(int meetupId)             // 切换 RSVP 状态
List<Map<String, dynamic>> get upcomingMeetups  // 获取即将到来的活动
List<Map<String, dynamic>> getMeetupsByCity(String)  // 按城市过滤

// 创建活动
Future<void> createMeetup({              // 创建新活动 (12个参数)
  required String title,
  required String city,
  required String country,
  required String type,
  required String venue,
  required DateTime date,
  required String time,
  required int maxAttendees,
  required String description,
  String? cityId,
  String? countryId,
  String? imageUrl,
  // ... 更多可选参数
})
Future<void> _createMeetupViaAPI(Map)     // 通过 API 创建
EventsApiService _getEventsApiService()   // 获取 API 服务实例
Map<String, dynamic> _convertToEventData(Map)  // 转换数据格式
String _mapTypeToCategory(String)         // 映射活动类型到分类
```

#### 🔄 **生命周期和数据同步**
```dart
@override
void onInit()                             // 初始化控制器
void initializeData()                     // 初始化数据加载
void _setupLoginStateListener()           // 设置登录状态监听器
void _clearData()                         // 清空数据（登出时）
Future<void> refreshAllData()             // 刷新所有数据（登录时）
void refreshData()                        // 刷新数据（公共方法）
```

#### 🔐 **认证相关**
```dart
bool _requireLogin({String? action})      // 检查登录状态
```

#### 🛠️ **辅助工具方法**
```dart
String _formatTime(String?)               // 格式化时间
```

---

## 🎯 2. 域拆分策略

### 2.1 域划分决策

根据业务逻辑分析,需要将功能拆分到以下域:

| 序号 | 域名称 | 状态 | 复杂度 | 优先级 |
|------|--------|------|--------|--------|
| 1 | **Meetup Domain** | ✨ **扩展现有** | ⚠️ 高 | P0 (核心) |
| 2 | **Location Domain** | ✨ **扩展现有** | 🟡 中 | P1 |
| 3 | **City Domain** | ✨ **扩展现有** | ⚠️ 高 | P0 (核心) |

> **注意**: Events Domain = Meetup Domain,不需要创建新域,直接扩展现有的 Meetup Domain 即可

### 2.2 域职责定义

#### 📦 **Events Domain** (新建)
**核心职责**: 活动生命周期管理

**迁移的方法** (11个):
- `refreshMeetups()` → `EventsRepository.getEvents()`
- `_loadMeetupsFromApi()` → 内部实现
- `toggleRSVP()` → `RsvpToEventUseCase` / `CancelRsvpUseCase`
- `upcomingMeetups` (getter) → `EventsStateController`
- `getMeetupsByCity()` → `GetEventsByCityUseCase`
- `createMeetup()` → `CreateEventUseCase`
- `_createMeetupViaAPI()` → 内部实现
- `_getEventsApiService()` → 依赖注入
- `_convertToEventData()` → EventDTO 转换
- `_mapTypeToCategory()` → EventType 值对象
- `_guessMeetupType()` → 辅助方法

**迁移的状态** (3个):
- `meetups` → `EventsStateController.events`
- `rsvpedMeetups` → `EventsStateController.rsvpedEventIds`
- `isLoadingMeetups` → `EventsStateController.isLoading`

**依赖关系**:
- ✅ 独立域，只依赖 EventsApiService
- ⚠️ 需要 UserStateController (认证检查)
- ⚠️ 需要 Location Domain (cityId 查找)

---

#### 📦 **Location Domain** (扩展现有)
**核心职责**: 地理位置数据管理

**迁移的方法** (6个):
- `loadCountries()` → `GetCountriesUseCase`
- `loadCitiesByCountry()` → `GetCitiesByCountryUseCase`
- `availableCountries` (getter) → `LocationStateController`
- `availableCities` (getter) → `LocationStateController`
- `getCitiesByCountry()` → `LocationRepository`
- `getCountryByCity()` → `LocationRepository`
- `_guessRegion()` → LocationHelpers 工具类

**迁移的状态** (4个):
- `countries` → `LocationStateController.countries`
- `citiesByCountry` → `LocationStateController.citiesByCountry`
- `cityLoadingStates` → `LocationStateController.cityLoadingStates`
- `isLoadingCountries` → `LocationStateController.isLoading`

**依赖关系**:
- ✅ 独立域，只依赖 LocationApiService
- 🔗 被 Events Domain 引用 (cityId 查找)

---

#### 📦 **City Domain** (扩展现有)
**核心职责**: 城市数据展示、搜索、筛选

**迁移的方法** (12个):
- `refreshCities()` → `GetCitiesUseCase`
- `searchCities()` → `SearchCitiesUseCase`
- `_loadCitiesFromApi()` → CityRepository 内部实现
- `filteredItems` (getter) → `CityStateController.filteredCities`
- `_sortItems()` → `CityStateController` 内部逻辑
- `changeSortBy()` → `CityStateController.updateSortBy()`
- `toggleView()` → `CityStateController.toggleViewMode()`
- `updateSearchQuery()` → `CityStateController.updateSearchQuery()`
- `resetFilters()` → `CityStateController.resetFilters()`
- `hasActiveFilters` (getter) → `CityStateController.hasActiveFilters`
- `_guessClimate()` → CityHelpers 工具类
- `_getAqiLevel()` → CityHelpers 工具类

**迁移的状态** (16个):
- `dataItems` → `CityStateController.cities`
- `isLoadingCities` → `CityStateController.isLoading`
- `isGridView` → `CityStateController.viewMode`
- `sortBy` → `CityStateController.sortOption`
- `searchQuery` → `CityStateController.searchQuery`
- **筛选条件** (9个):
  - `selectedRegions` → `CityStateController.filterCriteria.regions`
  - `selectedCountries` → `CityStateController.filterCriteria.countries`
  - `selectedCities` → `CityStateController.filterCriteria.cities`
  - `minPrice` / `maxPrice` → `CityStateController.filterCriteria.priceRange`
  - `minInternet` → `CityStateController.filterCriteria.minInternetSpeed`
  - `minRating` → `CityStateController.filterCriteria.minRating`
  - `maxAqi` → `CityStateController.filterCriteria.maxAqi`
  - `selectedClimates` → `CityStateController.filterCriteria.climates`

**依赖关系**:
- ✅ 独立域，只依赖 CityApiService
- 🔗 可选依赖 Location Domain (国家/地区数据)

---

## 🗂️ 3. 新 Events Domain 结构设计

### 3.1 完整目录结构
```
lib/features/events/
├── domain/
│   ├── entities/
│   │   ├── event.dart                    # Event 实体
│   │   ├── event_type.dart               # EventType 值对象
│   │   └── rsvp_status.dart              # RSVP 状态值对象
│   └── repositories/
│       └── i_events_repository.dart      # Events 仓储接口
│
├── infrastructure/
│   ├── models/
│   │   ├── event_dto.dart                # Event DTO
│   │   └── event_mapper.dart             # DTO ↔ Entity 映射
│   └── repositories/
│       └── events_repository.dart        # Events 仓储实现
│
├── application/
│   └── use_cases/
│       ├── get_events_use_case.dart             # 获取活动列表
│       ├── get_events_by_city_use_case.dart     # 按城市获取活动
│       ├── create_event_use_case.dart           # 创建活动
│       ├── rsvp_to_event_use_case.dart          # RSVP 活动
│       └── cancel_rsvp_use_case.dart            # 取消 RSVP
│
└── presentation/
    ├── controllers/
    │   └── events_state_controller.dart  # Events 状态控制器
    └── helpers/
        └── event_helpers.dart            # 辅助方法 (_guessMeetupType)
```

### 3.2 核心类设计

#### Event 实体
```dart
// lib/features/events/domain/entities/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final String cityName;
  final String? cityId;
  final EventType type;
  final String venue;
  final String? address;
  final DateTime startTime;
  final DateTime? endTime;
  final int currentParticipants;
  final int maxParticipants;
  final String organizerName;
  final String? organizerAvatar;
  final String? imageUrl;
  final List<String>? images;
  final double? latitude;
  final double? longitude;
  final List<String>? tags;
  final bool isParticipant;
  final String status; // 'upcoming', 'ongoing', 'completed'
}
```

#### EventType 值对象
```dart
// lib/features/events/domain/entities/event_type.dart
enum EventType {
  drinks,
  coworking,
  dinner,
  activity,
  workshop,
  networking;

  String toDisplayString() {
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }

  String toCategory() {
    switch (this) {
      case EventType.drinks:
      case EventType.dinner:
        return 'social';
      case EventType.coworking:
      case EventType.networking:
        return 'business';
      case EventType.workshop:
        return 'tech';
      case EventType.activity:
      default:
        return 'other';
    }
  }
}
```

#### Events Repository 接口
```dart
// lib/features/events/domain/repositories/i_events_repository.dart
abstract class IEventsRepository {
  Future<List<Event>> getEvents({
    String? status,
    String? cityId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Event> createEvent({
    required String title,
    required String description,
    required String location,
    required String? cityId,
    required EventType type,
    required DateTime startTime,
    DateTime? endTime,
    required int maxParticipants,
    String? address,
    String? imageUrl,
    List<String>? images,
    double? latitude,
    double? longitude,
    List<String>? tags,
  });

  Future<void> rsvpToEvent(String eventId);
  Future<void> cancelRsvp(String eventId);
}
```

#### Events State Controller
```dart
// lib/features/events/presentation/controllers/events_state_controller.dart
class EventsStateController extends GetxController {
  final GetEventsUseCase _getEventsUseCase;
  final CreateEventUseCase _createEventUseCase;
  final RsvpToEventUseCase _rsvpToEventUseCase;
  final CancelRsvpUseCase _cancelRsvpUseCase;

  // State
  final RxList<Event> events = <Event>[].obs;
  final RxList<String> rsvpedEventIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    final nextMonth = now.add(const Duration(days: 30));
    return events.where((event) {
      return event.startTime.isAfter(now) && 
             event.startTime.isBefore(nextMonth);
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> getEventsByCity(String cityName) {
    return upcomingEvents.where((e) => e.cityName == cityName).toList();
  }

  // Methods
  Future<void> loadEvents() async { /* ... */ }
  Future<void> createEvent(Event event) async { /* ... */ }
  Future<void> toggleRsvp(String eventId) async { /* ... */ }
}
```

---

## 🔧 4. Location Domain 扩展计划

### 4.1 新增文件

#### LocationStateController
```dart
// lib/features/location/presentation/controllers/location_state_controller.dart
class LocationStateController extends GetxController {
  final GetCountriesUseCase _getCountriesUseCase;
  final GetCitiesByCountryUseCase _getCitiesByCountryUseCase;

  // State
  final RxList<Country> countries = <Country>[].obs;
  final RxMap<String, List<City>> citiesByCountry = <String, List<City>>{}.obs;
  final RxMap<String, bool> cityLoadingStates = <String, bool>{}.obs;
  final RxBool isLoadingCountries = false.obs;

  // Getters
  List<String> get availableCountries {
    return countries
        .where((c) => c.isActive)
        .map((c) => c.name)
        .toList()..sort();
  }

  List<String> get availableCities {
    return citiesByCountry.values
        .expand((list) => list)
        .map((city) => city.name)
        .toSet()
        .toList()..sort();
  }

  List<String> getCitiesByCountry(String countryId) { /* ... */ }
  String getCountryByCity(String cityName) { /* ... */ }

  // Methods
  Future<void> loadCountries({bool forceRefresh = false}) async { /* ... */ }
  Future<List<City>> loadCitiesByCountry(String countryId, {bool forceRefresh = false}) async { /* ... */ }
}
```

---

## 🏙️ 5. City Domain 扩展计划

### 5.1 新增实体和值对象

#### FilterCriteria 值对象
```dart
// lib/features/city/domain/entities/filter_criteria.dart
class FilterCriteria {
  final List<String> regions;
  final List<String> countries;
  final List<String> cities;
  final PriceRange priceRange;
  final double minInternetSpeed;
  final double minRating;
  final int maxAqi;
  final List<String> climates;

  bool get hasActiveFilters {
    return regions.isNotEmpty ||
           countries.isNotEmpty ||
           cities.isNotEmpty ||
           priceRange.min > 0 ||
           priceRange.max < 5000 ||
           minInternetSpeed > 0 ||
           minRating > 0 ||
           maxAqi < 500 ||
           climates.isNotEmpty;
  }

  FilterCriteria reset() {
    return FilterCriteria(
      regions: [],
      countries: [],
      cities: [],
      priceRange: PriceRange(min: 0, max: 5000),
      minInternetSpeed: 0,
      minRating: 0,
      maxAqi: 500,
      climates: [],
    );
  }
}
```

#### SortOption 枚举
```dart
// lib/features/city/domain/entities/sort_option.dart
enum SortOption {
  popular('popular'),
  cost('cost'),
  internet('internet'),
  safety('safety');

  final String value;
  const SortOption(this.value);
}
```

### 5.2 扩展 CityStateController
```dart
// lib/features/city/presentation/controllers/city_state_controller.dart
class CityStateController extends GetxController {
  // 新增状态
  final Rx<ViewMode> viewMode = ViewMode.grid.obs;
  final Rx<SortOption> sortOption = SortOption.popular.obs;
  final RxString searchQuery = ''.obs;
  final Rx<FilterCriteria> filterCriteria = FilterCriteria.empty().obs;

  // 新增 Getters
  List<City> get filteredCities {
    var items = cities.toList();

    // 应用搜索
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      items = items.where((city) {
        return city.name.toLowerCase().contains(query) ||
               city.country.toLowerCase().contains(query);
      }).toList();
    }

    // 应用筛选
    items = _applyFilters(items, filterCriteria.value);

    // 应用排序
    items = _applySorting(items, sortOption.value);

    return items;
  }

  // 新增方法
  void toggleViewMode() {
    viewMode.value = viewMode.value == ViewMode.grid 
        ? ViewMode.list 
        : ViewMode.grid;
  }

  void updateSortBy(SortOption option) {
    sortOption.value = option;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateFilterCriteria(FilterCriteria criteria) {
    filterCriteria.value = criteria;
  }

  void resetFilters() {
    filterCriteria.value = FilterCriteria.empty();
  }

  Future<void> searchCities(String keyword) async { /* ... */ }

  // 私有方法
  List<City> _applyFilters(List<City> items, FilterCriteria criteria) { /* ... */ }
  List<City> _applySorting(List<City> items, SortOption option) { /* ... */ }
}
```

---

## 🔗 6. 依赖关系图

```
┌─────────────────────────────────────────────────────────────┐
│                     UserStateController                      │
│                   (认证状态 - 已存在)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │ 依赖 (登录检查)
                       ↓
┌──────────────────────────────────────────────────────────────┐
│                   EventsStateController                       │
│              (活动管理 - 新建 Events Domain)                   │
├──────────────────────────────────────────────────────────────┤
│  • events: RxList<Event>                                     │
│  • rsvpedEventIds: RxList<String>                            │
│  • loadEvents()                                              │
│  • createEvent()                                             │
│  • toggleRsvp()                                              │
└───────────────┬──────────────────────────────────────────────┘
                │ 需要 cityId 查找
                ↓
┌──────────────────────────────────────────────────────────────┐
│                 LocationStateController                       │
│             (地理位置 - 扩展 Location Domain)                  │
├──────────────────────────────────────────────────────────────┤
│  • countries: RxList<Country>                                │
│  • citiesByCountry: RxMap<String, List<City>>                │
│  • loadCountries()                                           │
│  • loadCitiesByCountry()                                     │
│  • getCitiesByCountry()                                      │
└──────────────────────────────────────────────────────────────┘
                       ↑
                       │ 可选依赖 (国家/地区数据)
                       │
┌──────────────────────────────────────────────────────────────┐
│                   CityStateController                         │
│             (城市筛选搜索 - 扩展 City Domain)                  │
├──────────────────────────────────────────────────────────────┤
│  • cities: RxList<City>                                      │
│  • filterCriteria: Rx<FilterCriteria>                        │
│  • sortOption: Rx<SortOption>                                │
│  • searchQuery: RxString                                     │
│  • filteredCities (getter)                                   │
│  • searchCities()                                            │
│  • updateFilterCriteria()                                    │
│  • resetFilters()                                            │
└──────────────────────────────────────────────────────────────┘
```

---

## 📝 7. 迁移顺序和步骤

### Phase 1: Events Domain 创建 (核心 - 优先级 P0)
**预计操作数**: 45-55

1. **创建 Events Domain 目录结构** (1 操作)
2. **创建实体和值对象** (3 文件 = 3 操作)
   - Event 实体
   - EventType 值对象
   - RsvpStatus 值对象
3. **创建仓储接口** (1 操作)
4. **创建 DTO 和映射器** (2 文件 = 2 操作)
5. **实现仓储** (1 操作)
6. **创建 Use Cases** (5 文件 = 5 操作)
7. **创建 EventsStateController** (1 操作)
8. **创建辅助类** (1 操作)
9. **注册依赖注入** (1 操作)
10. **更新 UI 引用** (预计 8-10 个文件 = 8-10 操作)
11. **测试和验证** (2-4 操作)

---

### Phase 2: Location Domain 扩展 (优先级 P1)
**预计操作数**: 20-25

1. **创建 LocationStateController** (1 操作)
2. **创建/更新 Use Cases** (2 文件 = 2 操作)
   - GetCountriesUseCase
   - GetCitiesByCountryUseCase
3. **创建辅助类** (1 操作 - LocationHelpers)
4. **注册依赖注入** (1 操作)
5. **更新 UI 引用** (预计 5-7 个文件 = 5-7 操作)
6. **测试和验证** (2-4 操作)

---

### Phase 3: City Domain 扩展 (核心 - 优先级 P0)
**预计操作数**: 35-45

1. **创建新实体和值对象** (4 文件 = 4 操作)
   - FilterCriteria
   - PriceRange
   - SortOption
   - ViewMode
2. **扩展 CityStateController** (1 操作 - 大改)
3. **创建新 Use Cases** (2 文件 = 2 操作)
   - SearchCitiesUseCase
   - FilterCitiesUseCase
4. **创建辅助类** (1 操作 - CityHelpers)
5. **更新仓储接口和实现** (2 操作)
6. **注册依赖注入** (1 操作)
7. **更新 UI 引用** (预计 10-15 个文件 = 10-15 操作)
8. **测试和验证** (3-5 操作)

---

### Phase 4: 清理和最终验证
**预计操作数**: 8-12

1. **删除 data_service_controller.dart** (1 操作)
2. **清理未使用的导入** (2-3 操作)
3. **运行 flutter analyze** (1 操作)
4. **全面测试** (2-3 操作)
5. **更新文档** (2-3 操作)

---

## ⏱️ 8. 完成时间预估

| 阶段 | 预计操作数 | 预估时间 |
|------|-----------|---------|
| Phase 1: Events Domain | 45-55 | 1.5-2 小时 |
| Phase 2: Location Domain | 20-25 | 30-45 分钟 |
| Phase 3: City Domain | 35-45 | 1-1.5 小时 |
| Phase 4: 清理验证 | 8-12 | 15-30 分钟 |
| **总计** | **108-137 操作** | **3-4.5 小时** |

---

## 🎯 9. 成功标准

### 功能验证
- ✅ 所有活动功能正常 (列表、搜索、RSVP、创建)
- ✅ 地理位置数据加载正常 (国家、城市)
- ✅ 城市筛选和搜索功能完整
- ✅ 所有 UI 页面引用更新
- ✅ 登录状态监听正常工作

### 技术质量
- ✅ `flutter analyze` 无错误
- ✅ 所有域遵循 DDD 架构
- ✅ 依赖注入配置正确
- ✅ 状态管理使用 GetX 正确
- ✅ 代码无重复逻辑

### 清理验证
- ✅ `data_service_controller.dart` 已删除
- ✅ `lib/controllers/` 仅剩 3 个文件:
  - `bottom_nav_controller.dart`
  - `locale_controller.dart`
  - `location_controller.dart` (待后续评估)
- ✅ 控制器删除进度: 14/17+ (82%)

---

## 📌 10. 注意事项

### 风险点
1. **⚠️ UI 引用广泛**: DataServiceController 被多个页面使用，需要逐一更新
2. **⚠️ 认证依赖**: Events Domain 需要保留对 UserStateController 的依赖
3. **⚠️ 复杂筛选逻辑**: City Domain 的筛选逻辑需要保持完整性
4. **⚠️ 状态同步**: 登录/登出时的数据清空和刷新逻辑需要正确迁移

### 最佳实践
- 📝 每完成一个 Phase 进行 `flutter analyze` 验证
- 🧪 每个 Use Case 至少有一个简单的功能测试
- 📚 创建 Quick Reference 文档便于后续维护
- 🔄 保持增量迁移，避免大爆炸式改动

---

## 🚀 11. 下一步行动

**立即开始**: Phase 1 - Events Domain 创建

**第一步**:
```bash
# 创建 Events Domain 目录结构
mkdir -p lib/features/events/{domain/{entities,repositories},infrastructure/{models,repositories},application/use_cases,presentation/{controllers,helpers}}
```

**第二步**: 创建 Event 实体文件

---

**文档版本**: v1.0  
**创建日期**: 2024年  
**作者**: GitHub Copilot (AI Assistant)  
**状态**: ✅ 分析完成 - 等待执行确认
