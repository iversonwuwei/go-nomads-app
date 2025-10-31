# 旅行计划页面对话框不消失问题 - 彻底修复

## 问题描述
在 `TravelPlanPage` 中生成旅行计划时，如果 API 请求失败或发生错误，进度对话框可能无法正确关闭，导致用户界面卡住。

## 问题原因分析

### 1. **多个错误路径缺少对话框关闭逻辑**
- 嵌套的 try-catch 块中，某些异常路径没有调用 `AsyncTaskProgressDialog.dismiss()`
- mounted 检查可能导致对话框关闭代码被跳过

### 2. **对话框关闭时机不当**
- 在异步操作完成前关闭对话框
- UI 帧渲染期间关闭对话框导致状态不一致

### 3. **Get.back() 调用可能失败**
- `Get.isDialogOpen` 状态判断不够健壮
- 没有错误处理机制

## 修复方案

### 1. **使用 finally 块确保对话框关闭**

```dart
Future<void> _generatePlanAsync() async {
  bool dialogShown = false;
  
  try {
    // 显示对话框
    AsyncTaskProgressDialog.show(...);
    dialogShown = true;
    
    // 执行异步操作...
    
  } catch (e) {
    // 错误处理...
  } finally {
    // 确保对话框一定会被关闭
    if (dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        AsyncTaskProgressDialog.dismiss();
      });
    }
    
    // 重置进度值
    controller.taskProgress.value = 0;
    controller.taskProgressMessage.value = '';
  }
}
```

**关键点：**
- 使用 `dialogShown` 标志追踪对话框状态
- finally 块确保无论成功还是失败都会执行关闭逻辑
- 使用 `addPostFrameCallback` 确保在正确的帧时机关闭
- 添加小延迟确保 UI 状态更新完成

### 2. **增强 AsyncTaskProgressDialog.dismiss() 方法**

```dart
static void dismiss() {
  try {
    if (Get.isDialogOpen == true) {
      print('[AsyncTaskProgressDialog] 关闭对话框...');
      Get.back();
      print('[AsyncTaskProgressDialog] 对话框已关闭');
    } else {
      print('[AsyncTaskProgressDialog] 没有打开的对话框，无需关闭');
    }
  } catch (e) {
    print('[AsyncTaskProgressDialog] 关闭对话框时出错: $e');
    // 尝试强制关闭所有对话框
    try {
      while (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e2) {
      print('[AsyncTaskProgressDialog] 强制关闭失败: $e2');
    }
  }
}

static Future<void> dismissSafely({Duration delay = const Duration(milliseconds: 100)}) async {
  await Future.delayed(delay);
  dismiss();
}
```

**关键改进：**
- 添加 try-catch 保护 dismiss 调用
- 严格检查 `Get.isDialogOpen == true`（而不是 `?? false`）
- 添加调试日志便于追踪
- 提供 `dismissSafely` 方法支持延迟关闭
- 添加强制关闭机制作为后备方案

### 3. **在 dispose 中清理对话框**

```dart
@override
void dispose() {
  _shimmerController.dispose();
  // 确保页面销毁时关闭任何可能残留的对话框
  print('[TravelPlanPage] dispose: 关闭可能残留的对话框');
  AsyncTaskProgressDialog.dismiss();
  super.dispose();
}
```

**作用：**
- 页面被销毁时（如用户按返回键）确保对话框被关闭
- 防止内存泄漏和状态污染

### 4. **改进错误处理流程**

```dart
try {
  // 生成计划...
  
  if (planId != null) {
    try {
      // 获取计划详情...
      if (mounted) {
        setState(() { ... });
        AppToast.success('...');
      }
    } catch (e) {
      // 降级到 mock 数据
      if (mounted) {
        setState(() { ... });
        AppToast.warning('...');
      }
    }
  } else {
    if (mounted) {
      setState(() { _isLoading = false; });
      AppToast.error('...');
      Get.back(); // 返回上一页
    }
  }
} catch (e, stackTrace) {
  print('❌ 异步生成旅行计划失败: $e');
  print('堆栈跟踪: $stackTrace');
  
  if (mounted) {
    setState(() { _isLoading = false; });
    AppToast.error('...');
    Get.back(); // 返回上一页
  }
} finally {
  // 无论如何都关闭对话框
}
```

**关键改进：**
- 所有错误路径都有明确的处理逻辑
- 失败时自动返回上一页（`Get.back()`）
- 添加堆栈跟踪日志便于调试
- mounted 检查防止状态更新错误

## 测试场景

### 场景 1: 正常成功流程
- ✅ 对话框显示 → 进度更新 → 获取数据成功 → 对话框关闭 → 显示计划

### 场景 2: 生成失败（planId 为 null）
- ✅ 对话框显示 → 生成失败 → 对话框关闭 → 显示错误 → 返回上一页

### 场景 3: 获取详情失败
- ✅ 对话框显示 → 生成成功 → 获取详情失败 → 对话框关闭 → 降级到 mock 数据

### 场景 4: 网络错误
- ✅ 对话框显示 → 网络超时/连接错误 → 对话框关闭 → 显示错误 → 返回上一页

### 场景 5: 用户中途退出
- ✅ 对话框显示 → 用户按返回键 → dispose 调用 → 对话框关闭

### 场景 6: 异常崩溃
- ✅ 对话框显示 → 未知异常 → finally 块执行 → 对话框关闭

## 修改的文件

1. **lib/pages/travel_plan_page.dart**
   - 重构 `_generatePlanAsync()` 方法
   - 添加 `dialogShown` 标志
   - 使用 finally 块确保清理
   - 改进 dispose 方法

2. **lib/widgets/async_task_progress_dialog.dart**
   - 增强 `dismiss()` 方法的健壮性
   - 添加 `dismissSafely()` 方法
   - 添加错误处理和调试日志

## 调试建议

### 1. 启用详细日志
所有关键步骤都添加了 print 日志，可以追踪：
- `[LOG]` - 对话框操作
- `[AsyncTaskProgressDialog]` - 对话框内部状态
- `[TravelPlanPage]` - 页面生命周期

### 2. 监控 console 输出
正常流程应该看到：
```
[LOG] 尝试关闭残留进度对话框...
[AsyncTaskProgressDialog] 没有打开的对话框，无需关闭
[LOG] 显示进度对话框
📊 进度: 10% - 正在分析您的需求...
...
✅ 成功获取旅行计划数据
[LOG] finally 块：确保关闭进度对话框
[LOG] 对话框已在 PostFrameCallback 中关闭
[AsyncTaskProgressDialog] 关闭对话框...
[AsyncTaskProgressDialog] 对话框已关闭
```

### 3. 如果仍有问题
检查以下几点：
- Get.isDialogOpen 是否正确反映状态
- 是否有其他代码也在显示对话框
- 是否有多个 Navigator 栈
- 是否在错误的 BuildContext 中操作

## 总结

这次修复采用了**多层防御**策略：

1. **主防线**: finally 块确保对话框关闭
2. **次防线**: dispose 方法清理残留对话框
3. **后备方案**: dismiss 方法内置强制关闭逻辑
4. **时序控制**: PostFrameCallback 确保正确的关闭时机
5. **状态追踪**: dialogShown 标志避免误关闭

通过这些改进，对话框不消失的问题应该得到**彻底解决**。

---

**修复日期**: 2025年10月30日  
**版本**: v1.0 - 彻底修复版
