import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../config/supabase_config.dart';
import '../controllers/locale_controller.dart';
import '../features/interest/domain/entities/interest.dart';
import '../features/interest/presentation/controllers/interest_state_controller.dart';
import '../features/skill/domain/entities/skill.dart';
import '../features/skill/presentation/controllers/skill_state_controller.dart';
import '../features/user/domain/entities/user.dart';
import '../features/user/presentation/controllers/user_state_controller.dart';
import '../features/user_management/domain/repositories/iuser_management_repository.dart';
import '../features/user_management/presentation/controllers/user_management_state_controller.dart';
import '../generated/app_localizations.dart';
import '../services/token_storage_service.dart';
import '../utils/image_upload_helper.dart';
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

  // 头像上传状态
  bool _uploadingAvatar = false;
  String? _newAvatarUrl;

  // 当前用户角色
  bool _isAdmin = false;
  UserManagementStateController? _userManagementController;

  @override
  void initState() {
    super.initState();
    // 延迟到下一帧执行，避免在 build 过程中触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _checkAdminRole();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // 检查用户是否为管理员
  Future<void> _checkAdminRole() async {
    final role = await TokenStorageService().getUserRole();
    debugPrint('🔍 检查用户角色: $role');

    final isAdmin = await TokenStorageService().isAdmin();
    debugPrint('🔍 是否管理员: $isAdmin');

    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        if (_isAdmin) {
          // 安全地获取或初始化用户管理 controller
          try {
            if (Get.isRegistered<UserManagementStateController>()) {
              _userManagementController =
                  Get.find<UserManagementStateController>();
            } else {
              // 如果未注册，强制创建实例
              _userManagementController = Get.put(
                UserManagementStateController(
                    Get.find<IUserManagementRepository>()),
              );
            }
            debugPrint('✅ UserManagementStateController 初始化成功');
          } catch (e) {
            debugPrint('❌ 获取 UserManagementStateController 失败: $e');
          }
        } else {
          debugPrint('⚠️ 当前用户不是管理员，不显示管理区域');
        }
      });
    }
  }

  // 加载用户资料
  Future<void> _loadUserProfile() async {
    final profileController = Get.find<UserStateController>();

    // 安全地获取或初始化 controller
    final skillController = Get.isRegistered<SkillStateController>()
        ? Get.find<SkillStateController>()
        : null;
    final interestController = Get.isRegistered<InterestStateController>()
        ? Get.find<InterestStateController>()
        : null;

    // 并行加载所有数据：用户信息、技能选项、兴趣选项
    final futures = <Future>[
      profileController.loadUserProfile(),
    ];

    if (skillController != null) {
      futures.add(skillController.getSkills());
    }

    if (interestController != null) {
      futures.add(interestController.getInterests());
    }

    await Future.wait(futures);

    // 加载后填充输入框
    final user = profileController.currentUser.value;
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email ?? '';
        _bioController.text = user.bio ?? '';
      });
    }

    // 继续监听后续的用户数据变化
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

  // 处理头像上传
  Future<void> _handleAvatarUpload() async {
    if (!SupabaseConfig.isConfigured) {
      AppToast.error('Supabase 未配置，请联系管理员');
      return;
    }

    setState(() => _uploadingAvatar = true);

    try {
      final avatarUrl = await ImageUploadHelper.uploadAvatar(context);

      if (avatarUrl != null && mounted) {
        setState(() {
          _newAvatarUrl = avatarUrl;
          _uploadingAvatar = false;
        });

        AppToast.success(
          '头像上传成功',
          title: '成功',
        );

        // TODO: 这里可以立即调用 API 保存头像 URL 到后端
        // await profileController.updateAvatar(avatarUrl);
      } else {
        setState(() => _uploadingAvatar = false);
      }
    } catch (e) {
      debugPrint('❌ 头像上传失败: $e');
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        AppToast.error('头像上传失败: $e');
      }
    }
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

            // 管理员权限管理区域（仅管理员可见）
            if (_isAdmin) ...[
              const SizedBox(height: 24),
              _buildAdminManagementSection(isMobile),
            ],

            const SizedBox(height: 32),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // TODO: 保存所有更改到后端
                  // 包括：name, bio, avatarUrl (_newAvatarUrl)

                  if (_newAvatarUrl != null) {
                    // 如果上传了新头像，这里应该调用 API 保存
                    debugPrint('新头像 URL: $_newAvatarUrl');
                    // await profileController.updateProfile(
                    //   name: _nameController.text,
                    //   bio: _bioController.text,
                    //   avatarUrl: _newAvatarUrl,
                    // );
                  }

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

      // 使用新上传的头像或原头像
      final avatarUrl = _newAvatarUrl ??
          user?.avatarUrl ??
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
                  child: _uploadingAvatar
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _uploadingAvatar ? null : _handleAvatarUpload,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _uploadingAvatar ? Colors.grey : AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _uploadingAvatar
                            ? Icons.hourglass_empty
                            : Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
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

    // 安全地获取 controller，如果不存在则不显示加载状态
    final skillController = Get.isRegistered<SkillStateController>()
        ? Get.find<SkillStateController>()
        : null;

    return Obx(() {
      final user = profileController.currentUser.value;
      final isLoading = skillController?.isLoading.value ?? false;

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
                Row(
                  children: [
                    Text(
                      l10n.skills,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton.icon(
                  icon: Icon(Icons.edit, color: AppColors.accent, size: 20),
                  label: Text(
                    '编辑',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  onPressed: isLoading
                      ? null
                      : () => _showSkillsBottomSheet(profileController),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (isLoading && skills.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (skills.isEmpty)
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
                    avatar: skill.hasIcon
                        ? Text(
                            skill.icon!,
                            style: const TextStyle(fontSize: 16),
                          )
                        : null,
                    label: Text(skill.name),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: isLoading
                        ? null
                        : () => profileController.removeSkill(skill.id),
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

    // 安全地获取 controller，如果不存在则不显示加载状态
    final interestController = Get.isRegistered<InterestStateController>()
        ? Get.find<InterestStateController>()
        : null;

    return Obx(() {
      final user = profileController.currentUser.value;
      final isLoading = interestController?.isLoading.value ?? false;

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
                Row(
                  children: [
                    Text(
                      l10n.interests,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFBA68C8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit,
                      color: Color(0xFFBA68C8), size: 20),
                  label: const Text(
                    '编辑',
                    style: TextStyle(color: Color(0xFFBA68C8)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () => _showInterestsBottomSheet(profileController),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (isLoading && interests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (interests.isEmpty)
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
                    avatar: interest.hasIcon
                        ? Text(
                            interest.icon!,
                            style: const TextStyle(fontSize: 16),
                          )
                        : null,
                    label: Text(interest.name),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: isLoading
                        ? null
                        : () => profileController.removeInterest(interest.id),
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
    print('📋 打开技能 Drawer: currentSkills = ${currentSkills.length} 个');
    for (var skill in currentSkills) {
      print('  - id=${skill.id}, name=${skill.name}, level=${skill.level}');
    }

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
    print('📋 打开兴趣 Drawer: currentInterests = ${currentInterests.length} 个');
    for (var interest in currentInterests) {
      print('  - id=${interest.id}, name=${interest.name}');
    }

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

  /// 构建管理员权限管理区域
  Widget _buildAdminManagementSection(bool isMobile) {
    if (_userManagementController == null) return const SizedBox.shrink();

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
                '🔐 管理员权限管理',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                    '已选择 ${_userManagementController!.selectedUserIds.length} 人',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // 角色加载状态提示
          Obx(() {
            if (_userManagementController!.roles.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ 角色数据未加载，批量操作功能受限\n请确认后端 /api/v1/roles 接口已正确配置',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 操作按钮行
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _batchSetAdmin(),
                  icon: const Icon(Icons.admin_panel_settings, size: 18),
                  label: const Text('设为管理员'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _batchSetUser(),
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('设为普通用户'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _userManagementController!.toggleSelectAll(),
                  icon: const Icon(Icons.check_box, size: 18),
                  label: const Text('全选/取消全选'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _userManagementController!.loadUsers(refresh: true),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('刷新'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 用户列表
          Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() {
              if (_userManagementController!.isLoading.value &&
                  _userManagementController!.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_userManagementController!.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    _userManagementController!.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (_userManagementController!.users.isEmpty) {
                return const Center(child: Text('暂无用户'));
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    _userManagementController!.loadUsers();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: _userManagementController!.users.length +
                      (_userManagementController!.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _userManagementController!.users.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final user = _userManagementController!.users[index];
                    final isSelected = _userManagementController!
                        .selectedUserIds
                        .contains(user.id);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) {
                        _userManagementController!.toggleUserSelection(user.id);
                      },
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Text(user.name.substring(0, 1).toUpperCase())
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (user.email != null)
                                  Text(
                                    user.email!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          _buildRoleBadge(user.role),
                          const SizedBox(width: 8),
                          Text(
                            '加入于 ${_formatDate(user.createdAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      activeColor: AppColors.accent,
                      dense: true,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color badgeColor;
    String roleText;

    switch (role.toLowerCase()) {
      case 'admin':
        badgeColor = Colors.red;
        roleText = '管理员';
        break;
      case 'moderator':
        badgeColor = Colors.orange;
        roleText = '版主';
        break;
      default:
        badgeColor = Colors.grey;
        roleText = '用户';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        roleText,
        style: TextStyle(
          fontSize: 11,
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return '今天';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  Future<void> _batchSetAdmin() async {
    if (_userManagementController == null) return;

    if (_userManagementController!.selectedUserIds.isEmpty) {
      AppToast.warning('请先选择要设置的用户');
      return;
    }

    final success = await _userManagementController!.batchSetAdmin();

    if (success) {
      AppToast.success(
        '已成功将 ${_userManagementController!.selectedUserIds.length} 个用户设为管理员',
        title: '成功',
      );
    } else {
      AppToast.error(
        _userManagementController!.errorMessage.value.isNotEmpty
            ? _userManagementController!.errorMessage.value
            : '批量设置管理员失败',
        title: '失败',
      );
    }
  }

  Future<void> _batchSetUser() async {
    if (_userManagementController == null) return;

    if (_userManagementController!.selectedUserIds.isEmpty) {
      AppToast.warning('请先选择要设置的用户');
      return;
    }

    final success = await _userManagementController!.batchSetUser();

    if (success) {
      AppToast.success(
        '已成功将 ${_userManagementController!.selectedUserIds.length} 个用户设为普通用户',
        title: '成功',
      );
    } else {
      AppToast.error(
        _userManagementController!.errorMessage.value.isNotEmpty
            ? _userManagementController!.errorMessage.value
            : '批量设置用户失败',
        title: '失败',
      );
    }
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
    // 延迟到下一帧加载，避免在父组件 build 期间触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSkills();
    });
  }

  Future<void> _loadSkills() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await widget.skillController.getSkills();
      if (!mounted) return;

      final skills = List<Skill>.from(widget.skillController.skills);

      // 先设置数据，再调用预选方法
      _skillsByCategory = _groupSkillsByCategory(skills);
      _preselectCurrentSkills();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // 延迟到下一帧检查错误，避免在 build 期间触发状态更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final error = widget.skillController.errorMessage.value;
        if (error != null && error.isNotEmpty) {
          Get.snackbar(
            '加载失败',
            error,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
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
    print('🔍 预选技能开始: currentSkills = ${widget.currentSkills.length} 个');
    for (var userSkill in widget.currentSkills) {
      print('  - 查找技能: id=${userSkill.id}, name=${userSkill.name}');
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
          print('  ✅ 找到并添加技能: ${skill.name}');
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
        } else if (skill.id.isEmpty) {
          print('  ❌ 未找到技能: ${userSkill.name}');
        }
      }
    }
    print('🔍 预选完成: _selectedSkills = ${_selectedSkills.length} 个');
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
            if (isSelected) {
              print('🎯 技能 ${skill.name} (id=${skill.id}) 被标记为选中');
            }
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
    // 延迟到下一帧加载，避免在父组件 build 期间触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInterests();
    });
  }

  Future<void> _loadInterests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await widget.interestController.getInterests();
      if (!mounted) return;

      final interests =
          List<Interest>.from(widget.interestController.interests);

      // 先设置数据，再调用预选方法
      _interestsByCategory = _groupInterestsByCategory(interests);
      _preselectCurrentInterests();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // 延迟到下一帧检查错误，避免在 build 期间触发状态更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final error = widget.interestController.errorMessage.value;
        if (error != null && error.isNotEmpty) {
          Get.snackbar(
            '加载失败',
            error,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
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
    print('🔍 预选兴趣开始: currentInterests = ${widget.currentInterests.length} 个');
    for (var userInterest in widget.currentInterests) {
      print('  - 查找兴趣: id=${userInterest.id}, name=${userInterest.name}');
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
          print('  ✅ 找到并添加兴趣: ${interest.name}');
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
        } else if (interest.id.isEmpty) {
          print('  ❌ 未找到兴趣: ${userInterest.name}');
        }
      }
    }
    print('🔍 预选完成: _selectedInterests = ${_selectedInterests.length} 个');
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
            if (isSelected) {
              print('🎯 兴趣 ${interest.name} (id=${interest.id}) 被标记为选中');
            }
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

// 技能选择底部抽屉组件
