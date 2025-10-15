import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// 用户数据访问对象
class UserDao {
  final DatabaseService _dbService = DatabaseService();

  /// 插入用户
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await _dbService.database;
    user['created_at'] = DateTime.now().toIso8601String();
    user['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 根据手机号查询用户
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 根据ID查询用户
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 更新用户信息
  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await _dbService.database;
    user['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除用户
  Future<int> deleteUser(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取所有用户
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await _dbService.database;
    return await db.query('users');
  }

  /// 用户登录验证
  Future<Map<String, dynamic>?> login(String phone, String password) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }
}
