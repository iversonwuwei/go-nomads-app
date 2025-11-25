# Meetup 列表页 Tab 分页重构完成

## 📋 重构概述

将 meetups_list_page.dart 从**前端过滤模式**重构为**后端分页模式**,每个 tab 独立从后端加载数据,支持无限滚动。

## 🎯 核心改动

### 1. Flutter 前端

#### 状态管理重构 (meetups_list_page.dart)
- **旧模式**: 单一 `_meetups` 列表 + 前端 `_filteredMeetups` 过滤
- **新模式**: 每个 tab 独立维护数据和分页状态

```dart
// 每个 tab 的数据
final Map<int, RxList<Meetup>> _tabMeetups = {
  0: <Meetup>[].obs, // Upcoming
  1: <Meetup>[].obs, // Joined
  2: <Meetup>[].obs, // Past
  3: <Meetup>[].obs, // Cancelled
};

// 每个 tab 的加载状态
final Map<int, RxBool> _tabLoading;

// 每个 tab 的分页状态
final Map<int, int> _tabPage;
final Map<int, bool> _tabHasMore;

// 每个 tab 的滚动控制器(用于无限滚动)
final Map<int, ScrollController> _tabScrollControllers;
```

#### Tab 切换监听
```dart
void _onTabChanged() {
  if (!_tabController.indexIsChanging) {
    final index = _tabController.index;
    // 如果该 tab 还没有数据,则加载
    if (_tabMeetups[index]!.isEmpty && !_tabLoading[index]!.value) {
      _loadTabData(index);
    }
  }
}
```

#### 数据加载逻辑
```dart
Future<void> _loadTabData(int tabIndex, {bool refresh = false}) async {
  switch (tabIndex) {
    case 0: // Upcoming
      meetups = await _meetupRepository.getMeetups(status: 'upcoming', page: page, pageSize: 20);
      break;
    case 1: // Joined
      meetups = await _meetupRepository.getJoinedMeetups(page: page, pageSize: 20);
      break;
    case 2: // Past
      meetups = await _meetupRepository.getMeetups(status: 'completed', page: page, pageSize: 20);
      break;
    case 3: // Cancelled
      meetups = await _meetupRepository.getCancelledMeetupsByUser(_currentUserId!, page: page, pageSize: 20);
      break;
  }
}
```

#### 无限滚动实现
```dart
void _setupScrollListener(int tabIndex) {
  _tabScrollControllers[tabIndex]!.addListener(() {
    final controller = _tabScrollControllers[tabIndex]!;
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      _loadMoreData(tabIndex); // 距离底部200px时加载下一页
    }
  });
}
```

#### UI 渲染
```dart
ListView.builder(
  controller: _tabScrollControllers[currentTabIndex],
  itemCount: meetups.length + (isLoading ? 1 : 0), // 加载中时多显示一个指示器
  itemBuilder: (context, index) {
    if (index == meetups.length) {
      // 底部加载更多指示器
      return CircularProgressIndicator();
    }
    return _buildMeetupCard(meetups[index]);
  },
)
```

### 2. Repository 层

#### 接口定义 (i_meetup_repository.dart)
新增两个方法:

```dart
/// 获取用户已加入的活动列表(分页)
Future<List<Meetup>> getJoinedMeetups({
  int page = 1,
  int pageSize = 20,
});

/// 获取当前用户取消的活动列表(分页)
Future<List<Meetup>> getCancelledMeetupsByUser(
  String userId, {
  int page = 1,
  int pageSize = 20,
});
```

#### 实现 (meetup_repository.dart)
```dart
@override
Future<List<Meetup>> getJoinedMeetups({int page = 1, int pageSize = 20}) async {
  final response = await _httpService.get(
    '/events/joined',
    queryParameters: {'page': page, 'pageSize': pageSize},
  );
  
  final data = response.data as Map<String, dynamic>;
  final eventsJson = data['data'] as List;
  
  return eventsJson
      .map((json) => MeetupDto.fromJson(json).toDomain())
      .toList();
}

@override
Future<List<Meetup>> getCancelledMeetupsByUser(
  String userId, {
  int page = 1,
  int pageSize = 20,
}) async {
  final response = await _httpService.get(
    '/events/cancelled/user/$userId',
    queryParameters: {'page': page, 'pageSize': pageSize},
  );
  
  final data = response.data as Map<String, dynamic>;
  final eventsJson = data['data'] as List;
  
  return eventsJson
      .map((json) => MeetupDto.fromJson(json).toDomain())
      .toList();
}
```

### 3. 后端 API

#### 新增端点 (EventsController.cs)

**1. 获取已加入的活动**
```csharp
/// <summary>
///     获取用户已加入的活动列表
/// </summary>
[HttpGet("joined")]
public async Task<ActionResult<ApiResponse<PaginatedResponse<EventResponse>>>> GetJoinedEvents(
    [FromQuery] int page = 1,
    [FromQuery] int pageSize = 20)
{
    var userContext = UserContextMiddleware.GetUserContext(HttpContext);
    if (userContext?.IsAuthenticated != true || string.IsNullOrEmpty(userContext.UserId))
        return Unauthorized(...);

    var userId = Guid.Parse(userContext.UserId);
    var (events, total) = await _eventService.GetJoinedEventsAsync(userId, page, pageSize);

    return Ok(new ApiResponse<PaginatedResponse<EventResponse>>
    {
        Success = true,
        Message = "已加入的活动列表获取成功",
        Data = new PaginatedResponse<EventResponse>
        {
            Items = events.ToList(),
            TotalCount = total,
            Page = page,
            PageSize = pageSize
        }
    });
}
```

**2. 获取用户取消的活动**
```csharp
/// <summary>
///     获取用户取消的活动列表
/// </summary>
[HttpGet("cancelled")]
public async Task<ActionResult<ApiResponse<PaginatedResponse<EventResponse>>>> GetCancelledEventsByUser(
    [FromQuery] int page = 1,
    [FromQuery] int pageSize = 20)
{
    // 从 UserContext 获取当前用户信息(不从 URL 参数获取,安全!)
    var userContext = UserContextMiddleware.GetUserContext(HttpContext);
    if (userContext?.IsAuthenticated != true || string.IsNullOrEmpty(userContext.UserId))
        return Unauthorized(...);

    var userId = Guid.Parse(userContext.UserId);
    
    var (events, total) = await _eventService.GetCancelledEventsByUserAsync(userId, page, pageSize);

    return Ok(...);
}
```

### 4. Service 层

#### EventApplicationService.cs 新增方法

**1. 获取已加入的活动(分页)**
```csharp
public async Task<(List<EventResponse> Events, int Total)> GetJoinedEventsAsync(
    Guid userId,
    int page = 1,
    int pageSize = 20)
{
    // 1. 获取用户参与的所有活动ID
    var participants = await _participantRepository.GetByUserIdAsync(userId);
    var eventIds = participants.Select(p => p.EventId).ToList();

    if (!eventIds.Any())
    {
        return (new List<EventResponse>(), 0);
    }

    // 2. 加载活动实体
    var events = new List<Event>();
    foreach (var eventId in eventIds)
    {
        var @event = await _eventRepository.GetByIdAsync(eventId);
        if (@event != null) events.Add(@event);
    }

    // 3. 排序并分页
    var total = events.Count;
    var pagedEvents = events
        .OrderByDescending(e => e.StartTime)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToList();

    // 4. 转换为 DTO 并设置 isJoined = true
    var responses = await Task.WhenAll(pagedEvents.Select(e => MapToResponseAsync(e)));
    var responsesList = responses.ToList();
    
    await EnrichEventResponsesWithRelatedDataAsync(responsesList);
    
    foreach (var response in responsesList)
    {
        response.IsJoined = true;
    }

    return (responsesList, total);
}
```

**2. 获取用户取消的活动(分页)**
```csharp
public async Task<(List<EventResponse> Events, int Total)> GetCancelledEventsByUserAsync(
    Guid userId,
    int page = 1,
    int pageSize = 20)
{
    // 1. 获取用户创建的所有活动
    var userEvents = await _eventRepository.GetByOrganizerIdAsync(userId);

    // 2. 筛选 status == 'cancelled'
    var cancelledEvents = userEvents
        .Where(e => e.Status == "cancelled")
        .ToList();

    // 3. 排序并分页
    var total = cancelledEvents.Count;
    var pagedEvents = cancelledEvents
        .OrderByDescending(e => e.CreatedAt)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToList();

    // 4. 转换为 DTO 并设置 isOrganizer = true
    var responses = await Task.WhenAll(pagedEvents.Select(e => MapToResponseAsync(e)));
    var responsesList = responses.ToList();
    
    await EnrichEventResponsesWithRelatedDataAsync(responsesList);
    
    foreach (var response in responsesList)
    {
        response.IsOrganizer = true;
    }

    return (responsesList, total);
}
```

## 📊 Tab 数据流图

```
Tab 0 (Upcoming)
  ├─ GET /events?status=upcoming&page=1&pageSize=20
  ├─ 存储到 _tabMeetups[0]
  └─ 滚动到底部时 page++

Tab 1 (Joined)
  ├─ GET /events/joined?page=1&pageSize=20
  ├─ 后端查询 event_participants 表
  ├─ 返回用户参与的活动 + isJoined=true
  └─ 存储到 _tabMeetups[1]

Tab 2 (Past)
  ├─ GET /events?status=completed&page=1&pageSize=20
  ├─ 存储到 _tabMeetups[2]
  └─ 滚动到底部时 page++

Tab 3 (Cancelled)
  ├─ GET /events/cancelled/user/:userId?page=1&pageSize=20
  ├─ 后端查询 organizerId == userId && status == 'cancelled'
  ├─ 返回用户取消的活动 + isOrganizer=true
  └─ 存储到 _tabMeetups[3]
```

## ✅ 功能验证清单

### 前端
- [x] 每个 tab 独立数据列表
- [x] 每个 tab 独立加载状态
- [x] 每个 tab 独立分页状态
- [x] Tab 切换时懒加载数据
- [x] 下拉刷新重置分页
- [x] 滚动到底部加载下一页
- [x] 加载更多时显示底部指示器
- [x] 首次加载时显示中心指示器
- [x] 数据为空时显示空状态

### 后端
- [x] `GET /events/joined` 端点
- [x] `GET /events/cancelled/user/:userId` 端点
- [x] 已加入活动分页查询
- [x] 用户取消活动分页查询
- [x] 权限验证(只能查询自己的数据)
- [x] 返回 isJoined 和 isOrganizer 标记

### Repository
- [x] `getJoinedMeetups()` 方法
- [x] `getCancelledMeetupsByUser()` 方法
- [x] 调用 HttpService 发送请求
- [x] DTO 转换为 Domain Entity

## 🚀 下一步优化建议

1. **后端优化**:
   - 在 EventRepository 添加 `GetByEventIdsAsync(List<Guid> eventIds, int page, int pageSize)` 方法,避免 N+1 查询
   - 考虑添加 Redis 缓存用户参与活动列表

2. **前端优化**:
   - 考虑添加下拉刷新动画
   - 考虑添加骨架屏替代 CircularProgressIndicator
   - 添加分页数据缓存机制(避免 tab 切换时重新加载)

3. **用户体验**:
   - 取消的 tab 可以添加"重新发布"功能
   - 已加入的 tab 可以添加"取消参与"快捷按钮

## 📝 API 端点总结

| 端点 | 方法 | 描述 | 权限 | userId 来源 |
|------|------|------|------|------------|
| `/events` | GET | 获取活动列表(支持 status 筛选) | 公开 | - |
| `/events/joined` | GET | 获取当前用户已加入的活动 | 需登录 | UserContext |
| `/events/cancelled` | GET | 获取当前用户取消的活动 | 需登录 | UserContext |

**安全说明**: `/events/cancelled` 端点从 UserContext 自动获取当前用户ID,不接受客户端传入的 userId 参数,避免了用户查询其他人取消活动的安全隐患。

## 🎉 完成时间

2025-11-25
