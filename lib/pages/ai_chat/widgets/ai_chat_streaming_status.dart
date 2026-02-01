import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';

/// AI Chat 流式状态指示器
/// 使用 GetView 自动获取 controller
class AiChatStreamingStatus extends GetView<AiChatController> {
  const AiChatStreamingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 不在流式传输中且无状态消息时隐藏
      if (!controller.isStreaming.value && controller.streamingStatus.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.cityPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.streamingStatus.value.isNotEmpty
                    ? controller.streamingStatus.value
                    : 'AI 正在输出…',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
