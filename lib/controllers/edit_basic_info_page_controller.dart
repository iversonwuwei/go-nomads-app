import 'dart:developer';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 基本信息编辑页面控制器
class EditBasicInfoPageController extends GetxController {
  final int accountId;
  final _userProfileDao = UserProfileDao();

  EditBasicInfoPageController({required this.accountId});

  // 表单控制器
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final occupationController = TextEditingController();
  final companyController = TextEditingController();
  final websiteController = TextEditingController();

  /// 头像URL
  final Rx<String?> avatarUrl = Rx<String?>(null);

  /// 性别
  final Rx<String?> gender = Rx<String?>(null);

  /// 是否正在加载
  final RxBool isLoading = true.obs;

  /// 是否正在保存
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBasicInfo();
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    cityController.dispose();
    countryController.dispose();
    occupationController.dispose();
    companyController.dispose();
    websiteController.dispose();
    super.onClose();
  }

  /// 加载基本信息
  Future<void> loadBasicInfo() async {
    try {
      final info = await _userProfileDao.getBasicInfo(accountId);
      if (info != null) {
        nameController.text = info.name;
        bioController.text = info.bio ?? '';
        cityController.text = info.currentCity ?? '';
        countryController.text = info.currentCountry ?? '';
        occupationController.text = info.occupation ?? '';
        companyController.text = info.company ?? '';
        websiteController.text = info.website ?? '';
        avatarUrl.value = info.avatarUrl;
        gender.value = info.gender;
      }
    } catch (e) {
      log('加载基本信息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 更新性别
  void updateGender(String? value) {
    gender.value = value;
  }

  /// 保存基本信息
  Future<bool> saveBasicInfo(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isSaving.value = true;

    try {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      final info = UserBasicInfoDto(
        accountId: accountId,
        name: nameController.text.trim(),
        bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
        avatarUrl: avatarUrl.value,
        currentCity: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
        currentCountry: countryController.text.trim().isEmpty ? null : countryController.text.trim(),
        occupation: occupationController.text.trim().isEmpty ? null : occupationController.text.trim(),
        company: companyController.text.trim().isEmpty ? null : companyController.text.trim(),
        website: websiteController.text.trim().isEmpty ? null : websiteController.text.trim(),
        gender: gender.value,
        createdAt: now,
        updatedAt: now,
      );

      await _userProfileDao.saveBasicInfo(info);
      AppToast.success('基本信息已保存', title: '成功');
      return true;
    } catch (e) {
      log('保存基本信息失败: $e');
      AppToast.error('保存失败，请重试', title: '错误');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// 上传头像（待实现）
  void uploadAvatar() {
    AppToast.info('头像上传功能开发中');
  }
}
