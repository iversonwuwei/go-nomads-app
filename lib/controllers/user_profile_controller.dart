import 'dart:convert';

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
    _checkLoginAndLoadProfile();
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
    // 解析JSON字符串字段或数组
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) {
        if (value.isEmpty) return [];
        try {
          return List<String>.from(json.decode(value));
        } catch (e) {
          return [];
        }
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
      bio: data['bio'],
      avatarUrl: data['avatarUrl'] ?? data['avatar_url'],
      currentCity: data['currentCity'] ?? data['current_city'],
      currentCountry: data['currentCountry'] ?? data['current_country'],
      skills: parseStringList(data['skills']),
      interests: parseStringList(data['interests']),
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

  // 添加技能
  void addSkill(String skill) {
    if (currentUser.value != null &&
        !currentUser.value!.skills.contains(skill)) {
      final updatedSkills = [...currentUser.value!.skills, skill];
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        username: currentUser.value!.username,
        bio: currentUser.value!.bio,
        avatarUrl: currentUser.value!.avatarUrl,
        currentCity: currentUser.value!.currentCity,
        currentCountry: currentUser.value!.currentCountry,
        skills: updatedSkills,
        interests: currentUser.value!.interests,
        socialLinks: currentUser.value!.socialLinks,
        badges: currentUser.value!.badges,
        stats: currentUser.value!.stats,
        travelHistory: currentUser.value!.travelHistory,
        joinedDate: currentUser.value!.joinedDate,
        isVerified: currentUser.value!.isVerified,
      );
    }
  }

  // 移除技能
  void removeSkill(String skill) {
    if (currentUser.value != null) {
      final updatedSkills =
          currentUser.value!.skills.where((s) => s != skill).toList();
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        username: currentUser.value!.username,
        bio: currentUser.value!.bio,
        avatarUrl: currentUser.value!.avatarUrl,
        currentCity: currentUser.value!.currentCity,
        currentCountry: currentUser.value!.currentCountry,
        skills: updatedSkills,
        interests: currentUser.value!.interests,
        socialLinks: currentUser.value!.socialLinks,
        badges: currentUser.value!.badges,
        stats: currentUser.value!.stats,
        travelHistory: currentUser.value!.travelHistory,
        joinedDate: currentUser.value!.joinedDate,
        isVerified: currentUser.value!.isVerified,
      );
    }
  }

  // 添加兴趣爱好
  void addInterest(String interest) {
    if (currentUser.value != null &&
        !currentUser.value!.interests.contains(interest)) {
      final updatedInterests = [...currentUser.value!.interests, interest];
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        username: currentUser.value!.username,
        bio: currentUser.value!.bio,
        avatarUrl: currentUser.value!.avatarUrl,
        currentCity: currentUser.value!.currentCity,
        currentCountry: currentUser.value!.currentCountry,
        skills: currentUser.value!.skills,
        interests: updatedInterests,
        socialLinks: currentUser.value!.socialLinks,
        badges: currentUser.value!.badges,
        stats: currentUser.value!.stats,
        travelHistory: currentUser.value!.travelHistory,
        joinedDate: currentUser.value!.joinedDate,
        isVerified: currentUser.value!.isVerified,
      );
    }
  }

  // 移除兴趣爱好
  void removeInterest(String interest) {
    if (currentUser.value != null) {
      final updatedInterests =
          currentUser.value!.interests.where((i) => i != interest).toList();
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        username: currentUser.value!.username,
        bio: currentUser.value!.bio,
        avatarUrl: currentUser.value!.avatarUrl,
        currentCity: currentUser.value!.currentCity,
        currentCountry: currentUser.value!.currentCountry,
        skills: currentUser.value!.skills,
        interests: updatedInterests,
        socialLinks: currentUser.value!.socialLinks,
        badges: currentUser.value!.badges,
        stats: currentUser.value!.stats,
        travelHistory: currentUser.value!.travelHistory,
        joinedDate: currentUser.value!.joinedDate,
        isVerified: currentUser.value!.isVerified,
      );
    }
  }
}
