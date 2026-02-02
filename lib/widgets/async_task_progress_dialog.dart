import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 进度指示器
              Obx(() {
                final progressValue = progress.value / 100.0;
                return Column(
                  children: [
                    // 圆形进度指示器
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progressValue,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(progress.value),
                            ),
                          ),
                          Text(
                            '${progress.value}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 线性进度条
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

              const SizedBox(height: 16),

              // 进度消息
              Obx(() => Text(
                    message.value.isEmpty ? '处理中...' : message.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  )),

              const SizedBox(height: 24),

              // 取消按钮
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
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
    Get.dialog(
      AsyncTaskProgressDialog(
        title: title,
        progress: progress,
        message: message,
        onCancel: onCancel,
      ),
      barrierDismissible: false, // 点击外部不关闭
    );
  }

  /// 关闭对话框
  static void dismiss() {
    log('[AsyncTaskProgressDialog] 尝试关闭对话框...');

    try {
      // 只关闭最顶层的对话框，不影响 snackbar
      if (Get.isDialogOpen == true) {
        // 使用 closeAllDialogs 而不是 back，避免误关闭 snackbar
        Get.until((route) => !Get.isDialogOpen!);
        log('[AsyncTaskProgressDialog] ✅ 对话框已成功关闭');
      } else {
        log('[AsyncTaskProgressDialog] ✅ 对话框已经关闭');
      }
    } catch (e) {
      log('[AsyncTaskProgressDialog] ❌ 关闭失败: $e');
    }
  }

  /// 安全地关闭对话框（带延迟）
  static Future<void> dismissSafely({Duration delay = const Duration(milliseconds: 100)}) async {
    await Future.delayed(delay);
    dismiss();
  }
}
