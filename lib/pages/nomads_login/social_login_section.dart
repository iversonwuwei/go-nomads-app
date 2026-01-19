import 'package:go_nomads_app/controllers/nomads_login_page_controller.dart';
import 'package:go_nomads_app/services/social_login_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 社交登录按钮部分
class SocialLoginSection extends StatelessWidget {
  final String controllerTag;

  const SocialLoginSection({super.key, required this.controllerTag});

  NomadsLoginPageController get _c => Get.find<NomadsLoginPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 分隔线
        Row(
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
        ),

        const SizedBox(height: 24),

        // 社交登录按钮
        ..._buildSocialLoginButtons(),
      ],
    );
  }

  List<Widget> _buildSocialLoginButtons() {
    if (_c.isChineseUser) {
      return [
        // 第一行：微信、支付宝、QQ
        Row(
          children: [
            _buildSocialButton(
              onPressed: () => _c.handleSocialLogin(SocialLoginType.wechat, '微信'),
              icon: FontAwesomeIcons.weixin,
              color: const Color(0xFF09BB07),
              label: '微信',
            ),
            _buildSocialButton(
              onPressed: () => _c.handleSocialLogin(SocialLoginType.alipay, '支付宝'),
              icon: FontAwesomeIcons.alipay,
              color: const Color(0xFF1677FF),
              label: '支付宝',
            ),
            _buildSocialButton(
              onPressed: () => _c.handleSocialLogin(SocialLoginType.qq, 'QQ'),
              icon: FontAwesomeIcons.qq,
              color: const Color(0xFF12B7F5),
              label: 'QQ',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 第二行：手机号
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              onPressed: () => _c.setLoginMode(LoginMode.phone),
              icon: FontAwesomeIcons.mobile,
              color: const Color(0xFF4CAF50),
              label: '手机号',
            ),
          ],
        ),
      ];
    } else {
      return [
        // 第一行：Google、Apple、Twitter
        Row(
          children: [
            _buildSocialButton(
              onPressed: () => AppToast.info('Google Sign In coming soon', title: 'Google'),
              icon: FontAwesomeIcons.google,
              color: const Color(0xFFDB4437),
              label: 'Google',
            ),
            _buildSocialButton(
              onPressed: () => AppToast.info('Apple Sign In coming soon', title: 'Apple'),
              icon: FontAwesomeIcons.apple,
              color: Colors.black,
              label: 'Apple',
            ),
            _buildSocialButton(
              onPressed: () => AppToast.info('Twitter Sign In coming soon', title: 'Twitter'),
              icon: FontAwesomeIcons.xTwitter,
              color: Colors.black,
              label: 'Twitter',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 第二行：Phone、Facebook、TikTok
        Row(
          children: [
            _buildSocialButton(
              onPressed: () => _c.setLoginMode(LoginMode.phone),
              icon: FontAwesomeIcons.mobile,
              color: const Color(0xFF4CAF50),
              label: 'Phone',
            ),
            _buildSocialButton(
              onPressed: () => AppToast.info('Facebook Sign In coming soon', title: 'Facebook'),
              icon: FontAwesomeIcons.facebook,
              color: const Color(0xFF1877F2),
              label: 'Facebook',
            ),
            _buildSocialButton(
              onPressed: () => AppToast.info('TikTok Sign In coming soon', title: 'TikTok'),
              icon: FontAwesomeIcons.tiktok,
              color: Colors.black,
              label: 'TikTok',
            ),
          ],
        ),
      ];
    }
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icon, size: 28, color: color),
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

/// 社区亮点部分
class CommunityHighlightSection extends StatelessWidget {
  const CommunityHighlightSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NomadsLoginPageController.nomadsRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.userGroup,
                  color: NomadsLoginPageController.nomadsRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join 38,000+ nomads',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    Text(
                      'Living and working around the world',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureBadge('🍹', '363 meetups/year'),
              const SizedBox(width: 8),
              _buildFeatureBadge('💬', '15k+ messages'),
              const SizedBox(width: 8),
              _buildFeatureBadge('🌍', '100+ cities'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String emoji, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
