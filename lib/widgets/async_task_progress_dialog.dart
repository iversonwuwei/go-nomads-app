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
    return WillPopScope(
      onWillPop: () async => false, // 禁止返回键关闭
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

  /// 关闭进度对话框
  static void dismiss() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
