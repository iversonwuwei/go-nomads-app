import 'package:get/get.dart';

import 'package:df_admin_mobile/services/database_service.dart';
import 'package:df_admin_mobile/services/notification_service.dart';

/// 后台任务状态
enum TaskStatus {
  idle, // 空闲
  running, // 运行中
  completed, // 已完成
  failed, // 失败
}

/// 后台任务信息
class BackgroundTask {
  final String id;
  final String cityId;
  final String cityName;
  final TaskStatus status;
  final String? error;
  final DateTime startTime;
  DateTime? endTime;

  BackgroundTask({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.status,
    this.error,
    required this.startTime,
    this.endTime,
  });

  /// 转换为数据库存储格式
  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'cityId': cityId,
      'cityName': cityName,
      'status': status.name,
      'error': error,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  /// 从数据库恢复任务
  factory BackgroundTask.fromDb(Map<String, dynamic> data) {
    return BackgroundTask(
      id: data['id'],
      cityId: data['city_id'],
      cityName: data['city_name'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.failed,
      ),
      error: data['error'],
      startTime: DateTime.parse(data['start_time']),
      endTime:
          data['end_time'] != null ? DateTime.parse(data['end_time']) : null,
    );
  }

  BackgroundTask copyWith({
    TaskStatus? status,
    String? error,
    DateTime? endTime,
  }) {
    return BackgroundTask(
      id: id,
      cityId: cityId,
      cityName: cityName,
      status: status ?? this.status,
      error: error ?? this.error,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// 后台任务服务
class BackgroundTaskService extends GetxService {
  static BackgroundTaskService get to => Get.find();

  // 当前活跃的任务
  final _activeTasks = <String, BackgroundTask>{}.obs;

  // 最大并发任务数
  static const int _maxConcurrentTasks = 2;

  /// 安全获取通知服务
  NotificationService? _getNotificationService() {
    try {
      return Get.find<NotificationService>();
    } catch (e) {
      // 通知服务未初始化,返回 null
      return null;
    }
  }

  /// 获取当前运行中的任务数量
  int get runningTasksCount {
    return _activeTasks.values
        .where((task) => task.status == TaskStatus.running)
        .length;
  }

  /// 检查是否可以创建新任务
  bool get canCreateTask => runningTasksCount < _maxConcurrentTasks;

  /// 创建并启动一个后台任务
  Future<String> createTask({
    required String cityId,
    required String cityName,
    required Future<void> Function(Function(int progress) onProgress)
        taskFunction,
  }) async {
    // 检查是否超过最大并发数
    if (!canCreateTask) {
      throw Exception('已达到最大并发任务数($_maxConcurrentTasks),请等待其他任务完成');
    }

    // 生成任务 ID
    final taskId = '${cityId}_${DateTime.now().millisecondsSinceEpoch}';

    // 创建任务
    final task = BackgroundTask(
      id: taskId,
      cityId: cityId,
      cityName: cityName,
      status: TaskStatus.running,
      startTime: DateTime.now(),
    );

    _activeTasks[taskId] = task;

    // 保存到数据库
    await DatabaseService().saveBackgroundTask(task.toDb());

    // 显示初始进行中通知 (0%)
    final notificationService = _getNotificationService();
    if (notificationService != null) {
      await notificationService.showGuideGenerating(cityName, progress: 0);
    } else {
      print('⚠️ 通知服务未初始化,跳过通知');
    }

    // 在后台执行任务
    _executeTask(taskId, taskFunction);

    return taskId;
  }

  /// 执行任务
  Future<void> _executeTask(
    String taskId,
    Future<void> Function(Function(int progress) onProgress) taskFunction,
  ) async {
    try {
      // 执行任务函数,传入进度回调
      await taskFunction((int progress) {
        // 更新通知进度 (确保进度在 0-100 范围内)
        final task = _activeTasks[taskId];
        if (task != null) {
          final clampedProgress = progress.clamp(0, 100);
          final notificationService = _getNotificationService();
          if (notificationService != null) {
            notificationService.showGuideGenerating(
              task.cityName,
              progress: clampedProgress,
            );
          }
          print('📊 任务 $taskId 进度更新: $clampedProgress%');
        }
      });

      // 更新任务状态为完成
      final task = _activeTasks[taskId];
      if (task != null) {
        final completedTask = task.copyWith(
          status: TaskStatus.completed,
          endTime: DateTime.now(),
        );
        _activeTasks[taskId] = completedTask;

        // 更新数据库
        await DatabaseService().updateBackgroundTask(taskId, {
          'status': TaskStatus.completed.name,
          'end_time': completedTask.endTime!.toIso8601String(),
        });

        // 显示完成通知
        final notificationService = _getNotificationService();
        if (notificationService != null) {
          await notificationService.showGuideCompleted(
            task.cityId,
            task.cityName,
          );
        }

        // 5秒后移除内存中的任务记录并删除数据库记录
        Future.delayed(const Duration(seconds: 5), () async {
          _activeTasks.remove(taskId);
          await DatabaseService().deleteBackgroundTask(taskId);
        });
      }
    } catch (e) {
      // 更新任务状态为失败
      final task = _activeTasks[taskId];
      if (task != null) {
        final failedTask = task.copyWith(
          status: TaskStatus.failed,
          error: e.toString(),
          endTime: DateTime.now(),
        );
        _activeTasks[taskId] = failedTask;

        // 更新数据库
        await DatabaseService().updateBackgroundTask(taskId, {
          'status': TaskStatus.failed.name,
          'error': e.toString(),
          'end_time': failedTask.endTime!.toIso8601String(),
        });

        // 显示失败通知
        final notificationService = _getNotificationService();
        if (notificationService != null) {
          await notificationService.showGuideFailed(
            task.cityName,
            e.toString(),
          );
        }

        // 5秒后移除内存中的任务记录 (保留数据库记录供分析)
        Future.delayed(const Duration(seconds: 5), () {
          _activeTasks.remove(taskId);
        });
      }
    }
  }

  /// 获取任务状态
  TaskStatus? getTaskStatus(String taskId) {
    return _activeTasks[taskId]?.status;
  }

  /// 获取城市的活跃任务
  BackgroundTask? getCityActiveTask(String cityId) {
    try {
      return _activeTasks.values.firstWhere(
        (task) => task.cityId == cityId && task.status == TaskStatus.running,
      );
    } catch (e) {
      return null;
    }
  }

  /// 检查城市是否有进行中的任务
  bool hasCityActiveTask(String cityId) {
    return getCityActiveTask(cityId) != null;
  }

  /// 取消任务(实际上无法真正取消异步任务,只是取消通知)
  Future<void> cancelTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null) {
      final notificationService = _getNotificationService();
      if (notificationService != null) {
        await notificationService.cancelNotification(task.cityName);
      }
      _activeTasks.remove(taskId);
    }
  }

  /// 获取所有活跃任务
  List<BackgroundTask> get activeTasks => _activeTasks.values.toList();

  /// 恢复未完成的任务 (App 启动时调用)
  /// 注意: 由于任务函数无法序列化,这里只能将未完成的任务标记为失败
  Future<void> restoreUnfinishedTasks() async {
    try {
      final pendingTasks = await DatabaseService().loadPendingBackgroundTasks();

      if (pendingTasks.isEmpty) {
        print('✅ 没有需要恢复的任务');
        return;
      }

      print('🔄 发现 ${pendingTasks.length} 个未完成的任务,将标记为失败');

      for (final taskData in pendingTasks) {
        final taskId = taskData['id'];
        final cityName = taskData['city_name'];

        // 更新数据库状态为失败
        await DatabaseService().updateBackgroundTask(taskId, {
          'status': TaskStatus.failed.name,
          'error': 'App 重启,任务被中断',
          'end_time': DateTime.now().toIso8601String(),
        });

        // 显示失败通知
        final notificationService = _getNotificationService();
        if (notificationService != null) {
          await notificationService.showGuideFailed(
            cityName,
            'App 重启导致任务中断,请重新生成指南',
          );
        }

        print('⚠️ 任务 $taskId 已标记为失败');
      }

      // 清理旧任务
      await DatabaseService().cleanupOldBackgroundTasks();
    } catch (e) {
      print('❌ 恢复任务失败: $e');
    }
  }
}
