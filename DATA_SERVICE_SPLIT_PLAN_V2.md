# Data Service Controller 域拆分计划 (更新版)

## 📊 文件分析概览

**目标文件**: `lib/controllers/data_service_controller.dart`  
**总行数**: 1205 行  
**复杂度**: ⚠️ 高（多域集成 + 复杂业务逻辑）  

**重要更新**: **Events Domain = Meetup Domain** (直接扩展现有 Meetup Domain,无需创建新域)

---

## 🎯 域拆分策略 (修订版)

### 域划分决策

| 序号 | 域名称 | 状态 | 复杂度 | 优先级 |
|------|--------|------|--------|--------|
| 1 | **Meetup Domain** | ✨ **扩展现有** | ⚠️ 高 | P0 (核心) |
| 2 | **Location Domain** | ✨ **扩展现有** | 🟡 中 | P1 |
| 3 | **City Domain** | ✨ **扩展现有** | ⚠️ 高 | P0 (核心) |

---

## 📦 1. Meetup Domain 扩展计划

### 1.1 现有结构分析

**已存在的文件**:
```
lib/features/meetup/
├── domain/
│   └── entities/
│       └── meetup.dart ✅          # 完整实体 (Meetup, MeetupType, Location, Venue, Schedule, etc.)
└── infrastructure/
    └── models/
        └── meetup_dto.dart ✅      # DTO 和映射器
```

**缺失的组件**:
- ❌ Repository 接口和实现
- ❌ Use Cases (应用层)
- ❌ State Controller (展示层)
- ❌ Helpers (辅助工具)

### 1.2 需要创建的文件

#### Repository 层 (2 个文件)
```
lib/features/meetup/domain/repositories/
└── i_meetup_repository.dart        # Repository 接口

lib/features/meetup/infrastructure/repositories/
└── meetup_repository.dart          # Repository 实现 (使用 EventsApiService)
```

#### Application 层 (4-5 个文件)
```
lib/features/meetup/application/use_cases/
├── get_meetups_use_case.dart              # 获取活动列表
├── get_meetups_by_city_use_case.dart      # 按城市获取活动
├── create_meetup_use_case.dart            # 创建活动
├── rsvp_to_meetup_use_case.dart           # RSVP 活动
└── cancel_rsvp_use_case.dart              # 取消 RSVP
```

#### Presentation 层 (2 个文件)
```
lib/features/meetup/presentation/
├── controllers/
│   └── meetup_state_controller.dart       # 状态控制器
└── helpers/
    └── meetup_helpers.dart                # 辅助方法 (_guessMeetupType, _mapTypeToCategory)
```

### 1.3 从 DataServiceController 迁移的功能

#### 迁移的方法 (11个):

| 原方法 | 新位置 | 说明 |
|--------|--------|------|
| `refreshMeetups()` | `MeetupRepository.getMeetups()` | 刷新活动列表 |
| `_loadMeetupsFromApi()` | `MeetupRepository` 内部实现 | API 调用逻辑 |
| `toggleRSVP(int)` | `RsvpToMeetupUseCase` / `CancelRsvpUseCase` | RSVP 切换 |
| `upcomingMeetups` (getter) | `MeetupStateController.upcomingMeetups` | 即将到来的活动 |
| `getMeetupsByCity(String)` | `GetMeetupsByCityUseCase` | 按城市过滤 |
| `createMeetup({...})` | `CreateMeetupUseCase` | 创建活动 (12参数) |
| `_createMeetupViaAPI(Map)` | `MeetupRepository` 内部实现 | API 创建逻辑 |
| `_getEventsApiService()` | 依赖注入 | EventsApiService 实例 |
| `_convertToEventData(Map)` | `MeetupDto.toApiRequest()` | DTO 转换 |
| `_mapTypeToCategory(String)` | `MeetupType.toCategory()` | 类型映射 |
| `_guessMeetupType(String)` | `MeetupHelpers.guessMeetupType()` | 类型推测 |

#### 迁移的状态 (3个):

| 原状态 | 新位置 | 类型 |
|--------|--------|------|
| `meetups` | `MeetupStateController.meetups` | `RxList<Meetup>` |
| `rsvpedMeetups` | `MeetupStateController.rsvpedMeetupIds` | `RxList<String>` |
| `isLoadingMeetups` | `MeetupStateController.isLoading` | `RxBool` |

### 1.4 Repository 接口设计

```dart
// lib/features/meetup/domain/repositories/i_meetup_repository.dart
abstract class IMeetupRepository {
  /// 获取活动列表
  Future<List<Meetup>> getMeetups({
    String? status,          // 'upcoming', 'ongoing', 'completed'
    String? cityId,
    int page = 1,
    int pageSize = 20,
  });

  /// 创建活动
  Future<Meetup> createMeetup({
    required String title,
    required String description,
    required String cityId,
    required String venue,
    required String venueAddress,
    required MeetupType type,
    required DateTime startTime,
    DateTime? endTime,
    required int maxAttendees,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
  });

  /// RSVP 活动
  Future<void> rsvpToMeetup(String meetupId);

  /// 取消 RSVP
  Future<void> cancelRsvp(String meetupId);
}
```

### 1.5 State Controller 设计

```dart
// lib/features/meetup/presentation/controllers/meetup_state_controller.dart
class MeetupStateController extends GetxController {
  final GetMeetupsUseCase _getMeetupsUseCase;
  final CreateMeetupUseCase _createMeetupUseCase;
  final RsvpToMeetupUseCase _rsvpToMeetupUseCase;
  final CancelRsvpUseCase _cancelRsvpUseCase;

  // State
  final RxList<Meetup> meetups = <Meetup>[].obs;
  final RxList<String> rsvpedMeetupIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  List<Meetup> get upcomingMeetups {
    final now = DateTime.now();
    final nextMonth = now.add(const Duration(days: 30));
    return meetups.where((meetup) {
      return meetup.schedule.startTime.isAfter(now) && 
             meetup.schedule.startTime.isBefore(nextMonth);
    }).toList()
      ..sort((a, b) => a.schedule.startTime.compareTo(b.schedule.startTime));
  }

  List<Meetup> getMeetupsByCity(String cityName) {
    return upcomingMeetups
        .where((m) => m.location.cityName == cityName)
        .toList();
  }

  bool isRsvped(String meetupId) => rsvpedMeetupIds.contains(meetupId);

  // Methods
  Future<void> loadMeetups({String? cityId, bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) return;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _getMeetupsUseCase.execute(
        status: 'upcoming',
        cityId: cityId,
      );
      
      meetups.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      AppToast.error('加载活动失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMeetup(Meetup meetup) async {
    // 检查登录
    if (!_requireLogin(action: '创建活动')) return;
    
    try {
      final created = await _createMeetupUseCase.execute(meetup);
      meetups.add(created);
      rsvpedMeetupIds.add(created.id); // 创建者自动 RSVP
      AppToast.success('活动创建成功');
    } catch (e) {
      AppToast.error('创建活动失败');
      rethrow;
    }
  }

  Future<void> toggleRsvp(String meetupId) async {
    // 检查登录
    if (!_requireLogin(action: 'RSVP活动')) return;
    
    try {
      if (rsvpedMeetupIds.contains(meetupId)) {
        await _cancelRsvpUseCase.execute(meetupId);
        rsvpedMeetupIds.remove(meetupId);
        _updateMeetupAttendees(meetupId, -1);
      } else {
        await _rsvpToMeetupUseCase.execute(meetupId);
        rsvpedMeetupIds.add(meetupId);
        _updateMeetupAttendees(meetupId, 1);
      }
      meetups.refresh();
    } catch (e) {
      AppToast.error('RSVP 操作失败');
    }
  }

  void _updateMeetupAttendees(String meetupId, int delta) {
    final index = meetups.indexWhere((m) => m.id == meetupId);
    if (index != -1) {
      final meetup = meetups[index];
      final newAttendees = [...meetup.attendeeIds];
      if (delta > 0) {
        // 添加当前用户ID (需要从 UserStateController 获取)
        // newAttendees.add(currentUserId);
      }
      // 这里需要创建新的 Meetup 实例 (因为是不可变对象)
      // meetups[index] = meetup.copyWith(attendeeIds: newAttendees);
    }
  }

  bool _requireLogin({String? action}) {
    try {
      final userStateController = Get.find<UserStateController>();
      if (!userStateController.isLoggedIn) {
        AppToast.warning('请先登录后再进行${action ?? '此操作'}');
        return false;
      }
      return true;
    } catch (e) {
      AppToast.warning('请先登录');
      return false;
    }
  }
}
```

---

## 📦 2. Location Domain 扩展计划

### 2.1 需要创建 LocationStateController

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

  // Methods
  Future<void> loadCountries({bool forceRefresh = false}) async { /* ... */ }
  Future<List<City>> loadCitiesByCountry(String countryId, {bool forceRefresh = false}) async { /* ... */ }
  List<String> getCitiesByCountry(String countryId) { /* ... */ }
  String getCountryByCity(String cityName) { /* ... */ }
}
```

---

## 📦 3. City Domain 扩展计划

### 3.1 扩展 CityStateController

需要添加:
- 筛选逻辑 (9种条件)
- 搜索功能
- 排序功能
- 视图切换

详细设计参考原文档第 5 节。

---

## 📝 迁移步骤 (修订版)

### Phase 1: Meetup Domain 扩展 (优先级 P0)
**预计操作数**: 40-50

1. ✅ **创建 Repository 层** (2 文件)
   - `i_meetup_repository.dart` (接口)
   - `meetup_repository.dart` (实现)

2. ✅ **创建 Use Cases** (4-5 文件)
   - `get_meetups_use_case.dart`
   - `get_meetups_by_city_use_case.dart`
   - `create_meetup_use_case.dart`
   - `rsvp_to_meetup_use_case.dart`
   - `cancel_rsvp_use_case.dart`

3. ✅ **创建 State Controller** (1 文件)
   - `meetup_state_controller.dart`

4. ✅ **创建 Helpers** (1 文件)
   - `meetup_helpers.dart` (辅助方法)

5. ✅ **更新 MeetupDto** (扩展方法)
   - 添加 `toApiRequest()` 方法

6. ✅ **注册依赖注入**
   - 在 `dependency_injection.dart` 中注册

7. ✅ **更新 UI 引用** (预计 5-8 个文件)
   - 替换 `DataServiceController` 为 `MeetupStateController`

8. ✅ **测试验证**

### Phase 2: Location Domain 扩展 (优先级 P1)
**预计操作数**: 20-25

(同原计划)

### Phase 3: City Domain 扩展 (优先级 P0)
**预计操作数**: 35-45

(同原计划)

### Phase 4: 清理和验证
**预计操作数**: 8-12

(同原计划)

---

## ⏱️ 完成时间预估 (修订版)

| 阶段 | 预计操作数 | 预估时间 |
|------|-----------|---------|
| Phase 1: Meetup Domain | 40-50 | 1.5-2 小时 |
| Phase 2: Location Domain | 20-25 | 30-45 分钟 |
| Phase 3: City Domain | 35-45 | 1-1.5 小时 |
| Phase 4: 清理验证 | 8-12 | 15-30 分钟 |
| **总计** | **103-132 操作** | **3-4.5 小时** |

---

## 🎯 成功标准

- ✅ Meetup Domain 完整 (Repository, Use Cases, Controller, Helpers)
- ✅ 所有活动功能正常 (列表、搜索、RSVP、创建)
- ✅ Location Domain 和 City Domain 扩展完成
- ✅ `data_service_controller.dart` 已删除
- ✅ `flutter analyze` 无错误
- ✅ 所有 UI 页面正常工作

---

## 🚀 下一步行动

**开始 Phase 1: Meetup Domain 扩展**

第一步: 创建 Repository 接口
```dart
// lib/features/meetup/domain/repositories/i_meetup_repository.dart
```

**文档版本**: v2.0 (修订版)  
**更新**: Events Domain → Meetup Domain (扩展现有)  
**状态**: ✅ 计划完成 - 等待执行确认
