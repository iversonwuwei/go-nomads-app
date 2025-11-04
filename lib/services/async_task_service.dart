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
    String? departureLocation,
    DateTime? departureDate,
  }) async {
    try {
      print('🚀 创建异步任务: 城市=$cityName, 天数=$duration');

      final requestData = {
        'cityId': cityId,
        'cityName': cityName,
        'duration': duration,
        'budget': budget,
        'travelStyle': travelStyle,
        'interests': interests ?? [],
      };

      // 添加出发地点（如果提供）
      if (departureLocation != null && departureLocation.isNotEmpty) {
        requestData['departureLocation'] = departureLocation;
      }

      // 添加出发日期（如果提供）
      if (departureDate != null) {
        requestData['departureDate'] = departureDate.toIso8601String();
      }

      final response = await _httpService.post(
        '/ai/travel-plan/async',
        data: requestData,
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

  /// 创建数字游民指南生成任务
  ///
  /// 返回任务ID和初始状态
  Future<CreateTaskResponse> createDigitalNomadGuideTask({
    required String cityId,
    required String cityName,
  }) async {
    try {
      print('🚀 创建数字游民指南异步任务: 城市=$cityName');

      final response = await _httpService.post(
        '/ai/guide/async',
        data: {
          'cityId': cityId,
          'cityName': cityName,
        },
      );

      print('✅ 指南任务创建成功: ${response.data}');

      final data = response.data;
      if (data == null) {
        throw Exception('后端返回数据为空');
      }

      final taskData = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      return CreateTaskResponse.fromJson(taskData);
    } catch (e) {
      print('❌ 创建指南任务失败: $e');
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

  /// 等待任务完成(使用 SignalR 实时通知)
  ///
  /// 优先使用 SignalR 实时推送,如果 SignalR 未连接则回退到轮询模式
  ///
  /// [taskId] 任务ID
  /// [onProgress] 进度更新回调
  /// [pollInterval] 轮询间隔(秒),默认3秒(仅轮询模式)
  /// [maxAttempts] 最大轮询次数,默认100次(仅轮询模式)
  ///
  /// 返回最终的任务状态
  Future<TaskStatus> pollTaskStatus({
    required String taskId,
    Function(TaskStatus status)? onProgress,
    Duration pollInterval = const Duration(seconds: 3),
    int maxAttempts = 100, // 5分钟 = 100次*3秒
  }) async {
    // 如果 SignalR 已连接,使用实时通知模式
    if (_signalRService.isConnected) {
      return _waitForTaskUsingSignalR(
        taskId: taskId,
        onProgress: onProgress,
      );
    }

    // 否则回退到轮询模式
    print('⚠️ SignalR 未连接,使用轮询模式');
    return _pollTaskStatusHttp(
      taskId: taskId,
      onProgress: onProgress,
      pollInterval: pollInterval,
      maxAttempts: maxAttempts,
    );
  }

  /// 使用 SignalR 等待任务完成
  Future<TaskStatus> _waitForTaskUsingSignalR({
    required String taskId,
    Function(TaskStatus status)? onProgress,
  }) async {
    print('📡 使用 SignalR 等待任务完成: $taskId');

    final completer = Completer<TaskStatus>();
    StreamSubscription<TaskStatus>? progressSub;
    StreamSubscription<TaskStatus>? completedSub;
    StreamSubscription<TaskStatus>? failedSub;

    try {
      // 订阅任务通知
      await _signalRService.subscribeToTask(taskId);

      // 监听进度更新
      progressSub = _signalRService.taskProgressStream
          .where((status) => status.taskId == taskId)
          .listen((status) {
        print('📊 收到进度更新: ${status.progress}%');
        onProgress?.call(status);
      });

      // 监听任务完成
      completedSub = _signalRService.taskCompletedStream
          .where((status) => status.taskId == taskId)
          .listen((status) {
        print('✅ 任务完成: $taskId');
        if (!completer.isCompleted) {
          completer.complete(status);
        }
      });

      // 监听任务失败
      failedSub = _signalRService.taskFailedStream
          .where((status) => status.taskId == taskId)
          .listen((status) {
        print('❌ 任务失败: $taskId');
        if (!completer.isCompleted) {
          completer.complete(status);
        }
      });

      // 获取初始状态
      final initialStatus = await getTaskStatus(taskId);

      // 如果任务已经完成或失败,直接返回
      if (initialStatus.isCompleted || initialStatus.isFailed) {
        return initialStatus;
      }

      // 回调初始进度
      onProgress?.call(initialStatus);

      // 等待完成信号(最多等待5分钟)
      final result = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('SignalR 等待超时: 超过5分钟未收到完成信号');
        },
      );

      return result;
    } catch (e) {
      print('❌ SignalR 等待失败: $e');
      rethrow;
    } finally {
      // 清理资源
      await progressSub?.cancel();
      await completedSub?.cancel();
      await failedSub?.cancel();
      await _signalRService.unsubscribeFromTask(taskId);
    }
  }

  /// HTTP 轮询模式(回退方案)
  Future<TaskStatus> _pollTaskStatusHttp({
    required String taskId,
    Function(TaskStatus status)? onProgress,
    Duration pollInterval = const Duration(seconds: 3),
    int maxAttempts = 100,
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
    String? departureLocation,
    DateTime? departureDate,
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
      departureLocation: departureLocation,
      departureDate: departureDate,
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

  /// 创建数字游民指南并等待完成
  ///
  /// [cityId] 城市ID
  /// [cityName] 城市名称
  /// [onProgress] 进度更新回调
  ///
  /// 返回完成后的任务状态(包含guideId)
  Future<TaskStatus> createGuideAndWaitForCompletion({
    required String cityId,
    required String cityName,
    Function(TaskStatus status)? onProgress,
  }) async {
    // 1. 创建任务
    final createResponse = await createDigitalNomadGuideTask(
      cityId: cityId,
      cityName: cityName,
    );

    print('✅ 指南任务已创建: ${createResponse.taskId}');

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
