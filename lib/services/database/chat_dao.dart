import '../database_service.dart';

/// 聊天消息数据访问对象
class ChatDao {
  final DatabaseService _dbService = DatabaseService();

  /// 插入聊天消息
  Future<int> insertMessage(Map<String, dynamic> message) async {
    final db = await _dbService.database;
    message['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('chat_messages', message);
  }

  /// 根据房间ID查询消息
  Future<List<Map<String, dynamic>>> getMessagesByRoom(String roomId,
      {int limit = 50}) async {
    final db = await _dbService.database;
    return await db.query(
      'chat_messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  /// 删除房间所有消息
  Future<int> deleteRoomMessages(String roomId) async {
    final db = await _dbService.database;
    return await db.delete(
      'chat_messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  /// 获取用户的聊天室列表
  Future<List<Map<String, dynamic>>> getUserChatRooms(int userId) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT DISTINCT room_id, MAX(created_at) as last_message_time
      FROM chat_messages
      WHERE sender_id = ? OR room_id IN (
        SELECT DISTINCT room_id FROM chat_messages WHERE sender_id != ?
      )
      GROUP BY room_id
      ORDER BY last_message_time DESC
    ''', [userId, userId]);
  }
}
