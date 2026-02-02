import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';

/// 登录页面头部 - Logo 和标题
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Logo 图标
        Container(
          width: LoginConstants.logoSize,
          height: LoginConstants.logoSize,
          decoration: BoxDecoration(
            color: LoginConstants.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            FontAwesomeIcons.earthAmericas,
            size: 40,
            color: LoginConstants.primaryColor,
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
    );
  }
}
