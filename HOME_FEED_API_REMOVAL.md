# Home Feed API 移除完成

## 概述

移除了 Flutter 端不必要的 `/home/feed` 聚合接口调用,改用独立的小接口。

## 背景

- 后端提供了 `/home/feed` BFF 聚合接口,用于同时获取城市和 Meetup 数据
- Flutter 端已经拆分成多个独立的小接口 (`/cities`, `/events` 等)
- 聚合接口在 Flutter 端已经没有必要,造成代码冗余

## 删除的文件

### 1. 服务层
- ❌ `lib/services/home_api_service.dart` - Home Feed API 服务

### 2. 模型层
- ❌ `lib/models/home_feed_model.dart` - Home Feed 数据模型

## 修改的文件

### 1. API 配置
**文件**: `lib/config/api_config.dart`

```dart
// 删除
- static const String homeFeedEndpoint = '/home/feed';
```

### 2. 城市列表控制器
**文件**: `lib/controllers/city_list_controller.dart`

**修改前**:
```dart
import '../services/home_api_service.dart';

class CityListController extends GetxController {
  final HomeApiService _homeApiService = HomeApiService();
  
  Future<void> _loadAllCitiesToCache() async {
    final homeFeed = await _homeApiService.getHomeFeed(
      cityLimit: 1000,
      meetupLimit: 0,
    );
    
    for (var city in homeFeed.cities) {
      // 转换数据...
    }
  }
}
```

**修改后**:
```dart
import '../services/cities_api_service.dart';

class CityListController extends GetxController {
  final CitiesApiService _citiesApiService = CitiesApiService();
  
  Future<void> _loadAllCitiesToCache() async {
    final response = await _citiesApiService.getCities(
      page: 1,
      pageSize: 1000,
    );
    
    final data = response['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? [];
    
    for (var city in items) {
      // 转换数据...
    }
  }
}
```

## API 对比

### 修改前 (Home Feed API)
```http
GET /api/v1/home/feed?cityLimit=1000&meetupLimit=0
```

**响应**:
```json
{
  "success": true,
  "message": "首页数据加载成功",
  "data": {
    "cities": [...],
    "meetups": [...],
    "cityCount": 100,
    "meetupCount": 0,
    "hasMoreCities": false,
    "hasMoreMeetups": false
  }
}
```

### 修改后 (Cities API)
```http
GET /api/v1/cities?page=1&pageSize=1000
```

**响应**:
```json
{
  "success": true,
  "message": "获取城市列表成功",
  "data": {
    "items": [...],
    "page": 1,
    "pageSize": 1000,
    "totalCount": 100,
    "totalPages": 1
  }
}
```

## 优势

### 1. 代码简化
- ✅ 减少服务层文件 (删除 `home_api_service.dart`)
- ✅ 减少模型文件 (删除 `home_feed_model.dart`)
- ✅ 统一使用独立接口,代码更清晰

### 2. 职责分离
- ✅ 城市数据使用 `CitiesApiService`
- ✅ 活动数据使用 `EventsApiService`
- ✅ 每个服务只负责自己的数据

### 3. 减少网络请求
- ✅ 城市列表页只需要城市数据,不需要加载 Meetup
- ✅ 避免请求不必要的数据

### 4. 更好的可维护性
- ✅ 接口职责单一,更容易维护
- ✅ 数据流向清晰,便于调试

## 后端状态

⚠️ **注意**: 后端的 `/home/feed` 接口仍然保留,可能有其他客户端使用。

如果确认没有其他客户端使用,可以考虑在后端也删除该接口:
- `src/Gateway/Gateway/Controllers/HomeController.cs`
- 相关的 DTO 和测试

## 测试建议

### 1. 功能测试
- [ ] 城市列表页面正常加载
- [ ] 城市列表分页功能正常
- [ ] 城市列表筛选功能正常
- [ ] 城市详情页面正常显示

### 2. 性能测试
- [ ] 检查加载时间是否有变化
- [ ] 验证网络请求数量减少

### 3. 错误处理
- [ ] 网络错误提示正常
- [ ] 空数据显示正常

## 验证结果

✅ **编译通过**: 所有 Dart 文件编译无错误  
✅ **引用清理**: 无残留的 `HomeApiService` 或 `HomeFeedModel` 引用

## 相关文件

- `lib/services/cities_api_service.dart` - 城市数据服务
- `lib/controllers/city_list_controller.dart` - 城市列表控制器
- `lib/config/api_config.dart` - API 配置

---

**修改时间**: 2025年11月4日  
**修改人**: GitHub Copilot  
**影响范围**: Flutter 前端
