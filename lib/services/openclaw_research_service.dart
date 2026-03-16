import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  final String gatewayUrl;
  final String? gatewayToken;

  OpenClawResearchService({
    String? gatewayUrl,
    String? gatewayToken,
  })  : gatewayUrl = _normalizeGatewayUrl(gatewayUrl ?? ApiConfig.openClawGatewayUrl),
        gatewayToken = _trimToNull(gatewayToken ?? ApiConfig.openClawGatewayToken);

  bool get isConfigured => gatewayUrl.isNotEmpty;

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
    if (!isConfigured) {
      return null;
    }

    final gatewayClient = _OpenClawGatewayClient(
      gatewayUrl: gatewayUrl,
      gatewayToken: gatewayToken,
    );

    final sessionKey =
        'travel-plan-${cityName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${DateTime.now().millisecondsSinceEpoch}';
    final requestId = 'travel-plan-research-${DateTime.now().microsecondsSinceEpoch}';

    try {
      await gatewayClient.connect();

      await gatewayClient.request(
        'chat.send',
        {
          'sessionKey': sessionKey,
          'message': _buildPrompt(
            cityName: cityName,
            duration: duration,
            budget: budget,
            travelStyle: travelStyle,
            planningMode: planningMode,
            planningObjective: planningObjective,
            researchSignals: researchSignals,
            interests: interests,
            departureLocation: departureLocation,
            departureDate: departureDate,
          ),
          'thinking': planningMode == 'research' ? 'high' : 'medium',
          'deliver': false,
          'timeoutMs': 60000,
          'idempotencyKey': requestId,
        },
      );

      final assistantReply = await _pollAssistantReply(
        gatewayClient,
        sessionKey: sessionKey,
        timeout: const Duration(seconds: 35),
      );

      if (assistantReply == null || assistantReply.trim().isEmpty) {
        return null;
      }

      return _parseBrief(sessionKey, assistantReply);
    } catch (error, stackTrace) {
      log('OpenClaw 研究失败: $error', stackTrace: stackTrace);
      return null;
    } finally {
      await gatewayClient.dispose();
    }
  }

  Future<String?> _pollAssistantReply(
    _OpenClawGatewayClient gatewayClient, {
    required String sessionKey,
    required Duration timeout,
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final history = await gatewayClient.request(
        'chat.history',
        {
          'sessionKey': sessionKey,
          'limit': 12,
        },
      );

      final assistantReply = _extractLatestAssistantReply(history);
      if (assistantReply != null && assistantReply.trim().isNotEmpty) {
        return assistantReply;
      }

      await Future.delayed(const Duration(milliseconds: 1500));
    }

    return null;
  }

  String? _extractLatestAssistantReply(dynamic history) {
    if (history is! Map) {
      return null;
    }

    final messages = history['messages'];
    if (messages is! List) {
      return null;
    }

    for (final message in messages.reversed) {
      if (message is! Map) {
        continue;
      }

      if ((message['role'] ?? '').toString() != 'assistant') {
        continue;
      }

      final content = message['content'];
      if (content is! List) {
        continue;
      }

      final buffer = StringBuffer();
      for (final part in content) {
        if (part is! Map) {
          continue;
        }

        if ((part['type'] ?? '').toString() == 'text') {
          final text = (part['text'] ?? '').toString();
          if (text.isNotEmpty) {
            if (buffer.isNotEmpty) {
              buffer.write('\n');
            }
            buffer.write(text);
          }
        }
      }

      if (buffer.isNotEmpty) {
        return buffer.toString();
      }
    }

    return null;
  }

  OpenClawResearchBrief _parseBrief(String sessionKey, String rawReply) {
    final normalized = _stripMarkdownFence(rawReply).trim();

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is Map<String, dynamic>) {
        final summary = (decoded['summary'] ?? '').toString().trim();
        final insights = _stringListFrom(decoded['insights']);
        final checks = _stringListFrom(decoded['checks']);

        return OpenClawResearchBrief(
          sessionKey: sessionKey,
          summary: summary.isEmpty ? 'OpenClaw 已完成研究预处理。' : summary,
          insights: insights,
          checks: checks,
          rawResponse: rawReply,
        );
      }
    } catch (_) {
      // 回退到纯文本摘要。
    }

    return OpenClawResearchBrief(
      sessionKey: sessionKey,
      summary: normalized,
      insights: const [],
      checks: const [],
      rawResponse: rawReply,
    );
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

  String _buildPrompt({
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
  }) {
    final normalizedSignals = researchSignals.isEmpty ? _defaultSignalsForMode(planningMode) : researchSignals;
    final cleanedInterests = interests.where((item) => !item.startsWith('openclaw_')).toList();

    final buffer = StringBuffer()
      ..writeln('你是 Go Nomads 的 OpenClaw 旅行研究层。')
      ..writeln('目标不是直接输出完整 itinerary，而是给下游 AI 旅行规划生成一个高质量、可执行的研究摘要。')
      ..writeln('请只返回 JSON，不要 Markdown，不要代码块，不要额外解释。')
      ..writeln('你的职责是先做策略判断，再给出压缩后的研究信号，供后续 itinerary 生成模型直接消费。')
      ..writeln('JSON schema:')
      ..writeln('{')
      ..writeln('  "summary": "一句中文摘要，80字内，必须体现模式和目标",')
      ..writeln('  "insights": ["3条以内的关键信号，每条32字内，必须具体，不要空话"],')
      ..writeln('  "checks": ["3条以内的落地核对项，每条32字内，必须可执行"]')
      ..writeln('}')
      ..writeln('')
      ..writeln('用户输入:')
      ..writeln('- 城市: $cityName')
      ..writeln('- 天数: $duration')
      ..writeln('- 预算: $budget')
      ..writeln('- 风格: $travelStyle')
      ..writeln('- 规划模式: $planningMode')
      ..writeln('- 规划目标: $planningObjective')
      ..writeln('- 研究信号: ${normalizedSignals.join('、')}')
      ..writeln('- 兴趣偏好: ${cleanedInterests.isEmpty ? '无' : cleanedInterests.join('、')}')
      ..writeln('- 出发地: ${_trimToNull(departureLocation) ?? '未提供'}')
      ..writeln('- 出发日期: ${departureDate?.toIso8601String() ?? '未提供'}')
      ..writeln('')
      ..writeln('模式约束:')
      ..writeln(_planningModeInstruction(planningMode))
      ..writeln('')
      ..writeln('目标约束:')
      ..writeln(_planningObjectiveInstruction(planningObjective))
      ..writeln('')
      ..writeln('信号优先级:')
      ..writeln(_researchSignalInstruction(normalizedSignals))
      ..writeln('')
      ..writeln('输出规则:')
      ..writeln('1. summary 必须先说清楚这一版路线应该偏向什么，不要重复输入字段。')
      ..writeln('2. insights 必须给下游 itinerary 模型真正有用的约束，例如节奏、区域、时段、预算风险、天气风险、办公可行性。')
      ..writeln('3. checks 必须是出行前或排程时要核对的动作，不要写成泛泛建议。')
      ..writeln('4. 如果模式是 quick，就少写核对项，优先保留方向判断。')
      ..writeln('5. 如果模式是 research，就把实时信号和不确定性写清楚，让下游模型显式做兜底。')
      ..writeln('6. 不要输出景点长名单，不要写完整行程，不要解释推理过程。')
      ..writeln('7. 输出必须可直接给另一个 AI 作为规划前置信号。');

    return buffer.toString();
  }

  List<String> _defaultSignalsForMode(String planningMode) {
    switch (planningMode) {
      case 'quick':
        return const ['weather', 'transit'];
      case 'research':
        return const ['weather', 'events', 'coworking', 'transit', 'budget'];
      default:
        return const ['weather', 'events', 'budget'];
    }
  }

  String _planningModeInstruction(String planningMode) {
    switch (planningMode) {
      case 'quick':
        return '你在 quick 模式下要优先给出方向判断和高风险提醒，减少展开，不做过重研究；结论要利于快速生成首稿。';
      case 'research':
        return '你在 research 模式下要更重视实时信号、潜在冲突、备选方案和排程不确定性；输出要像严谨的前置 briefing。';
      default:
        return '你在 balanced 模式下要在效率、体验、预算与执行可行性之间折中，不偏向极端保守或极端激进。';
    }
  }

  String _planningObjectiveInstruction(String planningObjective) {
    switch (planningObjective) {
      case 'work':
        return '重点审视共享办公质量、安静时段、通勤切换成本、白天专注窗口，以及娱乐安排是否打断工作节奏。';
      case 'explore':
        return '重点审视街区漫游、城市代表性体验、本地活动密度、天气对探索体验的影响，以及是否过度模板化。';
      default:
        return '同时兼顾工作可持续性与城市体验，避免两者互相挤压到不可执行。';
    }
  }

  String _researchSignalInstruction(List<String> signals) {
    final descriptions = signals.map((signal) => switch (signal) {
          'weather' => '天气: 判断户外活动是否需要备选和时段调整',
          'events' => '活动: 判断是否值得插入本地活动或避开拥挤时段',
          'coworking' => '办公: 判断远程工作落点是否稳定',
          'transit' => '交通: 判断跨区切换和日内动线是否过重',
          'visa' => '签证: 判断入境或停留限制是否影响路线安排',
          'budget' => '预算: 判断当前预算与天数/体验级别是否失衡',
          _ => '$signal: 若相关则纳入判断'
        });

    return descriptions.join('；');
  }

  static String _normalizeGatewayUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    if (trimmed.startsWith('ws://') || trimmed.startsWith('wss://')) {
      return trimmed.replaceFirst(RegExp(r'/+$'), '');
    }

    if (trimmed.startsWith('http://')) {
      return 'ws://${trimmed.substring('http://'.length)}'.replaceFirst(RegExp(r'/+$'), '');
    }

    if (trimmed.startsWith('https://')) {
      return 'wss://${trimmed.substring('https://'.length)}'.replaceFirst(RegExp(r'/+$'), '');
    }

    return 'ws://${trimmed.replaceFirst(RegExp(r'/+$'), '')}';
  }

  static String _stripMarkdownFence(String value) {
    final trimmed = value.trim();
    if (!trimmed.startsWith('```')) {
      return trimmed;
    }

    return trimmed.replaceFirst(RegExp(r'^```[a-zA-Z0-9_-]*\s*'), '').replaceFirst(RegExp(r'\s*```$'), '');
  }

  static String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

class _OpenClawGatewayClient {
  final String gatewayUrl;
  final String? gatewayToken;
  static const Duration _connectTimeout = Duration(seconds: 15);

  late final WebSocketChannel _channel;
  final Map<String, Completer<dynamic>> _pending = {};
  late final StreamSubscription _subscription;
  final Completer<void> _connectedCompleter = Completer<void>();
  final Set<String> _sentConnectKeys = <String>{};
  bool _isConnected = false;

  _OpenClawGatewayClient({
    required this.gatewayUrl,
    required this.gatewayToken,
  });

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(gatewayUrl));
    _subscription = _channel.stream.listen(
      _handleMessage,
      onError: (Object error, StackTrace stackTrace) {
        if (!_connectedCompleter.isCompleted) {
          _connectedCompleter.completeError(error, stackTrace);
        }
        _failPending(error);
      },
      onDone: () {
        final error = StateError('OpenClaw gateway disconnected');
        if (!_connectedCompleter.isCompleted) {
          _connectedCompleter.completeError(error);
        }
        _failPending(error);
      },
      cancelOnError: true,
    );

    _sendConnectRequest();

    await _connectedCompleter.future.timeout(
      _connectTimeout,
      onTimeout: () {
        throw TimeoutException(
          'OpenClaw connect timeout after ${_connectTimeout.inSeconds}s: $gatewayUrl',
        );
      },
    );
  }

  Future<dynamic> request(String method, Map<String, dynamic> params) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final completer = Completer<dynamic>();
    _pending[id] = completer;

    _channel.sink.add(
      jsonEncode(
        {
          'type': 'req',
          'id': id,
          'method': method,
          'params': params,
        },
      ),
    );

    return completer.future.timeout(const Duration(seconds: 70), onTimeout: () {
      _pending.remove(id);
      throw TimeoutException('OpenClaw request timeout: $method');
    });
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _channel.sink.close();
  }

  void _handleMessage(dynamic raw) {
    final text = raw?.toString();
    if (text == null || text.isEmpty) {
      return;
    }

    dynamic parsed;
    try {
      parsed = jsonDecode(text);
    } catch (_) {
      return;
    }

    if (parsed is! Map) {
      return;
    }

    final event = parsed['event']?.toString();
    if (event == 'connect.challenge') {
      final payload = parsed['payload'];
      final nonce = payload is Map ? payload['nonce']?.toString() : null;
      if (nonce == null || nonce.isEmpty) {
        if (!_connectedCompleter.isCompleted) {
          _connectedCompleter.completeError(StateError('OpenClaw connect challenge missing nonce'));
        }
        return;
      }

      _sendConnectRequest(nonce: nonce);
      return;
    }

    final id = parsed['id']?.toString();
    if (id == null) {
      return;
    }

    final completer = _pending.remove(id);
    if (completer == null) {
      return;
    }

    if (parsed['ok'] == true) {
      if (id.startsWith('connect-') && !_connectedCompleter.isCompleted) {
        _isConnected = true;
        _connectedCompleter.complete();
      }
      completer.complete(parsed['payload']);
      return;
    }

    final error = parsed['error'];
    final message = error is Map ? error['message']?.toString() : parsed['message']?.toString();
    completer.completeError(StateError(message ?? 'OpenClaw request failed'));
  }

  void _sendConnectRequest({String? nonce}) {
    if (_isConnected) {
      return;
    }

    final dedupeKey = nonce == null || nonce.isEmpty ? '__default__' : nonce;
    if (_sentConnectKeys.contains(dedupeKey)) {
      return;
    }
    _sentConnectKeys.add(dedupeKey);

    final connectId = 'connect-${DateTime.now().microsecondsSinceEpoch}';
    final completer = Completer<dynamic>();
    _pending[connectId] = completer;

    _channel.sink.add(
      jsonEncode(
        {
          'type': 'req',
          'id': connectId,
          'method': 'connect',
          'params': {
            'minProtocol': 3,
            'maxProtocol': 3,
            'client': {
              'id': 'go-nomads-app',
              'displayName': 'Go Nomads App',
              'version': '1.0.1',
              'platform': 'flutter',
              'mode': 'backend',
              'instanceId': 'travel-plan-openclaw',
            },
            'caps': <String>[],
            'role': 'operator',
            'scopes': const [
              'operator.admin',
              'operator.read',
              'operator.write',
              'operator.approvals',
              'operator.pairing',
            ],
            if (nonce != null && nonce.isNotEmpty) 'nonce': nonce,
            if (gatewayToken != null)
              'auth': {
                'token': gatewayToken,
              },
          },
        },
      ),
    );

    completer.future.then((_) {
      if (!_connectedCompleter.isCompleted) {
        _isConnected = true;
        _connectedCompleter.complete();
      }
    }).catchError((Object error, StackTrace stackTrace) {
      log('OpenClaw connect attempt failed: $error', stackTrace: stackTrace);
    });
  }

  void _failPending(Object error) {
    final pending = Map<String, Completer<dynamic>>.from(_pending);
    _pending.clear();
    for (final completer in pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
  }
}
