import 'dart:async';
import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/services/http_service.dart';

class OpenClawResearchBrief {
  final String sessionKey;
  final String summary;
  final List<String> insights;
  final List<String> checks;
  final String rawResponse;

  const OpenClawResearchBrief({
    required this.sessionKey,
    required this.summary,
    required this.insights,
    required this.checks,
    required this.rawResponse,
  });

  List<String> toInterestHints() {
    final hints = <String>[];

    final normalizedSummary = _normalizeHint(summary, maxLength: 120);
    if (normalizedSummary.isNotEmpty) {
      hints.add('openclaw_summary:$normalizedSummary');
    }

    for (final insight in insights.take(3)) {
      final normalized = _normalizeHint(insight, maxLength: 72);
      if (normalized.isNotEmpty) {
        hints.add('openclaw_insight:$normalized');
      }
    }

    for (final check in checks.take(3)) {
      final normalized = _normalizeHint(check, maxLength: 72);
      if (normalized.isNotEmpty) {
        hints.add('openclaw_check:$normalized');
      }
    }

    return hints;
  }

  static String _normalizeHint(String input, {required int maxLength}) {
    final collapsed = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.isEmpty) {
      return '';
    }

    if (collapsed.length <= maxLength) {
      return collapsed;
    }

    return '${collapsed.substring(0, maxLength - 1)}…';
  }
}

class OpenClawResearchService {
  final HttpService _httpService;

  OpenClawResearchService({
    HttpService? httpService,
  }) : _httpService = httpService ?? HttpService();

  bool get isConfigured => true;

  Future<OpenClawResearchBrief?> researchTravelPlan({
    required String cityName,
    required int duration,
    required String budget,
    required String travelStyle,
    required String planningMode,
    required String planningObjective,
    required List<String> researchSignals,
    required List<String> interests,
    String? departureLocation,
    DateTime? departureDate,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.aiOpenClawResearchEndpoint,
        data: {
          'cityName': cityName,
          'duration': duration,
          'budget': budget,
          'travelStyle': travelStyle,
          'planningMode': planningMode,
          'planningObjective': planningObjective,
          'researchSignals': researchSignals,
          'interests': interests,
          if (departureLocation != null) 'departureLocation': departureLocation,
          if (departureDate != null) 'departureDate': departureDate.toIso8601String(),
        },
      );

      final data = response.data;
      if (data is! Map) {
        return null;
      }

      final payload = Map<String, dynamic>.from(data);
      final summary = (payload['summary'] ?? '').toString().trim();
      if (summary.isEmpty) {
        return null;
      }

      return OpenClawResearchBrief(
        sessionKey: (payload['sessionKey'] ?? '').toString(),
        summary: summary,
        insights: _stringListFrom(payload['insights']),
        checks: _stringListFrom(payload['checks']),
        rawResponse: (payload['rawResponse'] ?? '').toString(),
      );
    } catch (error, stackTrace) {
      log('OpenClaw 代理研究失败: $error', stackTrace: stackTrace);
      return null;
    }
  }

  List<String> _stringListFrom(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item.toString().replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((item) => item.isNotEmpty)
        .take(3)
        .toList();
  }
}
