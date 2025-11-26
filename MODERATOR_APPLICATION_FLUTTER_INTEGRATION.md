# 版主申请系统 - Flutter 集成完成

## 📋 概览

已完成版主申请系统的 Flutter 客户端开发,包括:

1. ✅ **领域实体** - ModeratorApplication
2. ✅ **仓储接口和实现** - IModeratorApplicationRepository + ModeratorApplicationRepository
3. ✅ **状态控制器** - ModeratorApplicationController
4. ✅ **用户申请页面** - ApplyModeratorPage
5. ✅ **管理员审核页面** - ModeratorApplicationListPage
6. ✅ **依赖注入配置** - dependency_injection.dart

---

## 🗂️ 文件结构

```
lib/
├── features/
│   └── moderator/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── moderator_application.dart          # 版主申请实体
│       │   └── repositories/
│       │       └── i_moderator_application_repository.dart  # 仓储接口
│       ├── infrastructure/
│       │   └── repositories/
│       │       └── moderator_application_repository.dart    # 仓储实现
│       └── presentation/
│           ├── controllers/
│           │   └── moderator_application_controller.dart    # 状态控制器
│           └── pages/
│               └── moderator_application_list_page.dart     # 管理员审核页面
├── pages/
│   └── apply_moderator_page.dart                        # 用户申请页面
└── core/
    └── di/
        └── dependency_injection.dart                    # 依赖注入 (已更新)
```

---

## 🎯 功能说明

### 1. 用户申请成为版主 (ApplyModeratorPage)

**位置**: `lib/pages/apply_moderator_page.dart`

**功能**:
- 显示城市信息卡片
- 列出版主职责清单
- 提供申请理由输入框 (20-500字)
- 表单验证和提交

**使用方式**:
```dart
// 在城市详情页或其他地方跳转
Get.to(() => ApplyModeratorPage(city: selectedCity));
```

**API 调用**:
```
POST /api/v1/cities/moderator/apply
Body: {
  "city_id": "uuid",
  "reason": "申请理由文本..."
}
```

---

### 2. 管理员审核页面 (ModeratorApplicationListPage)

**位置**: `lib/features/moderator/presentation/pages/moderator_application_list_page.dart`

**功能**:
- 展示所有待处理申请列表
- 显示申请人头像、姓名、申请时间
- 显示申请城市和理由
- 提供"通过"和"拒绝"操作
- 拒绝时可输入原因
- 下拉刷新

**使用方式**:
```dart
// 仅限管理员访问
Get.to(() => const ModeratorApplicationListPage());
```

**API 调用**:
- 获取列表: `GET /api/v1/cities/moderator/applications/pending?page=1&page_size=20`
- 通过申请: `POST /api/v1/cities/moderator/handle` (action: "approve")
- 拒绝申请: `POST /api/v1/cities/moderator/handle` (action: "reject", rejection_reason)

---

## 🔧 控制器方法

### ModeratorApplicationController

```dart
// 申请成为版主
await controller.applyForModerator(
  cityId: 'city-uuid',
  reason: '我有丰富的社区管理经验...',
);

// 加载我的申请列表
await controller.loadMyApplications();

// 加载待处理申请 (管理员)
await controller.loadPendingApplications(page: 1, pageSize: 20);

// 处理申请 (管理员)
await controller.handleApplication(
  applicationId: 'application-uuid',
  action: 'approve', // or 'reject'
  rejectionReason: '可选拒绝原因',
);

// 加载统计数据 (管理员)
await controller.loadStatistics();
```

### 响应式状态

```dart
// 加载状态
controller.isLoading.value

// 我的申请列表
controller.myApplications.value

// 待处理申请列表
controller.pendingApplications.value

// 统计数据
controller.statistics.value
```

---

## 📊 数据实体

### ModeratorApplication

```dart
class ModeratorApplication {
  final String id;
  final String userId;
  final String cityId;
  final String reason;
  final String status;  // 'pending', 'approved', 'rejected'
  final String? processedBy;
  final DateTime? processedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 关联数据
  final String? userName;
  final String? userAvatar;
  final String? cityName;
  final String? cityNameEn;
  
  // 辅助方法
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  String get statusText; // '待审核', '已通过', '已拒绝'
}
```

---

## 🚀 集成步骤

### 1. 在路由中添加页面

```dart
// 用户申请页面
GetPage(
  name: '/apply-moderator',
  page: () => ApplyModeratorPage(
    city: Get.arguments as City,
  ),
),

// 管理员审核页面 (需要管理员权限)
GetPage(
  name: '/moderator-applications',
  page: () => const ModeratorApplicationListPage(),
  middlewares: [AdminMiddleware()],
),
```

### 2. 在城市详情页添加申请入口

```dart
// 检查用户是否已是该城市版主
if (!isAlreadyModerator) {
  ElevatedButton(
    onPressed: () {
      Get.to(() => ApplyModeratorPage(city: currentCity));
    },
    child: const Text('申请成为版主'),
  );
}
```

### 3. 在管理员菜单添加审核入口

```dart
// 管理员专用菜单项
if (isAdmin) {
  ListTile(
    leading: const Icon(Icons.assignment),
    title: const Text('版主申请审核'),
    onTap: () {
      Get.to(() => const ModeratorApplicationListPage());
    },
  );
}
```

---

## 🔔 SignalR 通知集成 (待实现)

### 需要监听的通知类型

1. **moderator_application** - 新的版主申请 (发送给所有管理员)
2. **moderator_approved** - 申请已通过 (发送给申请人)
3. **moderator_rejected** - 申请已拒绝 (发送给申请人)

### 实现示例

```dart
// 在 NotificationService 中添加
hubConnection.on('ReceiveNotification', (arguments) {
  final notification = arguments[0] as Map<String, dynamic>;
  final type = notification['type'] as String;
  
  switch (type) {
    case 'moderator_application':
      // 管理员收到新申请通知
      _showAdminNotification(notification);
      break;
      
    case 'moderator_approved':
      // 申请人收到通过通知
      _showSuccessNotification('🎉 恭喜!您已成为版主');
      break;
      
    case 'moderator_rejected':
      // 申请人收到拒绝通知
      final reason = notification['data']['rejection_reason'];
      _showRejectionNotification(reason);
      break;
  }
});
```

---

## ✅ 测试清单

### 用户端测试

- [ ] 打开申请页面,显示城市信息
- [ ] 输入少于20字,提示错误
- [ ] 输入超过500字,提示错误
- [ ] 提交申请成功
- [ ] 重复申请同一城市,后端返回错误
- [ ] 查看"我的申请"列表
- [ ] 收到通过/拒绝通知

### 管理员端测试

- [ ] 打开审核列表,显示所有待处理申请
- [ ] 点击"通过"按钮,确认对话框
- [ ] 通过申请成功,列表自动刷新
- [ ] 点击"拒绝"按钮,输入拒绝原因
- [ ] 拒绝申请成功,列表自动刷新
- [ ] 下拉刷新列表
- [ ] 收到新申请通知

### API 测试

```bash
# 1. 用户申请
curl -X POST http://localhost:5001/api/v1/cities/moderator/apply \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "city_id": "city-uuid",
    "reason": "我有丰富的社区管理经验..."
  }'

# 2. 查看我的申请
curl -X GET http://localhost:5001/api/v1/cities/moderator/applications/my \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. 管理员查看待处理申请
curl -X GET "http://localhost:5001/api/v1/cities/moderator/applications/pending?page=1&page_size=20" \
  -H "Authorization: Bearer ADMIN_TOKEN"

# 4. 管理员通过申请
curl -X POST http://localhost:5001/api/v1/cities/moderator/handle \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "application_id": "application-uuid",
    "action": "approve"
  }'

# 5. 管理员拒绝申请
curl -X POST http://localhost:5001/api/v1/cities/moderator/handle \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "application_id": "application-uuid",
    "action": "reject",
    "rejection_reason": "申请理由不够充分"
  }'

# 6. 查看统计数据
curl -X GET http://localhost:5001/api/v1/cities/moderator/applications/statistics \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

## 📝 下一步工作

1. **执行数据库迁移**
   ```bash
   # 在 Supabase SQL Editor 中运行
   # go-noma/database/migrations/create_moderator_applications.sql
   ```

2. **部署后端服务**
   ```bash
   cd go-noma
   ./deploy.sh  # 或使用 Docker Compose
   ```

3. **实现 SignalR 通知**
   - 在 `NotificationService` 中添加监听逻辑
   - 处理新申请、通过、拒绝三种通知类型
   - 显示相应的 UI 提示

4. **添加管理员权限检查**
   - 在路由中间件检查管理员角色
   - 在 UI 中根据权限显示/隐藏菜单项

5. **优化用户体验**
   - 添加申请历史记录页面
   - 显示申请进度和状态
   - 优化错误提示和加载动画

---

## 🎨 UI 截图说明

### 用户申请页面
- 顶部: 城市卡片 (图片/图标 + 名称)
- 中间: 版主职责列表 (5个要点)
- 底部: 申请理由输入框 (多行,20-500字)
- 提交按钮

### 管理员审核页面
- AppBar: 标题 "版主申请审核" + 刷新按钮
- 卡片列表: 
  - 申请人信息 (头像 + 姓名 + 时间)
  - 申请城市
  - 申请理由 (灰色背景框)
  - 两个按钮: "拒绝" (红色边框) + "通过" (蓝色填充)

---

## 🔗 相关文档

- [后端实现文档](../go-noma/MODERATOR_APPLICATION_SYSTEM.md)
- [数据库迁移脚本](../go-noma/database/migrations/create_moderator_applications.sql)
- [API 接口文档](../go-noma/MODERATOR_APPLICATION_SYSTEM.md#-api-endpoints)

---

## 🤝 贡献者

- 前端开发: ✅ 已完成
- 后端开发: ✅ 已完成
- 数据库设计: ✅ 已完成
- API 测试: ⏳ 待进行
- SignalR 集成: ⏳ 待进行

---

**状态**: 🟢 开发完成,等待部署和测试
**更新时间**: 2024-01-XX
