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
      version: 1,
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

    // 城市表
    await db.execute('''
      CREATE TABLE cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        weather TEXT,
        temperature REAL,
        cost_of_living REAL,
        internet_speed REAL,
        safety_score REAL,
        fun_score REAL,
        quality_of_life REAL,
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

    // 创建索引以提高查询性能
    await db.execute('CREATE INDEX idx_users_phone ON users(phone)');
    await db.execute('CREATE INDEX idx_cities_name ON cities(name)');
    await db.execute('CREATE INDEX idx_meetups_city ON meetups(city_id)');
    await db.execute('CREATE INDEX idx_meetups_status ON meetups(status)');
    await db.execute(
        'CREATE INDEX idx_reviews_target ON reviews(target_type, target_id)');
    await db.execute('CREATE INDEX idx_chat_room ON chat_messages(room_id)');
    await db.execute('CREATE INDEX idx_favorites_user ON favorites(user_id)');

    print('Database created successfully');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 在这里处理数据库升级逻辑
    if (oldVersion < newVersion) {
      // 根据版本号进行相应的升级操作
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
}
