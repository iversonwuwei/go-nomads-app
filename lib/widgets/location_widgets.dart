import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/location_controller.dart';

/// 位置权限请求对话框
class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: Color(0xFFFF4458),
              ),
            ),

            const SizedBox(height: 24),

            // 标题
            const Text(
              '需要位置权限',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // 描述
            const Text(
              '我们需要访问您的位置信息,以便为您推荐附近的城市和提供基于位置的服务',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // 按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await controller.getCurrentLocation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4458),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '授予权限',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 位置信息显示组件
class LocationInfoWidget extends StatelessWidget {
  const LocationInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '正在获取位置...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      if (!controller.hasPermission.value || controller.currentPosition.value == null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4458).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF4458).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_off,
                color: Color(0xFFFF4458),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '位置未启用',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => controller.getCurrentLocation(),
                child: const Text(
                  '启用',
                  style: TextStyle(color: Color(0xFFFF4458)),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFFF4458),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentCity.value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.currentCountry.value,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: AppColors.textSecondary,
              onPressed: () => controller.refreshLocation(),
            ),
          ],
        ),
      );
    });
  }
}
