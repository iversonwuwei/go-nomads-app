# Logout 用户数据清除问题修复

## 问题描述

用户切换账号后，仍然使用旧用户的 ID 查询通知列表，导致新用户看不到自己的通知。

## 根本原因

1. `profile_page.dart` 的 `_performLogout` 方法没有调用完整的 logout 链路
2. `user_local_repository.dart` 的 `clearUserData()` 方法没有清除 SQLite 数据库中的用户信息
3. `NotificationStateController` 的状态没有在 logout 时清除

## 修复内容

### 1. 修复 `profile_page.dart` 的 `_performLogout`

```dart
Future<void> _performLogout() async {
  try {
    print('🚪 开始执行退出登录...');
    
    final authController = Get.find<AuthStateController>();
    final userStateController = Get.find<UserStateController>();
    
    // 调用 AuthStateController 的 logout 方法
    await authController.logout();
    
    // 清除 UserStateController 状态
    userStateController.clearUser();
    
    // 清除通知控制器状态
    if (Get.isRegistered<NotificationStateController>()) {
      Get.find<NotificationStateController>().clearNotifications();
    }
    
    // 跳转到登录页
    Get.offAllNamed(AppRoutes.login);
  } catch (e) {
    // ...
  }
}
```

### 2. 修复 `user_local_repository.dart` 的 `clearUserData()`

```dart
Future<void> clearUserData() async {
  try {
    // 1. 先获取当前用户ID（在清除 token 之前）
    final userId = await _tokenStorage.getUserId();
    
    // 2. 清除 SQLite 中的当前用户数据
    if (userId != null) {
      final database = await _db.database;
      await database.delete('users', where: 'id = ?', whereArgs: [userId]);
      print('✅ SQLite 用户数据已清除: $userId');
    }
    
    // 3. 清除 SharedPreferences（token + 用户信息）
    await _tokenStorage.clearTokens();
    
    print('✅ 用户数据已完全清除');
  } catch (e) {
    print('❌ 清除用户数据失败: $e');
    // 确保即使出错也尝试清除 token
    try {
      await _tokenStorage.clearTokens();
    } catch (_) {}
  }
}
```

### 3. 添加 `NotificationStateController.clearNotifications()`

```dart
void clearNotifications() {
  print('🔔 清除通知状态');
  notifications.clear();
  unreadCount.value = 0;
  isLoading.value = false;
  errorMessage.value = '';
}
```

## Logout 完整清除链路

```
_performLogout() [profile_page.dart]
  ↓
authController.logout() [auth_state_controller.dart]
  ├── 删除数据库中的 token
  ├── _logoutUseCase.execute()
  │     ↓
  │   _authRepository.logout() [auth_repository.dart]
  │     ├── _userLocalRepo.clearUserData()
  │     │     ├── 获取当前用户 ID
  │     │     ├── 清除 SQLite 用户数据 ✅ 新增
  │     │     └── 清除 SharedPreferences (tokens)
  │     └── clearPersistedToken() (备用)
  │
  ├── httpService.clearAuthToken()
  └── httpService.clearUserId()
  ↓
userStateController.clearUser() [user_state_controller.dart]
  ↓
notificationController.clearNotifications() [notification_state_controller.dart] ✅ 新增
  ↓
Get.offAllNamed(AppRoutes.login)
```

## 清除的数据

### SharedPreferences
- `auth_token` - JWT 访问令牌
- `refresh_token` - 刷新令牌
- `token_expires_at` - 令牌过期时间
- `user_role` - 用户角色
- `user_id` - 用户ID
- `user_name` - 用户名
- `user_email` - 用户邮箱

### SQLite 数据库
- `users` 表中当前用户的记录

### 内存状态
- `HttpService._authToken` → null
- `HttpService._userId` → null
- `AuthStateController.currentUser` → null
- `AuthStateController.currentToken` → null
- `AuthStateController.isAuthenticated` → false
- `UserStateController.currentUser` → null
- `NotificationStateController.notifications` → []
- `NotificationStateController.unreadCount` → 0

## 测试步骤

1. 使用账号 A 登录
2. 进入个人资料页
3. 点击退出登录
4. 检查控制台日志确认数据已清除
5. 使用账号 B（admin 账号 walden.wuwei@gmail.com）登录
6. 进入通知页面
7. 确认看到的是账号 B 的通知，而不是账号 A 的

## 完成日期

2024-01-XX
