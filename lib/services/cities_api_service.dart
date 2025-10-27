import '../config/api_config.dart';
import 'http_service.dart';

/// Cities API Service
/// 负责与后端 CityService 交互
class CitiesApiService {
  static final CitiesApiService _instance = CitiesApiService._internal();
  factory CitiesApiService() => _instance;

  final HttpService _httpService = HttpService();
  late final String baseUrl;

  CitiesApiService._internal() {
    baseUrl = '${ApiConfig.baseUrl}/cities';
  }

  /// 获取城市列表（分页）
  Future<Map<String, dynamic>> getCities({
    int page = 1,
    int pageSize = 20,
    String? countryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (countryId != null && countryId.isNotEmpty) {
        queryParameters['countryId'] = countryId;
      }

      final response = await _httpService.get(
        baseUrl,
        queryParameters: queryParameters,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取城市列表失败: ${e.toString()}');
    }
  }

  /// 获取推荐城市
  Future<List<dynamic>> getRecommendedCities({int count = 10}) async {
    try {
      final response = await _httpService.get(
        '$baseUrl/recommended',
        queryParameters: {'count': count},
      );

      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('获取推荐城市失败: ${e.toString()}');
    }
  }

  /// 根据 ID 获取单个城市
  Future<Map<String, dynamic>> getCityById(String id) async {
    try {
      final response = await _httpService.get('$baseUrl/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取城市详情失败: ${e.toString()}');
    }
  }

  /// 获取按国家分组的城市
  Future<Map<String, dynamic>> getCitiesGroupedByCountry() async {
    try {
      final response = await _httpService.get('$baseUrl/grouped-by-country');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取分组城市失败: ${e.toString()}');
    }
  }

  /// 获取所有国家列表
  Future<List<dynamic>> getCountries() async {
    try {
      final response = await _httpService.get('$baseUrl/countries');
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('获取国家列表失败: ${e.toString()}');
    }
  }

  /// 获取城市列表（含 Coworking 数量）- 专门为 coworking_home 页面设计
  /// 调用 CityService 的 /api/v1/cities/with-coworking-count 接口
  Future<Map<String, dynamic>> getCitiesWithCoworkingCount({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      // 调用 CityService 的专用接口
      final response = await _httpService.get(
        '/cities/with-coworking-count',
        queryParameters: queryParameters,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取城市列表(含Coworking数量)失败: ${e.toString()}');
    }
  }
}
