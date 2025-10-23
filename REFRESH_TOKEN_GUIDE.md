# Refresh Token 功能说明

## 概述

Refresh Token 功能用于在 access_token 过期时自动获取新的 token，避免用户频繁重新登录。

## API 配置

### 端点信息
- **URL**: `/Users/refresh`
- **完整路径**: `http://localhost:5000/api/Users/refresh`
- **方法**: `GET`
- **参数**: `refreshToken` (query parameter)

### 配置位置
`lib/config/api_config.dart`:
```dart
static const String refreshTokenEndpoint = '/Users/refresh';
```

## 实现细节

### 1. refreshToken() 方法

```dart
Future<bool> refreshToken([String? userId]) async
```

**功能**：
- 使用 refresh_token 获取新的 access_token
- 自动更新数据库和内存中的 token

**参数**：
- `userId` (可选): 指定用户ID
- 如果不提供，会自动从数据库获取最新的 token

**返回值**：
- `true`: 刷新成功
- `false`: 刷新失败

**流程**：
1. 从数据库获取 refresh_token
2. 调用后端 GET `/Users/refresh?refreshToken=xxx`
3. 解析返回的新 token
4. 更新内存中的 access_token
5. 保存到 SQLite 数据库

**示例响应**：
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "new_access_token_here",
    "refreshToken": "new_refresh_token_here",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": "user123",
      "name": "John Doe",
      "email": "john@example.com"
    }
  }
}
```

### 2. 自动刷新集成

Token 刷新已集成到以下方法中：

#### restoreToken()
```dart
// 应用启动时恢复 token
final isExpired = await _tokenDao.isTokenExpired(userId);
if (isExpired) {
  print('⚠️ Token 已过期，尝试使用 refresh_token 刷新...');
  final refreshed = await refreshToken(userId);
  if (refreshed) {
    print('✅ Token 刷新成功，登录状态已恢复');
    return true;
  }
}
```

#### checkLoginStatus()
```dart
// 检查登录状态时自动刷新过期 token
final isExpired = await _tokenDao.isTokenExpired(userId);
if (isExpired) {
  print('⏰ Token 已过期，尝试使用 refresh_token 刷新...');
  final refreshed = await refreshToken(userId);
  if (refreshed) {
    return true;
  }
}
```

## 使用场景

### 场景 1：应用启动时自动刷新

```dart
// 在 AppInitService.initialize() 中
await AppInitService().initialize();
// 如果 token 过期，会自动调用 refreshToken()
```

**流程**：
1. 应用启动
2. 从 SQLite 恢复 token
3. 检测到 token 已过期
4. 自动使用 refresh_token 刷新
5. 更新 access_token
6. 用户无需重新登录

### 场景 2：手动刷新

```dart
final authService = NomadsAuthService();

// 方式1：刷新指定用户的 token
final success = await authService.refreshToken('user123');

// 方式2：刷新当前用户的 token（自动获取）
final success = await authService.refreshToken();

if (success) {
  print('Token 刷新成功');
} else {
  print('Token 刷新失败，需要重新登录');
  // 跳转到登录页
}
```

### 场景 3：API 请求时自动刷新（未来扩展）

TODO: 可以在 HTTP 拦截器中实现
```dart
// 在 http_service.dart 的错误拦截器中
if (response.statusCode == 401) {
  // Token 无效
  final refreshed = await _authService.refreshToken();
  if (refreshed) {
    // 重试原始请求
    return _retry(requestOptions);
  }
}
```

## 错误处理

### 刷新失败的原因

1. **refresh_token 不存在**
   ```
   ❌ refresh_token 不存在
   ```
   - 数据库中没有保存 refresh_token
   - 需要重新登录

2. **refresh_token 过期**
   ```
   ❌ Token 刷新失败: Token expired
   ```
   - refresh_token 本身已过期
   - 需要重新登录

3. **网络错误**
   ```
   ❌ 刷新 token 异常: Connection failed
   ```
   - 网络连接失败
   - 服务器无响应

4. **后端返回错误**
   ```
   ❌ Token 刷新失败: Invalid refresh token
   ```
   - refresh_token 无效
   - 需要重新登录

### 错误处理策略

```dart
try {
  final refreshed = await authService.refreshToken();
  if (!refreshed) {
    // 刷新失败，跳转到登录页
    Get.offAllNamed(AppRoutes.login);
  }
} catch (e) {
  // 异常处理
  print('Token 刷新异常: $e');
  Get.offAllNamed(AppRoutes.login);
}
```

## Token 有效期管理

### 过期判断

```dart
// 在 token_dao.dart 中
Future<bool> isTokenExpired(String userId) async {
  final token = await getTokenByUserId(userId);
  if (token == null) return true;

  final createdAt = DateTime.parse(token['created_at']);
  final expiresIn = token['expires_in'] as int;
  final expiryTime = createdAt.add(Duration(seconds: expiresIn));
  
  // 提前 5 分钟视为过期
  final bufferTime = expiryTime.subtract(const Duration(minutes: 5));
  
  return DateTime.now().isAfter(bufferTime);
}
```

### 提前刷新策略

- ✅ 在 token 过期前 5 分钟就视为已过期
- ✅ 避免在 API 请求中途 token 过期
- ✅ 提供更好的用户体验

## 调试日志

刷新 token 时会输出详细日志：

```
🔄 开始刷新 token...
📤 调用刷新 token 接口...
   接口: /Users/refresh
   refreshToken: eyJhbGciOiJIUzI1NiIs...
✅ 后端响应状态码: 200
✅ 后端响应数据: {success: true, message: Token refreshed, ...}
🎉 Token 刷新成功！
   新 Token: eyJhbGciOiJIUzI1NiIs...
💾 开始保存 token 到数据库...
✅ Token 已保存到 SQLite
```

## 安全建议

1. **Refresh Token 有效期**
   - 建议 refresh_token 有效期设置为 7-30 天
   - access_token 有效期设置为 15-60 分钟

2. **Token 轮换**
   - 每次刷新时，后端应该返回新的 refresh_token
   - 旧的 refresh_token 应该失效

3. **单设备限制**
   - 可以限制一个 refresh_token 只能在一个设备上使用
   - 在新设备登录时，旧设备的 token 自动失效

4. **HTTPS 传输**
   - 生产环境必须使用 HTTPS
   - 避免 token 在传输过程中被窃取

## API 参考

### NomadsAuthService

```dart
// 刷新指定用户的 token
Future<bool> refreshToken([String? userId])

// 检查登录状态（自动刷新过期 token）
Future<bool> checkLoginStatus()

// 恢复 token（自动刷新过期 token）
Future<bool> restoreToken()
```

### TokenDao

```dart
// 检查 token 是否过期
Future<bool> isTokenExpired(String userId)

// 获取指定用户的 token
Future<Map<String, dynamic>?> getTokenByUserId(String userId)

// 获取最新的 token
Future<Map<String, dynamic>?> getLatestToken()
```

## 测试建议

### 测试场景

1. **正常刷新**
   - 手动修改数据库中的 created_at 为 1 小时前
   - 重启应用，应该自动刷新 token

2. **刷新失败**
   - 删除数据库中的 refresh_token
   - 尝试刷新，应该返回失败

3. **网络异常**
   - 断开网络连接
   - 尝试刷新，应该捕获异常

4. **过期边界**
   - 设置 token 在 4 分钟后过期
   - 应该被判定为已过期（5 分钟缓冲）

### 测试代码示例

```dart
void testRefreshToken() async {
  final authService = NomadsAuthService();
  
  // 测试 1: 正常刷新
  print('测试 1: 正常刷新');
  final result1 = await authService.refreshToken();
  assert(result1 == true, '刷新应该成功');
  
  // 测试 2: 无效的 refresh_token
  print('测试 2: 无效的 refresh_token');
  await TokenDao().deleteAllTokens();
  final result2 = await authService.refreshToken();
  assert(result2 == false, '刷新应该失败');
}
```

## 总结

Refresh Token 功能现已完全实现：

- ✅ 调用后端 GET `/Users/refresh` 接口
- ✅ 使用 refresh_token 作为 query parameter
- ✅ 自动更新 access_token 和 refresh_token
- ✅ 集成到应用启动流程
- ✅ 集成到登录状态检查
- ✅ 详细的错误处理和日志
- ✅ 提前 5 分钟的过期缓冲

用户体验：
- 🎯 Token 过期时自动刷新，无需重新登录
- 🎯 应用启动时自动恢复登录状态
- 🎯 刷新失败时提示重新登录
- 🎯 完整的调试日志帮助排查问题
