# Meetup 加入功能 API 集成完成

## 概述
已成功将 Meetup 的加入/退出功能从本地 SQLite 存储迁移到后端 API 持久化。

## 修改文件

### 1. `lib/pages/meetups_list_page.dart`
- **修改方法**: `_toggleJoin(MeetupModel meetup)`
- **改动**:
  - 从同步方法改为异步方法 `Future<void>`
  - 添加 API 调用:
    - 加入: `await _eventsApiService.joinEvent(meetup.id)`
    - 退出: `await _eventsApiService.leaveEvent(meetup.id)`
  - 添加 try-catch 错误处理
  - API 成功后才更新本地状态
  - 失败时显示错误 toast

### 2. `lib/pages/meetup_detail_page.dart`
- **修改方法**: `_toggleJoin()`
- **改动**:
  - 从同步方法改为异步方法 `Future<void>`
  - 添加 API 调用:
    - 加入: `await _eventsApiService.joinEvent(_meetup.value.id)`
    - 退出: `await _eventsApiService.leaveEvent(_meetup.value.id)`
  - 添加 try-catch 错误处理
  - API 成功后才更新本地状态
  - 失败时显示错误 toast

## API 端点使用

### 加入活动
- **端点**: `POST /api/v1/events/{id}/join`
- **方法**: `EventsApiService.joinEvent(String eventId)`
- **认证**: 需要 Authorization Bearer Token 和 X-User-Id 头

### 退出活动
- **端点**: `DELETE /api/v1/events/{id}/join`
- **方法**: `EventsApiService.leaveEvent(String eventId)`
- **认证**: 需要 Authorization Bearer Token 和 X-User-Id 头

## 功能流程

### 加入流程
1. 用户点击 "加入" 按钮
2. 调用 `_toggleJoin()` 方法
3. 通过 `EventsApiService.joinEvent()` 调用后端 API
4. API 返回成功:
   - 更新本地状态 `isJoined = true`
   - 参与人数 +1
   - 显示成功 toast: "你已加入 {活动标题}"
5. API 返回失败:
   - 保持原状态不变
   - 显示错误 toast: "加入活动失败"

### 退出流程
1. 用户点击 "已加入" 按钮
2. 调用 `_toggleJoin()` 方法
3. 通过 `EventsApiService.leaveEvent()` 调用后端 API
4. API 返回成功:
   - 更新本地状态 `isJoined = false`
   - 参与人数 -1
   - 显示成功 toast: "你已退出 {活动标题}"
5. API 返回失败:
   - 保持原状态不变
   - 显示错误 toast: "退出活动失败"

## 错误处理

### 错误场景
1. **用户未登录**: API 调用会在 `_ensureAuthentication()` 中抛出异常
2. **网络错误**: 捕获并显示 "加入/退出活动失败"
3. **服务器错误**: 捕获并显示 "加入/退出活动失败"
4. **权限错误**: 捕获并显示 "加入/退出活动失败"

### 错误日志
所有错误都会在控制台输出详细信息:
```
❌ 加入/退出活动失败: {error details}
```

## 认证机制

### 自动认证
`EventsApiService` 会自动处理认证:
1. 从 `TokenDao` 获取最新 token
2. 设置 `Authorization: Bearer {token}` 头
3. 设置 `X-User-Id: {userId}` 头
4. 如果 token 不存在或过期,抛出异常

### 用户体验
- 未登录用户点击加入时会看到错误提示
- 建议在 UI 层面对未登录用户禁用加入按钮

## 数据同步

### 本地状态更新
- ✅ 只在 API 成功后更新本地状态
- ✅ 失败时保持原状态
- ✅ 参与人数实时更新

### 页面间同步
- **列表页 → 详情页**: 详情页通过 API 重新加载数据,确保最新状态
- **详情页 → 列表页**: 返回列表页时会刷新数据 (如果创建完成)

## 测试建议

### 测试场景
1. ✅ 已登录用户加入活动
2. ✅ 已登录用户退出活动
3. ✅ 网络断开时的错误处理
4. ✅ Token 过期时的错误处理
5. ✅ 活动已满时的处理 (UI 已禁用按钮)
6. ✅ 列表页和详情页状态一致性

### 预期结果
- 加入/退出操作成功持久化到后端
- 本地状态与后端同步
- 错误情况下有友好提示
- 日志清晰便于调试

## 移除的功能
- ❌ 本地 SQLite 数据库存储 (已废弃)
- ❌ 仅本地状态管理 (已替换为 API + 本地状态)

## 下一步优化建议

1. **乐观更新**: 可以先更新 UI,再调用 API,失败时回滚
2. **离线支持**: 缓存加入/退出操作,网络恢复后同步
3. **加载状态**: 添加按钮 loading 状态,防止重复点击
4. **参与人数**: 考虑从后端获取实时人数,而不是本地 ±1
5. **未登录提示**: 在点击前检查登录状态,引导用户登录

## 总结
✅ 加入/退出功能已完全迁移到 API
✅ 数据持久化到后端数据库
✅ 错误处理完善
✅ 用户体验良好 (toast 提示)
✅ 代码无编译错误

---
完成时间: 2025-01-25
