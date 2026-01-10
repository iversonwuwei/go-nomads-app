import 'dart:developer';

import 'package:df_admin_mobile/services/database_service.dart';

/// Token数据访问对象
///
/// 负责token相关的数据库操作
class TokenDao {
  final DatabaseService _dbService = DatabaseService();

  /// 保存token到数据库
  Future<void> saveToken({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    required String userName,
    required String userEmail,
  }) async {
    log('💾 [TokenDao] 开始保存 Token 到 SQLite...');
    log('   userId: $userId');
    log('   expiresIn: $expiresIn 秒');
    
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

    // 先删除该用户的旧token
    final deletedCount = await db.delete(
      'tokens',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    log('   删除旧 Token 数量: $deletedCount');

    // 插入新token
    final insertId = await db.insert('tokens', {
      'user_id': userId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
      'user_name': userName,
      'user_email': userEmail,
      'created_at': now,
      'updated_at': now,
    });
    log('✅ [TokenDao] Token 已保存到 SQLite, insertId: $insertId');
  }

  /// 获取最新的token
  Future<Map<String, dynamic>?> getLatestToken() async {
    log('🔍 [TokenDao] 从 SQLite 获取最新 Token...');
    final db = await _dbService.database;
    final results = await db.query(
      'tokens',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isEmpty) {
      log('⚠️ [TokenDao] SQLite 中没有找到任何 Token');
      return null;
    }

    log('✅ [TokenDao] 找到 Token: userId=${results.first['user_id']}, expiresAt=${results.first['expires_at']}');
    return results.first;
  }

  /// 根据用户ID获取token
  Future<Map<String, dynamic>?> getTokenByUserId(String userId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'tokens',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  /// 检查token是否过期
  Future<bool> isTokenExpired(String userId) async {
    final tokenData = await getTokenByUserId(userId);
    if (tokenData == null) {
      return true;
    }

    final expiresAt = tokenData['expires_at'] as String?;
    if (expiresAt == null) {
      return true;
    }

    final expiryTime = DateTime.parse(expiresAt);
    return DateTime.now().isAfter(expiryTime);
  }

  /// 删除所有token
  Future<void> deleteAllTokens() async {
    final db = await _dbService.database;
    await db.delete('tokens');
  }

  /// 根据用户ID删除token
  Future<void> deleteTokenByUserId(String userId) async {
    final db = await _dbService.database;
    await db.delete(
      'tokens',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// 更新指定用户的token（刷新token后使用）
  Future<void> updateToken({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

    await db.update(
      'tokens',
      {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'expires_at': expiresAt,
        'updated_at': now,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
