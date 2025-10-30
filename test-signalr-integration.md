# SignalR 集成测试指南

## 🧪 测试步骤

### 前提条件

✅ 后端服务运行中:
- RabbitMQ: http://localhost:15672 (guest/guest)
- Redis: localhost:6379
- Backend API: http://localhost:8009
- SignalR Hub: http://localhost:8009/hubs/notifications

### 测试 1: SignalR 连接测试

1. **启动 Flutter 应用** (Windows 桌面版)
   ```powershell
   flutter run -d windows
   ```

2. **打开控制台** (F12 或查看 VS Code 终端输出)

3. **观察连接日志**:
   应该看到类似输出:
   ```
   ✅ SignalR 已连接
   ConnectionId: xxxxxxxxxxxxx
   ```

### 测试 2: 异步任务生成测试

1. **在应用中导航到城市详情页**
   - 打开首页
   - 选择任意城市 (如 Shanghai)
   - 进入城市详情

2. **点击 "Generate Travel Plan" 按钮**

3. **观察进度对话框**:
   - 应该显示进度对话框
   - 圆形进度指示器旋转
   - 进度条从 0% 开始

4. **观察控制台输出**:
   ```
   📤 创建任务请求: cityId=2, duration=3, budget=medium, travelStyle=culture
   ✅ 任务已创建: taskId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   📊 进度更新: 10% - 正在初始化...
   📊 进度更新: 30% - 正在分析城市信息...
   📊 进度更新: 50% - AI 生成中...
   📊 进度更新: 70% - 优化行程...
   📊 进度更新: 90% - 完成处理...
   ✅ 任务完成! PlanId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

5. **验证进度对话框更新**:
   - 进度百分比应实时更新
   - 进度消息应显示当前阶段
   - 颜色应从橙色→蓝色→绿色变化

6. **验证完成提示**:
   - 对话框自动关闭
   - 显示成功提示: "Travel plan generated! ID: xxx"

### 测试 3: SignalR 实时推送验证

1. **打开 RabbitMQ 管理界面**: http://localhost:15672

2. **登录**: guest/guest

3. **查看 Queues 标签**:
   - 应该看到 `travel-plan-tasks` 队列
   - Messages 数量应该在任务创建时增加
   - 然后消费后减少到 0

4. **在 Flutter 控制台中观察**:
   ```
   🔔 SignalR TaskProgress 事件: taskId=xxx, progress=10%
   🔔 SignalR TaskProgress 事件: taskId=xxx, progress=30%
   ...
   🔔 SignalR TaskCompleted 事件: taskId=xxx, planId=xxx
   ```

5. **验证 SignalR 优先于轮询**:
   - SignalR 连接正常时,应该收到实时推送
   - 不应该看到 "轮询状态" 的日志

### 测试 4: 轮询回退机制测试

1. **停止后端 SignalR** (模拟网络故障):
   ```powershell
   cd e:\Workspaces\WaldenProjects\go-nomads
   docker stop go-nomads-backend
   ```

2. **等待 SignalR 断开连接** (约 30 秒)

3. **重新启动后端**:
   ```powershell
   docker start go-nomads-backend
   ```

4. **再次点击 "Generate Travel Plan"**

5. **观察控制台**:
   ```
   ⚠️ SignalR 连接失败,将使用轮询模式
   📊 轮询状态: 10% - 正在初始化...
   📊 轮询状态: 30% - 正在分析城市信息...
   ```

6. **验证轮询工作正常**:
   - 进度仍然更新 (每 3 秒)
   - 最终任务完成
   - 功能正常,只是稍慢

### 测试 5: 错误处理测试

1. **测试网络错误**:
   - 停止后端: `docker stop go-nomads-backend`
   - 点击 "Generate Travel Plan"
   - 应该看到错误提示: "Network error: ..."

2. **测试任务超时**:
   - 修改轮询最大次数为 3 (在 `async_task_service.dart`)
   - 重启应用
   - 创建任务
   - 应该超时并显示错误

3. **测试 SignalR 断线重连**:
   - 应用运行中
   - 重启后端
   - 等待 30 秒
   - SignalR 应该自动重连
   - 控制台应显示: "✅ SignalR 已重新连接"

## 📊 预期结果

### 成功标志

- [x] SignalR 连接成功 (connectionId 不为空)
- [x] 实时进度推送 (每 10% 推送一次)
- [x] 进度对话框实时更新
- [x] 任务完成后返回 planId
- [x] RabbitMQ 队列消息正常消费
- [x] Redis 缓存计划数据
- [x] 轮询回退机制工作正常

### 性能指标

- SignalR 连接时间: < 2 秒
- 任务创建响应: < 500ms
- 进度推送延迟: < 1 秒
- AI 生成时间: 30-60 秒 (取决于 DeepSeek API)
- 总完成时间: 约 1 分钟

## 🐛 常见问题排查

### 问题 1: SignalR 连接失败

**症状**:
```
⚠️ SignalR 连接失败: Connection failed
```

**解决**:
1. 检查后端是否运行:
   ```powershell
   curl http://localhost:8009/health
   ```

2. 检查 SignalR Hub 端点:
   ```powershell
   curl http://localhost:8009/hubs/notifications
   ```

3. 查看后端日志:
   ```powershell
   docker logs go-nomads-backend --tail 50
   ```

4. 检查 CORS 配置 (后端 Startup.cs)

### 问题 2: 没有收到进度更新

**症状**:
- 任务创建成功
- 进度一直是 0%
- 没有控制台输出

**解决**:
1. 检查 RabbitMQ 队列:
   - http://localhost:15672
   - 查看 `travel-plan-tasks` 是否有消息

2. 检查 AI Worker Service 日志:
   ```powershell
   docker logs go-nomads-ai-service --tail 50
   ```

3. 检查 Redis 连接:
   ```powershell
   docker exec -it go-nomads-redis redis-cli
   > KEYS task:*
   ```

### 问题 3: 进度对话框不更新

**症状**:
- 控制台有进度日志
- 对话框显示但不更新

**解决**:
1. 检查 GetX 状态绑定:
   ```dart
   final controller = Get.find<CityDetailController>();
   print(controller.taskProgress.value); // 应该变化
   ```

2. 确保使用 Obx 或 GetBuilder 包裹 UI

3. 检查 onProgress 回调是否触发

### 问题 4: 任务超时

**症状**:
```
❌ 任务超时: 已达最大轮询次数
```

**解决**:
1. 增加最大轮询次数 (在 `async_task_service.dart`):
   ```dart
   pollTaskStatus(maxAttempts: 60) // 3分钟
   ```

2. 检查 DeepSeek API 是否响应慢

3. 查看 AI Service 日志是否有错误

## 📝 测试清单

### 功能测试
- [ ] SignalR 连接成功
- [ ] 创建任务成功
- [ ] 实时进度推送工作
- [ ] 进度对话框更新
- [ ] 任务完成并返回 planId
- [ ] 错误提示正确显示
- [ ] 轮询回退机制正常

### 性能测试
- [ ] SignalR 连接时间 < 2s
- [ ] 任务创建响应 < 500ms
- [ ] 进度推送延迟 < 1s
- [ ] 总完成时间 < 2min

### 兼容性测试
- [ ] Windows 桌面版运行正常
- [ ] Android 模拟器运行正常 (可选)
- [ ] 网络切换后自动重连

### 边界测试
- [ ] 同时创建多个任务
- [ ] SignalR 断线重连
- [ ] 后端重启后恢复
- [ ] 长时间运行稳定性

---

**测试完成后**:
- 记录任何异常行为
- 提交 Issue 或创建 Bug Report
- 更新文档中的已知问题

**下一步**:
- 集成数据库持久化
- 添加任务取消功能
- 优化进度消息文案
- 添加网络状态监听
