import 'dart:developer';

import 'package:go_nomads_app/features/auth/domain/entities/auth_user.dart';
import 'package:go_nomads_app/services/database_service.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:sqflite/sqflite.dart';

/// 用户本地数据仓储
/// 协调 SharedPreferences 和 SQLite 的数据存储
/// 
/// 架构设计：
/// - SharedPreferences: 存储 token 和快速访问的轻量级数据（userId, role）
/// - SQLite: 存储完整的用户资料（支持复杂查询和离线缓存）
class UserLocalRepository {
  final DatabaseService _db;
  final TokenStorageService _tokenStorage;

  UserLocalRepository({
    required DatabaseService db,
    required TokenStorageService tokenStorage,
  })  : _db = db,
        _tokenStorage = tokenStorage;

  /// 保存用户完整信息（登录/注册时调用）
  /// 
  /// 流程：
  /// 1. 保存 token 到 SharedPreferences（快速访问）
  /// 2. 保存用户详细信息到 SQLite（持久化）
  Future<void> saveUser(AuthUser user) async {
    try {
      // 1. 保存轻量级信息到 SharedPreferences（用于快速访问和权限控制）
      await _tokenStorage.saveUserInfo(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userRole: user.role,
      );

      // 2. 保存完整用户信息到 SQLite（用于离线缓存和复杂查询）
      final database = await _db.database;
      await database.insert(
        'users',
        {
          'id': user.id,
          'phone': user.phone, // 允许为 null
          'nickname': user.name,
          'email': user.email,
          'avatar': user.avatar, // 允许为 null
          'bio': '', // 可以扩展
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      log('✅ 用户信息已保存 (SharedPreferences + SQLite): ${user.id}');
    } catch (e) {
      log('❌ 保存用户信息失败: $e');
      rethrow;
    }
  }

  /// 从 SharedPreferences 获取用户 ID（快速访问）
  Future<String?> getCurrentUserId() async {
    return await _tokenStorage.getUserId();
  }

  /// 从 SharedPreferences 获取用户角色（权限控制）
  Future<String?> getCurrentUserRole() async {
    return await _tokenStorage.getUserRole();
  }

  /// 检查是否为管理员（快速检查，无需查询数据库）
  Future<bool> isAdmin() async {
    return await _tokenStorage.isAdmin();
  }

  /// 从 SQLite 获取完整的用户信息（详细资料）
  Future<AuthUser?> getCurrentUser() async {
    try {
      final userId = await _tokenStorage.getUserId();
      if (userId == null) return null;

      final database = await _db.database;
      final List<Map<String, dynamic>> results = await database.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) {
        log('⚠️ SQLite 中未找到用户: $userId');
        
        // 尝试从 SharedPreferences 恢复基本信息
        final name = await _tokenStorage.getUserName();
        final email = await _tokenStorage.getUserEmail();
        final role = await _tokenStorage.getUserRole();
        
        if (name != null && email != null) {
          return AuthUser(
            id: userId,
            name: name,
            email: email,
            role: role ?? 'user',
          );
        }
        
        return null;
      }

      final row = results.first;
      return AuthUser(
        id: row['id'] as String,
        name: row['nickname'] as String? ?? row['email'] as String,
        email: row['email'] as String,
        phone: row['phone'] as String?,
        avatar: row['avatar'] as String?,
        role: await _tokenStorage.getUserRole() ?? 'user', // role 从 SharedPreferences 读取
      );
    } catch (e) {
      log('❌ 获取当前用户失败: $e');
      return null;
    }
  }

  /// 更新用户资料（保存到 SQLite）
  Future<void> updateUserProfile(AuthUser user) async {
    try {
      final database = await _db.database;
      await database.update(
        'users',
        {
          'nickname': user.name,
          'email': user.email,
          'phone': user.phone, // 允许为 null
          'avatar': user.avatar, // 允许为 null
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );

      // 同步更新 SharedPreferences 中的基本信息
      await _tokenStorage.saveUserInfo(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userRole: user.role,
      );

      log('✅ 用户资料已更新: ${user.id}');
    } catch (e) {
      log('❌ 更新用户资料失败: $e');
      rethrow;
    }
  }

  /// 清除用户数据（登出时调用）
  Future<void> clearUserData() async {
    try {
      // 1. 先获取当前用户ID（在清除 token 之前）
      final userId = await _tokenStorage.getUserId();

      // 2. 清除 SQLite 中的当前用户数据
      if (userId != null) {
        final database = await _db.database;
        await database.delete('users', where: 'id = ?', whereArgs: [userId]);
        log('✅ SQLite 用户数据已清除: $userId');
      }

      // 3. 清除 SharedPreferences（token + 用户信息）
      await _tokenStorage.clearTokens();

      log('✅ 用户数据已完全清除');
    } catch (e) {
      log('❌ 清除用户数据失败: $e');
      // 确保即使出错也尝试清除 token
      try {
        await _tokenStorage.clearTokens();
      } catch (_) {}
    }
  }

  /// 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    final userId = await _tokenStorage.getUserId();
    return userId != null;
  }

  /// 批量保存用户（用于缓存聊天室成员等）
  Future<void> saveUsers(List<AuthUser> users) async {
    try {
      final database = await _db.database;
      final batch = database.batch();

      for (final user in users) {
        batch.insert(
          'users',
          {
            'id': user.id,
            'phone': user.phone, // 允许为 null
            'nickname': user.name,
            'email': user.email,
            'avatar': user.avatar, // 允许为 null
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      log('✅ 批量保存 ${users.length} 个用户');
    } catch (e) {
      log('❌ 批量保存用户失败: $e');
    }
  }

  /// 根据 ID 获取用户（从 SQLite 缓存）
  Future<AuthUser?> getUserById(String userId) async {
    try {
      final database = await _db.database;
      final List<Map<String, dynamic>> results = await database.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return AuthUser(
        id: row['id'] as String,
        name: row['nickname'] as String? ?? row['email'] as String,
        email: row['email'] as String,
        phone: row['phone'] as String?,
        avatar: row['avatar'] as String?,
        role: 'user', // 其他用户默认为 user
      );
    } catch (e) {
      log('❌ 获取用户失败: $e');
      return null;
    }
  }

  /// 搜索用户（从 SQLite）
  Future<List<AuthUser>> searchUsers(String query) async {
    try {
      final database = await _db.database;
      final List<Map<String, dynamic>> results = await database.query(
        'users',
        where: 'nickname LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        limit: 20,
      );

      return results.map((row) => AuthUser(
        id: row['id'] as String,
        name: row['nickname'] as String? ?? row['email'] as String,
        email: row['email'] as String,
        phone: row['phone'] as String?,
        avatar: row['avatar'] as String?,
        role: 'user',
      )).toList();
    } catch (e) {
      log('❌ 搜索用户失败: $e');
      return [];
    }
  }
}
