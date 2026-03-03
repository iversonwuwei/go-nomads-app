import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_message_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// AI Chat 消息列表
/// 使用 GetView 自动获取 controller
class AiChatMessageList extends GetView<AiChatController> {
  const AiChatMessageList({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.messages;

      return ListView.builder(
        controller: controller.scrollController,
        reverse: true, // 从底部开始显示，自动显示最新消息
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 12.h,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          // reverse: true 时，index 0 是最后一条消息，需要反转索引
          final reversedIndex = items.length - 1 - index;
          final message = items[reversedIndex];
          final isLastMessage = reversedIndex == controller.messages.length - 1;

          return AiChatMessageBubble(
            message: message,
            isMine: message.isUser,
            isStreaming: controller.isStreaming.value && isLastMessage,
          );
        },
      );
    });
  }
}
