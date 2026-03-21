import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

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
    if (isMine) {
      return _UserMessageBubble(message: message);
    }

    return _AiMessageBubble(
      message: message,
      isStreaming: isStreaming,
    );
  }
}

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
        margin: EdgeInsets.only(left: 56.w, right: 4.w, bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: AiChatTheme.userBubbleGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22.r),
            topRight: Radius.circular(22.r),
            bottomLeft: Radius.circular(22.r),
            bottomRight: Radius.circular(8.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AiChatTheme.coral.withValues(alpha: 0.24),
              blurRadius: 14.r,
              offset: const Offset(0, 8),
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

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({
    required this.message,
    this.isStreaming = false,
  });

  final AiMessage message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final borderColor = message.isError ? AiChatTheme.error.withValues(alpha: 0.25) : AiChatTheme.line;
    final bg = message.isError ? AiChatTheme.errorSoft : Colors.white.withValues(alpha: 0.82);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        margin: EdgeInsets.only(left: 4.w, right: 28.w, bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(22.r),
            bottomLeft: Radius.circular(22.r),
            bottomRight: Radius.circular(22.r),
          ),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: AiChatTheme.shadow.withValues(alpha: 0.45),
              blurRadius: 16.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: message.isError
                        ? AiChatTheme.error.withValues(alpha: 0.12)
                        : AiChatTheme.tealSoft.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    message.isError ? Icons.priority_high_rounded : Icons.auto_awesome_rounded,
                    size: 15.r,
                    color: message.isError ? AiChatTheme.error : AiChatTheme.teal,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  message.isError ? '系统提示' : 'Nomads AI',
                  style: TextStyle(
                    color: message.isError ? AiChatTheme.error : AiChatTheme.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
                if (isStreaming) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AiChatTheme.tealSoft.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      '实时输出',
                      style: TextStyle(
                        color: AiChatTheme.teal,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            if (isStreaming && message.content.isEmpty)
              const _TypingDots()
            else
              _AiMarkdownContent(
                content: message.content,
                isError: message.isError,
              ),
          ],
        ),
      ),
    );
  }
}

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
          color: isError ? AiChatTheme.error : AiChatTheme.ink,
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
      color: isError ? AiChatTheme.error : AiChatTheme.ink,
      fontSize: 15.sp,
      height: 1.55,
    );

    return MarkdownStyleSheet(
      p: baseStyle,
      pPadding: EdgeInsets.only(bottom: 10.h),
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
      strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle?.copyWith(fontStyle: FontStyle.italic),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13.sp,
        color: AiChatTheme.coralDeep,
        backgroundColor: AiChatTheme.surfaceMuted,
      ),
      codeblockPadding: EdgeInsets.all(10.w),
      codeblockDecoration: BoxDecoration(
        color: AiChatTheme.codeBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      blockquote: baseStyle?.copyWith(
        color: AiChatTheme.inkSoft,
        fontStyle: FontStyle.italic,
        fontSize: 14.sp,
      ),
      blockquotePadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      blockquoteDecoration: BoxDecoration(
        color: AiChatTheme.surfaceMuted,
        border: Border(
          left: BorderSide(
            color: AiChatTheme.teal.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      listBullet: baseStyle?.copyWith(color: AiChatTheme.teal),
      listBulletPadding: EdgeInsets.only(right: 6.w),
      listIndent: 16,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AiChatTheme.line, width: 1),
        ),
      ),
      tableBorder: TableBorder.all(color: AiChatTheme.line, width: 0.5),
      tableHead: baseStyle?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
      tableBody: baseStyle?.copyWith(fontSize: 13.sp),
      tableCellsPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      a: baseStyle?.copyWith(
        color: AiChatTheme.teal,
        decoration: TextDecoration.underline,
      ),
      checkbox: const TextStyle(color: AiChatTheme.teal),
    );
  }
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, preferredStyle) {
    if (element.tag != 'code') return null;

    final code = element.textContent;
    String language = '';

    final className = element.attributes['class'];
    if (className != null && className.startsWith('language-')) {
      language = className.substring(9);
    }

    return _MobileCodeBlock(code: code, language: language);
  }
}

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
        color: AiChatTheme.codeBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildCodeContent(lines, lineCount),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: const BoxDecoration(
        color: AiChatTheme.codeHeader,
      ),
      child: Row(
        children: [
          if (widget.language.isNotEmpty)
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                widget.language,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AiChatTheme.codeMuted,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const Spacer(),
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
                    color: _copied ? AiChatTheme.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _copied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 12.r,
                        color: _copied ? Colors.white : AiChatTheme.codeMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _copied ? '已复制' : '复制',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: _copied ? Colors.white : AiChatTheme.codeMuted,
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
                          color: AiChatTheme.codeMuted.withValues(alpha: 0.72),
                          height: 1.5,
                        ),
                      );
                    }),
                  ),
                ),
              SelectableText(
                widget.code.trim(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.sp,
                  color: AiChatTheme.codeText,
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
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
                  color: active ? AiChatTheme.teal : AiChatTheme.teal.withValues(alpha: 0.25),
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
