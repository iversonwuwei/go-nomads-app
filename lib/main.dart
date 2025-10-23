import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/data_service_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/shopping_controller.dart';
import 'controllers/user_state_controller.dart';
import 'generated/app_localizations.dart';
import 'routes/app_routes.dart';
import 'services/app_init_service.dart';
import 'services/database/account_dao.dart';
import 'services/database_initializer.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('✅ 应用初始化');
  print('📍 使用 Geolocator 进行定位服务');

  // 初始化位置服务
  await Get.putAsync(() => LocationService().init());

  // 初始化 SQLite 数据库
  print('💾 初始化 SQLite 数据库...');
  try {
    final dbInitializer = DatabaseInitializer();
    // forceReset: false - 不删除数据库，保留登录状态和用户数据
    // forceReset: true - 仅在需要重置所有数据时使用
    await dbInitializer.initializeDatabase(forceReset: false);
    print('✅ 数据库初始化成功');
  } catch (e) {
    print('❌ 数据库初始化失败: $e');
  }

  // 🔥 关键修复：在main中初始化全局控制器，避免路由跳转时被清除
  print('🎯 初始化全局控制器...');
  Get.put(UserStateController(), permanent: true);
  Get.put(AccountDao(), permanent: true);
  print('✅ 全局控制器初始化完成');

  // 🔑 初始化应用，从 SQLite 恢复登录状态
  print('🔑 开始恢复登录状态...');
  await AppInitService().initialize();
  print('✅ 登录状态恢复完成');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化页面级控制器（全局控制器已在main()中初始化）
    Get.put(AuthController());
    Get.put(ShoppingController());
    Get.put(DataServiceController());
    final localeController = Get.put(LocaleController());

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro 的设计尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
              title: '行途 - Xingtu',

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
