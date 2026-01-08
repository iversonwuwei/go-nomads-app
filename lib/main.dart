import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'config/api_config.dart';
import 'config/supabase_config.dart';
import 'controllers/bottom_nav_controller.dart';
import 'controllers/locale_controller.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/deep_link_handler.dart';
import 'generated/app_localizations.dart';
import 'routes/app_routes.dart';
import 'routes/route_refresh_observer.dart';
import 'services/amap_native_location_service.dart';
import 'services/app_init_service.dart';
import 'services/background_task_service.dart';
import 'services/image_upload_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/signalr_service.dart';
import 'services/social_sdk_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('✅ 应用初始化');

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

  // 恢复登录状态 (必须在 UI 前完成)
  log('🔑 开始恢复登录状态...');
  await AppInitService().initialize();
  log('✅ 登录状态恢复完成');

  // 先启动 UI，再在后台完成其他初始化
  runApp(const MyApp());

  // ==================== 第二阶段：后台初始化（非阻塞） ====================
  // 这些服务可以在 UI 显示后再初始化，不影响用户体验
  _initializeBackgroundServices();
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

              initialRoute: AppRoutes.home,
              getPages: AppRoutes.getPages,
              navigatorObservers: [appRouteObserver],
            ));
      },
    );
  }
}
