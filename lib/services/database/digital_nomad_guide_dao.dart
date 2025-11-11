import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../features/city/domain/entities/city_detail.dart' as entity;

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
  Future<void> saveGuide(entity.DigitalNomadGuide guide) async {
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
  Future<entity.DigitalNomadGuide?> getGuide(String cityId) async {
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
  Future<List<entity.DigitalNomadGuide>> getAllGuides() async {
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
  entity.DigitalNomadGuide _mapToGuide(Map<String, dynamic> map) {
    return entity.DigitalNomadGuide(
      cityId: map['city_id'] as String,
      cityName: map['city_name'] as String,
      overview: map['overview'] as String,
      visaInfo: _mapToVisaInfo(jsonDecode(map['visa_info'] as String)),
      bestAreas: (jsonDecode(map['best_areas'] as String) as List)
          .map((area) => _mapToBestArea(area))
          .toList(),
      workspaceRecommendations: List<String>.from(
        jsonDecode(map['workspace_recommendations'] as String),
      ),
      tips: List<String>.from(jsonDecode(map['tips'] as String)),
      essentialInfo: Map<String, String>.from(
        jsonDecode(map['essential_info'] as String),
      ),
    );
  }

  /// 将 VisaInfo 转换为 Map
  Map<String, dynamic> _visaInfoToMap(entity.VisaInfo visaInfo) {
    return {
      'type': visaInfo.type,
      'duration': visaInfo.duration,
      'requirements': visaInfo.requirements,
      'cost': visaInfo.cost,
      'process': visaInfo.process,
    };
  }

  /// Map 转 VisaInfo
  entity.VisaInfo _mapToVisaInfo(Map<String, dynamic> map) {
    return entity.VisaInfo(
      type: map['type'] as String,
      duration: map['duration'] as int,
      requirements: map['requirements'] as String,
      cost: (map['cost'] as num).toDouble(),
      process: map['process'] as String,
    );
  }

  /// 将 BestArea 转换为 Map
  Map<String, dynamic> _bestAreaToMap(entity.BestArea area) {
    return {
      'name': area.name,
      'description': area.description,
      'entertainmentScore': area.entertainmentScore,
      'entertainmentDescription': area.entertainmentDescription,
      'tourismScore': area.tourismScore,
      'tourismDescription': area.tourismDescription,
      'economyScore': area.economyScore,
      'economyDescription': area.economyDescription,
      'cultureScore': area.cultureScore,
      'cultureDescription': area.cultureDescription,
    };
  }

  /// Map 转 BestArea
  entity.BestArea _mapToBestArea(Map<String, dynamic> map) {
    return entity.BestArea(
      name: map['name'] as String,
      description: map['description'] as String,
      entertainmentScore: (map['entertainmentScore'] as num).toDouble(),
      entertainmentDescription: map['entertainmentDescription'] as String,
      tourismScore: (map['tourismScore'] as num).toDouble(),
      tourismDescription: map['tourismDescription'] as String,
      economyScore: (map['economyScore'] as num).toDouble(),
      economyDescription: map['economyDescription'] as String,
      cultureScore: (map['cultureScore'] as num).toDouble(),
      cultureDescription: map['cultureDescription'] as String,
    );
  }
}
