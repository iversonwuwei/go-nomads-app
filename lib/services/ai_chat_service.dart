import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// AI Chat 对话信息
class AiConversation {
  final String id;
  final String title;
  final String status;
  final String modelName;
  final String? systemPrompt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AiConversation({
    required this.id,
    required this.title,
    required this.status,
    required this.modelName,
    this.systemPrompt,
    this.createdAt,
    this.updatedAt,
  });

  factory AiConversation.fromJson(Map<String, dynamic> json) {
    return AiConversation(
      id: _readString(json, ['id', 'Id']),
      title: _readString(json, ['title', 'Title'], fallback: ''),
      status: _readString(json, ['status', 'Status'], fallback: 'active'),
      modelName: _readString(json, ['modelName', 'ModelName'], fallback: ''),
      systemPrompt: _readStringOrNull(json, ['systemPrompt', 'SystemPrompt']),
      createdAt: _parseDate(json, ['createdAt', 'CreatedAt']),
      updatedAt: _parseDate(json, ['updatedAt', 'UpdatedAt']),
    );
  }
}

/// AI Chat 消息
class AiMessage {
  final String? id;
  final String role; // user | assistant | system
  final String content;
  final bool isError;
  final DateTime? createdAt;

  const AiMessage({
    this.id,
    required this.role,
    required this.content,
    this.createdAt,
    this.isError = false,
  });

  bool get isUser => role.toLowerCase() == 'user';
  bool get isAssistant => role.toLowerCase() == 'assistant';

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: _readStringOrNull(json, ['id', 'Id']),
      role: _readString(json, ['role', 'Role'], fallback: 'assistant'),
      content: _readString(json, ['content', 'Content'], fallback: ''),
      isError: _readBool(json, ['isError', 'IsError']),
      createdAt: _parseDate(json, ['createdAt', 'CreatedAt']),
    );
  }
}

/// AI Chat 流式分片
class AiStreamChunk {
  final String delta;
  final bool isComplete;
  final String? finishReason;
  final int? tokenCount;
  final String? error;

  const AiStreamChunk({
    required this.delta,
    required this.isComplete,
    this.finishReason,
    this.tokenCount,
    this.error,
  });

  bool get hasError => (error ?? '').isNotEmpty;

  factory AiStreamChunk.fromJson(Map<String, dynamic> json) {
    return AiStreamChunk(
      delta: _readString(json, ['delta', 'Delta'], fallback: ''),
      isComplete: _readBool(json, ['isComplete', 'IsComplete']),
      finishReason: _readStringOrNull(json, ['finishReason', 'FinishReason']),
      tokenCount: _readInt(json, ['tokenCount', 'TokenCount']),
      error: _readStringOrNull(json, ['error', 'Error']),
    );
  }
}

/// AI Chat Service - 对接 AIService 的 REST + 流式接口
class AiChatService {
  final HttpService _http;

  AiChatService({HttpService? httpService}) : _http = httpService ?? HttpService();

  /// 获取对话列表（当前仅取第一页，供重用最新对话）
  Future<List<AiConversation>> getConversations({int page = 1, int pageSize = 10}) async {
    final url = ApiConfig.buildUrl(ApiConfig.aiConversationsEndpoint);
    final response = await _http.get(url, queryParameters: {
      'page': page,
      'pageSize': pageSize,
      'status': 'active',
    });

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final list = (data['data'] ?? data['Data'] ?? []) as List<dynamic>;
      return list.map((e) => AiConversation.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  /// 创建新对话
  Future<AiConversation> createConversation({
    required String title,
    String? systemPrompt,
    String modelName = 'qwen-plus',
  }) async {
    final url = ApiConfig.buildUrl(ApiConfig.aiConversationsEndpoint);
    final response = await _http.post(url, data: {
      'title': title,
      'systemPrompt': systemPrompt,
      'modelName': modelName,
    });

    final data = Map<String, dynamic>.from(response.data as Map);
    return AiConversation.fromJson(data);
  }

  /// 获取消息历史
  Future<List<AiMessage>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 40,
  }) async {
    final url = ApiConfig.buildUrl(
      ApiConfig.aiMessagesEndpoint,
      {'conversationId': conversationId},
    );

    final response = await _http.get(url, queryParameters: {
      'page': page,
      'pageSize': pageSize,
      'includeSystem': false,
    });

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final list = (data['data'] ?? data['Data'] ?? []) as List<dynamic>;
      return list.map((e) => AiMessage.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  /// 发送消息并读取流式结果（AIService 的 /messages/stream）
  Stream<AiStreamChunk> sendMessageStream({
    required String conversationId,
    required String content,
    String? modelName,
    double temperature = 0.7,
    int maxTokens = 1200,
  }) async* {
    final url = ApiConfig.buildUrl(
      ApiConfig.aiMessageStreamEndpoint,
      {'conversationId': conversationId},
    );

    try {
      final response = await _http.post<ResponseBody>(
        url,
        data: {
          'content': content,
          'stream': true,
          'modelName': modelName,
          'temperature': temperature,
          'maxTokens': maxTokens,
        },
        options: Options(
          responseType: ResponseType.stream,
          // 禁止响应拦截器自动 unwrap，保留原始流
          extra: {HttpService.disableApiResponseUnwrapKey: true},
          headers: {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      final byteStream = response.data?.stream
          .map<List<int>>((chunk) => chunk)
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      if (byteStream == null) {
        yield const AiStreamChunk(delta: '', isComplete: true, error: '无法建立流式连接');
        return;
      }

      await for (final line in byteStream) {
        if (line.trim().isEmpty) continue;
        try {
          final decoded = jsonDecode(line);
          // 处理数组格式（后端可能返回 JSON 数组）
          if (decoded is List) {
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                yield AiStreamChunk.fromJson(item);
              }
            }
          } else if (decoded is Map<String, dynamic>) {
            yield AiStreamChunk.fromJson(decoded);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⛔️ AI stream decode error: $e | line: $line');
          }
        }
      }
    } on DioException catch (e) {
      final message = e.message ?? '发送消息失败';
      yield AiStreamChunk(delta: '', isComplete: true, error: message);
    } catch (e) {
      yield AiStreamChunk(delta: '', isComplete: true, error: e.toString());
    }
  }

  /// 发送消息（使用 SignalR 流式响应）
  /// 返回请求 ID，用于关联 SignalR 响应
  Future<SignalRStreamResponse> sendMessageWithSignalR({
    required String conversationId,
    required String content,
    String? requestId,
    double temperature = 0.7,
    int maxTokens = 1200,
  }) async {
    final url = ApiConfig.buildUrl(
      ApiConfig.aiMessageSignalRStreamEndpoint,
      {'conversationId': conversationId},
    );

    final response = await _http.post(url, data: {
      'content': content,
      'requestId': requestId,
      'temperature': temperature,
      'maxTokens': maxTokens,
    });

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SignalRStreamResponse.fromJson(data);
    }
    throw Exception('发送消息失败：无效响应');
  }
}

/// SignalR 流式响应结果
class SignalRStreamResponse {
  final String requestId;
  final AiMessage? userMessage;
  final String signalREvent;

  SignalRStreamResponse({
    required this.requestId,
    this.userMessage,
    required this.signalREvent,
  });

  factory SignalRStreamResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['Data'] ?? json;
    return SignalRStreamResponse(
      requestId: _readString(data as Map<String, dynamic>, ['requestId', 'RequestId']),
      userMessage: data['userMessage'] != null || data['UserMessage'] != null
          ? AiMessage.fromJson(Map<String, dynamic>.from(data['userMessage'] ?? data['UserMessage']))
          : null,
      signalREvent: _readString(data, ['signalREvent', 'SignalREvent'], fallback: 'AIChatChunk'),
    );
  }
}

// ================== 工具方法 ==================
String _readString(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
    if (value != null) return value.toString();
  }
  return fallback;
}

String? _readStringOrNull(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    if (value != null) return value.toString();
  }
  return null;
}

bool _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value != 0;
  }
  return false;
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

DateTime? _parseDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed.toLocal();
    }
  }
  return null;
}
