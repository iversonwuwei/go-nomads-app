import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/nomads_login_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 邮箱登录表单
class EmailLoginForm extends StatelessWidget {
  final String controllerTag;

  const EmailLoginForm({super.key, required this.controllerTag});

  NomadsLoginPageController get _c => Get.find<NomadsLoginPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 邮箱输入
        TextFormField(
          controller: _c.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.email,
            hintText: l10n.email,
            prefixIcon: const Icon(FontAwesomeIcons.envelope),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NomadsLoginPageController.nomadsRed, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return l10n.email;
            if (!GetUtils.isEmail(value)) return l10n.email;
            return null;
          },
        ),

        const SizedBox(height: 20),

        // 密码输入
        Obx(() => TextFormField(
              controller: _c.passwordController,
              obscureText: _c.obscurePassword.value,
              decoration: InputDecoration(
                labelText: l10n.password,
                hintText: l10n.password,
                prefixIcon: const Icon(FontAwesomeIcons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_c.obscurePassword.value ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash),
                  onPressed: _c.togglePasswordVisibility,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: NomadsLoginPageController.nomadsRed, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.password;
                return null;
              },
            )),

        const SizedBox(height: 16),

        // 记住我 & 忘记密码
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Obx(() => Checkbox(
                      value: _c.rememberMe.value,
                      onChanged: (value) => _c.setRememberMe(value ?? false),
                      activeColor: NomadsLoginPageController.nomadsRed,
                    )),
                Text(l10n.rememberMe, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.forgotPassword,
                style: const TextStyle(
                  fontSize: 14,
                  color: NomadsLoginPageController.nomadsRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 登录按钮
        ElevatedButton(
          onPressed: () => _c.loginWithEmail(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: NomadsLoginPageController.nomadsRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(l10n.login, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

/// 手机号登录表单
class PhoneLoginForm extends StatelessWidget {
  final String controllerTag;

  const PhoneLoginForm({super.key, required this.controllerTag});

  NomadsLoginPageController get _c => Get.find<NomadsLoginPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 手机号输入
        TextFormField(
          controller: _c.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: '手机号',
            hintText: '请输入手机号',
            prefixIcon: const Icon(FontAwesomeIcons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NomadsLoginPageController.nomadsRed, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入手机号';
            if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) return '请输入正确的手机号';
            return null;
          },
        ),

        const SizedBox(height: 20),

        // 验证码输入
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _c.smsCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: '验证码',
                  hintText: '请输入验证码',
                  counterText: '',
                  prefixIcon: const Icon(FontAwesomeIcons.message),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NomadsLoginPageController.nomadsRed, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入验证码';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              child: Obx(() => ElevatedButton(
                    onPressed: _c.countdown.value > 0 ? null : _c.sendSmsCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NomadsLoginPageController.nomadsRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _c.countdown.value > 0 ? '${_c.countdown.value}s' : '发送验证码',
                      style: const TextStyle(fontSize: 14),
                    ),
                  )),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 手机登录按钮
        ElevatedButton(
          onPressed: () => _c.loginWithPhone(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: NomadsLoginPageController.nomadsRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),

        const SizedBox(height: 16),

        // 切换到邮箱登录
        Center(
          child: TextButton(
            onPressed: () => _c.setLoginMode(LoginMode.email),
            child: const Text(
              '使用邮箱密码登录',
              style: TextStyle(color: NomadsLoginPageController.nomadsRed, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
