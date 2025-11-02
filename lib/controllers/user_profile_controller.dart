import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/http_service.dart';
import '../widgets/app_toast.dart';
import 'user_state_controller.dart';

class UserProfileController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isEditMode = false.obs;
  
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    // 延迟到下一帧执行，避免在 build 过程中触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginAndLoadProfile();
    });
    _setupLoginStateListener();
  }

  // 监听登录状态变化
  void _setupLoginStateListener() {
    final userStateController = Get.find<UserStateController>();
    ever(userStateController.loginStateChanged, (_) {
      if (userStateController.isLoggedIn) {
        print('🔔 UserProfileController: 检测到用户登录，重新加载用户资料...');
        loadUserProfile();
      } else {
        print('🔔 UserProfileController: 检测到用户登出，清空用户资料...');
        currentUser.value = null;
      }
    });
  }

  // 检查登录状态并加载用户资料
  Future<void> _checkLoginAndLoadProfile() async {
    try {
      print('🔐 检查用户登录状态...');
      final userStateController = Get.find<UserStateController>();
      print('   当前登录状态: ${userStateController.isLoggedIn}');

      if (!userStateController.isLoggedIn) {
        print('❌ 用户未登录，跳转到登录页面');
        // 延迟一点点以确保UI准备好
        Future.microtask(() {
          Get.offAllNamed(AppRoutes.login);
        });
        return;
      }

      print('✅ 用户已登录，开始加载资料');
      await loadUserProfile();
    } catch (e) {
      print('❌ 检查登录状态失败: $e');
      // 出错时也跳转到登录页
      Future.microtask(() {
        Get.offAllNamed(AppRoutes.login);
      });
    }
  }

  // 加载用户资料
  Future<void> loadUserProfile() async {
    isLoading.value = true;

    try {
      print('📄 开始从后端加载用户资料...');
      final userStateController = Get.find<UserStateController>();
      print('   UserStateController 实例: ${userStateController.hashCode}');
      print('   当前登录状态: ${userStateController.isLoggedIn}');
      final accountId = userStateController.currentAccountId;
      print('   当前账户ID: $accountId');

      if (accountId == null) {
        print('❌ 未找到登录用户ID');
        AppToast.error(
          'Please login to view your profile',
          title: 'Not Logged In',
        );
        isLoading.value = false;
        // 跳转到登录页
        Future.microtask(() {
          Get.offAllNamed(AppRoutes.login);
        });
        return;
      }

      // 从后端 API 加载用户数据
      try {
        final userData = await _authService.getCurrentUser();
        print('✅ 从后端获取到用户数据: ${userData['name'] ?? userData['email']}');
        
        currentUser.value = _parseUserFromApi(userData);
        print('✅ 已加载用户资料: ${currentUser.value?.name}');
      } on HttpException catch (e) {
        print('❌ 后端API调用失败: ${e.message}');
        AppToast.error(
          'Failed to load user profile: ${e.message}',
          title: 'Error',
        );
        currentUser.value = null;
      }
    } catch (e) {
      print('❌ 加载用户资料失败: $e');
      AppToast.error(
        'Failed to load user profile: $e',
        title: 'Error',
      );
      currentUser.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // 从后端 API 数据解析用户模型
  UserModel _parseUserFromApi(Map<String, dynamic> data) {
    // 解析技能对象数组
    List<UserSkillInfo> parseSkillsList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((skill) {
              if (skill is Map<String, dynamic>) {
                return UserSkillInfo.fromJson(skill);
              }
              return null;
            })
            .whereType<UserSkillInfo>()
            .toList();
      }
      return [];
    }

    // 解析兴趣对象数组
    List<UserInterestInfo> parseInterestsList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((interest) {
              if (interest is Map<String, dynamic>) {
                return UserInterestInfo.fromJson(interest);
              }
              return null;
            })
            .whereType<UserInterestInfo>()
            .toList();
      }
      return [];
    }

    Map<String, String> parseSocialLinks(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return Map<String, String>.from(value);
      }
      if (value is String) {
        if (value.isEmpty) return {};
        try {
          final decoded = json.decode(value);
          return Map<String, String>.from(decoded);
        } catch (e) {
          return {};
        }
      }
      return {};
    }

    return UserModel(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? data['username'] ?? 'User',
      username: '@${data['username'] ?? 'user'}',
      email: data['email'], // 添加 email
      bio: data['bio'],
      avatarUrl: data['avatarUrl'] ?? data['avatar_url'],
      currentCity: data['currentCity'] ?? data['current_city'],
      currentCountry: data['currentCountry'] ?? data['current_country'],
      skills: parseSkillsList(data['skills']),
      interests: parseInterestsList(data['interests']),
      socialLinks:
          parseSocialLinks(data['socialLinks'] ?? data['social_links']),
      badges: [], // TODO: 后端返回 badges 时解析
      stats: TravelStats(
        countriesVisited:
            data['countriesVisited'] ?? data['countries_visited'] ?? 0,
        citiesLived: data['citiesLived'] ?? data['cities_lived'] ?? 0,
        daysNomading: data['daysNomading'] ?? data['days_nomading'] ?? 0,
        meetupsAttended:
            data['meetupsAttended'] ?? data['meetups_attended'] ?? 0,
        tripsCompleted: data['tripsCompleted'] ?? data['trips_completed'] ?? 0,
        favorites: data['favorites'] ?? 0,
      ),
      travelHistory: [], // TODO: 后端返回 travel_history 时解析
      joinedDate:
          DateTime.tryParse(data['createdAt'] ?? data['created_at'] ?? '') ??
              DateTime.now(),
      isVerified: data['isVerified'] == true ||
          data['is_verified'] == true ||
          (data['is_verified'] ?? 0) == 1,
    );
  }

  // 切换编辑模式
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  // 更新用户资料
  void updateProfile(UserModel updatedUser) {
    currentUser.value = updatedUser;
    isEditMode.value = false;
    AppToast.success(
      'Profile updated successfully',
      title: 'Success',
    );
  }

  // 添加技能 - 已废弃,现在通过 SkillsApiService.addUserSkillsBatch 添加
  // void addSkill(UserSkillInfo skill) {
  //   ...
  // }

  // 移除技能
  Future<void> removeSkill(String userSkillId) async {
    if (currentUser.value == null) return;

    try {
      // 调用后端 API 删除(使用 user_skill 的 ID)
      final httpService = HttpService();
      final response = await httpService.delete('/skills/me/$userSkillId');

      if (response.statusCode == 200) {
        print('✅ 技能已从数据库删除: ID=$userSkillId');
        
        // 删除成功后,重新加载用户资料以刷新页面
        await loadUserProfile();
        
        AppToast.success(
          'Skill removed successfully',
          title: 'Success',
        );
      } else {
        print('⚠️ 删除技能失败: ${response.statusCode}');
        AppToast.error(
          'Failed to remove skill',
          title: 'Error',
        );
      }
    } catch (e) {
      print('❌ 删除技能出错: $e');
      AppToast.error(
        'Failed to remove skill: $e',
        title: 'Error',
      );
    }
  }

  // 添加兴趣爱好 - 已废弃,现在通过 InterestsApiService.addUserInterestsBatch 添加
  // void addInterest(UserInterestInfo interest) {
  //   ...
  // }

  // 移除兴趣爱好
  Future<void> removeInterest(String userInterestId) async {
    if (currentUser.value == null) return;

    try {
      // 调用后端 API 删除(使用 user_interest 的 ID)
      final httpService = HttpService();
      final response = await httpService.delete('/interests/me/$userInterestId');

      if (response.statusCode == 200) {
        print('✅ 兴趣爱好已从数据库删除: ID=$userInterestId');
        
        // 删除成功后,重新加载用户资料以刷新页面
        await loadUserProfile();
        
        AppToast.success(
          'Interest removed successfully',
          title: 'Success',
        );
      } else {
        print('⚠️ 删除兴趣爱好失败: ${response.statusCode}');
        AppToast.error(
          'Failed to remove interest',
          title: 'Error',
        );
      }
    } catch (e) {
      print('❌ 删除兴趣爱好出错: $e');
      AppToast.error(
        'Failed to remove interest: $e',
        title: 'Error',
      );
    }
  }
}
