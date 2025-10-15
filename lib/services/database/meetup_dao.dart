import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// 活动聚会数据访问对象
class MeetupDao {
  final DatabaseService _dbService = DatabaseService();

  /// 插入活动
  Future<int> insertMeetup(Map<String, dynamic> meetup) async {
    final db = await _dbService.database;
    meetup['created_at'] = DateTime.now().toIso8601String();
    meetup['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('meetups', meetup,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 根据ID查询活动
  Future<Map<String, dynamic>?> getMeetupById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meetups',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 获取所有活动
  Future<List<Map<String, dynamic>>> getAllMeetups() async {
    final db = await _dbService.database;
    return await db.query('meetups', orderBy: 'start_time DESC');
  }

  /// 根据城市ID查询活动
  Future<List<Map<String, dynamic>>> getMeetupsByCity(int cityId) async {
    final db = await _dbService.database;
    return await db.query(
      'meetups',
      where: 'city_id = ?',
      whereArgs: [cityId],
      orderBy: 'start_time DESC',
    );
  }

  /// 根据状态查询活动
  Future<List<Map<String, dynamic>>> getMeetupsByStatus(String status) async {
    final db = await _dbService.database;
    return await db.query(
      'meetups',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'start_time ASC',
    );
  }

  /// 更新活动信息
  Future<int> updateMeetup(int id, Map<String, dynamic> meetup) async {
    final db = await _dbService.database;
    meetup['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'meetups',
      meetup,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除活动
  Future<int> deleteMeetup(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'meetups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 用户加入活动
  Future<int> joinMeetup(int meetupId, int userId) async {
    final db = await _dbService.database;
    return await db.insert(
      'meetup_participants',
      {
        'meetup_id': meetupId,
        'user_id': userId,
        'status': 'joined',
        'joined_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 用户退出活动
  Future<int> leaveMeetup(int meetupId, int userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'meetup_participants',
      where: 'meetup_id = ? AND user_id = ?',
      whereArgs: [meetupId, userId],
    );
  }

  /// 查询用户是否已加入活动
  Future<bool> hasUserJoined(int meetupId, int userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meetup_participants',
      where: 'meetup_id = ? AND user_id = ?',
      whereArgs: [meetupId, userId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// 获取用户已加入的活动
  Future<List<Map<String, dynamic>>> getUserJoinedMeetups(int userId) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT m.* FROM meetups m
      INNER JOIN meetup_participants mp ON m.id = mp.meetup_id
      WHERE mp.user_id = ? AND mp.status = 'joined'
      ORDER BY m.start_time DESC
    ''', [userId]);
  }

  /// 获取活动的参与者列表
  Future<List<Map<String, dynamic>>> getMeetupParticipants(int meetupId) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT u.* FROM users u
      INNER JOIN meetup_participants mp ON u.id = mp.user_id
      WHERE mp.meetup_id = ? AND mp.status = 'joined'
      ORDER BY mp.joined_at DESC
    ''', [meetupId]);
  }
}
