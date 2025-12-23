import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

/// 地理编码结果
class GeocodingResult {
  final String? cityName;
  final String? districtName;
  final String? provinceName;
  final String? countryName;
  final String? formattedAddress;
  final String? adCode; // 行政区划代码

  GeocodingResult({
    this.cityName,
    this.districtName,
    this.provinceName,
    this.countryName,
    this.formattedAddress,
    this.adCode,
  });

  /// 获取显示用的城市名称
  String get displayCityName {
    // 优先使用区/县名，如果没有则使用城市名
    if (districtName != null && districtName!.isNotEmpty) {
      return districtName!;
    }
    if (cityName != null && cityName!.isNotEmpty) {
      return cityName!;
    }
    return '未知位置';
  }

  /// 获取完整的地址（城市+区）
  String get fullLocationName {
    final parts = <String>[];
    if (cityName != null && cityName!.isNotEmpty) {
      parts.add(cityName!);
    }
    if (districtName != null &&
        districtName!.isNotEmpty &&
        districtName != cityName) {
      parts.add(districtName!);
    }
    return parts.isNotEmpty ? parts.join(' ') : '未知位置';
  }

  @override
  String toString() {
    return 'GeocodingResult($displayCityName, $provinceName, $countryName)';
  }
}

/// 反向地理编码服务
/// 将经纬度坐标转换为城市/地址信息
class ReverseGeocodingService {
  static ReverseGeocodingService? _instance;

  ReverseGeocodingService._();

  static ReverseGeocodingService get instance {
    _instance ??= ReverseGeocodingService._();
    return _instance!;
  }

  /// 高德地图 Web API Key
  static const String _amapApiKey = '9194496314986698ad76d755f6349325';

  /// 缓存（避免重复请求）
  final Map<String, GeocodingResult> _cache = {};

  /// 生成缓存键（精确到小数点后2位，约1km精度）
  String _cacheKey(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
  }

  /// 反向地理编码（使用高德地图 API）
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [useCache] 是否使用缓存，默认 true
  Future<GeocodingResult?> reverseGeocode(
    double latitude,
    double longitude, {
    bool useCache = true,
  }) async {
    // 检查缓存
    final cacheKey = _cacheKey(latitude, longitude);
    if (useCache && _cache.containsKey(cacheKey)) {
      log('📍 使用缓存的地理编码结果: $cacheKey');
      return _cache[cacheKey];
    }

    try {
      // 高德使用 经度,纬度 格式
      final location = '$longitude,$latitude';

      final uri = Uri.https('restapi.amap.com', '/v3/geocode/regeo', {
        'key': _amapApiKey,
        'location': location,
        'extensions': 'base', // 基本信息即可
        'output': 'json',
      });

      log('🌐 反向地理编码请求: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        log('❌ 反向地理编码请求失败: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] != '1') {
        log('❌ 反向地理编码失败: ${data['info']} (code: ${data['infocode']})');
        return null;
      }

      final regeocode = data['regeocode'] as Map<String, dynamic>?;
      if (regeocode == null) {
        log('❌ 反向地理编码结果为空');
        return null;
      }

      final addressComponent =
          regeocode['addressComponent'] as Map<String, dynamic>?;
      final formattedAddress = regeocode['formatted_address'] as String?;

      if (addressComponent == null) {
        log('❌ 地址组件为空');
        return null;
      }

      // 解析结果
      final result = GeocodingResult(
        cityName: _parseField(addressComponent['city']),
        districtName: _parseField(addressComponent['district']),
        provinceName: _parseField(addressComponent['province']),
        countryName: _parseField(addressComponent['country']) ?? '中国',
        formattedAddress: formattedAddress,
        adCode: _parseField(addressComponent['adcode']),
      );

      // 缓存结果
      _cache[cacheKey] = result;

      log('✅ 反向地理编码成功: ${result.displayCityName}');
      return result;
    } catch (e) {
      log('❌ 反向地理编码异常: $e');
      return null;
    }
  }

  /// 解析字段（高德有时返回空数组 []）
  String? _parseField(dynamic value) {
    if (value == null) return null;
    if (value is List && value.isEmpty) return null;
    if (value is String && value.isEmpty) return null;
    return value.toString();
  }

  /// 批量反向地理编码
  /// 每次最多处理20个坐标（高德限制）
  Future<List<GeocodingResult?>> batchReverseGeocode(
    List<({double latitude, double longitude})> coordinates,
  ) async {
    final results = <GeocodingResult?>[];

    for (final coord in coordinates) {
      final result = await reverseGeocode(coord.latitude, coord.longitude);
      results.add(result);

      // 添加小延迟避免触发频率限制
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }

  /// 清除缓存
  void clearCache() {
    _cache.clear();
    log('🗑️ 地理编码缓存已清除');
  }

  /// 获取缓存大小
  int get cacheSize => _cache.length;
}
