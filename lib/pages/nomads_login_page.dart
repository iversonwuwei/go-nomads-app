import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/locale_controller.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/social_login_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 登录模式
enum LoginMode {
  email, // 邮箱+密码
  phone, // 手机号+验证码
}

class NomadsLoginPage extends StatefulWidget {
  const NomadsLoginPage({super.key});

  // Nomads.com 品牌红色
  static const Color nomadsRed = Color(0xFFFF4458);

  @override
  State<NomadsLoginPage> createState() => _NomadsLoginPageState();
}

class _NomadsLoginPageState extends State<NomadsLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _tokenStorageService = TokenStorageService();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  LoginMode _loginMode = LoginMode.email;

  // 验证码倒计时
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  /// 加载「记住我」数据
  Future<void> _loadRememberMe() async {
    final rememberMe = await _tokenStorageService.getRememberMe();
    final savedEmail = await _tokenStorageService.getSavedEmail();

    if (mounted) {
      setState(() {
        _rememberMe = rememberMe;
        if (rememberMe && savedEmail != null && savedEmail.isNotEmpty) {
          _emailController.text = savedEmail;
          log('📥 已恢复保存的邮箱: $savedEmail');
        }
      });
    }
  }

  /// 判断是否为中国区用户
  bool get _isChineseUser {
    try {
      final localeController = Get.find<LocaleController>();
      final locale = localeController.locale.value;
      return locale.languageCode == 'zh' ||
          locale.countryCode == 'CN' ||
          locale.countryCode == 'HK' ||
          locale.countryCode == 'MO' ||
          locale.countryCode == 'TW';
    } catch (_) {
      final systemLocale = Get.deviceLocale;
      return systemLocale?.languageCode == 'zh';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.warning('请输入手机号', title: '提示');
      return;
    }

    // 简单验证手机号格式
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      AppToast.warning('请输入正确的手机号', title: '提示');
      return;
    }

    try {
      // 调用后端发送验证码 API
      final httpService = Get.find<HttpService>();
      final response = await httpService.post(
        '/auth/sms/send-code',
        data: {
          'phoneNumber': '+86$phone',
          'purpose': 'login',
        },
      );

      if (response.data['success'] == true) {
        AppToast.success('验证码已发送', title: '成功');

        // 开始倒计时
        setState(() {
          _countdown = 60;
        });

        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _countdown--;
          });
          if (_countdown <= 0) {
            timer.cancel();
          }
        });
      } else {
        AppToast.error(response.data['message'] ?? '发送失败', title: '错误');
      }
    } catch (e) {
      log('❌ 发送验证码失败: $e');
      AppToast.error('发送验证码失败', title: '错误');
    }
  }

  /// 手机号登录
  Future<void> _loginWithPhone() async {
    final phone = _phoneController.text.trim();
    final code = _smsCodeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      AppToast.warning('请输入手机号和验证码', title: '提示');
      return;
    }

    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: NomadsLoginPage.nomadsRed,
        ),
      ),
    );

    try {
      log('🔐 开始手机号登录..');
      log('   手机号: $phone');

      // 调用后端手机号登录 API
      final authController = Get.find<AuthStateController>();
      final success = await authController.loginWithPhone(
        phone: '+86$phone',
        code: code,
      );

      log('📝 loginWithPhone 返回值: $success');

      if (mounted) {
        Navigator.pop(context);
      }

      if (success) {
        final user = authController.currentUser.value;
        log('✅ 手机号登录成功: ${user?.name}');

        AppToast.success('欢迎回来！', title: '登录成功');

        await Future.delayed(const Duration(milliseconds: 500));
        log('🚀 准备跳转到主页...');
        Get.offAllNamed('/');
        log('✅ 跳转命令已执行');
      } else {
        log('❌ 登录返回 false');
        AppToast.error('登录失败，请重试', title: '错误');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      log('❌ 手机号登录失败: $e');

      // 简化验证码相关的错误提示
      String errorMessage = '登录失败，请重试';
      if (e is DioException && e.error is HttpException) {
        final httpError = e.error as HttpException;
        // 验证码相关错误显示简洁提示
        if (httpError.message.contains('验证码')) {
          errorMessage = '验证码无效或已过期';
        } else {
          errorMessage = httpError.message;
        }
      } else if (e.toString().contains('验证码')) {
        errorMessage = '验证码无效或已过期';
      }

      AppToast.error(errorMessage, title: '错误');
    }
  }

  /// 处理社交登录
  Future<void> _handleSocialLogin(SocialLoginType type, String platformName) async {
    log('📱 开始 $platformName 登录...');

    try {
      final authController = Get.find<AuthStateController>();
      final success = await authController.socialLogin(type);

      if (success) {
        final user = authController.currentUser.value;
        log('✅ $platformName 登录成功: ${user?.name}');

        AppToast.success(
          '欢迎回来！',
          title: '登录成功',
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/');
      }
    } catch (e) {
      log('❌ $platformName 登录异常: $e');
      AppToast.error(
        '$platformName 登录失败，请稍后重试',
        title: '登录失败',
      );
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: NomadsLoginPage.nomadsRed,
          ),
        ),
      );

      try {
        log('🔐 开始登录验证..');
        log('   邮箱: ${_emailController.text.trim()}');

        // 调用 AuthStateController 登录
        final authController = Get.find<AuthStateController>();
        final success = await authController.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // 关闭加载指示器
        if (mounted) {
          Navigator.pop(context);
        }

        if (success) {
          // 登录成功 - 从 AuthStateController 获取当前用户
          final user = authController.currentUser.value;

          if (user == null) {
            // 用户数据为空
            log('❌ 登录失败: 用户数据为空');
            AppToast.error(
              'Failed to load user data',
              title: 'Login Failed',
            );
            return;
          }

          log('🎉 登录成功');
          log('   用户ID: ${user.id}');
          log('   用户名: ${user.name}');
          log('   邮箱: ${user.email}');

          // 保存「记住我」状态
          await _tokenStorageService.saveRememberMe(
            rememberMe: _rememberMe,
            email: _emailController.text.trim(),
          );
          log('✅ 用户登录成功，记住我: $_rememberMe');

          AppToast.success(
            'Welcome back, ${user.name}!',
            title: 'Login Successful',
          );

          // 等待一小段时间，确保登录状态事件已被处理
          await Future.delayed(const Duration(milliseconds: 300));

          // 登录成功后跳转到主页
          log('🚀 准备跳转到主页..');
          Get.offAllNamed('/');
        } else {
          // 登录失败
          log('❌ 登录失败');
          AppToast.error(
            'Invalid email or password',
            title: 'Login Failed',
          );
        }
      } on HttpException catch (e) {
        // 关闭加载指示器
        if (mounted) {
          Navigator.pop(context);
        }

        log('❌ HTTP 错误: ${e.message}');
        AppToast.error(
          e.message,
          title: 'Network Error',
        );
      } catch (e) {
        // 关闭加载指示器
        if (mounted) {
          Navigator.pop(context);
        }

        log('❌ 登录错误: $e');
        AppToast.error(
          'An error occurred. Please try again.',
          title: 'Error',
        );
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
                  // 返回按钮
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.arrowLeft,
                        color: NomadsLoginPage.nomadsRed,
                      ),
                      onPressed: () {
                        // 返回到主页
                        Get.offAllNamed('/'); // 跳转到主页
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logo 和标题
                  Center(
                    child: Column(
                      children: [
                        // Logo 图标
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: NomadsLoginPage.nomadsRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            FontAwesomeIcons.earthAmericas,
                            size: 40,
                            color: NomadsLoginPage.nomadsRed,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 标题
                        Text(
                          l10n.welcome,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 副标题
                        Text(
                          l10n.login,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 登录模式切换
                  if (_loginMode == LoginMode.phone) ...[
                    // 手机号输入
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: '手机号',
                        hintText: '请输入手机号',
                        prefixIcon: const Icon(FontAwesomeIcons.phone),
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
                            color: NomadsLoginPage.nomadsRed,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入手机号';
                        }
                        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                          return '请输入正确的手机号';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 验证码输入
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _smsCodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: '验证码',
                              hintText: '请输入验证码',
                              counterText: '',
                              prefixIcon: const Icon(FontAwesomeIcons.message),
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
                                  color: NomadsLoginPage.nomadsRed,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入验证码';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _countdown > 0 ? null : _sendSmsCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NomadsLoginPage.nomadsRed,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _countdown > 0 ? '${_countdown}s' : '发送验证码',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 手机登录按钮
                    ElevatedButton(
                      onPressed: _loginWithPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NomadsLoginPage.nomadsRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 切换到邮箱登录
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _loginMode = LoginMode.email;
                          });
                        },
                        child: const Text(
                          '使用邮箱密码登录',
                          style: TextStyle(
                            color: NomadsLoginPage.nomadsRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 邮箱输入
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        hintText: l10n.email,
                        prefixIcon: const Icon(FontAwesomeIcons.envelope),
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
                            color: NomadsLoginPage.nomadsRed,
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
                        hintText: l10n.password,
                        prefixIcon: const Icon(FontAwesomeIcons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
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
                            color: NomadsLoginPage.nomadsRed,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.password;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 记住我 & 忘记密码
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: NomadsLoginPage.nomadsRed,
                            ),
                            Text(
                              l10n.rememberMe,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            AppToast.info(
                              l10n.forgotPassword,
                              title: l10n.forgotPassword,
                            );
                          },
                          child: Text(
                            l10n.forgotPassword,
                            style: const TextStyle(
                              fontSize: 14,
                              color: NomadsLoginPage.nomadsRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 登录按钮
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NomadsLoginPage.nomadsRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.login,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 分隔线
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
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

                  // 社交登录按钮 - 根据地区显示不同的按钮
                  ..._buildSocialLoginButtons(),

                  const SizedBox(height: 32),

                  // 注册提示
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Let's Go",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.register);
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: NomadsLoginPage.nomadsRed,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 社区亮点提示
                  _buildCommunityHighlight(),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 根据地区构建社交登录按钮列表
  List<Widget> _buildSocialLoginButtons() {
    final isChinese = _isChineseUser;

    if (isChinese) {
      // 国内用户：微信、支付宝、QQ、手机号
      return [
        // 第一行
        Row(
          children: [
            _buildSocialLoginButton(
              onPressed: () => _handleSocialLogin(SocialLoginType.wechat, '微信'),
              icon: FontAwesomeIcons.weixin,
              color: const Color(0xFF09BB07), // WeChat Green
              label: '微信',
            ),
            _buildSocialLoginButton(
              onPressed: () => _handleSocialLogin(SocialLoginType.alipay, '支付宝'),
              icon: FontAwesomeIcons.alipay,
              color: const Color(0xFF1677FF), // Alipay Blue
              label: '支付宝',
            ),
            _buildSocialLoginButton(
              onPressed: () => _handleSocialLogin(SocialLoginType.qq, 'QQ'),
              icon: FontAwesomeIcons.qq,
              color: const Color(0xFF12B7F5), // QQ Blue
              label: 'QQ',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 第二行
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialLoginButton(
              onPressed: () {
                setState(() {
                  _loginMode = LoginMode.phone;
                });
              },
              icon: FontAwesomeIcons.mobile,
              color: const Color(0xFF4CAF50),
              label: '手机号',
            ),
          ],
        ),
      ];
    } else {
      // 国外用户：Google、Apple、Twitter、手机号
      return [
        // 第一行
        Row(
          children: [
            _buildSocialLoginButton(
              onPressed: () {
                AppToast.info('Google Sign In coming soon', title: 'Google');
              },
              icon: FontAwesomeIcons.google,
              color: const Color(0xFFDB4437), // Google Red
              label: 'Google',
            ),
            _buildSocialLoginButton(
              onPressed: () {
                AppToast.info('Apple Sign In coming soon', title: 'Apple');
              },
              icon: FontAwesomeIcons.apple,
              color: Colors.black,
              label: 'Apple',
            ),
            _buildSocialLoginButton(
              onPressed: () {
                AppToast.info('Twitter Sign In coming soon', title: 'Twitter');
              },
              icon: FontAwesomeIcons.xTwitter,
              color: Colors.black,
              label: 'Twitter',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 第二行
        Row(
          children: [
            _buildSocialLoginButton(
              onPressed: () {
                setState(() {
                  _loginMode = LoginMode.phone;
                });
              },
              icon: FontAwesomeIcons.mobile,
              color: const Color(0xFF4CAF50),
              label: 'Phone',
            ),
            _buildSocialLoginButton(
              onPressed: () {
                AppToast.info('Facebook Sign In coming soon', title: 'Facebook');
              },
              icon: FontAwesomeIcons.facebook,
              color: const Color(0xFF1877F2), // Facebook Blue
              label: 'Facebook',
            ),
            _buildSocialLoginButton(
              onPressed: () {
                AppToast.info('TikTok Sign In coming soon', title: 'TikTok');
              },
              icon: FontAwesomeIcons.tiktok,
              color: Colors.black,
              label: 'TikTok',
            ),
          ],
        ),
      ];
    }
  }

  Widget _buildSocialLoginButton({
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

  Widget _buildCommunityHighlight() {
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
                  color: NomadsLoginPage.nomadsRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.userGroup,
                  color: NomadsLoginPage.nomadsRed,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Living and working around the world',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
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
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 30, // 固定文字区域高度，确保所有卡片一样高
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
