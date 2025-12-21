# 聊天消息持久化与搜索功能实现完成

## 功能概述

实现了聊天消息的本地持久化和全文搜索功能，采用 SQLite 数据库存储，支持离线搜索和网络故障时的本地回退。

## 架构设计

### 1. 数据库层 (DatabaseService)

**位置**: `lib/services/database_service.dart`

- 数据库版本升级到 **v10**
- 新增/重构表结构:
  - `chat_messages` - 聊天消息表（全新设计）
  - `chat_rooms` - 聊天室缓存表

**chat_messages 表结构**:
```sql
CREATE TABLE chat_messages (
  id TEXT PRIMARY KEY,              -- 消息ID (UUID)
  room_id TEXT NOT NULL,            -- 聊天室ID
  sender_id TEXT NOT NULL,          -- 发送者ID
  sender_name TEXT NOT NULL,        -- 发送者名称
  sender_avatar TEXT,               -- 发送者头像
  message TEXT NOT NULL,            -- 消息内容
  message_type TEXT DEFAULT 'text', -- 消息类型
  reply_to_id TEXT,                 -- 回复消息ID
  reply_to_message TEXT,            -- 回复消息内容
  reply_to_user_name TEXT,          -- 被回复用户名
  mentions TEXT,                    -- @提及用户 (JSON)
  attachment_json TEXT,             -- 附件信息 (JSON)
  timestamp INTEGER NOT NULL,       -- 时间戳
  is_synced INTEGER DEFAULT 1,      -- 是否已同步
  created_at INTEGER NOT NULL       -- 创建时间
);

-- 搜索优化索引
CREATE INDEX idx_chat_messages_room_id ON chat_messages(room_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp);
CREATE INDEX idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_message ON chat_messages(message);
```

**chat_rooms 表结构**:
```sql
CREATE TABLE chat_rooms (
  id TEXT PRIMARY KEY,
  room_type TEXT NOT NULL,
  city TEXT,
  country TEXT,
  meetup_id TEXT,
  meetup_title TEXT,
  online_users INTEGER DEFAULT 0,
  total_members INTEGER DEFAULT 0,
  last_message_id TEXT,
  last_message_content TEXT,
  last_message_time INTEGER,
  last_message_sender TEXT,
  updated_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);
```

### 2. 本地仓储层 (ChatLocalRepository)

**接口**: `lib/features/chat/domain/repositories/i_chat_local_repository.dart`
**实现**: `lib/features/chat/infrastructure/repositories/chat_local_repository.dart`

**核心方法**:
```dart
// 消息管理
Future<void> saveMessage(ChatMessage message, String roomId);
Future<void> saveMessages(List<ChatMessage> messages, String roomId);
Future<List<ChatMessage>> getLocalMessages({String? roomId, int page, int pageSize});

// 搜索功能
Future<List<ChatMessage>> searchMessages({
  required String keyword,
  String? roomId,
  int page = 1,
  int pageSize = 20,
});
Future<int> searchMessagesCount({required String keyword, String? roomId});
Future<List<ChatMessage>> searchMessagesBySender({required String senderId, String? roomId});
Future<List<ChatMessage>> searchMessagesByTimeRange({
  required DateTime start,
  required DateTime end,
  String? roomId,
});

// 聊天室缓存
Future<void> saveChatRoom(ChatRoom room);
Future<void> saveChatRooms(List<ChatRoom> rooms);
Future<List<ChatRoom>> getLocalChatRooms();

// 清理
Future<void> cleanupOldMessages({int daysToKeep = 30});
Future<void> clearAllLocalData();
```

### 3. 主仓储层更新 (ChatRepository)

**位置**: `lib/features/chat/infrastructure/repositories/chat_repository.dart`

**新增功能**:
- 可选注入 `IChatLocalRepository` 实现离线支持
- 自动缓存聊天室列表和消息
- 网络失败时自动回退到本地数据
- 本地优先的搜索策略

**搜索方法**:
```dart
Future<Result<List<ChatMessage>>> searchMessages({
  required String keyword,
  String? roomId,
  int page = 1,
  int pageSize = 20,
});

Future<Result<int>> getSearchCount({
  required String keyword,
  String? roomId,
});
```

### 4. 状态管理层更新 (ChatStateController)

**位置**: `lib/features/chat/presentation/controllers/chat_state_controller.dart`

**新增状态**:
```dart
// 搜索状态
bool isSearching;                    // 是否正在搜索
List<ChatMessage> searchResults;     // 搜索结果
String searchKeyword;                // 搜索关键词
int searchResultCount;               // 搜索结果总数
bool hasMoreSearchResults;           // 是否还有更多结果
int searchPage;                      // 当前搜索页
```

**新增方法**:
```dart
// 搜索消息
Future<void> searchMessages(String keyword, {String? roomId});

// 加载更多搜索结果
Future<void> loadMoreSearchResults({String? roomId});

// 清除搜索状态
void clearSearch();

// 查找消息索引
int findMessageIndex(String messageId);
```

### 5. 依赖注入更新

**位置**: `lib/core/di/dependency_injection.dart`

```dart
// Local Repository
Get.lazyPut<IChatLocalRepository>(
  () => ChatLocalRepository(Get.find<DatabaseService>()),
);

// Repository (带本地缓存)
Get.lazyPut<IChatRepository>(
  () => ChatRepository(
    Get.find<HttpService>(),
    Get.find<IChatLocalRepository>(),
  ),
);
```

## 使用示例

### 在 UI 中搜索消息

```dart
// 获取控制器
final chatController = Get.find<ChatStateController>();

// 搜索消息
await chatController.searchMessages('关键词');

// 监听搜索结果
Obx(() {
  if (chatController.isSearching) {
    return CircularProgressIndicator();
  }
  
  return ListView.builder(
    itemCount: chatController.searchResults.length,
    itemBuilder: (context, index) {
      final message = chatController.searchResults[index];
      return MessageTile(message: message);
    },
  );
})

// 加载更多
await chatController.loadMoreSearchResults();

// 清除搜索
chatController.clearSearch();
```

### 在特定聊天室中搜索

```dart
// 只搜索当前聊天室
await chatController.searchMessages(
  '关键词',
  roomId: chatController.currentRoomId,
);
```

## 数据流程

### 消息持久化流程

```
1. 用户发送消息
   └── SendMessageUseCase
       └── ChatRepository.sendMessage()
           ├── HTTP POST 到后端
           └── _localRepository.saveMessage() (本地缓存)

2. 加载消息
   └── GetMessagesUseCase
       └── ChatRepository.getMessages()
           ├── HTTP GET 从后端
           ├── 成功 → _localRepository.saveMessages() (缓存)
           └── 失败 → _localRepository.getLocalMessages() (回退)
```

### 搜索流程

```
1. 用户输入搜索词
   └── ChatStateController.searchMessages()
       └── ChatRepository.searchMessages()
           ├── 优先: _localRepository.searchMessages()
           └── 回退: HTTP API (如果本地无结果)

2. 显示搜索结果
   └── UI 监听 searchResults
       └── 展示匹配的消息列表
```

## 特性

1. **离线支持**: 网络不可用时自动使用本地缓存
2. **搜索优化**: 使用 SQLite 索引加速搜索
3. **分页加载**: 支持分页查询，避免大量数据
4. **自动清理**: 支持清理过期消息（默认30天）
5. **实时同步**: 新消息自动缓存到本地

## 待扩展功能

1. **全文搜索 (FTS)**: 可升级为 SQLite FTS5 实现更高效的全文搜索
2. **搜索高亮**: UI 层实现搜索关键词高亮显示
3. **搜索历史**: 保存用户搜索历史
4. **高级过滤**: 按时间范围、发送者等过滤搜索结果
5. **后端搜索 API**: 实现后端全文搜索接口

## 文件清单

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/services/database_service.dart` | 修改 | 数据库版本升级，新增表结构 |
| `lib/features/chat/domain/repositories/i_chat_local_repository.dart` | 新增 | 本地仓储接口 |
| `lib/features/chat/infrastructure/repositories/chat_local_repository.dart` | 新增 | 本地仓储实现 |
| `lib/features/chat/domain/repositories/i_chat_repository.dart` | 修改 | 新增搜索方法签名 |
| `lib/features/chat/infrastructure/repositories/chat_repository.dart` | 修改 | 集成本地缓存和搜索 |
| `lib/features/chat/presentation/controllers/chat_state_controller.dart` | 修改 | 新增搜索状态和方法 |
| `lib/core/di/dependency_injection.dart` | 修改 | 注册新的依赖 |

## 完成时间

2025-01-XX
