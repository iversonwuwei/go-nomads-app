import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
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
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Nomads AI Copilot',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        leading: const AppBackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border.withValues(alpha: 0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isInitializing.value) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
                    vertical: 20.h,
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
        constraints: BoxConstraints(maxWidth: 720),
        child: Container(
          margin: EdgeInsets.only(left: 64.w, right: 0, bottom: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.cityPrimary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(4.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cityPrimary.withValues(alpha: 0.15),
                blurRadius: 8.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.content.isNotEmpty ? message.content : '…',
            style: TextStyle(color: Colors.white, height: 1.5, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }

  /// AI 消息气泡（支持 Markdown）
  Widget _buildAiMessage(BuildContext context) {
    // 错误消息背景稍微泛红，正常消息白色
    final bg = message.isError ? const Color(0xFFFEF2F2) : Colors.white;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720),
        child: Container(
          margin: EdgeInsets.only(left: 0, right: 48.w, bottom: 24.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
            border: message.isError ? Border.all(color: const Color(0xFFFCA5A5)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isStreaming && message.content.isEmpty
              ? const _TypingDots()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isStreaming) ...[
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 14.sp, color: AppColors.cityPrimary),
                          SizedBox(width: 6.w),
                          Text(
                            "AI Thinking...",
                            style: TextStyle(
                              fontSize: 12.sp, 
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                    _AiMarkdownContent(
                      content: message.content,
                      isError: message.isError,
                    ),
                  ],
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
      pPadding: EdgeInsets.only(bottom: 12.h),

      // 标题样式
      h1: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      h1Padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
      h2: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      h2Padding: EdgeInsets.only(top: 8.h, bottom: 10.h),
      h3: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      h3Padding: EdgeInsets.only(top: 6.h, bottom: 8.h),

      // 加粗和斜体
      strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle?.copyWith(fontStyle: FontStyle.italic),

      // 行内代码
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13.sp,
        color: const Color(0xFFE11D48),
        backgroundColor: const Color(0xFFF1F5F9),
      ),
      codeblockPadding: EdgeInsets.all(14.w),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10.r),
      ),

      // 引用块
      blockquote: baseStyle?.copyWith(
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
      listBulletPadding: EdgeInsets.only(right: 8.w),
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
      tableCellsPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),

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
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 头部（语言标签 + 操作按钮）
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color(0xFF334155),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9.r),
                topRight: Radius.circular(9.r),
              ),
            ),
            child: Row(
              children: [
                if (language.isNotEmpty) ...[
                  Text(
                    language,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ],
                // 复制按钮
                InkWell(
                  onTap: () => _copyCode(context),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 14.r, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4.w),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // 下载按钮
                InkWell(
                  onTap: () => _downloadCode(context),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(Icons.download_rounded, size: 14.r, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
          // 代码内容
          Padding(
            padding: EdgeInsets.all(14.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code.trim(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13.sp,
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
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: code.trim()));
    AppToast.success(l10n.aiChatCodeCopied);
  }

  void _downloadCode(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 简单实现：复制到剪贴板并提示
    Clipboard.setData(ClipboardData(text: code.trim()));
    AppToast.success(l10n.aiChatCodeCopiedToClipboard);
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
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Container(
                width: 7.w,
                height: 7.h,
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
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.6))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h), // adjusted vertical padding
                child: Obx(() {
                  return TextField(
                    controller: controller.inputController,
                    enabled: !controller.isStreaming.value,
                    decoration: InputDecoration(
                      hintText: l10n.aiChatInputHint,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 15.sp),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                  );
                }),
              ),
            ),
            SizedBox(width: 12.w),
            Obx(() {
              final isStreaming = controller.isStreaming.value;
              
              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Material(
                  color: isStreaming ? Colors.grey.shade300 : AppColors.cityPrimary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: isStreaming ? null : controller.sendMessage,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.all(10.r),
                      child: FaIcon(
                        FontAwesomeIcons.paperPlane, 
                        color: Colors.white, 
                        size: 18.r,
                      ),
                    ),
                  ),
                ),
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cityPrimary.withValues(alpha: 0.1),
                  blurRadius: 20.r,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FaIcon(
              FontAwesomeIcons.solidComments,
              color: AppColors.cityPrimary,
              size: 40.r,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            l10n.aiChatEmptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Start a conversation to get travel tips and more.", // Simplified fallback, original text used l10n
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
            child: Text(
              l10n.aiChatStartConversation,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.red.shade400,
                size: 28.r,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              message.isNotEmpty ? message : 'AI 服务暂时不可用',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '请检查网络连接或稍后重试',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: FaIcon(FontAwesomeIcons.arrowRotateRight, size: 14.r),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
