import '../config/api_config.dart';
import 'http_service.dart';

/// 首页数据服务类
class HomeDataService {
  final HttpService _httpService = HttpService();
  
  /// 获取首页数据
  /// 
  /// 返回包含首页所有数据的 Map:
  /// - banners: 轮播图数据
  /// - recommendedCities: 推荐城市
  /// - recentMeetups: 最近的 Meetup
  /// - featuredProjects: 精选创意项目
  /// - popularSpaces: 热门共享空间
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await _httpService.get(
        ApiConfig.homeDataEndpoint,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('获取首页数据失败');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 获取轮播图数据
  /// 
  /// 返回: List 包含轮播图项
  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final response = await _httpService.get(
        ApiConfig.homeBannersEndpoint,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['banners'] != null) {
          return (data['banners'] as List).cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw HttpException('获取轮播图失败');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 获取推荐城市列表
  /// 
  /// 参数:
  /// - [limit] 返回数量限制
  Future<List<Map<String, dynamic>>> getRecommendedCities({
    int? limit,
  }) async {
    try {
      final response = await _httpService.get(
        ApiConfig.citiesEndpoint,
        queryParameters: {
          'recommended': true,
          if (limit != null) 'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['cities'] != null) {
          return (data['cities'] as List).cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw HttpException('获取推荐城市失败');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 获取所有城市列表
  /// 
  /// 参数:
  /// - [page] 页码 (从 1 开始)
  /// - [pageSize] 每页数量
  /// - [search] 搜索关键词
  Future<Map<String, dynamic>> getCities({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final response = await _httpService.get(
        ApiConfig.citiesEndpoint,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('获取城市列表失败');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 获取城市详情
  /// 
  /// 参数:
  /// - [cityId] 城市 ID
  Future<Map<String, dynamic>> getCityDetail(String cityId) async {
    try {
      final response = await _httpService.get(
        ApiConfig.cityDetailEndpoint.replaceAll('{id}', cityId),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('获取城市详情失败');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 获取共享空间列表
  /// 
  /// 参数:
  /// - [cityId] 城市 ID (可选)
  /// - [page] 页码
  /// - [pageSize] 每页数量
  Future<Map<String, dynamic>> getCoworkingSpaces({
    String? cityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _httpService.get(
        ApiConfig.coworkingSpacesEndpoint,
        queryParameters: {
          if (cityId != null) 'cityId': cityId,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('获取共享空间列表失败');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 获取创意项目列表
  /// 
  /// 参数:
  /// - [page] 页码
  /// - [pageSize] 每页数量
  /// - [category] 分类
  Future<Map<String, dynamic>> getInnovationProjects({
    int page = 1,
    int pageSize = 20,
    String? category,
  }) async {
    try {
      final response = await _httpService.get(
        ApiConfig.innovationProjectsEndpoint,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (category != null) 'category': category,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('获取创意项目列表失败');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 获取 Meetup 列表
  /// 
  /// 参数:
  /// - [cityId] 城市 ID (可选)
  /// - [page] 页码
  /// - [pageSize] 每页数量
  /// - [upcoming] 是否只显示即将到来的活动
  Future<Map<String, dynamic>> getMeetups({
    String? cityId,
    int page = 1,
    int pageSize = 20,
    bool upcoming = false,
  }) async {
    try {
      final response = await _httpService.get(
        ApiConfig.meetupsEndpoint,
        queryParameters: {
          if (cityId != null) 'cityId': cityId,
          'page': page,
          'pageSize': pageSize,
          if (upcoming) 'upcoming': true,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw HttpException('获取 Meetup 列表失败');
      }
    } catch (e) {
      rethrow;
    }
  }
}
