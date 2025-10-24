# API Integration Guide

## 📚 概述

本文档描述了Flutter应用与后端EventService API的集成配置，包括认证头的自动添加和错误处理机制。

## 🔐 认证机制

### EventService认证要求

EventService使用用户上下文中间件来验证请求，主要通过以下头部信息：

- `Authorization`: Bearer token（从HttpService自动添加）
- `X-User-Id`: 用户GUID（从数据库token获取）

### 认证头自动添加

`EventsApiService`会自动为所有需要认证的API请求添加必要的头部信息：

```dart
// 自动获取认证头
final authHeaders = await _getAuthHeaders();

// 在API调用中使用
final response = await _httpService.post<Map<String, dynamic>>(
  ApiConfig.eventsEndpoint,
  data: eventData,
  options: Options(headers: authHeaders),
);
```

## 🛠️ API 端点配置

### 基础配置

在`lib/config/api_config.dart`中配置：

```dart
// EventService 基础URL
static String eventServiceBaseUrl = 'http://localhost:8005';

// Events API 端点
static String eventsEndpoint = '/api/v1/Events';
static String eventDetailEndpoint = '/api/v1/Events/{id}';
static String eventJoinEndpoint = '/api/v1/Events/{id}/join';
```

### 支持的API操作

| 操作 | 方法 | 端点 | 需要认证 |
|------|------|------|----------|
| 创建活动 | POST | `/api/v1/Events` | ✅ |
| 获取活动详情 | GET | `/api/v1/Events/{id}` | ❌ (可选) |
| 获取活动列表 | GET | `/api/v1/Events` | ❌ |
| 更新活动 | PUT | `/api/v1/Events/{id}` | ✅ |
| 参加活动 | POST | `/api/v1/Events/{id}/join` | ✅ |
| 取消参加 | DELETE | `/api/v1/Events/{id}/join` | ✅ |
| 关注活动 | POST | `/api/v1/Events/{id}/follow` | ✅ |
| 取消关注 | DELETE | `/api/v1/Events/{id}/follow` | ✅ |
| 我创建的活动 | GET | `/api/v1/Events/me/created` | ✅ |
| 我参加的活动 | GET | `/api/v1/Events/me/joined` | ✅ |
| 我关注的活动 | GET | `/api/v1/Events/me/following` | ✅ |

## 📝 使用示例

### 创建活动

```dart
final eventsApi = EventsApiService();

try {
  final eventData = EventsApiService.convertToEventData(
    title: 'Flutter Meetup',
    type: 'networking',
    city: 'Shanghai',
    country: 'China',
    venue: 'Tech Hub',
    date: DateTime.now().add(Duration(days: 7)),
    time: '18:00',
    maxAttendees: 50,
    description: 'Monthly Flutter developer meetup',
  );

  final result = await eventsApi.createEvent(eventData);
  print('Event created successfully: ${result['id']}');
} catch (e) {
  print('Failed to create event: $e');
}
```

### 获取用户创建的活动

```dart
try {
  final myEvents = await eventsApi.getUserCreatedEvents();
  print('My events: ${myEvents.length}');
} catch (e) {
  print('Failed to fetch my events: $e');
}
```

## ⚠️ 错误处理

### 常见错误类型

1. **未认证错误 (401)**
   ```
   Exception: 用户未登录，请先登录
   ```

2. **GUID格式错误**
   ```
   {"error":"Unrecognized Guid format."}
   ```

3. **数据库权限错误 (RLS)**
   ```
   {"error":"new row violates row-level security policy"}
   ```

### 错误处理流程

```dart
try {
  final result = await eventsApi.createEvent(eventData);
  // 处理成功结果
} catch (e) {
  if (e.toString().contains('未登录')) {
    // 跳转到登录页面
    Get.toNamed('/login');
  } else if (e.toString().contains('Guid format')) {
    // 用户ID格式错误，重新获取认证信息
    await _authService.checkLoginStatus();
  } else {
    // 其他错误，显示错误信息
    Get.snackbar('错误', e.toString());
  }
}
```

## 🔧 数据格式转换

### CreateMeetupPage 到 EventService 数据映射

```dart
// CreateMeetupPage 表单数据
{
  "title": "Flutter Meetup",
  "type": "networking",  // 前端类型
  "city": "Shanghai",
  "venue": "Tech Hub",
  "date": "2024-02-01",
  "time": "18:00",
  "maxAttendees": 50
}

// 转换为 EventService API 格式
{
  "title": "Flutter Meetup",
  "category": "business",     // 映射后的后端分类
  "location": "Tech Hub",
  "startTime": "2024-02-01T18:00:00.000Z",
  "maxParticipants": 50,
  "locationType": "physical",
  "isVirtual": false
}
```

### 类型映射规则

```dart
switch (type.toLowerCase()) {
  case 'drinks': return 'social';
  case 'coworking': return 'business';
  case 'dinner': return 'social';
  case 'activity': return 'other';
  case 'workshop': return 'tech';
  case 'networking': return 'business';
  default: return 'other';
}
```

## 🚀 部署注意事项

### 本地开发

- EventService: `http://localhost:8005`
- 确保EventService正在运行
- 确保数据库连接正常

### 生产环境

1. 更新API基础URL
2. 配置HTTPS
3. 验证认证流程
4. 测试所有API端点

## 📋 测试清单

- [ ] EventService启动并监听8005端口
- [ ] 用户登录状态正常
- [ ] 创建活动API调用成功
- [ ] 获取活动列表正常
- [ ] 认证头正确添加
- [ ] 错误处理机制工作正常
- [ ] 数据格式转换正确
- [ ] Flutter应用构建成功

## 🔍 调试信息

### 启用调试日志

EventsApiService会在调试模式下打印详细的请求信息：

```
🔐 开始调用后端登录接口...
   接口: /api/users/login
   邮箱: user@example.com
✅ 后端响应状态码: 200
✅ Token 已保存到 SQLite
🚀 REQUEST[POST] => http://localhost:8005/api/v1/Events
Headers: {Authorization: Bearer eyJ..., X-User-Id: 123e4567-e89b-12d3-a456-426614174000}
```

### 查看EventService日志

```bash
# 查看EventService控制台输出
cd /path/to/go-noma/src/Services/EventService/EventService
dotnet run

# 查看认证信息
[INFO] 用户上下文已设置 - UserId: 123e4567-e89b-12d3-a456-426614174000
[INFO] ✅ 用户 123e4567-e89b-12d3-a456-426614174000 成功创建 Event abc-123
```

## ✅ 完成状态

- [x] EventsApiService创建并配置认证头
- [x] API配置更新为正确的端点
- [x] 数据格式转换实现
- [x] DataServiceController集成API调用
- [x] 错误处理和fallback机制
- [x] Flutter项目构建验证

现在Meetup创建功能已完全集成到后端EventService API，支持认证、错误处理和本地存储fallback。