import 'package:dio/dio.dart';

import '../models/travel_plan_model.dart';
import 'http_service.dart';

/// AI API 服务
/// 专门处理 AI 相关的 API 交互
class AiApiService {
  static final AiApiService _instance = AiApiService._internal();
  factory AiApiService() => _instance;

  final HttpService _httpService = HttpService();

  AiApiService._internal();

  /// 生成旅行计划
  ///
  /// [cityId] 城市ID
  /// [cityName] 城市名称
  /// [cityImage] 城市图片URL
  /// [duration] 旅行天数 (1-30)
  /// [budget] 预算级别: 'low', 'medium', 'high'
  /// [travelStyle] 旅行风格: 'adventure', 'relaxation', 'culture', 'nightlife'
  /// [interests] 兴趣列表
  /// [departureLocation] 出发地 (可选)
  /// [customBudget] 自定义预算 (可选)
  /// [currency] 货币 (可选)
  /// [selectedAttractions] 选中的景点 (可选)
  ///
  /// 返回完整的旅行计划
  Future<TravelPlan> generateTravelPlan({
    required String cityId,
    required String cityName,
    required String cityImage,
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
  }) async {
    try {
      print('🤖 正在生成AI旅行计划...');
      print('   城市: $cityName');
      print('   天数: $duration');
      print('   预算: $budget');
      print('   风格: $travelStyle');
      print('   兴趣: ${interests.join(', ')}');

      // 设置较长的超时时间,因为AI生成需要时间
      final response = await _httpService.post(
        '/ai/travel-plan',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          'cityImage': cityImage,
          'duration': duration,
          'budget': budget,
          'travelStyle': travelStyle,
          'interests': interests,
          if (departureLocation != null) 'departureLocation': departureLocation,
          if (customBudget != null) 'customBudget': customBudget,
          if (currency != null) 'currency': currency,
          if (selectedAttractions != null)
            'selectedAttractions': selectedAttractions,
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 3), // AI生成可能需要更长时间（与后端保持一致）
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('✅ AI旅行计划生成成功');
      print('   响应状态: ${response.statusCode}');

      // HttpService 拦截器已经自动解包了 ApiResponse
      // response.data 现在直接是 TravelPlanResponse 对象
      if (response.data == null) {
        print('❌ 响应数据为 null');
        throw Exception('AI service returned null data');
      }

      final data = response.data as Map<String, dynamic>;
      print('📊 响应数据类型: ${data.runtimeType}');
      print('📊 数据键: ${data.keys.join(', ')}');

      print('📊 开始解析 TravelPlan...');
      final travelPlan = TravelPlan.fromJson(data);

      print('✅ 旅行计划解析成功');
      print('   计划ID: ${travelPlan.id}');
      print('   天数: ${travelPlan.duration}');
      print('   每日行程数: ${travelPlan.dailyItineraries.length}');
      print('   景点数: ${travelPlan.attractions.length}');
      print('   餐厅数: ${travelPlan.restaurants.length}');

      return travelPlan;
    } on DioException catch (e) {
      print('❌ Dio错误: ${e.type}');
      print('   错误信息: ${e.message}');
      print('   响应数据: ${e.response?.data}');

      if (e.response != null) {
        // 尝试解析后端返回的错误消息
        final errorData = e.response!.data;
        String errorMessage = 'AI服务错误';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        throw Exception('HTTP ${e.response!.statusCode}: $errorMessage');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('AI生成超时,请稍后重试');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('网络连接失败,请检查网络');
      } else {
        throw Exception('网络错误: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('❌ 生成旅行计划失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}
