import 'dart:developer';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../services/database_service.dart';
import '../../../../services/token_storage_service.dart';
import '../../domain/entities/entities.dart';

/// 旅行历史数据访问对象
/// 负责管理位置点、停留点、候选旅行和常住地的本地存储
class TravelHistoryDao {
  final DatabaseService _dbService;

  TravelHistoryDao({DatabaseService? dbService}) : _dbService = dbService ?? DatabaseService();

  Future<Database> get _db => _dbService.database;

  /// 获取当前用户 ID
  Future<String?> _getCurrentUserId() async {
    try {
      if (Get.isRegistered<TokenStorageService>()) {
        final tokenService = Get.find<TokenStorageService>();
        return await tokenService.getUserId();
      }
    } catch (e) {
      log('⚠️ 获取当前用户ID失败: $e');
    }
    return null;
  }

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
        user_id TEXT,
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

    // 访问地点表 - 记录用户在旅行中访问过的具体地点（停留40分钟以上）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS visited_places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id TEXT NOT NULL,
        backend_id TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        place_name TEXT,
        place_type TEXT,
        address TEXT,
        arrival_time TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        duration_minutes INTEGER DEFAULT 0,
        photo_url TEXT,
        notes TEXT,
        is_highlight INTEGER DEFAULT 0,
        google_place_id TEXT,
        client_id TEXT,
        is_synced_to_backend INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX IF NOT EXISTS idx_location_points_timestamp ON location_points(timestamp DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_location_points_is_processed ON location_points(is_processed)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stay_points_arrival ON stay_points(arrival_time DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stay_points_is_processed ON stay_points(is_processed)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_candidate_trips_status ON candidate_trips(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_candidate_trips_created ON candidate_trips(created_at DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_visited_places_trip_id ON visited_places(trip_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_visited_places_client_id ON visited_places(client_id)');

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

      // 添加 user_id 字段，用于区分不同用户的数据
      if (!columnNames.contains('user_id')) {
        await db.execute('ALTER TABLE candidate_trips ADD COLUMN user_id TEXT');
        log('✅ 添加 user_id 字段成功');
        // 创建索引
        await db.execute('CREATE INDEX IF NOT EXISTS idx_candidate_trips_user_id ON candidate_trips(user_id)');
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

  /// 获取待确认的候选旅行（按当前用户过滤）
  Future<List<CandidateTrip>> getPendingCandidateTrips() async {
    final db = await _db;
    final userId = await _getCurrentUserId();

    // 如果没有用户 ID，返回空列表
    if (userId == null) {
      log('⚠️ 未登录用户，无法获取待确认旅行');
      return [];
    }
    
    final maps = await db.query(
      'candidate_trips',
      where: 'status = ? AND user_id = ?',
      whereArgs: [CandidateTripStatus.pending.index, userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => CandidateTrip.fromMap(map)).toList();
  }

  /// 获取已确认的旅行（按当前用户过滤）
  Future<List<CandidateTrip>> getConfirmedTrips() async {
    final db = await _db;
    final userId = await _getCurrentUserId();

    // 如果没有用户 ID，返回空列表
    if (userId == null) {
      log('⚠️ 未登录用户，无法获取已确认旅行');
      return [];
    }
    
    final maps = await db.query(
      'candidate_trips',
      where: 'status = ? AND user_id = ?',
      whereArgs: [CandidateTripStatus.confirmed.index, userId],
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

  /// 插入候选旅行（自动添加当前用户 ID）
  Future<int> insertCandidateTrip(CandidateTrip trip) async {
    final db = await _db;
    final userId = await _getCurrentUserId();
    final tripMap = trip.toMap();

    // 如果没有 user_id，添加当前用户 ID
    if (tripMap['user_id'] == null && userId != null) {
      tripMap['user_id'] = userId;
    }
    
    return await db.insert('candidate_trips', tripMap);
  }

  /// 检查是否存在相似的旅行（相同城市和国家，到达时间在24小时内，同一用户）
  Future<bool> existsSimilarTrip(CandidateTrip trip) async {
    final db = await _db;
    final userId = await _getCurrentUserId();
    final startTime = trip.arrivalTime.subtract(const Duration(hours: 24));
    final endTime = trip.arrivalTime.add(const Duration(hours: 24));

    // 如果没有用户 ID，返回 false，允许插入
    if (userId == null) {
      return false;
    }

    final result = await db.query(
      'candidate_trips',
      where: 'city_name = ? AND country_name = ? AND arrival_time >= ? AND arrival_time <= ? AND user_id = ?',
      whereArgs: [
        trip.cityName,
        trip.countryName,
        startTime.toIso8601String(),
        endTime.toIso8601String(),
        userId,
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
      await txn.delete('visited_places');
    });
    log('✅ 所有旅行历史数据已清除');
  }

  // ==================== 访问地点操作 ====================

  /// 保存访问地点
  Future<int> saveVisitedPlace(VisitedPlace place) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final placeMap = place.toMap();
    placeMap['created_at'] = now;
    placeMap['updated_at'] = now;
    placeMap['is_synced_to_backend'] = 0;
    return await db.insert('visited_places', placeMap);
  }

  /// 批量保存访问地点
  Future<void> saveVisitedPlaces(List<VisitedPlace> places) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      for (final place in places) {
        final placeMap = place.toMap();
        placeMap['created_at'] = now;
        placeMap['updated_at'] = now;
        placeMap['is_synced_to_backend'] = 0;
        await txn.insert('visited_places', placeMap);
      }
    });
  }

  /// 根据旅行 ID 获取访问地点
  Future<List<VisitedPlace>> getVisitedPlacesByTripId(String tripId) async {
    final db = await _db;
    final maps = await db.query(
      'visited_places',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'arrival_time ASC',
    );
    return maps.map((map) => VisitedPlace.fromMap(map)).toList();
  }

  /// 获取未同步的访问地点
  Future<List<VisitedPlace>> getUnsyncedVisitedPlaces() async {
    final db = await _db;
    final maps = await db.query(
      'visited_places',
      where: 'is_synced_to_backend = ?',
      whereArgs: [0],
      orderBy: 'arrival_time ASC',
    );
    return maps.map((map) => VisitedPlace.fromMap(map)).toList();
  }

  /// 根据 client_id 获取访问地点
  Future<VisitedPlace?> getVisitedPlaceByClientId(String clientId) async {
    final db = await _db;
    final maps = await db.query(
      'visited_places',
      where: 'client_id = ?',
      whereArgs: [clientId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return VisitedPlace.fromMap(maps.first);
  }

  /// 更新访问地点
  Future<int> updateVisitedPlace(VisitedPlace place) async {
    final db = await _db;
    final placeMap = place.toMap();
    placeMap['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'visited_places',
      placeMap,
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  /// 标记访问地点为已同步
  Future<void> markVisitedPlaceAsSynced(int id, {String? backendId}) async {
    final db = await _db;
    final updates = <String, dynamic>{
      'is_synced_to_backend': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (backendId != null) {
      updates['backend_id'] = backendId;
    }
    await db.update(
      'visited_places',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除访问地点
  Future<int> deleteVisitedPlace(int id) async {
    final db = await _db;
    return await db.delete(
      'visited_places',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除旅行的所有访问地点
  Future<int> deleteVisitedPlacesByTripId(String tripId) async {
    final db = await _db;
    return await db.delete(
      'visited_places',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }

  /// 检查是否存在相似的访问地点（用于去重）
  Future<bool> existsSimilarVisitedPlace({
    required String tripId,
    required double latitude,
    required double longitude,
    required DateTime arrivalTime,
    Duration tolerance = const Duration(minutes: 30),
  }) async {
    final db = await _db;
    final startTime = arrivalTime.subtract(tolerance);
    final endTime = arrivalTime.add(tolerance);
    const locationTolerance = 0.001; // 约 100 米

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM visited_places
      WHERE trip_id = ?
        AND arrival_time >= ?
        AND arrival_time <= ?
        AND latitude >= ?
        AND latitude <= ?
        AND longitude >= ?
        AND longitude <= ?
    ''', [
      tripId,
      startTime.toIso8601String(),
      endTime.toIso8601String(),
      latitude - locationTolerance,
      latitude + locationTolerance,
      longitude - locationTolerance,
      longitude + locationTolerance,
    ]);

    return (result.first['count'] as int) > 0;
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
