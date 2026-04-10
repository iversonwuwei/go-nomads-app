import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 登录页面头部 - Logo 和标题
class LoginHeader extends StatelessWidget {
  final PreAuthMarketingCopy? copy;

  const LoginHeader({super.key, this.copy});

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
          child: Icon(
            FontAwesomeIcons.earthAmericas,
            size: 40.r,
            color: LoginConstants.primaryColor,
          ),
        ),
        SizedBox(height: 24.h),

        // 标题
        Text(
          copy?.loginHeaderTitle ?? l10n.welcome,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),

        // 副标题
        Text(
          copy?.loginHeaderSubtitle ?? l10n.login,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
