import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';

class AiChatStreamingStatus extends GetView<AiChatController> {
  const AiChatStreamingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isStreaming.value && controller.streamingStatus.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AiChatTheme.line),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18.w,
                height: 18.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AiChatTheme.teal,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  controller.streamingStatus.value.isNotEmpty ? controller.streamingStatus.value : 'AI 正在输出…',
                  style: TextStyle(
                    color: AiChatTheme.inkSoft,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
