import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/home_feed_model.dart';
import 'http_service.dart';

/// Home API 服务
/// 专门处理首页聚合数据的 API 交互
class HomeApiService {
  static final HomeApiService _instance = HomeApiService._internal();
  factory HomeApiService() => _instance;
  
  final HttpService _httpService = HttpService();
  
  HomeApiService._internal();
  
  /// 获取首页聚合数据
  /// 
  /// [cityLimit] 城市列表数量限制，默认6
  /// [meetupLimit] Meetup列表数量限制，默认6
  /// 
  /// 返回包含城市列表和活动列表的聚合数据
  Future<HomeFeedModel> getHomeFeed({
    int cityLimit = 6,
    int meetupLimit = 6,
  }) async {
    try {
      print('📡 正在获取首页聚合数据...');
      print('   城市限制: $cityLimit, 活动限制: $meetupLimit');
      
      final response = await _httpService.get(
        ApiConfig.homeFeedEndpoint,
        queryParameters: {
          'cityLimit': cityLimit,
          'meetupLimit': meetupLimit,
        },
      );
      
      print('✅ 首页数据获取成功');
      print('   响应状态: ${response.statusCode}');
      
      // 重要提示: HttpService 拦截器已经自动解包了 ApiResponse
      // response.data 现在直接是内层的 HomeFeedDto 对象，而不是完整的 { success, message, data } 结构
      // 因为拦截器在 onResponse 中执行了: response.data = envelope.data
      
      if (response.data == null) {
        print('❌ 响应数据为 null');
        throw Exception('API returned null data');
      }
      
      // response.data 已经是 data 字段的内容了
      final data = response.data as Map<String, dynamic>;
      print('📊 响应数据类型: ${data.runtimeType}');
      print('📊 数据键: ${data.keys.join(', ')}');
      
      print('📊 开始解析 HomeFeedModel...');
      final homeFeed = HomeFeedModel.fromJson(data);
      
      print('✅ 首页数据解析成功');
      print('   城市数量: ${homeFeed.cities.length}');
      print('   活动数量: ${homeFeed.meetups.length}');
      print('   hasMoreCities: ${homeFeed.hasMoreCities}');
      print('   hasMoreMeetups: ${homeFeed.hasMoreMeetups}');
      
      return homeFeed;
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
      print('❌ 获取首页数据失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
  
  /// 刷新首页数据
  /// 这是 getHomeFeed 的便捷包装，使用默认参数
  Future<HomeFeedModel> refreshHomeFeed() async {
    return getHomeFeed();
  }
}
