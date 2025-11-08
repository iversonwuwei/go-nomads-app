import '../../../../models/async_task_models.dart' as legacy;
import '../../domain/entities/async_task.dart';

/// AsyncTask DTO - 基础设施层数据传输对象
class AsyncTaskDto {
  final String taskId;
  final String status;
  final String? planId;
  final String? guideId;
  final Map<String, dynamic>? result;
  final String? error;
  final int progress;
  final String? progressMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  AsyncTaskDto({
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

  factory AsyncTaskDto.fromJson(Map<String, dynamic> json) {
    return AsyncTaskDto(
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

  /// 转换为领域实体
  AsyncTask toDomain({int estimatedTimeSeconds = 0}) {
    return AsyncTask(
      taskId: taskId,
      state: TaskState.fromString(status),
      result: result != null || planId != null || guideId != null
          ? TaskResult(
              planId: planId,
              guideId: guideId,
              rawData: result,
            )
          : null,
      error: error,
      progress: TaskProgress(
        percentage: progress,
        message: progressMessage,
        estimatedTimeSeconds: estimatedTimeSeconds,
      ),
      timestamps: TaskTimestamps(
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
      ),
    );
  }

  /// 从旧模型转换 (TaskStatus)
  factory AsyncTaskDto.fromLegacyModel(legacy.TaskStatus model) {
    return AsyncTaskDto(
      taskId: model.taskId,
      status: model.status,
      planId: model.planId,
      guideId: model.guideId,
      result: model.result,
      error: model.error,
      progress: model.progress,
      progressMessage: model.progressMessage,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      completedAt: model.completedAt,
    );
  }
}

/// TaskCreation DTO - 任务创建响应
class TaskCreationDto {
  final String taskId;
  final String status;
  final int estimatedTimeSeconds;
  final String message;

  TaskCreationDto({
    required this.taskId,
    required this.status,
    required this.estimatedTimeSeconds,
    required this.message,
  });

  factory TaskCreationDto.fromJson(Map<String, dynamic> json) {
    return TaskCreationDto(
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

  /// 转换为领域值对象
  TaskCreationResponse toDomain() {
    return TaskCreationResponse(
      taskId: taskId,
      initialState: TaskState.fromString(status),
      estimatedTimeSeconds: estimatedTimeSeconds,
      message: message,
    );
  }

  /// 从旧模型转换
  factory TaskCreationDto.fromLegacyModel(legacy.CreateTaskResponse model) {
    return TaskCreationDto(
      taskId: model.taskId,
      status: model.status,
      estimatedTimeSeconds: model.estimatedTimeSeconds,
      message: model.message,
    );
  }
}
