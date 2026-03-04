import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'config/api_config.dart';
import 'config/supabase_config.dart';
import 'controllers/locale_controller.dart';
import 'core/di/dependency_injection.dart';
import 'core/lifecycle/page_lifecycle_observer.dart';
import 'core/utils/deep_link_handler.dart';
import 'features/auth/presentation/controllers/auth_state_controller.dart';
import 'features/chat/infrastructure/services/tencent_im/tencent_im.dart';
import 'features/user/domain/repositories/i_user_preferences_repository.dart';
import 'generated/app_localizations.dart';
import 'layouts/bottom_nav/bottom_nav.dart';
import 'routes/app_routes.dart';
import 'routes/bottom_nav_route_observer.dart';
import 'routes/keyboard_dismiss_observer.dart';
import 'routes/route_refresh_observer.dart';
import 'services/amap_native_location_service.dart';
import 'services/app_init_service.dart';
import 'services/background_task_service.dart';
import 'services/image_upload_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/signalr_service.dart';
import 'services/social_sdk_service.dart';
import 'widgets/dialogs/first_launch_privacy_dialog.dart';

/// 全局初始化完成状态
final _initCompleter = ValueNotifier<bool>(false);

/// 全局变量：标记是否已从 AppWrapper 导航到目标页面
var _hasNavigatedFromAppWrapper = false;

/// 全局变量：标记首次启动隐私政策是否需要展示
var _needsFirstLaunchPrivacyConsent = false;

/// 全局变量：标记首次启动隐私政策已通过（用于控制SDK初始化时机）
var _privacyConsentCompleted = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('✅ 应用初始化');

  // 重置导航状态（热重启时需要）
  _hasNavigatedFromAppWrapper = false;
  _initCompleter.value = false;
  _privacyConsentCompleted = false;

  // 工信部合规：在初始化任何SDK之前，先检查用户是否已同意隐私政策
  final hasConsented = await FirstLaunchPrivacyDialog.hasConsented();
  _needsFirstLaunchPrivacyConsent = !hasConsented;

  if (_needsFirstLaunchPrivacyConsent) {
    log('📋 首次启动，需要展示隐私政策同意弹窗（在SDK初始化之前）');
    // 先启动UI显示启动页，等待用户同意后再初始化SDK
    runApp(const MyApp());
    // 不在这里执行 _performInitialization()，而是等用户同意后由 AppWrapper 触发
  } else {
    log('✅ 用户已同意隐私政策，正常初始化');
    _privacyConsentCompleted = true;

    // 立即启动 UI（显示启动页）
    runApp(const MyApp());

    // 在后台完成初始化
    await _performInitialization();
  }
}

/// 当用户在首次启动隐私弹窗中同意后，执行完整初始化
Future<void> performInitializationAfterConsent() async {
  if (_privacyConsentCompleted) return;
  _privacyConsentCompleted = true;
  log('✅ 用户同意隐私政策，开始完整初始化...');
  await _performInitialization();
}

/// 执行应用初始化
Future<void> _performInitialization() async {
  try {
    // ==================== 第一阶段：关键初始化（阻塞） ====================
    // 只保留必须在 UI 渲染前完成的初始化

    // 🔥 关键：初始化DDD依赖注入
    log('🎯 初始化DDD依赖注入...');
    await DependencyInjection.init();
    log('✅ DDD依赖注入初始化完成');

    // 初始化全局控制器
    log('🎯 初始化全局控制器...');
    Get.put(BottomNavController(), permanent: true);
    Get.put(BackgroundTaskService(), permanent: true);
    log('✅ 全局控制器初始化完成');

    // 🔥 提前注册腾讯云IM服务（在登录状态恢复之前）
    log('💬 提前注册腾讯云IM服务...');
    final imService = Get.put(TencentIMService(), permanent: true);
    await imService.initSDK();
    log('✅ 腾讯云IM服务已注册');

    // 恢复登录状态 (必须在 UI 前完成)
    log('🔑 开始恢复登录状态...');
    await AppInitService().initialize();
    log('✅ 登录状态恢复完成');

    // 标记初始化完成
    log('🎉 标记初始化完成，准备导航...');
    _initCompleter.value = true;

    // ==================== 第二阶段：后台初始化（非阻塞） ====================
    // 这些服务可以在 UI 显示后再初始化，不影响用户体验
    _initializeBackgroundServices();
  } catch (e, stack) {
    log('❌ 初始化失败: $e');
    log('Stack: $stack');
    // 即使初始化失败也要允许进入应用
    _initCompleter.value = true;
  }
}

/// 后台初始化非关键服务
Future<void> _initializeBackgroundServices() async {
  log('🔄 开始后台初始化非关键服务...');

  // 高德原生定位服务 - 后台初始化（优先于通用位置服务）
  Get.putAsync(() => AmapNativeLocationService().init()).then((_) {
    log('✅ 高德原生定位服务初始化完成');
  }).catchError((e) {
    log('⚠️ 高德原生定位服务初始化失败: $e');
  });

  // 位置服务 - 后台初始化（作为备用）
  Get.putAsync(() => LocationService().init()).then((_) {
    log('✅ 位置服务初始化完成');
  }).catchError((e) {
    log('⚠️ 位置服务初始化失败: $e');
  });

  // 🔌 SignalR 实时通信 - 后台初始化（带重试）
  Future.microtask(() async {
    log('🔌 初始化 SignalR 实时通信...');
    final signalrService = SignalRService();
    const maxRetries = 3;
    for (var i = 0; i < maxRetries; i++) {
      try {
        await signalrService.connect(ApiConfig.messageServiceBaseUrl);
        log('✅ SignalR 连接成功');
        break;
      } catch (e) {
        log('⚠️ SignalR 连接失败 (${i + 1}/$maxRetries): $e');
        if (i < maxRetries - 1) {
          // 等待后重试（递增延迟: 2s, 4s）
          await Future.delayed(Duration(seconds: 2 * (i + 1)));
        } else {
          log('⚠️ SignalR 所有重试均失败，将在需要时重连');
        }
      }
    }
  });

  // 📢 通知服务 - 后台初始化
  Future.microtask(() async {
    log('📢 初始化通知服务...');
    try {
      await Get.putAsync(() => NotificationService().init(), permanent: true);
      log('✅ 通知服务初始化成功');
    } catch (e) {
      log('❌ 通知服务初始化失败: $e');
    }
  });

  // 📸 Supabase Storage - 后台初始化
  if (SupabaseConfig.isConfigured) {
    Future.microtask(() async {
      log('📸 初始化 Supabase Storage...');
      try {
        await ImageUploadService().initialize(
          url: SupabaseConfig.url,
          anonKey: SupabaseConfig.anonKey,
        );
        log('✅ Supabase Storage 初始化成功');
      } catch (e) {
        log('❌ Supabase Storage 初始化失败: $e');
      }
    });
  } else {
    log('⚠️ Supabase 未配置，跳过初始化');
  }

  // 🔗 Deep Link 处理器 - 后台初始化
  Future.microtask(() async {
    log('🔗 初始化 Deep Link 处理器...');
    try {
      await DeepLinkHandler.init();
      log('✅ Deep Link 处理器初始化成功');
    } catch (e) {
      log('❌ Deep Link 处理器初始化失败: $e');
    }
  });

  // 📱 社交 SDK - 后台初始化
  Future.microtask(() async {
    log('📱 初始化社交 SDK...');
    try {
      await SocialSdkService.init();
      log('✅ 社交 SDK 初始化完成');
    } catch (e) {
      log('❌ 社交 SDK 初始化失败: $e');
    }
  });

  // 注意：TencentIMService 已在第一阶段初始化
  // IM 登录会在 UserStateController 监听到认证状态变化时自动执行

  log('🔄 后台初始化任务已派发');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.put(LocaleController());

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro 的设计尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
              title: '行途 - GO-NOMADS',

              // 国际化配置
              locale: localeController.uiLocale.value,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: localeController.supportedLocales,

              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,

                // ── 全局统一控件高度 ──
                // 按钮和输入框统一为 48.h 高度
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(0, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, 48.h),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),

              // 使用 AppWrapper 来控制启动页和主内容的切换
              home: const AppWrapper(),
              getPages: AppRoutes.getPages,
              navigatorObservers: [
                appRouteObserver,
                keyboardDismissObserver,
                BottomNavRouteObserver(),
                PageLifecycleObserver(),
              ],
            ));
      },
    );
  }
}

/// 应用包装器 - 处理启动页到主页的过渡
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();

    // 如果已经导航过，不再重复导航
    if (_hasNavigatedFromAppWrapper) {
      log('📱 AppWrapper initState - 已经导航过，跳过');
      return;
    }

    log('📱 AppWrapper initState - _initCompleter.value = ${_initCompleter.value}');

    // 如果需要首次启动隐私政策弹窗，等 UI 渲染后显示
    if (_needsFirstLaunchPrivacyConsent) {
      log('📋 等待 UI 渲染后显示首次启动隐私政策弹窗');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstLaunchPrivacyDialog();
      });
      return;
    }

    // 监听初始化完成
    _initCompleter.addListener(_onInitComplete);

    // 如果初始化已经完成，立即导航
    if (_initCompleter.value) {
      log('📱 初始化已完成，立即导航');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToTargetPage();
      });
    }

    // 添加超时保护：3秒后如果还没导航，强制导航
    Future.delayed(const Duration(seconds: 3), () {
      if (!_hasNavigatedFromAppWrapper && mounted) {
        log('⏰ 超时保护触发，强制导航');
        _navigateToTargetPage();
      }
    });
  }

  @override
  void dispose() {
    _initCompleter.removeListener(_onInitComplete);
    super.dispose();
  }

  /// 显示首次启动隐私政策弹窗（工信部合规要求）
  Future<void> _showFirstLaunchPrivacyDialog() async {
    if (!mounted) return;

    final consented = await FirstLaunchPrivacyDialog.show(context);

    if (consented) {
      // 用户同意 → 开始完整初始化
      _needsFirstLaunchPrivacyConsent = false;

      // 开始监听初始化完成
      _initCompleter.addListener(_onInitComplete);

      // 执行完整的SDK初始化
      await performInitializationAfterConsent();

      // 添加超时保护
      Future.delayed(const Duration(seconds: 3), () {
        if (!_hasNavigatedFromAppWrapper && mounted) {
          log('⏰ 超时保护触发，强制导航');
          _navigateToTargetPage();
        }
      });
    }
    // 如果不同意，FirstLaunchPrivacyDialog 内部会退出应用
  }

  void _onInitComplete() {
    log('📱 _onInitComplete 被调用 - value=${_initCompleter.value}, hasNavigated=$_hasNavigatedFromAppWrapper');
    if (_initCompleter.value && !_hasNavigatedFromAppWrapper && mounted) {
      // 使用 addPostFrameCallback 确保在当前帧结束后执行
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToTargetPage();
      });
    }
  }

  void _navigateToTargetPage() {
    if (_hasNavigatedFromAppWrapper || !mounted) {
      log('📱 _navigateToTargetPage 跳过: hasNavigated=$_hasNavigatedFromAppWrapper, mounted=$mounted');
      return;
    }
    _hasNavigatedFromAppWrapper = true;
    log('📱 _navigateToTargetPage 执行导航...');

    // 检查认证状态来决定目标页面
    String targetRoute;
    try {
      final authController = Get.find<AuthStateController>();
      log('📱 AuthStateController found: isAuthenticated=${authController.isAuthenticated.value}');
      if (authController.isAuthenticated.value &&
          authController.currentToken.value != null &&
          !authController.currentToken.value!.isExpired) {
        targetRoute = AppRoutes.home;
        log('🚀 已认证，导航到首页...');
      } else {
        targetRoute = AppRoutes.login;
        log('🚀 未认证，导航到登录页...');
      }
    } catch (e) {
      targetRoute = AppRoutes.login;
      log('🚀 认证状态检查失败($e)，导航到登录页...');
    }

    log('📱 执行 Get.offNamed($targetRoute)');
    Get.offNamed(targetRoute);

    // 如果是已认证用户，静默同步隐私政策状态到后端（不再弹窗）
    if (targetRoute == AppRoutes.home) {
      _syncPrivacyConsentToBackend();
    }
  }

  /// 双向同步隐私政策同意状态（后端为 source of truth）
  ///
  /// - 后端未同意 + 本地已同意 → 清除本地缓存，重新弹窗
  /// - 后端已同意 + 本地未同意 → 补写本地缓存（换设备场景）
  /// - 本地已同意 + 后端未记录 → 静默推送到后端
  Future<void> _syncPrivacyConsentToBackend() async {
    try {
      final prefsRepo = Get.find<IUserPreferencesRepository>();
      final preferences = await prefsRepo.getCurrentUserPreferences();

      if (!preferences.privacyPolicyAccepted) {
        final localConsented = await FirstLaunchPrivacyDialog.hasConsented();

        if (localConsented) {
          // 后端标记为未同意（可能是管理员重置了），清除本地缓存并重新弹窗
          log('⚠️ 后端隐私政策状态为未同意，需要重新确认');
          await FirstLaunchPrivacyDialog.clearConsent();

          if (mounted) {
            final consented = await FirstLaunchPrivacyDialog.show(context);
            if (consented) {
              await prefsRepo.acceptPrivacyPolicy();
              log('✅ 用户重新同意隐私政策，已同步到后端');
            }
            // 不同意则 dialog 内部会退出应用
          }
        } else {
          // 本地也没同意过（不应出现在这里，但防御性处理）
          log('🔄 静默同步隐私政策同意状态到后端...');
          await prefsRepo.acceptPrivacyPolicy();
          log('✅ 隐私政策同意状态已同步到后端');
        }
      } else {
        // 后端已同意，确保本地也有记录（换设备场景）
        final localConsented = await FirstLaunchPrivacyDialog.hasConsented();
        if (!localConsented) {
          await FirstLaunchPrivacyDialog.markConsented();
          log('✅ 后端已同意，补写本地缓存');
        }
      }
    } catch (e) {
      log('⚠️ 同步隐私政策状态失败（不影响使用）: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashLoadingScreen();
  }
}

/// 简化的启动加载页面 - 仅显示背景色，文字由原生层显示
class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 青蓝色背景，与原生启动页一致
        // 不显示文字，避免与原生启动页文字大小不一致的问题
        color: const Color(0xFF0891B2),
      ),
    );
  }
}
