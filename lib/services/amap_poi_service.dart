import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 高德地图 POI 服务
/// 通过高德地图 Web API 搜索周边 POI
class AmapPoiService {
  static AmapPoiService? _instance;

  AmapPoiService._();

  static AmapPoiService get instance {
    _instance ??= AmapPoiService._();
    return _instance!;
  }

  /// 高德地图 Web API Key
  /// 注意: 这是 Web 服务 API Key，不是 Android/iOS SDK Key
  /// 请在高德开放平台申请: https://lbs.amap.com/
  static const String _apiKey = '9194496314986698ad76d755f6349325';

  /// POI 类型定义 (高德分类编码)
  /// 参考: https://lbs.amap.com/api/webservice/download
  static const Map<String, String> poiTypeCode = {
    'hotel': '100000', // 酒店 (住宿服务)
    'cafe': '050500', // 咖啡厅
    'restaurant': '050000', // 餐饮服务
    'shopping': '060000', // 购物服务
    'attraction': '110000', // 风景名胜
  };

  /// POI 类型的中文名称
  static const Map<String, String> poiTypeName = {
    'hotel': '酒店',
    'cafe': '咖啡厅',
    'restaurant': '餐厅',
    'shopping': '购物中心',
    'attraction': '景点',
  };

  /// POI 类型的英文名称
  static const Map<String, String> poiTypeNameEn = {
    'hotel': 'Hotels',
    'cafe': 'Cafes',
    'restaurant': 'Restaurants',
    'shopping': 'Shopping',
    'attraction': 'Attractions',
  };

  /// 搜索周边 POI
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [type] POI 类型 (hotel, cafe, restaurant, shopping, attraction)
  /// [radius] 搜索半径(米)，默认 3000 米
  /// [limit] 返回结果数量限制，默认 20
  Future<List<PoiResult>> searchNearby({
    required double latitude,
    required double longitude,
    required String type,
    int radius = 3000,
    int limit = 20,
  }) async {
    final typeCode = poiTypeCode[type];
    if (typeCode == null) {
      debugPrint('❌ 未知的 POI 类型: $type');
      return [];
    }

    try {
      final uri = Uri.https('restapi.amap.com', '/v3/place/around', {
        'key': _apiKey,
        'location': '$longitude,$latitude', // 高德使用 经度,纬度 格式
        'types': typeCode,
        'radius': radius.toString(),
        'offset': limit.toString(),
        'page': '1',
        'extensions': 'all', // 返回详细信息
      });

      debugPrint('🔍 搜索周边 POI: $type');
      debugPrint('📍 位置: $latitude, $longitude');
      debugPrint('🌐 请求 URL: $uri');

      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      debugPrint('📥 响应状态码: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ POI 搜索请求失败: ${response.statusCode}');
        debugPrint('❌ 响应内容: ${response.body}');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('📦 响应数据: ${jsonEncode(data).substring(0, (jsonEncode(data).length > 500 ? 500 : jsonEncode(data).length))}...');

      if (data['status'] != '1') {
        debugPrint('❌ POI 搜索失败: ${data['info']} (infocode: ${data['infocode']})');
        return [];
      }

      final pois = (data['pois'] as List<dynamic>?) ?? [];
      final results = pois.map((poi) => PoiResult.fromAmapJson(poi, type)).toList();

      debugPrint('✅ 找到 ${results.length} 个 $type 类型的 POI');
      return results;
    } catch (e) {
      debugPrint('❌ POI 搜索异常: $e');
      return [];
    }
  }

  /// 搜索所有类型的周边 POI
  Future<Map<String, List<PoiResult>>> searchAllTypes({
    required double latitude,
    required double longitude,
    int radius = 3000,
    int limitPerType = 10,
  }) async {
    final results = <String, List<PoiResult>>{};

    // 并行搜索所有类型
    final futures = poiTypeCode.keys.map((type) async {
      final pois = await searchNearby(
        latitude: latitude,
        longitude: longitude,
        type: type,
        radius: radius,
        limit: limitPerType,
      );
      return MapEntry(type, pois);
    });

    final entries = await Future.wait(futures);

    for (final entry in entries) {
      results[entry.key] = entry.value;
    }

    return results;
  }
}

/// POI 搜索结果
class PoiResult {
  final String id;
  final String name;
  final String type; // hotel, cafe, restaurant, shopping, attraction
  final String typeName; // 类型中文名
  final String address;
  final double latitude;
  final double longitude;
  final String? tel; // 电话
  final double? rating; // 评分
  final String? distance; // 距离(米)
  final String? businessArea; // 商圈
  final String? openingHours; // 营业时间
  final List<String>? photos; // 图片 URL

  const PoiResult({
    required this.id,
    required this.name,
    required this.type,
    required this.typeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.tel,
    this.rating,
    this.distance,
    this.businessArea,
    this.openingHours,
    this.photos,
  });

  /// 从高德 API 响应解析
  factory PoiResult.fromAmapJson(Map<String, dynamic> json, String poiType) {
    // 安全获取字符串值（高德 API 可能返回空数组代替 null）
    String? safeString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      if (value is List) return null; // 空数组返回 null
      return value.toString();
    }

    // 解析坐标
    final locationStr = safeString(json['location']) ?? '';
    final parts = locationStr.split(',');
    final longitude = parts.isNotEmpty ? double.tryParse(parts[0]) ?? 0.0 : 0.0;
    final latitude = parts.length > 1 ? double.tryParse(parts[1]) ?? 0.0 : 0.0;

    // 解析评分 (高德返回的是字符串或空数组)
    final bizExt = json['biz_ext'];
    String? ratingStr;
    if (bizExt is Map<String, dynamic>) {
      ratingStr = safeString(bizExt['rating']);
    }
    final rating = ratingStr != null ? double.tryParse(ratingStr) : null;

    // 解析营业时间
    String? openingHours;
    if (bizExt is Map<String, dynamic>) {
      openingHours = safeString(bizExt['open_time']);
    }

    // 解析图片
    List<String>? photos;
    final photosData = json['photos'];
    if (photosData is List && photosData.isNotEmpty) {
      photos = photosData
          .whereType<Map<String, dynamic>>()
          .map((p) => safeString(p['url']) ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
      if (photos.isEmpty) photos = null;
    }

    return PoiResult(
      id: safeString(json['id']) ?? '',
      name: safeString(json['name']) ?? '',
      type: poiType,
      typeName: AmapPoiService.poiTypeName[poiType] ?? poiType,
      address: safeString(json['address']) ?? '',
      latitude: latitude,
      longitude: longitude,
      tel: safeString(json['tel']),
      rating: rating,
      distance: safeString(json['distance']),
      businessArea: safeString(json['business_area']),
      openingHours: openingHours,
      photos: photos,
    );
  }

  /// 格式化距离显示
  String get formattedDistance {
    if (distance == null) return '';
    final meters = int.tryParse(distance!) ?? 0;
    if (meters < 1000) {
      return '${meters}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }
}
