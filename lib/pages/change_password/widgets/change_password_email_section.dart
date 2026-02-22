import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/change_password_page_controller.dart';

/// 邮箱信息区域 / Email info section
class ChangePasswordEmailSection extends GetView<ChangePasswordController> {
  const ChangePasswordEmailSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.envelope,
            color: AppColors.icon,
            size: 18,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '账号邮箱',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                    controller.userEmail.value.isNotEmpty
                        ? controller.userEmail.value
                        : '未绑定邮箱',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
