import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
      print('   预算(原始): $budget');
      print('   风格: $travelStyle');
      print('   兴趣: ${interests.join(', ')}');

      // 处理自定义预算格式 (e.g., "CNY:5000")
      String finalBudget = budget;
      String? finalCurrency = currency;
      double? finalCustomBudget = customBudget;

      if (budget.contains(':')) {
        // 解析自定义预算格式: "CURRENCY:AMOUNT"
        final parts = budget.split(':');
        if (parts.length == 2) {
          finalCurrency = parts[0]; // e.g., "CNY"
          final amount = double.tryParse(parts[1]);

          if (amount != null) {
            finalCustomBudget = amount;

            // 根据金额范围映射到 budget 级别
            // 这些阈值可以根据需要调整
            if (amount < 3000) {
              finalBudget = 'low';
            } else if (amount < 10000) {
              finalBudget = 'medium';
            } else {
              finalBudget = 'high';
            }

            print(
                '   💰 解析自定义预算: $finalCurrency $finalCustomBudget → $finalBudget');
          }
        }
      }

      print('   预算(最终): $finalBudget');

      // 设置较长的超时时间,因为AI生成需要时间
      final response = await _httpService.post(
        '/ai/travel-plan',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          'cityImage': cityImage,
          'duration': duration,
          'budget': finalBudget, // 使用映射后的预算级别 (low/medium/high)
          'travelStyle': travelStyle,
          'interests': interests,
          if (departureLocation != null) 'departureLocation': departureLocation,
          if (finalCustomBudget != null)
            'customBudget': finalCustomBudget.toString(),
          if (finalCurrency != null) 'currency': finalCurrency,
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

  /// 流式生成旅行计划 (使用 Server-Sent Events)
  ///
  /// 通过 [onProgress] 回调实时接收进度更新
  /// 通过 [onData] 回调接收最终的旅行计划
  /// 通过 [onError] 回调接收错误信息
  ///
  /// [cityId] 城市ID
  /// [cityName] 城市名称
  /// [cityImage] 城市图片URL
  /// [duration] 旅行天数 (1-30)
  /// [budget] 预算级别: 'low', 'medium', 'high'
  /// [travelStyle] 旅行风格: 'adventure', 'relaxation', 'culture', 'nightlife'
  /// [interests] 兴趣列表
  /// [onProgress] 进度回调 (message: 提示信息, progress: 进度 0-100)
  /// [onData] 数据回调 (返回完整的旅行计划)
  /// [onError] 错误回调
  Future<void> generateTravelPlanStream({
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
    required Function(String message, int progress) onProgress,
    required Function(TravelPlan plan) onData,
    required Function(String error) onError,
  }) async {
    try {
      print('🤖 [流式] 正在生成AI旅行计划...');

      // 处理预算格式 (与普通方法相同)
      String finalBudget = budget;
      String? finalCurrency = currency;
      double? finalCustomBudget = customBudget;

      if (budget.contains(':')) {
        final parts = budget.split(':');
        if (parts.length == 2) {
          finalCurrency = parts[0];
          final amount = double.tryParse(parts[1]);

          if (amount != null) {
            finalCustomBudget = amount;
            if (amount < 3000) {
              finalBudget = 'low';
            } else if (amount < 10000) {
              finalBudget = 'medium';
            } else {
              finalBudget = 'high';
            }
          }
        }
      }

      final response = await _httpService.post<ResponseBody>(
        '/ai/travel-plan/stream',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          'cityImage': cityImage,
          'duration': duration,
          'budget': finalBudget,
          'travelStyle': travelStyle,
          'interests': interests,
          if (departureLocation != null) 'departureLocation': departureLocation,
          if (finalCustomBudget != null)
            'customBudget': finalCustomBudget.toString(),
          if (finalCurrency != null) 'currency': finalCurrency,
          if (selectedAttractions != null)
            'selectedAttractions': selectedAttractions,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
          extra: {
            HttpService.disableApiResponseUnwrapKey: true,
          },
        ),
      );

      // 读取 SSE 流
      String buffer = '';

      await for (final Uint8List data in response.data!.stream) {
        final chunk = utf8.decode(data);
        buffer += chunk;

        // SSE 格式: data: {...}\n\n
        while (buffer.contains('\n\n')) {
          final index = buffer.indexOf('\n\n');
          final message = buffer.substring(0, index);
          buffer = buffer.substring(index + 2);

          // 解析 SSE 消息
          if (message.startsWith('data: ')) {
            final jsonStr = message.substring(6).trim();
            try {
              final event = json.decode(jsonStr) as Map<String, dynamic>;
              final type = event['type'] as String;
              final payload = event['payload'] as Map<String, dynamic>;

              print('📨 收到事件: $type');

              switch (type) {
                case 'start':
                case 'analyzing':
                case 'generating':
                  // 进度更新
                  final msg = payload['message'] as String;
                  final progress = (payload['progress'] as num).toInt();
                  onProgress(msg, progress);
                  break;

                case 'success':
                  // 生成成功,返回数据
                  final msg = payload['message'] as String;
                  final progress = (payload['progress'] as num).toInt();
                  onProgress(msg, progress);

                  final data = payload['data'] as Map<String, dynamic>;
                  final plan = TravelPlan.fromJson(data);
                  onData(plan);
                  print('✅ [流式] 旅行计划接收完成');
                  break;

                case 'error':
                  // 错误
                  final errorMsg = payload['message'] as String;
                  onError(errorMsg);
                  print('❌ [流式] 生成失败: $errorMsg');
                  break;

                default:
                  print('⚠️ 未知事件类型: $type');
              }
            } catch (e) {
              print('⚠️ 解析事件失败: $e');
            }
          }
        }
      }

      print('📡 流式连接已关闭');
    } on DioException catch (e) {
      print('❌ [流式] Dio错误: ${e.type}');
      print('   错误信息: ${e.message}');

      String errorMessage = '流式请求失败';
      if (e.response != null) {
        errorMessage = 'HTTP ${e.response!.statusCode}: ${e.message}';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'AI生成超时,请稍后重试';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = '网络连接失败,请检查网络';
      }

      onError(errorMessage);
    } catch (e, stackTrace) {
      print('❌ [流式] 生成旅行计划失败: $e');
      print('   堆栈跟踪: $stackTrace');
      onError('生成失败: $e');
    }
  }

  /// 根据 planId 获取旅行计划详情
  ///
  /// [planId] 旅行计划ID (从异步任务返回)
  ///
  /// 返回完整的旅行计划对象
  Future<TravelPlan> getTravelPlanById(String planId) async {
    try {
      print('📥 正在获取旅行计划详情...');
      print('   PlanId: $planId');

      final response = await _httpService.get(
        '/ai/travel-plans/$planId',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('✅ 旅行计划详情获取成功');
      print('   响应状态: ${response.statusCode}');

      // HttpService 拦截器已经自动解包了 ApiResponse
      if (response.data == null) {
        print('❌ 响应数据为 null');
        throw Exception('旅行计划数据为空');
      }

      final data = response.data as Map<String, dynamic>;
      print('📊 开始解析 TravelPlan...');

      final travelPlan = TravelPlan.fromJson(data);

      print('✅ 旅行计划解析成功');
      print('   计划ID: ${travelPlan.id}');
      print('   城市: ${travelPlan.cityName}');
      print('   天数: ${travelPlan.duration}');
      print('   每日行程数: ${travelPlan.dailyItineraries.length}');
      print('   景点数: ${travelPlan.attractions.length}');

      return travelPlan;
    } on DioException catch (e) {
      print('❌ Dio错误: ${e.type}');
      print('   错误信息: ${e.message}');
      print('   响应数据: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        throw Exception('旅行计划不存在或已过期 (24小时有效期)');
      }

      if (e.response != null) {
        final errorData = e.response!.data;
        String errorMessage = '获取旅行计划失败';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        throw Exception(errorMessage);
      }

      // 网络错误
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('请求超时,请稍后重试');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('网络连接失败,请检查网络');
      }

      throw Exception('获取旅行计划失败: ${e.message}');
    } catch (e) {
      print('❌ 解析旅行计划失败: $e');
      rethrow;
    }
  }
}
