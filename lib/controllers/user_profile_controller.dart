import 'dart:convert';

import 'package:get/get.dart';

import '../models/user_model.dart';
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
    loadUserProfile();
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
        print('! 未找到登录用户，使用示例数据');
        print('💡 提示：请先登录以查看您的个人资料');
        print('   测试账号: sarah_chen / 123456');
        print('   或邮箱: sarah.chen@nomads.com / 123456');
        currentUser.value = _generateMockUser();
        isLoading.value = false;
        return;
      }

      // 从数据库加载用户数据
      final accountDao = Get.find<AccountDao>();
      final accountData = await accountDao.getAccountWithProfile(accountId);

      if (accountData != null) {
        currentUser.value = _parseUserFromDatabase(accountData);
        print('✅ 已加载用户资料: ${accountData['username']}');
      } else {
        print('⚠️ 未找到用户数据，使用示例数据');
        currentUser.value = _generateMockUser();
      }
    } catch (e) {
      print('❌ 加载用户资料失败: $e');
      currentUser.value = _generateMockUser();
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

  // 生成示例用户数据
  UserModel _generateMockUser() {
    return UserModel(
      id: 'user_001',
      name: 'Alex Chen',
      username: '@alexchen',
      bio:
          '🌍 Digital nomad & full-stack developer\n💻 Building products remotely\n📍 Currently exploring Southeast Asia',
      avatarUrl: 'https://i.pravatar.cc/300?img=33',
      currentCity: 'Chiang Mai',
      currentCountry: 'Thailand',
      skills: [
        'Flutter',
        'React',
        'Node.js',
        'Python',
        'UI/UX Design',
        'Product Management'
      ],
      interests: [
        'Remote Work',
        'Startup',
        'Travel',
        'Photography',
        'Hiking',
        'Local Food'
      ],
      socialLinks: {
        'twitter': 'https://twitter.com/alexchen',
        'github': 'https://github.com/alexchen',
        'linkedin': 'https://linkedin.com/in/alexchen',
        'website': 'https://alexchen.dev'
      },
      badges: [
        Badge(
          id: 'badge_001',
          name: 'Early Adopter',
          icon: '🚀',
          description: 'Joined in the first year',
          earnedDate: DateTime(2023, 1, 15),
        ),
        Badge(
          id: 'badge_002',
          name: 'Globe Trotter',
          icon: '🌏',
          description: 'Visited 20+ countries',
          earnedDate: DateTime(2024, 6, 20),
        ),
        Badge(
          id: 'badge_003',
          name: 'Community Leader',
          icon: '👥',
          description: 'Organized 10+ meetups',
          earnedDate: DateTime(2024, 8, 10),
        ),
        Badge(
          id: 'badge_004',
          name: 'Top Contributor',
          icon: '⭐',
          description: 'Shared 50+ helpful reviews',
          earnedDate: DateTime(2024, 9, 5),
        ),
      ],
      stats: TravelStats(
        countriesVisited: 23,
        citiesLived: 12,
        daysNomading: 487,
        meetupsAttended: 28,
        tripsCompleted: 15,
      ),
      travelHistory: [
        TravelHistory(
          city: 'Chiang Mai',
          country: 'Thailand',
          startDate: DateTime(2024, 11, 1),
          endDate: null, // 当前所在地
          rating: 4.8,
        ),
        TravelHistory(
          city: 'Bali',
          country: 'Indonesia',
          startDate: DateTime(2024, 8, 15),
          endDate: DateTime(2024, 10, 31),
          review:
              'Amazing coworking spaces and digital nomad community. Canggu is perfect for remote work!',
          rating: 4.9,
        ),
        TravelHistory(
          city: 'Lisbon',
          country: 'Portugal',
          startDate: DateTime(2024, 5, 1),
          endDate: DateTime(2024, 8, 14),
          review:
              'Beautiful city with great weather. Fast internet and affordable living costs.',
          rating: 4.7,
        ),
        TravelHistory(
          city: 'Mexico City',
          country: 'Mexico',
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 4, 30),
          review:
              'Incredible food scene and vibrant culture. Roma Norte is ideal for nomads.',
          rating: 4.6,
        ),
        TravelHistory(
          city: 'Tokyo',
          country: 'Japan',
          startDate: DateTime(2023, 11, 1),
          endDate: DateTime(2024, 1, 31),
          review:
              'Super fast internet everywhere. Expensive but worth it for the experience.',
          rating: 4.5,
        ),
      ],
      joinedDate: DateTime(2023, 1, 15),
      isVerified: true,
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
}
