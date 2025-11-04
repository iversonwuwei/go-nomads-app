import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/city_detail_model.dart';
import 'http_service.dart';

/// City API 服务
/// 专门处理与后端 CityService 的 API 交互
class CityApiService {
  static final CityApiService _instance = CityApiService._internal();
  factory CityApiService() => _instance;

  final HttpService _httpService = HttpService();

  CityApiService._internal();

  /// 获取城市列表
  ///
  /// [page] 页码,从1开始
  /// [pageSize] 每页数量,默认20
  /// [search] 搜索关键词(可选)
  /// [countryId] 国家筛选(可选)
  ///
  /// 返回城市列表数据
  Future<Map<String, dynamic>> getCities({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? countryId,
  }) async {
    try {
      print('📡 正在获取城市列表...');
      print('   页码: $page, 每页: $pageSize');
      if (search != null) print('   搜索: $search');
      if (countryId != null) print('   国家: $countryId');

      // 如果有搜索关键词,使用专用搜索接口
      if (search != null && search.isNotEmpty) {
        return await _searchCities(
          name: search,
          pageNumber: page,
          pageSize: pageSize,
        );
      }

      // 否则使用普通列表接口
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (countryId != null && countryId.isNotEmpty) {
        queryParams['countryId'] = countryId;
      }

      final response = await _httpService.get(
        ApiConfig.citiesEndpoint,
        queryParameters: queryParams,
      );

      print('✅ 城市列表获取成功');
      print('   响应状态: ${response.statusCode}');

      if (response.data == null) {
        print('❌ 响应数据为 null');
        throw Exception('API returned null data');
      }

      final data = response.data as Map<String, dynamic>;
      print('📊 返回数据: ${data['totalCount'] ?? 0} 条城市');

      return data;
    } on DioException catch (e) {
      print('❌ Dio错误: ${e.type}');
      print('   错误信息: ${e.message}');
      print('   响应数据: ${e.response?.data}');

      if (e.response != null) {
        throw Exception('HTTP ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('❌ 获取城市列表失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 使用专用搜索接口搜索城市
  ///
  /// [name] 城市名称关键词
  /// [pageNumber] 页码
  /// [pageSize] 每页数量
  ///
  /// 返回搜索结果(包装成统一的分页格式)
  Future<Map<String, dynamic>> _searchCities({
    required String name,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      print('🔍 使用搜索接口: /cities/search');
      print('   关键词: $name');

      final response = await _httpService.get(
        ApiConfig.citySearchEndpoint,
        queryParameters: {
          'name': name,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      print('✅ 搜索接口调用成功');

      if (response.data == null) {
        print('❌ 响应数据为 null');
        throw Exception('API returned null data');
      }

      // 搜索接口返回的是 { success, message, data: [...] }
      // response.data 可能已经是解析后的对象
      dynamic responseData = response.data;

      // 如果是 Map,提取 data 字段
      List<dynamic> itemsList = [];
      if (responseData is Map<String, dynamic>) {
        final dataField = responseData['data'];
        if (dataField is List) {
          itemsList = dataField;
        }
      } else if (responseData is List) {
        // 如果直接是 List,使用它
        itemsList = responseData;
      }

      print('📊 搜索到 ${itemsList.length} 条城市');

      return {
        'items': itemsList,
        'totalCount': itemsList.length,
        'page': pageNumber,
        'pageSize': pageSize,
      };
    } on DioException catch (e) {
      print('❌ 搜索Dio错误: ${e.type}');
      print('   错误信息: ${e.message}');
      print('   响应数据: ${e.response?.data}');

      if (e.response != null) {
        throw Exception('HTTP ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('❌ 搜索城市失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 获取推荐城市列表
  ///
  /// [limit] 数量限制,默认10
  ///
  /// 返回推荐城市列表
  Future<List<Map<String, dynamic>>> getRecommendedCities({
    int limit = 10,
  }) async {
    try {
      print('📡 正在获取推荐城市...');
      print('   数量限制: $limit');

      final response = await _httpService.get(
        ApiConfig.cityRecommendedEndpoint,
        queryParameters: {'limit': limit},
      );

      print('✅ 推荐城市获取成功');

      if (response.data == null) {
        return [];
      }

      // HttpService 拦截器已自动解包 ApiResponse
      final data = response.data;

      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map((item) => item as Map<String, dynamic>),
        );
      } else if (data is Map<String, dynamic>) {
        // 如果返回的是分页数据,提取 items 字段
        final items = data['items'] ?? data['data'] ?? [];
        return List<Map<String, dynamic>>.from(
          items.map((item) => item as Map<String, dynamic>),
        );
      }

      return [];
    } catch (e, stackTrace) {
      print('❌ 获取推荐城市失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 获取城市详情
  ///
  /// [cityId] 城市ID
  ///
  /// 返回城市详细信息
  Future<Map<String, dynamic>> getCityDetail(String cityId) async {
    try {
      print('📡 正在获取城市详情: $cityId');

      final endpoint = ApiConfig.cityDetailEndpoint.replaceAll('{id}', cityId);
      final response = await _httpService.get(endpoint);

      print('✅ 城市详情获取成功');

      if (response.data == null) {
        throw Exception('City not found');
      }

      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      print('❌ 获取城市详情失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 搜索城市
  ///
  /// [query] 搜索关键词
  /// [limit] 结果数量限制,默认20
  ///
  /// 返回匹配的城市列表
  Future<List<Map<String, dynamic>>> searchCities({
    required String query,
    int limit = 20,
  }) async {
    try {
      print('📡 正在搜索城市: $query');

      final response = await _httpService.get(
        ApiConfig.citySearchEndpoint,
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      print('✅ 城市搜索成功');

      if (response.data == null) {
        return [];
      }

      final data = response.data;

      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map((item) => item as Map<String, dynamic>),
        );
      } else if (data is Map<String, dynamic>) {
        final items = data['items'] ?? data['data'] ?? [];
        return List<Map<String, dynamic>>.from(
          items.map((item) => item as Map<String, dynamic>),
        );
      }

      return [];
    } catch (e, stackTrace) {
      print('❌ 搜索城市失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 按国家获取城市列表
  ///
  /// [countryId] 国家ID
  ///
  /// 返回该国家的城市列表
  Future<List<Map<String, dynamic>>> getCitiesByCountry(
      String countryId) async {
    try {
      print('📡 正在获取国家城市列表: $countryId');

      final endpoint =
          ApiConfig.cityByCountryEndpoint.replaceAll('{id}', countryId);
      final response = await _httpService.get(endpoint);

      print('✅ 国家城市列表获取成功');

      if (response.data == null) {
        return [];
      }

      final data = response.data;

      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map((item) => item as Map<String, dynamic>),
        );
      } else if (data is Map<String, dynamic>) {
        final items = data['items'] ?? data['data'] ?? [];
        return List<Map<String, dynamic>>.from(
          items.map((item) => item as Map<String, dynamic>),
        );
      }

      return [];
    } catch (e, stackTrace) {
      print('❌ 获取国家城市列表失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 获取城市统计信息
  ///
  /// [cityId] 城市ID
  ///
  /// 返回城市的统计数据(评分、费用、人口等)
  Future<Map<String, dynamic>> getCityStatistics(String cityId) async {
    try {
      print('📡 正在获取城市统计: $cityId');

      final endpoint =
          ApiConfig.cityStatisticsEndpoint.replaceAll('{id}', cityId);
      final response = await _httpService.get(endpoint);

      print('✅ 城市统计获取成功');

      if (response.data == null) {
        throw Exception('Statistics not found');
      }

      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      print('❌ 获取城市统计失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  // ==================== Pros & Cons API ====================

  /// 添加城市 Pros & Cons
  ///
  /// [cityId] 城市ID
  /// [text] 优点或挑战的文本内容
  /// [isPro] true = 优点, false = 挑战
  ///
  /// 返回创建的 Pros & Cons 数据
  /// 添加 Pros & Cons
  /// [isPro] true = 优点, false = 挑战
  Future<ProsCons> addProsCons({
    required String cityId,
    required String text,
    required bool isPro,
  }) async {
    try {
      print('📡 正在添加 ${isPro ? "优点" : "挑战"}: $cityId');
      print('   内容: $text');

      final endpoint = '/cities/$cityId/user-content/pros-cons';
      final response = await _httpService.post(
        endpoint,
        data: {
          'cityId': cityId,
          'text': text,
          'isPro': isPro,
        },
      );

      print('✅ ${isPro ? "优点" : "挑战"}添加成功');

      if (response.data == null) {
        throw Exception('Failed to add pros/cons');
      }

      final data = response.data as Map<String, dynamic>;
      final prosConsData = data['data'] as Map<String, dynamic>;
      return ProsCons.fromJson(prosConsData);
    } catch (e, stackTrace) {
      print('❌ 添加 Pros & Cons 失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 获取城市的 Pros & Cons
  ///
  /// [cityId] 城市ID
  /// [isPro] 可选筛选: true = 只返回优点, false = 只返回挑战, null = 返回全部
  ///
  /// 返回 Pros & Cons 列表
  Future<List<ProsCons>> getCityProsCons({
    required String cityId,
    bool? isPro,
  }) async {
    try {
      print('📡 正在获取城市 Pros & Cons: $cityId');
      if (isPro != null) {
        print('   筛选: ${isPro ? "仅优点" : "仅挑战"}');
      }

      final endpoint = '/cities/$cityId/user-content/pros-cons';
      final queryParams = <String, dynamic>{};

      if (isPro != null) {
        queryParams['isPro'] = isPro;
      }

      final response = await _httpService.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('✅ Pros & Cons 获取成功');

      if (response.data == null) {
        return [];
      }

      // 处理两种可能的响应格式
      List<dynamic> items;

      if (response.data is List) {
        // 直接返回数组格式: [...]
        items = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        // 标准包装格式: {success: true, data: [...]}
        final data = response.data as Map<String, dynamic>;
        items = data['data'] as List<dynamic>? ?? [];
      } else {
        print('⚠️ 未知的响应格式: ${response.data.runtimeType}');
        return [];
      }

      print('📊 返回数据: ${items.length} 条 Pros & Cons');

      return items
          .map((item) => ProsCons.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print('❌ 获取 Pros & Cons 失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 更新 Pros & Cons
  ///
  /// [cityId] 城市ID
  /// [id] Pros & Cons ID
  /// [text] 新的文本内容
  /// [isPro] true = 优点, false = 挑战
  ///
  /// 返回更新后的数据
  Future<Map<String, dynamic>> updateProsCons({
    required String cityId,
    required String id,
    required String text,
    required bool isPro,
  }) async {
    try {
      print('📡 正在更新 Pros & Cons: $id');
      print('   内容: $text');

      final endpoint = '/cities/$cityId/user-content/pros-cons/$id';
      final response = await _httpService.put(
        endpoint,
        data: {
          'text': text,
          'isPro': isPro,
        },
      );

      print('✅ Pros & Cons 更新成功');

      if (response.data == null) {
        throw Exception('Failed to update pros/cons');
      }

      final data = response.data as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>;
    } catch (e, stackTrace) {
      print('❌ 更新 Pros & Cons 失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 删除 Pros & Cons
  ///
  /// [cityId] 城市ID
  /// [id] Pros & Cons ID
  ///
  /// 返回是否删除成功
  Future<bool> deleteProsCons({
    required String cityId,
    required String id,
  }) async {
    try {
      print('📡 正在删除 Pros & Cons: $id');

      final endpoint = '/cities/$cityId/user-content/pros-cons/$id';
      final response = await _httpService.delete(endpoint);

      print('✅ Pros & Cons 删除成功');

      if (response.data == null) {
        return false;
      }

      final data = response.data as Map<String, dynamic>;
      return data['success'] as bool? ?? false;
    } catch (e, stackTrace) {
      print('❌ 删除 Pros & Cons 失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}
