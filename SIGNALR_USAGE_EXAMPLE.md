# SignalR 实时推送集成 - 使用示例

## 🚀 快速开始

### 1. 确保后端服务运行

```powershell
# 确认 RabbitMQ + Redis + Backend 正在运行
cd e:\Workspaces\WaldenProjects\go-nomads
docker ps

# 应该看到:
# - rabbitmq:3-management-alpine (Ports: 5672, 15672)
# - redis:7-alpine (Port: 6379)
# - backend API (Port: 8009)
```

### 2. 在 Flutter 中使用

#### 方法 1: 自动集成(推荐)

```dart
// 在 CityDetailController 中已经自动集成 SignalR
// 只需调用 generateTravelPlanAsync() 即可

final controller = Get.find<CityDetailController>();

final planId = await controller.generateTravelPlanAsync(
  duration: 3,
  budget: 'medium',        // "low", "medium", "high"
  travelStyle: 'culture',  // "adventure", "relaxation", "culture", "nightlife"
  interests: ['Food', 'Culture', 'Shopping'],
  onProgress: (progress, message) {
    print('$progress% - $message');
  },
);

print('生成的计划ID: $planId');
```

#### 方法 2: 手动使用 SignalR Service

```dart
import 'package:df_admin_mobile/services/signalr_service.dart';
import 'package:df_admin_mobile/services/async_task_service.dart';

final signalR = SignalRService();
final asyncTask = AsyncTaskService();

// 1. 连接到 SignalR Hub
if (!signalR.isConnected) {
  await signalR.connect('http://localhost:8009');
  print('✅ SignalR 已连接, ConnectionId: ${signalR.connectionId}');
}

// 2. 订阅事件流
signalR.taskProgressStream.listen((taskStatus) {
  print('进度更新: ${taskStatus.progress}%');
  print('消息: ${taskStatus.progressMessage}');
});

signalR.taskCompletedStream.listen((taskStatus) {
  print('✅ 任务完成! PlanId: ${taskStatus.planId}');
});

signalR.taskFailedStream.listen((taskStatus) {
  print('❌ 任务失败: ${taskStatus.error}');
});

// 3. 创建任务
final response = await asyncTask.createTravelPlanTask(
  cityId: '2',
  cityName: 'Shanghai',
  duration: 3,
  budget: 'medium',
  travelStyle: 'culture',
  interests: ['Food', 'Culture', 'Shopping'],
);

print('任务已创建: ${response.taskId}');

// SignalR 会自动推送进度更新!
// 不需要手动轮询
```

## 📊 工作流程

```
Flutter App
    |
    | 1. connect('http://localhost:8009')
    v
SignalR Hub (/hubs/notifications)
    |
    | 2. WebSocket 建立
    v
Flutter 订阅事件流:
  - taskProgressStream
  - taskCompletedStream
  - taskFailedStream
    |
    | 3. createTravelPlanTask()
    v
Backend API
    |
    | 4. 发布到 RabbitMQ
    v
AIWorkerService
    |
    | 5. 处理任务 + 调用 DeepSeek AI
    |
    | 6. 每 10% 推送进度
    v
SignalR Hub
    |
    | 7. TaskProgress Event
    v
Flutter App (taskProgressStream)
    |
    | 更新 UI 进度条
    v
显示实时进度
```

## 🔧 API 参考

### SignalRService

#### 属性
- `bool isConnected` - 是否已连接
- `String? connectionId` - SignalR ConnectionId
- `Stream<TaskStatus> taskProgressStream` - 进度更新流
- `Stream<TaskStatus> taskCompletedStream` - 完成通知流
- `Stream<TaskStatus> taskFailedStream` - 失败通知流

#### 方法
```dart
// 连接到 SignalR Hub
Future<void> connect(String baseUrl);

// 断开连接
Future<void> disconnect();
```

### AsyncTaskService

#### 创建任务
```dart
Future<CreateTaskResponse> createTravelPlanTask({
  required String cityId,        // 城市ID (字符串)
  required String cityName,      // 城市名称
  required int duration,         // 旅行天数
  required String budget,        // "low", "medium", "high"
  required String travelStyle,   // "adventure", "relaxation", "culture", "nightlife"
  required List<String> interests,
});
```

#### 查询任务状态
```dart
Future<TaskStatus> getTaskStatus(String taskId);
```

#### 轮询任务(备用方案)
```dart
Future<TaskStatus> pollTaskStatus({
  required String taskId,
  Function(TaskStatus)? onProgress,
  Duration pollInterval = const Duration(seconds: 3),
  int maxAttempts = 40,
});
```

#### 创建并等待完成
```dart
Future<TaskStatus> createAndWaitForCompletion({
  required String cityId,
  required String cityName,
  required int duration,
  required String budget,
  required String travelStyle,
  required List<String> interests,
  Function(TaskStatus)? onProgress,
});
```

### CityDetailController

#### 异步生成旅行计划
```dart
Future<String?> generateTravelPlanAsync({
  required int duration,
  required String budget,
  required String travelStyle,
  required List<String> interests,
  Function(int, String)? onProgress,
});
```

## 📱 UI 集成示例

### 完整的按钮点击处理

```dart
import 'package:df_admin_mobile/widgets/async_task_progress_dialog.dart';
import 'package:df_admin_mobile/controllers/city_detail_controller.dart';
import 'package:df_admin_mobile/utils/toast_helper.dart';
import 'package:get/get.dart';

class TravelPlanPage extends StatelessWidget {
  final controller = Get.find<CityDetailController>();

  Future<void> _generatePlanAsync() async {
    // 1. 显示进度对话框
    AsyncTaskProgressDialog.show(
      title: 'Generating Travel Plan',
      progress: controller.taskProgress,
      message: controller.taskProgressMessage,
    );

    try {
      // 2. 调用异步生成
      final planId = await controller.generateTravelPlanAsync(
        duration: 3,
        budget: 'medium',
        travelStyle: 'culture',
        interests: ['Food', 'Culture', 'Shopping'],
        onProgress: (progress, message) {
          print('进度: $progress% - $message');
          // controller.taskProgress 和 taskProgressMessage 会自动更新
        },
      );

      // 3. 关闭对话框
      AsyncTaskProgressDialog.dismiss();

      // 4. 显示结果
      if (planId != null) {
        AppToast.success('Travel plan generated! ID: $planId');
        // TODO: 导航到计划详情页
      } else {
        AppToast.error('Failed to generate travel plan');
      }
    } catch (e) {
      AsyncTaskProgressDialog.dismiss();
      AppToast.error('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _generatePlanAsync,
          child: Text('Generate Travel Plan'),
        ),
      ),
    );
  }
}
```

## 🔍 调试技巧

### 1. 查看 SignalR 连接状态
```dart
final signalR = SignalRService();
print('是否连接: ${signalR.isConnected}');
print('ConnectionId: ${signalR.connectionId}');
```

### 2. 监听所有事件
```dart
signalR.taskProgressStream.listen((status) {
  print('📊 进度: ${status.taskId} - ${status.progress}%');
});

signalR.taskCompletedStream.listen((status) {
  print('✅ 完成: ${status.taskId} - PlanId: ${status.planId}');
});

signalR.taskFailedStream.listen((status) {
  print('❌ 失败: ${status.taskId} - ${status.error}');
});
```

### 3. 测试轮询回退
```dart
// 故意不连接 SignalR,测试轮询模式
final asyncTask = AsyncTaskService();

final status = await asyncTask.createAndWaitForCompletion(
  cityId: '2',
  cityName: 'Shanghai',
  duration: 3,
  budget: 'medium',
  travelStyle: 'culture',
  interests: [],
  onProgress: (status) {
    print('轮询模式 - 进度: ${status.progress}%');
  },
);
```

### 4. Chrome DevTools 查看 WebSocket
```
1. 运行 Flutter Web 版本
2. 打开 Chrome DevTools (F12)
3. Network → WS (WebSocket)
4. 查看 SignalR 消息:
   - Handshake
   - TaskProgress
   - TaskCompleted
```

## ⚠️ 常见问题

### Q1: SignalR 连接失败
```dart
// 错误: Failed to connect to SignalR Hub
// 解决:
1. 确认后端运行在 http://localhost:8009
2. 检查 CORS 配置是否允许 Flutter 应用
3. 查看后端日志是否有错误
```

### Q2: 没有收到进度更新
```dart
// 可能原因:
1. SignalR 连接断开 → 自动回退到轮询
2. 任务创建失败 → 检查 createTravelPlanTask() 返回值
3. 事件流未订阅 → 确保调用 .listen()
```

### Q3: 进度对话框不更新
```dart
// 确保使用 Rx 变量
final controller = Get.find<CityDetailController>();
controller.taskProgress.value = 50;  // ✅ 正确
controller.taskProgressMessage.value = 'Processing...';  // ✅ 正确

// 对话框自动监听 RxInt 和 RxString
```

## 🧪 测试建议

### 1. 单元测试 SignalR Service
```dart
test('SignalR 连接测试', () async {
  final signalR = SignalRService();
  await signalR.connect('http://localhost:8009');
  
  expect(signalR.isConnected, true);
  expect(signalR.connectionId, isNotNull);
  
  await signalR.disconnect();
  expect(signalR.isConnected, false);
});
```

### 2. 集成测试 - 完整流程
```dart
testWidgets('异步任务完整流程', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 点击生成按钮
  await tester.tap(find.text('Generate Plan'));
  await tester.pump();
  
  // 验证对话框显示
  expect(find.byType(AsyncTaskProgressDialog), findsOneWidget);
  
  // 等待任务完成 (最多 2 分钟)
  await tester.pumpAndSettle(Duration(minutes: 2));
  
  // 验证对话框关闭
  expect(find.byType(AsyncTaskProgressDialog), findsNothing);
  
  // 验证成功提示
  expect(find.text('Travel plan generated!'), findsOneWidget);
});
```

## 📋 生产环境检查清单

- [ ] **修改 SignalR URL**: 从 `http://localhost:8009` 改为生产域名
- [ ] **修改 HTTP Base URL**: 同步修改 AsyncTaskService 的基础 URL
- [ ] **配置 CORS**: 后端允许 Flutter 应用域名
- [ ] **移除 console.log**: 将 `print()` 改为日志服务
- [ ] **添加认证**: SignalR 连接需要传递 JWT Token
- [ ] **错误监控**: 集成 Sentry/Firebase Crashlytics
- [ ] **网络检测**: 添加网络状态监听
- [ ] **重连策略**: 优化 SignalR 自动重连逻辑
- [ ] **超时配置**: 调整轮询间隔和最大尝试次数
- [ ] **清理未使用代码**: 删除 `_generatePlanStream`, `_generatePlan`

## 🔗 相关文档

- [后端异步任务实现](../go-nomads/ASYNC_TASK_QUEUE_IMPLEMENTATION.md)
- [后端测试成功报告](../go-nomads/ASYNC_TASK_TEST_SUCCESS.md)
- [异步任务快速参考](../go-nomads/ASYNC_TASK_QUICK_REFERENCE.md)
- [Flutter 集成完成总结](./FLUTTER_ASYNC_INTEGRATION_COMPLETE.md)

---

**Created:** 2025-01-24
**Status:** ✅ 集成完成,等待测试
**Next Step:** 运行 Flutter 应用并测试 SignalR 实时推送
