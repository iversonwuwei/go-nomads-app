# 后台生成加载对话框功能完成

## 📋 需求
前台生成的过程，要保持加载过程对话框显示，直到整个过程加载完成才会关闭对话框并显示最新的 guide 内容。

## ✅ 实现内容

### 1. 新增后台生成对话框方法
在 `city_detail_page.dart` 中添加了 `_showBackgroundGenerateProgressDialog` 方法：

**核心功能：**
- 显示不可关闭的加载对话框（`barrierDismissible: false`）
- 通过 SignalR 实时接收后台任务进度更新
- 监听 `isGeneratingGuide` 状态变化，任务完成时自动关闭对话框
- 显示实时进度百分比和状态消息
- 提供取消按钮（仅在生成中时可用）

**SignalR 实时更新：**
```dart
// 监听生成状态变化（任务完成/失败）
statusWorker = ever(
  controller.isGeneratingGuideRx,
  (isGenerating) {
    if (isGenerating == false) {
      // 延迟1.5秒关闭，让用户看到完成状态
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(dialogContext).pop();
        statusWorker?.dispose();
      });
    }
  },
);
```

### 2. 更新调用点
修改了两处后台生成的触发点：

1. **后台生成按钮（独立按钮）：**
```dart
onPressed: () async {
  if (await _checkGeneratePermission()) {
    _showBackgroundGenerateProgressDialog(controller);
  }
}
```

2. **下拉菜单后台生成选项：**
```dart
if (value == 'background') {
  _showBackgroundGenerateProgressDialog(controller);
}
```

### 3. 对话框 UI 设计
- **图标：** `Icons.cloud_upload`（云上传图标）
- **标题：** "AI 后台生成中"
- **进度条：** 
  - 有进度时显示确定进度（0-100%）
  - 无进度时显示不确定进度动画
- **状态信息：**
  - 实时显示进度百分比
  - 实时显示状态消息（如"正在分析推荐区域..."）
  - 底部提示："后台任务通过 SignalR 实时推送进度"

### 4. 生命周期管理
- 对话框显示后立即调用 `controller.generateDigitalNomadGuideInBackground()`
- 通过 `Obx` 自动响应 controller 中的响应式变量变化
- 任务完成时通过 `ever` 监听器自动关闭对话框
- 用户取消时正确清理 `statusWorker` 监听器

## 🔄 工作流程

```
用户点击"后台生成"
    ↓
显示加载对话框
    ↓
调用 generateDigitalNomadGuideInBackground()
    ↓
后端创建异步任务并返回
    ↓
SignalR 推送进度更新（实时）
    ├─ 进度消息：更新对话框进度条和文本
    ├─ 任务完成：关闭对话框，显示成功提示
    └─ 任务失败：关闭对话框，显示错误提示
```

## 📊 SignalR 事件流

在 `ai_state_controller.dart` 中，后台生成已集成 SignalR 监听：

```dart
// 订阅任务完成事件
_taskCompletedSubscription = signalr.taskCompletedStream.listen((task) {
  if (task.result?.guideId != null) {
    _isGeneratingGuide.value = false;
    loadCityGuide(cityId: cityId, cityName: cityName);
    // 显示成功提示...
  }
});

// 订阅任务失败事件
_taskFailedSubscription = signalr.taskFailedStream.listen((task) {
  _isGeneratingGuide.value = false;
  _guideError.value = task.error;
  // 显示失败提示...
});

// 订阅进度更新
_taskProgressSubscription = signalr.taskProgressStream.listen((task) {
  _guideGenerationProgress.value = task.progress.percentage;
  _guideGenerationMessage.value = task.progress.message ?? '';
});
```

## 🎯 关键特性

1. **不可关闭：** 对话框设置 `barrierDismissible: false`，防止用户误触关闭
2. **实时更新：** 通过 `Obx` 包装，自动响应进度和消息变化
3. **自动关闭：** 监听 `isGeneratingGuide` 状态，完成时自动关闭
4. **延迟关闭：** 完成后延迟1.5秒关闭，让用户看到完成状态
5. **优雅降级：** 如果没有进度信息，显示不确定进度动画
6. **资源清理：** 对话框关闭时正确清理 Worker 监听器

## 📝 修改文件
- `/Users/walden/Workspaces/WaldenProjects/open-platform-app/lib/pages/city_detail_page.dart`
  - 新增 `_showBackgroundGenerateProgressDialog()` 方法
  - 修改两处后台生成按钮的 `onPressed` 回调

## ✅ 测试要点
1. ✅ 点击"后台生成"按钮显示对话框
2. ✅ 对话框显示期间接收 SignalR 进度更新
3. ✅ 进度百分比和消息实时更新
4. ✅ 任务完成后对话框自动关闭
5. ✅ 点击"取消"按钮可以关闭对话框
6. ✅ 无法通过点击外部区域关闭对话框

## 🎨 用户体验
- 用户点击"后台生成"后立即看到加载对话框，明确知道任务正在处理
- 实时进度更新让用户了解任务进展（如"正在分析推荐区域... 40%"）
- 任务完成后对话框自动关闭，无需手动操作
- 完成后自动刷新 guide 内容，显示最新生成的指南

## 📅 完成时间
2025年11月20日
