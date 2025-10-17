import '../database_service.dart';
import 'user_profile_dao.dart';

/// 用户账户和Profile数据访问对象
class AccountDao {
  final DatabaseService _dbService = DatabaseService();
  final UserProfileDao _profileDao = UserProfileDao();

  /// 创建账户表（如果不存在）
  Future<void> createAccountTables() async {
    final db = await _dbService.database;

    // 创建账户表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建用户profile表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL UNIQUE,
        name TEXT NOT NULL,
        bio TEXT,
        avatar_url TEXT,
        current_city TEXT,
        current_country TEXT,
        skills TEXT,
        interests TEXT,
        social_links TEXT,
        badges TEXT,
        countries_visited INTEGER DEFAULT 0,
        cities_lived INTEGER DEFAULT 0,
        days_nomading INTEGER DEFAULT 0,
        meetups_attended INTEGER DEFAULT 0,
        trips_completed INTEGER DEFAULT 0,
        travel_history TEXT,
        joined_date TEXT NOT NULL,
        is_verified INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE
      )
    ''');

    print('✅ 账户和Profile表创建完成');
  }

  /// 插入测试账户
  Future<int> insertAccount(Map<String, dynamic> account) async {
    final db = await _dbService.database;
    return await db.insert('user_accounts', account);
  }

  /// 插入用户Profile
  Future<int> insertProfile(Map<String, dynamic> profile) async {
    final db = await _dbService.database;
    return await db.insert('user_profiles', profile);
  }

  /// 根据email查询账户
  Future<Map<String, dynamic>?> getAccountByEmail(String email) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_accounts',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 根据用户名查询账户
  Future<Map<String, dynamic>?> getAccountByUsername(String username) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_accounts',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 获取账户的完整Profile
  Future<Map<String, dynamic>?> getAccountWithProfile(int accountId) async {
    final db = await _dbService.database;
    final results = await db.rawQuery('''
      SELECT 
        a.*,
        p.name,
        p.bio,
        p.avatar_url,
        p.current_city,
        p.current_country,
        p.skills,
        p.interests,
        p.social_links,
        p.badges,
        p.countries_visited,
        p.cities_lived,
        p.days_nomading,
        p.meetups_attended,
        p.trips_completed,
        p.travel_history,
        p.joined_date,
        p.is_verified
      FROM user_accounts a
      LEFT JOIN user_profiles p ON a.id = p.account_id
      WHERE a.id = ?
    ''', [accountId]);

    return results.isNotEmpty ? results.first : null;
  }

  /// 验证登录
  Future<Map<String, dynamic>?> validateLogin(
      String emailOrUsername, String password) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_accounts',
      where: '(email = ? OR username = ?) AND password = ?',
      whereArgs: [emailOrUsername, emailOrUsername, password],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final accountId = results.first['id'] as int;
      return await getAccountWithProfile(accountId);
    }
    return null;
  }

  /// 获取所有账户
  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    final db = await _dbService.database;
    return await db.query('user_accounts');
  }

  /// 获取所有账户及其Profile
  Future<List<Map<String, dynamic>>> getAllAccountsWithProfiles() async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT 
        a.*,
        p.name,
        p.bio,
        p.avatar_url,
        p.current_city,
        p.current_country,
        p.skills,
        p.interests,
        p.social_links,
        p.badges,
        p.countries_visited,
        p.cities_lived,
        p.days_nomading,
        p.meetups_attended,
        p.trips_completed,
        p.travel_history,
        p.joined_date,
        p.is_verified
      FROM user_accounts a
      LEFT JOIN user_profiles p ON a.id = p.account_id
      ORDER BY a.created_at DESC
    ''');
  }

  /// 注册新用户
  /// 返回：成功返回账户ID，失败返回null
  Future<int?> registerAccount({
    required String email,
    required String username,
    required String password,
    String? name,
  }) async {
    try {
      final db = await _dbService.database;
      final now = DateTime.now().millisecondsSinceEpoch.toString();

      // 检查邮箱是否已存在
      final existingEmail = await getAccountByEmail(email);
      if (existingEmail != null) {
        print('❌ 邮箱已被注册: $email');
        return null;
      }

      // 检查用户名是否已存在
      final existingUsername = await getAccountByUsername(username);
      if (existingUsername != null) {
        print('❌ 用户名已被使用: $username');
        return null;
      }

      // 插入账户
      final accountId = await db.insert('user_accounts', {
        'email': email,
        'username': username,
        'password': password, // 注意：实际项目中应该加密密码
        'created_at': now,
        'updated_at': now,
      });

      print('✅ 创建账户成功: $username (ID: $accountId)');

      // 初始化用户资料模块（新模块化系统）
      await _profileDao.initializeUserProfile(accountId, name ?? username);

      print('✅ 用户资料模块初始化完成: ${name ?? username}');

      return accountId;
    } catch (e) {
      print('❌ 注册失败: $e');
      return null;
    }
  }

  /// 根据邮箱删除账户（会级联删除Profile）
  Future<bool> deleteAccountByEmail(String email) async {
    try {
      final db = await _dbService.database;

      // 先查询账户是否存在
      final account = await getAccountByEmail(email);
      if (account == null) {
        print('❌ 账户不存在: $email');
        return false;
      }

      final accountId = account['id'] as int;
      final username = account['username'] as String;

      // 删除账户（会自动级联删除Profile，因为设置了ON DELETE CASCADE）
      final count = await db.delete(
        'user_accounts',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (count > 0) {
        print('✅ 成功删除账户: $username ($email) - ID: $accountId');
        return true;
      } else {
        print('❌ 删除账户失败: $email');
        return false;
      }
    } catch (e) {
      print('❌ 删除账户时发生错误: $e');
      return false;
    }
  }
}
