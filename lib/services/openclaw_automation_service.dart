import 'dart:convert';
import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// OpenClaw 执行结果
class OpenClawResult {
  final bool success;
  final String? data;
  final String? error;
  final bool isMembershipRequired;

  const OpenClawResult({
    required this.success,
    this.data,
    this.error,
    this.isMembershipRequired = false,
  });

  factory OpenClawResult.fromJson(Map<String, dynamic> json) {
    return OpenClawResult(
      success: json['success'] ?? false,
      data: json['data']?.toString(),
      error: json['message']?.toString() ?? json['error']?.toString(),
    );
  }
}

/// OpenClaw 自动化服务
/// 通过后端 API 与 OpenClaw Gateway 通信，执行自然语言指令和预设自动化场景
class OpenClawAutomationService {
  final HttpService _httpService;

  OpenClawAutomationService({
    HttpService? httpService,
  }) : _httpService = httpService ?? HttpService();

  /// 安全解析响应数据为 Map
  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      // 尝试 JSON 解析，若为纯文本则包装为成功结果
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } on FormatException {
        return {'success': true, 'data': data};
      }
    }
    throw FormatException('Unexpected response type: ${data.runtimeType}');
  }

  /// 执行自然语言指令
  Future<OpenClawResult> executeCommand(String command, {String? sessionId}) async {
    try {
      log('🤖 OpenClaw 执行指令: $command');

      final response = await _httpService.post(
        ApiConfig.openClawExecuteEndpoint,
        data: {
          'command': command,
          if (sessionId != null) 'sessionId': sessionId,
        },
      );

      return OpenClawResult.fromJson(_parseResponse(response.data));
    } catch (e, stack) {
      log('❌ OpenClaw 执行失败: $e\n$stack');
      return _handleError(e);
    }
  }

  /// 设置提醒
  Future<OpenClawResult> setReminder(String text, DateTime triggerTime) async {
    try {
      log('🔔 OpenClaw 设置提醒: $text @ $triggerTime');

      final response = await _httpService.post(
        ApiConfig.openClawReminderEndpoint,
        data: {
          'text': text,
          'triggerTime': triggerTime.toIso8601String(),
        },
      );

      return OpenClawResult.fromJson(_parseResponse(response.data));
    } catch (e, stack) {
      log('❌ OpenClaw 设置提醒失败: $e\n$stack');
      return _handleError(e);
    }
  }

  /// 设置签证到期提醒
  Future<OpenClawResult> setVisaReminder(String country, DateTime expiryDate) async {
    try {
      log('🛂 OpenClaw 设置签证提醒: $country 到期 $expiryDate');

      final response = await _httpService.post(
        ApiConfig.openClawVisaReminderEndpoint,
        data: {
          'country': country,
          'expiryDate': expiryDate.toIso8601String(),
        },
      );

      return OpenClawResult.fromJson(_parseResponse(response.data));
    } catch (e, stack) {
      log('❌ OpenClaw 设置签证提醒失败: $e\n$stack');
      return _handleError(e);
    }
  }

  /// 整理发票并发送到指定邮箱
  Future<OpenClawResult> organizeInvoices(String email) async {
    try {
      log('🧾 OpenClaw 整理发票: 发送到 $email');

      final response = await _httpService.post(
        ApiConfig.openClawInvoiceEndpoint,
        data: {
          'email': email,
        },
      );

      return OpenClawResult.fromJson(_parseResponse(response.data));
    } catch (e, stack) {
      log('❌ OpenClaw 整理发票失败: $e\n$stack');
      return _handleError(e);
    }
  }

  /// 创建定时自动化脚本
  Future<OpenClawResult> createScheduledScript(String command, {String? schedule}) async {
    try {
      log('⚙️ OpenClaw 创建脚本: $command ${schedule != null ? '@ $schedule' : ''}');

      final response = await _httpService.post(
        ApiConfig.openClawScriptEndpoint,
        data: {
          'command': command,
          if (schedule != null) 'schedule': schedule,
        },
      );

      return OpenClawResult.fromJson(_parseResponse(response.data));
    } catch (e, stack) {
      log('❌ OpenClaw 创建脚本失败: $e\n$stack');
      return _handleError(e);
    }
  }

  /// 执行预设自动化场景
  Future<OpenClawResult> runAutomation(
    AutomationScenario scenario,
    Map<String, String> params,
  ) async {
    try {
      log('⚡ OpenClaw 执行场景: ${scenario.name}');

      final endpoint = ApiConfig.buildUrl(
        ApiConfig.openClawAutomationEndpoint,
        {'scenario': scenario.name},
      );

      final response = await _httpService.post(
        endpoint,
        data: params,
      );

      return OpenClawResult.fromJson(_parseResponse(response.data));
    } catch (e, stack) {
      log('❌ OpenClaw 执行场景失败: $e\n$stack');
      return _handleError(e);
    }
  }

  /// 统一错误处理，识别会员权限不足的情况
  OpenClawResult _handleError(Object e) {
    if (e is HttpException && (e.statusCode == 403 || e.statusCode == 401)) {
      return OpenClawResult(
        success: false,
        error: e.statusCode == 403 ? 'OpenClaw 自动化功能仅对会员开放，请先开通会员' : '请先登录后使用',
        isMembershipRequired: e.statusCode == 403,
      );
    }
    return OpenClawResult(
      success: false,
      error: e.toString(),
    );
  }
}
