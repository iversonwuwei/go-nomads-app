import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 用户个人资料页面
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserStateController _profileController = Get.find<UserStateController>();

  // TODO: enable when server provides travel history data again.
  static const bool _travelHistoryEnabled = false;

  Map<String, dynamic> _userInfo = {
    'id': 'unknown',
    'username': 'nomad',
    'name': 'Digital Nomad',
    'email': 'nomad@example.com',
    'memberSince': '2024-01-15',
    'favoritesCount': 12,
    'visitedCount': 8,
    'countriesCount': 0,
    'citiesCount': 0,
    'avatar': 'https://ui-avatars.com/api/?name=Digital+Nomad&background=FF9800&color=fff&size=200',
  };

  User? _routeUser;
  Worker? _currentUserWorker;
  String? _requestedUserId;
  bool _isRemoteProfileLoading = false;
  String? _remoteProfileError;

  @override
  void initState() {
    super.initState();
    _initializeProfileData();
    _listenForCurrentUserUpdates();
  }

  @override
  void dispose() {
    _currentUserWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final chatUser = _getChatTargetUser();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildProfileBody(isMobile, chatUser),
      ),
    );
  }

  Widget _buildProfileBody(bool isMobile, User? chatUser) {
    if (_shouldBlockForRemoteProfile()) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_remoteProfileError != null) {
      return _buildRemoteErrorState(isMobile);
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 24 : 32,
        isMobile ? 16 : 24,
        100,
      ),
      children: [
        _buildUserInfoCard(isMobile, chatUser),
        const SizedBox(height: 24),
        _buildStatsSection(isMobile),
        const SizedBox(height: 24),
        _buildBadgesSection(isMobile),
        if (_travelHistoryEnabled) ...[
          const SizedBox(height: 24),
          _buildTravelHistorySection(isMobile),
        ],
        const SizedBox(height: 24),
        _buildSkillsSection(isMobile),
        const SizedBox(height: 24),
        _buildInterestsSection(isMobile),
      ],
    );
  }

  bool _shouldBlockForRemoteProfile() {
    if (_requestedUserId == null) {
      return false;
    }

    if (_routeUser != null) {
      return false;
    }

    return _isRemoteProfileLoading;
  }

  Widget _buildRemoteErrorState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.circleExclamation, color: Colors.redAccent, size: 56),
              const SizedBox(height: 16),
              Text(
                _remoteProfileError ?? '无法加载用户信息',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _requestedUserId == null ? null : () => _fetchUserProfile(_requestedUserId!),
                icon: const Icon(FontAwesomeIcons.arrowsRotate),
                label: const Text('重新加载'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('返回上一页'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      leading: const AppBackButton(),
      title: Text(
        _userInfo['username'] ?? 'Profile',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(bool isMobile, User? chatUser) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SafeCircleAvatar(
            imageUrl: _userInfo['avatar'],
            radius: isMobile ? 50 : 70,
            backgroundColor: AppColors.containerBlueGrey,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            _userInfo['name'],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _userInfo['email'],
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.calendar,
                  color: AppColors.accent,
                  size: isMobile ? 14 : 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Member since ${_userInfo['memberSince']}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 20 : 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: chatUser == null ? null : () => _openChat(chatUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(FontAwesomeIcons.message),
              label: Text(
                'Message',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  FontAwesomeIcons.earthAmericas,
                  'Countries',
                  _userInfo['countriesCount'].toString(),
                  Colors.blue,
                  isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: _buildStatItem(
                  FontAwesomeIcons.city,
                  'Cities',
                  _userInfo['citiesCount'].toString(),
                  Colors.orange,
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(bool isMobile) {
    final user = _getDisplayUser();

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final badges = user.badges;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.trophy, color: AppColors.accent, size: isMobile ? 24 : 28),
              const SizedBox(width: 8),
              Text(
                'Achievements & Badges',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (badges.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 40 : 60,
                horizontal: isMobile ? 20 : 40,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.trophy,
                    size: isMobile ? 48 : 64,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No badges earned yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start exploring and attending events to earn badges!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 3 : 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeCard(badge, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: TextStyle(fontSize: isMobile ? 32 : 40),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelHistorySection(bool isMobile) {
    final user = _getDisplayUser();

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final travelHistory = user.travelHistory;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.earthAmericas, color: AppColors.accent, size: isMobile ? 24 : 28),
                  const SizedBox(width: 8),
                  Text(
                    'Travel History',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (travelHistory.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60),
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.plane,
                      size: isMobile ? 48 : 64,
                      color: AppColors.iconSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No travel history yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: travelHistory.length > 5 ? 5 : travelHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final travel = travelHistory[index];
                return _buildTravelHistoryCard(travel, isMobile);
              },
            ),
          if (travelHistory.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    AppToast.info('View all travel history coming soon');
                  },
                  child: Text(
                    'View all ${travelHistory.length} trips →',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTravelHistoryCard(TravelHistory travel, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // 城市国旗/图标
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                _getCountryFlag(travel.countryName ?? ''),
                style: TextStyle(fontSize: isMobile ? 24 : 32),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 城市信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travel.cityName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  travel.countryName ?? '',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.calendar,
                      size: isMobile ? 12 : 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(travel.visitDate.toIso8601String(), null),
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: isMobile ? 11 : 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 不显示评分(entity中没有rating字段)
        ],
      ),
    );
  }

  String _getCountryFlag(String country) {
    // 简单的国家到国旗emoji映射
    final Map<String, String> countryFlags = {
      'Thailand': '🇹🇭',
      'Indonesia': '🇮🇩',
      'Vietnam': '🇻🇳',
      'Portugal': '🇵🇹',
      'Mexico': '🇲🇽',
      'Japan': '🇯🇵',
      'China': '🇨🇳',
      'USA': '🇺🇸',
      'UK': '🇬🇧',
      'Spain': '🇪🇸',
      'France': '🇫🇷',
      'Germany': '🇩🇪',
      'Italy': '🇮🇹',
      'Brazil': '🇧🇷',
      'Australia': '🇦🇺',
    };
    return countryFlags[country] ?? '🌍';
  }

  String _formatDateRange(String startDate, String? endDate) {
    try {
      final start = DateTime.parse(startDate);
      final startFormatted = '${start.month}/${start.year}';

      if (endDate == null || endDate.isEmpty) {
        return '$startFormatted - Present';
      }

      final end = DateTime.parse(endDate);
      final endFormatted = '${end.month}/${end.year}';

      return '$startFormatted - $endFormatted';
    } catch (e) {
      return startDate;
    }
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 32 : 40),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(bool isMobile) {
    final user = _getDisplayUser();

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final skills = user.skills;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          if (skills.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 32),
                child: Text(
                  'No skills added yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill.name),
                  backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                  labelStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  side: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(bool isMobile) {
    final user = _getDisplayUser();

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final interests = user.interests;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interests',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          if (interests.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 32),
                child: Text(
                  'No interests added yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map((interest) {
                return Chip(
                  label: Text(interest.name),
                  backgroundColor: AppColors.containerBlueGrey.withValues(alpha: 0.15),
                  labelStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  side: BorderSide(
                    color: AppColors.containerBlueGrey.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _initializeProfileData() {
    final args = Get.arguments;
    _requestedUserId = _extractUserId(args);
    _routeUser = _parseRouteUser(args);

    if (_requestedUserId != null && _routeUser != null && _routeUser!.id != _requestedUserId) {
      // 忽略不匹配的数据，等待后端返回
      _routeUser = null;
    }

    if (_requestedUserId != null && _profileController.currentUser.value?.id == _requestedUserId) {
      _routeUser = _profileController.currentUser.value;
    }

    if (_routeUser != null) {
      _userInfo = _mapUserToInfo(_routeUser!);
    } else if (_requestedUserId == null) {
      final currentUser = _profileController.currentUser.value;
      if (currentUser != null) {
        _userInfo = _mapUserToInfo(currentUser);
      }
    } else {
      _userInfo = _buildLoadingUserInfo(_requestedUserId!);
    }

    if (_requestedUserId != null) {
      _fetchUserProfile(_requestedUserId!);
    }
  }

  void _listenForCurrentUserUpdates() {
    _currentUserWorker = ever<User?>(
      _profileController.currentUser,
      (user) {
        if (!mounted || user == null) {
          return;
        }
        if (_routeUser != null) {
          return;
        }
        if (_requestedUserId != null && _requestedUserId!.isNotEmpty) {
          return;
        }
        setState(() {
          _userInfo = _mapUserToInfo(user);
        });
      },
    );
  }

  Future<void> _fetchUserProfile(String userId) async {
    if (userId.isEmpty) {
      return;
    }

    setState(() {
      _isRemoteProfileLoading = true;
      _remoteProfileError = null;
    });

    final user = await _profileController.getUserById(userId);

    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        _isRemoteProfileLoading = false;
        _remoteProfileError = '无法加载用户信息';
      });
      return;
    }

    setState(() {
      _routeUser = user;
      _userInfo = _mapUserToInfo(user);
      _isRemoteProfileLoading = false;
      _remoteProfileError = null;
    });
  }

  String? _extractUserId(dynamic args) {
    if (args == null) {
      return null;
    }

    if (args is User) {
      return args.id;
    }

    if (args is String && args.isNotEmpty) {
      return args;
    }

    if (args is Map<String, dynamic>) {
      final nestedUser = args['user'];
      if (nestedUser is User) {
        return nestedUser.id;
      }

      final id = args['userId'] ?? args['id'];
      if (id is String && id.isNotEmpty) {
        return id;
      }
    }

    return null;
  }

  Map<String, dynamic> _buildLoadingUserInfo(String userId) {
    return {
      'id': userId,
      'username': userId,
      'name': '加载中...',
      'email': '加载中...',
      'memberSince': '--',
      'favoritesCount': 0,
      'visitedCount': 0,
      'countriesCount': 0,
      'citiesCount': 0,
      'avatar': 'https://ui-avatars.com/api/?name=User&background=374151&color=fff&size=200',
    };
  }

  User? _parseRouteUser(dynamic args) {
    if (args == null) {
      return null;
    }

    if (args is User) {
      return args;
    }

    if (args is Map<String, dynamic>) {
      final id = args['userId'] ?? args['id'];
      final username = args['username'] ?? args['name'];

      if (id == null || username == null) {
        return null;
      }

      final statsArgument = args['stats'];

      return User(
        id: id.toString(),
        name: (args['name'] ?? username).toString(),
        username: username.toString(),
        email: args['email'] as String?,
        bio: args['bio'] as String?,
        avatarUrl: args['avatarUrl'] as String?,
        currentCity: args['currentCity'] as String?,
        currentCountry: args['currentCountry'] as String?,
        skills: const [],
        interests: const [],
        socialLinks: const {},
        badges: const [],
        stats: _parseStats(statsArgument, args),
        travelHistory: const [],
        joinedDate: _parseDate(args['joinedDate']?.toString()) ?? DateTime.now(),
        isVerified: args['isVerified'] == true,
      );
    }

    return null;
  }

  TravelStats _parseStats(
    dynamic stats,
    Map<String, dynamic> fallback,
  ) {
    if (stats is TravelStats) {
      return stats;
    }

    if (stats is Map<String, dynamic>) {
      return TravelStats(
        citiesVisited: _parseInt(stats['citiesVisited']),
        countriesVisited: _parseInt(stats['countriesVisited']),
        reviewsWritten: _parseInt(stats['reviewsWritten']),
        photosShared: _parseInt(stats['photosShared']),
        totalDistanceTraveled: _parseDouble(stats['totalDistanceTraveled']),
      );
    }

    return TravelStats(
      citiesVisited: _parseInt(fallback['visitedCount']),
      countriesVisited: _parseInt(fallback['countriesVisited']),
      reviewsWritten: _parseInt(fallback['favoritesCount']),
      photosShared: 0,
      totalDistanceTraveled: 0,
    );
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> _mapUserToInfo(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'name': user.name,
      'email': user.email ?? 'Email not provided',
      'memberSince': _formatMemberSince(user.joinedDate),
      'favoritesCount': user.stats.reviewsWritten,
      'visitedCount': user.stats.citiesVisited,
      'countriesCount': user.stats.countriesVisited,
      'citiesCount': user.stats.citiesVisited,
      'avatar': user.avatarUrl ?? 'https://ui-avatars.com/api/?name=${user.name}&background=FF9800&color=fff&size=200',
    };
  }

  String _formatMemberSince(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day';
  }

  User? _getDisplayUser() {
    if (_routeUser != null) {
      return _routeUser;
    }

    if (_requestedUserId != null && _requestedUserId!.isNotEmpty) {
      return null;
    }

    return _profileController.currentUser.value;
  }

  User? _getChatTargetUser() => _getDisplayUser();

  void _openChat(User user) {
    Get.toNamed(AppRoutes.directChat, arguments: user);
  }
}
