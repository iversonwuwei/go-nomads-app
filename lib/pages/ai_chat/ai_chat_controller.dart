import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:uuid/uuid.dart';

class AiChatController extends GetxController {
  AiChatController(
    this._aiChatService,
    this._authController,
    this._signalRService,
  );

  final AiChatService _aiChatService;
  final AuthStateController _authController;
  final SignalRService _signalRService;

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

  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StreamSubscription? _taskProgressSub;
  StreamSubscription? _aiChatChunkSub;
  int? _streamingIndex;
  String? _currentRequestId;
  String? _pendingEmptyConversationId;

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
      await loadConversationList();
      if (historyConversations.isEmpty) {
        conversation.value = null;
        messages.clear();
        return;
      }
      await _startNewConversation();
      await loadHistory();
    } catch (e, stack) {
      log('❌ 初始化 AI Chat 失败: $e\n$stack');
      hasInitError.value = true;
      initErrorMessage.value = 'AI 服务暂时不可用，请稍后重试';
      // 不显示 Toast，让 UI 显示错误状态
    } finally {
      isInitializing.value = false;
      // 初始化完成后，确保滚动到底部显示最新消息
      if (messages.isNotEmpty) {
        _scrollToBottom(delay: const Duration(milliseconds: 300), animate: false);
      }
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
          content: chunk.error ?? 'AI 返回错误',
          isError: true,
          createdAt: DateTime.now(),
        ),
      );
      _finalizeStreaming();
      AppToast.error(chunk.error ?? 'AI Chat 失败');
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

  Future<void> _startNewConversation() async {
    final conv = await _createNewConversation();
    if (conv == null) {
      throw Exception('无法初始化 AI 对话');
    }
    conversation.value = conv;
    messages.clear();
  }

  Future<AiConversation?> _createNewConversation() async {
    try {
      return await _aiChatService.createConversation(
        title: 'Nomads AI Copilot',
        systemPrompt: 'You are the Go Nomads AI copilot. Provide concise, actionable travel help for digital nomads.',
      );
    } catch (e, stack) {
      log('❌ 创建 AI 对话失败: $e\n$stack');
      AppToast.error('暂时无法创建 AI 对话');
      return null;
    }
  }

  Future<void> loadConversationList() async {
    try {
      isHistoryLoading.value = true;
      final list = await _aiChatService.getConversations(pageSize: 50);
      final current = conversation.value;
      if (current != null && list.every((item) => item.id != current.id)) {
        list.insert(0, current);
      }
      list.sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      final filtered = await _filterConversationsWithMessages(list);
      historyConversations.assignAll(filtered);
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
      AppToast.error('加载历史对话失败');
    }
  }

  Future<void> selectConversation(AiConversation target) async {
    if (isStreaming.value) {
      AppToast.warning('正在生成回复，请稍后再切换对话');
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
      AppToast.error('切换对话失败，请稍后重试');
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
    streamingStatus.value = 'AI 正在思考...';

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
              content: '请求超时，请稍后重试',
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
          content: '暂时无法获取 AI 回复，请稍后重试',
          isError: true,
          createdAt: DateTime.now(),
        ),
      );
      AppToast.error('AI Chat 发送失败');
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
          content: '暂时未收到 AI 回复，请稍后重试',
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
    return item.title.isNotEmpty ? item.title : '未命名对话';
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
          return messages.isNotEmpty ? item : null;
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
      AppToast.error('暂时无法创建 AI 对话');
      return null;
    }

    conversation.value = conv;
    messages.clear();
    historyConversations.insert(0, conv);
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
}
