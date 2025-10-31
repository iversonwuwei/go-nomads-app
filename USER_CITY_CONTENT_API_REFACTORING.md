# User City Content API Service 架构重构完成

## 📋 问题背景

之前的 `UserCityContentApiService` 实现存在严重的架构问题:

```dart
// ❌ 错误的做法
UserCityContentApiService._internal() {
  final httpService = HttpService();
  _dio = httpService.dio;
  
  // 直接修改共享 Dio 实例的 baseUrl - 会影响所有其他服务!
  _dio.options.baseUrl = ApiConfig.cityServiceBaseUrl;
}
```

**问题**:
- 修改了 `HttpService` 的共享 Dio 实例的 `baseUrl`
- 违反了单一职责原则 - 影响了其他使用 HttpService 的服务
- 代码重复 - `ApiConfig` 已经管理了所有 base URL 配置
- 不符合 DRY (Don't Repeat Yourself) 原则

## ✅ 解决方案

### 1. 在 ApiConfig 中添加 User Content 端点

```dart
// lib/config/api_config.dart

// ============================================================
// City User Content Endpoints - /api/v1/cities/{id}/user-content/*
// 这些端点直接连接到 CityService (端口 8002)
// ============================================================

// 照片相关
static const String cityPhotosEndpoint = '/cities/{cityId}/user-content/photos';
static const String cityPhotoDetailEndpoint = '/cities/{cityId}/user-content/photos/{photoId}';
static const String myPhotosEndpoint = '/user/city-content/photos';

// 费用相关
static const String cityExpensesEndpoint = '/cities/{cityId}/user-content/expenses';
static const String cityExpenseDetailEndpoint = '/cities/{cityId}/user-content/expenses/{expenseId}';
static const String myExpensesEndpoint = '/user/city-content/expenses';

// 评论相关
static const String cityReviewsEndpoint = '/cities/{cityId}/user-content/reviews';
static const String myCityReviewEndpoint = '/cities/{cityId}/user-content/reviews/mine';

// 统计相关
static const String cityUserContentStatsEndpoint = '/cities/{cityId}/user-content/stats';
```

### 2. 重构 UserCityContentApiService

```dart
// lib/services/user_city_content_api_service.dart

class UserCityContentApiService {
  static final UserCityContentApiService _instance = UserCityContentApiService._internal();
  factory UserCityContentApiService() => _instance;

  late final HttpService _httpService;

  UserCityContentApiService._internal() {
    // ✅ 正确做法: 只获取 HttpService 实例,不修改其配置
    _httpService = HttpService();
  }

  /// 构建完整的 CityService URL
  String _buildUrl(String path) {
    // 使用 ApiConfig 的 cityServiceApiBaseUrl (http://10.0.2.2:8002/api/v1)
    return '${ApiConfig.cityServiceApiBaseUrl}$path';
  }

  // 使用示例
  Future<UserCityPhoto> addCityPhoto({
    required String cityId,
    required String imageUrl,
    // ...
  }) async {
    final endpoint = ApiConfig.cityPhotosEndpoint.replaceAll('{cityId}', cityId);
    // endpoint: /cities/123/user-content/photos
    
    final response = await _httpService.post(
      _buildUrl(endpoint),  // http://10.0.2.2:8002/api/v1/cities/123/user-content/photos
      data: { /* ... */ },
    );
    return UserCityPhoto.fromJson(response.data);
  }
}
```

## 🎯 改进点

### 1. **职责分离**
- `ApiConfig`: 管理所有 URL 和端点配置
- `HttpService`: 提供共享的 HTTP 客户端
- `UserCityContentApiService`: 专注于业务逻辑,组合使用上述服务

### 2. **使用集中配置**
- 所有端点定义在 `ApiConfig` 中
- 自动适配不同平台 (Android/iOS/Web)
- 自动切换真机/模拟器地址

### 3. **避免副作用**
- 不修改共享的 Dio 实例
- 每次调用都构建完整 URL
- 不影响其他 API 服务

### 4. **易于维护**
- URL 路径集中管理
- 使用模板变量 `{cityId}` `{photoId}` 等
- 一处修改,全局生效

## 📊 对比

| 方面 | 修改前 | 修改后 |
|------|--------|--------|
| Dio 实例 | 修改共享实例的 baseUrl | 使用共享实例但不修改配置 |
| URL 管理 | 硬编码在方法中 | 集中在 ApiConfig |
| 平台适配 | 重复实现 | 使用 ApiConfig 的配置 |
| 代码重复 | 高 (重复 baseUrl 逻辑) | 低 (复用 ApiConfig) |
| 副作用 | 影响其他服务 | 无副作用 |
| 可维护性 | 低 | 高 |

## 🔧 技术细节

### URL 构建流程

1. **获取端点模板**
   ```dart
   ApiConfig.cityPhotosEndpoint  
   // → '/cities/{cityId}/user-content/photos'
   ```

2. **替换参数**
   ```dart
   endpoint.replaceAll('{cityId}', cityId)
   // → '/cities/550e8400-e29b-41d4-a716-446655440000/user-content/photos'
   ```

3. **构建完整 URL**
   ```dart
   _buildUrl(endpoint)
   // → 'http://10.0.2.2:8002/api/v1/cities/550e8400-e29b-41d4-a716-446655440000/user-content/photos'
   ```

### ApiConfig 配置逻辑

```dart
// CityService 地址 (端口 8002)
static String get cityServiceBaseUrl {
  if (kIsProduction) {
    return productionUrl;
  }
  
  if (usePhysicalDevice) {
    return cityServicePhysicalDeviceUrl;  // http://192.168.110.54:8002
  }
  
  return cityServiceDevelopmentUrl;  // Android: http://10.0.2.2:8002
}

// CityService API 路径
static String get cityServiceApiBaseUrl => '$cityServiceBaseUrl$apiVersion';
// → http://10.0.2.2:8002/api/v1
```

## ✅ 验证结果

```bash
$ flutter analyze lib/services/user_city_content_api_service.dart lib/config/api_config.dart
Analyzing 2 items...
No issues found! (ran in 0.4s)
```

## 📝 使用示例

### 添加城市费用

```dart
final apiService = UserCityContentApiService();

final expense = await apiService.addCityExpense(
  cityId: '550e8400-e29b-41d4-a716-446655440000',
  category: ExpenseCategory.accommodation,
  amount: 1500.0,
  currency: 'CNY',
  description: '月租房费',
  date: DateTime.now(),
);

// 实际请求 URL:
// http://10.0.2.2:8002/api/v1/cities/550e8400-e29b-41d4-a716-446655440000/user-content/expenses
```

### 获取城市照片

```dart
final photos = await apiService.getCityPhotos(
  cityId: '550e8400-e29b-41d4-a716-446655440000',
  onlyMine: false,
);

// 实际请求 URL:
// http://10.0.2.2:8002/api/v1/cities/550e8400-e29b-41d4-a716-446655440000/user-content/photos?onlyMine=false
```

## 🎓 最佳实践总结

1. **不要修改共享的 Dio 实例配置** - 会影响其他服务
2. **使用完整 URL** - `baseUrl + path` 而不是修改 baseUrl
3. **集中管理配置** - 在 ApiConfig 中统一定义
4. **复用现有服务** - 使用 HttpService 而不是创建新的 Dio
5. **职责分离** - 每个类只负责自己的事情

## 📚 相关文件

- ✅ `lib/config/api_config.dart` - 添加了 user-content 端点
- ✅ `lib/services/user_city_content_api_service.dart` - 重构为使用 ApiConfig
- ✅ `lib/services/http_service.dart` - 保持不变,提供共享 Dio 实例
- ✅ `lib/pages/add_cost_page.dart` - 使用该服务,无需修改

## 🚀 下一步

- [x] 重构完成并验证
- [x] 编译无错误
- [x] 静态分析通过
- [ ] 端到端测试费用提交功能
- [ ] 验证在真机/模拟器上的实际表现

---

**重构日期**: 2025-01-XX  
**问题发现者**: 用户 (指出架构问题)  
**修复人员**: AI Assistant
