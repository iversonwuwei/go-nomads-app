import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 已有账号登录链接
class RegisterLoginLink extends StatelessWidget {
  const RegisterLoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${l10n.alreadyHaveAccount} ',
            style: TextStyle(color: Colors.black87, fontSize: 15.sp),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.login),
            child: Text(
              l10n.login,
              style: TextStyle(
                color: RegisterConstants.primaryColor,
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
