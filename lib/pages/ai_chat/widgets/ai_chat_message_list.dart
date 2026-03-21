import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_message_bubble.dart';

class AiChatMessageList extends GetView<AiChatController> {
  const AiChatMessageList({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.messages;

      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              AiChatTheme.shell.withValues(alpha: 0.18),
            ],
          ),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 20,
            vertical: 18.h,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final message = items[index];
            final isLastMessage = index == controller.messages.length - 1;

            return AiChatMessageBubble(
              message: message,
              isMine: message.isUser,
              isStreaming: controller.isStreaming.value && isLastMessage,
            );
          },
        ),
      );
    });
  }
}
