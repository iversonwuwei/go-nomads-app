import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

/// AI 旅行规划师会员访问控制
class AiPlannerAccessService {
  static final AiPlannerAccessService _instance = AiPlannerAccessService._internal();

  factory AiPlannerAccessService() => _instance;

  AiPlannerAccessService._internal();

  MembershipStateController get _membershipController => Get.find<MembershipStateController>();

  Future<bool> ensureAccess({
    String featureName = 'AI 旅行规划师',
    bool showUpgradeDialog = true,
  }) async {
    try {
      final isAdmin = await TokenStorageService().isAdmin();
      if (isAdmin) {
        return true;
      }

      if (_membershipController.membership == null && !_membershipController.isLoading) {
        await _membershipController.loadMembership();
      }

      final membership = _membershipController.membership;
      final hasAccess = membership?.isActive == true;
      if (hasAccess) {
        return true;
      }

      if (showUpgradeDialog) {
        _showUpgradeDialog(featureName);
      }

      return false;
    } catch (_) {
      return true;
    }
  }

  void redirectToMembership({String featureName = 'AI 旅行规划师'}) {
    AppToast.warning('$featureName 仅对会员开放，请先开通会员');
    if (Get.currentRoute != AppRoutes.membershipPlan) {
      Get.offNamed(AppRoutes.membershipPlan);
    }
  }

  void _showUpgradeDialog(String featureName) {
    Get.bottomSheet(
      AppBottomDrawer(
        title: '会员专享功能',
        maxHeightFactor: 0.52,
        child: Text(
          '$featureName 需要开通会员后使用。升级会员即可解锁 AI 旅行规划能力。',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        footer: AppBottomDrawerActionRow(
          secondaryLabel: '暂不升级',
          onSecondaryPressed: () => Get.back<void>(),
          primaryLabel: '开通会员',
          onPrimaryPressed: () {
            Get.back<void>();
            Get.toNamed(AppRoutes.membershipPlan);
          },
        ),
      ),
      barrierColor: Colors.black54,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }
}
