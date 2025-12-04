# 用户偏好设置持久化功能完成

## 功能概述

实现了用户偏好设置的数据库持久化功能，包括：
- 通知开关 (Notifications)
- 旅行历史可见性 (Travel History Visible)
- 个人资料公开 (Profile Public)
- 货币偏好 (Currency)
- 温度单位 (Temperature Unit)

## 技术架构

### 后端 (.NET C#)

1. **实体 (Entity)**
   - `UserPreferences.cs` - 用户偏好设置领域实体
   - 位置: `go-nomads/src/Services/UserService/UserService/Domain/Entities/`

2. **仓储接口 (Repository Interface)**
   - `IUserPreferencesRepository.cs`
   - 位置: `go-nomads/src/Services/UserService/UserService/Domain/Repositories/`

3. **仓储实现 (Repository Implementation)**
   - `UserPreferencesRepository.cs` - Supabase 实现
   - 位置: `go-nomads/src/Services/UserService/UserService/Infrastructure/Repositories/`

4. **DTO**
   - `UserPreferencesDto.cs` - 数据传输对象
   - `UpdateUserPreferencesRequest.cs` - 更新请求对象
   - 位置: `go-nomads/src/Services/UserService/UserService/Application/DTOs/`

5. **控制器 (Controller)**
   - `UserPreferencesController.cs`
   - 位置: `go-nomads/src/Services/UserService/UserService/API/Controllers/`
   - API 端点:
     - `GET /api/v1/users/me/preferences` - 获取当前用户偏好
     - `PUT /api/v1/users/me/preferences` - 更新偏好（完整更新）
     - `PATCH /api/v1/users/me/preferences` - 部分更新偏好
     - `GET /api/v1/users/{userId}/preferences` - 获取指定用户偏好

6. **依赖注入**
   - 在 `Program.cs` 中注册 `IUserPreferencesRepository`

### 前端 (Flutter)

1. **领域实体 (Domain Entity)**
   - `user_preferences.dart`
   - 位置: `df_admin_mobile/lib/features/user/domain/entities/`

2. **仓储接口 (Repository Interface)**
   - `i_user_preferences_repository.dart`
   - 位置: `df_admin_mobile/lib/features/user/domain/repositories/`

3. **仓储实现 (Repository Implementation)**
   - `user_preferences_repository.dart` - Dio HTTP 实现
   - 位置: `df_admin_mobile/lib/features/user/infrastructure/repositories/`

4. **依赖注入**
   - 在 `dependency_injection.dart` 中注册 `IUserPreferencesRepository`

5. **页面集成**
   - `profile_edit_page.dart` 已更新，支持：
     - 从数据库加载偏好设置
     - 实时保存偏好更改到数据库
     - 加载/保存状态指示器

### 数据库 (Supabase/PostgreSQL)

1. **迁移脚本**
   - `create_user_preferences_table.sql`
   - 位置: `go-nomads/migrations/`
   - 包含:
     - 表结构创建
     - 唯一约束（每用户一条记录）
     - 索引优化
     - 更新时间触发器
     - RLS (Row Level Security) 策略

## 使用方式

### 在 Profile Edit 页面

偏好设置会自动：
1. 页面加载时从数据库获取用户偏好
2. 每次更改开关/下拉框时自动保存到数据库
3. 显示加载/保存状态指示器

### API 调用示例

```dart
// 获取偏好
final prefs = await _preferencesRepository.getCurrentUserPreferences();

// 更新偏好
await _preferencesRepository.updatePreferences(
  notificationsEnabled: true,
  currency: 'CNY',
);
```

## 部署步骤

1. **数据库迁移**
   - 在 Supabase 中执行 `create_user_preferences_table.sql`

2. **后端部署**
   - 确保 `UserPreferencesRepository` 已在 DI 中注册
   - 部署 UserService

3. **前端部署**
   - 构建并部署 Flutter 应用

## 注意事项

1. 通知状态同时保存在本地 (SharedPreferences) 和数据库，确保离线时也能正常工作
2. 偏好设置使用 PATCH 请求进行部分更新，只发送变更的字段
3. 首次访问时会自动创建默认偏好记录

## 相关文件列表

### 后端
- `UserPreferences.cs`
- `IUserPreferencesRepository.cs`
- `UserPreferencesRepository.cs`
- `UserPreferencesDto.cs`
- `UpdateUserPreferencesRequest.cs`
- `UserPreferencesController.cs`
- `create_user_preferences_table.sql`

### 前端
- `user_preferences.dart`
- `i_user_preferences_repository.dart`
- `user_preferences_repository.dart`
- `dependency_injection.dart` (已更新)
- `profile_edit_page.dart` (已更新)
