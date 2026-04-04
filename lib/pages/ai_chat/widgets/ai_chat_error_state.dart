import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';

class AiChatErrorState extends StatelessWidget {
  const AiChatErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AiChatTheme.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              SizedBox(height: 18.h),
              _buildMessage(),
              SizedBox(height: 8.h),
              _buildSubMessage(),
              SizedBox(height: 20.h),
              _buildRetryButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AiChatTheme.errorSoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: FaIcon(
        FontAwesomeIcons.triangleExclamation,
        color: AiChatTheme.error,
        size: 28.r,
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      message.isNotEmpty ? message : 'AI 服务暂时不可用',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AiChatTheme.ink,
      ),
    );
  }

  Widget _buildSubMessage() {
    return Text(
      '请检查网络连接或稍后重试',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        color: AiChatTheme.inkSoft,
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: FaIcon(FontAwesomeIcons.arrowRotateRight, size: 14.r),
      label: Text(l10n.retry),
      style: ElevatedButton.styleFrom(
        backgroundColor: AiChatTheme.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
