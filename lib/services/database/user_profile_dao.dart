import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database_service.dart';

/// 用户资料模块数据访问对象
class UserProfileDao {
  final DatabaseService _dbService = DatabaseService();

  /// 创建所有用户资料相关的表
  Future<void> createUserProfileTables() async {
    final db = await _dbService.database;

    // 1. 用户基本信息表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_basic_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL UNIQUE,
        name TEXT NOT NULL,
        bio TEXT,
        avatar_url TEXT,
        current_city TEXT,
        current_country TEXT,
        birth_date TEXT,
        gender TEXT,
        occupation TEXT,
        company TEXT,
        website TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE
      )
    ''');

    // 2. 游牧状态统计表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS nomad_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL UNIQUE,
        countries_visited INTEGER DEFAULT 0,
        cities_lived INTEGER DEFAULT 0,
        days_nomading INTEGER DEFAULT 0,
        meetups_attended INTEGER DEFAULT 0,
        trips_completed INTEGER DEFAULT 0,
        reviews_written INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE
      )
    ''');

    // 3. 用户技能表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_skills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        skill_name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE,
        UNIQUE(account_id, skill_name)
      )
    ''');

    // 4. 用户兴趣表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_interests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        interest_name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE,
        UNIQUE(account_id, interest_name)
      )
    ''');

    // 5. 社交链接表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_social_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        platform TEXT NOT NULL,
        url TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE,
        UNIQUE(account_id, platform)
      )
    ''');

    // 6. 旅行计划表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS travel_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        destination TEXT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        description TEXT,
        itinerary TEXT,
        budget TEXT,
        accommodation TEXT,
        transportation TEXT,
        status TEXT DEFAULT 'planning',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE
      )
    ''');

    // 7. 用户徽章表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        badge_id TEXT NOT NULL,
        badge_name TEXT NOT NULL,
        badge_icon TEXT,
        description TEXT,
        earned_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE,
        UNIQUE(account_id, badge_id)
      )
    ''');

    // 8. 旅行历史表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS travel_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        city TEXT NOT NULL,
        country TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        review TEXT,
        rating REAL,
        photos TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES user_accounts (id) ON DELETE CASCADE
      )
    ''');

    print('✅ 用户资料模块表创建完成');
  }

  // ==================== 基本信息模块 ====================

  /// 保存/更新用户基本信息
  Future<int> saveBasicInfo(UserBasicInfoDto info) async {
    final db = await _dbService.database;
    final existing = await getBasicInfo(info.accountId);

    if (existing != null) {
      // 更新
      await db.update(
        'user_basic_info',
        info.toMap()..remove('id'),
        where: 'account_id = ?',
        whereArgs: [info.accountId],
      );
      return existing.id!;
    } else {
      // 插入
      return await db.insert('user_basic_info', info.toMap());
    }
  }

  /// 获取用户基本信息
  Future<UserBasicInfoDto?> getBasicInfo(int accountId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_basic_info',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
    return results.isNotEmpty ? UserBasicInfoDto.fromMap(results.first) : null;
  }

  // ==================== 游牧状态统计模块 ====================

  /// 保存/更新游牧状态统计
  Future<int> saveNomadStats(NomadStatsDto stats) async {
    final db = await _dbService.database;
    final existing = await getNomadStats(stats.accountId);

    if (existing != null) {
      await db.update(
        'nomad_stats',
        stats.toMap()..remove('id'),
        where: 'account_id = ?',
        whereArgs: [stats.accountId],
      );
      return existing.id!;
    } else {
      return await db.insert('nomad_stats', stats.toMap());
    }
  }

  /// 获取游牧状态统计
  Future<NomadStatsDto?> getNomadStats(int accountId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'nomad_stats',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
    return results.isNotEmpty ? NomadStatsDto.fromMap(results.first) : null;
  }

  /// 增加计数器
  Future<void> incrementStat(int accountId, String statName) async {
    final stats = await getNomadStats(accountId);
    if (stats != null) {
      NomadStatsDto updated;

      switch (statName) {
        case 'countriesVisited':
          updated =
              stats.copyWith(countriesVisited: stats.countriesVisited + 1);
          break;
        case 'citiesLived':
          updated = stats.copyWith(citiesLived: stats.citiesLived + 1);
          break;
        case 'daysNomading':
          updated = stats.copyWith(daysNomading: stats.daysNomading + 1);
          break;
        case 'meetupsAttended':
          updated = stats.copyWith(meetupsAttended: stats.meetupsAttended + 1);
          break;
        case 'tripsCompleted':
          updated = stats.copyWith(tripsCompleted: stats.tripsCompleted + 1);
          break;
        case 'reviewsWritten':
          updated = stats.copyWith(reviewsWritten: stats.reviewsWritten + 1);
          break;
        default:
          return;
      }

      await saveNomadStats(updated);
    }
  }

  // ==================== 技能模块 ====================

  /// 添加技能
  Future<int> addSkill(UserSkillDto skill) async {
    final db = await _dbService.database;
    try {
      return await db.insert('user_skills', skill.toMap());
    } catch (e) {
      print('技能已存在或添加失败: $e');
      return -1;
    }
  }

  /// 删除技能
  Future<bool> removeSkill(int accountId, String skillName) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'user_skills',
      where: 'account_id = ? AND skill_name = ?',
      whereArgs: [accountId, skillName],
    );
    return count > 0;
  }

  /// 获取用户所有技能
  Future<List<UserSkillDto>> getSkills(int accountId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_skills',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => UserSkillDto.fromMap(map)).toList();
  }

  // ==================== 兴趣模块 ====================

  /// 添加兴趣
  Future<int> addInterest(UserInterestDto interest) async {
    final db = await _dbService.database;
    try {
      return await db.insert('user_interests', interest.toMap());
    } catch (e) {
      print('兴趣已存在或添加失败: $e');
      return -1;
    }
  }

  /// 删除兴趣
  Future<bool> removeInterest(int accountId, String interestName) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'user_interests',
      where: 'account_id = ? AND interest_name = ?',
      whereArgs: [accountId, interestName],
    );
    return count > 0;
  }

  /// 获取用户所有兴趣
  Future<List<UserInterestDto>> getInterests(int accountId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_interests',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => UserInterestDto.fromMap(map)).toList();
  }

  // ==================== 社交链接模块 ====================

  /// 保存/更新社交链接
  Future<int> saveSocialLink(SocialLinkDto link) async {
    final db = await _dbService.database;
    final existing = await getSocialLink(link.accountId, link.platform);

    if (existing != null) {
      await db.update(
        'user_social_links',
        link.toMap()..remove('id'),
        where: 'account_id = ? AND platform = ?',
        whereArgs: [link.accountId, link.platform],
      );
      return existing.id!;
    } else {
      return await db.insert('user_social_links', link.toMap());
    }
  }

  /// 获取单个社交链接
  Future<SocialLinkDto?> getSocialLink(int accountId, String platform) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_social_links',
      where: 'account_id = ? AND platform = ?',
      whereArgs: [accountId, platform],
    );
    return results.isNotEmpty ? SocialLinkDto.fromMap(results.first) : null;
  }

  /// 获取所有社交链接
  Future<List<SocialLinkDto>> getSocialLinks(int accountId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_social_links',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'created_at ASC',
    );
    return results.map((map) => SocialLinkDto.fromMap(map)).toList();
  }

  /// 删除社交链接
  Future<bool> removeSocialLink(int accountId, String platform) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'user_social_links',
      where: 'account_id = ? AND platform = ?',
      whereArgs: [accountId, platform],
    );
    return count > 0;
  }

  // ==================== 旅行计划模块 ====================

  /// 保存旅行计划
  Future<int> saveTravelPlan(UserTravelPlanDto plan) async {
    final db = await _dbService.database;
    if (plan.id != null) {
      await db.update(
        'travel_plans',
        plan.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [plan.id],
      );
      return plan.id!;
    } else {
      return await db.insert('travel_plans', plan.toMap());
    }
  }

  /// 获取单个旅行计划
  Future<UserTravelPlanDto?> getTravelPlan(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'travel_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? UserTravelPlanDto.fromMap(results.first) : null;
  }

  /// 获取用户所有旅行计划
  Future<List<UserTravelPlanDto>> getTravelPlans(int accountId,
      {String? status}) async {
    final db = await _dbService.database;
    final results = status != null
        ? await db.query(
            'travel_plans',
            where: 'account_id = ? AND status = ?',
            whereArgs: [accountId, status],
            orderBy: 'created_at DESC',
          )
        : await db.query(
            'travel_plans',
            where: 'account_id = ?',
            whereArgs: [accountId],
            orderBy: 'created_at DESC',
          );
    return results.map((map) => UserTravelPlanDto.fromMap(map)).toList();
  }

  /// 删除旅行计划
  Future<bool> deleteTravelPlan(int id) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'travel_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // ==================== 徽章模块 ====================

  /// 授予徽章
  Future<int> awardBadge(UserBadgeDto badge) async {
    final db = await _dbService.database;
    try {
      return await db.insert('user_badges', badge.toMap());
    } catch (e) {
      print('徽章已存在或添加失败: $e');
      return -1;
    }
  }

  /// 获取用户所有徽章
  Future<List<UserBadgeDto>> getBadges(int accountId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_badges',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'earned_date DESC',
    );
    return results.map((map) => UserBadgeDto.fromMap(map)).toList();
  }

  // ==================== 旅行历史模块 ====================

  /// 保存旅行历史
  Future<int> saveTravelHistory(TravelHistoryEntryDto history) async {
    final db = await _dbService.database;
    if (history.id != null) {
      await db.update(
        'travel_history',
        history.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [history.id],
      );
      return history.id!;
    } else {
      return await db.insert('travel_history', history.toMap());
    }
  }

  /// 获取旅行历史
  Future<List<TravelHistoryEntryDto>> getTravelHistory(int accountId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'travel_history',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'start_date DESC',
    );
    return results.map((map) => TravelHistoryEntryDto.fromMap(map)).toList();
  }

  /// 删除旅行历史
  Future<bool> deleteTravelHistory(int id) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'travel_history',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // ==================== 初始化用户资料 ====================

  /// 为新用户创建默认资料
  Future<void> initializeUserProfile(int accountId, String name) async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    // 创建基本信息
    await saveBasicInfo(UserBasicInfoDto(
      accountId: accountId,
      name: name,
      avatarUrl: '',
      createdAt: now,
      updatedAt: now,
    ));

    // 创建初始统计数据
    await saveNomadStats(NomadStatsDto(
      accountId: accountId,
      createdAt: now,
      updatedAt: now,
    ));

    print('✅ 用户资料初始化完成: $name (账户ID: $accountId)');
  }
}
