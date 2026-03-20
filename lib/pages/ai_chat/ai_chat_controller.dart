import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_planner_access_service.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/services/openclaw_automation_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:uuid/uuid.dart';

class AiChatController extends GetxController {
  AiChatController(
    this._aiChatService,
    this._authController,
    this._signalRService,
    this._openClawService,
  );

  final AiChatService _aiChatService;
  final AuthStateController _authController;
  final SignalRService _signalRService;
  final OpenClawAutomationService _openClawService;

  final Rxn<AiConversation> conversation = Rxn<AiConversation>();
  final RxList<AiMessage> messages = <AiMessage>[].obs;
  final RxList<AiConversation> historyConversations = <AiConversation>[].obs;
  final RxBool isHistoryLoading = false.obs;
  final RxMap<String, String> historyTitleOverrides = <String, String>{}.obs;
  final RxBool isInitializing = true.obs;
  final RxBool isStreaming = false.obs;
  final RxString streamingStatus = ''.obs;
  final RxBool hasInitError = false.obs;
  final RxString initErrorMessage = ''.obs;
  final RxBool showQuickActions = true.obs;
  final RxBool isOpenClawBusy = false.obs;

  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StreamSubscription? _taskProgressSub;
  StreamSubscription? _aiChatChunkSub;
  int? _streamingIndex;
  String? _currentRequestId;
  String? _pendingEmptyConversationId;

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  @override
  void onInit() {
    super.onInit();
    _connectSignalR();
    _bootstrap();
  }

  @override
  void onClose() {
    _taskProgressSub?.cancel();
    _aiChatChunkSub?.cancel();
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    try {
      isInitializing.value = true;
      hasInitError.value = false;
      initErrorMessage.value = '';

      // 初始化为空状态，不预加载历史对话
      // 用户可以直接开始新对话，或点击历史图标查看历史
      conversation.value = null;
      messages.clear();
    } catch (e, stack) {
      log('❌ 初始化 AI Chat 失败: $e\n$stack');
      hasInitError.value = true;
      initErrorMessage.value = _l10n.aiChatServiceUnavailable;
    } finally {
      isInitializing.value = false;
    }
  }

  /// 重试初始化（从 UI 调用）
  Future<void> retryInit() async {
    await _bootstrap();
  }

  Future<void> _connectSignalR() async {
    final userId = _authController.currentUser.value?.id;
    try {
      await _signalRService.connect(ApiConfig.messageServiceBaseUrl, userId: userId);
      if (userId != null) {
        await _signalRService.joinUserGroup(userId);
      }

      // 监听任务进度（用于显示状态）
      _taskProgressSub = _signalRService.taskProgressStream.listen((task) {
        if (task.progress.message != null && task.progress.message!.isNotEmpty) {
          streamingStatus.value = task.progress.message!;
        }
      });

      // 监听 AI Chat 流式响应
      _aiChatChunkSub = _signalRService.aiChatChunkStream.listen(_handleAIChatChunk);

      log('✅ SignalR 连接成功，已订阅 AIChatChunk 事件');
    } catch (e) {
      log('⚠️ SignalR 连接失败: $e');
    }
  }

  /// 处理 AI Chat 流式响应块
  void _handleAIChatChunk(AIChatChunk chunk) {
    // 只处理当前请求的响应
    if (_currentRequestId == null || chunk.requestId != _currentRequestId) {
      return;
    }

    if (_streamingIndex == null || _streamingIndex! >= messages.length) {
      return;
    }

    // 处理错误
    if (chunk.hasError) {
      _replaceStreamingMessage(
        AiMessage(
          role: 'assistant',
          content: chunk.error ?? _l10n.aiChatResponseError,
          isError: true,
          createdAt: DateTime.now(),
        ),
      );
      _finalizeStreaming();
      AppToast.error(chunk.error ?? _l10n.aiChatFailed);
      return;
    }

    // 追加增量内容
    if (chunk.delta.isNotEmpty) {
      final current = messages[_streamingIndex!];
      _replaceStreamingMessage(
        AiMessage(
          role: current.role,
          content: current.content + chunk.delta,
          createdAt: current.createdAt,
        ),
      );
      _scrollToBottom();
    }

    // 完成
    if (chunk.isComplete) {
      log('✅ AI Chat 流式响应完成，messageId: ${chunk.messageId}');
      _finalizeStreaming();
    }
  }

  Future<AiConversation?> _createNewConversation() async {
    try {
      return await _aiChatService.createConversation(
        title: _l10n.aiChatDefaultConversationTitle,
        systemPrompt: _l10n.aiChatSystemPrompt,
      );
    } catch (e, stack) {
      log('❌ 创建 AI 对话失败: $e\n$stack');
      AppToast.error(_l10n.aiChatCreateConversationFailed);
      return null;
    }
  }

  Future<void> loadConversationList() async {
    try {
      isHistoryLoading.value = true;
      final list = await _aiChatService.getConversations(pageSize: 50);
      list.sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      final filtered = await _filterConversationsWithMessages(list);

      // 不显示当前正在进行的对话（未退出的会话不出现在历史列表）
      final currentId = conversation.value?.id;
      final withoutCurrent = currentId == null ? filtered : filtered.where((item) => item.id != currentId).toList();

      historyConversations.assignAll(withoutCurrent);
    } catch (e, stack) {
      log('⚠️ 加载对话列表失败: $e\n$stack');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> loadHistory() async {
    final id = conversation.value?.id;
    if (id == null) return;

    try {
      final history = await _aiChatService.getMessages(conversationId: id);
      history.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
      messages.assignAll(history);
      _tryUpdateHistoryTitleFromMessages(id, history);
      // 加载完成后立即跳转到底部（不带动画），确保页面打开时显示最新消息
      _scrollToBottom(delay: const Duration(milliseconds: 100), animate: false);
    } catch (e, stack) {
      log('⚠️ 加载历史消息失败: $e\n$stack');
      AppToast.error(_l10n.aiChatLoadHistoryFailed);
    }
  }

  Future<void> selectConversation(AiConversation target) async {
    if (isStreaming.value) {
      AppToast.warning(_l10n.aiChatSwitchBlockedWhileStreaming);
      return;
    }
    if (conversation.value?.id == target.id) return;

    try {
      isInitializing.value = true;
      hasInitError.value = false;
      initErrorMessage.value = '';
      conversation.value = target;
      messages.clear();
      await loadHistory();
    } catch (e, stack) {
      log('⚠️ 切换对话失败: $e\n$stack');
      AppToast.error(_l10n.aiChatSwitchConversationFailed);
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || isStreaming.value) return;
    final convId = await _ensureConversationForSend();
    if (convId == null) return;

    _trySetHistoryTitleFromFirstQuestion(convId, text);

    // 生成请求 ID 用于关联 SignalR 响应
    _currentRequestId = const Uuid().v4();

    // 追加用户消息
    final userMsg = AiMessage(
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    messages.add(userMsg);
    inputController.clear();
    _scrollToBottom();

    // 占位的助手消息
    _streamingIndex = messages.length;
    messages.add(
      AiMessage(
        role: 'assistant',
        content: '',
        createdAt: DateTime.now(),
      ),
    );

    isStreaming.value = true;
    streamingStatus.value = _l10n.aiChatThinking;

    try {
      // 使用 SignalR 流式响应
      log('🚀 发送消息，使用 SignalR 流式响应，requestId: $_currentRequestId');

      await _aiChatService.sendMessageWithSignalR(
        conversationId: convId,
        content: text,
        requestId: _currentRequestId,
      );

      _pendingEmptyConversationId = null;

      // 响应将通过 SignalR 的 _handleAIChatChunk 处理
      log('✅ 消息已发送，等待 SignalR 响应...');

      // 设置超时保护（60秒）
      Future.delayed(const Duration(seconds: 60), () {
        if (isStreaming.value && _currentRequestId != null) {
          log('⚠️ AI Chat 响应超时');
          _replaceStreamingMessage(
            AiMessage(
              role: 'assistant',
              content: _l10n.aiChatRequestTimeout,
              isError: true,
              createdAt: DateTime.now(),
            ),
          );
          _finalizeStreaming();
        }
      });
    } catch (e, stack) {
      log('❌ AI Chat 发送失败: $e\n$stack');
      await _cleanupPendingConversation();
      _replaceStreamingMessage(
        AiMessage(
          role: 'assistant',
          content: _l10n.aiChatReplyUnavailable,
          isError: true,
          createdAt: DateTime.now(),
        ),
      );
      AppToast.error(_l10n.aiChatSendFailed);
      _finalizeStreaming();
    }
  }

  void _replaceStreamingMessage(AiMessage message) {
    if (_streamingIndex == null) return;
    messages[_streamingIndex!] = message;
    messages.refresh();
  }

  void _finalizeStreaming() {
    if (_streamingIndex != null && _streamingIndex! < messages.length) {
      final current = messages[_streamingIndex!];
      if (current.content.isEmpty && !current.isError) {
        messages[_streamingIndex!] = AiMessage(
          role: current.role,
          content: _l10n.aiChatNoReplyYet,
          isError: true,
          createdAt: current.createdAt,
        );
        messages.refresh();
      }
    }
    isStreaming.value = false;
    streamingStatus.value = '';
    _streamingIndex = null;
    _currentRequestId = null;
  }

  void _scrollToBottom({Duration delay = Duration.zero, bool animate = true}) {
    if (!scrollController.hasClients) return;
    Future.delayed(delay, () {
      if (!scrollController.hasClients) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        // 使用 reverse: true 后，滚动到底部就是滚动到 0 位置
        if (animate) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(0);
        }
      });
    });
  }

  String getHistoryTitle(AiConversation item) {
    final override = historyTitleOverrides[item.id];
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return item.title.isNotEmpty ? item.title : _l10n.aiChatUntitledConversation;
  }

  void _trySetHistoryTitleFromFirstQuestion(String convId, String question) {
    if (historyTitleOverrides.containsKey(convId)) return;
    final formatted = _truncateQuestionTitle(question);
    if (formatted.isEmpty) return;
    historyTitleOverrides[convId] = formatted;
    historyTitleOverrides.refresh();
  }

  void _tryUpdateHistoryTitleFromMessages(String convId, List<AiMessage> list) {
    if (historyTitleOverrides.containsKey(convId)) return;
    final firstUser = list.firstWhereOrNull((item) => item.isUser && item.content.trim().isNotEmpty);
    if (firstUser == null) return;
    final formatted = _truncateQuestionTitle(firstUser.content);
    if (formatted.isEmpty) return;
    historyTitleOverrides[convId] = formatted;
    historyTitleOverrides.refresh();
  }

  Future<List<AiConversation>> _filterConversationsWithMessages(
    List<AiConversation> list,
  ) async {
    if (list.isEmpty) return list;

    final results = await Future.wait(
      list.map((item) async {
        try {
          final messages = await _aiChatService.getMessages(
            conversationId: item.id,
            pageSize: 1,
          );

          if (messages.isEmpty) return null;

          // 提前用首条用户消息为历史列表生成标题，避免默认标题展示错误
          if (!historyTitleOverrides.containsKey(item.id)) {
            final firstUser =
                messages.firstWhereOrNull((m) => m.isUser && m.content.trim().isNotEmpty) ?? messages.first;
            final formatted = _truncateQuestionTitle(firstUser.content);
            if (formatted.isNotEmpty) {
              historyTitleOverrides[item.id] = formatted;
            }
          }

          return item;
        } catch (_) {
          return null;
        }
      }),
    );

    return results.whereType<AiConversation>().toList();
  }

  Future<String?> _ensureConversationForSend() async {
    final existingId = conversation.value?.id;
    if (existingId != null) return existingId;

    final conv = await _createNewConversation();
    if (conv == null) {
      AppToast.error(_l10n.aiChatCreateConversationFailed);
      return null;
    }

    conversation.value = conv;
    messages.clear();
    _pendingEmptyConversationId = conv.id;
    return conv.id;
  }

  Future<void> _cleanupPendingConversation() async {
    final pendingId = _pendingEmptyConversationId;
    if (pendingId == null) return;

    try {
      await _aiChatService.deleteConversation(conversationId: pendingId);
    } catch (e, stack) {
      log('⚠️ 清理空对话失败: $e\n$stack');
    } finally {
      historyConversations.removeWhere((item) => item.id == pendingId);
      historyTitleOverrides.remove(pendingId);
      if (conversation.value?.id == pendingId) {
        conversation.value = null;
      }
      _pendingEmptyConversationId = null;
    }
  }

  String _truncateQuestionTitle(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return '';
    final chars = normalized.characters;
    if (chars.length <= 10) return normalized;
    return chars.take(10).toString();
  }

  // ── OpenClaw 自动化 ──────────────────────────────────────────────

  /// 切换快捷操作面板的显示
  void toggleQuickActions() {
    showQuickActions.toggle();
  }

  /// 执行 OpenClaw 自然语言指令
  Future<void> executeOpenClawCommand(String command) async {
    if (command.trim().isEmpty || isOpenClawBusy.value) return;

    // 添加用户消息
    messages.add(AiMessage(
      role: 'user',
      content: '🤖 $command',
      createdAt: DateTime.now(),
    ));
    _scrollToBottom();

    isOpenClawBusy.value = true;

    try {
      final result = await _openClawService.executeCommand(command);
      if (result.isMembershipRequired) {
        AiPlannerAccessService().redirectToMembership(featureName: 'OpenClaw 自动化');
        messages.add(AiMessage(
          role: 'assistant',
          content: '🔒 ${result.error ?? 'OpenClaw 自动化功能仅对会员开放，请先开通会员'}',
          isError: true,
          createdAt: DateTime.now(),
        ));
        return;
      }
      messages.add(AiMessage(
        role: 'assistant',
        content: result.success ? '✅ ${result.data ?? '指令已执行'}' : '❌ ${result.error ?? '执行失败'}',
        isError: !result.success,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      log('❌ OpenClaw 执行失败: $e');
      messages.add(AiMessage(
        role: 'assistant',
        content: '❌ 自动化执行出错，请稍后重试',
        isError: true,
        createdAt: DateTime.now(),
      ));
    } finally {
      isOpenClawBusy.value = false;
      _scrollToBottom();
    }
  }

  /// 执行 OpenClaw 预设场景
  Future<void> runOpenClawScenario(
    AutomationScenario scenario,
    Map<String, String> params,
  ) async {
    if (isOpenClawBusy.value) return;

    // 添加用户消息
    final paramDesc = params.entries.where((e) => e.value.isNotEmpty).map((e) => '${e.key}: ${e.value}').join(', ');
    messages.add(AiMessage(
      role: 'user',
      content: '${scenario.icon} ${scenario.title}${paramDesc.isNotEmpty ? '（$paramDesc）' : ''}',
      createdAt: DateTime.now(),
    ));
    _scrollToBottom();

    isOpenClawBusy.value = true;

    try {
      final result = await _openClawService.runAutomation(scenario, params);
      if (result.isMembershipRequired) {
        AiPlannerAccessService().redirectToMembership(featureName: 'OpenClaw 自动化');
        messages.add(AiMessage(
          role: 'assistant',
          content: '🔒 ${result.error ?? 'OpenClaw 自动化功能仅对会员开放，请先开通会员'}',
          isError: true,
          createdAt: DateTime.now(),
        ));
        return;
      }
      messages.add(AiMessage(
        role: 'assistant',
        content: result.success
            ? '✅ ${result.data ?? '${scenario.title}已完成'}'
            : '❌ ${result.error ?? '${scenario.title}执行失败'}',
        isError: !result.success,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      log('❌ OpenClaw 场景执行失败: $e');
      messages.add(AiMessage(
        role: 'assistant',
        content: '❌ ${scenario.title}执行出错，请稍后重试',
        isError: true,
        createdAt: DateTime.now(),
      ));
    } finally {
      isOpenClawBusy.value = false;
      _scrollToBottom();
    }
  }
}
