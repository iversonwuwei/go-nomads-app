import 'package:get/get.dart';

import '../models/user_model.dart';

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
  void loadUserProfile() {
    isLoading.value = true;

    // 模拟网络延迟
    Future.delayed(const Duration(milliseconds: 800), () {
      // 生成示例用户数据
      currentUser.value = _generateMockUser();
      isLoading.value = false;
    });
  }

  // 生成示例用户数据
  UserModel _generateMockUser() {
    return UserModel(
      id: 'user_001',
      name: 'Alex Chen',
      username: '@alexchen',
      bio: '🌍 Digital nomad & full-stack developer\n💻 Building products remotely\n📍 Currently exploring Southeast Asia',
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
          review: 'Amazing coworking spaces and digital nomad community. Canggu is perfect for remote work!',
          rating: 4.9,
        ),
        TravelHistory(
          city: 'Lisbon',
          country: 'Portugal',
          startDate: DateTime(2024, 5, 1),
          endDate: DateTime(2024, 8, 14),
          review: 'Beautiful city with great weather. Fast internet and affordable living costs.',
          rating: 4.7,
        ),
        TravelHistory(
          city: 'Mexico City',
          country: 'Mexico',
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 4, 30),
          review: 'Incredible food scene and vibrant culture. Roma Norte is ideal for nomads.',
          rating: 4.6,
        ),
        TravelHistory(
          city: 'Tokyo',
          country: 'Japan',
          startDate: DateTime(2023, 11, 1),
          endDate: DateTime(2024, 1, 31),
          review: 'Super fast internet everywhere. Expensive but worth it for the experience.',
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
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // 添加技能
  void addSkill(String skill) {
    if (currentUser.value != null && !currentUser.value!.skills.contains(skill)) {
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
      final updatedSkills = currentUser.value!.skills.where((s) => s != skill).toList();
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
