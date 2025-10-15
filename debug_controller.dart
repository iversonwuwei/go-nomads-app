import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'lib/controllers/data_service_controller.dart';
import 'lib/services/data/city_data_service.dart';
import 'lib/services/database_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('\n🔍 详细调试 DataServiceController 数据加载问题');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // 1. 初始化数据库
  print('步骤 1: 初始化数据库');
  final dbInitializer = DatabaseInitializer();
  await dbInitializer.initializeDatabase(forceReset: false);
  print('✅ 数据库初始化完成\n');

  // 2. 初始化 GetX
  runApp(const MaterialApp(home: Scaffold()));

  // 3. 模拟 main.dart 中的初始化
  print('步骤 2: 初始化 DataServiceController');
  final controller = Get.put(DataServiceController());
  print('✅ Controller 已创建');
  print('   hashCode: ${controller.hashCode}\n');

  // 4. 等待初始化完成
  print('步骤 3: 等待数据加载 (3秒)...');
  await Future.delayed(const Duration(seconds: 3));

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 Controller 状态检查');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print('1. isLoading: ${controller.isLoading.value}');
  print('2. dataItems.length: ${controller.dataItems.length}');
  print('3. meetups.length: ${controller.meetups.length}');
  print('4. filteredItems.length: ${controller.filteredItems.length}');
  print('5. upcomingMeetups.length: ${controller.upcomingMeetups.length}\n');

  if (controller.dataItems.isEmpty) {
    print('❌ 问题: dataItems 为空！');
    print('\n检查原因...\n');
    
    // 直接测试数据库查询
    print('测试: 直接从数据库查询城市');
    try {
      // 创建新的 CityDataService 实例来测试
      final cityService = CityDataService();
      final cities = await cityService.getAllCities();
      print('数据库查询结果: ${cities.length} 个城市');
      if (cities.isNotEmpty) {
        print('✅ 数据库有数据，但 Controller 没有加载到');
        print('\n可能原因:');
        print('1. onInit() 没有被调用');
        print('2. _loadCitiesFromDatabase() 执行失败');
        print('3. 数据转换过程出错\n');
      } else {
        print('❌ 数据库查询也是空的\n');
      }
    } catch (e) {
      print('❌ 数据库查询出错: $e\n');
    }
  } else {
    print('✅ dataItems 有数据\n');
    print('城市列表 (前3个):');
    for (var i = 0; i < (controller.dataItems.length > 3 ? 3 : controller.dataItems.length); i++) {
      final city = controller.dataItems[i];
      print('   ${i + 1}. ${city['city']}, ${city['country']}');
    }
  }

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔍 筛选器状态检查');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print('searchQuery: "${controller.searchQuery.value}"');
  print('selectedRegions: ${controller.selectedRegions}');
  print('selectedCountries: ${controller.selectedCountries}');
  print('selectedCities: ${controller.selectedCities}');
  print('selectedClimates: ${controller.selectedClimates}');
  print('minPrice: ${controller.minPrice.value}');
  print('maxPrice: ${controller.maxPrice.value}');
  print('minInternet: ${controller.minInternet.value}');
  print('minRating: ${controller.minRating.value}');
  print('maxAqi: ${controller.maxAqi.value}');
  print('hasActiveFilters: ${controller.hasActiveFilters}\n');

  if (controller.dataItems.isNotEmpty && controller.filteredItems.isEmpty) {
    print('❌ 问题: dataItems 有数据但 filteredItems 为空！');
    print('   这意味着筛选器过滤掉了所有数据\n');
    
    print('检查每个城市是否通过筛选...');
    for (var i = 0; i < controller.dataItems.length; i++) {
      final city = controller.dataItems[i];
      print('\n城市 ${i + 1}: ${city['city']}');
      
      // 模拟筛选逻辑
      bool passSearch = controller.searchQuery.value.isEmpty ||
          city['city'].toString().toLowerCase().contains(controller.searchQuery.value.toLowerCase()) ||
          city['country'].toString().toLowerCase().contains(controller.searchQuery.value.toLowerCase());
      print('   搜索筛选: ${passSearch ? "✅ 通过" : "❌ 未通过"}');
      
      bool passRegion = controller.selectedRegions.isEmpty ||
          controller.selectedRegions.contains(city['region']);
      print('   地区筛选: ${passRegion ? "✅ 通过" : "❌ 未通过 (需要: ${controller.selectedRegions})"}');
      
      bool passClimate = controller.selectedClimates.isEmpty ||
          controller.selectedClimates.contains(city['climate']);
      print('   气候筛选: ${passClimate ? "✅ 通过" : "❌ 未通过 (需要: ${controller.selectedClimates})"}');
      
      bool passPrice = (city['price'] as num) >= controller.minPrice.value &&
          (city['price'] as num) <= controller.maxPrice.value;
      print('   价格筛选: ${passPrice ? "✅ 通过" : "❌ 未通过 (价格: ${city['price']}, 范围: ${controller.minPrice.value}-${controller.maxPrice.value})"}');
      
      bool passInternet = (city['internet'] as num) >= controller.minInternet.value;
      print('   网速筛选: ${passInternet ? "✅ 通过" : "❌ 未通过 (网速: ${city['internet']}, 最低: ${controller.minInternet.value})"}');
      
      bool passRating = (city['overall'] as num) >= controller.minRating.value;
      print('   评分筛选: ${passRating ? "✅ 通过" : "❌ 未通过 (评分: ${city['overall']}, 最低: ${controller.minRating.value})"}');
      
      bool passAqi = (city['aqi'] as num) <= controller.maxAqi.value;
      print('   AQI筛选: ${passAqi ? "✅ 通过" : "❌ 未通过 (AQI: ${city['aqi']}, 最大: ${controller.maxAqi.value})"}');
      
      bool passAll = passSearch && passRegion && passClimate && passPrice && passInternet && passRating && passAqi;
      print('   总结: ${passAll ? "✅ 通过所有筛选" : "❌ 被筛选掉"}');
    }
  }

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🎯 模拟页面访问');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print('测试: 使用 Get.find() 获取 Controller');
  try {
    final pageController = Get.find<DataServiceController>();
    print('✅ 成功获取 Controller');
    print('   hashCode: ${pageController.hashCode}');
    print('   是同一个实例: ${controller.hashCode == pageController.hashCode}');
    print('   dataItems.length: ${pageController.dataItems.length}');
    print('   filteredItems.length: ${pageController.filteredItems.length}\n');
  } catch (e) {
    print('❌ 获取 Controller 失败: $e\n');
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📋 诊断结果');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  if (controller.dataItems.isEmpty) {
    print('❌ 主要问题: dataItems 为空');
    print('   需要检查:');
    print('   1. Controller 的 onInit() 是否被调用');
    print('   2. _loadCitiesFromDatabase() 是否执行成功');
    print('   3. 数据库连接是否正常\n');
  } else if (controller.filteredItems.isEmpty) {
    print('❌ 主要问题: 筛选器过滤掉了所有数据');
    print('   需要检查:');
    print('   1. 筛选条件是否过于严格');
    print('   2. 数据格式是否匹配筛选逻辑\n');
  } else {
    print('✅ 数据加载正常！');
    print('   dataItems: ${controller.dataItems.length} 个城市');
    print('   filteredItems: ${controller.filteredItems.length} 个城市');
    print('   页面应该能正常显示数据\n');
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}
