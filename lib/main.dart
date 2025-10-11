import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'config/amap_keys.dart';
import 'controllers/auth_controller.dart';
import 'controllers/shopping_controller.dart';
import 'routes/app_routes.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化高德地图（根据平台使用不同的 Key）
  try {
    await AmapCore.init(AmapKeys.platformKey);
    print('✅ 高德地图初始化成功');
    print('📱 平台: ${AmapKeys.currentPlatform}');
    print('🔑 Key: ${AmapKeys.platformKey.substring(0, 8)}...');

    if (!AmapKeys.isConfigured) {
      print('⚠️ 警告: ${AmapKeys.currentPlatform} 平台的 API Key 可能未正确配置');
      print('请检查 lib/config/amap_keys.dart');
    }
  } catch (e) {
    print('❌ 高德地图初始化失败: $e');
    print('请检查 API Key 配置');
  }
  
  // 初始化位置服务
  await Get.putAsync(() => LocationService().init());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化全局控制器
    Get.put(AuthController());
    Get.put(ShoppingController());

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro 的设计尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Flutter Getx Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.home,
          getPages: AppRoutes.getPages,
        );
      },
    );
  }
}
