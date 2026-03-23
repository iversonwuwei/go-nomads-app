import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 底部法律协议链接组件
///
/// 工信部合规要求：APP 注册/登录页面底部必须展示
/// 「用户协议」和「隐私政策」的可点击链接。
class LegalLinksWidget extends StatelessWidget {
  /// 链接文字颜色
  final Color? linkColor;

  /// 普通文字颜色
  final Color? textColor;

  /// 字体大小
  final double fontSize;

  const LegalLinksWidget({
    super.key,
    this.linkColor,
    this.textColor,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveLinkColor = linkColor ?? AppColors.cityPrimary;
    final effectiveTextColor = textColor ?? AppColors.textTertiary;

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: fontSize,
            color: effectiveTextColor,
            height: 1.6,
          ),
          children: [
            const TextSpan(text: '继续使用即表示您同意 '),
            TextSpan(
              text: l10n?.termsAndConditions ?? '用户协议',
              style: TextStyle(
                color: effectiveLinkColor,
                decoration: TextDecoration.underline,
                decorationColor: effectiveLinkColor.withValues(alpha: 0.4),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(AppRoutes.termsOfService),
            ),
            const TextSpan(text: ' 与 '),
            TextSpan(
              text: l10n?.privacyPolicy ?? '隐私政策',
              style: TextStyle(
                color: effectiveLinkColor,
                decoration: TextDecoration.underline,
                decorationColor: effectiveLinkColor.withValues(alpha: 0.4),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(AppRoutes.privacyPolicy),
            ),
            const TextSpan(text: '。'),
          ],
        ),
      ),
    );
  }
}
