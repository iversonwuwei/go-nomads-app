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
import 'generated/app_localizations.dart';
import 'routes/app_routes.dart';
import 'routes/route_refresh_observer.dart';
import 'services/app_init_service.dart';
import 'services/background_task_service.dart';
import 'services/image_upload_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/signalr_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('✅ 应用初始化');
  log('📍 使用 Geolocator 进行定位服务');

  // 初始化位置服务
  await Get.putAsync(() => LocationService().init());

  // 🔥 关键修复：在main中初始化DDD依赖注入
  log('🎯 初始化DDD依赖注入...');
  await DependencyInjection.init();
  log('✅ DDD依赖注入初始化完成');

  // 初始化其他全局控制器
  log('🎯 初始化全局控制器...');
  Get.put(BottomNavController(), permanent: true);
  Get.put(BackgroundTaskService(), permanent: true);
  log('✅ 全局控制器初始化完成');

  // 🔌 初始化 SignalR 实时通信
  log('🔌 初始化 SignalR 实时通信...');
  try {
    final signalrService = SignalRService();
    await signalrService.connect(ApiConfig.messageServiceBaseUrl);
    log('✅ SignalR 连接成功');
  } catch (e) {
    log('⚠️ SignalR 连接失败: $e (将使用轮询机制作为备选)');
  }

  // 📢 初始化通知服务
  log('📢 初始化通知服务...');
  try {
    await Get.putAsync(() => NotificationService().init(), permanent: true);
    log('✅ 通知服务初始化成功');
  } catch (e) {
    log('❌ 通知服务初始化失败: $e');
  }

  // 📸 初始化 Supabase Storage（图片上传）
  if (SupabaseConfig.isConfigured) {
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
  } else {
    log('⚠️ Supabase 未配置，跳过初始化');
  }

  // Restore login state from persisted token
  log('🔑 开始恢复登录状态...');
  await AppInitService().initialize();
  log('✅ 登录状态恢复完成');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 迁移 DataService 功能到 DDD controller
    // Get.put(DataServiceController());
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
