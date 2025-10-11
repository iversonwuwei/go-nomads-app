import 'dart:io';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/shopping_controller.dart';
import 'routes/app_routes.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化高德地图（根据平台使用不同的 Key）
  if (Platform.isIOS) {
    // iOS 平台 Key
    await AmapCore.init('6b053c71911726f46271e4b54124d35f');
  } else if (Platform.isAndroid) {
    // Android 平台 Key
    await AmapCore.init('6b053c71911726f46271e4b54124d35f');
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
