import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/locale_controller.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';

/// 用户个人资料页面
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // 用户信息
  final Map<String, dynamic> _userInfo = {
    'name': 'Digital Nomad',
    'email': 'nomad@example.com',
    'memberSince': '2024-01-15',
    'favoritesCount': 12,
    'visitedCount': 8,
    'avatar':
        'https://ui-avatars.com/api/?name=Digital+Nomad&background=FF9800&color=fff&size=200',
  };

  // 用户偏好设置
  bool _notifications = true;
  String _currency = 'USD';
  String _temperatureUnit = 'Celsius';

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY'];
  final List<String> _temperatureUnits = ['Celsius', 'Fahrenheit'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 18 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Edit Profile',
                'Profile editing coming soon',
                backgroundColor: Colors.orange.withValues(alpha: 0.8),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        children: [
          // 用户信息卡片
          _buildUserInfoCard(isMobile),

          const SizedBox(height: 24),

          // 统计信息
          _buildStatsSection(isMobile),

          const SizedBox(height: 24),

          // 偏好设置
          _buildPreferencesSection(isMobile),

          const SizedBox(height: 24),

          // 账户操作
          _buildAccountActionsSection(isMobile),

          const SizedBox(height: 32),

          // 登出按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Logout',
                  titleStyle: const TextStyle(color: Colors.white),
                  backgroundColor: const Color(0xFF1a1a1a),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  textCancel: 'Cancel',
                  textConfirm: 'Logout',
                  cancelTextColor: Colors.white70,
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    Get.back();
                    Get.snackbar(
                      'Logged Out',
                      'You have been successfully logged out',
                      backgroundColor: Colors.green.withValues(alpha: 0.8),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
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

  Widget _buildUserInfoCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // 头像
          CircleAvatar(
            radius: isMobile ? 50 : 70,
            backgroundImage: NetworkImage(_userInfo['avatar']),
            backgroundColor: Colors.orange,
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // 用户名
          Text(
            _userInfo['name'],
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // 邮箱
          Text(
            _userInfo['email'],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isMobile ? 14 : 16,
            ),
          ),

          const SizedBox(height: 8),

          // 会员时间
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.orange,
                size: isMobile ? 14 : 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Member since ${_userInfo['memberSince']}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.favorite,
                  'Favorites',
                  _userInfo['favoritesCount'].toString(),
                  Colors.red,
                  isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: _buildStatItem(
                  Icons.location_on,
                  'Visited',
                  _userInfo['visitedCount'].toString(),
                  Colors.green,
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 32 : 40),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // 通知开关
          _buildSwitchTile(
            'Notifications',
            'Receive updates about new cities',
            Icons.notifications,
            _notifications,
            (value) => setState(() => _notifications = value),
            isMobile,
          ),

          const Divider(color: Colors.white24, height: 32),

          // 货币选择
          _buildDropdownTile(
            'Currency',
            Icons.attach_money,
            _currency,
            _currencies,
            (value) => setState(() => _currency = value!),
            isMobile,
          ),

          const Divider(color: Colors.white24, height: 32),

          // 温度单位选择
          _buildDropdownTile(
            'Temperature Unit',
            Icons.thermostat,
            _temperatureUnit,
            _temperatureUnits,
            (value) => setState(() => _temperatureUnit = value!),
            isMobile,
          ),

          const Divider(color: Colors.white24, height: 32),

          // 语言选择
          _buildLanguageTile(isMobile),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(bool isMobile) {
    final localeController = Get.find<LocaleController>();
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.languageSettings),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.language,
                color: Colors.orange, size: isMobile ? 20 : 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.language,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        localeController.currentLanguageName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: isMobile ? 12 : 14,
                        ),
                      )),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: isMobile ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isMobile,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: isMobile ? 20 : 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildDropdownTile(
    String title,
    IconData icon,
    String value,
    List<String> items,
    Function(String?) onChanged,
    bool isMobile,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: isMobile ? 20 : 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1a1a1a),
          style: TextStyle(
            color: Colors.orange,
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
          underline: Container(),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildActionTile(
            'Privacy Settings',
            Icons.privacy_tip,
            () => _showComingSoon('Privacy Settings'),
            isMobile,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildActionTile(
            'Help & Support',
            Icons.help,
            () => _showComingSoon('Help & Support'),
            isMobile,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildActionTile(
            'About',
            Icons.info,
            () => _showComingSoon('About'),
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: isMobile ? 20 : 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: isMobile ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available in a future update',
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
