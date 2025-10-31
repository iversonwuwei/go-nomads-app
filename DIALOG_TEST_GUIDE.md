# 对话框不消失问题 - 测试指南

## 快速测试步骤

### 1. 启动后端服务
```bash
cd /Users/walden/Workspaces/WaldenProjects/go-noma/deployment
./deploy-services-local.sh
```

### 2. 启动 Flutter 应用
```bash
cd /Users/walden/Workspaces/WaldenProjects/open-platform-app
flutter run
```

### 3. 测试场景

#### 场景 A: 正常流程（后端运行正常）
1. 打开应用，选择任意城市
2. 点击"生成旅行计划"
3. 观察进度对话框显示和更新
4. 等待生成完成
5. **预期结果**: 对话框自动关闭，显示旅行计划详情

#### 场景 B: 后端服务未启动
1. **停止后端服务**
2. 打开应用，选择任意城市
3. 点击"生成旅行计划"
4. 等待超时
5. **预期结果**: 
   - 对话框关闭
   - 显示错误提示
   - 自动返回上一页
   - **不应该**有对话框残留

#### 场景 C: 网络超时
1. 设置较短的超时时间（可选）
2. 在生成过程中断网
3. **预期结果**: 
   - 对话框关闭
   - 显示超时错误
   - 自动返回上一页

#### 场景 D: 用户中途退出
1. 开始生成旅行计划
2. 在进度对话框显示时，按设备返回键
3. **预期结果**: 
   - 对话框立即关闭（在 dispose 中处理）
   - 返回到上一页
   - 没有内存泄漏

#### 场景 E: 获取详情失败但生成成功
1. 修改代码模拟获取详情失败（可选）
2. 生成旅行计划
3. **预期结果**: 
   - 对话框关闭
   - 显示警告提示
   - 降级显示 mock 数据

## 调试日志检查

### 正常流程应看到的日志：
```
[LOG] 尝试关闭残留进度对话框...
[AsyncTaskProgressDialog] 没有打开的对话框，无需关闭
[LOG] 显示进度对话框
🚀 开始异步生成旅行计划...
📊 任务进度: 10% - 正在分析您的需求...
📊 任务进度: 30% - AI 正在生成行程安排...
📊 任务进度: 100% - 旅行计划生成成功
✅ 旅行计划生成成功! PlanId: xxx
📥 开始获取旅行计划详情...
✅ 成功获取旅行计划数据
[LOG] finally 块：确保关闭进度对话框
[LOG] 对话框已在 PostFrameCallback 中关闭
[AsyncTaskProgressDialog] 关闭对话框...
[AsyncTaskProgressDialog] 对话框已关闭
```

### 错误流程应看到的日志：
```
[LOG] 尝试关闭残留进度对话框...
[LOG] 显示进度对话框
🚀 开始异步生成旅行计划...
❌ 异步生成失败: xxx
[LOG] finally 块：确保关闭进度对话框
[LOG] 对话框已在 PostFrameCallback 中关闭
[AsyncTaskProgressDialog] 关闭对话框...
[AsyncTaskProgressDialog] 对话框已关闭
```

### 用户退出应看到的日志：
```
[LOG] 显示进度对话框
📊 任务进度: 30% - xxx
[TravelPlanPage] dispose: 关闭可能残留的对话框
[AsyncTaskProgressDialog] 关闭对话框...
```

## 如果仍然出现对话框不消失

### 检查清单：

1. **查看 console 日志**
   - 是否执行到了 finally 块？
   - `[AsyncTaskProgressDialog]` 日志显示什么状态？
   - 是否有异常被抛出但未打印？

2. **检查 Get 状态**
   ```dart
   // 在代码中添加临时调试
   print('Get.isDialogOpen: ${Get.isDialogOpen}');
   print('Navigator canPop: ${Navigator.canPop(context)}');
   ```

3. **检查是否有多个对话框**
   - 是否其他地方也显示了对话框？
   - 使用 Flutter Inspector 查看 widget 树

4. **强制关闭方案**
   如果上述都无效，可以在 finally 中添加：
   ```dart
   finally {
     // 强制关闭所有对话框
     while (Get.isDialogOpen == true) {
       Get.back();
       await Future.delayed(Duration(milliseconds: 50));
     }
   }
   ```

## 性能检查

- 内存是否增长？（使用 Flutter DevTools）
- 对话框关闭后是否有 widget 泄漏？
- taskProgress 和 taskProgressMessage 是否正确重置为 0 和 ''？

## 回归测试

在修复后，确保以下功能仍然正常：
- ✅ 正常生成旅行计划
- ✅ 进度更新实时显示
- ✅ 错误提示正常显示
- ✅ Toast 消息正常显示
- ✅ 页面导航正常
- ✅ 无内存泄漏

---

**测试负责人**: 开发者  
**测试日期**: 2025年10月30日  
**预期结果**: 所有场景下对话框都能正确关闭
