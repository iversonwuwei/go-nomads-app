import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/pages/login/widgets/login_community_highlight.dart';
import 'package:go_nomads_app/pages/login/widgets/login_email_form.dart';
import 'package:go_nomads_app/pages/login/widgets/login_header.dart';
import 'package:go_nomads_app/pages/login/widgets/login_phone_form.dart';
import 'package:go_nomads_app/pages/login/widgets/login_register_link.dart';
import 'package:go_nomads_app/pages/login/widgets/login_social_buttons.dart';
import 'package:go_nomads_app/pages/login/widgets/login_terms_checkbox.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 登录页面 - 使用响应式验证，无需 GlobalKey
class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: LoginConstants.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo 和标题
                const LoginHeader(),

                SizedBox(height: 36.h),

                // 邮箱/手机号 书签式 Tab 切换
                const _LoginModeTabs(),

                SizedBox(height: 24.h),

                // 根据登录模式显示不同表单（带切换动画）
                Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: controller.loginMode.value == LoginMode.phone
                          ? const LoginPhoneForm(key: ValueKey('phone'))
                          : const LoginEmailForm(key: ValueKey('email')),
                    )),

                SizedBox(height: 24.h),

                // 用户协议勾选框（工信部/腾讯合规要求）
                const LoginTermsCheckbox(),

                SizedBox(height: 16.h),

                // 社交登录按钮
                const LoginSocialButtons(),

                SizedBox(height: 32.h),

                // 注册提示
                const LoginRegisterLink(),

                SizedBox(height: 32.h),

                // 社区亮点
                const LoginCommunityHighlight(),

                SizedBox(height: 24.h),

                // ICP 备案信息
                const CopyrightWidget(),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 书签式登录模式切换 Tab（滑动指示器方案）
class _LoginModeTabs extends StatefulWidget {
  const _LoginModeTabs();

  @override
  State<_LoginModeTabs> createState() => _LoginModeTabsState();
}

class _LoginModeTabsState extends State<_LoginModeTabs> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _emailIconScale;
  late Animation<double> _phoneIconScale;
  late Animation<Color?> _emailTextColor;
  late Animation<Color?> _phoneTextColor;

  final _controller = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
      value: _controller.loginMode.value == LoginMode.phone ? 1.0 : 0.0,
    );
    _setupAnimations();

    // 监听 loginMode 变化驱动动画
    ever(_controller.loginMode, (mode) {
      if (mode == LoginMode.phone) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _setupAnimations() {
    final curve = CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic);

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    // 图标缩放：选中时轻微弹跳
    _emailIconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6),
    ));
    _phoneIconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0),
    ));

    _emailTextColor = ColorTween(
      begin: LoginConstants.primaryColor,
      end: Colors.grey.shade500,
    ).animate(curve);
    _phoneTextColor = ColorTween(
      begin: Colors.grey.shade500,
      end: LoginConstants.primaryColor,
    ).animate(curve);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius),
      ),
      padding: EdgeInsets.all(4.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 2; // 减去 padding
          return Stack(
            children: [
              // 滑动白色指示器
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: 4.w + _slideAnimation.value * tabWidth,
                    top: 4.h,
                    bottom: 4.h,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(LoginConstants.buttonBorderRadius - 2),
                        boxShadow: [
                          BoxShadow(
                            color: LoginConstants.primaryColor.withValues(alpha: 0.10),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4.r,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Tab 按钮行
              Row(
                children: [
                  _buildTab(
                    label: '邮箱登录',
                    icon: Icons.email_outlined,
                    colorAnimation: _emailTextColor,
                    scaleAnimation: _emailIconScale,
                    onTap: () => _controller.setLoginMode(LoginMode.email),
                  ),
                  _buildTab(
                    label: '手机登录',
                    icon: Icons.phone_android_outlined,
                    colorAnimation: _phoneTextColor,
                    scaleAnimation: _phoneIconScale,
                    onTap: () => _controller.setLoginMode(LoginMode.phone),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required Animation<Color?> colorAnimation,
    required Animation<double> scaleAnimation,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: scaleAnimation.value,
                    child: Icon(
                      icon,
                      size: 18.r,
                      color: colorAnimation.value,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight:
                          colorAnimation.value == LoginConstants.primaryColor ? FontWeight.w600 : FontWeight.w400,
                      color: colorAnimation.value,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
