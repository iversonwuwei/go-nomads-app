# EventsApiService 认证修复

## 问题背景

在重构 DataService 后测试时发现:

- ✅ 城市列表加载成功: "CityService 返回: 20 城市"
- ❌ 活动列表加载失败: "HttpException: Missing Authorization header (Status Code: 401)"

## 问题根因

`EventsApiService.getEvents()` 方法强制要求认证:

```dart
// 问题代码
final authHeaders = await _getAuthHeaders();
// _getAuthHeaders() 调用 _ensureAuthentication()
// _ensureAuthentication() 在未登录时抛出异常: "用户未登录,请先登录"
```


这导致未登录用户无法查看活动列表,影响用户体验。

## 解决方案

### 1. 新增 `_tryGetAuthHeaders()` 方法

创建一个不强制要求登录的认证头获取方法:

```dart
/// 尝试获取认证头(不强制要求登录)
/// 如果用户已登录则返回认证头,未登录则返回 null
Future<Map<String, String>?> _tryGetAuthHeaders() async {
  try {
    // 检查是否已登录
    final isLoggedIn = await _authService.checkLoginStatus();
    if (!isLoggedIn) {
      return null;
    }

    final headers = <String, String>{};

    // 添加Authorization头
    if (_httpService.authToken != null &&
        _httpService.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_httpService.authToken}';
    }

    // 添加X-User-Id头
    final userId = await _getCurrentUserId();
    if (userId != null && userId.isNotEmpty) {
      headers['X-User-Id'] = userId;
    }

    return headers.isNotEmpty ? headers : null;
  } catch (e) {
    print('ℹ️ 获取认证头失败,以访客身份继续: $e');
    return null;
  }
}
```

**优势**:

- ✅ 不会抛出异常,返回 `null` 表示未登录
- ✅ 通过 `checkLoginStatus()` 检查登录状态,避免调用 `_ensureAuthentication()`
- ✅ 支持访客用户和登录用户两种场景


### 2. 修改 `getEvents()` 方法

使用新的 `_tryGetAuthHeaders()` 替代旧的 try-catch 逻辑:

```dart
/// 获取活动列表
///
/// [requireAuth] 是否需要认证,默认 false,允许未登录用户查看活动列表
Future<Map<String, dynamic>> getEvents({
  String? cityId,
  String? category,
  String? status = 'upcoming',
  int page = 1,
  int pageSize = 20,
  bool requireAuth = false,
}) async {
  // ...

  // 如果需要认证,获取认证头
  Options? requestOptions;
  if (requireAuth) {
    // 强制要求认证
    final authHeaders = await _getAuthHeaders();
    requestOptions = Options(headers: authHeaders);
  } else {
    // 可选认证:如果已登录则添加认证头,未登录则以访客身份访问
    final authHeaders = await _tryGetAuthHeaders();
    if (authHeaders != null) {
      requestOptions = Options(headers: authHeaders);
      print('✅ 已登录,使用认证头获取活动列表');
    } else {
      print('ℹ️ 未登录,以访客身份获取活动列表');
    }
  }

  // ...
}
```

**逻辑说明**:

- `requireAuth = true`: 强制要求认证,使用 `_getAuthHeaders()`,未登录会抛出异常
- `requireAuth = false`: 可选认证,使用 `_tryGetAuthHeaders()`:
  - 已登录: 添加认证头,获取包含 `isParticipant` 状态的完整数据
  - 未登录: 不添加认证头,以访客身份获取基本数据


### 3. 修改 `getEvent()` 方法

活动详情也采用相同的可选认证逻辑:

```dart
/// 获取活动详情
Future<Map<String, dynamic>> getEvent(String eventId) async {
  try {
    // 获取认证头(可选,但用于判断参与状态)
    final authHeaders = await _tryGetAuthHeaders();

    final endpoint = ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId);
    final response = await _httpService.get<Map<String, dynamic>>(
      endpoint,
      options: authHeaders != null ? Options(headers: authHeaders) : null,
    );

    // ...
  }
}
```

### 4. 修改 DataServiceController 调用

确保 `_loadMeetupsFromApi()` 使用 `requireAuth: false`:

```dart
Future<void> _loadMeetupsFromApi() async {
  try {
    isLoadingMeetups.value = true;
    
    // 获取活动列表(不需要认证,访客也可以查看)
    final eventsResponse = await _eventsApiService.getEvents(
      status: 'upcoming',
      requireAuth: false,  // ✅ 访客也可以查看
    );

    // ...
  } finally {
    isLoadingMeetups.value = false;
  }
}
```

## 修改文件

1. ✅ `lib/services/events_api_service.dart`
   - 新增 `_tryGetAuthHeaders()` 方法
   - 修改 `getEvents()` 使用可选认证
   - 修改 `getEvent()` 使用可选认证

2. ✅ `lib/controllers/data_service_controller.dart`
   - 确保 `_loadMeetupsFromApi()` 调用时设置 `requireAuth: false`

## 技术亮点

### 认证策略设计

```text
访客用户
  └─ _tryGetAuthHeaders() 返回 null
      └─ 不添加 Authorization header
          └─ 后端返回基本活动信息

登录用户
  └─ _tryGetAuthHeaders() 返回认证头
      └─ 添加 Authorization header + X-User-Id
          └─ 后端返回完整活动信息(包括 isParticipant 状态)
```

### HttpService 拦截器配合

HttpService 的拦截器只在 `authToken` 存在时才添加 Authorization header:

```dart
// HttpService 拦截器
if (_authToken != null && _authToken!.isNotEmpty) {
  options.headers['Authorization'] = 'Bearer $_authToken';
}
```

因此:

- **访客用户**: 没有 token → 拦截器不添加 header → 正常访问
- **登录用户**: 有 token → 拦截器添加 header → 获取完整数据

## 测试验证

### 未登录状态

```text
ℹ️ 未登录,以访客身份获取活动列表
✅ EventService 返回: N 个活动
```

### 登录状态

```text
✅ 已登录,使用认证头获取活动列表
✅ EventService 返回: N 个活动(包含 isParticipant 状态)
```


## 最佳实践总结

1. **可选认证模式**: 提供 `requireAuth` 参数,默认为 `false`,允许访客访问
2. **优雅降级**: 未登录时不抛异常,返回 `null` 表示无认证
3. **状态检查优先**: 通过 `checkLoginStatus()` 检查登录状态,避免调用会抛异常的方法
4. **清晰的日志**: 区分访客和登录用户的日志输出
5. **职责分离**: `_getAuthHeaders()` 用于强制认证,`_tryGetAuthHeaders()` 用于可选认证

## 相关文档

- [DATA_SERVICE_REFACTORING_COMPLETE.md](./DATA_SERVICE_REFACTORING_COMPLETE.md) - DataService 重构文档
- [SIGNALR_REALTIME_NOTIFICATION_FIX.md](./SIGNALR_REALTIME_NOTIFICATION_FIX.md) - SignalR 实时通知文档

---

**修复完成时间**: 2024-01-XX
**影响范围**: EventsApiService, DataServiceController
**测试状态**: ✅ 待验证
