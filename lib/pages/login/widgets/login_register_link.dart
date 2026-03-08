import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 注册链接
class LoginRegisterLink extends StatelessWidget {
  const LoginRegisterLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.letsGo,
            style: TextStyle(color: Colors.black87, fontSize: 15.sp),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.register),
            child: Text(
              l10n.register,
              style: TextStyle(
                color: LoginConstants.primaryColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
