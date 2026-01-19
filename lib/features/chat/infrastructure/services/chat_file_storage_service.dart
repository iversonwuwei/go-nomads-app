import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:go_nomads_app/features/chat/domain/entities/chat.dart';
import 'package:path_provider/path_provider.dart';

/// 聊天记录文件存储服务
///
/// 按天将聊天记录保存为 JSON 文件
/// 文件结构:
/// /app_documents/chat_history/
///   /{roomId}/
///     /2025-12-21.json
///     /2025-12-20.json
///     ...
class ChatFileStorageService {
  static const String _chatHistoryFolder = 'chat_history';

  /// 获取聊天历史根目录
  Future<Directory> _getChatHistoryDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final chatDir = Directory('${appDir.path}/$_chatHistoryFolder');
    if (!await chatDir.exists()) {
      await chatDir.create(recursive: true);
    }
    return chatDir;
  }

  /// 获取特定聊天室的目录
  Future<Directory> _getRoomDir(String roomId) async {
    final chatDir = await _getChatHistoryDir();
    // 将 roomId 中的特殊字符替换为下划线，避免文件系统问题
    final safeRoomId = roomId.replaceAll(RegExp(r'[^\w\-]'), '_');
    final roomDir = Directory('${chatDir.path}/$safeRoomId');
    if (!await roomDir.exists()) {
      await roomDir.create(recursive: true);
    }
    return roomDir;
  }

  /// 获取日期字符串 (yyyy-MM-dd)
  String _getDateString(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 获取特定日期的聊天记录文件
  Future<File> _getDayFile(String roomId, DateTime date) async {
    final roomDir = await _getRoomDir(roomId);
    final dateStr = _getDateString(date);
    return File('${roomDir.path}/$dateStr.json');
  }

  /// 保存单条消息
  Future<void> saveMessage(ChatMessage message, String roomId) async {
    try {
      log('💾 正在保存消息到文件, roomId: $roomId, messageId: ${message.id}');
      final file = await _getDayFile(roomId, message.timestamp);
      log('💾 文件路径: ${file.path}');
      List<Map<String, dynamic>> messages = [];

      // 读取现有消息
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> existing = json.decode(content);
          messages = existing.cast<Map<String, dynamic>>();
        }
      }

      // 检查是否已存在（避免重复）
      final existingIndex = messages.indexWhere((m) => m['id'] == message.id);
      final messageJson = _messageToJson(message, roomId);

      if (existingIndex >= 0) {
        // 更新现有消息
        messages[existingIndex] = messageJson;
      } else {
        // 添加新消息
        messages.add(messageJson);
      }

      // 按时间排序
      messages.sort((a, b) {
        final timeA = DateTime.parse(a['timestamp'] as String);
        final timeB = DateTime.parse(b['timestamp'] as String);
        return timeA.compareTo(timeB);
      });

      // 写入文件
      await file.writeAsString(json.encode(messages));
      log('💾 消息已保存到文件: ${file.path}, 共 ${messages.length} 条消息');
    } catch (e) {
      log('❌ 保存消息到文件失败: $e');
    }
  }

  /// 批量保存消息
  Future<void> saveMessages(List<ChatMessage> messages, String roomId) async {
    if (messages.isEmpty) return;

    try {
      log('💾 正在批量保存 ${messages.length} 条消息到文件, roomId: $roomId');
      
      // 按日期分组
      final Map<String, List<ChatMessage>> groupedByDate = {};
      for (final message in messages) {
        final dateStr = _getDateString(message.timestamp);
        groupedByDate.putIfAbsent(dateStr, () => []);
        groupedByDate[dateStr]!.add(message);
      }

      log('💾 消息按日期分组: ${groupedByDate.keys.toList()}');

      // 分别保存到各自的日期文件
      for (final entry in groupedByDate.entries) {
        final date = DateTime.parse(entry.key);
        final dayMessages = entry.value;
        final file = await _getDayFile(roomId, date);
        
        log('💾 保存到文件: ${file.path}');

        List<Map<String, dynamic>> existingMessages = [];

        // 读取现有消息
        if (await file.exists()) {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            final List<dynamic> existing = json.decode(content);
            existingMessages = existing.cast<Map<String, dynamic>>();
          }
        }

        // 创建消息 ID 集合用于去重
        final existingIds = existingMessages.map((m) => m['id'] as String).toSet();

        // 添加新消息
        int addedCount = 0;
        for (final message in dayMessages) {
          if (!existingIds.contains(message.id)) {
            existingMessages.add(_messageToJson(message, roomId));
            existingIds.add(message.id);
            addedCount++;
          }
        }

        // 按时间排序
        existingMessages.sort((a, b) {
          final timeA = DateTime.parse(a['timestamp'] as String);
          final timeB = DateTime.parse(b['timestamp'] as String);
          return timeA.compareTo(timeB);
        });

        // 写入文件
        await file.writeAsString(json.encode(existingMessages));
        log('💾 文件 ${entry.key}.json: 新增 $addedCount 条, 总计 ${existingMessages.length} 条');
      }

      log('💾 ${messages.length} 条消息已保存到文件');
    } catch (e, stack) {
      log('❌ 批量保存消息到文件失败: $e');
      log('❌ Stack: $stack');
    }
  }

  /// 获取特定聊天室的所有消息（分页）
  Future<List<ChatMessage>> getMessages({
    required String roomId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final roomDir = await _getRoomDir(roomId);
      if (!await roomDir.exists()) {
        return [];
      }

      // 获取所有日期文件并排序（最新的在前）
      final files = await roomDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      files.sort((a, b) => b.path.compareTo(a.path)); // 降序排列

      final List<ChatMessage> allMessages = [];

      // 读取所有文件中的消息
      for (final file in files) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> messages = json.decode(content);
          for (final msgJson in messages) {
            allMessages.add(_jsonToMessage(msgJson as Map<String, dynamic>));
          }
        }
      }

      // 按时间降序排列（最新的在前）
      allMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 分页
      final startIndex = (page - 1) * pageSize;
      if (startIndex >= allMessages.length) {
        return [];
      }

      final endIndex = (startIndex + pageSize).clamp(0, allMessages.length);
      return allMessages.sublist(startIndex, endIndex);
    } catch (e) {
      log('❌ 读取消息文件失败: $e');
      return [];
    }
  }

  /// 搜索消息
  Future<List<ChatMessage>> searchMessages({
    required String keyword,
    String? roomId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final List<ChatMessage> results = [];
      final lowerKeyword = keyword.toLowerCase();
      
      log('🔍 开始搜索，关键词: $keyword, roomId: $roomId');

      if (roomId != null) {
        // 在特定聊天室中搜索
        results.addAll(await _searchInRoom(roomId, lowerKeyword));
      } else {
        // 在所有聊天室中搜索
        final chatDir = await _getChatHistoryDir();
        log('🔍 搜索目录: ${chatDir.path}');
        if (await chatDir.exists()) {
          final roomDirs = await chatDir.list().where((e) => e is Directory).cast<Directory>().toList();
          log('🔍 找到 ${roomDirs.length} 个聊天室目录');
          for (final roomDir in roomDirs) {
            final roomIdFromPath = roomDir.path.split('/').last;
            results.addAll(await _searchInRoom(roomIdFromPath, lowerKeyword));
          }
        }
      }

      log('🔍 搜索完成，找到 ${results.length} 条结果');

      // 按时间降序排列
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 分页
      final startIndex = (page - 1) * pageSize;
      if (startIndex >= results.length) {
        return [];
      }

      final endIndex = (startIndex + pageSize).clamp(0, results.length);
      return results.sublist(startIndex, endIndex);
    } catch (e) {
      log('❌ 搜索消息失败: $e');
      return [];
    }
  }

  /// 在特定聊天室中搜索
  Future<List<ChatMessage>> _searchInRoom(String roomId, String lowerKeyword) async {
    final List<ChatMessage> results = [];

    try {
      final chatDir = await _getChatHistoryDir();
      // 将 roomId 中的特殊字符替换为下划线，保持与保存时一致
      final safeRoomId = roomId.replaceAll(RegExp(r'[^\w\-]'), '_');
      final roomDir = Directory('${chatDir.path}/$safeRoomId');
      
      log('🔍 搜索聊天室: $roomId -> $safeRoomId');
      log('🔍 目录路径: ${roomDir.path}');
      
      if (!await roomDir.exists()) {
        log('⚠️ 聊天室目录不存在: ${roomDir.path}');
        return results;
      }

      final files = await roomDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      log('🔍 找到 ${files.length} 个日期文件');

      for (final file in files) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> messages = json.decode(content);
          log('🔍 文件 ${file.path.split('/').last} 包含 ${messages.length} 条消息');
          for (final msgJson in messages) {
            final message = msgJson as Map<String, dynamic>;
            final messageText = (message['message'] as String? ?? '').toLowerCase();
            final senderName = (message['sender_name'] as String? ?? '').toLowerCase();

            // 搜索消息内容和发送者名称
            if (messageText.contains(lowerKeyword) || senderName.contains(lowerKeyword)) {
              results.add(_jsonToMessage(message));
            }
          }
        }
      }
      
      log('🔍 在聊天室 $roomId 中找到 ${results.length} 条匹配结果');
    } catch (e) {
      log('⚠️ 搜索聊天室 $roomId 失败: $e');
    }

    return results;
  }

  /// 获取搜索结果数量
  Future<int> searchMessagesCount({
    required String keyword,
    String? roomId,
  }) async {
    final results = await searchMessages(
      keyword: keyword,
      roomId: roomId,
      page: 1,
      pageSize: 10000, // 获取所有结果来计数
    );
    return results.length;
  }

  /// 清理过期消息（默认保留30天）
  Future<void> cleanupOldMessages({int daysToKeep = 30}) async {
    try {
      final chatDir = await _getChatHistoryDir();
      if (!await chatDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffDateStr = _getDateString(cutoffDate);
      int deletedCount = 0;

      final roomDirs = await chatDir.list().where((e) => e is Directory).cast<Directory>().toList();

      for (final roomDir in roomDirs) {
        final files = await roomDir.list().where((e) => e is File && e.path.endsWith('.json')).cast<File>().toList();

        for (final file in files) {
          final fileName = file.path.split('/').last.replaceAll('.json', '');
          if (fileName.compareTo(cutoffDateStr) < 0) {
            await file.delete();
            deletedCount++;
          }
        }

        // 如果目录为空，删除目录
        final remaining = await roomDir.list().length;
        if (remaining == 0) {
          await roomDir.delete();
        }
      }

      if (deletedCount > 0) {
        log('🗑️ 已清理 $deletedCount 个过期的聊天记录文件');
      }
    } catch (e) {
      log('❌ 清理过期消息失败: $e');
    }
  }

  /// 清除所有本地聊天记录
  Future<void> clearAllData() async {
    try {
      final chatDir = await _getChatHistoryDir();
      if (await chatDir.exists()) {
        await chatDir.delete(recursive: true);
        log('🗑️ 所有聊天记录文件已清除');
      }
    } catch (e) {
      log('❌ 清除聊天记录失败: $e');
    }
  }

  /// 获取存储统计信息（带详细日志）
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final chatDir = await _getChatHistoryDir();
      log('📊 聊天存储目录: ${chatDir.path}');
      
      if (!await chatDir.exists()) {
        log('📊 聊天存储目录不存在');
        return {'totalFiles': 0, 'totalSize': 0, 'roomCount': 0, 'rooms': []};
      }

      int totalFiles = 0;
      int totalSize = 0;
      int totalMessages = 0;
      int roomCount = 0;
      final List<Map<String, dynamic>> rooms = [];

      final roomDirs = await chatDir.list().where((e) => e is Directory).cast<Directory>().toList();
      roomCount = roomDirs.length;
      log('📊 找到 $roomCount 个聊天室');

      for (final roomDir in roomDirs) {
        final roomName = roomDir.path.split('/').last;
        final files = await roomDir.list().where((e) => e is File && e.path.endsWith('.json')).cast<File>().toList();
        totalFiles += files.length;
        
        int roomMessages = 0;
        int roomSize = 0;
        
        for (final file in files) {
          final fileSize = await file.length();
          roomSize += fileSize;
          totalSize += fileSize;
          
          // 统计消息数量
          try {
            final content = await file.readAsString();
            if (content.isNotEmpty) {
              final List<dynamic> messages = json.decode(content);
              roomMessages += messages.length;
              totalMessages += messages.length;
            }
          } catch (_) {}
        }
        
        rooms.add({
          'roomId': roomName,
          'files': files.length,
          'messages': roomMessages,
          'size': _formatFileSize(roomSize),
        });
        
        log('📊 聊天室 $roomName: ${files.length} 个文件, $roomMessages 条消息');
      }

      log('📊 总计: $roomCount 个聊天室, $totalFiles 个文件, $totalMessages 条消息, ${_formatFileSize(totalSize)}');

      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'totalSizeFormatted': _formatFileSize(totalSize),
        'roomCount': roomCount,
        'totalMessages': totalMessages,
        'rooms': rooms,
      };
    } catch (e) {
      log('❌ 获取存储统计失败: $e');
      return {'totalFiles': 0, 'totalSize': 0, 'roomCount': 0, 'rooms': []};
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  /// 将 ChatMessage 转换为 JSON
  Map<String, dynamic> _messageToJson(ChatMessage message, String roomId) {
    return {
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
      'mentions': message.mentions,
      'attachment': message.attachment != null
          ? {
              'url': message.attachment!.url,
              'fileName': message.attachment!.fileName,
              'fileSize': message.attachment!.fileSize,
              'mimeType': message.attachment!.mimeType,
              'latitude': message.attachment!.latitude,
              'longitude': message.attachment!.longitude,
              'locationName': message.attachment!.locationName,
              'duration': message.attachment!.duration,
              'width': message.attachment!.width,
              'height': message.attachment!.height,
            }
          : null,
      'timestamp': message.timestamp.toIso8601String(),
    };
  }

  /// 将 JSON 转换为 ChatMessage
  ChatMessage _jsonToMessage(Map<String, dynamic> json) {
    MessageReply? replyTo;
    if (json['reply_to_id'] != null) {
      replyTo = MessageReply(
        messageId: json['reply_to_id'] as String,
        message: json['reply_to_message'] as String? ?? '',
        userName: json['reply_to_user_name'] as String? ?? '',
      );
    }

    MessageAttachment? attachment;
    if (json['attachment'] != null) {
      final att = json['attachment'] as Map<String, dynamic>;
      attachment = MessageAttachment(
        url: att['url'] as String? ?? '',
        fileName: att['fileName'] as String?,
        fileSize: att['fileSize'] as int?,
        mimeType: att['mimeType'] as String?,
        latitude: (att['latitude'] as num?)?.toDouble(),
        longitude: (att['longitude'] as num?)?.toDouble(),
        locationName: att['locationName'] as String?,
        duration: att['duration'] as int?,
        width: att['width'] as int?,
        height: att['height'] as int?,
      );
    }

    return ChatMessage(
      id: json['id'] as String,
      author: MessageAuthor(
        userId: json['sender_id'] as String,
        userName: json['sender_name'] as String,
        userAvatar: json['sender_avatar'] as String?,
      ),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      replyTo: replyTo,
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['message_type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      attachment: attachment,
    );
  }
}
