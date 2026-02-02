import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'config/api_config.dart';
import 'config/supabase_config.dart';
import 'controllers/locale_controller.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/deep_link_handler.dart';
import 'features/auth/presentation/controllers/auth_state_controller.dart';
import 'features/chat/infrastructure/services/tencent_im/tencent_im.dart';
import 'generated/app_localizations.dart';
import 'layouts/bottom_nav/bottom_nav.dart';
import 'routes/app_routes.dart';
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

/// 全局初始化完成状态
final _initCompleter = ValueNotifier<bool>(false);

/// 全局变量：标记是否已从 AppWrapper 导航到目标页面
var _hasNavigatedFromAppWrapper = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('✅ 应用初始化');

  // 重置导航状态（热重启时需要）
  _hasNavigatedFromAppWrapper = false;
  _initCompleter.value = false;

  // 立即启动 UI（显示启动页）
  runApp(const MyApp());

  // 在后台完成初始化
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

  // 🔌 SignalR 实时通信 - 后台初始化
  Future.microtask(() async {
    log('🔌 初始化 SignalR 实时通信...');
    try {
      final signalrService = SignalRService();
      await signalrService.connect(ApiConfig.messageServiceBaseUrl);
      log('✅ SignalR 连接成功');
    } catch (e) {
      log('⚠️ SignalR 连接失败: $e (将使用轮询机制作为备选)');
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
              locale: localeController.locale.value,
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
              ),

              // 使用 AppWrapper 来控制启动页和主内容的切换
              home: const AppWrapper(),
              getPages: AppRoutes.getPages,
              navigatorObservers: [appRouteObserver, keyboardDismissObserver],
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

    // 监听初始化完成
    _initCompleter.addListener(_onInitComplete);

    // 如果初始化已经完成，立即导航
    if (_initCompleter.value) {
      log('📱 初始化已完成，立即导航');
      _navigateToTargetPage();
    }

    // 添加超时保护：5秒后如果还没导航，强制导航
    Future.delayed(const Duration(seconds: 5), () {
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

  void _onInitComplete() {
    log('📱 _onInitComplete 被调用 - value=${_initCompleter.value}, hasNavigated=$_hasNavigatedFromAppWrapper');
    if (_initCompleter.value && !_hasNavigatedFromAppWrapper && mounted) {
      _navigateToTargetPage();
    }
  }

  void _navigateToTargetPage() {
    if (_hasNavigatedFromAppWrapper || !mounted) {
      log('📱 _navigateToTargetPage 跳过: hasNavigated=$_hasNavigatedFromAppWrapper, mounted=$mounted');
      return;
    }
    _hasNavigatedFromAppWrapper = true;
    log('📱 _navigateToTargetPage 执行导航...');

    // 延迟一帧后导航，确保 UI 已完全构建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        log('📱 postFrameCallback: widget 已销毁');
        return;
      }

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
    });
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
