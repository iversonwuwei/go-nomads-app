# 通知系统集成指南

## 📋 功能概述

完整的应用内通知系统，支持：
- ✅ 版主申请通知（发送给管理员）
- ✅ 审核结果通知（发送给申请人）
- ✅ 城市更新通知
- ✅ 系统公告
- ✅ 未读数量Badge显示
- ✅ 消息持久化到数据库
- ✅ 下拉刷新
- ✅ 滑动删除
- ✅ 点击标记已读

## 📂 已创建的文件

### 1. 实体层（Domain）
```
lib/features/notification/domain/entities/app_notification.dart
lib/features/notification/domain/repositories/i_notification_repository.dart
```

### 2. 仓储层（Infrastructure）
```
lib/features/notification/infrastructure/repositories/notification_repository.dart
```

### 3. 表现层（Presentation）
```
lib/features/notification/presentation/controllers/notification_state_controller.dart
lib/pages/notifications_page.dart
lib/widgets/notification_button.dart
```

## 🔧 集成步骤

### 步骤 1: 添加依赖注入

编辑 `lib/core/di/dependency_injection.dart`，在导入部分添加：

```dart
// Notification Domain
import '../../features/notification/domain/repositories/i_notification_repository.dart';
import '../../features/notification/infrastructure/repositories/notification_repository.dart';
import '../../features/notification/presentation/controllers/notification_state_controller.dart';
```

在 `_registerInfrastructure()` 方法后添加新方法：

```dart
  /// 注册通知领域依赖
  static void _registerNotificationDomain() {
    // Repository
    Get.lazyPut<INotificationRepository>(
      () => NotificationRepository(Get.find<HttpService>()),
    );

    // Controller
    Get.put(
      NotificationStateController(Get.find<INotificationRepository>()),
      permanent: true, // 持久化，不会被销毁
    );
  }
```

在 `init()` 方法中调用：

```dart
static Future<void> init() async {
  print('🎯 开始DDD依赖注入初始化...');

  _registerInfrastructure();
  _registerUserDomain();
  _registerAuthDomain();
  _registerCityDomain();
  _registerWeatherDomain();
  _registerAIDomain();
  _registerMeetupDomain();
  _registerChatDomain();
  _registerCommunityDomain();
  _registerInterestDomain();
  _registerSkillDomain();
  _registerUserCityContentDomain();
  _registerLocationDomain();
  _registerInnovationProjectDomain();
  _registerCoworkingDomain();
  _registerHotelDomain();
  _registerNotificationDomain(); // 👈 添加这一行

  print('✅ DDD依赖注入初始化完成!');
}
```

### 步骤 2: 添加路由

编辑 `lib/routes/app_routes.dart`，添加通知页面路由：

```dart
import '../pages/notifications_page.dart';

class AppRoutes {
  static const String notifications = '/notifications';
  
  static final routes = [
    GetPage(
      name: notifications,
      page: () => const NotificationsPage(),
    ),
    // ... 其他路由
  ];
}
```

### 步骤 3: 在顶部栏添加通知按钮

找到你的主页面 AppBar（如 `home_page.dart` 或 `main_layout.dart`），添加通知按钮：

```dart
import '../widgets/notification_button.dart';

AppBar(
  title: const Text('GO-NOMADS'),
  actions: [
    // 通知按钮（带未读数量徽章）
    const NotificationButton(),
    
    // 其他按钮...
  ],
)
```

### 步骤 4: 后端 API 端点（需要实现）

后端需要提供以下 API 端点：

#### 4.1 获取用户通知列表
```http
GET /api/v1/notifications?isRead=false&type=moderator_application&limit=50&offset=0
Authorization: Bearer {token}

Response:
[
  {
    "id": "notification_123",
    "userId": "user_456",
    "title": "新的版主申请",
    "message": "用户申请成为 Tokyo 的版主，请及时审核",
    "type": "moderator_application",
    "relatedId": "city_789",
    "metadata": {
      "cityName": "Tokyo",
      "cityId": "city_789"
    },
    "isRead": false,
    "createdAt": "2025-01-13T10:30:00Z",
    "readAt": null
  }
]
```

#### 4.2 获取未读数量
```http
GET /api/v1/notifications/unread/count
Authorization: Bearer {token}

Response:
{
  "count": 5
}
```

#### 4.3 标记为已读
```http
PUT /api/v1/notifications/{notificationId}/read
Authorization: Bearer {token}

Response:
{
  "success": true
}
```

#### 4.4 标记所有为已读
```http
PUT /api/v1/notifications/read/all
Authorization: Bearer {token}

Response:
{
  "success": true
}
```

#### 4.5 删除通知
```http
DELETE /api/v1/notifications/{notificationId}
Authorization: Bearer {token}

Response:
{
  "success": true
}
```

#### 4.6 发送通知给管理员
```http
POST /api/v1/notifications/admins
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "新的版主申请",
  "message": "用户申请成为 Tokyo 的版主，请及时审核",
  "type": "moderator_application",
  "relatedId": "city_789",
  "metadata": {
    "cityName": "Tokyo",
    "cityId": "city_789"
  }
}

Response:
[
  {
    "id": "notification_123",
    "userId": "admin_1",
    // ... 其他字段
  },
  {
    "id": "notification_124",
    "userId": "admin_2",
    // ... 其他字段
  }
]
```

## 📊 数据库表设计（参考）

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id VARCHAR(100),
    metadata JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    read_at TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at DESC)
);
```

## 🎯 使用示例

### 1. 用户申请版主时发送通知

已在 `city_detail_page.dart` 的 `_handleApplyModerator()` 方法中集成：

```dart
// 发送通知给所有管理员
if (Get.isRegistered<NotificationStateController>()) {
  final notificationController = Get.find<NotificationStateController>();
  
  await notificationController.sendToAdmins(
    title: '新的版主申请',
    message: '用户申请成为 Tokyo 的版主，请及时审核',
    type: NotificationType.moderatorApplication,
    relatedId: cityId,
    metadata: {
      'cityName': city?.name ?? '',
      'cityId': cityId,
    },
  );
}
```

### 2. 审核通过后发送通知给申请人

```dart
final notificationRepo = Get.find<INotificationRepository>();

await notificationRepo.sendNotification(
  recipientUserId: applicantUserId,
  title: '版主申请已通过',
  message: '恭喜！您已成为 Tokyo 的版主',
  type: NotificationType.moderatorApproved,
  relatedId: cityId,
  metadata: {
    'cityName': 'Tokyo',
  },
);
```

### 3. 审核拒绝后发送通知

```dart
await notificationRepo.sendNotification(
  recipientUserId: applicantUserId,
  title: '版主申请未通过',
  message: '很抱歉，您的版主申请未通过审核',
  type: NotificationType.moderatorRejected,
  relatedId: cityId,
);
```

## 🎨 UI 效果

### 通知按钮
- 无未读：灰色铃铛图标
- 有未读：橙色铃铛 + 红色数字徽章

### 通知列表
- 三个Tab：全部、未读、已读
- 未读通知：淡橙色背景 + 橙色边框 + 蓝点标记
- 已读通知：白色背景 + 灰色边框
- 滑动删除：从右向左滑动显示红色删除背景
- 下拉刷新：支持下拉刷新列表

### 通知类型图标
- 📝 版主申请
- ✅ 申请通过
- ❌ 申请拒绝
- 🌆 城市更新
- 📢 系统公告
- 🔔 其他

## 🔐 权限控制

### 发送通知权限
- 普通用户：只能触发发送给管理员的通知（如申请版主）
- 管理员：可以发送任何类型的通知

### 查看通知权限
- 每个用户只能看到自己的通知
- 后端需要通过 JWT Token 验证用户身份

## 🚀 测试步骤

### 1. 前端测试
```bash
# 运行 Flutter 应用
flutter run

# 测试流程：
1. 登录应用
2. 查看顶部栏是否有通知按钮
3. 进入某个城市详情页
4. 点击"申请成为版主"
5. 确认申请
6. 查看顶部通知按钮是否有徽章（如果你是管理员）
7. 点击通知按钮进入通知列表
8. 测试：下拉刷新、点击标记已读、滑动删除
```

### 2. 后端测试

使用 curl 或 Postman 测试 API：

```bash
# 获取通知列表
curl -X GET http://localhost:5000/api/v1/notifications \
  -H "Authorization: Bearer {your_token}"

# 标记已读
curl -X PUT http://localhost:5000/api/v1/notifications/{id}/read \
  -H "Authorization: Bearer {your_token}"

# 发送给管理员
curl -X POST http://localhost:5000/api/v1/notifications/admins \
  -H "Authorization: Bearer {your_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试通知",
    "message": "这是一条测试消息",
    "type": "moderator_application"
  }'
```

## ⚠️ 注意事项

1. **依赖包**：需要添加 `timeago: ^3.6.0` 到 `pubspec.yaml`
2. **路由配置**：确保在路由配置中添加了 `/notifications` 路由
3. **权限验证**：后端需要验证用户是否为管理员才能查看版主申请通知
4. **性能优化**：建议添加分页加载，避免一次加载太多通知
5. **推送通知**：如需要真实推送通知（离线也能收到），需要集成 FCM（Firebase Cloud Messaging）

## 📝 待实现功能

- [ ] 后端 API 实现（Notification Controller）
- [ ] 数据库表创建和迁移
- [ ] 管理员审核页面（查看所有版主申请）
- [ ] 推送通知集成（FCM）
- [ ] 通知分页加载
- [ ] 通知搜索和筛选
- [ ] 通知设置页面（允许用户选择接收哪些类型的通知）

## 🎉 完成状态

- ✅ Flutter 前端实体、仓储、控制器
- ✅ 通知列表页面 UI
- ✅ 通知按钮 Widget
- ✅ 版主申请时发送通知集成
- ⏳ 后端 API 实现
- ⏳ 依赖注入配置
- ⏳ 路由配置

---

**实现日期**: 2025-01-13  
**修改文件**: 7 个新文件 + 1 个修改（city_detail_page.dart）  
**架构**: DDD（领域驱动设计）
