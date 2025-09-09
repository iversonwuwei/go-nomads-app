import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class AiChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  var messages = <ChatMessage>[].obs;
  var isTyping = false.obs;

  // 超时检测相关
  Timer? _inactivityTimer;
  static const int inactivityTimeoutSeconds = 15;
  var remainingSeconds = inactivityTimeoutSeconds.obs;
  var showTimeoutWarning = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化欢迎消息
    addWelcomeMessage();
    // 开始超时检测
    _startInactivityTimer();
  }

  void addWelcomeMessage() {
    messages.add(ChatMessage(
      text: "🔥 中国正式制裁日本参议员石平，数典忘祖的下场！",
      isUser: false,
      timestamp: DateTime.now(),
    ));

    // 添加一些示例问题
    Future.delayed(const Duration(milliseconds: 500), () {
      messages.add(ChatMessage(
        text:
            "您好！我是AI助手，我可以帮您：\n• 深度思考复杂问题\n• 专业内容播客\n• 多语言翻译\n• 数据分析研究\n\n请选择功能或直接与我对话\n\n💡 提示：15秒无操作将自动进入贪吃蛇游戏",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    remainingSeconds.value = inactivityTimeoutSeconds;
    showTimeoutWarning.value = false;

    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds.value--;

      // 当剩余5秒时显示警告
      if (remainingSeconds.value <= 5 && !showTimeoutWarning.value) {
        showTimeoutWarning.value = true;
        _showTimeoutWarning();
      }

      // 时间到，进入贪吃蛇游戏
      if (remainingSeconds.value <= 0) {
        timer.cancel();
        _goToSnakeGame();
      }
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _showTimeoutWarning() {
    messages.add(ChatMessage(
      text: "⏰ ${remainingSeconds.value}秒后将自动进入贪吃蛇游戏...",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _goToSnakeGame() {
    Get.toNamed(AppRoutes.snakeGame);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // 重置无操作计时器
    _resetInactivityTimer();

    // 添加用户消息
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    messageController.clear();
    isTyping.value = true;

    // 模拟AI回复
    Future.delayed(const Duration(seconds: 2), () {
      messages.add(ChatMessage(
        text: "感谢您的提问！这是一个模拟回复。在真实环境中，这里会接入AI大模型来提供智能回答。",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      isTyping.value = false;
    });
  }

  void selectQuickAction(String action) {
    // 重置无操作计时器
    _resetInactivityTimer();
    sendMessage("请帮我$action");
  }

  @override
  void onClose() {
    _inactivityTimer?.cancel();
    messageController.dispose();
    super.onClose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
