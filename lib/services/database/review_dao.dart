import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// 评论数据访问对象
class ReviewDao {
  final DatabaseService _dbService = DatabaseService();

  /// 插入评论
  Future<int> insertReview(Map<String, dynamic> review) async {
    final db = await _dbService.database;
    review['created_at'] = DateTime.now().toIso8601String();
    review['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('reviews', review,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 根据ID查询评论
  Future<Map<String, dynamic>?> getReviewById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 根据目标查询评论
  Future<List<Map<String, dynamic>>> getReviewsByTarget(
      String targetType, int targetId) async {
    final db = await _dbService.database;
    return await db.query(
      'reviews',
      where: 'target_type = ? AND target_id = ?',
      whereArgs: [targetType, targetId],
      orderBy: 'created_at DESC',
    );
  }

  /// 根据用户ID查询评论
  Future<List<Map<String, dynamic>>> getReviewsByUser(int userId) async {
    final db = await _dbService.database;
    return await db.query(
      'reviews',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// 更新评论
  Future<int> updateReview(int id, Map<String, dynamic> review) async {
    final db = await _dbService.database;
    review['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'reviews',
      review,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除评论
  Future<int> deleteReview(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 计算目标的平均评分
  Future<double> getAverageRating(String targetType, int targetId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT AVG(rating) as avg_rating
      FROM reviews
      WHERE target_type = ? AND target_id = ?
    ''', [targetType, targetId]);

    if (result.isNotEmpty && result.first['avg_rating'] != null) {
      return (result.first['avg_rating'] as num).toDouble();
    }
    return 0.0;
  }

  /// 获取目标的评论数量
  Future<int> getReviewCount(String targetType, int targetId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM reviews
      WHERE target_type = ? AND target_id = ?
    ''', [targetType, targetId]);

    if (result.isNotEmpty) {
      return Sqflite.firstIntValue(result) ?? 0;
    }
    return 0;
  }
}
