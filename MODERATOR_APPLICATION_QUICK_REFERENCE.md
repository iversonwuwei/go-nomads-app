# 版主申请系统 - 快速参考

## 🚀 快速开始

### 1. 数据库迁移 (必须先执行)
```sql
-- 在 Supabase SQL Editor 中执行
-- 文件位置: go-noma/database/migrations/create_moderator_applications.sql
```

### 2. 后端部署
```bash
cd go-noma
./deploy.sh
```

### 3. Flutter 路由配置
```dart
// 在 app_routes.dart 中添加
GetPage(
  name: '/apply-moderator',
  page: () => ApplyModeratorPage(city: Get.arguments),
),
GetPage(
  name: '/moderator-applications',
  page: () => const ModeratorApplicationListPage(),
),
```

---

## 📱 在 Flutter 中使用

### 用户申请成为版主
```dart
// 跳转到申请页面
Get.to(() => ApplyModeratorPage(city: selectedCity));

// 或使用路由
Get.toNamed('/apply-moderator', arguments: selectedCity);
```

### 管理员审核页面
```dart
// 跳转到审核页面
Get.to(() => const ModeratorApplicationListPage());

// 或使用路由
Get.toNamed('/moderator-applications');
```

### 使用控制器
```dart
// 获取控制器
final controller = Get.find<ModeratorApplicationController>();

// 申请
await controller.applyForModerator(
  cityId: 'uuid',
  reason: '申请理由...',
);

// 查看我的申请
await controller.loadMyApplications();
List<ModeratorApplication> myApps = controller.myApplications.value;

// 管理员操作
await controller.loadPendingApplications();
await controller.handleApplication(
  applicationId: 'uuid',
  action: 'approve', // or 'reject'
);
```

---

## 🔌 API 端点

### 基础 URL
```
http://localhost:5001/api/v1/cities/moderator
```

### 用户端点
```
POST   /apply                      # 申请
GET    /applications/my             # 我的申请
GET    /applications/{id}           # 申请详情
```

### 管理员端点
```
GET    /applications/pending        # 待处理 (需要 Admin 角色)
POST   /handle                      # 处理申请 (需要 Admin 角色)
GET    /applications/statistics     # 统计 (需要 Admin 角色)
```

---

## 🧪 测试命令

### 用户申请
```bash
curl -X POST http://localhost:5001/api/v1/cities/moderator/apply \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"city_id":"uuid","reason":"申请理由..."}'
```

### 管理员通过
```bash
curl -X POST http://localhost:5001/api/v1/cities/moderator/handle \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"application_id":"uuid","action":"approve"}'
```

### 管理员拒绝
```bash
curl -X POST http://localhost:5001/api/v1/cities/moderator/handle \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"application_id":"uuid","action":"reject","rejection_reason":"原因"}'
```

---

## 🔔 SignalR 监听

### 在 NotificationService 中添加
```dart
hubConnection.on('ReceiveNotification', (arguments) {
  final data = arguments[0] as Map<String, dynamic>;
  final type = data['type'] as String;
  
  switch (type) {
    case 'moderator_application':
      // 管理员收到新申请
      _handleNewApplication(data);
      break;
    case 'moderator_approved':
      // 申请已通过
      Get.snackbar('🎉 恭喜', '您已成为版主!');
      break;
    case 'moderator_rejected':
      // 申请被拒绝
      final reason = data['data']['rejection_reason'];
      _handleRejection(reason);
      break;
  }
});
```

---

## 📊 数据库表结构

### moderator_applications
```sql
id              UUID PRIMARY KEY
user_id         UUID (外键 users.id)
city_id         UUID (外键 cities.id)
reason          TEXT (申请理由)
status          VARCHAR(20) (pending/approved/rejected)
processed_by    UUID (处理人 ID)
processed_at    TIMESTAMP (处理时间)
rejection_reason TEXT (拒绝原因)
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

### 索引
- `idx_moderator_applications_user_id`
- `idx_moderator_applications_city_id`
- `idx_moderator_applications_status`
- `idx_moderator_applications_created_at`

---

## ✅ 完整文件列表

### 后端 (8 个文件)
1. `ModeratorApplication.cs` - 实体
2. `IModeratorApplicationRepository.cs` - 仓储接口
3. `ModeratorApplicationRepository.cs` - 仓储实现
4. `ModeratorApplicationDto.cs` - DTO
5. `IModeratorApplicationService.cs` - 服务接口
6. `ModeratorApplicationService.cs` - 服务实现
7. `ModeratorApplicationController.cs` - API 控制器
8. `Program.cs` - DI 配置 (已更新)

### 数据库 (1 个文件)
1. `create_moderator_applications.sql` - 迁移脚本

### 前端 (6 个文件 + 1 更新)
1. `moderator_application.dart` - 实体
2. `i_moderator_application_repository.dart` - 仓储接口
3. `moderator_application_repository.dart` - 仓储实现
4. `moderator_application_controller.dart` - 控制器
5. `moderator_application_list_page.dart` - 审核页面
6. `apply_moderator_page.dart` - 申请页面 (已更新)
7. `dependency_injection.dart` - DI 配置 (已更新)

---

## 🎯 下一步

1. ✅ 代码完成
2. ⏳ 执行数据库迁移
3. ⏳ 部署服务
4. ⏳ 测试 API
5. ⏳ 实现 SignalR 监听
6. ⏳ 添加路由配置
7. ⏳ 添加权限检查

---

**文档更新**: 2024-01-XX  
**状态**: ✅ 开发完成,等待部署
