import 'package:flutter/material.dart' hide Badge;
import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../widgets/skeleton_loader.dart';
import 'data_service_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonLoader(type: SkeletonType.profile);
        }

        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF1a1a1a),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    controller.isEditMode.value ? Icons.check : Icons.edit,
                    color: const Color(0xFFFF4458),
                  ),
                  onPressed: controller.toggleEditMode,
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    _buildProfileHeader(user, isMobile),
                    const SizedBox(height: 32),

                    // Stats
                    _buildStatsSection(user.stats, isMobile),
                    const SizedBox(height: 32),

                    // Badges
                    _buildBadgesSection(user.badges, isMobile),
                    const SizedBox(height: 32),

                    // Skills & Interests
                    _buildSkillsAndInterests(user, controller, isMobile),
                    const SizedBox(height: 32),

                    // Travel History
                    _buildTravelHistory(user.travelHistory, isMobile),
                    const SizedBox(height: 32),

                    // My Travel Plans (AI Generated)
                    _buildTravelPlansSection(isMobile),
                    const SizedBox(height: 32),

                    // Social Links
                    _buildSocialLinks(user.socialLinks, isMobile),

                    const SizedBox(height: 48),

                    // Legacy API Profile Link
                    _buildLegacyProfileLink(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Profile Header
  Widget _buildProfileHeader(UserModel user, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: isMobile ? 80 : 120,
              height: isMobile ? 80 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF4458),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  user.avatarUrl ?? 'https://i.pravatar.cc/300',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (user.isVerified)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: isMobile ? 24 : 32,
                  height: isMobile ? 24 : 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4458),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 20),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (user.isVerified)
                    const Icon(
                      Icons.verified,
                      color: Color(0xFFFF4458),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6b7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (user.currentCity != null && user.currentCountry != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Color(0xFFFF4458),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user.currentCity}, ${user.currentCountry}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1a1a1a),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (user.bio != null) ...[
                const SizedBox(height: 16),
                Text(
                  user.bio!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Member since ${_formatJoinDate(user.joinedDate)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9ca3af),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Stats Section
  Widget _buildStatsSection(TravelStats stats, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomad Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
                '🌍', stats.countriesVisited.toString(), 'Countries', isMobile),
            _buildStatCard(
                '🏙️', stats.citiesLived.toString(), 'Cities', isMobile),
            _buildStatCard(
                '📅', stats.daysNomading.toString(), 'Days nomading', isMobile),
            _buildStatCard(
                '🤝', stats.meetupsAttended.toString(), 'Meetups', isMobile),
            _buildStatCard(
                '✈️', stats.tripsCompleted.toString(), 'Trips', isMobile),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String emoji, String value, String label, bool isMobile) {
    return Container(
      width: isMobile ? ((Get.width - 44) / 2) : 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6b7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Badges Section
  Widget _buildBadgesSection(List<Badge> badges, bool isMobile) {
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: badges.map((badge) => _buildBadgeCard(badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                badge.description,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Skills & Interests
  Widget _buildSkillsAndInterests(
      UserModel user, UserProfileController controller, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Skills',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3)),
              ),
              child: Text(
                skill,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4458)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Interests',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.interests.map((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                interest,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Travel History
  Widget _buildTravelHistory(List<TravelHistory> history, bool isMobile) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Travel History',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 16),
        ...history.map((trip) => _buildTravelHistoryCard(trip)),
      ],
    );
  }

  Widget _buildTravelHistoryCard(TravelHistory trip) {
    final isCurrentLocation = trip.endDate == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentLocation
            ? const Color(0xFFFF4458).withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentLocation
              ? const Color(0xFFFF4458).withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
          width: isCurrentLocation ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${trip.city}, ${trip.country}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a1a1a))),
                        if (isCurrentLocation) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFF4458),
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('Current',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_formatDate(trip.startDate)} - ${trip.endDate != null ? _formatDate(trip.endDate!) : 'Present'}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6b7280)),
                    ),
                  ],
                ),
              ),
              if (trip.rating != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(trip.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E))),
                    ],
                  ),
                ),
            ],
          ),
          if (trip.review != null) ...[
            const SizedBox(height: 12),
            Text(trip.review!,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF374151), height: 1.5)),
          ],
        ],
      ),
    );
  }

  // Social Links
  Widget _buildSocialLinks(Map<String, String> links, bool isMobile) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Connect',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: links.entries
              .map((entry) => _buildSocialLinkButton(entry.key, entry.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSocialLinkButton(String platform, String url) {
    IconData icon;
    Color color;

    switch (platform.toLowerCase()) {
      case 'twitter':
        icon = Icons.flutter_dash;
        color = const Color(0xFF1DA1F2);
        break;
      case 'github':
        icon = Icons.code;
        color = const Color(0xFF171515);
        break;
      case 'linkedin':
        icon = Icons.business;
        color = const Color(0xFF0A66C2);
        break;
      case 'website':
        icon = Icons.language;
        color = const Color(0xFF6B7280);
        break;
      default:
        icon = Icons.link;
        color = const Color(0xFF6B7280);
    }

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(platform.toUpperCase(),
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  // Legacy Profile Link
  Widget _buildLegacyProfileLink() {
    return Column(
      children: [
        // 位置服务设置
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF4458), size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '位置服务',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.locationDemo);
                },
                child: const Text('打开',
                    style: TextStyle(color: Color(0xFFFF4458))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // API开发者设置
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'API Developer Settings',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.login);
                },
                child: const Text('View',
                    style: TextStyle(color: Color(0xFFFF4458))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 我的旅行计划部分
  Widget _buildTravelPlansSection(bool isMobile) {
    // 这里应该从用户数据中获取保存的计划
    // 暂时使用空列表演示
    final savedPlans = <String>[]; // TODO: 从UserProfileController获取

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Color(0xFFFF4458),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'My Travel Plans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Info',
                  'Visit city details and click "AI Travel Plan" to generate new plans',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor:
                      const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  colorText: const Color(0xFF3B82F6),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create New'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF4458),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (savedPlans.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.travel_explore,
                    size: 48,
                    color: Color(0xFFFF4458),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Travel Plans Yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate AI-powered travel plans from city detail pages',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back(); // 返回主页
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Get.to(() => const DataServicePage(scrollToCities: true));
                    });
                  },
                  icon: const Icon(Icons.explore, size: 18),
                  label: const Text('Explore Cities'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          // TODO: 显示保存的旅行计划列表
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedPlans.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: const Text('Travel plan card'), // Placeholder
              );
            },
          ),
      ],
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
