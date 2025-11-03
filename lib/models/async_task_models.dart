/// 异步任务响应模型
class CreateTaskResponse {
  final String taskId;
  final String status;
  final int estimatedTimeSeconds;
  final String message;

  CreateTaskResponse({
    required this.taskId,
    required this.status,
    required this.estimatedTimeSeconds,
    required this.message,
  });

  factory CreateTaskResponse.fromJson(Map<String, dynamic> json) {
    return CreateTaskResponse(
      taskId: json['taskId'] as String,
      status: json['status'] as String,
      estimatedTimeSeconds: json['estimatedTimeSeconds'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'status': status,
      'estimatedTimeSeconds': estimatedTimeSeconds,
      'message': message,
    };
  }
}

/// 任务状态模型
class TaskStatus {
  final String taskId;
  final String status; // queued, processing, completed, failed
  final String? planId; // 旅行计划ID (兼容旧版)
  final String? guideId; // 数字游民指南ID
  final Map<String, dynamic>? result; // 通用结果数据
  final String? error;
  final int progress; // 0-100
  final String? progressMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  TaskStatus({
    required this.taskId,
    required this.status,
    this.planId,
    this.guideId,
    this.result,
    this.error,
    required this.progress,
    this.progressMessage,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      taskId: json['taskId'] as String,
      status: json['status'] as String,
      planId: json['planId'] as String?,
      guideId: json['guideId'] as String?,
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      progress: json['progress'] as int,
      progressMessage: json['progressMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'status': status,
      'planId': planId,
      'guideId': guideId,
      'result': result,
      'error': error,
      'progress': progress,
      'progressMessage': progressMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// 是否已完成
  bool get isCompleted => status == 'completed';

  /// 是否失败
  bool get isFailed => status == 'failed';

  /// 是否处理中
  bool get isProcessing => status == 'processing';

  /// 是否排队中
  bool get isQueued => status == 'queued';
}
