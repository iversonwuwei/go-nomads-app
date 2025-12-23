import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../../services/database_service.dart';
import '../../domain/entities/entities.dart';

/// 旅行历史数据访问对象
/// 负责管理位置点、停留点、候选旅行和常住地的本地存储
class TravelHistoryDao {
  final DatabaseService _dbService;

  TravelHistoryDao({DatabaseService? dbService}) : _dbService = dbService ?? DatabaseService();

  Future<Database> get _db => _dbService.database;

  // ==================== 初始化 ====================

  /// 确保旅行历史相关的表已创建
  Future<void> ensureTables() async {
    final db = await _db;

    // 位置点表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS location_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        altitude REAL,
        speed REAL,
        timestamp TEXT NOT NULL,
        is_processed INTEGER DEFAULT 0
      )
    ''');

    // 停留点表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stay_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        arrival_time TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        point_count INTEGER NOT NULL,
        radius REAL DEFAULT 300,
        is_processed INTEGER DEFAULT 0
      )
    ''');

    // 候选旅行表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS candidate_trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backend_id TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        arrival_time TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        distance_from_home REAL NOT NULL DEFAULT 0,
        status INTEGER DEFAULT 0,
        city_name TEXT,
        country_name TEXT,
        country_code TEXT,
        city_id TEXT,
        created_at TEXT NOT NULL,
        confirmed_at TEXT,
        dismissed_at TEXT,
        is_synced_to_backend INTEGER DEFAULT 0
      )
    ''');

    // 常住地表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS home_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        city_name TEXT,
        country_name TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        confidence INTEGER DEFAULT 0
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX IF NOT EXISTS idx_location_points_timestamp ON location_points(timestamp DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_location_points_is_processed ON location_points(is_processed)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stay_points_arrival ON stay_points(arrival_time DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stay_points_is_processed ON stay_points(is_processed)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_candidate_trips_status ON candidate_trips(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_candidate_trips_created ON candidate_trips(created_at DESC)');

    // 旅行历史设置表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS travel_history_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    log('✅ 旅行历史表初始化完成');

    // 执行必要的迁移
    await _migrateDatabase(db);
  }

  /// 数据库迁移，添加新字段
  Future<void> _migrateDatabase(Database db) async {
    try {
      // 检查 candidate_trips 表是否有 backend_id 字段
      final tableInfo = await db.rawQuery("PRAGMA table_info(candidate_trips)");
      final columnNames = tableInfo.map((col) => col['name'] as String).toSet();

      // 添加 backend_id 字段
      if (!columnNames.contains('backend_id')) {
        await db.execute('ALTER TABLE candidate_trips ADD COLUMN backend_id TEXT');
        log('✅ 添加 backend_id 字段成功');
      }

      // 添加 is_synced_to_backend 字段
      if (!columnNames.contains('is_synced_to_backend')) {
        await db.execute('ALTER TABLE candidate_trips ADD COLUMN is_synced_to_backend INTEGER DEFAULT 0');
        log('✅ 添加 is_synced_to_backend 字段成功');
      }

      // 添加 city_id 字段，用于关联城市详情
      if (!columnNames.contains('city_id')) {
        await db.execute('ALTER TABLE candidate_trips ADD COLUMN city_id TEXT');
        log('✅ 添加 city_id 字段成功');
      }
    } catch (e) {
      log('⚠️ 数据库迁移警告: $e');
    }
  }

  // ==================== 位置点操作 ====================

  /// 保存位置点
  Future<int> saveLocationPoint(LocationPoint point) async {
    final db = await _db;
    return await db.insert('location_points', point.toMap());
  }

  /// 批量保存位置点
  Future<void> saveLocationPoints(List<LocationPoint> points) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final point in points) {
        await txn.insert('location_points', point.toMap());
      }
    });
  }

  /// 获取未处理的位置点
  Future<List<LocationPoint>> getUnprocessedLocationPoints() async {
    final db = await _db;
    final maps = await db.query(
      'location_points',
      where: 'is_processed = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => LocationPoint.fromMap(map)).toList();
  }

  /// 获取指定时间范围内的位置点
  Future<List<LocationPoint>> getLocationPointsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final maps = await db.query(
      'location_points',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => LocationPoint.fromMap(map)).toList();
  }

  /// 标记位置点为已处理
  Future<void> markLocationPointsAsProcessed(List<int> ids) async {
    final db = await _db;
    await db.update(
      'location_points',
      {'is_processed': 1},
      where: 'id IN (${ids.join(",")})',
    );
  }

  /// 删除旧的位置点（保留最近N天）
  Future<int> deleteOldLocationPoints({int keepDays = 30}) async {
    final db = await _db;
    final cutoff = DateTime.now().subtract(Duration(days: keepDays)).toIso8601String();
    return await db.delete(
      'location_points',
      where: 'timestamp < ? AND is_processed = ?',
      whereArgs: [cutoff, 1],
    );
  }

  // ==================== 停留点操作 ====================

  /// 保存停留点
  Future<int> saveStayPoint(StayPoint stayPoint) async {
    final db = await _db;
    return await db.insert('stay_points', stayPoint.toMap());
  }

  /// 批量保存停留点
  Future<void> saveStayPoints(List<StayPoint> stayPoints) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final stayPoint in stayPoints) {
        await txn.insert('stay_points', stayPoint.toMap());
      }
    });
  }

  /// 获取未处理的停留点
  Future<List<StayPoint>> getUnprocessedStayPoints() async {
    final db = await _db;
    final maps = await db.query(
      'stay_points',
      where: 'is_processed = ?',
      whereArgs: [0],
      orderBy: 'arrival_time ASC',
    );
    return maps.map((map) => StayPoint.fromMap(map)).toList();
  }

  /// 获取所有停留点
  Future<List<StayPoint>> getAllStayPoints() async {
    final db = await _db;
    final maps = await db.query(
      'stay_points',
      orderBy: 'arrival_time DESC',
    );
    return maps.map((map) => StayPoint.fromMap(map)).toList();
  }

  /// 标记停留点为已处理
  Future<void> markStayPointsAsProcessed(List<int> ids) async {
    final db = await _db;
    await db.update(
      'stay_points',
      {'is_processed': 1},
      where: 'id IN (${ids.join(",")})',
    );
  }

  // ==================== 候选旅行操作 ====================

  /// 保存候选旅行
  Future<int> saveCandidateTrip(CandidateTrip trip) async {
    final db = await _db;
    return await db.insert('candidate_trips', trip.toMap());
  }

  /// 更新候选旅行
  Future<int> updateCandidateTrip(CandidateTrip trip) async {
    final db = await _db;
    return await db.update(
      'candidate_trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  /// 获取待确认的候选旅行
  Future<List<CandidateTrip>> getPendingCandidateTrips() async {
    final db = await _db;
    final maps = await db.query(
      'candidate_trips',
      where: 'status = ?',
      whereArgs: [CandidateTripStatus.pending.index],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => CandidateTrip.fromMap(map)).toList();
  }

  /// 获取已确认的旅行
  Future<List<CandidateTrip>> getConfirmedTrips() async {
    final db = await _db;
    final maps = await db.query(
      'candidate_trips',
      where: 'status = ?',
      whereArgs: [CandidateTripStatus.confirmed.index],
      orderBy: 'arrival_time DESC',
    );
    return maps.map((map) => CandidateTrip.fromMap(map)).toList();
  }

  /// 通过 ID 获取候选旅行
  Future<CandidateTrip?> getCandidateTripById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'candidate_trips',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CandidateTrip.fromMap(maps.first);
  }

  /// 确认旅行
  Future<void> confirmTrip(int id) async {
    final db = await _db;
    await db.update(
      'candidate_trips',
      {
        'status': CandidateTripStatus.confirmed.index,
        'confirmed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 忽略旅行
  Future<void> dismissTrip(int id) async {
    final db = await _db;
    await db.update(
      'candidate_trips',
      {
        'status': CandidateTripStatus.dismissed.index,
        'dismissed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 标记旅行为已同步到后端
  Future<void> markAsSynced(int id, {String? backendId}) async {
    final db = await _db;
    final updates = <String, dynamic>{
      'is_synced_to_backend': 1,
    };
    if (backendId != null) {
      updates['backend_id'] = backendId;
    }
    await db.update(
      'candidate_trips',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 插入候选旅行
  Future<int> insertCandidateTrip(CandidateTrip trip) async {
    final db = await _db;
    return await db.insert('candidate_trips', trip.toMap());
  }

  /// 检查是否存在相似的旅行（相同城市和国家，到达时间在24小时内）
  Future<bool> existsSimilarTrip(CandidateTrip trip) async {
    final db = await _db;
    final startTime = trip.arrivalTime.subtract(const Duration(hours: 24));
    final endTime = trip.arrivalTime.add(const Duration(hours: 24));

    final result = await db.query(
      'candidate_trips',
      where: 'city_name = ? AND country_name = ? AND arrival_time >= ? AND arrival_time <= ?',
      whereArgs: [
        trip.cityName,
        trip.countryName,
        startTime.toIso8601String(),
        endTime.toIso8601String(),
      ],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// 将过期的候选旅行标记为已过期
  Future<int> expireOldCandidateTrips({int expirationDays = 14}) async {
    final db = await _db;
    final cutoff = DateTime.now().subtract(Duration(days: expirationDays)).toIso8601String();
    return await db.update(
      'candidate_trips',
      {'status': CandidateTripStatus.expired.index},
      where: 'status = ? AND created_at < ?',
      whereArgs: [CandidateTripStatus.pending.index, cutoff],
    );
  }

  // ==================== 常住地操作 ====================

  /// 保存或更新常住地
  Future<int> saveHomeLocation(HomeLocation home) async {
    final db = await _db;

    // 检查是否已有常住地记录
    final existing = await db.query('home_locations', limit: 1);

    if (existing.isNotEmpty) {
      // 更新现有记录
      return await db.update(
        'home_locations',
        home.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // 插入新记录
      return await db.insert('home_locations', home.toMap());
    }
  }

  /// 获取常住地
  Future<HomeLocation?> getHomeLocation() async {
    final db = await _db;
    final maps = await db.query('home_locations', limit: 1);
    if (maps.isEmpty) return null;
    return HomeLocation.fromMap(maps.first);
  }

  /// 更新常住地置信度
  Future<void> updateHomeConfidence(int id, int confidence) async {
    final db = await _db;
    await db.update(
      'home_locations',
      {
        'confidence': confidence,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 统计方法 ====================

  /// 获取位置点数量
  Future<int> getLocationPointCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM location_points');
    return result.first['count'] as int;
  }

  /// 获取停留点数量
  Future<int> getStayPointCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM stay_points');
    return result.first['count'] as int;
  }

  /// 获取候选旅行数量（按状态）
  Future<Map<CandidateTripStatus, int>> getCandidateTripCounts() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM candidate_trips 
      GROUP BY status
    ''');

    final counts = <CandidateTripStatus, int>{};
    for (final row in result) {
      final status = CandidateTripStatus.values[row['status'] as int];
      counts[status] = row['count'] as int;
    }
    return counts;
  }

  // ==================== 清理方法 ====================

  /// 清除所有旅行历史数据
  Future<void> clearAllData() async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('location_points');
      await txn.delete('stay_points');
      await txn.delete('candidate_trips');
      await txn.delete('home_locations');
    });
    log('✅ 所有旅行历史数据已清除');
  }

  // ==================== 设置操作 ====================

  /// 保存设置
  Future<void> saveSetting(String key, String value) async {
    final db = await _db;
    await db.insert(
      'travel_history_settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取设置
  Future<String?> getSetting(String key) async {
    final db = await _db;
    final result = await db.query(
      'travel_history_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  /// 获取自动检测是否启用
  Future<bool> isAutoDetectionEnabled() async {
    final value = await getSetting('auto_detection_enabled');
    return value == 'true';
  }

  /// 设置自动检测是否启用
  Future<void> setAutoDetectionEnabled(bool enabled) async {
    await saveSetting('auto_detection_enabled', enabled.toString());
  }
}
