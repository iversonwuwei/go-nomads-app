# API Path 重复问题修复完成

## 问题描述

Flutter 应用在请求城市相关接口时,URL 路径出现重复的 `/api` 前缀:
- ❌ 错误: `/api/v1/api/cities/上海市/user-content/photos`
- ✅ 正确: `/api/v1/cities/上海市/user-content/photos`

## 根本原因

在 `cities_api_service.dart` 中,`baseUrl` 使用了完整的服务器地址:
```dart
baseUrl = '${ApiConfig.baseUrl}/cities';  // http://127.0.0.1:5000/cities
```

而 `HttpService` 的 Dio 实例已经配置了 `baseUrl`:
```dart
baseUrl: ApiConfig.currentApiBaseUrl,  // http://127.0.0.1:5000/api/v1
```

当 Dio 发送请求时,它会将相对路径附加到配置的 `baseUrl` 后面。但如果传入的路径是绝对路径(以 `http://` 开头),Dio 会直接使用该路径。

由于 `CitiesApiService.baseUrl` 是 `http://127.0.0.1:5000/cities`,Dio 会将其视为绝对路径并尝试附加,导致路径错误。

## 修复方案

### 修改文件: `lib/services/cities_api_service.dart`

**修改前:**
```dart
CitiesApiService._internal() {
  baseUrl = '${ApiConfig.baseUrl}/cities';
}
```

**修改后:**
```dart
CitiesApiService._internal() {
  // HttpService 已经配置了 baseUrl 为 /api/v1
  // 所以这里只需要路径,不需要完整URL
  baseUrl = '/cities';
}
```

同时移除了未使用的 import:
```dart
- import '../config/api_config.dart';
```

## 现在的路径结构

- **Dio baseUrl**: `http://127.0.0.1:5000/api/v1`
- **CitiesApiService baseUrl**: `/cities`
- **最终请求 URL**: `http://127.0.0.1:5000/api/v1/cities`

所有子路径都会正确拼接:
- `GET /cities` → `http://127.0.0.1:5000/api/v1/cities`
- `GET /cities/{id}` → `http://127.0.0.1:5000/api/v1/cities/{id}`
- `GET /cities/{id}/user-content/photos` → `http://127.0.0.1:5000/api/v1/cities/{id}/user-content/photos`

## 验证

1. ✅ 编译检查通过,无错误
2. ✅ 路径拼接逻辑正确
3. ✅ 与其他服务(CoworkingApiService)保持一致

## 其他服务检查

已检查项目中所有 API 服务:
- ✅ `CoworkingApiService`: 已正确使用 `baseUrl = '/coworking'`
- ✅ `UserApiService`: 直接使用 `ApiConfig.currentApiBaseUrl`
- ✅ `CitiesApiService`: 已修复为 `baseUrl = '/cities'`

## 建议

在后续开发中,所有使用 `HttpService` 的 API 服务都应该:
1. 只使用相对路径(以 `/` 开头)
2. 不要使用完整的 URL
3. 依赖 `HttpService` 中配置的 `baseUrl`

示例:
```dart
class SomeApiService {
  late final String baseUrl;
  
  SomeApiService._internal() {
    // ✅ 正确: 只使用路径
    baseUrl = '/some-resource';
    
    // ❌ 错误: 不要使用完整 URL
    // baseUrl = '${ApiConfig.baseUrl}/some-resource';
  }
}
```

## 修复时间

- 问题发现: 2025-01-XX
- 修复完成: 2025-01-XX
- 状态: ✅ 已完成

---
*本文档记录了 API 路径重复问题的完整修复过程*
