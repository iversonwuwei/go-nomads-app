import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/user_state_controller.dart';
import '../generated/app_localizations.dart';
import '../services/http_service.dart';
import '../services/nomads_auth_service.dart';
import '../widgets/app_toast.dart';

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

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        print('🔐 开始登录验证...');
        print('   邮箱: ${_emailController.text.trim()}');

        // 调用后端登录接口
        final nomadsAuthService = NomadsAuthService();
        final loginResponse = await nomadsAuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // 关闭加载指示器
        if (mounted) {
          Navigator.pop(context);
        }

        if (loginResponse.success && loginResponse.data != null) {
          // 登录成功
          final user = loginResponse.data!.user;

          print('🎉 登录成功！');
          print('   用户ID: ${user.id}');
          print('   用户名: ${user.name}');
          print('   邮箱: ${user.email}');

          // 保存用户状态到全局控制器
          try {
            final userStateController = Get.find<UserStateController>();
            // 注意：后端返回的是 String ID，需要转换或修改控制器
            // 这里暂时使用 hashCode 作为临时方案
            userStateController.login(
              user.id.hashCode,
              user.name,
              email: user.email,
            );
            print('✅ 用户状态已保存');
            print('🔔 登录状态变化事件将触发数据重新加载');
          } catch (e) {
            print('⚠️ 保存用户状态失败: $e');
          }

          AppToast.success(
            'Welcome back, ${user.name}!',
            title: 'Login Successful',
          );

          // 等待一小段时间，确保登录状态事件已被处理
          await Future.delayed(const Duration(milliseconds: 300));
          
          // 登录成功后跳转到主页
          print('🚀 准备跳转到主页...');
          Get.offAllNamed('/');
        } else {
          // 登录失败
          print('❌ 登录失败: ${loginResponse.message}');
          AppToast.error(
            loginResponse.message,
            title: 'Login Failed',
          );
        }
      } on HttpException catch (e) {
        // 关闭加载指示器
        if (mounted) {
          Navigator.pop(context);
        }

        print('❌ HTTP 错误: ${e.message}');
        AppToast.error(
          e.message,
          title: 'Network Error',
        );
      } catch (e) {
        // 关闭加载指示器
        if (mounted) {
          Navigator.pop(context);
        }
        
        print('❌ 登录错误: $e');
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
                        Icons.arrow_back,
                        color: NomadsLoginPage.nomadsRed,
                      ),
                      onPressed: () {
                        // 返回到主页
                        Get.back();
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
                            color: NomadsLoginPage.nomadsRed
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.travel_explore,
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

                  // 社交登录按钮
                  Row(
                    children: [
                      // Google 登录
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AppToast.info(
                              'Google authentication coming soon',
                              title: 'Google Sign In',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Google'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Apple 登录
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AppToast.info(
                              'Apple',
                              title: 'Apple',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.apple, size: 24),
                          label: const Text('Apple'),
                        ),
                      ),
                    ],
                  ),

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
                            Get.toNamed('/register');
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
                  Icons.group,
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
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
