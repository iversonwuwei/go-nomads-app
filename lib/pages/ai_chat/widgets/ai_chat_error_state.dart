import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// AI Chat 错误状态组件
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget _buildIcon() {
    return Container(
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
    );
  }

  Widget _buildMessage() {
    return Text(
      message.isNotEmpty ? message : 'AI 服务暂时不可用',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildSubMessage() {
    return Text(
      '请检查网络连接或稍后重试',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.grey.shade500,
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
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
    );
  }
}
