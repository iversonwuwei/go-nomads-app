import 'package:go_nomads_app/features/membership/domain/entities/ai_usage_check.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// AI 配额检查服务
/// 
/// 提供统一的 AI 服务调用前配额检查功能
/// 所有 AI 服务调用点都应使用此服务进行配额检查
class AiQuotaService {
  static final AiQuotaService _instance = AiQuotaService._internal();
  factory AiQuotaService() => _instance;
  AiQuotaService._internal();

  /// 获取会员状态控制器
  MembershipStateController get _membershipController {
    return Get.find<MembershipStateController>();
  }

  /// 检查 AI 配额是否足够
  /// 
  /// 如果配额不足，自动显示升级提示对话框
  /// 返回 true 表示可以继续使用 AI，false 表示配额不足
  Future<bool> checkAndUseAI({
    String? featureName,
    bool showUpgradeDialog = true,
  }) async {
    try {
      // 检查配额
      final check = await _membershipController.checkAiQuota();
      
      if (!check.canUse) {
        if (showUpgradeDialog) {
          _showQuotaExhaustedDialog(check, featureName);
        }
        return false;
      }
      
      // 记录使用
      await _membershipController.incrementAIUsage();
      
      // 如果即将用完，显示提示
      if (check.shouldShowUpgradeHint && check.remaining > 0) {
        _showLowQuotaHint(check);
      }
      
      return true;
    } catch (e) {
      // 出错时默认允许（降级处理）
      AppToast.warning('无法检查 AI 配额，请稍后重试');
      return true;
    }
  }

  /// 仅检查配额（不消耗次数）
  Future<AiUsageCheck> checkQuota() async {
    return _membershipController.checkAiQuota();
  }

  /// 获取当前剩余次数
  int get remainingUsage => _membershipController.aiUsageRemaining;

  /// 是否可以使用 AI
  bool get canUseAI => _membershipController.canUseAI;

  /// 显示配额用尽对话框
  void _showQuotaExhaustedDialog(AiUsageCheck check, String? featureName) {
    final feature = featureName ?? 'AI 功能';
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('AI 配额已用完'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '您本月的 $feature 使用次数已达上限 (${check.used}/${check.limit})。',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    check.upgradeMessage,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (check.resetDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '配额将于 ${_formatDate(check.resetDate!)} 重置',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('稍后再说'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.membershipPlan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('升级会员'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 显示配额即将用完提示
  void _showLowQuotaHint(AiUsageCheck check) {
    AppToast.info(
      '本月 AI 剩余 ${check.remaining} 次使用机会',
      title: '温馨提示',
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
