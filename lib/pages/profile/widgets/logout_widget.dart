import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 退出登录组件
class LogoutWidget extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutWidget({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.rightFromBracket,
            color: Color(0xFF6B7280),
            size: 20.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.logout,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          TextButton(
            onPressed: onLogout,
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Color(0xFFFF4458)),
            ),
          ),
        ],
      ),
    );
  }
}
