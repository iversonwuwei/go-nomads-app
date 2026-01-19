import 'dart:convert';
import 'dart:developer';

import 'package:go_nomads_app/features/chat/domain/entities/chat.dart';
import 'package:go_nomads_app/features/chat/domain/repositories/i_chat_local_repository.dart';
import 'package:go_nomads_app/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

/// 聊天消息本地仓储实现
///
/// 职责:
/// - 使用 SQLite 持久化聊天消息
/// - 提供高效的消息搜索功能
/// - 缓存聊天室信息
class ChatLocalRepository implements IChatLocalRepository {
  final DatabaseService _databaseService;

  ChatLocalRepository(this._databaseService);

  // ==================== 消息持久化 ====================

  @override
  Future<bool> saveMessage(String roomId, ChatMessage message) async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();

      await db.insert(
        'chat_messages',
        {
          'id': message.id,
          'room_id': roomId,
          'sender_id': message.author.userId,
          'sender_name': message.author.userName,
          'sender_avatar': message.author.userAvatar,
          'message': message.message,
          'message_type': message.type.name,
          'reply_to_id': message.replyTo?.messageId,
          'reply_to_message': message.replyTo?.message,
          'reply_to_user_name': message.replyTo?.userName,
          'mentions': message.mentions.isNotEmpty ? jsonEncode(message.mentions) : null,
          'attachment_json': message.attachment != null ? _serializeAttachment(message.attachment!) : null,
          'timestamp': message.timestamp.toIso8601String(),
          'is_synced': 1,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      log('💾 消息已保存到本地: ${message.id}');
      return true;
    } catch (e) {
      log('❌ 保存消息失败: $e');
      return false;
    }
  }

  @override
  Future<int> saveMessages(String roomId, List<ChatMessage> messages) async {
    if (messages.isEmpty) return 0;

    try {
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();
      int savedCount = 0;

      await db.transaction((txn) async {
        for (final message in messages) {
          await txn.insert(
            'chat_messages',
            {
              'id': message.id,
              'room_id': roomId,
              'sender_id': message.author.userId,
              'sender_name': message.author.userName,
              'sender_avatar': message.author.userAvatar,
              'message': message.message,
              'message_type': message.type.name,
              'reply_to_id': message.replyTo?.messageId,
              'reply_to_message': message.replyTo?.message,
              'reply_to_user_name': message.replyTo?.userName,
              'mentions': message.mentions.isNotEmpty ? jsonEncode(message.mentions) : null,
              'attachment_json': message.attachment != null ? _serializeAttachment(message.attachment!) : null,
              'timestamp': message.timestamp.toIso8601String(),
              'is_synced': 1,
              'created_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          savedCount++;
        }
      });

      log('💾 批量保存消息完成: $savedCount 条');
      return savedCount;
    } catch (e) {
      log('❌ 批量保存消息失败: $e');
      return 0;
    }
  }

  @override
  Future<List<ChatMessage>> getLocalMessages({
    required String roomId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final db = await _databaseService.database;
      final offset = (page - 1) * pageSize;

      final results = await db.query(
        'chat_messages',
        where: 'room_id = ?',
        whereArgs: [roomId],
        orderBy: 'timestamp DESC',
        limit: pageSize,
        offset: offset,
      );

      return results.map(_mapRowToMessage).toList();
    } catch (e) {
      log('❌ 获取本地消息失败: $e');
      return [];
    }
  }

  @override
  Future<List<ChatMessage>> getRecentMessages({
    required String roomId,
    int limit = 20,
  }) async {
    try {
      final db = await _databaseService.database;

      final results = await db.query(
        'chat_messages',
        where: 'room_id = ?',
        whereArgs: [roomId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return results.map(_mapRowToMessage).toList();
    } catch (e) {
      log('❌ 获取最近消息失败: $e');
      return [];
    }
  }

  @override
  Future<bool> deleteLocalMessage(String messageId) async {
    try {
      final db = await _databaseService.database;

      final count = await db.delete(
        'chat_messages',
        where: 'id = ?',
        whereArgs: [messageId],
      );

      return count > 0;
    } catch (e) {
      log('❌ 删除消息失败: $e');
      return false;
    }
  }

  @override
  Future<int> clearRoomMessages(String roomId) async {
    try {
      final db = await _databaseService.database;

      final count = await db.delete(
        'chat_messages',
        where: 'room_id = ?',
        whereArgs: [roomId],
      );

      log('🗑️ 清空聊天室消息: $roomId, 删除 $count 条');
      return count;
    } catch (e) {
      log('❌ 清空聊天室消息失败: $e');
      return 0;
    }
  }

  // ==================== 消息搜索 ====================

  @override
  Future<List<ChatMessage>> searchMessages({
    required String keyword,
    String? roomId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final db = await _databaseService.database;
      final offset = (page - 1) * pageSize;
      final searchPattern = '%$keyword%';

      String whereClause = 'message LIKE ?';
      List<dynamic> whereArgs = [searchPattern];

      if (roomId != null) {
        whereClause += ' AND room_id = ?';
        whereArgs.add(roomId);
      }

      final results = await db.query(
        'chat_messages',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: pageSize,
        offset: offset,
      );

      log('🔍 搜索消息: keyword="$keyword", roomId=$roomId, 找到 ${results.length} 条');
      return results.map(_mapRowToMessage).toList();
    } catch (e) {
      log('❌ 搜索消息失败: $e');
      return [];
    }
  }

  @override
  Future<int> searchMessagesCount({
    required String keyword,
    String? roomId,
  }) async {
    try {
      final db = await _databaseService.database;
      final searchPattern = '%$keyword%';

      String whereClause = 'message LIKE ?';
      List<dynamic> whereArgs = [searchPattern];

      if (roomId != null) {
        whereClause += ' AND room_id = ?';
        whereArgs.add(roomId);
      }

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM chat_messages WHERE $whereClause',
        whereArgs,
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      log('❌ 搜索消息计数失败: $e');
      return 0;
    }
  }

  @override
  Future<List<ChatMessage>> searchMessagesBySender({
    required String senderId,
    String? roomId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final db = await _databaseService.database;
      final offset = (page - 1) * pageSize;

      String whereClause = 'sender_id = ?';
      List<dynamic> whereArgs = [senderId];

      if (roomId != null) {
        whereClause += ' AND room_id = ?';
        whereArgs.add(roomId);
      }

      final results = await db.query(
        'chat_messages',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: pageSize,
        offset: offset,
      );

      return results.map(_mapRowToMessage).toList();
    } catch (e) {
      log('❌ 按发送者搜索消息失败: $e');
      return [];
    }
  }

  @override
  Future<List<ChatMessage>> searchMessagesByTimeRange({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final db = await _databaseService.database;
      final offset = (page - 1) * pageSize;

      final results = await db.query(
        'chat_messages',
        where: 'room_id = ? AND timestamp >= ? AND timestamp <= ?',
        whereArgs: [
          roomId,
          startTime.toIso8601String(),
          endTime.toIso8601String(),
        ],
        orderBy: 'timestamp DESC',
        limit: pageSize,
        offset: offset,
      );

      return results.map(_mapRowToMessage).toList();
    } catch (e) {
      log('❌ 按时间范围搜索消息失败: $e');
      return [];
    }
  }

  // ==================== 聊天室缓存 ====================

  @override
  Future<bool> saveChatRoom(ChatRoom room) async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();

      await db.insert(
        'chat_rooms',
        {
          'id': room.id,
          'room_type': room.roomType.name,
          'city': room.location.city,
          'country': room.location.country,
          'meetup_id': room.meetupId,
          'meetup_title': room.meetupTitle,
          'online_users': room.stats.onlineUsers,
          'total_members': room.stats.totalMembers,
          'last_message_id': room.lastMessage?.id,
          'last_message_content': room.lastMessage?.message,
          'last_message_time': room.lastMessage?.timestamp.toIso8601String(),
          'last_message_sender': room.lastMessage?.author.userName,
          'updated_at': now,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    } catch (e) {
      log('❌ 保存聊天室失败: $e');
      return false;
    }
  }

  @override
  Future<int> saveChatRooms(List<ChatRoom> rooms) async {
    if (rooms.isEmpty) return 0;

    try {
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();
      int savedCount = 0;

      await db.transaction((txn) async {
        for (final room in rooms) {
          await txn.insert(
            'chat_rooms',
            {
              'id': room.id,
              'room_type': room.roomType.name,
              'city': room.location.city,
              'country': room.location.country,
              'meetup_id': room.meetupId,
              'meetup_title': room.meetupTitle,
              'online_users': room.stats.onlineUsers,
              'total_members': room.stats.totalMembers,
              'last_message_id': room.lastMessage?.id,
              'last_message_content': room.lastMessage?.message,
              'last_message_time': room.lastMessage?.timestamp.toIso8601String(),
              'last_message_sender': room.lastMessage?.author.userName,
              'updated_at': now,
              'created_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          savedCount++;
        }
      });

      return savedCount;
    } catch (e) {
      log('❌ 批量保存聊天室失败: $e');
      return 0;
    }
  }

  @override
  Future<List<ChatRoom>> getLocalChatRooms() async {
    try {
      final db = await _databaseService.database;

      final results = await db.query(
        'chat_rooms',
        orderBy: 'updated_at DESC',
      );

      return results.map(_mapRowToChatRoom).toList();
    } catch (e) {
      log('❌ 获取本地聊天室列表失败: $e');
      return [];
    }
  }

  @override
  Future<ChatRoom?> getLocalChatRoom(String roomId) async {
    try {
      final db = await _databaseService.database;

      final results = await db.query(
        'chat_rooms',
        where: 'id = ?',
        whereArgs: [roomId],
        limit: 1,
      );

      if (results.isEmpty) return null;
      return _mapRowToChatRoom(results.first);
    } catch (e) {
      log('❌ 获取本地聊天室失败: $e');
      return null;
    }
  }

  @override
  Future<bool> updateLastMessage(String roomId, ChatMessage message) async {
    try {
      final db = await _databaseService.database;

      final count = await db.update(
        'chat_rooms',
        {
          'last_message_id': message.id,
          'last_message_content': message.message,
          'last_message_time': message.timestamp.toIso8601String(),
          'last_message_sender': message.author.userName,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [roomId],
      );

      return count > 0;
    } catch (e) {
      log('❌ 更新最后消息失败: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteLocalChatRoom(String roomId) async {
    try {
      final db = await _databaseService.database;

      // 先删除聊天室的所有消息
      await clearRoomMessages(roomId);

      // 再删除聊天室
      final count = await db.delete(
        'chat_rooms',
        where: 'id = ?',
        whereArgs: [roomId],
      );

      return count > 0;
    } catch (e) {
      log('❌ 删除本地聊天室失败: $e');
      return false;
    }
  }

  // ==================== 统计方法 ====================

  @override
  Future<int> getLocalMessageCount(String roomId) async {
    try {
      final db = await _databaseService.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM chat_messages WHERE room_id = ?',
        [roomId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      log('❌ 获取消息数量失败: $e');
      return 0;
    }
  }

  @override
  Future<int> getTotalLocalMessageCount() async {
    try {
      final db = await _databaseService.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM chat_messages',
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      log('❌ 获取总消息数量失败: $e');
      return 0;
    }
  }

  @override
  Future<int> getEstimatedStorageSize() async {
    try {
      final db = await _databaseService.database;

      // 估算消息表大小
      final messageResult = await db.rawQuery(
        'SELECT SUM(LENGTH(message) + LENGTH(sender_name) + LENGTH(COALESCE(attachment_json, ""))) as size FROM chat_messages',
      );

      // 估算聊天室表大小
      final roomResult = await db.rawQuery(
        'SELECT SUM(LENGTH(COALESCE(city, "")) + LENGTH(COALESCE(country, "")) + LENGTH(COALESCE(meetup_title, ""))) as size FROM chat_rooms',
      );

      final messageSize = Sqflite.firstIntValue(messageResult) ?? 0;
      final roomSize = Sqflite.firstIntValue(roomResult) ?? 0;

      return messageSize + roomSize;
    } catch (e) {
      log('❌ 获取存储大小失败: $e');
      return 0;
    }
  }

  // ==================== 同步管理 ====================

  @override
  Future<DateTime?> getLastSyncTime(String roomId) async {
    try {
      final db = await _databaseService.database;

      final results = await db.query(
        'chat_messages',
        columns: ['timestamp'],
        where: 'room_id = ? AND is_synced = 1',
        whereArgs: [roomId],
        orderBy: 'timestamp DESC',
        limit: 1,
      );

      if (results.isEmpty) return null;
      final timestamp = results.first['timestamp'] as String?;
      return timestamp != null ? DateTime.tryParse(timestamp) : null;
    } catch (e) {
      log('❌ 获取最后同步时间失败: $e');
      return null;
    }
  }

  @override
  Future<void> updateSyncTime(String roomId, DateTime syncTime) async {
    // 同步时间通过消息的 timestamp 和 is_synced 字段来管理
    // 此方法主要用于触发同步状态的更新
    log('📅 更新同步时间: $roomId -> ${syncTime.toIso8601String()}');
  }

  @override
  Future<void> markMessagesSynced(List<String> messageIds) async {
    if (messageIds.isEmpty) return;

    try {
      final db = await _databaseService.database;

      final placeholders = List.filled(messageIds.length, '?').join(',');
      await db.rawUpdate(
        'UPDATE chat_messages SET is_synced = 1 WHERE id IN ($placeholders)',
        messageIds,
      );

      log('✅ 标记 ${messageIds.length} 条消息为已同步');
    } catch (e) {
      log('❌ 标记消息同步失败: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getUnsyncedMessages({String? roomId}) async {
    try {
      final db = await _databaseService.database;

      String whereClause = 'is_synced = 0';
      List<dynamic> whereArgs = [];

      if (roomId != null) {
        whereClause += ' AND room_id = ?';
        whereArgs.add(roomId);
      }

      final results = await db.query(
        'chat_messages',
        where: whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'timestamp ASC',
      );

      return results.map(_mapRowToMessage).toList();
    } catch (e) {
      log('❌ 获取未同步消息失败: $e');
      return [];
    }
  }

  // ==================== 清理方法 ====================

  @override
  Future<int> cleanupOldMessages(DateTime olderThan) async {
    try {
      final db = await _databaseService.database;

      final count = await db.delete(
        'chat_messages',
        where: 'timestamp < ?',
        whereArgs: [olderThan.toIso8601String()],
      );

      log('🧹 清理旧消息: 删除 $count 条');
      return count;
    } catch (e) {
      log('❌ 清理旧消息失败: $e');
      return 0;
    }
  }

  @override
  Future<bool> clearAllLocalData() async {
    try {
      final db = await _databaseService.database;

      await db.transaction((txn) async {
        await txn.delete('chat_messages');
        await txn.delete('chat_rooms');
      });

      log('🗑️ 已清空所有本地聊天数据');
      return true;
    } catch (e) {
      log('❌ 清空本地聊天数据失败: $e');
      return false;
    }
  }

  // ==================== 私有辅助方法 ====================

  /// 将数据库行映射为 ChatMessage 实体
  ChatMessage _mapRowToMessage(Map<String, dynamic> row) {
    MessageReply? replyTo;
    if (row['reply_to_id'] != null) {
      replyTo = MessageReply(
        messageId: row['reply_to_id'] as String,
        message: row['reply_to_message'] as String? ?? '',
        userName: row['reply_to_user_name'] as String? ?? '',
      );
    }

    List<String> mentions = [];
    final mentionsJson = row['mentions'] as String?;
    if (mentionsJson != null && mentionsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(mentionsJson);
        if (decoded is List) {
          mentions = decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        log('⚠️ 解析 mentions 失败: $e');
      }
    }

    MessageAttachment? attachment;
    final attachmentJson = row['attachment_json'] as String?;
    if (attachmentJson != null && attachmentJson.isNotEmpty) {
      attachment = _deserializeAttachment(attachmentJson);
    }

    final messageTypeStr = row['message_type'] as String? ?? 'text';
    final messageType = MessageType.values.firstWhere(
      (e) => e.name == messageTypeStr,
      orElse: () => MessageType.text,
    );

    return ChatMessage(
      id: row['id'] as String,
      author: MessageAuthor(
        userId: row['sender_id'] as String,
        userName: row['sender_name'] as String,
        userAvatar: row['sender_avatar'] as String?,
      ),
      message: row['message'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      replyTo: replyTo,
      mentions: mentions,
      type: messageType,
      attachment: attachment,
    );
  }

  /// 将数据库行映射为 ChatRoom 实体
  ChatRoom _mapRowToChatRoom(Map<String, dynamic> row) {
    ChatMessage? lastMessage;
    if (row['last_message_id'] != null && row['last_message_content'] != null) {
      lastMessage = ChatMessage(
        id: row['last_message_id'] as String,
        author: MessageAuthor(
          userId: '', // 简化版本，没有存储发送者ID
          userName: row['last_message_sender'] as String? ?? '',
        ),
        message: row['last_message_content'] as String,
        timestamp: DateTime.tryParse(row['last_message_time'] as String? ?? '') ?? DateTime.now(),
      );
    }

    final roomTypeStr = row['room_type'] as String? ?? 'city';
    final roomType = ChatRoomType.values.firstWhere(
      (e) => e.name == roomTypeStr,
      orElse: () => ChatRoomType.city,
    );

    return ChatRoom(
      id: row['id'] as String,
      location: RoomLocation(
        city: row['city'] as String? ?? '',
        country: row['country'] as String? ?? '',
      ),
      stats: RoomStats(
        onlineUsers: row['online_users'] as int? ?? 0,
        totalMembers: row['total_members'] as int? ?? 0,
      ),
      lastMessage: lastMessage,
      roomType: roomType,
      meetupId: row['meetup_id'] as String?,
      meetupTitle: row['meetup_title'] as String?,
    );
  }

  /// 序列化附件
  String _serializeAttachment(MessageAttachment attachment) {
    return jsonEncode({
      'url': attachment.url,
      'fileName': attachment.fileName,
      'fileSize': attachment.fileSize,
      'mimeType': attachment.mimeType,
      'latitude': attachment.latitude,
      'longitude': attachment.longitude,
      'locationName': attachment.locationName,
      'duration': attachment.duration,
      'width': attachment.width,
      'height': attachment.height,
    });
  }

  /// 反序列化附件
  MessageAttachment? _deserializeAttachment(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return MessageAttachment(
        url: map['url'] as String? ?? '',
        fileName: map['fileName'] as String?,
        fileSize: map['fileSize'] as int?,
        mimeType: map['mimeType'] as String?,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        locationName: map['locationName'] as String?,
        duration: map['duration'] as int?,
        width: map['width'] as int?,
        height: map['height'] as int?,
      );
    } catch (e) {
      log('⚠️ 反序列化附件失败: $e');
      return null;
    }
  }
}
