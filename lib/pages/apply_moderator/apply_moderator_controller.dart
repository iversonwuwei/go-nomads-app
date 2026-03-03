import 'dart:developer';

import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 申请成为版主页面控制器
class ApplyModeratorController extends GetxController {
  final IModeratorApplicationRepository _repository;

  ApplyModeratorController(this._repository);

  // 城市信息
  late City city;

  // 表单相关
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();

  // 加载状态
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 从路由参数获取城市信息
    final args = Get.arguments;
    if (args is City) {
      city = args;
    } else if (args is Map<String, dynamic> && args['city'] is City) {
      city = args['city'] as City;
    } else {
      log('❌ [ApplyModeratorController] 未找到城市参数');
      Get.back();
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  /// 提交申请
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isSubmitting.value = true;

      await _repository.applyForModerator(
        cityId: city.id,
        reason: reasonController.text.trim(),
      );

      AppToast.success('申请已提交，请等待管理员审核');
      Get.back();
    } catch (e) {
      log('❌ [ApplyModeratorController] 提交申请失败: $e');
      AppToast.error('提交失败: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }
}
