# 活动邀请功能实现完成

## 概述

实现了从 member detail 页面邀请成员参加聚会的完整功能，包括后端 API、通知发送和 Flutter 客户端集成。

## 功能说明

用户可以：
1. 在 member detail 页面点击"邀请参加聚会"按钮
2. 跳转到聚会列表页面选择一个聚会
3. 确认后发送邀请，被邀请者会收到通知

## 后端实现

### 1. 新增实体
- **EventInvitation** (`Services/EventService/Domain/Entities/EventInvitation.cs`)
  - 字段：Id, EventId, InviterId, InviteeId, Status, Message, CreatedAt, RespondedAt, ExpiresAt
  - 状态：Pending, Accepted, Rejected, Expired
  - 方法：Create(), Accept(), Reject(), IsExpired(), IsPending()

### 2. 新增仓储
- **IEventInvitationRepository** (`Domain/Repositories/IEventInvitationRepository.cs`)
- **EventInvitationRepository** (`Infrastructure/Repositories/EventInvitationRepository.cs`)
  - Supabase 实现，完整 CRUD 操作

### 3. 新增 DTOs
- **InviteToEventRequest**: meetupId, inviteeId, message
- **EventInvitationResponse**: id, eventId, event, inviter, invitee, status, message, createdAt, respondedAt, expiresAt
- **RespondToInvitationRequest**: accept

### 4. API 端点 (EventsController)

| Method | Path | 描述 |
|--------|------|------|
| POST | `/api/v1/events/{eventId}/invitations` | 发送邀请 |
| POST | `/api/v1/events/invitations/{id}/respond` | 响应邀请 |
| GET | `/api/v1/events/invitations/{id}` | 获取邀请详情 |
| GET | `/api/v1/events/invitations/received` | 获取收到的邀请 |
| GET | `/api/v1/events/invitations/sent` | 获取发出的邀请 |

### 5. 通知集成
通过 Dapr pub/sub 发送通知到 MessageService：
- 发送邀请时：发送 `event_invitation` 类型通知给被邀请人
- 响应邀请时：发送 `event_invitation_response` 类型通知给邀请人

## Flutter 实现

### 1. 通知类型扩展
- `NotificationType.eventInvitation`: 活动邀请通知
- `NotificationType.eventInvitationResponse`: 邀请响应通知

### 2. 数据模型
- **MeetupInvitation**: 邀请实体
- **InviterInfo**: 邀请人信息
- **InviteeInfo**: 被邀请人信息

### 3. 仓储层
- **IMeetupRepository**: 添加邀请相关方法
- **MeetupRepository**: API 调用实现

### 4. 控制器
- **MeetupStateController**: 添加邀请方法
  - `inviteToMeetup()`: 发送邀请
  - `respondToInvitation()`: 响应邀请
  - `getReceivedInvitations()`: 获取收到的邀请
  - `getSentInvitations()`: 获取发出的邀请

### 5. UI 页面
- **InviteToMeetupPage**: 更新确认按钮调用实际 API

## 数据库迁移

创建 `event_invitations` 表:
```sql
-- migrations/20250702_create_event_invitations.sql
CREATE TABLE event_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id),
    inviter_id VARCHAR(100) NOT NULL,
    invitee_id VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE
);
```

## 修改的文件

### 后端 (go-noma)
1. `Services/EventService/Domain/Entities/EventInvitation.cs` (新增)
2. `Services/EventService/Domain/Repositories/IEventInvitationRepository.cs` (新增)
3. `Services/EventService/Infrastructure/Repositories/EventInvitationRepository.cs` (新增)
4. `Services/EventService/Application/DTOs/EventDTOs.cs` (修改)
5. `Services/EventService/Application/Services/IEventService.cs` (修改)
6. `Services/EventService/Application/Services/EventApplicationService.cs` (修改)
7. `Services/EventService/Api/Controllers/EventsController.cs` (修改)
8. `Services/EventService/Program.cs` (修改)
9. `migrations/20250702_create_event_invitations.sql` (新增)

### Flutter (open-platform-app)
1. `lib/features/notifications/domain/entities/app_notification.dart` (修改)
2. `lib/features/meetup/domain/repositories/i_meetup_repository.dart` (修改)
3. `lib/features/meetup/infrastructure/repositories/meetup_repository.dart` (修改)
4. `lib/features/meetup/presentation/controllers/meetup_state_controller.dart` (修改)
5. `lib/core/di/dependency_injection.dart` (修改)
6. `lib/pages/invite_to_meetup_page.dart` (修改)

## 使用流程

1. **发送邀请**:
   - 用户在 member detail 页面点击"邀请参加聚会"
   - 选择聚会，确认发送
   - 系统创建邀请记录并发送通知

2. **接收邀请**:
   - 被邀请者收到推送通知
   - 在通知列表查看邀请详情
   - 点击接受或拒绝

3. **邀请响应**:
   - 接受：自动 RSVP 到活动
   - 拒绝：更新邀请状态
   - 邀请人收到响应通知

## 部署步骤

1. 运行数据库迁移:
   ```bash
   psql -d your_database -f migrations/20250702_create_event_invitations.sql
   ```

2. 部署 EventService 后端

3. 构建并部署 Flutter 应用

## 测试

### API 测试
```bash
# 发送邀请
curl -X POST "http://localhost:5000/api/v1/events/{eventId}/invitations" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"inviteeId": "user-id", "message": "Join us!"}'

# 响应邀请
curl -X POST "http://localhost:5000/api/v1/events/invitations/{id}/respond" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"accept": true}'

# 获取收到的邀请
curl "http://localhost:5000/api/v1/events/invitations/received?status=pending" \
  -H "Authorization: Bearer {token}"
```
