import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

/// 异步任务进度对话框
///
/// 显示任务生成进度,支持取消操作
class AsyncTaskProgressDialog extends StatelessWidget {
  final String title;
  final RxInt progress;
  final RxString message;
  final VoidCallback? onCancel;

  const AsyncTaskProgressDialog({
    super.key,
    required this.title,
    required this.progress,
    required this.message,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止返回键关闭
      child: AppBottomDrawer(
        title: title,
        maxHeightFactor: 0.52,
        child: Column(
          children: [
            Obx(() {
              final progressValue = progress.value / 100.0;
              return Column(
                children: [
                  SizedBox(
                    width: 80.w,
                    height: 80.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 8.w,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(progress.value),
                          ),
                        ),
                        Text(
                          '${progress.value}%',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress.value),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 16.h),
            Obx(() => Text(
                  message.value.isEmpty ? '处理中...' : message.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                )),
          ],
        ),
        footer: onCancel == null
            ? null
            : SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
      ),
    );
  }

  /// 根据进度获取颜色
  Color _getProgressColor(int progress) {
    if (progress < 30) {
      return Colors.orange;
    } else if (progress < 70) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  /// 显示进度对话框
  static void show({
    required String title,
    required RxInt progress,
    required RxString message,
    VoidCallback? onCancel,
  }) {
    Get.bottomSheet(
      AsyncTaskProgressDialog(
        title: title,
        progress: progress,
        message: message,
        onCancel: onCancel,
      ),
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// 关闭对话框
  static void dismiss() {
    log('[AsyncTaskProgressDialog] 尝试关闭对话框...');

    try {
      // 只关闭最顶层的对话框，不影响 snackbar
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back<void>();
        log('[AsyncTaskProgressDialog] ✅ 抽屉已成功关闭');
      } else {
        log('[AsyncTaskProgressDialog] ✅ 抽屉已经关闭');
      }
    } catch (e) {
      log('[AsyncTaskProgressDialog] ❌ 关闭失败: $e');
    }
  }

  /// 安全地关闭对话框（带延迟）
  static Future<void> dismissSafely(
      {Duration delay = const Duration(milliseconds: 100)}) async {
    await Future.delayed(delay);
    dismiss();
  }
}
