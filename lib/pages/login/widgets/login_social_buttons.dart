import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/services/social_login_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 社交登录按钮组
class LoginSocialButtons extends GetView<LoginController> {
  final LoginSocialCopy? copy;

  const LoginSocialButtons({super.key, this.copy});

  static String resolveCopy(String? remote, String fallback) {
    if (remote == null) {
      return fallback;
    }

    final trimmed = remote.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 分隔线
        _Divider(copy: copy),
        SizedBox(height: 24.h),
        // 社交登录按钮
        if (controller.isChineseUser) _ChineseSocialButtons(copy: copy) else _InternationalSocialButtons(copy: copy),
      ],
    );
  }
}

/// 分隔线
class _Divider extends StatelessWidget {
  final LoginSocialCopy? copy;

  const _Divider({this.copy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            LoginSocialButtons.resolveCopy(copy?.dividerLabel, AppLocalizations.of(context)!.orContinueWith),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}

/// 中国区社交登录按钮
class _ChineseSocialButtons extends GetView<LoginController> {
  final LoginSocialCopy? copy;

  const _ChineseSocialButtons({this.copy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wechatLabel = LoginSocialButtons.resolveCopy(copy?.wechatLabel, l10n.wechat);
    final qqLabel = LoginSocialButtons.resolveCopy(copy?.qqLabel, 'QQ');
    final appleLabel = LoginSocialButtons.resolveCopy(copy?.appleLabel, 'Apple');
    final googleLabel = LoginSocialButtons.resolveCopy(copy?.googleLabel, 'Google');

    if (!Platform.isIOS) {
      return Row(
        children: [
          _SocialButton(
            onPressed: () => controller.handleSocialLogin(SocialLoginType.wechat, wechatLabel),
            icon: FontAwesomeIcons.weixin,
            color: LoginConstants.wechatGreen,
            label: wechatLabel,
          ),
          _SocialButton(
            onPressed: () => controller.handleSocialLogin(SocialLoginType.qq, qqLabel),
            icon: FontAwesomeIcons.qq,
            color: LoginConstants.qqBlue,
            label: qqLabel,
          ),
        ],
      );
    }

    return Row(
      children: [
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.apple, appleLabel),
          icon: FontAwesomeIcons.apple,
          color: Colors.black,
          label: appleLabel,
        ),
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.google, googleLabel),
          icon: FontAwesomeIcons.google,
          color: LoginConstants.googleRed,
          label: googleLabel,
        ),
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.wechat, wechatLabel),
          icon: FontAwesomeIcons.weixin,
          color: LoginConstants.wechatGreen,
          label: wechatLabel,
        ),
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.qq, qqLabel),
          icon: FontAwesomeIcons.qq,
          color: LoginConstants.qqBlue,
          label: qqLabel,
        ),
      ],
    );
  }
}

/// 国际区社交登录按钮
class _InternationalSocialButtons extends GetView<LoginController> {
  final LoginSocialCopy? copy;

  const _InternationalSocialButtons({this.copy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final googleLabel = LoginSocialButtons.resolveCopy(copy?.googleLabel, 'Google');
    final appleLabel = LoginSocialButtons.resolveCopy(copy?.appleLabel, 'Apple');
    final twitterLabel = LoginSocialButtons.resolveCopy(copy?.twitterLabel, 'Twitter');
    final facebookLabel = LoginSocialButtons.resolveCopy(copy?.facebookLabel, 'Facebook');
    final facebookUnavailableTitle =
        LoginSocialButtons.resolveCopy(copy?.facebookUnavailableTitle, l10n.continueWithFacebook);
    final facebookUnavailableMessage =
        LoginSocialButtons.resolveCopy(copy?.facebookUnavailableMessage, l10n.profileEditingComingSoon);

    return Row(
      children: [
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.google, googleLabel),
          icon: FontAwesomeIcons.google,
          color: LoginConstants.googleRed,
          label: googleLabel,
        ),
        // Apple 登录仅在 iOS 上显示
        if (Platform.isIOS)
          _SocialButton(
            onPressed: () => controller.handleSocialLogin(SocialLoginType.apple, appleLabel),
            icon: FontAwesomeIcons.apple,
            color: Colors.black,
            label: appleLabel,
          ),
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.twitter, twitterLabel),
          icon: FontAwesomeIcons.xTwitter,
          color: Colors.black,
          label: twitterLabel,
        ),
        _SocialButton(
          onPressed: () => AppToast.info(facebookUnavailableMessage, title: facebookUnavailableTitle),
          icon: FontAwesomeIcons.facebook,
          color: LoginConstants.facebookBlue,
          label: facebookLabel,
        ),
      ],
    );
  }
}

/// 社交登录按钮
class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String label;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icon, size: LoginConstants.iconSize, color: color),
                SizedBox(height: 6.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
