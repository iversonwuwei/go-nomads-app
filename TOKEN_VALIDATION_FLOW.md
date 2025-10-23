# Token 验证流程说明

## 概述

应用的 token 验证采用两层架构：
1. **启动时恢复**：应用启动时从 SQLite 恢复 token
2. **路由时验证**：访问受保护页面时验证内存中的 token

## 完整流程

### 1. 用户登录

```dart
// 在 nomads_login_page.dart 中
await _authService.login(email, password);
```

登录成功后自动完成：
- ✅ 保存 token 到 SQLite 数据库
- ✅ 将 token 加载到内存
- ✅ 设置 HTTP 请求头的 Authorization

**SQLite 存储的数据**：
- `user_id`: 用户 ID
- `access_token`: 访问令牌
- `refresh_token`: 刷新令牌
- `token_type`: Bearer
- `expires_in`: 过期时间（秒）
- `created_at`: 创建时间
- `updated_at`: 更新时间

### 2. 应用启动初始化

```dart
// 在 main.dart 中
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化应用，恢复登录状态
  await AppInitService().initialize();
  
  runApp(const MyApp());
}
```

`AppInitService.initialize()` 会：
1. 调用 `checkLoginStatus()` 从 SQLite 恢复 token
2. 验证 token 是否过期
3. 如果有效，将 token 加载到内存

**checkLoginStatus() 的详细流程**：

```dart
Future<bool> checkLoginStatus() async {
  // 1. 检查内存中是否有 token
  if (_httpService.authToken != null) {
    print('✅ 内存中已有 token');
    return true;
  }

  // 2. 从 SQLite 查询最新的 token
  final tokenData = await _tokenDao.getLatestToken();
  
  if (tokenData == null) {
    print('❌ 数据库中没有 token');
    return false;
  }

  // 3. 验证 token 是否过期
  final userId = tokenData['user_id'] as String;
  final isExpired = await _tokenDao.isTokenExpired(userId);
  
  if (isExpired) {
    print('❌ Token 已过期');
    await _tokenDao.deleteTokenByUserId(userId);
    return false;
  }

  // 4. 恢复 token 到内存
  final accessToken = tokenData['access_token'] as String;
  _httpService.setAuthToken(accessToken);
  print('✅ Token 已从数据库恢复到内存');
  
  return true;
}
```

### 3. 路由保护验证

**方式一：AuthMiddleware（推荐用于大多数页面）**

```dart
// 在 app_routes.dart 中
GetPage(
  name: AppRoutes.cityDetail,
  page: () => const CityDetailPage(),
  middlewares: [AuthMiddleware()],  // 添加认证中间件
)
```

`AuthMiddleware.redirect()` 会：
1. 检查内存中是否有 token（同步检查）
2. 如果没有 token，重定向到登录页
3. 如果有 token，允许访问

**注意**：由于 GetX 的 redirect 是同步方法，AuthMiddleware 只检查内存中的 token。但应用启动时已经从 SQLite 恢复过了，所以这里的检查是有效的。

**方式二：AuthGuard Widget（用于需要异步检查的场景）**

```dart
class SomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        // 页面内容
      ),
    );
  }
}
```

`AuthGuard._checkAuth()` 会：
1. 调用 `checkLoginStatus()` 进行完整的异步检查
2. 包括从 SQLite 恢复和验证过期
3. 如果认证失败，自动跳转到登录页

**方式三：手动检查（用于特定逻辑）**

```dart
class SomePage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await checkAuthAndRedirect();
    if (isAuthenticated) {
      // 执行需要认证后的操作
    }
  }
}
```

### 4. 退出登录

```dart
await _authService.logout();
```

退出登录会：
- ✅ 清空内存中的 token
- ✅ 删除 SQLite 中的 token
- ✅ 清空 HTTP 请求头的 Authorization
- ✅ 跳转到登录页

## Token 过期处理

### 过期判断逻辑

```dart
// 在 token_dao.dart 中
Future<bool> isTokenExpired(String userId) async {
  final token = await getTokenByUserId(userId);
  if (token == null) return true;

  final createdAt = DateTime.parse(token['created_at']);
  final expiresIn = token['expires_in'] as int;
  final expiryTime = createdAt.add(Duration(seconds: expiresIn));
  
  // 提前 5 分钟视为过期（避免边界情况）
  final bufferTime = expiryTime.subtract(const Duration(minutes: 5));
  
  return DateTime.now().isAfter(bufferTime);
}
```

### 自动刷新机制（待实现）

TODO: 实现自动 token 刷新机制
- 当检测到 token 即将过期时
- 使用 refresh_token 请求新的 access_token
- 更新 SQLite 和内存中的 token

## 使用场景

### 场景 1：用户首次登录
1. 用户输入账号密码，点击登录
2. 调用后端 API `/api/Users/login`
3. 后端返回 token（access + refresh）
4. 自动保存到 SQLite
5. 自动加载到内存
6. 跳转到首页

### 场景 2：用户关闭应用后重新打开
1. 应用启动，执行 `AppInitService.initialize()`
2. 调用 `checkLoginStatus()` 从 SQLite 查询 token
3. 验证 token 是否过期
4. 如果有效，恢复到内存
5. 用户直接看到已登录状态，无需重新登录

### 场景 3：用户访问受保护页面
1. 用户点击导航到受保护页面
2. AuthMiddleware 拦截路由
3. 检查内存中是否有 token
4. 如果有，允许访问
5. 如果没有，重定向到登录页

### 场景 4：Token 过期
1. 应用启动时检测到 token 已过期
2. 自动删除过期的 token
3. 用户需要重新登录
4. 或者自动使用 refresh_token 刷新（待实现）

### 场景 5：用户主动退出
1. 用户点击退出按钮
2. 调用 `logout()` 方法
3. 清空内存和数据库中的 token
4. 跳转到登录页

## 数据库表结构

```sql
CREATE TABLE tokens (
  user_id TEXT PRIMARY KEY,
  access_token TEXT NOT NULL,
  refresh_token TEXT,
  token_type TEXT NOT NULL,
  expires_in INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

## 安全性考虑

1. **Token 存储**：SQLite 数据库文件存储在应用私有目录，其他应用无法访问
2. **过期验证**：提前 5 分钟视为过期，避免使用即将过期的 token
3. **自动清理**：检测到过期 token 会自动删除
4. **内存加密**：TODO - 考虑对内存中的 token 进行加密

## 调试日志

应用会输出详细的日志帮助调试：

```
🚀 开始初始化应用...
🔐 checkLoginStatus: 开始检查登录状态...
✅ 内存中已有 token
✅ 用户登录状态已恢复
✅ 应用初始化完成

🔒 AuthMiddleware: 检查路由 /cityDetail 的访问权限
   Token 状态: 有效
✅ Token 验证通过，允许访问
```

## API 参考

### NomadsAuthService

```dart
// 登录
Future<void> login(String email, String password)

// 退出登录
Future<void> logout()

// 检查登录状态（异步，完整检查）
Future<bool> checkLoginStatus()

// 检查是否已登录（同步，只检查内存）
bool isLoggedIn()

// 从数据库恢复 token（旧方法，建议使用 checkLoginStatus）
Future<bool> restoreToken()
```

### AppInitService

```dart
// 初始化应用（恢复登录状态）
Future<void> initialize()

// 是否已初始化
bool get isInitialized

// 重置初始化状态（用于测试）
void reset()
```

### AuthMiddleware & AuthGuard

```dart
// 中间件（用于路由）
middlewares: [AuthMiddleware()]

// Widget 包装器（用于页面）
AuthGuard(child: YourPage())

// 手动检查函数
await checkAuthAndRedirect()
```

## 总结

Token 验证流程确保了：
- ✅ 登录后 token 自动保存到 SQLite
- ✅ 应用启动时自动从 SQLite 恢复 token
- ✅ 访问受保护页面时验证 token 有效性
- ✅ Token 过期自动删除并要求重新登录
- ✅ 退出登录清空所有 token 数据

这个流程同时考虑了性能（内存缓存）和持久性（数据库存储），为用户提供流畅的登录体验。
