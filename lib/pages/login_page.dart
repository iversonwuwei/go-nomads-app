import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo和标题
                _buildHeader(),

                const SizedBox(height: 40),

                // 认证模式切换
                _buildAuthModeTabs(controller),

                const SizedBox(height: 30),

                // 表单内容
                Obx(() => _buildFormContent(controller)),

                const SizedBox(height: 30),

                // 主要操作按钮
                _buildMainButton(controller),

                const SizedBox(height: 20),

                // 第三方登录
                Obx(() {
                  if (controller.authMode.value == AuthMode.login) {
                    return _buildThirdPartyLogin(controller);
                  }
                  return const SizedBox();
                }),

                const SizedBox(height: 20),

                // 底部链接
                _buildBottomLinks(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 欢迎文字
        const Center(
          child: Text(
            '数金数据',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            '欢迎来到数金数据，开始您的购物之旅',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthModeTabs(AuthController controller) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildTabButton(
                '登录',
                controller.authMode.value == AuthMode.login,
                () => controller.switchAuthMode(AuthMode.login),
              ),
              _buildTabButton(
                '注册',
                controller.authMode.value == AuthMode.register,
                () => controller.switchAuthMode(AuthMode.register),
              ),
              _buildTabButton(
                '找回密码',
                controller.authMode.value == AuthMode.forgotPassword,
                () => controller.switchAuthMode(AuthMode.forgotPassword),
              ),
            ],
          ),
        ));
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(AuthController controller) {
    switch (controller.authMode.value) {
      case AuthMode.login:
        return _buildLoginForm(controller);
      case AuthMode.register:
        return _buildRegisterForm(controller);
      case AuthMode.forgotPassword:
        return _buildForgotPasswordForm(controller);
    }
  }

  Widget _buildLoginForm(AuthController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // 登录方式切换
          _buildLoginTypeTabs(controller),
          const SizedBox(height: 24),

          // 手机号输入
          _buildPhoneField(controller),
          const SizedBox(height: 16),

          // 密码或验证码输入
          Obx(() {
            if (controller.loginType.value == LoginType.phonePassword) {
              return _buildPasswordField(controller);
            } else {
              return _buildCodeField(controller);
            }
          }),

          const SizedBox(height: 16),

          // 忘记密码链接
          Obx(() {
            if (controller.loginType.value == LoginType.phonePassword) {
              return Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      controller.switchAuthMode(AuthMode.forgotPassword),
                  child: Text(
                    '忘记密码？',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // 手机号输入
          _buildPhoneField(controller),
          const SizedBox(height: 16),

          // 验证码输入
          _buildCodeField(controller),
          const SizedBox(height: 16),

          // 密码输入
          _buildPasswordField(controller),
          const SizedBox(height: 16),

          // 确认密码输入
          _buildConfirmPasswordField(controller),
          const SizedBox(height: 16),

          // 用户协议
          _buildAgreementCheckbox(controller),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordForm(AuthController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // 手机号输入
          _buildPhoneField(controller),
          const SizedBox(height: 16),

          // 验证码输入
          _buildCodeField(controller),
          const SizedBox(height: 16),

          // 新密码输入
          _buildPasswordField(controller, label: '新密码'),
          const SizedBox(height: 16),

          // 确认新密码输入
          _buildConfirmPasswordField(controller, label: '确认新密码'),
        ],
      ),
    );
  }

  Widget _buildLoginTypeTabs(AuthController controller) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildLoginTypeTab(
                '密码登录',
                controller.loginType.value == LoginType.phonePassword,
                () => controller.switchLoginType(LoginType.phonePassword),
              ),
              _buildLoginTypeTab(
                '验证码登录',
                controller.loginType.value == LoginType.phoneCode,
                () => controller.switchLoginType(LoginType.phoneCode),
              ),
            ],
          ),
        ));
  }

  Widget _buildLoginTypeTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(AuthController controller) {
    return TextFormField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      decoration: InputDecoration(
        labelText: '手机号',
        prefixIcon: const Icon(Icons.phone_android),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!),
        ),
      ),
      validator: controller.phoneValidator,
    );
  }

  Widget _buildPasswordField(AuthController controller, {String? label}) {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: !controller.isPasswordVisible.value,
          decoration: InputDecoration(
            labelText: label ?? '密码',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
          validator: controller.passwordValidator,
        ));
  }

  Widget _buildConfirmPasswordField(AuthController controller,
      {String? label}) {
    return Obx(() => TextFormField(
          controller: controller.confirmPasswordController,
          obscureText: !controller.isConfirmPasswordVisible.value,
          decoration: InputDecoration(
            labelText: label ?? '确认密码',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
          validator: controller.confirmPasswordValidator,
        ));
  }

  Widget _buildCodeField(AuthController controller) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: '验证码',
              prefixIcon: const Icon(Icons.sms_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
            ),
            validator: controller.codeValidator,
          ),
        ),
        const SizedBox(width: 12),
        Obx(() => SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: controller.canSendCode.value
                    ? controller.sendVerificationCode
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  controller.canSendCode.value
                      ? '发送'
                      : '${controller.codeCountdown.value}s',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildAgreementCheckbox(AuthController controller) {
    return Obx(() => Row(
          children: [
            Checkbox(
              value: controller.agreeToTerms.value,
              onChanged: (value) => controller.toggleAgreement(),
              activeColor: Colors.blue[600],
            ),
            Expanded(
              child: Wrap(
                children: [
                  const Text('我已阅读并同意'),
                  TextButton(
                    onPressed: () {
                      Get.snackbar('用户协议', '用户协议内容');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '《用户协议》',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ),
                  const Text('和'),
                  TextButton(
                    onPressed: () {
                      Get.snackbar('隐私政策', '隐私政策内容');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '《隐私政策》',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildMainButton(AuthController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    switch (controller.authMode.value) {
                      case AuthMode.login:
                        controller.login();
                        break;
                      case AuthMode.register:
                        controller.register();
                        break;
                      case AuthMode.forgotPassword:
                        controller.resetPassword();
                        break;
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _getButtonText(controller.authMode.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ));
  }

  String _getButtonText(AuthMode mode) {
    switch (mode) {
      case AuthMode.login:
        return '登录';
      case AuthMode.register:
        return '注册';
      case AuthMode.forgotPassword:
        return '重置密码';
    }
  }

  Widget _buildThirdPartyLogin(AuthController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '其他登录方式',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildThirdPartyButton(
              icon: Icons.wechat_outlined,
              label: '微信',
              color: Colors.green,
              onTap: () => controller.thirdPartyLogin(LoginType.wechat),
            ),
            _buildThirdPartyButton(
              icon: Icons.account_balance_wallet_outlined,
              label: '支付宝',
              color: Colors.blue[700]!,
              onTap: () => controller.thirdPartyLogin(LoginType.alipay),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThirdPartyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLinks(AuthController controller) {
    return Obx(() {
      if (controller.authMode.value == AuthMode.login) {
        return Center(
          child: TextButton(
            onPressed: () => controller.switchAuthMode(AuthMode.register),
            child: Text(
              '还没有账号？立即注册',
              style: TextStyle(color: Colors.blue[600]),
            ),
          ),
        );
      } else {
        return Center(
          child: TextButton(
            onPressed: () => controller.switchAuthMode(AuthMode.login),
            child: Text(
              '已有账号？立即登录',
              style: TextStyle(color: Colors.blue[600]),
            ),
          ),
        );
      }
    });
  }
}
