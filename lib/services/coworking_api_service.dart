import '../config/api_config.dart';
import 'http_service.dart';

/// Coworking API Service
/// 负责与后端 CoworkingService 交互
class CoworkingApiService {
  static final CoworkingApiService _instance = CoworkingApiService._internal();
  factory CoworkingApiService() => _instance;
  
  final HttpService _httpService = HttpService();
  late final String baseUrl;

  CoworkingApiService._internal() {
    baseUrl = '${ApiConfig.baseUrl}/coworking';
  }

  /// 获取 Coworking 空间列表（分页,支持按城市过滤）
  Future<Map<String, dynamic>> getCoworkingSpaces({
    int page = 1,
    int pageSize = 20,
    String? cityId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      
      if (cityId != null && cityId.isNotEmpty) {
        queryParameters['cityId'] = cityId;
      }

      final response = await _httpService.get(
        baseUrl,
        queryParameters: queryParameters,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取列表失败: ${e.toString()}');
    }
  }

  /// 获取城市的 Coworking 空间数量
  Future<int> getCityCoworkingCount(String cityId) async {
    try {
      final response = await _httpService.get(
        baseUrl,
        queryParameters: {
          'cityId': cityId,
          'page': 1,
          'pageSize': 1, // 只需要知道总数,不需要所有数据
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['totalCount'] as int? ?? 0;
    } catch (e) {
      print('获取城市 Coworking 数量失败: $e');
      return 0;
    }
  }

  /// 批量获取多个城市的 Coworking 空间数量
  /// 
  /// [cityIds] - 城市 ID 列表
  /// 返回: Map<String, int> - key 为城市 ID, value 为该城市的 Coworking 数量
  Future<Map<String, int>> getCoworkingCountByCities(List<String> cityIds) async {
    try {
      if (cityIds.isEmpty) {
        return {};
      }

      // 将城市 ID 列表转换为逗号分隔的字符串
      final cityIdsParam = cityIds.join(',');

      final response = await _httpService.get(
        '$baseUrl/count-by-cities',
        queryParameters: {
          'cityIds': cityIdsParam,
        },
      );

      // 响应格式: Map<String, int> (城市ID -> 数量)
      final data = response.data as Map<String, dynamic>;
      
      // 转换为 Map<String, int>
      return data.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('批量获取城市 Coworking 数量失败: $e');
      // 返回空 Map,让调用方处理
      return {};
    }
  }

  /// 创建 Coworking 空间
  Future<Map<String, dynamic>> createCoworkingSpace(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await _httpService.post(
        baseUrl,
        data: request,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('创建失败: ${e.toString()}');
    }
  }

  /// 根据 ID 获取单个 Coworking 空间
  Future<Map<String, dynamic>> getCoworkingById(String id) async {
    try {
      final response = await _httpService.get('$baseUrl/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取详情失败: ${e.toString()}');
    }
  }

  /// 更新 Coworking 空间
  Future<Map<String, dynamic>> updateCoworkingSpace(
    String id,
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await _httpService.put(
        '$baseUrl/$id',
        data: request,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('更新失败: ${e.toString()}');
    }
  }

  /// 删除 Coworking 空间
  Future<void> deleteCoworkingSpace(String id) async {
    try {
      await _httpService.delete('$baseUrl/$id');
    } catch (e) {
      throw Exception('删除失败: ${e.toString()}');
    }
  }
}
