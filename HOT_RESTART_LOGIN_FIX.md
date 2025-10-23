# 热重启登录状态保持 - 问题解决

## 问题原因

你遇到的问题是因为 `main.dart` 中设置了 `forceReset: true`，导致每次应用启动（包括热重启）时都会：

1. 删除整个 SQLite 数据库文件
2. 包括 tokens 表中保存的登录 token
3. 重新创建空数据库
4. 导致 `AppInitService` 无法从数据库恢复登录状态

```dart
// ❌ 之前的配置（有问题）
await dbInitializer.initializeDatabase(forceReset: true);
```

## 已修复

已将 `forceReset` 改为 `false`：

```dart
// ✅ 现在的配置（已修复）
await dbInitializer.initializeDatabase(forceReset: false);
```

## 验证步骤

### 1. 测试登录状态保持

1. **登录应用**
   - 打开应用
   - 进入登录页面
   - 使用邮箱和密码登录
   - 确认登录成功

2. **执行热重启**
   - 在 VS Code 中按 `Cmd+Shift+F5` (macOS) 或 `Ctrl+Shift+F5` (Windows/Linux)
   - 或者在终端运行: `r` (hot restart)

3. **验证结果**
   - ✅ 应该看到日志：`✅ 用户登录状态已恢复`
   - ✅ 应该直接进入首页，无需重新登录
   - ✅ 可以正常访问需要登录的页面

### 2. 使用调试工具检查

已创建调试工具 `LoginDebugHelper`，可以查看详细的登录状态：

```dart
import 'package:your_app/utils/login_debug_helper.dart';

// 在任何地方调用
await LoginDebugHelper.printLoginStatus();
```

**输出示例**：
```
============================================================
🔍 登录状态调试信息
============================================================
1️⃣ 内存中的 token:
   ✅ 存在: eyJhbGciOiJIUzI1NiIs...

2️⃣ SQLite 中的 token:
   ✅ 找到 token:
      用户ID: user123
      Access Token: eyJhbGciOiJIUzI1NiIs...
      Token类型: Bearer
      过期时间: 3600 秒
      创建时间: 2025-10-23 10:30:00
      更新时间: 2025-10-23 10:30:00

3️⃣ Token 过期状态:
   ✅ 有效

4️⃣ checkLoginStatus() 结果:
   ✅ 已登录
============================================================
```

### 3. 查看启动日志

热重启后，应该看到以下日志序列：

```
✅ 应用初始化
📍 使用 Geolocator 进行定位服务
💾 初始化 SQLite 数据库...
✅ 数据库初始化成功
🎯 初始化全局控制器...
✅ 全局控制器初始化完成
🔑 开始恢复登录状态...
🚀 开始初始化应用...
🔐 checkLoginStatus: 开始检查登录状态...
🔍 内存中没有 token，尝试从 SQLite 获取...
📦 从 SQLite 找到 token，用户ID: user123
✅ Token 已从 SQLite 恢复到内存
✅ 用户登录状态已恢复
✅ 应用初始化完成
✅ 登录状态恢复完成
```

## 热重启 vs 热重载

### Hot Reload (热重载) - `r`
- **不会**重新运行 `main()`
- **不会**初始化数据库
- **不会**调用 `AppInitService.initialize()`
- 只更新 widget 代码
- 内存中的 token 保持不变

### Hot Restart (热重启) - `R`
- **会**重新运行 `main()`
- **会**初始化数据库（但不删除）
- **会**调用 `AppInitService.initialize()`
- **会**从 SQLite 恢复 token
- 清空所有内存状态，但 SQLite 文件保留

### Full Restart (完全重启)
- 完全关闭应用
- 重新启动应用
- 同样从 SQLite 恢复登录状态

## 登录状态恢复流程

```
应用启动 (Hot Restart)
    ↓
main() 执行
    ↓
初始化数据库 (forceReset: false)
    ├─ 不删除数据库 ✅
    └─ tokens 表保留 ✅
    ↓
AppInitService.initialize()
    ↓
checkLoginStatus()
    ├─ 检查内存 token (空)
    ├─ 查询 SQLite
    ├─ 找到 token ✅
    ├─ 验证未过期 ✅
    └─ 恢复到内存 ✅
    ↓
✅ 登录状态已恢复
    ↓
用户无需重新登录 🎉
```

## 什么时候需要重新登录

只有在以下情况下才需要重新登录：

1. **Token 过期**
   - access_token 超过有效期
   - refresh_token 也过期
   - 无法自动刷新

2. **用户主动退出**
   - 点击退出按钮
   - 调用 `logout()` 方法
   - 清空所有 token

3. **数据库被清空**
   - 设置 `forceReset: true`
   - 手动删除应用数据
   - 卸载重装应用

4. **Token 被服务器吊销**
   - 后端主动吊销 token
   - 安全原因强制下线

## 常见问题排查

### Q1: 热重启后还是需要登录？

**检查步骤**：
1. 确认 `main.dart` 中 `forceReset: false`
2. 查看启动日志，确认有 "从 SQLite 找到 token"
3. 运行 `LoginDebugHelper.printLoginStatus()` 查看详情

### Q2: 看到 "SQLite 中没有保存的 token"？

**可能原因**：
- 还没有登录过
- 之前使用 `forceReset: true` 清空了数据库
- 手动清除了应用数据

**解决方法**：
重新登录一次，确保 token 保存到数据库

### Q3: Token 总是显示已过期？

**检查**：
- 后端返回的 `expiresIn` 是否正确
- 本地时间是否准确
- 是否在过期时间附近（5分钟缓冲）

### Q4: 内存中有 token，但 SQLite 中没有？

**说明**：
这是异常情况，可能是保存失败

**解决**：
重新登录，查看日志确认 "Token 已保存到 SQLite"

## 开发建议

### forceReset 的使用场景

```dart
// 🟢 日常开发（推荐）
await dbInitializer.initializeDatabase(forceReset: false);

// 🟡 需要重置测试数据
await dbInitializer.initializeDatabase(forceReset: true);

// 🔴 不要在生产环境使用
// await dbInitializer.initializeDatabase(forceReset: true); // ❌
```

### 调试登录状态

```dart
// 在需要调试的地方添加
import 'package:your_app/utils/login_debug_helper.dart';

// 打印详细状态
await LoginDebugHelper.printLoginStatus();

// 或者添加调试按钮
FloatingActionButton(
  onPressed: () => LoginDebugHelper.printLoginStatus(),
  child: Icon(Icons.bug_report),
)
```

### 测试登出功能

```dart
// 清除登录数据
await LoginDebugHelper.clearLoginData();

// 或者调用 auth service
await NomadsAuthService().logout();
```

## 总结

✅ **问题已解决**：将 `forceReset` 改为 `false`

✅ **验证方法**：
- 登录 → 热重启 → 检查是否保持登录状态
- 使用 `LoginDebugHelper` 查看详细信息
- 查看启动日志确认 token 恢复

✅ **预期行为**：
- 热重启不会清空 SQLite 数据
- Token 自动从数据库恢复
- 用户无需重新登录

✅ **自动刷新**：
- Token 过期时自动使用 refresh_token 刷新
- 刷新成功后继续保持登录
- 刷新失败才需要重新登录
