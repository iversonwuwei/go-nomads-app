import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// 共享办公空间数据访问对象
class CoworkingDao {
  final DatabaseService _dbService = DatabaseService();

  /// 插入共享办公空间
  Future<int> insertCoworking(Map<String, dynamic> coworking) async {
    final db = await _dbService.database;
    coworking['created_at'] = DateTime.now().toIso8601String();
    coworking['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('coworking_spaces', coworking,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 根据ID查询共享办公空间
  Future<Map<String, dynamic>?> getCoworkingById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coworking_spaces',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 获取所有共享办公空间
  Future<List<Map<String, dynamic>>> getAllCoworkings() async {
    final db = await _dbService.database;
    return await db.query('coworking_spaces', orderBy: 'rating DESC');
  }

  /// 根据城市ID查询共享办公空间
  Future<List<Map<String, dynamic>>> getCoworkingsByCity(int cityId) async {
    final db = await _dbService.database;
    return await db.query(
      'coworking_spaces',
      where: 'city_id = ?',
      whereArgs: [cityId],
      orderBy: 'rating DESC',
    );
  }

  /// 更新共享办公空间信息
  Future<int> updateCoworking(int id, Map<String, dynamic> coworking) async {
    final db = await _dbService.database;
    coworking['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'coworking_spaces',
      coworking,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除共享办公空间
  Future<int> deleteCoworking(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'coworking_spaces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 搜索共享办公空间
  Future<List<Map<String, dynamic>>> searchCoworkings(String keyword) async {
    final db = await _dbService.database;
    return await db.query(
      'coworking_spaces',
      where: 'name LIKE ? OR address LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'rating DESC',
    );
  }
}
