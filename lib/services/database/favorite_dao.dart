import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// 收藏数据访问对象
class FavoriteDao {
  final DatabaseService _dbService = DatabaseService();

  /// 添加收藏
  Future<int> addFavorite(int userId, String targetType, int targetId) async {
    final db = await _dbService.database;
    return await db.insert(
      'favorites',
      {
        'user_id': userId,
        'target_type': targetType,
        'target_id': targetId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 取消收藏
  Future<int> removeFavorite(
      int userId, String targetType, int targetId) async {
    final db = await _dbService.database;
    return await db.delete(
      'favorites',
      where: 'user_id = ? AND target_type = ? AND target_id = ?',
      whereArgs: [userId, targetType, targetId],
    );
  }

  /// 检查是否已收藏
  Future<bool> isFavorited(int userId, String targetType, int targetId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'user_id = ? AND target_type = ? AND target_id = ?',
      whereArgs: [userId, targetType, targetId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// 获取用户的所有收藏
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId,
      {String? targetType}) async {
    final db = await _dbService.database;
    if (targetType != null) {
      return await db.query(
        'favorites',
        where: 'user_id = ? AND target_type = ?',
        whereArgs: [userId, targetType],
        orderBy: 'created_at DESC',
      );
    } else {
      return await db.query(
        'favorites',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    }
  }

  /// 获取用户收藏的城市列表
  Future<List<Map<String, dynamic>>> getFavoriteCities(int userId) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT c.* FROM cities c
      INNER JOIN favorites f ON c.id = f.target_id
      WHERE f.user_id = ? AND f.target_type = 'city'
      ORDER BY f.created_at DESC
    ''', [userId]);
  }

  /// 获取用户收藏的活动列表
  Future<List<Map<String, dynamic>>> getFavoriteMeetups(int userId) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT m.* FROM meetups m
      INNER JOIN favorites f ON m.id = f.target_id
      WHERE f.user_id = ? AND f.target_type = 'meetup'
      ORDER BY f.created_at DESC
    ''', [userId]);
  }
}
