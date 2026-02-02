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
import 'package:intl/intl.dart';

/// AI Chat 页面
/// 使用 GetView 模式，自动获取 AiChatController
class AiChatPage extends GetView<AiChatController> {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
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
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.6,
      title: const Text(
        'Nomads AI Copilot',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      leading: const AppBackButton(),
      actions: [
        IconButton(
          tooltip: '历史对话',
          icon: const Icon(Icons.history_rounded),
          onPressed: () => _showHistorySheet(context),
        ),
      ],
    );
  }

  void _showHistorySheet(BuildContext context) {
    controller.loadConversationList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                const Text(
                  '历史对话',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Obx(() {
                    if (controller.isHistoryLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = controller.historyConversations;
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          '暂无历史对话',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final currentId = controller.conversation.value?.id;
                        final time = item.updatedAt ?? item.createdAt;
                        final timeLabel = time == null ? '' : DateFormat('yyyy-MM-dd HH:mm').format(time);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          title: Text(
                            controller.getHistoryTitle(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: timeLabel.isEmpty
                              ? null
                              : Text(
                                  timeLabel,
                                  style: const TextStyle(fontSize: 12),
                                ),
                          trailing: currentId == item.id ? const Icon(Icons.check_rounded, size: 18) : null,
                          onTap: () async {
                            Navigator.of(sheetContext).pop();
                            await controller.selectConversation(item);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
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
