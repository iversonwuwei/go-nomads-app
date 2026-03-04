import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // FocusNode 用于监听失焦自动保存
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  // 原始值，用于检测是否有改动
  String _originalName = '';
  String _originalEmail = '';
  String _originalBio = '';

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
    // 初始化失焦自动保存监听
    _initFocusListeners();
    // 延迟到下一帧执行，避免在 build 过程中触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _loadUserPreferences();
      _checkAdminRole();
    });
  }

  // 初始化失焦自动保存监听（与头像/技能即时保存行为一致）
  void _initFocusListeners() {
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) _autoSaveFieldIfChanged('name', _nameController.text.trim(), _originalName);
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _autoSaveFieldIfChanged('email', _emailController.text.trim(), _originalEmail);
    });
    _bioFocus.addListener(() {
      if (!_bioFocus.hasFocus) _autoSaveFieldIfChanged('bio', _bioController.text.trim(), _originalBio);
    });
  }

  // 字段失焦时自动保存（仅在值有变动时）
  Future<void> _autoSaveFieldIfChanged(String field, String newValue, String originalValue) async {
    if (newValue == originalValue) return;

    final l10n = AppLocalizations.of(context)!;

    // 邮箱格式校验
    if (field == 'email' && newValue.isNotEmpty && !_isValidEmail(newValue)) {
      AppToast.error(l10n.invalidEmailFormat, title: l10n.error);
      return;
    }

    // 用户名不能为空
    if (field == 'name' && newValue.isEmpty) return;

    final updates = <String, dynamic>{};
    if (field == 'name') updates['name'] = newValue;
    if (field == 'email') updates['email'] = newValue;
    if (field == 'bio') updates['bio'] = newValue;

    final profileController = Get.find<UserStateController>();
    final success = await profileController.updateUser(updates);

    if (success && mounted) {
      // 更新原始值，避免重复保存
      setState(() {
        if (field == 'name') _originalName = newValue;
        if (field == 'email') _originalEmail = newValue;
        if (field == 'bio') _originalBio = newValue;
      });
      AppToast.success(l10n.profileUpdatedSuccessfully, title: l10n.saved);
    }
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
        final l10n = AppLocalizations.of(context)!;
        // 没有系统权限，提示用户并引导到系统设置
        final shouldOpenSettings = await Get.dialog<bool>(
          AlertDialog(
            title: Text(l10n.profileNotificationPermissionTitle),
            content: Text(l10n.profileNotificationPermissionMessage),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(l10n.profileGoToSettings),
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
    _nameFocus.dispose();
    _emailFocus.dispose();
    _bioFocus.dispose();
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
        _originalName = user.name;
        _originalEmail = user.email ?? '';
        _originalBio = user.bio ?? '';
      });
    }

    // 继续监听后续的用户数据变化（仅在字段未聚焦时更新，避免覆盖正在编辑的内容）
    ever(profileController.currentUser, (user) {
      if (user != null && mounted) {
        setState(() {
          if (!_nameFocus.hasFocus) {
            _nameController.text = user.name;
            _originalName = user.name;
          }
          if (!_emailFocus.hasFocus) {
            _emailController.text = user.email ?? '';
            _originalEmail = user.email ?? '';
          }
          if (!_bioFocus.hasFocus) {
            _bioController.text = user.bio ?? '';
            _originalBio = user.bio ?? '';
          }
        });
      }
    });
  }

  // 处理头像上传
  Future<void> _handleAvatarUpload() async {
    final l10n = AppLocalizations.of(context)!;

    if (!SupabaseConfig.isConfigured) {
      AppToast.error(
        l10n.profileSupabaseNotConfigured,
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
          l10n.profileAvatarUploadFailed(e.toString()),
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
                  SizedBox(width: 8.w),
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

            SizedBox(height: 24.h),

            // 技能编辑
            _buildSkillsSection(isMobile, profileController),

            SizedBox(height: 24.h),

            // 兴趣爱好编辑
            _buildInterestsSection(isMobile, profileController),

            SizedBox(height: 24.h),

            // 偏好设置
            _buildPreferencesSection(isMobile),

            SizedBox(height: 24.h),

            // 账户操作
            _buildAccountActionsSection(isMobile),

            // 管理员权限管理区域（仅管理员可见）
            if (_isAdmin) ...[
              SizedBox(height: 24.h),
              _buildAdminManagementSection(isMobile),
            ],
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
          borderRadius: BorderRadius.circular(16.r),
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
                          child: Center(
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
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _uploadingAvatar ? Colors.grey : AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _uploadingAvatar ? FontAwesomeIcons.hourglass : FontAwesomeIcons.camera,
                        color: Colors.white,
                        size: 20.r,
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
              focusNode: _nameFocus,
              decoration: InputDecoration(
                labelText: l10n.name,
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: l10n.enterYourName,
                hintStyle: TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.containerLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),

            SizedBox(height: 16.h),

            // 邮箱编辑
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: l10n.email,
                hintStyle: TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.containerLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),

            SizedBox(height: 16.h),

            // Bio
            TextField(
              controller: _bioController,
              focusNode: _bioFocus,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.bio,
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: l10n.tellUsAboutYourself,
                hintStyle: TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.containerLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
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
          borderRadius: BorderRadius.circular(12.r),
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
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
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
                  icon: Icon(FontAwesomeIcons.pen, color: AppColors.accent, size: 20.r),
                  label: Text(
                    l10n.edit,
                    style: TextStyle(color: AppColors.accent),
                  ),
                  onPressed: isLoading ? null : () => _showSkillsBottomSheet(profileController),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (isLoading && skills.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (skills.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
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
                spacing: 8.w,
                runSpacing: 8.w,
                children: skills.map((skill) {
                  return Chip(
                    avatar: skill.hasIcon
                        ? Text(
                            skill.icon!,
                            style: TextStyle(fontSize: 16.sp),
                          )
                        : null,
                    label: Text(skill.name),
                    deleteIcon: Icon(FontAwesomeIcons.xmark, size: 18.r),
                    onDeleted: isLoading ? null : () => profileController.removeSkill(skill.id),
                    backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
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
          borderRadius: BorderRadius.circular(12.r),
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
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
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
                  icon: Icon(FontAwesomeIcons.pen, color: Color(0xFFBA68C8), size: 20.r),
                  label: Text(
                    l10n.edit,
                    style: TextStyle(color: Color(0xFFBA68C8)),
                  ),
                  onPressed: isLoading ? null : () => _showInterestsBottomSheet(profileController),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (isLoading && interests.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (interests.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
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
                spacing: 8.w,
                runSpacing: 8.w,
                children: interests.map((interest) {
                  return Chip(
                    avatar: interest.hasIcon
                        ? Text(
                            interest.icon!,
                            style: TextStyle(fontSize: 16.sp),
                          )
                        : null,
                    label: Text(interest.name),
                    deleteIcon: Icon(FontAwesomeIcons.xmark, size: 18.r),
                    onDeleted: isLoading ? null : () => profileController.removeInterest(interest.id),
                    backgroundColor: const Color(0xFFBA68C8).withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
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
        borderRadius: BorderRadius.circular(12.r),
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
                SizedBox(width: 8.w),
                SizedBox(
                  width: 16.w,
                  height: 16.h,
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
    final l10n = AppLocalizations.of(Get.context!)!;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        l10n.language,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
        ),
      ),
      subtitle: Obx(() => Text(
            localeController.uiLocale.value.languageCode == 'en'
                ? l10n.languageOptionEnglish
                : l10n.languageOptionChinese,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          )),
      trailing: Obx(() => DropdownButton<String>(
            value: localeController.uiLocale.value.languageCode,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            icon: Icon(
              FontAwesomeIcons.chevronDown,
              color: AppColors.iconSecondary,
            ),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(l10n.languageOptionEnglish, style: TextStyle(color: AppColors.textPrimary)),
              ),
              DropdownMenuItem(
                value: 'zh',
                child: Text(l10n.languageOptionChinese, style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
            onChanged: (languageCode) {
              if (languageCode != null) {
                localeController.changeLocaleUiOnly(languageCode);
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
          fontSize: 16.sp,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
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
        borderRadius: BorderRadius.circular(12.r),
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
            onTap: () => Get.toNamed(AppRoutes.changePassword),
          ),
          Divider(color: AppColors.divider),
          // TODO: 隐私设置暂时隐藏，后续功能完善后恢复
          // _buildActionTile(
          //   icon: FontAwesomeIcons.userSecret,
          //   title: l10n.privacySettings,
          //   onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          // ),
          // Divider(color: AppColors.divider),
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
                textConfirm: l10n.delete,
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
          fontSize: 16.sp,
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
    final l10n = AppLocalizations.of(context)!;
    final SkillStateController skillController = Get.find<SkillStateController>();
    final currentUser = profileController.currentUser.value;

    if (currentUser == null) {
      AppToast.error(l10n.pleaseLogin);
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
              if (addedCount > 0) messages.add(l10n.profileAddedCount(addedCount));
              if (removedCount > 0) messages.add(l10n.profileRemovedCount(removedCount));
              AppToast.success(
                messages.join(', '),
                title: l10n.saveSuccess,
              );
            } else if (toRemove.isEmpty && toAdd.isEmpty) {
              // 没有变化，不需要提示
            } else {
              AppToast.error(l10n.saveFailed);
            }
          } catch (e) {
            log('❌ 保存技能失败: $e');
            AppToast.error(l10n.saveFailed);
          }
        },
      ),
    );
  }

  // 显示兴趣选择底部抽屉
  void _showInterestsBottomSheet(UserStateController profileController) {
    final l10n = AppLocalizations.of(context)!;
    final InterestStateController interestController = Get.find<InterestStateController>();
    final currentUser = profileController.currentUser.value;

    if (currentUser == null) {
      AppToast.error(l10n.pleaseLogin);
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
              if (addedCount > 0) messages.add(l10n.profileAddedCount(addedCount));
              if (removedCount > 0) messages.add(l10n.profileRemovedCount(removedCount));
              AppToast.success(
                messages.join(', '),
                title: l10n.saveSuccess,
              );
            } else if (toRemove.isEmpty && toAdd.isEmpty) {
              // 没有变化，不需要提示
            } else {
              AppToast.error(l10n.saveFailed);
            }
          } catch (e) {
            log('❌ 保存兴趣失败: $e');
            AppToast.error(l10n.saveFailed);
          }
        },
      ),
    );
  }

  /// 构建管理员权限管理区域
  Widget _buildAdminManagementSection(bool isMobile) {
    if (_userManagementController == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(Get.context!)!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.profileRolesManagement,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                    l10n.profileSelectedUsers(_userManagementController!.selectedUserIds.length),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  )),
            ],
          ),
          SizedBox(height: 16.h),

          // 角色加载状态提示
          Obx(() {
            if (_userManagementController!.roles.isEmpty) {
              return Container(
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.triangleExclamation, color: Colors.orange, size: 20.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10n.profileRolesNotLoadedWarning,
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12.sp,
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
                  icon: Icon(FontAwesomeIcons.userShield, size: 18.r),
                  label: Text(l10n.profileSetAsAdmin),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _batchSetUser(),
                  icon: Icon(FontAwesomeIcons.user, size: 18.r),
                  label: Text(l10n.profileSetAsNormalUser),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _userManagementController!.toggleSelectAll(),
                  icon: Icon(FontAwesomeIcons.squareCheck, size: 18.r),
                  label: Text(l10n.profileToggleSelectAll),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _userManagementController!.loadUsers(refresh: true),
                  icon: Icon(FontAwesomeIcons.arrowsRotate, size: 18.r),
                  label: Text(l10n.refresh),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 用户列表
          Container(
            height: 400.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8.r),
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
                return Center(child: Text(l10n.profileNoUsers));
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
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0.w),
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
                          SizedBox(width: 12.w),
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
                                      fontSize: 12.sp,
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
                          SizedBox(width: 8.w),
                          Text(
                            l10n.profileJoinedAt(_formatDate(user.createdAt)),
                            style: TextStyle(
                              fontSize: 11.sp,
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
    final l10n = AppLocalizations.of(Get.context!)!;
    Color badgeColor;
    String roleText;

    switch (role.toLowerCase()) {
      case 'admin':
        badgeColor = Colors.red;
        roleText = l10n.profileRoleAdmin;
        break;
      case 'moderator':
        badgeColor = Colors.orange;
        roleText = l10n.profileRoleModerator;
        break;
      default:
        badgeColor = Colors.grey;
        roleText = l10n.profileRoleUser;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        roleText,
        style: TextStyle(
          fontSize: 11.sp,
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return l10n.today;
    } else if (difference.inDays < 30) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inDays < 365) {
      return l10n.monthsAgo((difference.inDays / 30).floor());
    } else {
      return l10n.yearsAgo((difference.inDays / 365).floor());
    }
  }

  Future<void> _batchSetAdmin() async {
    if (_userManagementController == null) return;

    if (_userManagementController!.selectedUserIds.isEmpty) {
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.warning(l10n.profileSelectUsersFirst);
      return;
    }

    final success = await _userManagementController!.batchSetAdmin();

    if (success) {
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.success(
        l10n.profileBatchSetAdminSuccess(_userManagementController!.selectedUserIds.length),
        title: l10n.success,
      );
    } else {
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.error(
        _userManagementController!.errorMessage.value.isNotEmpty
            ? _userManagementController!.errorMessage.value
            : l10n.profileBatchSetAdminFailed,
        title: l10n.error,
      );
    }
  }

  Future<void> _batchSetUser() async {
    if (_userManagementController == null) return;

    if (_userManagementController!.selectedUserIds.isEmpty) {
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.warning(l10n.profileSelectUsersFirst);
      return;
    }

    final success = await _userManagementController!.batchSetUser();

    if (success) {
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.success(
        l10n.profileBatchSetUserSuccess(_userManagementController!.selectedUserIds.length),
        title: l10n.success,
      );
    } else {
      final l10n = AppLocalizations.of(Get.context!)!;
      AppToast.error(
        _userManagementController!.errorMessage.value.isNotEmpty
            ? _userManagementController!.errorMessage.value
            : l10n.profileBatchSetUserFailed,
        title: l10n.error,
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
      final l10n = AppLocalizations.of(context)!;
      AppToast.error('${l10n.failedToLoadSkillsList}: $e');
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
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // 标题栏
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.selectSkills,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        if (_selectedSkills.isNotEmpty)
                          Text(
                            '${_selectedSkills.length} ${l10n.itemUnit}',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        SizedBox(width: 8.w),
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
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchSkillsHint,
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
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
                  height: 40.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      _buildCategoryChip(l10n.all, null),
                      SizedBox(width: 8.w),
                      ..._skillsByCategory.map((category) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _buildCategoryChip(
                            _getCategoryText(category.category),
                            category.category,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              SizedBox(height: 8.h),

              // 技能列表
              Expanded(
                child:
                    _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSkillsList(scrollController),
              ),

              // 底部按钮
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10.r,
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
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(
                        '${l10n.confirm} (${_selectedSkills.length})',
                        style: TextStyle(
                          fontSize: 16.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
    final l10n = AppLocalizations.of(context)!;
    final filteredSkills = _getFilteredSkills();

    if (filteredSkills.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? l10n.noSkills : l10n.noMatchingSkills,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
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
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'Programming':
        return l10n.skillCategoryProgramming;
      case 'Design':
        return l10n.skillCategoryDesign;
      case 'Marketing':
        return l10n.skillCategoryMarketing;
      case 'Languages':
        return l10n.skillCategoryLanguages;
      case 'Data':
        return l10n.skillCategoryData;
      case 'Management':
        return l10n.skillCategoryManagement;
      case 'Other':
        return l10n.skillCategoryOther;
      default:
        return category;
    }
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
      final l10n = AppLocalizations.of(context)!;
      AppToast.error('${l10n.failedToLoadInterestsList}: $e');
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
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // 标题栏
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.selectInterests,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        if (_selectedInterests.isNotEmpty)
                          Text(
                            '${_selectedInterests.length} ${l10n.itemUnit}',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        SizedBox(width: 8.w),
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
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchInterestsHint,
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
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
                  height: 40.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      _buildCategoryChip(l10n.all, null),
                      SizedBox(width: 8.w),
                      ..._interestsByCategory.map((category) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _buildCategoryChip(
                            _getCategoryText(category.category),
                            category.category,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              SizedBox(height: 8.h),

              // 兴趣列表
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildInterestsList(scrollController),
              ),

              // 底部按钮
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10.r,
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
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(
                        '${l10n.confirm} (${_selectedInterests.length})',
                        style: TextStyle(
                          fontSize: 16.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
    final l10n = AppLocalizations.of(context)!;
    final filteredInterests = _getFilteredInterests();

    if (filteredInterests.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? l10n.noInterests : l10n.noMatchingInterests,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
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
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'Sports':
        return l10n.interestCategorySports;
      case 'Arts':
        return l10n.interestCategoryArts;
      case 'Food':
        return l10n.interestCategoryFood;
      case 'Travel':
        return l10n.interestCategoryTravel;
      case 'Technology':
        return l10n.interestCategoryTechnology;
      case 'Reading':
        return l10n.interestCategoryReading;
      case 'Music':
        return l10n.interestCategoryMusic;
      case 'Social':
        return l10n.interestCategorySocial;
      default:
        return category;
    }
  }
}

// 技能选择底部抽屉组件
