import 'package:go_nomads_app/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Pros & Cons 添加页面控制器
class ProsAndConsAddPageController extends GetxController {
  final String cityId;
  final String cityName;

  ProsAndConsAddPageController({
    required this.cityId,
    required this.cityName,
  });

  // 文本控制器
  final TextEditingController prosTextController = TextEditingController();
  final TextEditingController consTextController = TextEditingController();

  // 状态管理
  final RxBool isAddingPros = false.obs;
  final RxBool isAddingCons = false.obs;
  final RxBool canDelete = false.obs;

  /// 获取 ProsConsStateController
  ProsConsStateController get prosConsController => Get.find<ProsConsStateController>();

  /// 是否有变更
  bool get hasChanges =>
      prosTextController.text.isNotEmpty ||
      consTextController.text.isNotEmpty ||
      prosConsController.prosList.isNotEmpty ||
      prosConsController.consList.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    // 延迟到首帧之后再加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  @override
  void onClose() {
    prosTextController.dispose();
    consTextController.dispose();
    super.onClose();
  }

  /// 检查用户权限
  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  /// 加载已有数据
  Future<void> loadData() async {
    await prosConsController.loadCityProsCons(cityId);
  }

  /// 添加优点
  Future<void> addPros() async {
    if (prosTextController.text.trim().isEmpty) return;

    isAddingPros.value = true;
    try {
      final success = await prosConsController.addPros(
        cityId: cityId,
        text: prosTextController.text.trim(),
      );

      if (success) {
        prosTextController.clear();
        AppToast.success('优点已添加');
        await loadData();
      } else {
        AppToast.error('添加优点失败，请重试');
      }
    } catch (e) {
      AppToast.error('添加失败: $e');
    } finally {
      isAddingPros.value = false;
    }
  }

  /// 添加挑战
  Future<void> addCons() async {
    if (consTextController.text.trim().isEmpty) return;

    isAddingCons.value = true;
    try {
      final success = await prosConsController.addCons(
        cityId: cityId,
        text: consTextController.text.trim(),
      );

      if (success) {
        consTextController.clear();
        AppToast.success('挑战已添加');
        await loadData();
      } else {
        AppToast.error('添加挑战失败，请重试');
      }
    } catch (e) {
      AppToast.error('添加失败: $e');
    } finally {
      isAddingCons.value = false;
    }
  }

  /// 删除优点
  Future<bool> deletePros(String id) async {
    try {
      final success = await prosConsController.deleteProsCons(cityId, id, true);

      if (success) {
        AppToast.success('优点已删除');
        await loadData();
        return true;
      } else {
        AppToast.error('删除失败，请重试');
        return false;
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
      return false;
    }
  }

  /// 删除挑战
  Future<bool> deleteCons(String id) async {
    try {
      final success = await prosConsController.deleteProsCons(cityId, id, false);

      if (success) {
        AppToast.success('挑战已删除');
        await loadData();
        return true;
      } else {
        AppToast.error('删除失败，请重试');
        return false;
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
      return false;
    }
  }

  /// 处理投票
  Future<void> handleVote(String id, bool isPro) async {
    if (id.isEmpty) return;

    final success = await prosConsController.upvote(id, isPro);
    if (success) {
      await loadData();
    } else {
      final message = prosConsController.error.value ?? '操作失败，请稍后再试';
      AppToast.error(message);
    }
  }
}
