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
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/dialogs/app_loading_dialog.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  Future<void> _showHistorySheet(BuildContext context) async {
    // 显示优雅的加载对话框
    AppLoadingDialog.show(
      title: '加载历史对话...',
      subtitle: '请稍候',
    );

    try {
      // 加载历史对话
      await controller.loadConversationList();
    } finally {
      // 关闭加载对话框
      AppLoadingDialog.hide();
    }

    // 如果没有历史对话，直接提示
    if (controller.historyConversations.isEmpty) {
      AppToast.info('暂无历史对话，直接开始新对话吧');
      return;
    }

    // 有历史对话才显示底部抽屉
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '历史对话',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Obx(() {
                    final items = controller.historyConversations;
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final currentId = controller.conversation.value?.id;
                        final time = item.updatedAt ?? item.createdAt;
                        final timeLabel = time == null ? '' : DateFormat('yyyy-MM-dd HH:mm').format(time);
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
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
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                          trailing: currentId == item.id ? Icon(Icons.check_rounded, size: 18.r) : null,
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
