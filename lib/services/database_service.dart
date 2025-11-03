import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite 数据库服务
/// 用于管理本地数据存储,临时替代后端服务
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    // 获取应用文档目录
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'df_admin.db');

    // 打开数据库,如果不存在则创建
    return await openDatabase(
      path,
      version: 6, // 升级到版本6 - 添加数字游民指南表
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone TEXT UNIQUE NOT NULL,
        password TEXT,
        nickname TEXT,
        avatar TEXT,
        email TEXT,
        bio TEXT,
        city TEXT,
        country TEXT,
        occupation TEXT,
        skills TEXT,
        interests TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 城市表 - 按照 DataServiceController 格式
    await db.execute('''
      CREATE TABLE cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        region TEXT,
        climate TEXT,
        description TEXT,
        image_url TEXT,
        weather TEXT,
        temperature REAL,
        cost_of_living REAL,
        internet_speed REAL,
        safety_score REAL,
        overall_score REAL,
        fun_score REAL,
        quality_of_life REAL,
        aqi INTEGER,
        population TEXT,
        timezone TEXT,
        humidity INTEGER,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 共享办公空间表
    await db.execute('''
      CREATE TABLE coworking_spaces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        city_id INTEGER,
        address TEXT,
        description TEXT,
        image_url TEXT,
        price_per_day REAL,
        price_per_month REAL,
        rating REAL,
        wifi_speed REAL,
        has_meeting_room INTEGER DEFAULT 0,
        has_coffee INTEGER DEFAULT 0,
        latitude REAL,
        longitude REAL,
        phone TEXT,
        email TEXT,
        website TEXT,
        opening_hours TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities (id)
      )
    ''');

    // 活动聚会表
    await db.execute('''
      CREATE TABLE meetups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        organizer_id INTEGER,
        city_id INTEGER,
        location TEXT,
        address TEXT,
        image_url TEXT,
        category TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        max_participants INTEGER,
        current_participants INTEGER DEFAULT 0,
        price REAL DEFAULT 0,
        status TEXT DEFAULT 'upcoming',
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (organizer_id) REFERENCES users (id),
        FOREIGN KEY (city_id) REFERENCES cities (id)
      )
    ''');

    // 活动参与者表
    await db.execute('''
      CREATE TABLE meetup_participants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meetup_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        status TEXT DEFAULT 'joined',
        joined_at TEXT NOT NULL,
        FOREIGN KEY (meetup_id) REFERENCES meetups (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(meetup_id, user_id)
      )
    ''');

    // 酒店表
    await db.execute('''
      CREATE TABLE hotels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        city_id INTEGER NOT NULL,
        address TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        rating REAL DEFAULT 0.0,
        review_count INTEGER DEFAULT 0,
        description TEXT,
        amenities TEXT,
        images TEXT,
        category TEXT DEFAULT 'mid-range',
        price_per_night REAL DEFAULT 0.0,
        currency TEXT DEFAULT 'USD',
        is_featured INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities (id)
      )
    ''');

    // 房型表
    await db.execute('''
      CREATE TABLE room_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hotel_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        max_occupancy INTEGER DEFAULT 2,
        size REAL DEFAULT 25.0,
        bed_type TEXT DEFAULT 'Queen',
        price_per_night REAL NOT NULL,
        currency TEXT DEFAULT 'USD',
        available_rooms INTEGER DEFAULT 0,
        amenities TEXT,
        images TEXT,
        is_available INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE
      )
    ''');

    // 酒店预订表
    await db.execute('''
      CREATE TABLE hotel_bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hotel_id INTEGER NOT NULL,
        room_type_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        check_in_date TEXT NOT NULL,
        check_out_date TEXT NOT NULL,
        number_of_rooms INTEGER DEFAULT 1,
        number_of_guests INTEGER DEFAULT 1,
        total_price REAL NOT NULL,
        currency TEXT DEFAULT 'USD',
        status TEXT DEFAULT 'pending',
        special_requests TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (hotel_id) REFERENCES hotels (id),
        FOREIGN KEY (room_type_id) REFERENCES room_types (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 酒店相关索引
    await db.execute('CREATE INDEX idx_hotels_city_id ON hotels (city_id)');
    await db
        .execute('CREATE INDEX idx_hotels_is_featured ON hotels (is_featured)');
    await db.execute('CREATE INDEX idx_hotels_rating ON hotels (rating DESC)');
    await db.execute('CREATE INDEX idx_hotels_category ON hotels (category)');
    await db.execute(
        'CREATE INDEX idx_room_types_hotel_id ON room_types (hotel_id)');
    await db.execute(
        'CREATE INDEX idx_room_types_is_available ON room_types (is_available)');
    await db.execute(
        'CREATE INDEX idx_hotel_bookings_user_id ON hotel_bookings (user_id)');
    await db.execute(
        'CREATE INDEX idx_hotel_bookings_status ON hotel_bookings (status)');
    await db.execute(
        'CREATE INDEX idx_hotel_bookings_check_in ON hotel_bookings (check_in_date)');
    await db.execute(
        'CREATE INDEX idx_hotel_bookings_hotel_id ON hotel_bookings (hotel_id)');

    // 评论表
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        target_type TEXT NOT NULL,
        target_id INTEGER NOT NULL,
        rating REAL NOT NULL,
        content TEXT,
        images TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 旅行计划表
    await db.execute('''
      CREATE TABLE travel_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        cities TEXT,
        budget REAL,
        status TEXT DEFAULT 'planning',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 聊天消息表
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_id TEXT NOT NULL,
        sender_id INTEGER NOT NULL,
        sender_name TEXT NOT NULL,
        sender_avatar TEXT,
        message TEXT NOT NULL,
        message_type TEXT DEFAULT 'text',
        created_at TEXT NOT NULL,
        FOREIGN KEY (sender_id) REFERENCES users (id)
      )
    ''');

    // 收藏表
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        target_type TEXT NOT NULL,
        target_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, target_type, target_id)
      )
    ''');

    // Token 认证表
    await db.execute('''
      CREATE TABLE tokens (
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
    ''');

    // 数字游民指南表
    await db.execute('''
      CREATE TABLE digital_nomad_guides (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city_id TEXT NOT NULL UNIQUE,
        city_name TEXT NOT NULL,
        overview TEXT,
        best_areas TEXT,
        visa_info TEXT,
        workspace_recommendations TEXT,
        tips TEXT,
        essential_info TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('CREATE INDEX idx_users_phone ON users(phone)');
    await db.execute('CREATE INDEX idx_cities_name ON cities(name)');
    await db.execute('CREATE INDEX idx_meetups_city ON meetups(city_id)');
    await db.execute('CREATE INDEX idx_meetups_status ON meetups(status)');
    await db.execute(
        'CREATE INDEX idx_reviews_target ON reviews(target_type, target_id)');
    await db.execute('CREATE INDEX idx_chat_room ON chat_messages(room_id)');
    await db.execute('CREATE INDEX idx_favorites_user ON favorites(user_id)');
    await db.execute('CREATE INDEX idx_tokens_user ON tokens(user_id)');
    await db.execute(
        'CREATE INDEX idx_guides_city ON digital_nomad_guides(city_id)');

    print('Database created successfully');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (oldVersion < 2 && newVersion >= 2) {
      // 版本 1 -> 2: 添加 cities 表的 region 字段
      try {
        // 检查 cities 表是否存在 region 列
        final result = await db.rawQuery("PRAGMA table_info(cities)");
        final hasRegion = result.any((col) => col['name'] == 'region');

        if (!hasRegion) {
          // 添加 region 列
          await db.execute('ALTER TABLE cities ADD COLUMN region TEXT');
          print('✅ 已添加 cities.region 字段');
        }
      } catch (e) {
        print('⚠️ 升级数据库时出错: $e');
      }
    }

    if (oldVersion < 3 && newVersion >= 3) {
      // 版本 2 -> 3: 添加酒店相关表
      try {
        print('🏨 开始添加酒店相关表...');

        // 酒店表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS hotels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            city_id INTEGER NOT NULL,
            address TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            rating REAL DEFAULT 0.0,
            review_count INTEGER DEFAULT 0,
            description TEXT,
            amenities TEXT,
            images TEXT,
            category TEXT DEFAULT 'mid-range',
            price_per_night REAL DEFAULT 0.0,
            currency TEXT DEFAULT 'USD',
            is_featured INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (city_id) REFERENCES cities (id)
          )
        ''');

        // 房型表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS room_types (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hotel_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            max_occupancy INTEGER DEFAULT 2,
            size REAL DEFAULT 25.0,
            bed_type TEXT DEFAULT 'Queen',
            price_per_night REAL NOT NULL,
            currency TEXT DEFAULT 'USD',
            available_rooms INTEGER DEFAULT 0,
            amenities TEXT,
            images TEXT,
            is_available INTEGER DEFAULT 1,
            created_at TEXT NOT NULL,
            FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE
          )
        ''');

        // 酒店预订表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS hotel_bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hotel_id INTEGER NOT NULL,
            room_type_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            check_in_date TEXT NOT NULL,
            check_out_date TEXT NOT NULL,
            number_of_rooms INTEGER DEFAULT 1,
            number_of_guests INTEGER DEFAULT 1,
            total_price REAL NOT NULL,
            currency TEXT DEFAULT 'USD',
            status TEXT DEFAULT 'pending',
            special_requests TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (hotel_id) REFERENCES hotels (id),
            FOREIGN KEY (room_type_id) REFERENCES room_types (id),
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');

        // 创建索引
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotels_city_id ON hotels (city_id)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotels_is_featured ON hotels (is_featured)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotels_rating ON hotels (rating DESC)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotels_category ON hotels (category)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_room_types_hotel_id ON room_types (hotel_id)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_room_types_is_available ON room_types (is_available)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotel_bookings_user_id ON hotel_bookings (user_id)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotel_bookings_status ON hotel_bookings (status)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotel_bookings_check_in ON hotel_bookings (check_in_date)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_hotel_bookings_hotel_id ON hotel_bookings (hotel_id)');

        print('✅ 酒店相关表创建完成');
      } catch (e) {
        print('⚠️ 创建酒店表时出错: $e');
      }
    }

    if (oldVersion < 4 && newVersion >= 4) {
      // 版本 3 -> 4: 添加 tokens 表
      try {
        print('🔑 开始添加 tokens 表...');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS tokens (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            access_token TEXT NOT NULL,
            refresh_token TEXT NOT NULL,
            token_type TEXT NOT NULL,
            expires_in INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tokens_user ON tokens(user_id)');

        print('✅ tokens 表创建完成');
      } catch (e) {
        print('⚠️ 创建 tokens 表时出错: $e');
      }
    }

    if (oldVersion < 5 && newVersion >= 5) {
      // 版本 4 -> 5: 为 tokens 表添加用户信息字段
      try {
        print('🔑 开始为 tokens 表添加用户信息字段...');

        // 检查字段是否已存在
        final result = await db.rawQuery("PRAGMA table_info(tokens)");
        final hasUserName = result.any((col) => col['name'] == 'user_name');
        final hasUserEmail = result.any((col) => col['name'] == 'user_email');

        if (!hasUserName) {
          await db.execute('ALTER TABLE tokens ADD COLUMN user_name TEXT');
          print('✅ 添加 user_name 字段');
        }

        if (!hasUserEmail) {
          await db.execute('ALTER TABLE tokens ADD COLUMN user_email TEXT');
          print('✅ 添加 user_email 字段');
        }

        print('✅ tokens 表字段升级完成');
      } catch (e) {
        print('⚠️ 升级 tokens 表时出错: $e');
      }
    }

    if (oldVersion < 6 && newVersion >= 6) {
      // 版本 5 -> 6: 添加数字游民指南表
      try {
        print('📖 开始添加数字游民指南表...');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS digital_nomad_guides (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            city_id TEXT NOT NULL UNIQUE,
            city_name TEXT NOT NULL,
            overview TEXT,
            best_areas TEXT,
            visa_info TEXT,
            workspace_recommendations TEXT,
            tips TEXT,
            essential_info TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_guides_city ON digital_nomad_guides(city_id)');

        print('✅ 数字游民指南表创建完成');
      } catch (e) {
        print('⚠️ 创建数字游民指南表时出错: $e');
      }
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 清空所有表数据(用于测试)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('favorites');
      await txn.delete('chat_messages');
      await txn.delete('travel_plans');
      await txn.delete('reviews');
      await txn.delete('meetup_participants');
      await txn.delete('meetups');
      await txn.delete('coworking_spaces');
      await txn.delete('cities');
      await txn.delete('users');
    });
    print('All data cleared');
  }

  /// 删除数据库文件
  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'df_admin.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('Database deleted');
  }

  // ==================== 数字游民指南相关方法 ====================

  /// 保存或更新数字游民指南 (使用 cityId 作为唯一标识)
  Future<void> saveGuide(Map<String, dynamic> guideJson) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    try {
      // 将复杂字段序列化为 JSON 字符串
      final guideData = {
        'city_id': guideJson['cityId'] ?? guideJson['CityId'],
        'city_name': guideJson['cityName'] ?? guideJson['CityName'],
        'overview': guideJson['overview'] ?? guideJson['Overview'],
        'best_areas':
            _serializeList(guideJson['bestAreas'] ?? guideJson['BestAreas']),
        'visa_info':
            _serializeMap(guideJson['visaInfo'] ?? guideJson['VisaInfo']),
        'workspace_recommendations': _serializeList(
            guideJson['workspaceRecommendations'] ??
                guideJson['WorkspaceRecommendations']),
        'tips': _serializeList(guideJson['tips'] ?? guideJson['Tips']),
        'essential_info': _serializeMap(
            guideJson['essentialInfo'] ?? guideJson['EssentialInfo']),
        'created_at': now,
        'updated_at': now,
      };

      // 使用 INSERT OR REPLACE 实现覆盖
      await db.insert(
        'digital_nomad_guides',
        guideData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Guide 已保存到 SQLite: cityId=${guideData['city_id']}');
    } catch (e) {
      print('❌ 保存 Guide 失败: $e');
      rethrow;
    }
  }

  /// 从 SQLite 加载指南
  Future<Map<String, dynamic>?> loadGuide(String cityId) async {
    final db = await database;

    try {
      final results = await db.query(
        'digital_nomad_guides',
        where: 'city_id = ?',
        whereArgs: [cityId],
        limit: 1,
      );

      if (results.isEmpty) {
        print('ℹ️ SQLite 中未找到 Guide: cityId=$cityId');
        return null;
      }

      final row = results.first;

      // 反序列化为标准格式 (使用 camelCase)
      final guideJson = {
        'cityId': row['city_id'],
        'cityName': row['city_name'],
        'overview': row['overview'],
        'bestAreas': _deserializeList(row['best_areas'] as String?),
        'visaInfo': _deserializeMap(row['visa_info'] as String?),
        'workspaceRecommendations':
            _deserializeStringList(row['workspace_recommendations'] as String?),
        'tips': _deserializeStringList(row['tips'] as String?),
        'essentialInfo':
            _deserializeStringMap(row['essential_info'] as String?),
      };

      print('✅ 从 SQLite 加载 Guide: cityId=$cityId');
      return guideJson;
    } catch (e) {
      print('❌ 加载 Guide 失败: $e');
      return null;
    }
  }

  /// 删除指定城市的指南
  Future<void> deleteGuide(String cityId) async {
    final db = await database;

    try {
      await db.delete(
        'digital_nomad_guides',
        where: 'city_id = ?',
        whereArgs: [cityId],
      );

      print('✅ Guide 已删除: cityId=$cityId');
    } catch (e) {
      print('❌ 删除 Guide 失败: $e');
    }
  }

  // ==================== 序列化辅助方法 ====================

  String _serializeList(dynamic list) {
    if (list == null) return '[]';
    if (list is String) return list; // 已经是字符串
    return jsonEncode(list);
  }

  String _serializeMap(dynamic map) {
    if (map == null) return '{}';
    if (map is String) return map; // 已经是字符串
    return jsonEncode(map);
  }

  List<dynamic> _deserializeList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return jsonDecode(json) as List<dynamic>;
    } catch (e) {
      print('❌ 反序列化 List 失败: $e');
      return [];
    }
  }

  Map<String, dynamic> _deserializeMap(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      print('❌ 反序列化 Map 失败: $e');
      return {};
    }
  }

  List<String> _deserializeStringList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      print('❌ 反序列化 String List 失败: $e');
      return [];
    }
  }

  Map<String, String> _deserializeStringMap(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      print('❌ 反序列化 String Map 失败: $e');
      return {};
    }
  }
}
