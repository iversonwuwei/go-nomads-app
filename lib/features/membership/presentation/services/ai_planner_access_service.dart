import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

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
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        contentPadding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        actionsPadding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
        title: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Colors.orange[700], size: 24.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '会员专享功能',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          '$featureName 需要开通会员后使用。升级会员即可解锁 AI 旅行规划能力。',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('暂不升级', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.membershipPlan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text('开通会员', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}