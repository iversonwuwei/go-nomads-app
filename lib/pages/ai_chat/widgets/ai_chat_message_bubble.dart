import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// AI Chat 消息气泡
class AiChatMessageBubble extends StatelessWidget {
  const AiChatMessageBubble({
    super.key,
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
      return _UserMessageBubble(message: message);
    }
    // AI 消息使用 Markdown 渲染
    return _AiMessageBubble(
      message: message,
      isStreaming: isStreaming,
    );
  }
}

/// 用户消息气泡
class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(left: 48, right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cityPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cityPrimary.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.content.isNotEmpty ? message.content : '…',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

/// AI 消息气泡（支持 Markdown）
class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({
    required this.message,
    this.isStreaming = false,
  });

  final AiMessage message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final bg = message.isError ? const Color(0xFFFFEAEA) : Colors.white;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        margin: const EdgeInsets.only(left: 8, right: 24, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: message.isError ? const Color(0xFFFFB4B4) : AppColors.border,
            width: 0.5,
          ),
        ),
        child: isStreaming && message.content.isEmpty
            ? const _TypingDots()
            : _AiMarkdownContent(
                content: message.content,
                isError: message.isError,
              ),
      ),
    );
  }
}

/// AI 消息的 Markdown 内容渲染（手机端优化）
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
      shrinkWrap: true,
      softLineBreak: true,
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
      fontSize: 15,
      height: 1.55,
    );

    return MarkdownStyleSheet(
      // 段落样式
      p: baseStyle,
      pPadding: const EdgeInsets.only(bottom: 10),

      // 标题样式 - 手机端稍小
      h1: baseStyle?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        height: 1.3,
      ),
      h1Padding: const EdgeInsets.only(top: 6, bottom: 8),
      h2: baseStyle?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        height: 1.3,
      ),
      h2Padding: const EdgeInsets.only(top: 6, bottom: 6),
      h3: baseStyle?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 1.3,
      ),
      h3Padding: const EdgeInsets.only(top: 4, bottom: 4),

      // 加粗和斜体
      strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle?.copyWith(fontStyle: FontStyle.italic),

      // 行内代码 - 手机端优化
      code: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: Color(0xFFE11D48),
        backgroundColor: Color(0xFFF1F5F9),
      ),
      codeblockPadding: const EdgeInsets.all(10),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),

      // 引用块 - 手机端更紧凑
      blockquote: baseStyle?.copyWith(
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
        fontSize: 14,
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          left: BorderSide(
            color: AppColors.cityPrimary.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),

      // 列表样式 - 手机端缩进更小
      listBullet: baseStyle?.copyWith(color: AppColors.cityPrimary),
      listBulletPadding: const EdgeInsets.only(right: 6),
      listIndent: 16,

      // 分割线
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // 表格 - 手机端更紧凑
      tableBorder: TableBorder.all(color: AppColors.border, width: 0.5),
      tableHead: baseStyle?.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
      tableBody: baseStyle?.copyWith(fontSize: 13),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

      // 链接
      a: baseStyle?.copyWith(
        color: AppColors.cityPrimary,
        decoration: TextDecoration.underline,
      ),

      // Checkbox
      checkbox: TextStyle(color: AppColors.cityPrimary),
    );
  }
}

/// 代码块构建器（手机端优化）
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

    return _MobileCodeBlock(code: code, language: language);
  }
}

/// 手机端代码块组件
class _MobileCodeBlock extends StatefulWidget {
  const _MobileCodeBlock({
    required this.code,
    required this.language,
  });

  final String code;
  final String language;

  @override
  State<_MobileCodeBlock> createState() => _MobileCodeBlockState();
}

class _MobileCodeBlockState extends State<_MobileCodeBlock> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.code.trim().split('\n');
    final lineCount = lines.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部（语言标签 + 复制按钮）
          _buildHeader(),
          // 代码内容（带行号）
          _buildCodeContent(lines, lineCount),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF334155),
      ),
      child: Row(
        children: [
          // 语言标签
          if (widget.language.isNotEmpty)
            Text(
              widget.language,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          const Spacer(),
          // 复制按钮
          GestureDetector(
            onTap: _copyCode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _copied ? const Color(0xFF10B981) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 12,
                    color: _copied ? Colors.white : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _copied ? '已复制' : '复制',
                    style: TextStyle(
                      fontSize: 11,
                      color: _copied ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeContent(List<String> lines, int lineCount) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 行号
              if (lineCount > 1)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(lineCount, (index) {
                      return Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      );
                    }),
                  ),
                ),
              // 代码内容
              SelectableText(
                widget.code.trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFFE2E8F0),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code.trim()));
    setState(() => _copied = true);
    AppToast.success('代码已复制');

    // 2秒后重置状态
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }
}

/// 打字动画点
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
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
        return SizedBox(
          width: 30,
          height: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(3, (index) {
              final active = index <= value % 3;
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.textSecondary
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
