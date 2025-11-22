import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../features/auth/presentation/controllers/auth_state_controller.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';
import '../services/http_service.dart';
import '../widgets/app_toast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  // Nomads.com 品牌红色
  static const Color nomadsRed = Color(0xFFFF4458);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.warning(
          l10n.pleaseAgreeToTerms,
          title: l10n.termsRequired,
        );
        return;
      }

      setState(() {
        _isRegistering = true;
      });

      try {
        final l10n = AppLocalizations.of(context)!;

        // 调用 AuthStateController 注册
        final authController = Get.find<AuthStateController>();
        final success = await authController.register(
          name: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        if (success) {
          // 注册成功
          final user = authController.currentUser.value;
          print('✅ 注册成功: ${user?.name}');

          AppToast.success(
            l10n.welcomeToCommunity,
            title: l10n.success,
          );

          // 延迟一下让用户看到成功提示
          await Future.delayed(const Duration(milliseconds: 500));

          // 注册成功后跳转到主页 (已自动登录)
          Get.offAllNamed('/');
        } else {
          // 注册失败
          print('❌ 注册失败');
          AppToast.error(
            '注册失败,请检查输入信息',
            title: '注册失败',
          );
        }
      } on HttpException catch (e) {
        // HTTP 异常 - 显示后端返回的错误信�?
        print('�?注册失败 (HttpException): ${e.message}');
        AppToast.error(
          e.message,
          title: '注册失败',
        );
      } catch (e) {
        // 其他错误
        print('�?注册错误: $e');
        AppToast.error(
          '注册过程中发生错误，请稍后重�?',
          title: '错误',
        );
      } finally {
        if (mounted) {
          setState(() {
            _isRegistering = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo 和标�?
                  Center(
                    child: Column(
                      children: [
                        // Logo 图标
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color:
                                RegisterPage.nomadsRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.travel_explore,
                            size: 40,
                            color: RegisterPage.nomadsRed,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 标题
                        Text(
                          '🌍 ${l10n.goNomad}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 副标�?
                        Text(
                          l10n.joinGlobalCommunity,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 用户名输�?
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      hintText: l10n.chooseUsername,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: RegisterPage.nomadsRed,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.usernameRequired;
                      }
                      if (value.length < 3) {
                        return l10n.usernameMinLength;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 邮箱输入
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      hintText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: RegisterPage.nomadsRed,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.email;
                      }
                      if (!GetUtils.isEmail(value)) {
                        return l10n.email;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 密码输入
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      hintText: l10n.createPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: RegisterPage.nomadsRed,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.password;
                      }
                      if (value.length < 6) {
                        return l10n.password;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 确认密码输入
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPassword,
                      hintText: l10n.reenterPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: RegisterPage.nomadsRed,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.confirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsNotMatch;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // 服务条款复选框
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: RegisterPage.nomadsRed,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(text: '${l10n.agreeToTerms} '),
                                  TextSpan(
                                    text: l10n.termsOfService,
                                    style: const TextStyle(
                                      color: RegisterPage.nomadsRed,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(text: ' ${l10n.and} '),
                                  TextSpan(
                                    text: l10n.communityGuidelines,
                                    style: TextStyle(
                                      color: RegisterPage.nomadsRed,
                                      decoration: TextDecoration.underline,
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

                  const SizedBox(height: 32),

                  // 注册按钮
                  ElevatedButton(
                    onPressed: _isRegistering ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RegisterPage.nomadsRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isRegistering
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.joinNomads,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // 分隔�?
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.orContinueWith,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 社交登录按钮 - 第一行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info(
                            l10n.googleAuthComingSoon,
                            title: l10n.googleSignIn,
                          );
                        },
                        icon: FontAwesomeIcons.google,
                        color: const Color(0xFFDB4437), // Google Red
                        label: 'Google',
                      ),
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info(
                            l10n.appleAuthComingSoon,
                            title: l10n.appleSignIn,
                          );
                        },
                        icon: FontAwesomeIcons.apple,
                        color: Colors.black,
                        label: 'Apple',
                      ),
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info('WeChat Sign In', title: 'WeChat');
                        },
                        icon: FontAwesomeIcons.weixin, // WeChat icon
                        color: const Color(0xFF09BB07), // WeChat Green
                        label: 'WeChat',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 社交登录按钮 - 第二行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info('Twitter Sign In', title: 'Twitter');
                        },
                        icon: FontAwesomeIcons.xTwitter, // X/Twitter icon
                        color: Colors.black,
                        label: 'Twitter',
                      ),
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info('Alipay Sign In', title: 'Alipay');
                        },
                        icon: FontAwesomeIcons.alipay,
                        color: const Color(0xFF1677FF), // Alipay Blue
                        label: 'Alipay',
                      ),
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info('QQ Sign In', title: 'QQ');
                        },
                        icon: FontAwesomeIcons.qq,
                        color: const Color(0xFF12B7F5), // QQ Blue
                        label: 'QQ',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 社交登录按钮 - 第三行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info('TikTok Sign In', title: 'TikTok');
                        },
                        icon: FontAwesomeIcons.tiktok,
                        color: Colors.black,
                        label: 'TikTok',
                      ),
                      _buildSocialLoginButton(
                        onPressed: () {
                          AppToast.info('Phone Sign In', title: 'Phone');
                        },
                        icon: FontAwesomeIcons.mobile,
                        color: const Color(0xFF4CAF50), // Green for phone
                        label: 'Phone',
                      ),
                      // 占位,保持对齐
                      const SizedBox(width: 100),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 已有账号提示
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l10n.alreadyHaveAccount} ',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.login);
                          },
                          child: Text(
                            l10n.login,
                            style: TextStyle(
                              color: RegisterPage.nomadsRed,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 社区亮点
                  _buildFeatureHighlights(),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.joinMembers,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              '🍹',
              l10n.attendMeetups,
              l10n.inCitiesWorldwide,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '❤️',
              l10n.meetNewPeople,
              l10n.forDatingAndFriends,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '🧪',
              l10n.researchDestinations,
              l10n.findBestPlace,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '💬',
              l10n.joinExclusiveChat,
              l10n.messagesSentThisMonth,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '🗺️',
              l10n.trackTravels,
              l10n.shareJourney,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeatureItem(String emoji, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
