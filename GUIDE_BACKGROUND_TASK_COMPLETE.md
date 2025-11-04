# Guide 后台加载优化完成

## 📋 功能概述

实现了 Guide 生成过程的后台运行功能,允许用户在生成过程中关闭对话框,任务在后台继续执行,完成后通过系统通知告知用户,点击通知可直接跳转到对应的 Guide 页面查看结果。

## ✅ 已完成的任务

### 1. 添加依赖包

**文件**: `pubspec.yaml`

```yaml
flutter_local_notifications: ^17.2.3
```

### 2. 创建通知服务

**文件**: `lib/services/notification_service.dart`

**功能**:
- ✅ 初始化本地通知 (Android + iOS)
- ✅ 请求通知权限 (Android 13+ 运行时权限)
- ✅ 显示进行中通知 (ongoing notification with indeterminate progress)
- ✅ 显示完成通知 (high priority, sound, vibration)
- ✅ 显示失败通知
- ✅ 处理通知点击事件,导航到城市详情页面的 Guide Tab

**关键方法**:
```dart
Future<void> showGuideGenerating(String cityName)
Future<void> showGuideCompleted(String cityId, String cityName)
Future<void> showGuideFailed(String cityName, String error)
void _onNotificationTapped(NotificationResponse response)
```

### 3. 创建后台任务服务

**文件**: `lib/services/background_task_service.dart`

**功能**:
- ✅ 管理后台任务状态 (idle, running, completed, failed)
- ✅ 创建并执行后台任务
- ✅ 任务进度追踪
- ✅ 任务完成/失败自动发送通知
- ✅ 任务记录自动清理 (5秒后)

**任务状态枚举**:
```dart
enum TaskStatus {
  idle,      // 空闲
  running,   // 运行中
  completed, // 已完成
  failed,    // 失败
}
```

**关键方法**:
```dart
Future<String> createTask({
  required String cityId,
  required String cityName,
  required Future<void> Function() taskFunction,
})
TaskStatus? getTaskStatus(String taskId)
BackgroundTask? getCityActiveTask(String cityId)
bool hasCityActiveTask(String cityId)
```

### 4. 修改 CityDetailController

**文件**: `lib/controllers/city_detail_controller.dart`

**新增方法**:
```dart
Future<String?> generateGuideInBackground() async
```

**功能**:
- ✅ 创建后台任务
- ✅ 调用异步 API 生成 Guide
- ✅ 更新 Guide 数据
- ✅ 保存到 SQLite 缓存
- ✅ 任务完成后自动发送通知

**工作流程**:
```
1. 创建后台任务 → BackgroundTaskService
2. 显示"正在生成"通知
3. 调用 AsyncTaskService.createGuideAndWaitForCompletion()
4. 监听进度 (后台打印日志)
5. 解析返回的 Guide 数据
6. 更新 Controller 状态
7. 保存到 SQLite
8. 发送"生成完成"通知 (带跳转 payload)
```

### 5. 修改加载对话框

**文件**: `lib/pages/city_detail_page.dart`

**UI 改进**:
- ✅ 添加"后台运行"按钮 (TextButton with cloud_queue icon)
- ✅ 点击后关闭对话框
- ✅ 调用 `controller.generateGuideInBackground()`
- ✅ 显示 Toast 提示用户任务已在后台运行

**对话框结构**:
```dart
AlertDialog(
  title: 'AI 正在生成旅游指南',
  content: LinearProgressIndicator + 进度信息,
  actions: [
    TextButton.icon(
      icon: Icons.cloud_queue,
      label: '后台运行',
      onPressed: () {
        Navigator.pop();
        controller.generateGuideInBackground();
      },
    ),
  ],
)
```

### 6. 初始化服务

**文件**: `lib/main.dart`

**修改**:
```dart
// 初始化通知服务
await Get.putAsync(() => NotificationService().init(), permanent: true);

// 初始化后台任务服务
Get.put(BackgroundTaskService(), permanent: true);
```

### 7. 通知点击跳转

**文件**: `lib/services/notification_service.dart` + `lib/pages/city_detail_page.dart`

**跳转逻辑**:
1. 通知 payload 格式: `"cityId|cityName"`
2. 点击通知解析 payload
3. 导航到 `/city-detail` 并传递参数:
   ```dart
   Get.toNamed(
     '/city-detail',
     arguments: {
       'cityId': cityId,
       'cityName': cityName,
       'initialTab': 2, // Guide Tab 索引
     },
   );
   ```
4. CityDetailPage 接收 `initialTab` 参数
5. TabController 使用 `initialIndex: initialTab`

### 8. Android 配置

**文件**: `android/app/src/main/AndroidManifest.xml`

**添加权限**:
```xml
<!-- 通知权限 (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

## 🎯 用户体验流程

### 前台模式 (现有功能保持不变)
```
1. 用户点击"生成 Guide"
2. 显示进度对话框
3. 实时显示进度 (0% → 100%)
4. 生成完成,自动关闭对话框
5. Guide Tab 显示结果
```

### 后台模式 (新增功能)
```
1. 用户点击"生成 Guide"
2. 显示进度对话框
3. 用户点击"后台运行"按钮
4. 对话框关闭,显示 Toast: "指南正在后台生成,完成后会通知您"
5. 状态栏显示持续通知: "正在生成旅游指南 - 正在为 北京 生成数字游民指南..."
6. 用户可以自由操作 App (切换页面、浏览其他城市等)
7. 生成完成后:
   - 移除"正在生成"通知
   - 显示"已完成"通知: "旅游指南已生成 - 北京 的数字游民指南已准备就绪,点击查看"
   - 播放提示音 + 震动
8. 用户点击通知:
   - 自动跳转到北京城市详情页
   - 自动切换到 Guide Tab (索引 2)
   - 显示生成的 Guide 内容
```

## 🔔 通知类型

### 1. 进行中通知 (Ongoing)
- **标题**: "正在生成旅游指南"
- **内容**: "正在为 [城市名] 生成数字游民指南..."
- **特性**: 
  - 不可滑动删除 (`ongoing: true`)
  - 显示不确定进度条 (`indeterminate: true`)
  - 低优先级,无声音 (`Importance.low`)

### 2. 完成通知 (Completed)
- **标题**: "旅游指南已生成"
- **内容**: "[城市名] 的数字游民指南已准备就绪,点击查看"
- **特性**:
  - 高优先级 (`Importance.high`)
  - 播放声音 (`playSound: true`)
  - 震动 (`enableVibration: true`)
  - 可点击跳转 (payload: `"cityId|cityName"`)

### 3. 失败通知 (Failed)
- **标题**: "指南生成失败"
- **内容**: "[城市名] 的指南生成失败: [错误信息]"
- **特性**: 高优先级,声音+震动

## 📂 新增文件

```
lib/
├── services/
│   ├── notification_service.dart       (新增 - 通知服务)
│   └── background_task_service.dart    (新增 - 后台任务服务)
└── (修改文件)
    ├── controllers/city_detail_controller.dart
    ├── pages/city_detail_page.dart
    └── main.dart
```

## 🔧 技术细节

### 通知 ID 策略
使用城市名称的 `hashCode` 作为通知 ID,确保:
- ✅ 同一城市的通知可以相互覆盖 (不会重复显示)
- ✅ 不同城市的通知独立显示
- ✅ 进行中通知可以被完成/失败通知正确替换

### 任务生命周期
```
创建任务 (running)
    ↓
执行 taskFunction
    ↓
成功 → 更新状态 (completed) → 发送完成通知 → 5秒后清理
    ↓
失败 → 更新状态 (failed) → 发送失败通知 → 5秒后清理
```

### 数据持久化
- ✅ Guide 数据保存到 SQLite (`digital_nomad_guides` 表)
- ✅ 使用 `cityId` 作为唯一标识
- ✅ 后台生成完成后自动保存
- ✅ 下次打开城市详情页直接从缓存加载

## 🚀 下一步优化建议

1. **任务队列管理**:
   - 限制同时运行的后台任务数量
   - 添加任务优先级机制

2. **通知分组** (Android 7.0+):
   - 将多个 Guide 生成通知分组显示
   - 添加"取消所有"操作

3. **进度同步**:
   - 在通知中显示实时进度 (0-100%)
   - 使用确定性进度条替代不确定进度条

4. **任务持久化**:
   - 将后台任务保存到 SQLite
   - App 重启后恢复未完成的任务

5. **网络重试机制**:
   - API 调用失败自动重试
   - 指数退避策略

6. **用户偏好设置**:
   - 允许用户关闭通知
   - 设置通知声音/震动偏好

## 📊 测试场景

### 场景 1: 前台生成
1. 打开城市详情页 → Guide Tab
2. 点击"生成 Guide"
3. **保持对话框打开**
4. 等待进度到 100%
5. 对话框自动关闭,Guide 显示

### 场景 2: 后台生成
1. 打开城市详情页 → Guide Tab
2. 点击"生成 Guide"
3. **点击"后台运行"按钮**
4. 对话框关闭,Toast 提示
5. 状态栏显示"正在生成"通知
6. 切换到其他页面 (测试后台运行)
7. 等待通知变为"已生成"
8. 点击通知,跳转到 Guide Tab

### 场景 3: 多城市并发
1. 生成北京 Guide (后台运行)
2. 立即切换到上海
3. 生成上海 Guide (后台运行)
4. 观察两个城市的通知独立显示
5. 分别点击通知,跳转到对应城市

### 场景 4: 失败处理
1. 断开网络连接
2. 生成 Guide (后台运行)
3. 观察失败通知

## 🎉 总结

通过引入 `flutter_local_notifications` 和自定义的后台任务服务,成功实现了 Guide 生成的后台运行功能。用户现在可以自由选择:
- **前台模式**: 等待生成完成,立即查看结果
- **后台模式**: 关闭对话框继续使用 App,通过通知获取结果

这大大提升了用户体验,特别是在生成时间较长 (30秒+) 的情况下,用户不再需要被"强制"等待。
