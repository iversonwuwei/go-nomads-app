import 'dart:convert';

import 'package:get/get.dart';

import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../services/database/account_dao.dart';
import '../widgets/app_toast.dart';
import 'user_state_controller.dart';

class UserProfileController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginAndLoadProfile();
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
      // 获取当前登录用户ID
      print('📄 开始加载用户资料...');
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

      // 从数据库加载用户数据
      final accountDao = Get.find<AccountDao>();
      final accountData = await accountDao.getAccountWithProfile(accountId);

      if (accountData != null) {
        currentUser.value = _parseUserFromDatabase(accountData);
        print('✅ 已加载用户资料: ${accountData['username']}');
      } else {
        print('⚠️ 未找到用户数据');
        AppToast.error(
          'User profile not found',
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

  // 从数据库数据解析用户模型
  UserModel _parseUserFromDatabase(Map<String, dynamic> data) {
    // 解析JSON字符串字段
    List<String> parseStringList(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return [];
      try {
        return List<String>.from(json.decode(jsonStr));
      } catch (e) {
        return [];
      }
    }

    Map<String, String> parseSocialLinks(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return {};
      try {
        final decoded = json.decode(jsonStr);
        return Map<String, String>.from(decoded);
      } catch (e) {
        return {};
      }
    }

    List<Badge> parseBadges(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return [];
      try {
        final List<dynamic> decoded = json.decode(jsonStr);
        return decoded
            .map((item) => Badge(
                  id: item['id'] ?? '',
                  name: item['name'] ?? '',
                  icon: item['icon'] ?? '🏆',
                  description: item['description'] ?? '',
                  earnedDate: DateTime.tryParse(item['earnedDate'] ?? '') ??
                      DateTime.now(),
                ))
            .toList();
      } catch (e) {
        return [];
      }
    }

    List<TravelHistory> parseTravelHistory(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return [];
      try {
        final List<dynamic> decoded = json.decode(jsonStr);
        return decoded
            .map((item) => TravelHistory(
                  city: item['city'] ?? '',
                  country: item['country'] ?? '',
                  startDate: DateTime.tryParse(item['startDate'] ?? '') ??
                      DateTime.now(),
                  endDate: item['endDate'] != null
                      ? DateTime.tryParse(item['endDate'])
                      : null,
                  review: item['review'],
                  rating: (item['rating'] ?? 0).toDouble(),
                ))
            .toList();
      } catch (e) {
        return [];
      }
    }

    return UserModel(
      id: data['id'].toString(),
      name: data['name'] ?? data['username'] ?? 'User',
      username: '@${data['username'] ?? 'user'}',
      bio: data['bio'],
      avatarUrl: data['avatar_url'],
      currentCity: data['current_city'],
      currentCountry: data['current_country'],
      skills: parseStringList(data['skills']),
      interests: parseStringList(data['interests']),
      socialLinks: parseSocialLinks(data['social_links']),
      badges: parseBadges(data['badges']),
      stats: TravelStats(
        countriesVisited: data['countries_visited'] ?? 0,
        citiesLived: data['cities_lived'] ?? 0,
        daysNomading: data['days_nomading'] ?? 0,
        meetupsAttended: data['meetups_attended'] ?? 0,
        tripsCompleted: data['trips_completed'] ?? 0,
      ),
      travelHistory: parseTravelHistory(data['travel_history']),
      joinedDate:
          DateTime.tryParse(data['joined_date'] ?? '') ?? DateTime.now(),
      isVerified: (data['is_verified'] ?? 0) == 1,
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
