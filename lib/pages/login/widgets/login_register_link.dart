import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 注册链接
class LoginRegisterLink extends StatelessWidget {
  const LoginRegisterLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Let's Go",
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.register),
            child: const Text(
              "Register",
              style: TextStyle(
                color: LoginConstants.primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
