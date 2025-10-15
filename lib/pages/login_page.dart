import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLargeScreen
            ? _buildDesktopLayout(controller)
            : _buildMobileLayout(controller),
      ),
    );
  }

  Widget _buildDesktopLayout(AuthController controller) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildLeftContent(),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildLoginCard(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AuthController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),
                // Logo 区域
                Center(
                  child: Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'API',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                // 欢迎文字
                Text(
                  l10n.welcomeBack,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.loginToContinue,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 48.h),
                // 登录表单
                Obx(() => _buildLoginForm(controller, true)),
                SizedBox(height: 24.h),
                // 登录按钮
                _buildLoginButton(controller),
                SizedBox(height: 24.h),
                // 分隔线
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], height: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        l10n.orLoginWith,
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], height: 1),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // 第三方登录按钮
                _buildThirdPartyButtons(controller),
                SizedBox(height: 32.h),
                // 注册提示
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          AppToast.info(l10n.registerInDevelopment,
                              title: l10n.hint);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          minimumSize: Size(0, 32.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.registerNow,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeftContent() {
    return Padding(
      padding: EdgeInsets.all(60.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    'API',
                    style: TextStyle(
                      color: const Color(0xFF2C5364),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '数金 API 管理平台',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '提供企业级数字化开发者统一入口',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 80.h),
          Text(
            '一站式开放平台',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          Text(
            '驱动数字金融创新',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            '集成认证、支付、风控、数据等核心能力,提供安全可靠的 API 服务,精准助力企业上线、商用部署,打造有温度的开发者体验。',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              height: 1.8,
            ),
          ),
          SizedBox(height: 40.h),
          _buildFeatureItem(Icons.api, '统一 API / IP、标准化接口文档及接口工具'),
          SizedBox(height: 16.h),
          _buildFeatureItem(Icons.verified_user, '企业级权限管理与身份安全认证'),
          SizedBox(height: 16.h),
          _buildFeatureItem(Icons.speed, '实时接口调用监控版，精准提高价格'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(AuthController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return Container(
          width: 450.w,
          constraints: BoxConstraints(maxWidth: 500.w),
          padding: EdgeInsets.all(40.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeBack,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.secureLoginDescription,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              _buildLoginTypeTabs(controller),
              SizedBox(height: 24.h),
              Obx(() => _buildLoginForm(controller, false)),
              SizedBox(height: 24.h),
              _buildLoginButton(controller),
              SizedBox(height: 16.h),
              Center(
                child: TextButton(
                  onPressed: () {
                    AppToast.info('试用申请功能开发中', title: '提示');
                  },
                  child: Text(
                    '还没用过吗？申请试用',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '密码',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildThirdPartyButtons(controller),
              SizedBox(height: 20.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    AppToast.info('立即注册功能开发中', title: '提示');
                  },
                  child: RichText(
                    text: TextSpan(
                      text: '还没有账号？',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                      ),
                      children: [
                        TextSpan(
                          text: '立即注册',
                          style: TextStyle(
                            color: const Color(0xFF1890FF),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: Text(
                  '客服服务热线:400-123-456',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginTypeTabs(AuthController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return Obx(() => Row(
              children: [
                Expanded(
                  child: _buildLoginTypeTab(
                    l10n.passwordLogin,
                    controller.loginType.value == LoginType.phonePassword,
                    () => controller.switchLoginType(LoginType.phonePassword),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildLoginTypeTab(
                    l10n.verificationCodeLogin,
                    controller.loginType.value == LoginType.phoneCode,
                    () => controller.switchLoginType(LoginType.phoneCode),
                  ),
                ),
              ],
            ));
      },
    );
  }

  Widget _buildLoginTypeTab(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthController controller, bool isMobile) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 16.sp),
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  hintText: l10n.enterPhoneNumber,
                  prefixIcon: Icon(Icons.phone_android, size: 22.sp),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: Color(0xFF1976D2), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.red[300]!, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                validator: controller.phoneValidator,
              ),
              SizedBox(height: isMobile ? 16.h : 20.h),
              if (controller.loginType.value == LoginType.phonePassword)
                _buildPasswordField(controller)
              else
                _buildCodeField(controller),
              SizedBox(height: isMobile ? 12.h : 16.h),
              Row(
                children: [
                  Obx(() => Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: Checkbox(
                              value: controller.agreeToTerms.value,
                              onChanged: (value) =>
                                  controller.toggleAgreement(),
                              activeColor: const Color(0xFF1976D2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.rememberMe,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )),
                  const Spacer(),
                  if (controller.loginType.value == LoginType.phonePassword)
                    TextButton(
                      onPressed: () {
                        AppToast.info(l10n.forgotPasswordInDevelopment,
                            title: l10n.hint);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 32.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.forgotPasswordQuestion,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF1976D2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordField(AuthController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                labelText: l10n.password,
                hintText: l10n.enterPassword,
                prefixIcon: Icon(Icons.lock_outline, size: 22.sp),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 22.sp,
                    color: Colors.black38,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                      const BorderSide(color: Color(0xFF1976D2), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.red[300]!, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              validator: controller.passwordValidator,
            ));
      },
    );
  }

  Widget _buildCodeField(AuthController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.codeController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16.sp),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: l10n.verificationCode,
                  hintText: l10n.enterVerificationCode,
                  prefixIcon: Icon(Icons.sms_outlined, size: 22.sp),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: Color(0xFF1976D2), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.red[300]!, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                validator: controller.codeValidator,
              ),
            ),
            SizedBox(width: 12.w),
            Obx(() => SizedBox(
                  width: 110.w,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: controller.canSendCode.value
                        ? controller.sendVerificationCode
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1976D2),
                      elevation: 0,
                      side: BorderSide(
                        color: controller.canSendCode.value
                            ? const Color(0xFF1976D2)
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      disabledBackgroundColor: Colors.grey[100],
                      disabledForegroundColor: Colors.grey[400],
                    ),
                    child: Text(
                      controller.canSendCode.value
                          ? l10n.sendCode
                          : l10n.resendIn(
                              controller.codeCountdown.value.toString()),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildLoginButton(AuthController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return Obx(() => SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFF1976D2).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 22.w,
                        width: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.login,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ));
      },
    );
  }

  Widget _buildThirdPartyButtons(AuthController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.wechat,
          color: const Color(0xFF07C160),
          onTap: () => controller.thirdPartyLogin(LoginType.wechat),
        ),
        SizedBox(width: 24.w),
        _buildSocialButton(
          icon: Icons.apple,
          color: Colors.black87,
          onTap: () => controller.thirdPartyLogin(LoginType.alipay),
        ),
        SizedBox(width: 24.w),
        _buildSocialButton(
          icon: Icons.facebook,
          color: const Color(0xFF1877F2),
          onTap: () => controller.thirdPartyLogin(LoginType.alipay),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(
          icon,
          color: color,
          size: 28.sp,
        ),
      ),
    );
  }
}
