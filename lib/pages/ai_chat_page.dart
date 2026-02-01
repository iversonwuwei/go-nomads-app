import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/ai_chat_controller.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

class AiChatPage extends GetView<AiChatController> {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        title: const Text(
          'Nomads AI Copilot',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _HeroCard(isMobile: isMobile),
            _StreamingStatus(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isInitializing.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 显示初始化错误状态
                if (controller.hasInitError.value) {
                  return _ErrorState(
                    message: controller.initErrorMessage.value,
                    onRetry: controller.retryInit,
                  );
                }

                final items = controller.messages;
                if (items.isEmpty) {
                  return _EmptyHint(onStart: controller.sendMessage);
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final message = items[index];
                    return _MessageBubble(
                      message: message,
                      isMine: message.isUser,
                      isStreaming: controller.isStreaming.value && index == controller.messages.length - 1,
                    );
                  },
                );
              }),
            ),
            _InputBar(controller: controller, isMobile: isMobile),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 12, isMobile ? 16 : 24, 10),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: isMobile ? 48 : 56,
            width: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.robot, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '行途 AI 智能助手',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '用流式对话聊攻略、问路线、生成行程草稿。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'SignalR 流式',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamingStatus extends StatelessWidget {
  const _StreamingStatus({required this.controller});
  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.cityPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.streamingStatus.value.isNotEmpty
                    ? controller.streamingStatus.value
                    : 'AI 正在输出，SignalR 实时传输…',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.isStreaming = false,
  });

  final AiMessage message;
  final bool isMine;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final bg = isMine
        ? AppColors.cityPrimary
        : message.isError
            ? const Color(0xFFFFEAEA)
            : Colors.white;
    final textColor = isMine ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: EdgeInsets.only(
            left: isMine ? 60 : 12,
            right: isMine ? 12 : 60,
            bottom: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: isMine
                ? null
                : Border.all(
                    color: message.isError ? const Color(0xFFFFB4B4) : AppColors.border,
                  ),
            boxShadow: isMine
                ? [
                    BoxShadow(
                      color: AppColors.cityPrimary.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: isStreaming && message.content.isEmpty
              ? const _TypingDots()
              : Text(
                  message.content.isNotEmpty ? message.content : '…',
                  style: TextStyle(
                    color: message.isError ? const Color(0xFFB42318) : textColor,
                    height: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (_controller.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final active = index <= value % 3;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.isMobile});

  final AiChatController controller;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(isMobile ? 14 : 24, 8, isMobile ? 14 : 24, 14),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Obx(() {
                  return TextField(
                    controller: controller.inputController,
                    enabled: !controller.isStreaming.value,
                    decoration: const InputDecoration(
                      hintText: '问路、问签证、生成行程，都可以直接开聊…',
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => controller.sendMessage(),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            Obx(() {
              final disabled = controller.isStreaming.value;
              return ElevatedButton(
                onPressed: disabled ? null : controller.sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cityPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 16,
                    vertical: isMobile ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 16),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: const FaIcon(FontAwesomeIcons.solidComments, color: AppColors.cityPrimary, size: 28),
          ),
          const SizedBox(height: 18),
          const Text('还没有对话，向 AI 提问试试', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('开始对话'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.red.shade400,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message.isNotEmpty ? message : 'AI 服务暂时不可用',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请检查网络连接或稍后重试',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const FaIcon(FontAwesomeIcons.arrowRotateRight, size: 14),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
