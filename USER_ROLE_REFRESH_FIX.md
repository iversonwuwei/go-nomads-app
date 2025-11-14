# 用户角色刷新修复

## 问题描述

用户通过后端 API 更新角色(如从 `user` 改为 `admin`)后,Flutter 应用仍然显示旧的角色,导致权限相关的 UI 元素(如 city detail 页面的添加按钮)不显示。

## 根本原因

Flutter 应用在登录时将用户角色缓存在 `SharedPreferences` 中(通过 `TokenStorageService.saveUserInfo()`):
- 登录时:从后端 `/api/v1/auth/login` 获取 `user.role` 并保存到本地
- 角色更新后:后端数据库已更新,但 Flutter 应用的 SharedPreferences 缓存未更新
- 权限检查:`TokenStorageService.isAdmin()` 读取的是本地缓存的旧角色

```dart
// city_detail_page.dart
Future<bool> _checkIsAdmin() async {
  final tokenService = TokenStorageService();
  return await tokenService.isAdmin(); // ❌ 读取的是登录时缓存的旧角色
}
```

## 解决方案

### 1. 修改 `auth_repository.dart` - 自动更新本地缓存

修改 `getCurrentUser()` 方法,在从 API 获取用户信息后,自动更新 SharedPreferences 中的角色:

```dart
@override
Future<Result<AuthUser>> getCurrentUser() async {
  return execute(() async {
    final response = await _httpService.get(ApiConfig.userMeEndpoint);

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final userDto = AuthUserDto.fromJson(data);
      final user = userDto.toDomain();
      
      // ✅ 更新本地缓存的用户信息(包括角色)
      await _userLocalRepo.saveUser(user);
      
      return user;
    } else {
      throw ServerException('获取用户信息失败');
    }
  });
}
```

### 2. 修改 `auth_state_controller.dart` - 应用启动时自动刷新

启用 `_checkLoginStatusWithDatabase()` 中的 `_loadCurrentUser()` 调用:

```dart
Future<void> _checkLoginStatusWithDatabase() async {
  final result = await _checkLoginStatusWithDatabaseUseCase.execute(NoParams());
  result.fold(
    onSuccess: (isAuth) {
      isAuthenticated.value = isAuth;
      if (isAuth) {
        // ✅ 加载并刷新用户信息(会更新本地缓存的角色)
        _loadCurrentUser();
        _autoRefreshToken();
      }
    },
    onFailure: (_) => isAuthenticated.value = false,
  );
}
```

## 使用方法

### 方法 1: 重启应用(推荐)

1. 后台更新用户角色(如通过 API: `PATCH /api/v1/users/{id}/role`)
2. 用户关闭并重新打开应用
3. 应用启动时会自动调用 `/api/v1/users/me` 获取最新角色
4. 本地 SharedPreferences 自动更新为最新角色

### 方法 2: 重新登录

1. 用户退出登录
2. 重新登录
3. 登录时会从后端获取最新角色并保存到本地

### 方法 3: 手动刷新(代码中调用)

在任何需要刷新用户信息的地方调用:

```dart
final authController = Get.find<AuthStateController>();
await authController.refreshCurrentUser();
```

## 验证步骤

### 1. 更新用户角色

```bash
curl -X PATCH http://localhost:5001/api/v1/users/{userId}/role \
  -H "Content-Type: application/json" \
  -H "X-User-Id: {adminUserId}" \
  -H "X-User-Role: admin" \
  -d '{"roleId": "3629ff78-6d58-4b91-ad7e-d6a1bcca3bb3"}'
```

### 2. 验证后端已更新

```bash
curl -X GET http://localhost:5001/api/v1/users/me \
  -H "X-User-Id: {userId}" | jq '.data.role'
# 应该返回: "admin"
```

### 3. 重启 Flutter 应用

- 完全关闭应用
- 重新打开
- 检查 city detail 页面的添加按钮是否显示

## 技术细节

### API 端点
- **登录**: `POST /api/v1/auth/login` - 返回 user.role
- **获取当前用户**: `GET /api/v1/users/me` - 返回最新的 user.role
- **更新用户角色**: `PATCH /api/v1/users/{id}/role` - 需要 admin 权限

### 角色存储层次
1. **数据库(Supabase)**: 真实数据源,通过 `users.role_id` 外键关联到 `roles` 表
2. **后端 API**: 返回角色名称(如 "admin", "user", "moderator")
3. **Flutter SharedPreferences**: 缓存角色名称供快速权限检查
4. **Flutter SQLite**: 缓存用户完整信息(不包括 role,role 从 SharedPreferences 读取)

### 权限检查流程
```
城市详情页 → _checkIsAdmin() → TokenStorageService.isAdmin()
  → SharedPreferences.getString('user_role') → 比较 role == 'admin'
```

## 影响范围

以下功能会受益于这次修复:
- ✅ City detail 页面的添加按钮(Cowork、Visa、Cost 等)
- ✅ 所有依赖 `TokenStorageService.isAdmin()` 的权限检查
- ✅ 所有使用 `AuthStateController.currentUser.value.role` 的地方

## 注意事项

1. **网络连接要求**: 应用启动时需要网络连接才能刷新用户信息
2. **Token 有效性**: 如果 token 过期,需要先刷新 token 再获取用户信息
3. **离线模式**: 如果应用离线启动,会继续使用缓存的旧角色(直到下次在线刷新)

## 后续优化建议

1. **实时同步**: 使用 WebSocket 或 SignalR 推送角色变更通知
2. **定期刷新**: 在应用前台时定期(如每小时)刷新一次用户信息
3. **手动刷新按钮**: 在用户设置页面添加"刷新账户信息"按钮

## 相关文件

- `lib/services/token_storage_service.dart` - 角色缓存服务
- `lib/features/auth/infrastructure/repositories/auth_repository.dart` - 认证仓储(已修改)
- `lib/features/auth/infrastructure/repositories/user_local_repository.dart` - 本地用户数据仓储
- `lib/features/auth/presentation/controllers/auth_state_controller.dart` - 认证状态控制器(已修改)
- `lib/pages/city_detail_page.dart` - 城市详情页面(权限检查)

## 测试清单

- [x] 修改 `auth_repository.dart` 的 `getCurrentUser()` 方法
- [x] 修改 `auth_state_controller.dart` 的 `_checkLoginStatusWithDatabase()` 方法
- [x] 验证 Flutter 代码没有语法错误
- [ ] 后端更新用户角色为 admin
- [ ] 重启 Flutter 应用
- [ ] 登录并检查 city detail 页面添加按钮是否显示
- [ ] 验证其他权限相关功能是否正常

## 修复日期
2025-11-14

## 修复人员
GitHub Copilot (Claude Sonnet 4.5)
