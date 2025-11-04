import 'dart:convert';
import 'package:flutter/services.dart';

/// 城市名称国际化辅助类
/// 用于将API返回的英文城市名称转换为本地化显示
class CityNameHelper {
  static Map<String, String>? _cityNames;
  static String? _currentLocale;

  /// 加载城市名称映射
  /// 
  /// [locale] 语言代码，如 'zh' 或 'en'
  static Future<void> loadCityNames(String locale) async {
    if (_currentLocale == locale && _cityNames != null) {
      return; // 已加载相同语言，无需重新加载
    }

    try {
      final fileName = locale == 'zh' || locale.startsWith('zh')
          ? 'city_names_zh.json'
          : 'city_names_en.json';

      final jsonString = await rootBundle.loadString('lib/l10n/$fileName');
      final jsonData = json.decode(jsonString);
      _cityNames = Map<String, String>.from(jsonData['cityNames']);
      _currentLocale = locale;
    } catch (e) {
      print('⚠️ 加载城市名称映射失败: $e');
      _cityNames = {};
    }
  }

  /// 获取本地化的城市名称
  /// 
  /// [englishName] API返回的英文城市名称
  /// 返回对应语言的城市名称，如果找不到则返回原始英文名称
  static String getLocalizedCityName(String englishName) {
    if (_cityNames == null) {
      print('⚠️ 城市名称映射未加载，请先调用 loadCityNames()');
      return englishName;
    }
    return _cityNames![englishName] ?? englishName;
  }

  /// 清除缓存（用于语言切换后强制重新加载）
  static void clearCache() {
    _cityNames = null;
    _currentLocale = null;
  }

  /// 批量转换城市名称
  /// 
  /// [cities] 城市对象列表，需要有 name 属性
  /// 返回转换后的列表
  static List<Map<String, dynamic>> localizeCityList(
      List<Map<String, dynamic>> cities) {
    return cities.map((city) {
      return {
        ...city,
        'localizedName': getLocalizedCityName(city['name'] ?? ''),
      };
    }).toList();
  }

  /// 检查是否已加载
  static bool get isLoaded => _cityNames != null;

  /// 获取当前加载的语言
  static String? get currentLocale => _currentLocale;

  /// 获取支持的城市数量
  static int get supportedCitiesCount => _cityNames?.length ?? 0;
}
