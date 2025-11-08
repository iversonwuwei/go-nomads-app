import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/locale_controller.dart';
import '../features/interest/domain/entities/interest.dart';
import '../features/interest/presentation/controllers/interest_state_controller.dart';
import '../features/skill/domain/entities/skill.dart';
import '../features/skill/presentation/controllers/skill_state_controller.dart';
import '../features/user/domain/entities/user.dart';
import '../features/user/presentation/controllers/user_state_controller.dart';
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
    // 延迟到下一帧执行，避免在 build 过程中触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
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
    final profileController = Get.find<UserStateController>();

    // 监听用户数据变化，填充输入框
    ever(profileController.currentUser, (user) {
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email ?? '';
          _bioController.text = user.bio ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    // 在这里获取 controller
    final profileController = Get.find<UserStateController>();
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
    final profileController = Get.find<UserStateController>();

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

  Widget _buildSkillsSection(
      bool isMobile, UserStateController profileController) {
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
                TextButton.icon(
                  icon: Icon(Icons.edit, color: AppColors.accent, size: 20),
                  label: Text(
                    '编辑',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  onPressed: () => _showSkillsBottomSheet(profileController),
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
                    label: Text(skill.name),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => profileController.removeSkill(skill.id),
                    backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    deleteIconColor: AppColors.textSecondary,
                    side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildInterestsSection(
      bool isMobile, UserStateController profileController) {
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
                TextButton.icon(
                  icon: Icon(Icons.edit, color: AppColors.accent, size: 20),
                  label: Text(
                    '编辑',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  onPressed: () => _showInterestsBottomSheet(profileController),
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
                    label: Text(interest.name),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () =>
                        profileController.removeInterest(interest.id),
                    backgroundColor:
                        const Color(0xFFBA68C8).withValues(alpha: 0.1),
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
      activeThumbColor: AppColors.accent,
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

  // 显示技能选择底部抽屉
  void _showSkillsBottomSheet(UserStateController profileController) {
    final SkillStateController skillController =
        Get.find<SkillStateController>();
    final currentUser = profileController.currentUser.value;

    if (currentUser == null) {
      AppToast.error('请先登录');
      return;
    }

    final currentSkills = currentUser.skills;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SkillsBottomSheet(
        skillController: skillController,
        currentSkills: currentSkills,
        onSave: (selectedSkills) async {
          if (selectedSkills.isNotEmpty) {
            try {
              var successCount = 0;
              for (final skill in selectedSkills) {
                final success = await skillController.addUserSkill(
                  currentUser.id,
                  AddUserSkillRequest(
                    skillId: skill.skillId,
                    proficiencyLevel: skill.proficiencyLevel,
                    yearsOfExperience: skill.yearsOfExperience,
                  ),
                );
                if (success) {
                  successCount++;
                }
              }

              if (successCount > 0) {
                AppToast.success(
                  '已保存 $successCount 个技能',
                  title: '保存成功',
                );

                // 刷新用户资料数据
                await profileController.loadUserProfile();
              } else {
                AppToast.error('保存失败，请稍后重试');
              }
            } catch (e) {
              print('❌ 保存技能失败: $e');
              AppToast.error('保存失败，请稍后重试');
            }
          }
        },
      ),
    );
  }

  // 显示兴趣选择底部抽屉
  void _showInterestsBottomSheet(UserStateController profileController) {
    final InterestStateController interestController =
        Get.find<InterestStateController>();
    final currentUser = profileController.currentUser.value;

    if (currentUser == null) {
      AppToast.error('请先登录');
      return;
    }

    final currentInterests = currentUser.interests;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InterestsBottomSheet(
        interestController: interestController,
        currentInterests: currentInterests,
        onSave: (selectedInterests) async {
          if (selectedInterests.isNotEmpty) {
            try {
              var successCount = 0;
              for (final interest in selectedInterests) {
                final success = await interestController.addUserInterest(
                  currentUser.id,
                  AddUserInterestRequest(
                    interestId: interest.interestId,
                    intensityLevel: interest.intensityLevel,
                  ),
                );
                if (success) {
                  successCount++;
                }
              }

              if (successCount > 0) {
                AppToast.success(
                  '已保存 $successCount 个兴趣',
                  title: '保存成功',
                );

                // 刷新用户资料数据
                await profileController.loadUserProfile();
              } else {
                AppToast.error('保存失败，请稍后重试');
              }
            } catch (e) {
              print('❌ 保存兴趣失败: $e');
              AppToast.error('保存失败，请稍后重试');
            }
          }
        },
      ),
    );
  }
}

// 技能选择底部抽屉组件
class _SkillsBottomSheet extends StatefulWidget {
  final SkillStateController skillController;
  final List<UserSkillInfo> currentSkills;
  final Function(List<UserSkill>) onSave;

  const _SkillsBottomSheet({
    required this.skillController,
    required this.currentSkills,
    required this.onSave,
  });

  @override
  State<_SkillsBottomSheet> createState() => _SkillsBottomSheetState();
}

class _SkillsBottomSheetState extends State<_SkillsBottomSheet> {
  List<SkillsByCategory> _skillsByCategory = [];
  final List<UserSkill> _selectedSkills = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);

    try {
      await widget.skillController.getSkills();

      final skills = List<Skill>.from(widget.skillController.skills);
      if (!mounted) return;

      setState(() {
        _skillsByCategory = _groupSkillsByCategory(skills);
        _isLoading = false;
        // 预填充当前用户已有的技能
        _preselectCurrentSkills();
      });

      final error = widget.skillController.errorMessage.value;
      if (error != null && error.isNotEmpty && mounted) {
        Get.snackbar(
          '加载失败',
          error,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ 加载技能失败: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      Get.snackbar(
        '加载失败',
        '无法加载技能列表: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  List<SkillsByCategory> _groupSkillsByCategory(List<Skill> skills) {
    final Map<String, List<Skill>> grouped = {};
    for (final skill in skills) {
      grouped.putIfAbsent(skill.category, () => []).add(skill);
    }

    final categories = grouped.entries
        .map((entry) => SkillsByCategory(
              category: entry.key,
              skills: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));

    return categories;
  }

  void _preselectCurrentSkills() {
    // 预填充用户已有的技能
    for (var userSkill in widget.currentSkills) {
      for (var category in _skillsByCategory) {
        final skill = category.skills.firstWhere(
          (s) => s.id == userSkill.id,
          orElse: () => Skill(
            id: '',
            name: '',
            category: '',
            createdAt: DateTime.now(),
          ),
        );

        if (skill.id.isNotEmpty &&
            !_selectedSkills.any((s) => s.skillId == skill.id)) {
          _selectedSkills.add(UserSkill(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: '',
            skillId: skill.id,
            skillName: skill.name,
            category: skill.category,
            icon: skill.icon,
            proficiencyLevel: userSkill.level,
            yearsOfExperience: null,
            createdAt: DateTime.now(),
          ));
        }
      }
    }
  }

  void _toggleSkill(Skill skill) {
    final isSelected = _selectedSkills.any((s) => s.skillId == skill.id);

    setState(() {
      if (isSelected) {
        _selectedSkills.removeWhere((s) => s.skillId == skill.id);
      } else {
        final userSkill = UserSkill(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '',
          skillId: skill.id,
          skillName: skill.name,
          category: skill.category,
          icon: skill.icon,
          proficiencyLevel: 'Intermediate',
          yearsOfExperience: null,
          createdAt: DateTime.now(),
        );
        _selectedSkills.add(userSkill);
      }
    });
  }

  List<Skill> _getFilteredSkills() {
    List<Skill> allSkills = [];

    for (var category in _skillsByCategory) {
      if (_selectedCategory != null && category.category != _selectedCategory) {
        continue;
      }
      allSkills.addAll(category.skills);
    }

    if (_searchQuery.isNotEmpty) {
      allSkills = allSkills.where((skill) {
        return skill.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return allSkills;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 标题栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择技能',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        if (_selectedSkills.isNotEmpty)
                          Text(
                            '${_selectedSkills.length} 项',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 搜索框
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索技能...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.containerLight,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // 类别筛选
              if (_searchQuery.isEmpty && _skillsByCategory.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryChip('全部', null),
                      const SizedBox(width: 8),
                      ..._skillsByCategory.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            _getCategoryText(category.category),
                            category.category,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // 技能列表
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSkillsList(scrollController),
              ),

              // 底部按钮
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(_selectedSkills);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        '确定 (${_selectedSkills.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsList(ScrollController scrollController) {
    final filteredSkills = _getFilteredSkills();

    if (filteredSkills.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? '暂无技能' : '未找到匹配的技能',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredSkills.map((skill) {
            final isSelected =
                _selectedSkills.any((s) => s.skillId == skill.id);
            return FilterChip(
              avatar: Text(skill.icon ?? '💼'),
              label: Text(skill.name),
              selected: isSelected,
              onSelected: (_) => _toggleSkill(skill),
              selectedColor: AppColors.accent.withValues(alpha: 0.2),
              checkmarkColor: AppColors.accent,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getCategoryText(String category) {
    const categoryMap = {
      'Programming': '编程开发',
      'Design': '设计创意',
      'Marketing': '营销商务',
      'Languages': '语言能力',
      'Data': '数据分析',
      'Management': '项目管理',
      'Other': '其他技能',
    };
    return categoryMap[category] ?? category;
  }
}

// 兴趣选择底部抽屉组件
class _InterestsBottomSheet extends StatefulWidget {
  final InterestStateController interestController;
  final List<UserInterestInfo> currentInterests;
  final Function(List<UserInterest>) onSave;

  const _InterestsBottomSheet({
    required this.interestController,
    required this.currentInterests,
    required this.onSave,
  });

  @override
  State<_InterestsBottomSheet> createState() => _InterestsBottomSheetState();
}

class _InterestsBottomSheetState extends State<_InterestsBottomSheet> {
  List<InterestsByCategory> _interestsByCategory = [];
  final List<UserInterest> _selectedInterests = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    setState(() => _isLoading = true);

    try {
      await widget.interestController.getInterests();

      final interests =
          List<Interest>.from(widget.interestController.interests);
      if (!mounted) return;

      setState(() {
        _interestsByCategory = _groupInterestsByCategory(interests);
        _isLoading = false;
        // 预填充当前用户已有的兴趣
        _preselectCurrentInterests();
      });

      final error = widget.interestController.errorMessage.value;
      if (error != null && error.isNotEmpty && mounted) {
        Get.snackbar(
          '加载失败',
          error,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ 加载兴趣失败: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      Get.snackbar(
        '加载失败',
        '无法加载兴趣列表: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  List<InterestsByCategory> _groupInterestsByCategory(
      List<Interest> interests) {
    final Map<String, List<Interest>> grouped = {};
    for (final interest in interests) {
      grouped.putIfAbsent(interest.category, () => []).add(interest);
    }

    final categories = grouped.entries
        .map((entry) => InterestsByCategory(
              category: entry.key,
              interests: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));

    return categories;
  }

  void _preselectCurrentInterests() {
    // 预填充用户已有的兴趣
    for (var userInterest in widget.currentInterests) {
      for (var category in _interestsByCategory) {
        final interest = category.interests.firstWhere(
          (i) => i.id == userInterest.id,
          orElse: () => Interest(
            id: '',
            name: '',
            category: '',
            createdAt: DateTime.now(),
          ),
        );

        if (interest.id.isNotEmpty &&
            !_selectedInterests.any((i) => i.interestId == interest.id)) {
          _selectedInterests.add(UserInterest(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: '',
            interestId: interest.id,
            interestName: interest.name,
            category: interest.category,
            icon: interest.icon,
            intensityLevel: 'moderate',
            createdAt: DateTime.now(),
          ));
        }
      }
    }
  }

  void _toggleInterest(Interest interest) {
    final isSelected =
        _selectedInterests.any((i) => i.interestId == interest.id);

    setState(() {
      if (isSelected) {
        _selectedInterests.removeWhere((i) => i.interestId == interest.id);
      } else {
        final userInterest = UserInterest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '',
          interestId: interest.id,
          interestName: interest.name,
          category: interest.category,
          icon: interest.icon,
          intensityLevel: 'Medium',
          createdAt: DateTime.now(),
        );
        _selectedInterests.add(userInterest);
      }
    });
  }

  List<Interest> _getFilteredInterests() {
    List<Interest> allInterests = [];

    for (var category in _interestsByCategory) {
      if (_selectedCategory != null && category.category != _selectedCategory) {
        continue;
      }
      allInterests.addAll(category.interests);
    }

    if (_searchQuery.isNotEmpty) {
      allInterests = allInterests.where((interest) {
        return interest.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return allInterests;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 标题栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择兴趣',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        if (_selectedInterests.isNotEmpty)
                          Text(
                            '${_selectedInterests.length} 项',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 搜索框
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索兴趣...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.containerLight,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // 类别筛选
              if (_searchQuery.isEmpty && _interestsByCategory.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryChip('全部', null),
                      const SizedBox(width: 8),
                      ..._interestsByCategory.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            _getCategoryText(category.category),
                            category.category,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // 兴趣列表
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildInterestsList(scrollController),
              ),

              // 底部按钮
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(_selectedInterests);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        '确定 (${_selectedInterests.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsList(ScrollController scrollController) {
    final filteredInterests = _getFilteredInterests();

    if (filteredInterests.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? '暂无兴趣' : '未找到匹配的兴趣',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredInterests.map((interest) {
            final isSelected =
                _selectedInterests.any((i) => i.interestId == interest.id);
            return FilterChip(
              avatar: Text(interest.icon ?? '❤️'),
              label: Text(interest.name),
              selected: isSelected,
              onSelected: (_) => _toggleInterest(interest),
              selectedColor: AppColors.accent.withValues(alpha: 0.2),
              checkmarkColor: AppColors.accent,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getCategoryText(String category) {
    const categoryMap = {
      'Sports': '运动健身',
      'Arts': '艺术文化',
      'Food': '美食烹饪',
      'Travel': '旅行探险',
      'Technology': '科技数码',
      'Reading': '阅读学习',
      'Music': '音乐娱乐',
      'Social': '社交公益',
    };
    return categoryMap[category] ?? category;
  }
}
