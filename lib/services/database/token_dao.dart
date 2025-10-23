import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// Token 数据访问对象
/// 负责管理认证 Token 的持久化存储
class TokenDao {
  final DatabaseService _dbService = DatabaseService();

  /// 表名
  static const String tableName = 'tokens';

  /// 创建 Token 表
  static String get createTableSQL => '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      access_token TEXT NOT NULL,
      refresh_token TEXT NOT NULL,
      token_type TEXT NOT NULL,
      expires_in INTEGER NOT NULL,
      user_name TEXT,
      user_email TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  /// 保存 Token
  /// 
  /// 如果已存在该用户的 Token，则更新；否则插入新记录
  Future<int> saveToken({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    String? userName,
    String? userEmail,
  }) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    // 先检查是否存在
    final existing = await getTokenByUserId(userId);
    
    final data = {
      'user_id': userId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user_name': userName,
      'user_email': userEmail,
      'created_at': existing?['created_at'] ?? now,
      'updated_at': now,
    };

    if (existing != null) {
      // 更新现有记录
      await db.update(
        tableName,
        data,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return existing['id'] as int;
    } else {
      // 插入新记录
      return await db.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// 根据用户 ID 获取 Token
  Future<Map<String, dynamic>?> getTokenByUserId(String userId) async {
    final db = await _dbService.database;
    final results = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// 获取最近的 Token（最后更新的）
  Future<Map<String, dynamic>?> getLatestToken() async {
    final db = await _dbService.database;
    final results = await db.query(
      tableName,
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// 检查 Token 是否过期
  /// 
  /// 返回 true 表示已过期或即将过期（提前 5 分钟）
  Future<bool> isTokenExpired(String userId) async {
    final token = await getTokenByUserId(userId);
    if (token == null) return true;

    final updatedAt = DateTime.parse(token['updated_at'] as String);
    final expiresIn = token['expires_in'] as int;
    
    // Token 过期时间
    final expiresAt = updatedAt.add(Duration(seconds: expiresIn));
    
    // 提前 5 分钟判断为过期
    final now = DateTime.now();
    final bufferTime = now.add(const Duration(minutes: 5));
    
    return bufferTime.isAfter(expiresAt);
  }

  /// 删除指定用户的 Token
  Future<int> deleteTokenByUserId(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// 清空所有 Token（登出时使用）
  Future<int> deleteAllTokens() async {
    final db = await _dbService.database;
    return await db.delete(tableName);
  }

  /// 获取所有 Token（调试用）
  Future<List<Map<String, dynamic>>> getAllTokens() async {
    final db = await _dbService.database;
    return await db.query(tableName);
  }
}
