# Meetup Detail 参与者 API 集成完成

## 问题分析

### 原始问题
- Meetup Detail 页面的 "View All" 功能显示测试数据,未集成真实后端接口
- 代码尝试从 `getEvent()` API 响应的 `eventData['participants']` 获取参与者列表
- 后端实际上使用独立的 API endpoint 返回参与者数据

### 后端 API 结构
根据用户提供的实际响应:
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": "participant-uuid",
      "eventId": "event-uuid",
      "userId": "user-uuid", 
      "status": "registered",
      "registeredAt": "2025-10-28T...",
      "user": {
        "id": "user-uuid",
        "name": "walden",
        "email": "walden.wuwei@gmail.com",
        "avatar": "https://...",
        "phone": "..."
      }
    }
  ],
  "errors": []
}
```

- **API Endpoint**: `GET /api/v1/events/{id}/participants`
- **认证**: 需要 `Authorization: Bearer {token}` + `X-User-Id` 头
- **数据结构**: 参与者对象包含嵌套的 `user` 对象

---

## 修改内容

### 1. EventsApiService - 添加认证头

**文件**: `lib/services/events_api_service.dart`

**修改前**:
```dart
Future<List<Map<String, dynamic>>> getEventParticipants(String eventId) async {
  try {
    final endpoint = '${ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId)}/participants';
    final response = await _httpService.get<Map<String, dynamic>>(endpoint);
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } else {
      throw Exception('Failed to get event participants: Invalid response');
    }
  } catch (e) {
    if (e is HttpException) {
      rethrow;
    }
    throw Exception('Failed to get event participants: ${e.toString()}');
  }
}
```

**修改后**:
```dart
Future<List<Map<String, dynamic>>> getEventParticipants(String eventId) async {
  try {
    // ✅ 获取认证头 (Authorization + X-User-Id)
    final authHeaders = await _getAuthHeaders();
    
    final endpoint = '${ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId)}/participants';
    final response = await _httpService.get<Map<String, dynamic>>(
      endpoint,
      options: Options(headers: authHeaders),  // ✅ 添加认证头
    );
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!['data'];  // ✅ 从 ApiResponse wrapper 提取 data
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } else {
      throw Exception('Failed to get event participants: Invalid response');
    }
  } catch (e) {
    if (e is HttpException) {
      rethrow;
    }
    throw Exception('Failed to get event participants: ${e.toString()}');
  }
}
```

**关键改动**:
- ✅ 调用 `_getAuthHeaders()` 获取 JWT token 和 X-User-Id
- ✅ 传递 `options: Options(headers: authHeaders)` 到 HTTP 请求
- ✅ 正确解析 ApiResponse wrapper 的 `data` 字段

---

### 2. Meetup Detail Page - 调用独立 API

**文件**: `lib/pages/meetup_detail_page.dart`

**修改前**:
```dart
Future<void> _loadEventDetails() async {
  try {
    _isLoading.value = true;

    // 调用 API 获取详情
    final response = await _eventsApiService.getEvent(widget.meetup.id);

    // 解析响应数据
    final eventData = response;

    // 更新 meetup 数据
    _meetup.value = _convertApiEventToMeetupModel(eventData);

    // ❌ 错误: 从 getEvent() 响应中尝试获取 participants
    final participantsList = eventData['participants'];
    if (participantsList is List) {
      _participants.value = List<Map<String, dynamic>>.from(
          participantsList.map((p) => p as Map<String, dynamic>));
      print('✅ 成功加载 ${_participants.length} 个参与者(包含用户信息)');
    } else {
      _participants.value = [];
      print('⚠️ 响应中没有参与者列表数据');
    }

    print('✅ 成功加载活动详情: ${_meetup.value.title}');
  } catch (e) {
    print('❌ 加载活动详情失败: $e');
    AppToast.error('加载活动详情失败');
  } finally {
    _isLoading.value = false;
  }
}
```

**修改后**:
```dart
Future<void> _loadEventDetails() async {
  try {
    _isLoading.value = true;

    // 调用 API 获取详情
    final response = await _eventsApiService.getEvent(widget.meetup.id);

    // 解析响应数据
    final eventData = response;

    // 更新 meetup 数据
    _meetup.value = _convertApiEventToMeetupModel(eventData);

    // ✅ 调用独立的参与者API获取参与者列表
    // ParticipantResponse 包含: id, eventId, userId, status, registeredAt, user{id, name, email, avatar, phone}
    // 后端返回格式: { success: true, data: [{ userId, user: {...} }] }
    final participantsList = await _eventsApiService.getEventParticipants(widget.meetup.id);
    _participants.value = participantsList;
    print('✅ 成功加载 ${_participants.length} 个参与者(包含用户信息)');

    print('✅ 成功加载活动详情: ${_meetup.value.title}');
  } catch (e) {
    print('❌ 加载活动详情失败: $e');
    AppToast.error('加载活动详情失败');
  } finally {
    _isLoading.value = false;
  }
}
```

**关键改动**:
- ❌ 删除: 从 `eventData['participants']` 读取数据的逻辑
- ✅ 新增: 调用 `_eventsApiService.getEventParticipants(eventId)` 独立 API
- ✅ 简化: 直接赋值 `_participants.value = participantsList` (API 已返回处理好的列表)

---

## UI 渲染 (已正确实现)

**文件**: `lib/pages/meetup_detail_page.dart` (Lines 500-527)

```dart
final participant = _participants[index];
final userId = participant['userId']?.toString() ?? '';

// ✅ 从嵌套的 user 对象中获取头像
final userInfo = participant['user'] as Map<String, dynamic>?;
final userAvatar = userInfo?['avatar'] as String?;
final userName = userInfo?['name'] as String? ?? 'User';

return Padding(
  padding: EdgeInsets.only(right: 12.w),
  child: Tooltip(
    message: userName,  // ✅ 显示真实用户名
    child: CircleAvatar(
      radius: 20.r,
      backgroundImage: NetworkImage(
        userAvatar ?? 'https://i.pravatar.cc/150?u=$userId',  // ✅ 真实头像
      ),
    ),
  ),
);
```

**数据提取逻辑**:
- ✅ 使用 `participant['user']` 访问嵌套的用户对象
- ✅ `userInfo?['avatar']` 获取头像 URL
- ✅ `userInfo?['name']` 获取用户名并显示在 Tooltip
- ✅ 后备逻辑: 使用 `pravatar.cc` 生成占位头像

---

## 数据流程

```
┌─────────────────────────────────────────────────────────────┐
│                  Meetup Detail Page                         │
│                                                             │
│  onInit() → _loadEventDetails()                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ├──► 1. getEvent(eventId)
                          │    └─► 返回: event 基本信息 (无 participants)
                          │
                          └──► 2. getEventParticipants(eventId)  ✅ 新增
                               │
                               ├─► 认证: _getAuthHeaders()
                               │   ├─► Authorization: Bearer {token}
                               │   └─► X-User-Id: {userId}
                               │
                               ├─► 请求: GET /api/v1/events/{id}/participants
                               │
                               └─► 响应: ApiResponse wrapper
                                   {
                                     "success": true,
                                     "data": [
                                       {
                                         "userId": "...",
                                         "user": {
                                           "id": "...",
                                           "name": "walden",
                                           "avatar": "https://...",
                                           ...
                                         }
                                       }
                                     ]
                                   }
                                   │
                                   └─► 解析: response.data['data']
                                       │
                                       └─► 赋值: _participants.value = [...]
                                           │
                                           └─► UI 渲染:
                                               participant['user']['avatar']
                                               participant['user']['name']
```

---

## 测试验证

### 前置条件
- ✅ 用户已登录 (walden.wuwei@gmail.com)
- ✅ EventService 后端服务运行正常
- ✅ UserService 后端服务运行正常 (EventService 通过 Dapr 调用)

### 测试步骤
1. **启动应用**
   - 登录账号: `walden.wuwei@gmail.com`

2. **进入 Meetup Detail 页面**
   - 导航到任意活动详情页 (如 Bangkok Meetup)

3. **查看参与者头像**
   - 确认头像显示真实用户头像 (非测试占位符)
   - 鼠标悬停查看 Tooltip,显示用户真实姓名

4. **点击 "View All" 按钮**
   - 查看完整参与者列表
   - 验证所有头像和名称来自后端数据

5. **检查控制台日志**
   - 查找: `✅ 成功加载 X 个参与者(包含用户信息)`
   - 确认 X > 0 (如果活动有参与者)

### 预期结果
- ✅ 参与者头像显示真实用户照片
- ✅ Tooltip 显示真实用户名 (如 "walden")
- ✅ 控制台打印正确的参与者数量
- ✅ 无 "⚠️ 响应中没有参与者列表数据" 警告

---

## 已知测试数据

根据用户提供的实际响应:
- **Event ID**: `00000000-0000-0000-0000-000000000001` (Bangkok)
- **Participant User ID**: `00000000-0000-0000-0000-000000000001`
- **User Name**: "walden"
- **User Email**: "walden.wuwei@gmail.com"
- **User Avatar**: "https://..."

---

## 修改总结

| 文件 | 修改类型 | 说明 |
|------|---------|------|
| `events_api_service.dart` | 增强 | 为 `getEventParticipants()` 添加认证头 |
| `meetup_detail_page.dart` | 重构 | 调用独立的参与者 API,移除错误的数据提取逻辑 |

**核心改进**:
- ✅ 修复了错误的数据源 (从 `eventData['participants']` → `getEventParticipants()` API)
- ✅ 添加了必需的认证头 (Authorization + X-User-Id)
- ✅ 正确解析 ApiResponse wrapper 的 `data` 字段
- ✅ UI 代码已正确使用嵌套的 `user` 对象

**验证状态**:
- ✅ 代码编译无错误
- ⏳ 需要运行时测试验证数据显示

---

## 下一步

1. **运行应用测试**:
   - 启动 Flutter 应用
   - 登录并查看任意 Meetup Detail 页面
   - 验证参与者数据显示正确

2. **可选优化**:
   - 添加加载状态指示器 (当获取参与者数据时)
   - 添加错误处理 UI (当 API 调用失败时)
   - 实现参与者列表的分页 (如果参与者数量很多)

3. **代码审查检查点**:
   - ✅ 认证头正确设置
   - ✅ API endpoint 路径正确
   - ✅ 数据解析逻辑正确
   - ✅ UI 渲染使用嵌套对象

---

**集成完成时间**: 2025-01-XX  
**修改文件数**: 2  
**状态**: ✅ 代码就绪,等待运行时测试
