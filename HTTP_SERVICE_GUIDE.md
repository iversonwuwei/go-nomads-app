# HTTP 服务集成指南

## 概述

本项目已集成完整的 HTTP 服务层，用于与后端 API 进行通信。基于 Dio 封装，提供了统一的请求处理、错误处理和认证管理。

## 文件结构

```
lib/
├── config/
│   └── api_config.dart          # API 配置（URL、端点等）
└── services/
    ├── http_service.dart         # HTTP 基础服务
    ├── auth_service.dart         # 认证服务（登录、注册等）
    ├── home_data_service.dart    # 首页数据服务
    └── http_service_example.dart # 使用示例
```

## 快速开始

### 1. 配置后端地址

在 `lib/config/api_config.dart` 中配置后端地址：

```dart
// 开发环境 - 本地后端
static const String baseUrl = 'http://localhost:8080';

// 或者在运行时动态设置
ApiConfig.setBaseUrl('http://192.168.1.100:8080');
```

**重要提示**：
- iOS 模拟器使用 `http://localhost:8080`
- Android 模拟器使用 `http://10.0.2.2:8080`
- 真机测试使用局域网 IP，如 `http://192.168.1.100:8080`

### 2. 用户登录

```dart
import 'package:df_admin_mobile/services/auth_service.dart';

final authService = AuthService();

// 登录
try {
  final result = await authService.login(
    username: 'user@example.com',
    password: 'password123',
  );
  
  print('登录成功');
  print('Token: ${result['token']}');
  print('用户信息: ${result['user']}');
  
  // 导航到首页
  Navigator.pushReplacementNamed(context, '/home');
  
} on HttpException catch (e) {
  // 显示错误提示
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
}
```

### 3. 获取首页数据

```dart
import 'package:df_admin_mobile/services/home_data_service.dart';

final homeDataService = HomeDataService();

// 获取完整首页数据
final homeData = await homeDataService.getHomeData();

// 或者单独获取各部分数据
final banners = await homeDataService.getBanners();
final cities = await homeDataService.getRecommendedCities(limit: 10);
final meetups = await homeDataService.getMeetups(upcoming: true);
```

### 4. 在 StatefulWidget 中使用

```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeDataService _homeDataService = HomeDataService();
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _homeDataService.getHomeData();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } on HttpException catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          // 使用 _data 构建 UI
        ],
      ),
    );
  }
}
```

## API 端点说明

### 认证相关

| 方法 | 端点 | 说明 |
|------|------|------|
| POST | `/api/v1/auth/login` | 用户登录 |
| POST | `/api/v1/auth/register` | 用户注册 |
| POST | `/api/v1/auth/logout` | 用户登出 |
| POST | `/api/v1/auth/refresh` | 刷新 Token |

### 首页相关

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/v1/home/data` | 获取首页所有数据 |
| GET | `/api/v1/home/banners` | 获取轮播图数据 |

### 用户相关

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/v1/user/profile` | 获取用户信息 |
| PUT | `/api/v1/user/update` | 更新用户信息 |

### 城市相关

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/v1/cities` | 获取城市列表 |
| GET | `/api/v1/cities/{id}` | 获取城市详情 |

### 共享空间相关

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/v1/coworking-spaces` | 获取共享空间列表 |
| GET | `/api/v1/coworking-spaces/{id}` | 获取共享空间详情 |

### 创意项目相关

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/v1/innovation-projects` | 获取创意项目列表 |
| GET | `/api/v1/innovation-projects/{id}` | 获取创意项目详情 |

### Meetup 相关

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/v1/meetups` | 获取 Meetup 列表 |
| GET | `/api/v1/meetups/{id}` | 获取 Meetup 详情 |
| POST | `/api/v1/meetups/{id}/join` | 参加 Meetup |

## 请求参数说明

### 登录请求

```json
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123"
}
```

**响应示例：**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_here",
  "user": {
    "id": "123",
    "username": "testuser",
    "email": "user@example.com",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

### 首页数据响应

```json
GET /api/v1/home/data

{
  "banners": [
    {
      "id": "1",
      "imageUrl": "https://example.com/banner1.jpg",
      "title": "欢迎来到行途",
      "link": "/cities/chiang-mai"
    }
  ],
  "recommendedCities": [
    {
      "id": "chiang-mai",
      "name": "清迈",
      "nameEn": "Chiang Mai",
      "country": "泰国",
      "imageUrl": "https://example.com/chiang-mai.jpg",
      "description": "泰国北部的数字游民天堂"
    }
  ],
  "recentMeetups": [...],
  "featuredProjects": [...],
  "popularSpaces": [...]
}
```

### 分页列表响应

```json
GET /api/v1/cities?page=1&pageSize=20

{
  "cities": [...],
  "total": 50,
  "page": 1,
  "pageSize": 20,
  "totalPages": 3,
  "hasMore": true
}
```

## 错误处理

### 统一错误格式

所有 API 错误都会抛出 `HttpException`，包含：
- `message`: 错误消息（中文）
- `statusCode`: HTTP 状态码

```dart
try {
  await authService.login(...);
} on HttpException catch (e) {
  print('错误: ${e.message}');
  print('状态码: ${e.statusCode}');
}
```

### 常见错误码

| 状态码 | 说明 | 处理建议 |
|--------|------|----------|
| 400 | 请求参数错误 | 检查请求参数 |
| 401 | 未授权 | 重新登录 |
| 403 | 无权限 | 提示用户权限不足 |
| 404 | 资源不存在 | 检查资源 ID |
| 500 | 服务器错误 | 提示用户稍后重试 |

## 认证机制

### Token 管理

登录成功后，Token 会自动保存到 `HttpService` 中，后续所有请求都会自动携带：

```
Authorization: Bearer <token>
```

### 手动设置 Token（从本地存储恢复）

```dart
final authService = AuthService();
authService.setToken('saved_token_from_local_storage');
```

### 检查登录状态

```dart
if (authService.isLoggedIn()) {
  // 已登录
} else {
  // 未登录，跳转到登录页
  Navigator.pushNamed(context, '/login');
}
```

## 调试技巧

### 1. 查看请求日志

在开发模式下，所有 HTTP 请求都会自动打印到控制台：

```
🚀 REQUEST[POST] => http://localhost:8080/api/v1/auth/login
Headers: {Content-Type: application/json, Accept: application/json}
Data: {username: test@example.com, password: ******}

✅ RESPONSE[200] => http://localhost:8080/api/v1/auth/login
Data: {token: eyJhbG..., user: {...}}
```

### 2. 测试不同环境

```dart
// 开发环境
ApiConfig.setBaseUrl('http://localhost:8080');

// 测试环境
ApiConfig.setBaseUrl('http://192.168.1.100:8080');

// 生产环境
ApiConfig.setBaseUrl('https://api.yourdomain.com');
```

### 3. 模拟网络延迟

```dart
// 在 http_service.dart 的拦截器中添加
onRequest: (options, handler) async {
  await Future.delayed(Duration(seconds: 2)); // 模拟 2 秒延迟
  return handler.next(options);
},
```

## 后续任务

- [ ] 实现 Token 持久化（使用 SharedPreferences 或 Hive）
- [ ] 实现 Token 自动刷新机制
- [ ] 添加请求缓存机制
- [ ] 添加离线数据支持
- [ ] 创建更多业务 Service（如 MeetupService、CoworkingService 等）
- [ ] 添加文件上传功能（头像、图片等）
- [ ] 实现 WebSocket 支持（实时聊天）

## 常见问题

### Q: Android 模拟器无法连接 localhost？

A: Android 模拟器需要使用 `10.0.2.2` 代替 `localhost`：

```dart
ApiConfig.setBaseUrl('http://10.0.2.2:8080');
```

### Q: iOS 真机无法访问 HTTP？

A: 需要在 `Info.plist` 中配置允许 HTTP：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Q: 如何处理网络超时？

A: 可以在 `api_config.dart` 中调整超时时间：

```dart
static const int connectTimeout = 30000; // 30 秒
static const int receiveTimeout = 30000; // 30 秒
```

### Q: 如何取消正在进行的请求？

A: 使用 `CancelToken`：

```dart
final cancelToken = CancelToken();

// 发起请求
httpService.get('/data', cancelToken: cancelToken);

// 取消请求
cancelToken.cancel('用户取消');
```

## 参考资料

- [Dio 官方文档](https://pub.dev/packages/dio)
- [Flutter HTTP 请求最佳实践](https://flutter.dev/docs/cookbook/networking/fetch-data)
- [RESTful API 设计指南](https://restfulapi.net/)
