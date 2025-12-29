# 控制器迁移指南

## 迁移状态

### 已迁移的页面 ✅

| 页面 | 原控制器 | V2 控制器 | 状态 |
|------|----------|-----------|------|
| `favorites_page.dart` | CityStateController | CityStateControllerV2 | ✅ |
| `city_list_page.dart` | CityStateController | CityStateControllerV2 | ✅ |
| `amap_global_page.dart` | CityStateController | CityStateControllerV2 | ✅ |
| `data_service_page.dart` | City/Meetup | V2 版本 | ✅ |
| `meetup_detail_page.dart` | MeetupStateController | MeetupStateControllerV2 | ✅ |
| `meetups_list_page.dart` | MeetupStateController | MeetupStateControllerV2 | ✅ |
| `create_meetup_page.dart` | MeetupStateController | MeetupStateControllerV2 | ✅ |
| `invite_to_meetup_page.dart` | MeetupStateController | MeetupStateControllerV2 | ✅ |
| `coworking_list_page.dart` | CoworkingStateController | CoworkingStateControllerV2 | ✅ |
| `coworking_detail_page.dart` | CoworkingStateController | CoworkingStateControllerV2 | ✅ |

## 快速迁移步骤

V2 控制器已设计为与原控制器 API 兼容，迁移只需修改少量代码。

### 1. City 控制器迁移示例

**修改前：**
```dart
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';

class _CityListPageState extends State<CityListPage> {
  final CityStateController controller = Get.find<CityStateController>();
  // ...
}
```

**修改后：**
```dart
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller_v2.dart';

class _CityListPageState extends State<CityListPage> {
  final CityStateControllerV2 controller = Get.find<CityStateControllerV2>();
  // ...
}
```

### 2. 兼容的 API 列表

| 原 API | V2 API | 说明 |
|--------|--------|------|
| `loadInitialCities()` | ✅ 保持不变 | 初始加载城市 |
| `loadMoreCities()` | ✅ 保持不变 | 加载更多 |
| `searchCities(query)` | ✅ 保持不变 | 搜索城市 |
| `filterByCountry(id)` | ✅ 保持不变 | 按国家筛选 |
| `clearFilters()` | ✅ 保持不变 | 清除筛选 |
| `resetFilters()` | ✅ 保持不变 | 重置筛选 |
| `toggleFavorite(id)` | ✅ 保持不变 | 切换收藏 |
| `toggleCityFavorite(id)` | ✅ 保持不变 | 切换收藏（别名） |
| `loadUserFavoriteCityIds()` | ✅ 保持不变 | 加载收藏ID |
| `refresh()` | ✅ 保持不变 | 刷新数据 |
| `cities` | ✅ 保持不变 | 城市列表 |
| `filteredCities` | ✅ 保持不变 | 筛选后的城市 |
| `isLoading` | ✅ 保持不变 | 加载状态 |
| `isLoadingMore` | ✅ 保持不变 | 加载更多状态 |
| `hasMoreData` | ✅ 保持不变 | 是否有更多数据 |
| `hasError` | ✅ 保持不变 | 是否有错误 |
| `hasActiveFilters` | ✅ 保持不变 | 是否有筛选 |
| `hasCities` | ✅ 保持不变 | 是否有城市 |
| `canLoadMore` | ✅ 保持不变 | 是否可以加载更多 |
| `searchQuery` | ✅ 保持不变 | 搜索关键词 |
| `selectedCountryId` | ✅ 保持不变 | 选中的国家 |
| `availableRegions` | ✅ 保持不变 | 可选区域 |
| `availableCountries` | ✅ 保持不变 | 可选国家 |
| `availableCities` | ✅ 保持不变 | 可选城市 |
| `availableClimates` | ✅ 保持不变 | 可选气候 |
| `isGeneratingImages(id)` | ✅ 保持不变 | 检查图片生成 |
| `generateCityImages(id)` | ✅ 保持不变 | 生成城市图片 |

### 3. Meetup 控制器兼容 API

| 原 API | V2 API | 说明 |
|--------|--------|------|
| `isRsvped(id)` | ✅ 保持不变 | 检查是否已报名 |
| `rsvpedMeetupIds` | ✅ 保持不变 | 已报名ID列表 |
| `upcomingMeetups` | ✅ 保持不变 | 即将举行的活动 |
| `refreshMeetups()` | ✅ 保持不变 | 刷新活动列表 |
| `inviteToMeetup()` | ✅ 保持不变 | 邀请用户参加 |
| `hasMoreData` | ✅ 保持不变 | 是否有更多数据 |

### 4. 新增功能

V2 控制器额外提供以下功能：

```dart
// 智能缓存 - 自动判断是否需要刷新
await controller.initialLoad(); // 使用缓存
await controller.forceRefresh(); // 强制刷新

// 数据同步 - 自动响应其他组件的数据变更
// 例如：当用户收藏城市后，其他页面会自动更新
```

### 4. 迁移其他控制器

#### Coworking 控制器
```dart
// 修改前
final CoworkingStateController controller = Get.find<CoworkingStateController>();

// 修改后
final CoworkingStateControllerV2 controller = Get.find<CoworkingStateControllerV2>();
```

#### Meetup 控制器
```dart
// 修改前
final MeetupStateController controller = Get.find<MeetupStateController>();

// 修改后
final MeetupStateControllerV2 controller = Get.find<MeetupStateControllerV2>();
```

#### User 控制器
```dart
// 修改前
final UserStateController controller = Get.find<UserStateController>();

// 修改后
final UserStateControllerV2 controller = Get.find<UserStateControllerV2>();
```

### 5. 测试检查清单

迁移后请验证以下功能：

- [ ] 页面初始加载正常
- [ ] 下拉刷新正常工作
- [ ] 滚动加载更多正常
- [ ] 搜索功能正常
- [ ] 筛选功能正常
- [ ] 收藏功能正常
- [ ] 从其他页面返回时数据正确更新

### 6. 常见问题

**Q: V2 控制器和原控制器可以同时使用吗？**

A: 可以。它们是独立注册的，不会互相影响。但建议逐步迁移到 V2。

**Q: 如果遇到 API 不兼容怎么办？**

A: 请检查是否使用了不在兼容列表中的方法。如需要，可以在 V2 控制器中添加兼容方法。

**Q: V2 控制器的缓存如何控制？**

A: 
- `initialLoad()` - 使用缓存（如果有效）
- `refresh()` - 检查缓存后决定是否刷新
- `forceRefresh()` - 强制从服务器获取最新数据
