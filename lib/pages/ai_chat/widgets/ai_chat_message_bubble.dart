import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        margin: EdgeInsets.only(left: 48.w, right: 8.w, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.cityPrimary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.cityPrimary.withValues(alpha: 0.18),
              blurRadius: 8.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.content.isNotEmpty ? message.content : '…',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
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
        margin: EdgeInsets.only(left: 8.w, right: 24.w, bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
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
      fontSize: 15.sp,
      height: 1.55,
    );

    return MarkdownStyleSheet(
      // 段落样式
      p: baseStyle,
      pPadding: EdgeInsets.only(bottom: 10.h),

      // 标题样式 - 手机端稍小
      h1: baseStyle?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18.sp,
        height: 1.3,
      ),
      h1Padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
      h2: baseStyle?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
        height: 1.3,
      ),
      h2Padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
      h3: baseStyle?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        height: 1.3,
      ),
      h3Padding: EdgeInsets.only(top: 4.h, bottom: 4.h),

      // 加粗和斜体
      strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle?.copyWith(fontStyle: FontStyle.italic),

      // 行内代码 - 手机端优化
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13.sp,
        color: Color(0xFFE11D48),
        backgroundColor: Color(0xFFF1F5F9),
      ),
      codeblockPadding: EdgeInsets.all(10.w),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8.r),
      ),

      // 引用块 - 手机端更紧凑
      blockquote: baseStyle?.copyWith(
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
        fontSize: 14.sp,
      ),
      blockquotePadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
      listBulletPadding: EdgeInsets.only(right: 6.w),
      listIndent: 16,

      // 分割线
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // 表格 - 手机端更紧凑
      tableBorder: TableBorder.all(color: AppColors.border, width: 0.5),
      tableHead: baseStyle?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
      tableBody: baseStyle?.copyWith(fontSize: 13.sp),
      tableCellsPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),

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
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8.r),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: const BoxDecoration(
        color: Color(0xFF334155),
      ),
      child: Row(
        children: [
          // 语言标签
          if (widget.language.isNotEmpty)
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                widget.language,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const Spacer(),
          // 复制按钮
          Flexible(
            fit: FlexFit.loose,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _copyCode,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _copied ? const Color(0xFF10B981) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _copied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 12.r,
                        color: _copied ? Colors.white : const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _copied ? '已复制' : '复制',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: _copied ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeContent(List<String> lines, int lineCount) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300.h),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 行号
              if (lineCount > 1)
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(lineCount, (index) {
                      return Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.sp,
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
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.sp,
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
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: widget.code.trim()));
    setState(() => _copied = true);
    AppToast.success(l10n.aiChatCodeCopied);

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

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
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
          width: 30.w,
          height: 10.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(3, (index) {
              final active = index <= value % 3;
              return Container(
                width: 6.w,
                height: 6.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: active ? AppColors.textSecondary : AppColors.textSecondary.withValues(alpha: 0.3),
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
