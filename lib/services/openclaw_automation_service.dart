import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// OpenClaw 执行结果
class OpenClawResult {
  final bool success;
  final String? data;
  final String? error;

  const OpenClawResult({
    required this.success,
    this.data,
    this.error,
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

      return OpenClawResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stack) {
      log('❌ OpenClaw 执行失败: $e\n$stack');
      return OpenClawResult(
        success: false,
        error: e.toString(),
      );
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

      return OpenClawResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stack) {
      log('❌ OpenClaw 设置提醒失败: $e\n$stack');
      return OpenClawResult(
        success: false,
        error: e.toString(),
      );
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

      return OpenClawResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stack) {
      log('❌ OpenClaw 设置签证提醒失败: $e\n$stack');
      return OpenClawResult(
        success: false,
        error: e.toString(),
      );
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

      return OpenClawResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stack) {
      log('❌ OpenClaw 执行场景失败: $e\n$stack');
      return OpenClawResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}
