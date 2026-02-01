import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/ai_chat_controller.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  reverse: true, // 从底部开始显示，自动显示最新消息
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // reverse: true 时，index 0 是最后一条消息，需要反转索引
                    final reversedIndex = items.length - 1 - index;
                    final message = items[reversedIndex];
                    return _MessageBubble(
                      message: message,
                      isMine: message.isUser,
                      isStreaming: controller.isStreaming.value && reversedIndex == controller.messages.length - 1,
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
    // 用户消息使用简单样式
    if (isMine) {
      return _buildUserMessage(context);
    }
    // AI 消息使用 Markdown 渲染
    return _buildAiMessage(context);
  }

  /// 用户消息气泡
  Widget _buildUserMessage(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.only(left: 60, right: 12, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cityPrimary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.cityPrimary.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            message.content.isNotEmpty ? message.content : '…',
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
        ),
      ),
    );
  }

  /// AI 消息气泡（支持 Markdown）
  Widget _buildAiMessage(BuildContext context) {
    final bg = message.isError ? const Color(0xFFFFEAEA) : Colors.white;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 60, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: message.isError ? const Color(0xFFFFB4B4) : AppColors.border,
            ),
          ),
          child: isStreaming && message.content.isEmpty
              ? const _TypingDots()
              : _AiMarkdownContent(
                  content: message.content,
                  isError: message.isError,
                ),
        ),
      ),
    );
  }
}

/// AI 消息的 Markdown 内容渲染
class _AiMarkdownContent extends StatelessWidget {
  const _AiMarkdownContent({
    required this.content,
    this.isError = false,
  });

  final String content;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return Text(
        '…',
        style: TextStyle(
          color: isError ? const Color(0xFFB42318) : AppColors.textPrimary,
        ),
      );
    }

    return MarkdownBody(
      data: content,
      selectable: true,
      onTapLink: (text, href, title) async {
        if (href != null) {
          final uri = Uri.tryParse(href);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      styleSheet: _buildMarkdownStyleSheet(context),
      builders: {
        'code': _CodeBlockBuilder(),
      },
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = textTheme.bodyMedium?.copyWith(
      color: isError ? const Color(0xFFB42318) : AppColors.textPrimary,
      height: 1.6,
    );

    return MarkdownStyleSheet(
      // 段落样式
      p: baseStyle,
      pPadding: const EdgeInsets.only(bottom: 12),

      // 标题样式
      h1: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 12),
      h2: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      h2Padding: const EdgeInsets.only(top: 8, bottom: 10),
      h3: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      h3Padding: const EdgeInsets.only(top: 6, bottom: 8),

      // 加粗和斜体
      strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle?.copyWith(fontStyle: FontStyle.italic),

      // 行内代码
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: const Color(0xFFE11D48),
        backgroundColor: const Color(0xFFF1F5F9),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),

      // 引用块
      blockquote: baseStyle?.copyWith(
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          left: BorderSide(
            color: AppColors.cityPrimary.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
      ),

      // 列表样式
      listBullet: baseStyle?.copyWith(color: AppColors.cityPrimary),
      listBulletPadding: const EdgeInsets.only(right: 8),
      listIndent: 20,

      // 分割线
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // 表格
      tableBorder: TableBorder.all(color: AppColors.border, width: 1),
      tableHead: baseStyle?.copyWith(fontWeight: FontWeight.w600),
      tableBody: baseStyle,
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      // 链接
      a: baseStyle?.copyWith(
        color: AppColors.cityPrimary,
        decoration: TextDecoration.underline,
      ),

      // Checkbox (用于 todo list)
      checkbox: TextStyle(color: AppColors.cityPrimary),
    );
  }
}

/// 代码块构建器（支持语法高亮和复制功能）
class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, preferredStyle) {
    if (element.tag != 'code') return null;

    final code = element.textContent;
    String language = '';

    // 尝试从 class 属性获取语言
    final className = element.attributes['class'];
    if (className != null && className.startsWith('language-')) {
      language = className.substring(9);
    }

    return _CodeBlockWidget(code: code, language: language);
  }
}

/// 代码块组件
class _CodeBlockWidget extends StatelessWidget {
  const _CodeBlockWidget({
    required this.code,
    required this.language,
  });

  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 头部（语言标签 + 操作按钮）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Row(
              children: [
                if (language.isNotEmpty) ...[
                  Text(
                    language,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ],
                // 复制按钮
                InkWell(
                  onTap: () => _copyCode(context),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 下载按钮
                InkWell(
                  onTap: () => _downloadCode(context),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.download_rounded, size: 14, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
          // 代码内容
          Padding(
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code.trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFFE2E8F0),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code.trim()));
    AppToast.success('代码已复制');
  }

  void _downloadCode(BuildContext context) {
    // 简单实现：复制到剪贴板并提示
    Clipboard.setData(ClipboardData(text: code.trim()));
    AppToast.success('代码已复制到剪贴板');
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
