import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  // 响应式数据
  final RxBool isLoading = true.obs;
  final RxString selectedTimeRange = '最近7天'.obs;
  final RxList<Map<String, dynamic>> kLineData = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> commodities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  // 初始化数据
  void initializeData() {
    isLoading.value = true;
    
    // 模拟网络延迟
    Future.delayed(const Duration(seconds: 1), () {
      _generateMockData();
      isLoading.value = false;
    });
  }

  // 生成模拟数据
  void _generateMockData() {
    // 生成K线数据
    _generateKLineData();
    
    // 生成商品列表数据
    _generateCommodityData();
  }

  // 生成K线图数据
  void _generateKLineData() {
    final random = math.Random();
    final List<Map<String, dynamic>> data = [];
    
    for (int i = 0; i < 30; i++) {
      final basePrice = 100 + random.nextDouble() * 50;
      data.add({
        'date': DateTime.now().subtract(Duration(days: 30 - i)),
        'open': basePrice,
        'high': basePrice + random.nextDouble() * 10,
        'low': basePrice - random.nextDouble() * 10,
        'close': basePrice + (random.nextDouble() - 0.5) * 8,
        'volume': random.nextInt(1000) + 500,
      });
    }
    
    kLineData.value = data;
  }

  // 生成商品数据
  void _generateCommodityData() {
    final random = math.Random();
    
    final List<Map<String, dynamic>> mockCommodities = [
      {
        'name': '电子产品',
        'icon': Icons.devices,
        'color': Colors.blue,
        'price': (1200 + random.nextDouble() * 300).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 10,
        'volume': '${(random.nextDouble() * 999 + 100).toInt()}K',
      },
      {
        'name': '服装纺织',
        'icon': Icons.checkroom,
        'color': Colors.green,
        'price': (800 + random.nextDouble() * 200).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 8,
        'volume': '${(random.nextDouble() * 799 + 200).toInt()}K',
      },
      {
        'name': '食品饮料',
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'price': (600 + random.nextDouble() * 150).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 6,
        'volume': '${(random.nextDouble() * 599 + 300).toInt()}K',
      },
      {
        'name': '化工原料',
        'icon': Icons.science,
        'color': Colors.red,
        'price': (2000 + random.nextDouble() * 500).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 12,
        'volume': '${(random.nextDouble() * 399 + 150).toInt()}K',
      },
      {
        'name': '机械设备',
        'icon': Icons.precision_manufacturing,
        'color': Colors.purple,
        'price': (5000 + random.nextDouble() * 1000).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 15,
        'volume': '${(random.nextDouble() * 299 + 100).toInt()}K',
      },
      {
        'name': '建筑材料',
        'icon': Icons.construction,
        'color': Colors.brown,
        'price': (300 + random.nextDouble() * 100).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 5,
        'volume': '${(random.nextDouble() * 199 + 250).toInt()}K',
      },
      {
        'name': '汽车配件',
        'icon': Icons.directions_car,
        'color': Colors.indigo,
        'price': (1500 + random.nextDouble() * 400).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 9,
        'volume': '${(random.nextDouble() * 349 + 180).toInt()}K',
      },
      {
        'name': '医疗器械',
        'icon': Icons.medical_services,
        'color': Colors.teal,
        'price': (3000 + random.nextDouble() * 800).toStringAsFixed(2),
        'change': (random.nextDouble() - 0.5) * 11,
        'volume': '${(random.nextDouble() * 149 + 80).toInt()}K',
      },
    ];
    
    commodities.value = mockCommodities;
  }

  // 刷新数据
  void refreshData() {
    isLoading.value = true;
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _generateMockData();
      isLoading.value = false;
      Get.snackbar(
        '刷新成功',
        '数据已更新到最新状态',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  // 更新时间范围
  void updateTimeRange(String newRange) {
    selectedTimeRange.value = newRange;
    refreshData();
  }

  // 获取总体统计信息
  Map<String, dynamic> getOverviewStats() {
    if (commodities.isEmpty) {
      return {
        'totalCategories': 0,
        'averageChange': 0.0,
        'totalVolume': '0',
      };
    }

    final totalCategories = commodities.length;
    final averageChange = commodities
        .map((c) => c['change'] as double)
        .reduce((a, b) => a + b) / commodities.length;
    
    // 计算总成交量（简化处理）
    var totalVolumeNum = 0;
    for (var commodity in commodities) {
      final volumeStr = commodity['volume'] as String;
      final numStr = volumeStr.replaceAll('K', '');
      totalVolumeNum += int.tryParse(numStr) ?? 0;
    }
    
    final totalVolume = '${(totalVolumeNum / 1000).toStringAsFixed(1)}M';

    return {
      'totalCategories': totalCategories,
      'averageChange': averageChange,
      'totalVolume': totalVolume,
    };
  }

  // 获取涨跌商品统计
  Map<String, int> getTrendStats() {
    int upCount = 0;
    int downCount = 0;
    int flatCount = 0;

    for (var commodity in commodities) {
      final change = commodity['change'] as double;
      if (change > 0.1) {
        upCount++;
      } else if (change < -0.1) {
        downCount++;
      } else {
        flatCount++;
      }
    }

    return {
      'up': upCount,
      'down': downCount,
      'flat': flatCount,
    };
  }

  // 根据分类筛选商品
  List<Map<String, dynamic>> getCommoditiesByCategory(String category) {
    if (category == '全部') {
      return commodities;
    }
    
    return commodities.where((commodity) {
      return commodity['name'].toString().contains(category);
    }).toList();
  }

  // 排序商品
  void sortCommodities(String sortBy) {
    final currentList = List<Map<String, dynamic>>.from(commodities);
    
    switch (sortBy) {
      case 'name':
        currentList.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'price_high':
        currentList.sort((a, b) {
          final priceA = double.tryParse(a['price']) ?? 0;
          final priceB = double.tryParse(b['price']) ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'price_low':
        currentList.sort((a, b) {
          final priceA = double.tryParse(a['price']) ?? 0;
          final priceB = double.tryParse(b['price']) ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'change_high':
        currentList.sort((a, b) => b['change'].compareTo(a['change']));
        break;
      case 'change_low':
        currentList.sort((a, b) => a['change'].compareTo(b['change']));
        break;
      default:
        break;
    }
    
    commodities.value = currentList;
  }
}