import 'dart:developer';

import 'dart:convert';

import 'package:go_nomads_app/features/async_task/domain/entities/async_task.dart';

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
    // 支持 camelCase 和 PascalCase 字段名
    final taskId = json['taskId'] as String? ?? json['TaskId'] as String? ?? '';
    final status = json['status'] as String? ?? json['Status'] as String? ?? 'unknown';
    final planId = json['planId'] as String? ?? json['PlanId'] as String?;
    final guideId = json['guideId'] as String? ?? json['GuideId'] as String?;

    // result 字段可能是 Map 或 JSON 字符串，需要兼容处理
    Map<String, dynamic>? result;
    final rawResult = json['result'] ?? json['Result'];
    if (rawResult != null) {
      if (rawResult is Map<String, dynamic>) {
        result = rawResult;
      } else if (rawResult is String) {
        // 后端可能返回 JSON 字符串，需要解析
        try {
          result = jsonDecode(rawResult) as Map<String, dynamic>;
        } catch (e) {
          log('⚠️ 解析 result JSON 字符串失败: $e');
          result = null;
        }
      }
    }

    final error = json['error'] as String? ?? json['Error'] as String?;

    // Progress 字段支持多种格式
    int progress = 0;
    if (json['progress'] != null) {
      progress = (json['progress'] as num).toInt();
    } else if (json['Progress'] != null) {
      progress = (json['Progress'] as num).toInt();
    }

    // ProgressMessage 字段支持多种格式
    String? progressMessage;
    if (json['progressMessage'] != null) {
      progressMessage = json['progressMessage'] as String;
    } else if (json['ProgressMessage'] != null) {
      progressMessage = json['ProgressMessage'] as String;
    } else if (json['currentStep'] != null) {
      progressMessage = json['currentStep'] as String;
    } else if (json['CurrentStep'] != null) {
      progressMessage = json['CurrentStep'] as String;
    }

    return AsyncTaskDto(
      taskId: taskId,
      status: status,
      planId: planId,
      guideId: guideId,
      result: result,
      error: error,
      progress: progress,
      progressMessage: progressMessage,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt'] as String) : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt'] as String) : DateTime.now()),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : (json['CompletedAt'] != null ? DateTime.parse(json['CompletedAt'] as String) : null),
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
        status: status, // 使用 status 字段
      ),
      timestamps: TaskTimestamps(
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
      ),
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
}
