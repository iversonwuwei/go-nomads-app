import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/services/social_login_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 社交登录按钮组
class LoginSocialButtons extends GetView<LoginController> {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 分隔线
        _Divider(),
        SizedBox(height: 24.h),
        // 社交登录按钮
        if (controller.isChineseUser) _ChineseSocialButtons() else _InternationalSocialButtons(),
      ],
    );
  }
}

/// 分隔线
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            AppLocalizations.of(context)!.orContinueWith,
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SocialButton(
          onPressed: () =>
              controller.handleSocialLogin(SocialLoginType.wechat, AppLocalizations.of(Get.context!)!.wechat),
          icon: FontAwesomeIcons.weixin,
          color: LoginConstants.wechatGreen,
          label: AppLocalizations.of(Get.context!)!.wechat,
        ),
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.qq, 'QQ'),
          icon: FontAwesomeIcons.qq,
          color: LoginConstants.qqBlue,
          label: 'QQ',
        ),
        // Apple 登录仅在 iOS 上显示（Apple Review 要求）
        if (Platform.isIOS)
          _SocialButton(
            onPressed: () => controller.handleSocialLogin(SocialLoginType.apple, 'Apple'),
            icon: FontAwesomeIcons.apple,
            color: Colors.black,
            label: 'Apple',
          ),
      ],
    );
  }
}

/// 国际区社交登录按钮
class _InternationalSocialButtons extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.google, 'Google'),
          icon: FontAwesomeIcons.google,
          color: LoginConstants.googleRed,
          label: 'Google',
        ),
        // Apple 登录仅在 iOS 上显示（Apple Review 要求）
        if (Platform.isIOS)
          _SocialButton(
            onPressed: () => controller.handleSocialLogin(SocialLoginType.apple, 'Apple'),
            icon: FontAwesomeIcons.apple,
            color: Colors.black,
            label: 'Apple',
          ),
        _SocialButton(
          onPressed: () => controller.handleSocialLogin(SocialLoginType.twitter, 'Twitter'),
          icon: FontAwesomeIcons.xTwitter,
          color: Colors.black,
          label: 'Twitter',
        ),
        _SocialButton(
          onPressed: () => AppToast.info(l10n.profileEditingComingSoon, title: l10n.continueWithFacebook),
          icon: FontAwesomeIcons.facebook,
          color: LoginConstants.facebookBlue,
          label: 'Facebook',
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
