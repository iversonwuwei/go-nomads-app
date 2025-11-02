import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/locale_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';

/// 用户资料编辑页面 - 浅色性冷淡风格
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // 用户偏好设置
  bool _notifications = true;
  bool _travelHistoryVisible = true;
  bool _profilePublic = true;
  String _currency = 'USD';
  String _temperatureUnit = 'Celsius';

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY'];
  final List<String> _temperatureUnits = ['Celsius', 'Fahrenheit'];

  // TextEditingController 用于管理输入框
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // 加载用户资料
  Future<void> _loadUserProfile() async {
    final profileController = Get.put(UserProfileController());

    // 加载用户资料
    await profileController.loadUserProfile();

    // 填充输入框
    if (profileController.currentUser.value != null) {
      final user = profileController.currentUser.value!;
      _nameController.text = user.name;
      _emailController.text = user.email ?? ''; // 使用 email 字段
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    
    // 在这里获取 controller，如果不存在则创建
    final profileController = Get.put(UserProfileController());
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            isMobile ? 16 : 24,
            isMobile ? 16 : 24,
            100, // 底部留白给导航栏
          ),
          children: [
          // 头像和基本信息编辑
          _buildProfileEditCard(isMobile),

          const SizedBox(height: 24),

          // 技能编辑
          _buildSkillsSection(isMobile, profileController),

          const SizedBox(height: 24),

          // 兴趣爱好编辑
          _buildInterestsSection(isMobile, profileController),

          const SizedBox(height: 24),

          // 偏好设置
          _buildPreferencesSection(isMobile),

          const SizedBox(height: 24),

          // 账户操作
          _buildAccountActionsSection(isMobile),

          const SizedBox(height: 32),

          // 保存按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AppToast.success(
                  l10n.profileUpdatedSuccessfully,
                  title: l10n.saved,
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.saveChanges,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildProfileEditCard(bool isMobile) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final profileController = Get.find<UserProfileController>();

    return Obx(() {
      final user = profileController.currentUser.value;

      // 生成头像 URL (如果没有 avatarUrl，使用用户名生成)
      final avatarUrl = user?.avatarUrl ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.name ?? 'User')}&background=FF9800&color=fff&size=200';
      
      return Container(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // 头像编辑
            Stack(
              children: [
                CircleAvatar(
                  radius: isMobile ? 50 : 70,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: Colors.orange,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 24),

          // 用户名编辑
          TextField(
              controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.name,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: l10n.enterYourName,
              hintStyle: TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.containerLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accent),
              ),
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),

          const SizedBox(height: 16),

            // 邮箱(只读)
          TextField(
              controller: _emailController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: l10n.email,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: 'nomad@example.com',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.containerLight.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              suffixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.iconSecondary,
              ),
            ),
            style: TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Bio
          TextField(
              controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.bio,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: l10n.tellUsAboutYourself,
              hintStyle: TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.containerLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accent),
              ),
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
    }); // 关闭 Obx
  }

  Widget _buildSkillsSection(bool isMobile, UserProfileController profileController) {
    final l10n = AppLocalizations.of(Get.context!)!;
    
    return Obx(() {
      final user = profileController.currentUser.value;

      if (user == null) {
        return const SizedBox.shrink();
      }

      final skills = user.skills;

      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.skills,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.accent),
                  onPressed: () => _showAddSkillDialog(profileController),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (skills.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.noSkillsAddedYet,
                    style: TextStyle(
                      color: AppColors.textTertiary,
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
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => profileController.removeSkill(skill),
                    backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    deleteIconColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildInterestsSection(bool isMobile, UserProfileController profileController) {
    final l10n = AppLocalizations.of(Get.context!)!;
    
    return Obx(() {
      final user = profileController.currentUser.value;

      if (user == null) {
        return const SizedBox.shrink();
      }

      final interests = user.interests;

      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.interests,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.accent),
                  onPressed: () => _showAddInterestDialog(profileController),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (interests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.noInterestsAddedYet,
                    style: TextStyle(
                      color: AppColors.textTertiary,
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
                    label: Text(interest),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => profileController.removeInterest(interest),
                    backgroundColor: const Color(0xFFBA68C8).withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    deleteIconColor: AppColors.textSecondary,
                    side: BorderSide(
                      color: const Color(0xFFBA68C8).withValues(alpha: 0.3),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPreferencesSection(bool isMobile) {
    final l10n = AppLocalizations.of(Get.context!)!;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.preferences,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildLanguageTile(isMobile),
          Divider(color: AppColors.divider),
          _buildSwitchTile(
            l10n.notificationsPreference,
            l10n.receiveUpdatesAndAlerts,
            _notifications,
            (value) => setState(() => _notifications = value),
          ),
          Divider(color: AppColors.divider),
          _buildSwitchTile(
            l10n.travelHistoryVisible,
            l10n.showTravelHistoryToOthers,
            _travelHistoryVisible,
            (value) => setState(() => _travelHistoryVisible = value),
          ),
          Divider(color: AppColors.divider),
          _buildSwitchTile(
            l10n.publicProfile,
            l10n.makeProfileVisibleToEveryone,
            _profilePublic,
            (value) => setState(() => _profilePublic = value),
          ),
          Divider(color: AppColors.divider),
          _buildDropdownTile(
            l10n.currency,
            _currency,
            _currencies,
            (value) => setState(() => _currency = value ?? 'USD'),
          ),
          Divider(color: AppColors.divider),
          _buildDropdownTile(
            l10n.temperature,
            _temperatureUnit,
            _temperatureUnits,
            (value) => setState(() => _temperatureUnit = value ?? 'Celsius'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(bool isMobile) {
    final localeController = Get.find<LocaleController>();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Language',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      subtitle: Obx(() => Text(
            localeController.locale.value.languageCode == 'en'
                ? 'English'
                : '中文',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          )),
      trailing: Obx(() => DropdownButton<String>(
            value: localeController.locale.value.languageCode,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.iconSecondary,
            ),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text('English',
                    style: TextStyle(color: AppColors.textPrimary)),
              ),
              DropdownMenuItem(
                value: 'zh',
                child:
                    Text('中文', style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
            onChanged: (languageCode) {
              if (languageCode != null) {
                localeController.changeLocale(languageCode);
              }
            },
          )),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.accent,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.iconSecondary,
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option, style: TextStyle(color: AppColors.textPrimary)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAccountActionsSection(bool isMobile) {
    final l10n = AppLocalizations.of(Get.context!)!;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.account,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionTile(
            icon: Icons.lock_outline,
            title: l10n.changePassword,
            onTap: () => AppToast.info(l10n.changePasswordComingSoon),
          ),
          Divider(color: AppColors.divider),
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacySettings,
            onTap: () => AppToast.info(l10n.privacySettingsComingSoon),
          ),
          Divider(color: AppColors.divider),
          _buildActionTile(
            icon: Icons.delete_outline,
            title: l10n.deleteAccount,
            titleColor: Colors.red,
            onTap: () {
              Get.defaultDialog(
                title: l10n.deleteAccount,
                titleStyle: TextStyle(color: AppColors.textPrimary),
                backgroundColor: Colors.white,
                content: Text(
                  l10n.deleteAccountConfirmation,
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                textCancel: l10n.cancel,
                textConfirm: 'Delete',
                cancelTextColor: AppColors.textSecondary,
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  AppToast.error(l10n.accountDeletionCancelled);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: titleColor ?? AppColors.icon,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.iconLight,
      ),
      onTap: onTap,
    );
  }

  void _showAddSkillDialog(UserProfileController profileController) {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(Get.context!)!;

    Get.defaultDialog(
      title: l10n.addSkill,
      titleStyle: TextStyle(color: AppColors.textPrimary),
      backgroundColor: Colors.white,
      content: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.enterSkillName,
          hintStyle: TextStyle(color: AppColors.textTertiary),
          filled: true,
          fillColor: AppColors.containerLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.accent),
          ),
        ),
      ),
      textCancel: l10n.cancel,
      textConfirm: l10n.add,
      cancelTextColor: AppColors.textSecondary,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.accent,
      onConfirm: () {
        if (controller.text.trim().isNotEmpty) {
          profileController.addSkill(controller.text.trim());
          Get.back();
        }
      },
    );
  }

  void _showAddInterestDialog(UserProfileController profileController) {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(Get.context!)!;

    Get.defaultDialog(
      title: l10n.addInterest,
      titleStyle: TextStyle(color: AppColors.textPrimary),
      backgroundColor: Colors.white,
      content: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.enterInterest,
          hintStyle: TextStyle(color: AppColors.textTertiary),
          filled: true,
          fillColor: AppColors.containerLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.accent),
          ),
        ),
      ),
      textCancel: l10n.cancel,
      textConfirm: l10n.add,
      cancelTextColor: AppColors.textSecondary,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.accent,
      onConfirm: () {
        if (controller.text.trim().isNotEmpty) {
          profileController.addInterest(controller.text.trim());
          Get.back();
        }
      },
    );
  }
}
