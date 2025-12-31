import 'dart:developer';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 兴趣编辑页面控制器
class EditInterestsPageController extends GetxController {
  final int accountId;

  EditInterestsPageController({required this.accountId});

  final _userProfileDao = UserProfileDao();
  final customInterestController = TextEditingController();

  final RxBool loading = true.obs;
  final RxSet<String> selectedInterests = <String>{}.obs;
  final RxnString selectedCategory = RxnString('全部');

  final Map<String, List<String>> categorizedInterests = {
    '旅行': ['旅行', '冒险', '背包旅行', '徒步', '露营', '公路旅行', '探索', '文化交流'],
    '运动': ['健身', '瑜伽', '跑步', '游泳', '冲浪', '滑雪', '攀岩', '骑行', '潜水', '极限运动'],
    '艺术': ['摄影', '绘画', '音乐', '舞蹈', '电影', '戏剧', '博物馆', '艺术展'],
    '美食': ['美食', '烹饪', '街头小吃', '咖啡', '美酒', '素食', '甜点', '异国料理'],
    '社交': ['交友', '聚会', '夜生活', '派对', 'Meetup', '社区活动', '志愿服务'],
    '学习': ['阅读', '写作', '语言学习', '编程', '历史', '哲学', '科学', '教育'],
    '科技': ['科技', '创业', '创新', '数字游民', '远程工作', '区块链', 'AI', 'Web3'],
    '生活': ['冥想', '正念', '可持续生活', '极简主义', '宠物', '园艺', '手工艺', '时尚', '健康生活', '环保'],
  };

  @override
  void onInit() {
    super.onInit();
    loadInterests();
  }

  @override
  void onClose() {
    customInterestController.dispose();
    super.onClose();
  }

  Future<void> loadInterests() async {
    try {
      final interests = await _userProfileDao.getInterests(accountId);
      selectedInterests.assignAll(interests.map((i) => i.interestName).toSet());
      loading.value = false;
    } catch (e) {
      log('加载兴趣失败: $e');
      loading.value = false;
    }
  }

  Future<void> toggleInterest(String interestName) async {
    try {
      if (selectedInterests.contains(interestName)) {
        await _userProfileDao.removeInterest(accountId, interestName);
        selectedInterests.remove(interestName);
        AppToast.success('已移除兴趣');
      } else {
        final interest = UserInterestDto(
          accountId: accountId,
          interestName: interestName,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _userProfileDao.addInterest(interest);
        selectedInterests.add(interestName);
        AppToast.success('已添加兴趣');
      }
    } catch (e) {
      log('操作兴趣失败: $e');
      AppToast.error('操作失败，请重试');
    }
  }

  Future<void> addCustomInterest() async {
    final interestName = customInterestController.text.trim();
    if (interestName.isEmpty) {
      AppToast.warning('请输入兴趣名称');
      return;
    }

    if (selectedInterests.contains(interestName)) {
      AppToast.warning('该兴趣已存在');
      return;
    }

    try {
      final interest = UserInterestDto(
        accountId: accountId,
        interestName: interestName,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _userProfileDao.addInterest(interest);
      selectedInterests.add(interestName);
      customInterestController.clear();
      AppToast.success('已添加自定义兴趣');
    } catch (e) {
      log('添加自定义兴趣失败: $e');
      AppToast.error('添加失败，请重试');
    }
  }

  List<String> getFilteredInterests() {
    if (selectedCategory.value == '全部') {
      return categorizedInterests.values.expand((interests) => interests).toList();
    }
    return categorizedInterests[selectedCategory.value] ?? [];
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }
}
