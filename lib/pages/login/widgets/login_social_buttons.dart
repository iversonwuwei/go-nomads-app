import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
        const SizedBox(height: 24),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
    return Column(
      children: [
        Row(
          children: [
            _SocialButton(
              onPressed: () => controller.handleSocialLogin(SocialLoginType.wechat, '微信'),
              icon: FontAwesomeIcons.weixin,
              color: LoginConstants.wechatGreen,
              label: '微信',
            ),
            _SocialButton(
              onPressed: () => controller.handleSocialLogin(SocialLoginType.alipay, '支付宝'),
              icon: FontAwesomeIcons.alipay,
              color: LoginConstants.alipayBlue,
              label: '支付宝',
            ),
            _SocialButton(
              onPressed: () => controller.handleSocialLogin(SocialLoginType.qq, 'QQ'),
              icon: FontAwesomeIcons.qq,
              color: LoginConstants.qqBlue,
              label: 'QQ',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              onPressed: () => controller.setLoginMode(LoginMode.phone),
              icon: FontAwesomeIcons.mobile,
              color: LoginConstants.phoneGreen,
              label: '手机号',
            ),
          ],
        ),
      ],
    );
  }
}

/// 国际区社交登录按钮
class _InternationalSocialButtons extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _SocialButton(
              onPressed: () => AppToast.info('Google Sign In coming soon', title: 'Google'),
              icon: FontAwesomeIcons.google,
              color: LoginConstants.googleRed,
              label: 'Google',
            ),
            _SocialButton(
              onPressed: () => AppToast.info('Apple Sign In coming soon', title: 'Apple'),
              icon: FontAwesomeIcons.apple,
              color: Colors.black,
              label: 'Apple',
            ),
            _SocialButton(
              onPressed: () => AppToast.info('Twitter Sign In coming soon', title: 'Twitter'),
              icon: FontAwesomeIcons.xTwitter,
              color: Colors.black,
              label: 'Twitter',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SocialButton(
              onPressed: () => controller.setLoginMode(LoginMode.phone),
              icon: FontAwesomeIcons.mobile,
              color: LoginConstants.phoneGreen,
              label: 'Phone',
            ),
            _SocialButton(
              onPressed: () => AppToast.info('Facebook Sign In coming soon', title: 'Facebook'),
              icon: FontAwesomeIcons.facebook,
              color: LoginConstants.facebookBlue,
              label: 'Facebook',
            ),
            _SocialButton(
              onPressed: () => AppToast.info('TikTok Sign In coming soon', title: 'TikTok'),
              icon: FontAwesomeIcons.tiktok,
              color: Colors.black,
              label: 'TikTok',
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icon, size: LoginConstants.iconSize, color: color),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
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
