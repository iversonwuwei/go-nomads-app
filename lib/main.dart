import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/shopping_controller.dart';
import 'generated/app_localizations.dart';
import 'routes/app_routes.dart';
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
    // 设置 forceReset: true 可以清空并重新初始化数据库
    // 数据修复完成后已改为 false,避免每次启动都清空数据
    await dbInitializer.initializeDatabase(forceReset: false);
    print('✅ 数据库初始化成功');
  } catch (e) {
    print('❌ 数据库初始化失败: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化全局控制器
    Get.put(AuthController());
    Get.put(ShoppingController());
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
