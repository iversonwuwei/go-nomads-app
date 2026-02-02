import 'package:go_nomads_app/features/chat/domain/entities/chat.dart';

/// 聊天消息本地仓储接口
///
/// 职责:
/// - 本地持久化聊天消息
/// - 提供消息搜索功能
/// - 缓存聊天室信息
abstract class IChatLocalRepository {
  // ==================== 消息持久化 ====================

  /// 保存单条消息到本地
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [message]: 消息实体
  ///
  /// 返回: 是否保存成功
  Future<bool> saveMessage(String roomId, ChatMessage message);

  /// 批量保存消息到本地
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [messages]: 消息列表
  ///
  /// 返回: 成功保存的消息数量
  Future<int> saveMessages(String roomId, List<ChatMessage> messages);

  /// 获取本地缓存的消息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [page]: 页码 (默认1)
  /// - [pageSize]: 每页数量 (默认50)
  ///
  /// 返回: 消息列表
  Future<List<ChatMessage>> getLocalMessages({
    required String roomId,
    int page = 1,
    int pageSize = 50,
  });

  /// 获取最近的消息 (用于同步)
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [limit]: 限制数量
  ///
  /// 返回: 最近的消息列表
  Future<List<ChatMessage>> getRecentMessages({
    required String roomId,
    int limit = 20,
  });

  /// 删除本地消息
  ///
  /// 参数:
  /// - [messageId]: 消息ID
  ///
  /// 返回: 是否删除成功
  Future<bool> deleteLocalMessage(String messageId);

  /// 清空聊天室的所有本地消息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: 删除的消息数量
  Future<int> clearRoomMessages(String roomId);

  // ==================== 消息搜索 ====================

  /// 搜索本地消息
  ///
  /// 参数:
  /// - [keyword]: 搜索关键词
  /// - [roomId]: 聊天室ID (可选，不传则搜索所有聊天室)
  /// - [page]: 页码 (默认1)
  /// - [pageSize]: 每页数量 (默认20)
  ///
  /// 返回: 匹配的消息列表
  Future<List<ChatMessage>> searchMessages({
    required String keyword,
    String? roomId,
    int page = 1,
    int pageSize = 20,
  });

  /// 搜索消息并返回匹配数量
  ///
  /// 参数:
  /// - [keyword]: 搜索关键词
  /// - [roomId]: 聊天室ID (可选)
  ///
  /// 返回: 匹配的消息数量
  Future<int> searchMessagesCount({
    required String keyword,
    String? roomId,
  });

  /// 按发送者搜索消息
  ///
  /// 参数:
  /// - [senderId]: 发送者ID
  /// - [roomId]: 聊天室ID (可选)
  /// - [page]: 页码 (默认1)
  /// - [pageSize]: 每页数量 (默认20)
  ///
  /// 返回: 该用户发送的消息列表
  Future<List<ChatMessage>> searchMessagesBySender({
    required String senderId,
    String? roomId,
    int page = 1,
    int pageSize = 20,
  });

  /// 按时间范围搜索消息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [startTime]: 开始时间
  /// - [endTime]: 结束时间
  /// - [page]: 页码 (默认1)
  /// - [pageSize]: 每页数量 (默认50)
  ///
  /// 返回: 时间范围内的消息列表
  Future<List<ChatMessage>> searchMessagesByTimeRange({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    int page = 1,
    int pageSize = 50,
  });

  // ==================== 聊天室缓存 ====================

  /// 保存聊天室信息到本地
  ///
  /// 参数:
  /// - [room]: 聊天室实体
  ///
  /// 返回: 是否保存成功
  Future<bool> saveChatRoom(ChatRoom room);

  /// 批量保存聊天室
  ///
  /// 参数:
  /// - [rooms]: 聊天室列表
  ///
  /// 返回: 成功保存的数量
  Future<int> saveChatRooms(List<ChatRoom> rooms);

  /// 获取本地缓存的聊天室列表
  ///
  /// 返回: 聊天室列表
  Future<List<ChatRoom>> getLocalChatRooms();

  /// 获取单个聊天室信息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: 聊天室实体 (可能为null)
  Future<ChatRoom?> getLocalChatRoom(String roomId);

  /// 更新聊天室最后消息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [message]: 最后一条消息
  ///
  /// 返回: 是否更新成功
  Future<bool> updateLastMessage(String roomId, ChatMessage message);

  /// 删除本地聊天室
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: 是否删除成功
  Future<bool> deleteLocalChatRoom(String roomId);

  // ==================== 统计方法 ====================

  /// 获取聊天室的本地消息数量
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: 消息数量
  Future<int> getLocalMessageCount(String roomId);

  /// 获取所有本地消息总数
  ///
  /// 返回: 总消息数量
  Future<int> getTotalLocalMessageCount();

  /// 获取本地缓存的存储大小 (估算)
  ///
  /// 返回: 估算的存储大小 (字节)
  Future<int> getEstimatedStorageSize();

  // ==================== 同步管理 ====================

  /// 获取最后同步时间
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: 最后同步时间 (可能为null)
  Future<DateTime?> getLastSyncTime(String roomId);

  /// 更新同步时间
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [syncTime]: 同步时间
  Future<void> updateSyncTime(String roomId, DateTime syncTime);

  /// 标记消息为已同步
  ///
  /// 参数:
  /// - [messageIds]: 消息ID列表
  Future<void> markMessagesSynced(List<String> messageIds);

  /// 获取未同步的消息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID (可选)
  ///
  /// 返回: 未同步的消息列表
  Future<List<ChatMessage>> getUnsyncedMessages({String? roomId});

  // ==================== 清理方法 ====================

  /// 清理过期的本地消息
  ///
  /// 参数:
  /// - [olderThan]: 清理此时间之前的消息
  ///
  /// 返回: 清理的消息数量
  Future<int> cleanupOldMessages(DateTime olderThan);

  /// 清空所有本地聊天数据
  ///
  /// 返回: 是否清空成功
  Future<bool> clearAllLocalData();
}
