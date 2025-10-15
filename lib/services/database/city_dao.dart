import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// 城市数据访问对象
class CityDao {
  final DatabaseService _dbService = DatabaseService();

  /// 插入城市
  Future<int> insertCity(Map<String, dynamic> city) async {
    final db = await _dbService.database;
    city['created_at'] = DateTime.now().toIso8601String();
    city['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('cities', city,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 根据ID查询城市
  Future<Map<String, dynamic>?> getCityById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cities',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 根据名称查询城市
  Future<Map<String, dynamic>?> getCityByName(String name) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cities',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 获取所有城市
  Future<List<Map<String, dynamic>>> getAllCities() async {
    final db = await _dbService.database;
    return await db.query('cities', orderBy: 'name ASC');
  }

  /// 更新城市信息
  Future<int> updateCity(int id, Map<String, dynamic> city) async {
    final db = await _dbService.database;
    city['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'cities',
      city,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除城市
  Future<int> deleteCity(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'cities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据国家查询城市
  Future<List<Map<String, dynamic>>> getCitiesByCountry(String country) async {
    final db = await _dbService.database;
    return await db.query(
      'cities',
      where: 'country = ?',
      whereArgs: [country],
      orderBy: 'name ASC',
    );
  }

  /// 搜索城市
  Future<List<Map<String, dynamic>>> searchCities(String keyword) async {
    final db = await _dbService.database;
    return await db.query(
      'cities',
      where: 'name LIKE ? OR country LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'name ASC',
    );
  }
}
