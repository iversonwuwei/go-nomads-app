/// 异步任务领域实体
/// 代表后台异步执行的任务核心领域对象
class AsyncTask {
  final String taskId;
  final TaskState state;
  final TaskResult? result;
  final String? error;
  final TaskProgress progress;
  final TaskTimestamps timestamps;

  AsyncTask({
    required this.taskId,
    required this.state,
    this.result,
    this.error,
    required this.progress,
    required this.timestamps,
  });

  // === 业务逻辑方法 ===

  /// 是否已完成
  bool get isCompleted => state == TaskState.completed;

  /// 是否失败
  bool get isFailed => state == TaskState.failed;

  /// 是否处理中
  bool get isProcessing => state == TaskState.processing;

  /// 是否排队中
  bool get isQueued => state == TaskState.queued;

  /// 是否处于终态 (已完成或失败)
  bool get isTerminal => isCompleted || isFailed;

  /// 是否可以重试 (仅失败的任务可以重试)
  bool get canRetry => isFailed;

  /// 是否可以取消 (排队中或处理中的任务可以取消)
  bool get canCancel => isQueued || isProcessing;

  /// 获取任务运行时长
  Duration get runningDuration {
    final endTime = timestamps.completedAt ?? DateTime.now();
    return endTime.difference(timestamps.createdAt);
  }

  /// 获取任务等待时长 (从创建到开始处理的时间)
  Duration? get waitingDuration {
    if (timestamps.completedAt == null) return null;
    // 假设处理时长 = 完成时间 - 更新时间的一半
    final estimatedProcessingStart = timestamps.createdAt.add(
      timestamps.updatedAt.difference(timestamps.createdAt) ~/ 2,
    );
    return estimatedProcessingStart.difference(timestamps.createdAt);
  }

  /// 是否超时 (运行时间超过预期)
  bool isTimeout(Duration expectedDuration) {
    return runningDuration > expectedDuration;
  }

  /// 获取进度百分比文本
  String get progressText => '${progress.percentage}%';

  /// 是否接近完成 (进度 >= 90%)
  bool get isNearlyComplete => progress.percentage >= 90;
}

/// 任务状态值对象
enum TaskState {
  queued, // 排队中
  processing, // 处理中
  completed, // 已完成
  failed, // 失败
  cancelled; // 已取消

  static TaskState fromString(String status) {
    switch (status.toLowerCase()) {
      case 'queued':
        return TaskState.queued;
      case 'processing':
        return TaskState.processing;
      case 'completed':
        return TaskState.completed;
      case 'failed':
        return TaskState.failed;
      case 'cancelled':
        return TaskState.cancelled;
      default:
        return TaskState.queued;
    }
  }

  @override
  String toString() => name;
}

/// 任务结果值对象
class TaskResult {
  final String? planId; // 旅行计划ID (兼容旧版)
  final String? guideId; // 数字游民指南ID
  final Map<String, dynamic>? rawData; // 通用结果数据

  TaskResult({
    this.planId,
    this.guideId,
    this.rawData,
  });

  /// 是否有旅行计划结果
  bool get hasPlan => planId != null;

  /// 是否有指南结果
  bool get hasGuide => guideId != null;

  /// 是否有原始数据
  bool get hasRawData => rawData != null && rawData!.isNotEmpty;

  /// 是否为空结果
  bool get isEmpty => planId == null && guideId == null && !hasRawData;
}

/// 任务进度值对象
class TaskProgress {
  final int percentage; // 0-100
  final String? message; // 进度消息
  final int estimatedTimeSeconds; // 预估剩余时间(秒)

  TaskProgress({
    required this.percentage,
    this.message,
    required this.estimatedTimeSeconds,
  });

  /// 验证进度值有效性
  bool get isValid => percentage >= 0 && percentage <= 100;

  /// 获取预估剩余时间
  Duration get estimatedRemainingTime =>
      Duration(seconds: estimatedTimeSeconds);

  /// 是否有进度消息
  bool get hasMessage => message != null && message!.isNotEmpty;

  /// 获取进度描述
  String get description {
    if (hasMessage) {
      return '$message ($percentage%)';
    }
    return '$percentage%';
  }

  /// 是否已完成
  bool get isComplete => percentage >= 100;

  /// 是否刚开始 (进度 < 10%)
  bool get isJustStarted => percentage < 10;

  /// 是否进行中 (10% <= 进度 < 90%)
  bool get isInProgress => percentage >= 10 && percentage < 90;
}

/// 任务时间戳值对象
class TaskTimestamps {
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 最后更新时间
  final DateTime? completedAt; // 完成时间

  TaskTimestamps({
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// 获取任务总耗时
  Duration? get totalDuration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  /// 获取最后更新距今时间
  Duration get timeSinceLastUpdate {
    return DateTime.now().difference(updatedAt);
  }

  /// 任务是否长时间未更新 (超过指定时长)
  bool isStale(Duration staleDuration) {
    return timeSinceLastUpdate > staleDuration;
  }

  /// 格式化总耗时
  String? get formattedTotalDuration {
    final duration = totalDuration;
    if (duration == null) return null;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// 任务创建响应值对象
/// 用于表示任务创建成功后的初始状态
class TaskCreationResponse {
  final String taskId;
  final TaskState initialState;
  final int estimatedTimeSeconds;
  final String message;

  TaskCreationResponse({
    required this.taskId,
    required this.initialState,
    required this.estimatedTimeSeconds,
    required this.message,
  });

  /// 获取预估完成时间
  DateTime get estimatedCompletionTime {
    return DateTime.now().add(Duration(seconds: estimatedTimeSeconds));
  }

  /// 格式化预估时间
  String get formattedEstimatedTime {
    final minutes = estimatedTimeSeconds ~/ 60;
    final seconds = estimatedTimeSeconds % 60;
    if (minutes > 0) {
      return '$minutes 分 $seconds 秒';
    }
    return '$seconds 秒';
  }
}
