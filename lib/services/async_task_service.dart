import 'dart:async';

import '../models/async_task_models.dart';
import 'http_service.dart';
import 'signalr_service.dart';

/// 异步任务服务
/// 处理 AI 旅行计划异步生成任务,支持 SignalR 实时通知和轮询回退
class AsyncTaskService {
  static final AsyncTaskService _instance = AsyncTaskService._internal();
  factory AsyncTaskService() => _instance;

  final HttpService _httpService = HttpService();
  final SignalRService _signalRService = SignalRService();

  AsyncTaskService._internal();

  /// 创建旅行计划生成任务
  ///
  /// 返回任务ID和初始状态
  Future<CreateTaskResponse> createTravelPlanTask({
    required String cityId,
    required String cityName,
    required int duration,
    required String budget, // "low", "medium", "high"
    required String
        travelStyle, // "adventure", "relaxation", "culture", "nightlife"
    List<String>? interests,
  }) async {
    try {
      print('🚀 创建异步任务: 城市=$cityName, 天数=$duration');

      final response = await _httpService.post(
        '/ai/travel-plan/async',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          'duration': duration,
          'budget': budget,
          'travelStyle': travelStyle,
          'interests': interests ?? [],
        },
      );

      print('✅ 任务创建成功: ${response.data}');

      // 后端直接返回数据对象,不需要嵌套 data 字段
      final data = response.data;
      if (data == null) {
        throw Exception('后端返回数据为空');
      }

      // 如果后端返回格式是 { "data": {...} },则取 data 字段
      // 否则直接使用 response.data
      final taskData = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      return CreateTaskResponse.fromJson(taskData);
    } catch (e) {
      print('❌ 创建任务失败: $e');
      rethrow;
    }
  }

  /// 查询任务状态
  ///
  /// [taskId] 任务ID
  /// 返回任务的当前状态和进度
  Future<TaskStatus> getTaskStatus(String taskId) async {
    try {
      final response = await _httpService.get(
        '/ai/travel-plan/tasks/$taskId',
      );

      final data = response.data;
      if (data == null) {
        throw Exception('后端返回数据为空');
      }

      // 如果后端返回格式是 { "data": {...} },则取 data 字段
      // 否则直接使用 response.data
      final taskData = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      return TaskStatus.fromJson(taskData);
    } catch (e) {
      print('❌ 查询任务状态失败: $e');
      rethrow;
    }
  }

  /// 轮询任务状态直到完成
  ///
  /// [taskId] 任务ID
  /// [onProgress] 进度更新回调
  /// [pollInterval] 轮询间隔(秒),默认3秒
  /// [maxAttempts] 最大轮询次数,默认40次(2分钟)
  ///
  /// 返回最终的任务状态
  Future<TaskStatus> pollTaskStatus({
    required String taskId,
    Function(TaskStatus status)? onProgress,
    Duration pollInterval = const Duration(seconds: 3),
    int maxAttempts = 100, // 5分钟 = 100次*3秒
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;

      try {
        final status = await getTaskStatus(taskId);

        print('📊 任务状态 (第$attempts次): ${status.status} - ${status.progress}%');

        // 通知进度
        onProgress?.call(status);

        // 检查是否完成
        if (status.isCompleted || status.isFailed) {
          return status;
        }

        // 等待后继续轮询
        await Future.delayed(pollInterval);
      } catch (e) {
        print('⚠️ 轮询出错 (第$attempts次): $e');

        // 如果是最后一次尝试,抛出异常
        if (attempts >= maxAttempts) {
          rethrow;
        }

        // 否则继续等待
        await Future.delayed(pollInterval);
      }
    }

    throw TimeoutException(
      '任务超时: 轮询超过 ${maxAttempts * pollInterval.inSeconds} 秒',
    );
  }

  /// 创建任务并等待完成
  ///
  /// 这是一个便捷方法,结合了创建任务和轮询状态
  ///
  /// [cityId] 城市ID
  /// [cityName] 城市名称
  /// [duration] 旅行天数
  /// [budget] 预算等级 ("low", "medium", "high")
  /// [travelStyle] 旅行风格 ("adventure", "relaxation", "culture", "nightlife")
  /// [interests] 兴趣列表
  /// [onProgress] 进度更新回调
  ///
  /// 返回完成后的任务状态(包含planId)
  Future<TaskStatus> createAndWaitForCompletion({
    required String cityId,
    required String cityName,
    required int duration,
    required String budget,
    required String travelStyle,
    List<String>? interests,
    Function(TaskStatus status)? onProgress,
  }) async {
    // 1. 创建任务
    final createResponse = await createTravelPlanTask(
      cityId: cityId,
      cityName: cityName,
      duration: duration,
      budget: budget,
      travelStyle: travelStyle,
      interests: interests,
    );

    print('✅ 任务已创建: ${createResponse.taskId}');

    // 2. 轮询直到完成
    final finalStatus = await pollTaskStatus(
      taskId: createResponse.taskId,
      onProgress: onProgress,
    );

    if (finalStatus.isFailed) {
      throw Exception('任务失败: ${finalStatus.error}');
    }

    return finalStatus;
  }

  /// 获取 SignalR 服务实例(用于外部订阅事件)
  SignalRService get signalR => _signalRService;
}

/// 超时异常
class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
