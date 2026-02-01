import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_empty_hint.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_error_state.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_hero_card.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_input_bar.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_message_list.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_streaming_status.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

/// AI Chat 页面
/// 使用 GetView 模式，自动获取 AiChatController
class AiChatPage extends GetView<AiChatController> {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部 Hero 卡片
            AiChatHeroCard(isMobile: isMobile),
            // 流式状态指示器
            const AiChatStreamingStatus(),
            // 消息列表区域
            Expanded(child: _buildMessageArea(isMobile)),
            // 输入框
            AiChatInputBar(isMobile: isMobile),
          ],
        ),
      ),
    );
  }

  /// 构建 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.6,
      title: const Text(
        'Nomads AI Copilot',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      leading: const AppBackButton(),
    );
  }

  /// 构建消息区域
  Widget _buildMessageArea(bool isMobile) {
    return Obx(() {
      // 初始化加载中
      if (controller.isInitializing.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 初始化错误状态
      if (controller.hasInitError.value) {
        return AiChatErrorState(
          message: controller.initErrorMessage.value,
          onRetry: controller.retryInit,
        );
      }

      // 空状态
      if (controller.messages.isEmpty) {
        return AiChatEmptyHint(onStart: controller.sendMessage);
      }

      // 消息列表
      return AiChatMessageList(isMobile: isMobile);
    });
  }
}
