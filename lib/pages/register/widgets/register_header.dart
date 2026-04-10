import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 注册页面头部 - Logo 和标题
class RegisterHeader extends StatelessWidget {
  final PreAuthMarketingCopy? copy;

  const RegisterHeader({super.key, this.copy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        children: [
          // Logo
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: RegisterConstants.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.earthAmericas,
              size: 40.r,
              color: RegisterConstants.primaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          // 标题
          Text(
            '🌍 ${copy?.registerHeaderTitle ?? l10n.goNomad}',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          // 副标题
          Text(
            copy?.registerHeaderSubtitle ?? l10n.joinGlobalCommunity,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
