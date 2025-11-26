# 事件类型集成测试指南

## 🚀 快速测试步骤

### 1. 确认数据库已初始化
```sql
-- 在 Supabase SQL Editor 中执行
-- 已执行: quick-create-event-types.sql
-- 验证数据是否存在:
SELECT COUNT(*) FROM event_types WHERE is_active = true;
-- 应该返回 20
```

### 2. 确认后端服务运行
```powershell
# 在 EventService 目录下
cd e:\Workspaces\WaldenProjects\go-nomads\src\Services\EventService\EventService
dotnet run

# 应该看到:
# Now listening on: http://localhost:8005
```

### 3. 测试后端 API
```powershell
# 测试获取事件类型列表
curl http://localhost:8005/api/v1/event-types

# 应该返回 JSON 数组，包含 20 个类型
```

### 4. 运行 Flutter 应用
```powershell
cd e:\Workspaces\WaldenProjects\df_admin_mobile
flutter run
```

### 5. 测试界面操作

#### 测试场景 1: 加载类型列表
1. 打开应用，进入"创建聚会"页面
2. 观察控制台日志：
   ```
   🔄 正在从后端加载事件类型列表...
   ✅ 成功加载 20 个事件类型
   ```
3. 点击"聚会类型"下拉框
4. 应该看到 20 个类型选项（根据系统语言显示中文或英文）

#### 测试场景 2: 缓存机制
1. 选择一个类型后，返回上一页
2. 再次进入"创建聚会"页面
3. 观察控制台日志：
   ```
   ✅ 使用缓存的事件类型列表 (20 项)
   ```
4. **不应该**看到"正在从后端加载..."，证明缓存生效

#### 测试场景 3: 选择预设类型
1. 点击"聚会类型"下拉框
2. 选择"社交网络" (或 "Networking")
3. 观察控制台日志：
   ```
   ✅ 选择类型: 社交网络 (Networking)
   ```
4. 填写其他必填字段
5. 点击"创建"按钮
6. 观察网络请求中的 `category` 字段应该是 "Networking"

#### 测试场景 4: 自定义类型
1. 点击"聚会类型"下拉框
2. 选择"+ 自定义类型"
3. 输入自定义类型名称，如"摄影分享会"
4. 填写其他必填字段
5. 点击"创建"按钮
6. 提交应该成功

#### 测试场景 5: 多语言切换
1. 切换系统语言为英文
2. 进入"创建聚会"页面
3. 点击"Meetup Type"下拉框
4. 应该看到英文类型名称（Networking, Workshop, etc.）
5. 切换回中文
6. 应该看到中文类型名称（社交网络、工作坊等）

#### 测试场景 6: 错误处理
1. 停止后端服务 (Ctrl+C)
2. 清除应用缓存（重新安装或清除数据）
3. 打开应用，进入"创建聚会"页面
4. 观察控制台日志：
   ```
   ❌ 加载事件类型失败: ...
   ⚠️ 使用后备事件类型列表
   ```
5. 下拉框应该显示 3 个后备类型：社交聚会、休闲活动、工作坊

## 🔍 日志检查点

### 正常加载流程
```
🔄 正在从后端加载事件类型列表...
✅ 成功加载 20 个事件类型
```

### 使用缓存
```
✅ 使用缓存的事件类型列表 (20 项)
```

### 选择类型
```
✅ 选择类型: 社交网络 (Networking)
✅ 使用事件类型: 社交网络 (Networking)
```

### API 失败时
```
❌ 加载事件类型失败: DioException [...]
⚠️ 使用后备事件类型列表
```

## 🐛 常见问题排查

### 问题 1: 类型列表为空
**原因**: 
- 后端服务未启动
- 数据库未初始化
- API 路径错误

**解决**:
1. 检查后端服务是否运行: `curl http://localhost:8005/api/v1/event-types`
2. 检查数据库: `SELECT * FROM event_types WHERE is_active = true;`
3. 查看 Flutter 控制台错误日志

### 问题 2: 显示英文但系统是中文
**原因**: 
- locale 获取错误
- 数据库中 name 字段为空

**解决**:
1. 检查 `Localizations.localeOf(context).languageCode`
2. 检查数据库: `SELECT name, en_name FROM event_types LIMIT 5;`

### 问题 3: 提交失败
**原因**:
- typeId 未正确保存
- EventType 转换为 MeetupType 失败

**解决**:
1. 检查选择时的日志: `✅ 选择类型: ...`
2. 检查提交时的日志: `✅ 使用事件类型: ...`
3. 检查网络请求中的 `category` 字段值

### 问题 4: 重复加载
**原因**:
- EventTypeController 未正确初始化为单例
- _hasLoaded 标志未生效

**解决**:
1. 确认 Controller 使用 `Get.put()` 而非 `Get.find()`
2. 检查 `_hasLoaded` 标志: 在 `loadEventTypes()` 开头添加日志

## ✅ 验收标准

- [x] 首次进入页面自动加载类型列表
- [x] 控制台显示"成功加载 20 个事件类型"
- [x] 下拉框显示 20+ 个选项（含自定义）
- [x] 根据系统语言显示中文或英文名称
- [x] 第二次进入使用缓存，不重复请求
- [x] 选择类型后正确保存 id 和名称
- [x] 提交时使用 enName 作为 category
- [x] 自定义类型功能正常
- [x] API 失败时显示后备类型
- [x] 无编译错误和警告

## 📊 性能指标

- **首次加载时间**: < 500ms（本地后端）
- **缓存命中率**: > 90%（正常使用）
- **UI 响应时间**: < 100ms（选择操作）
- **后备方案触发**: < 100ms（API 失败时）

## 🎉 测试通过标志

当你看到以下现象时，说明集成成功：

1. ✅ 控制台无红色错误
2. ✅ 类型下拉框显示完整列表
3. ✅ 第二次进入不重复请求
4. ✅ 提交成功创建 meetup
5. ✅ 多语言切换正常
6. ✅ API 失败时有后备方案

恭喜！事件类型集成测试通过！🎊
