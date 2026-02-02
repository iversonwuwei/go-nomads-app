import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:go_nomads_app/features/city/domain/entities/digital_nomad_guide.dart';

/// DigitalNomadGuide 数据访问对象
/// 负责管理城市指南的本地存储和检索
class DigitalNomadGuideDao {
  final Database _db;

  DigitalNomadGuideDao(this._db);

  static const String tableName = 'digital_nomad_guides';

  /// 创建表
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        city_id TEXT PRIMARY KEY,
        city_name TEXT NOT NULL,
        overview TEXT NOT NULL,
        visa_info TEXT NOT NULL,
        best_areas TEXT NOT NULL,
        workspace_recommendations TEXT NOT NULL,
        tips TEXT NOT NULL,
        essential_info TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建索引以加速查询
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_guides_city_id 
      ON $tableName(city_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_guides_updated_at 
      ON $tableName(updated_at DESC)
    ''');
  }

  /// 保存或更新城市指南
  Future<void> saveGuide(DigitalNomadGuide guide) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 将 DTO 转为可存储的 Map
    final data = {
      'city_id': guide.cityId,
      'city_name': guide.cityName,
      'overview': guide.overview,
      'visa_info': jsonEncode(_visaInfoToMap(guide.visaInfo)),
      'best_areas': jsonEncode(
        guide.bestAreas.map((area) => _bestAreaToMap(area)).toList(),
      ),
      'workspace_recommendations': jsonEncode(guide.workspaceRecommendations),
      'tips': jsonEncode(guide.tips),
      'essential_info': jsonEncode(guide.essentialInfo),
      'created_at': now,
      'updated_at': now,
    };

    await _db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 根据城市ID获取指南
  Future<DigitalNomadGuide?> getGuide(String cityId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      where: 'city_id = ?',
      whereArgs: [cityId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToGuide(maps.first);
  }

  /// 检查指南是否存在
  Future<bool> hasGuide(String cityId) async {
    final count = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE city_id = ?',
        [cityId],
      ),
    );
    return (count ?? 0) > 0;
  }

  /// 删除指定城市的指南
  Future<void> deleteGuide(String cityId) async {
    await _db.delete(
      tableName,
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
  }

  /// 删除所有指南（用于清空缓存）
  Future<void> deleteAll() async {
    await _db.delete(tableName);
  }

  /// 获取所有指南（用于管理或调试）
  Future<List<DigitalNomadGuide>> getAllGuides() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => _mapToGuide(map)).toList();
  }

  /// 获取指南更新时间
  Future<DateTime?> getGuideUpdatedAt(String cityId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      tableName,
      columns: ['updated_at'],
      where: 'city_id = ?',
      whereArgs: [cityId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    final timestamp = maps.first['updated_at'] as int;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 检查指南是否过期（默认30天）
  Future<bool> isGuideExpired(String cityId, {int maxDays = 30}) async {
    final updatedAt = await getGuideUpdatedAt(cityId);
    if (updatedAt == null) return true;

    final difference = DateTime.now().difference(updatedAt);
    return difference.inDays > maxDays;
  }

  /// 删除过期指南
  Future<int> deleteExpiredGuides({int maxDays = 30}) async {
    final expiredTimestamp = DateTime.now()
        .subtract(Duration(days: maxDays))
        .millisecondsSinceEpoch;

    return await _db.delete(
      tableName,
      where: 'updated_at < ?',
      whereArgs: [expiredTimestamp],
    );
  }

  // ==================== 私有辅助方法 ====================

  /// 将数据库 Map 转为 DigitalNomadGuide 实体
  DigitalNomadGuide _mapToGuide(Map<String, dynamic> map) {
    return DigitalNomadGuide.fromMap({
      'cityId': map['city_id'],
      'cityName': map['city_name'],
      'overview': map['overview'],
      'visaInfo': jsonDecode(map['visa_info'] as String),
      'bestAreas': jsonDecode(map['best_areas'] as String),
      'workspaceRecommendations':
          jsonDecode(map['workspace_recommendations'] as String),
      'tips': jsonDecode(map['tips'] as String),
      'essentialInfo': jsonDecode(map['essential_info'] as String),
    });
  }

  /// 将 VisaInfo 转换为 Map
  Map<String, dynamic> _visaInfoToMap(VisaInfo visaInfo) {
    return visaInfo.toMap();
  }

  /// 将 BestArea 转换为 Map
  Map<String, dynamic> _bestAreaToMap(BestArea area) {
    return area.toMap();
  }
}
