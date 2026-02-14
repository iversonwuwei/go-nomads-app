import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/supabase_config.dart';
import 'package:go_nomads_app/controllers/locale_controller.dart';
import 'package:go_nomads_app/features/interest/domain/entities/interest.dart';
import 'package:go_nomads_app/features/interest/presentation/controllers/interest_state_controller.dart';
import 'package:go_nomads_app/features/skill/domain/entities/skill.dart';
import 'package:go_nomads_app/features/skill/presentation/controllers/skill_state_controller.dart';
import 'package:go_nomads_app/features/travel_history/services/travel_detection_service.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/features/user/domain/repositories/i_user_preferences_repository.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/features/user_management/domain/repositories/iuser_management_repository.dart';
import 'package:go_nomads_app/features/user_management/presentation/controllers/user_management_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/services/notification_service.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/utils/image_upload_helper.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';

/// 用户资料编辑页面 - 浅色性冷淡风格
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> with RouteAwareRefreshMixin<ProfileEditPage> {
  // 用户偏好设置
  bool _notifications = true;
  bool _travelHistoryVisible = true;
  bool _profilePublic = true;
  bool _autoTravelDetection = false;
  String _currency = 'USD';
  String _temperatureUnit = 'Celsius';

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

  // 用户偏好设置仓库
  IUserPreferencesRepository? _preferencesRepository;

  // 是否正在加载或保存偏好设置
  bool _isLoadingPreferences = false;
  bool _isSavingPreferences = false;

  @override
  void initState() {
    super.initState();
    // 初始化通知状态
    _initNotificationState();
    // 初始化自动旅行检测状态
    _initAutoTravelDetectionState();
    // 初始化偏好设置仓库
    _initPreferencesRepository();
    // 延迟到下一帧执行，避免在 build 过程中触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _loadUserPreferences();
      _checkAdminRole();
    });
  }

  // 初始化偏好设置仓库
  void _initPreferencesRepository() {
    if (Get.isRegistered<IUserPreferencesRepository>()) {
      _preferencesRepository = Get.find<IUserPreferencesRepository>();
    }
  }

  // 验证邮箱格式
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // 从数据库加载用户偏好设置
  Future<void> _loadUserPreferences() async {
    if (_preferencesRepository == null) {
      debugPrint('⚠️ UserPreferencesRepository 未注册，使用本地默认值');
      return;
    }

    setState(() => _isLoadingPreferences = true);

    try {
      final preferences = await _preferencesRepository!.getCurrentUserPreferences();
      if (mounted) {
        setState(() {
          _notifications = preferences.notificationsEnabled;
          _travelHistoryVisible = preferences.travelHistoryVisible;
          _autoTravelDetection = preferences.autoTravelDetectionEnabled;
          _profilePublic = preferences.profilePublic;
          _currency = preferences.currency;
          _temperatureUnit = preferences.temperatureUnit;
        });

        // 同步通知状态到 NotificationService
        if (Get.isRegistered<NotificationService>()) {
          final notificationService = Get.find<NotificationService>();
          await notificationService.setEnabled(preferences.notificationsEnabled);
        }

        // 同步自动旅行检测状态到 TravelDetectionService
        if (Get.isRegistered<TravelDetectionService>()) {
          final detectionService = Get.find<TravelDetectionService>();
          if (preferences.autoTravelDetectionEnabled && !detectionService.isRunning.value) {
            await detectionService.start();
          } else if (!preferences.autoTravelDetectionEnabled && detectionService.isRunning.value) {
            await detectionService.stop();
          }
        }

        debugPrint('✅ 用户偏好设置加载成功');
      }
    } catch (e) {
      debugPrint('❌ 加载用户偏好设置失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPreferences = false);
      }
    }
  }

  // 保存用户偏好设置到数据库
  Future<void> _saveUserPreferences() async {
    if (_preferencesRepository == null) {
      debugPrint('⚠️ UserPreferencesRepository 未注册，无法保存到数据库');
      return;
    }

    setState(() => _isSavingPreferences = true);

    try {
      await _preferencesRepository!.updatePreferences(
        notificationsEnabled: _notifications,
        travelHistoryVisible: _travelHistoryVisible,
        autoTravelDetectionEnabled: _autoTravelDetection,
        profilePublic: _profilePublic,
        currency: _currency,
        temperatureUnit: _temperatureUnit,
      );

      debugPrint('✅ 用户偏好设置保存成功');
    } catch (e) {
      debugPrint('❌ 保存用户偏好设置失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isSavingPreferences = false);
      }
    }
  }

  // 初始化通知状态
  void _initNotificationState() {
    if (Get.isRegistered<NotificationService>()) {
      final notificationService = Get.find<NotificationService>();
      _notifications = notificationService.isEnabled.value;
    }
  }

  // 初始化自动旅行检测状态 - 从后端加载，在 _loadUserPreferences 中处理
  void _initAutoTravelDetectionState() {
    // 状态已在 _loadUserPreferences 中从后端加载
    // 这里只是检查本地服务状态作为后备
    if (Get.isRegistered<TravelDetectionService>()) {
      final detectionService = Get.find<TravelDetectionService>();
      // 如果后端还没加载，先用本地状态
      if (!_isLoadingPreferences) {
        _autoTravelDetection = detectionService.isEnabled.value;
      }
    }
  }

  // 处理自动旅行检测开关变化 - 同时保存到后端
  Future<void> _handleAutoTravelDetectionToggle(bool value) async {
    if (!Get.isRegistered<TravelDetectionService>()) {
      debugPrint('⚠️ TravelDetectionService 未注册');
      return;
    }

    final detectionService = Get.find<TravelDetectionService>();

    if (value) {
      // 启动自动检测
      await detectionService.start();
      if (mounted) {
        setState(() => _autoTravelDetection = detectionService.isRunning.value);
      }
      log('🚀 自动旅行检测已启动');
    } else {
      // 停止自动检测
      await detectionService.stop();
      if (mounted) {
        setState(() => _autoTravelDetection = false);
      }
      log('⏹️ 自动旅行检测已停止');
    }

    // 保存到后端
    await _saveAutoTravelDetectionPreference(value);
  }

  // 保存自动旅行检测状态到后端
  Future<void> _saveAutoTravelDetectionPreference(bool enabled) async {
    if (_preferencesRepository == null) {
      debugPrint('⚠️ UserPreferencesRepository 未注册，无法保存到后端');
      return;
    }

    try {
      await _preferencesRepository!.updatePreferences(
        autoTravelDetectionEnabled: enabled,
      );
      debugPrint('✅ 自动旅行检测状态已保存到后端: $enabled');
    } catch (e) {
      debugPrint('❌ 保存自动旅行检测状态失败: $e');
    }
  }

  // 处理通知开关变化
  Future<void> _handleNotificationToggle(bool value) async {
    final notificationService = Get.isRegistered<NotificationService>() ? Get.find<NotificationService>() : null;

    if (value && notificationService != null) {
      // 用户想要开启通知，检查系统权限
      final hasPermission = await notificationService.checkPermissionStatus();

      if (!hasPermission) {
        // 没有系统权限，提示用户并引导到系统设置
        final shouldOpenSettings = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('需要通知权限'),
            content: const Text('请在系统设置中开启通知权限，以便接收重要消息提醒。'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('去设置'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          await notificationService.openNotificationSettings();
        }

        // 不改变开关状态，等用户从设置返回后重新操作
        return;
      }
    }

    setState(() => _notifications = value);

    // 同步到 NotificationService (本地)
    if (notificationService != null) {
      await notificationService.setEnabled(value);
    }

    // 保存到数据库
    await _saveUserPreferences();
  }

  // 处理旅行历史可见性变化
  Future<void> _handleTravelHistoryVisibleToggle(bool value) async {
    setState(() => _travelHistoryVisible = value);
    await _saveUserPreferences();
  }

  // 处理个人资料公开变化
  Future<void> _handleProfilePublicToggle(bool value) async {
    setState(() => _profilePublic = value);
    await _saveUserPreferences();
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
              _userManagementController = Get.find<UserManagementStateController>();
            } else {
              // 如果未注册，强制创建实例
              _userManagementController = Get.put(
                UserManagementStateController(Get.find<IUserManagementRepository>()),
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
    final skillController = Get.isRegistered<SkillStateController>() ? Get.find<SkillStateController>() : null;
    final interestController = Get.isRegistered<InterestStateController>() ? Get.find<InterestStateController>() : null;

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
    final l10n = AppLocalizations.of(context)!;

    if (!SupabaseConfig.isConfigured) {
      AppToast.error(
        'Supabase 未配置，请联系管理员',
        title: l10n.error,
      );
      return;
    }

    setState(() => _uploadingAvatar = true);

    try {
      final avatarUrl = await ImageUploadHelper.uploadAvatar(context);

      if (avatarUrl == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      // 更新本地头像显示
      setState(() {
        _newAvatarUrl = avatarUrl;
      });

      // 只更新头像到后端，不刷新整个用户数据（避免丢失 skills/interests）
      final profileController = Get.find<UserStateController>();
      await profileController.updateAvatarOnly(avatarUrl);

      AppToast.success(
        l10n.profileUpdatedSuccessfully,
        title: l10n.success,
      );
    } catch (e) {
      debugPrint('❌ 头像上传失败: $e');
      if (mounted) {
        AppToast.error(
          '头像上传失败: $e',
          title: l10n.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  @override
  Future<void> onRouteResume() async {
    await _loadUserProfile();
    await _checkAdminRole();
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
            isMobile ? 8 : 16,
            isMobile ? 16 : 24,
            100, // 底部留白给导航栏
          ),
          children: [
            // 顶部导航栏
            Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 8 : 16),
              child: Row(
                children: [
                  // 回退按钮
                  const AppBackButton(color: Color(0xFF1a1a1a)),
                  const SizedBox(width: 8),
                  // 页面标题
                  Expanded(
                    child: Text(
                      l10n.editProfile,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1a1a1a),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                  final profileController = Get.find<UserStateController>();

                  // 验证邮箱格式
                  final email = _emailController.text.trim();
                  if (email.isNotEmpty && !_isValidEmail(email)) {
                    AppToast.error(
                      l10n.invalidEmailFormat,
                      title: l10n.error,
                    );
                    return;
                  }

                  // 构建更新数据
                  final updates = <String, dynamic>{};

                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    updates['name'] = name;
                  }

                  if (email.isNotEmpty) {
                    updates['email'] = email;
                  }

                  final bio = _bioController.text.trim();
                  if (bio.isNotEmpty) {
                    updates['bio'] = bio;
                  }

                  if (_newAvatarUrl != null) {
                    updates['avatarUrl'] = _newAvatarUrl;
                  }

                  // 如果没有任何更新，直接返回
                  if (updates.isEmpty) {
                    Get.back();
                    return;
                  }

                  // 调用更新 API
                  final success = await profileController.updateUser(updates);

                  if (success) {
                    AppToast.success(
                      l10n.profileUpdatedSuccessfully,
                      title: l10n.saved,
                    );
                    Get.back();
                  }
                  // 失败的情况 updateUser 内部已经处理了错误提示
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
      String avatarUrl = _newAvatarUrl ?? user?.avatarUrl ?? '';

      // 处理空字符串的情况
      if (avatarUrl.isEmpty) {
        avatarUrl =
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.name ?? 'User')}&background=FF9800&color=fff&size=200';
      }

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
                Stack(
                  children: [
                    SafeCircleAvatar(
                      imageUrl: avatarUrl,
                      radius: isMobile ? 50 : 70,
                      backgroundColor: Colors.orange,
                    ),
                    if (_uploadingAvatar)
                      Positioned.fill(
                        child: Container(
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
                        ),
                      ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _uploadingAvatar ? null : _handleAvatarUpload,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _uploadingAvatar ? Colors.grey : AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _uploadingAvatar ? FontAwesomeIcons.hourglass : FontAwesomeIcons.camera,
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

            // 邮箱编辑
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: 'nomad@example.com',
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

  Widget _buildSkillsSection(bool isMobile, UserStateController profileController) {
    final l10n = AppLocalizations.of(Get.context!)!;

    // 安全地获取 controller，如果不存在则不显示加载状态
    final skillController = Get.isRegistered<SkillStateController>() ? Get.find<SkillStateController>() : null;

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
                  icon: Icon(FontAwesomeIcons.pen, color: AppColors.accent, size: 20),
                  label: Text(
                    '编辑',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  onPressed: isLoading ? null : () => _showSkillsBottomSheet(profileController),
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
                    deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 18),
                    onDeleted: isLoading ? null : () => profileController.removeSkill(skill.id),
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

  Widget _buildInterestsSection(bool isMobile, UserStateController profileController) {
    final l10n = AppLocalizations.of(Get.context!)!;

    // 安全地获取 controller，如果不存在则不显示加载状态
    final interestController = Get.isRegistered<InterestStateController>() ? Get.find<InterestStateController>() : null;

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
                  icon: const Icon(FontAwesomeIcons.pen, color: Color(0xFFBA68C8), size: 20),
                  label: const Text(
                    '编辑',
                    style: TextStyle(color: Color(0xFFBA68C8)),
                  ),
                  onPressed: isLoading ? null : () => _showInterestsBottomSheet(profileController),
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
                    deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 18),
                    onDeleted: isLoading ? null : () => profileController.removeInterest(interest.id),
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
          Row(
            children: [
              Text(
                l10n.preferences,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoadingPreferences || _isSavingPreferences) ...[
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
          SizedBox(height: isMobile ? 12 : 16),
          _buildLanguageTile(isMobile),
          Divider(color: AppColors.divider),
          _buildSwitchTile(
            l10n.notificationsPreference,
            l10n.receiveUpdatesAndAlerts,
            _notifications,
            _handleNotificationToggle,
          ),
          Divider(color: AppColors.divider),
          _buildSwitchTile(
            l10n.travelHistoryVisible,
            l10n.showTravelHistoryToOthers,
            _travelHistoryVisible,
            _handleTravelHistoryVisibleToggle,
          ),
          Divider(color: AppColors.divider),
          _buildSwitchTile(
            l10n.autoTravelDetection,
            l10n.autoTravelDetectionDescription,
            _autoTravelDetection,
            _handleAutoTravelDetectionToggle,
          ),
          Divider(color: AppColors.divider),
          _buildSwitchTile(
            l10n.publicProfile,
            l10n.makeProfileVisibleToEveryone,
            _profilePublic,
            _handleProfilePublicToggle,
          ),
          // TODO: 暂时隐藏货币和温度设置，后期启用
          // Divider(color: AppColors.divider),
          // _buildDropdownTile(
          //   l10n.currency,
          //   _currency,
          //   _currencies,
          //   _handleCurrencyChange,
          // ),
          // Divider(color: AppColors.divider),
          // _buildDropdownTile(
          //   l10n.temperature,
          //   _temperatureUnit,
          //   _temperatureUnits,
          //   _handleTemperatureUnitChange,
          // ),
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
            localeController.locale.value.languageCode == 'en' ? 'English' : '中文',
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
              FontAwesomeIcons.chevronDown,
              color: AppColors.iconSecondary,
            ),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text('English', style: TextStyle(color: AppColors.textPrimary)),
              ),
              DropdownMenuItem(
                value: 'zh',
                child: Text('中文', style: TextStyle(color: AppColors.textPrimary)),
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
            icon: FontAwesomeIcons.lock,
            title: l10n.changePassword,
            onTap: () => AppToast.info(l10n.changePasswordComingSoon),
          ),
          Divider(color: AppColors.divider),
          _buildActionTile(
            icon: FontAwesomeIcons.userSecret,
            title: l10n.privacySettings,
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          Divider(color: AppColors.divider),
          _buildActionTile(
            icon: FontAwesomeIcons.trash,
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
        FontAwesomeIcons.chevronRight,
        color: AppColors.iconLight,
      ),
      onTap: onTap,
    );
  }

  // 显示技能选择底部抽屉
  void _showSkillsBottomSheet(UserStateController profileController) {
    final SkillStateController skillController = Get.find<SkillStateController>();
    final currentUser = profileController.currentUser.value;

    if (currentUser == null) {
      AppToast.error('请先登录');
      return;
    }

    final currentSkills = currentUser.skills;
    log('📋 打开技能 Drawer: currentSkills = ${currentSkills.length} 个');
    for (var skill in currentSkills) {
      log('  - id=${skill.id}, name=${skill.name}, level=${skill.level}');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SkillsBottomSheet(
        skillController: skillController,
        currentSkills: currentSkills,
        onSave: (selectedSkills) async {
          try {
            var addedCount = 0;
            var removedCount = 0;

            // 用于乐观更新的新技能列表
            final updatedSkills = List<UserSkillInfo>.from(currentSkills);

            // 1. 找出需要删除的技能（原有但不在新选择中）
            final selectedIds = selectedSkills.map((s) => s.skillId).toSet();
            final originalIds = currentSkills.map((s) => s.id).toSet();
            final toRemove = originalIds.difference(selectedIds);

            // 2. 找出需要添加的技能（新选择但不在原有中）
            final toAdd = selectedIds.difference(originalIds);

            log('🔄 技能变更: 删除 ${toRemove.length} 个, 添加 ${toAdd.length} 个');

            // 3. 执行删除
            for (final skillId in toRemove) {
              final success = await skillController.removeUserSkill(
                currentUser.id,
                skillId,
              );
              if (success) {
                removedCount++;
                // 立即从本地列表移除
                updatedSkills.removeWhere((s) => s.id == skillId);
              }
            }

            // 4. 执行添加
            for (final skill in selectedSkills) {
              if (toAdd.contains(skill.skillId)) {
                final success = await skillController.addUserSkill(
                  currentUser.id,
                  AddUserSkillRequest(
                    skillId: skill.skillId,
                    proficiencyLevel: skill.proficiencyLevel,
                    yearsOfExperience: skill.yearsOfExperience,
                  ),
                );
                if (success) {
                  addedCount++;
                  // 立即添加到本地列表
                  // 从全局技能列表中查找技能信息
                  final skillInfo = skillController.skills.firstWhereOrNull(
                    (s) => s.id == skill.skillId,
                  );
                  if (skillInfo != null) {
                    updatedSkills.add(UserSkillInfo(
                      id: skill.skillId,
                      name: skillInfo.name,
                      level: skill.proficiencyLevel ?? 'intermediate',
                      icon: skillInfo.icon,
                    ));
                  }
                }
              }
            }

            // 5. 立即更新本地 currentUser 状态（乐观更新）
            if (addedCount > 0 || removedCount > 0) {
              profileController.currentUser.value = currentUser.copyWith(
                skills: updatedSkills,
              );

              final messages = <String>[];
              if (addedCount > 0) messages.add('添加 $addedCount 个');
              if (removedCount > 0) messages.add('移除 $removedCount 个');
              AppToast.success(
                messages.join(', '),
                title: '保存成功',
              );
            } else if (toRemove.isEmpty && toAdd.isEmpty) {
              // 没有变化，不需要提示
            } else {
              AppToast.error('保存失败，请稍后重试');
            }
          } catch (e) {
            log('❌ 保存技能失败: $e');
            AppToast.error('保存失败，请稍后重试');
          }
        },
      ),
    );
  }

  // 显示兴趣选择底部抽屉
  void _showInterestsBottomSheet(UserStateController profileController) {
    final InterestStateController interestController = Get.find<InterestStateController>();
    final currentUser = profileController.currentUser.value;

    if (currentUser == null) {
      AppToast.error('请先登录');
      return;
    }

    final currentInterests = currentUser.interests;
    log('📋 打开兴趣 Drawer: currentInterests = ${currentInterests.length} 个');
    for (var interest in currentInterests) {
      log('  - id=${interest.id}, name=${interest.name}');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InterestsBottomSheet(
        interestController: interestController,
        currentInterests: currentInterests,
        onSave: (selectedInterests) async {
          try {
            var addedCount = 0;
            var removedCount = 0;

            // 用于乐观更新的新兴趣列表
            final updatedInterests = List<UserInterestInfo>.from(currentInterests);

            // 1. 找出需要删除的兴趣（原有但不在新选择中）
            final selectedIds = selectedInterests.map((i) => i.interestId).toSet();
            final originalIds = currentInterests.map((i) => i.id).toSet();
            final toRemove = originalIds.difference(selectedIds);

            // 2. 找出需要添加的兴趣（新选择但不在原有中）
            final toAdd = selectedIds.difference(originalIds);

            log('🔄 兴趣变更: 删除 ${toRemove.length} 个, 添加 ${toAdd.length} 个');

            // 3. 执行删除
            for (final interestId in toRemove) {
              final success = await interestController.removeUserInterest(
                currentUser.id,
                interestId,
              );
              if (success) {
                removedCount++;
                // 立即从本地列表移除
                updatedInterests.removeWhere((i) => i.id == interestId);
              }
            }

            // 4. 执行添加
            for (final interest in selectedInterests) {
              if (toAdd.contains(interest.interestId)) {
                final success = await interestController.addUserInterest(
                  currentUser.id,
                  AddUserInterestRequest(
                    interestId: interest.interestId,
                    intensityLevel: interest.intensityLevel,
                  ),
                );
                if (success) {
                  addedCount++;
                  // 立即添加到本地列表
                  // 从全局兴趣列表中查找兴趣信息
                  final interestInfo = interestController.interests.firstWhereOrNull(
                    (i) => i.id == interest.interestId,
                  );
                  if (interestInfo != null) {
                    updatedInterests.add(UserInterestInfo(
                      id: interest.interestId,
                      name: interestInfo.name,
                      icon: interestInfo.icon,
                    ));
                  }
                }
              }
            }

            // 5. 立即更新本地 currentUser 状态（乐观更新）
            if (addedCount > 0 || removedCount > 0) {
              profileController.currentUser.value = currentUser.copyWith(
                interests: updatedInterests,
              );

              final messages = <String>[];
              if (addedCount > 0) messages.add('添加 $addedCount 个');
              if (removedCount > 0) messages.add('移除 $removedCount 个');
              AppToast.success(
                messages.join(', '),
                title: '保存成功',
              );
            } else if (toRemove.isEmpty && toAdd.isEmpty) {
              // 没有变化，不需要提示
            } else {
              AppToast.error('保存失败，请稍后重试');
            }
          } catch (e) {
            log('❌ 保存兴趣失败: $e');
            AppToast.error('保存失败，请稍后重试');
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.triangleExclamation, color: Colors.orange, size: 20),
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
                  icon: const Icon(FontAwesomeIcons.userShield, size: 18),
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
                  icon: const Icon(FontAwesomeIcons.user, size: 18),
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
                  icon: const Icon(FontAwesomeIcons.squareCheck, size: 18),
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
                  onPressed: () => _userManagementController!.loadUsers(refresh: true),
                  icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
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
              if (_userManagementController!.isLoading.value && _userManagementController!.users.isEmpty) {
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
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    _userManagementController!.loadUsers();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount:
                      _userManagementController!.users.length + (_userManagementController!.hasMoreData.value ? 1 : 0),
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
                    final isSelected = _userManagementController!.selectedUserIds.contains(user.id);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) {
                        _userManagementController!.toggleUserSelection(user.id);
                      },
                      title: Row(
                        children: [
                          SafeCircleAvatar(
                            imageUrl: user.avatarUrl,
                            radius: 16,
                            placeholder: Text(user.name.substring(0, 1).toUpperCase()),
                            errorWidget: Text(user.name.substring(0, 1).toUpperCase()),
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
          AppToast.error(error);
        }
      });
    } catch (e) {
      log('❌ 加载技能失败: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.error('无法加载技能列表: $e');
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
    log('🔍 预选技能开始: currentSkills = ${widget.currentSkills.length} 个');
    for (var userSkill in widget.currentSkills) {
      log('  - 查找技能: id=${userSkill.id}, name=${userSkill.name}');
      
      bool found = false;
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

        if (skill.id.isNotEmpty && !_selectedSkills.any((s) => s.skillId == skill.id)) {
          log('  ✅ 找到并添加技能: ${skill.name}');
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
          found = true;
          break; // 找到后立即退出内层循环
        }
      }

      if (!found) {
        log('  ❌ 未找到技能: ${userSkill.name}');
      }
    }
    log('🔍 预选完成: _selectedSkills = ${_selectedSkills.length} 个');
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
                          icon: const Icon(FontAwesomeIcons.xmark),
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
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
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
                child:
                    _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSkillsList(scrollController),
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
            final isSelected = _selectedSkills.any((s) => s.skillId == skill.id);
            if (isSelected) {
              log('🎯 技能 ${skill.name} (id=${skill.id}) 被标记为选中');
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

      final interests = List<Interest>.from(widget.interestController.interests);

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
          AppToast.error(error);
        }
      });
    } catch (e) {
      log('❌ 加载兴趣失败: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.error('无法加载兴趣列表: $e');
    }
  }

  List<InterestsByCategory> _groupInterestsByCategory(List<Interest> interests) {
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
    log('🔍 预选兴趣开始: currentInterests = ${widget.currentInterests.length} 个');
    for (var userInterest in widget.currentInterests) {
      log('  - 查找兴趣: id=${userInterest.id}, name=${userInterest.name}');
      
      bool found = false;
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

        if (interest.id.isNotEmpty && !_selectedInterests.any((i) => i.interestId == interest.id)) {
          log('  ✅ 找到并添加兴趣: ${interest.name}');
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
          found = true;
          break; // 找到后立即退出内层循环
        }
      }

      if (!found) {
        log('  ❌ 未找到兴趣: ${userInterest.name}');
      }
    }
    log('🔍 预选完成: _selectedInterests = ${_selectedInterests.length} 个');
  }

  void _toggleInterest(Interest interest) {
    final isSelected = _selectedInterests.any((i) => i.interestId == interest.id);

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
                          icon: const Icon(FontAwesomeIcons.xmark),
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
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
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
            final isSelected = _selectedInterests.any((i) => i.interestId == interest.id);
            if (isSelected) {
              log('🎯 兴趣 ${interest.name} (id=${interest.id}) 被标记为选中');
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
