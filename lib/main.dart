import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controllers/bottom_nav_controller.dart';
import 'controllers/locale_controller.dart';
import 'core/di/dependency_injection.dart';
import 'generated/app_localizations.dart';
import 'routes/app_routes.dart';
import 'services/app_init_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('✅ 应用初始化');
  print('📍 使用 Geolocator 进行定位服务');

  // 初始化位置服务
  await Get.putAsync(() => LocationService().init());

  // 🔥 关键修复：在main中初始化DDD依赖注入
  print('🎯 初始化DDD依赖注入...');
  await DependencyInjection.init();
  print('✅ DDD依赖注入初始化完成');

  // 初始化其他全局控制器
  print('🎯 初始化全局控制器...');
  Get.put(BottomNavController(), permanent: true);
  print('✅ 全局控制器初始化完成');

  // � 初始化通知服务
  print('📢 初始化通知服务...');
  try {
    await Get.putAsync(() => NotificationService().init(), permanent: true);
    print('✅ 通知服务初始化成功');
  } catch (e) {
    print('❌ 通知服务初始化失败: $e');
  }

  // Restore login state from persisted token
  print('🔑 开始恢复登录状态...');
  await AppInitService().initialize();
  print('✅ 登录状态恢复完成');

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
            ));
      },
    );
  }
}
