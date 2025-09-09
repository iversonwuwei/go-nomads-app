import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/api_interface_model.dart';
import '../models/product_model.dart';

class ShoppingController extends GetxController {
  // 轮播图数据
  var bannerList = <BannerModel>[].obs;
  var currentBannerIndex = 0.obs;

  // API接口数据
  var hotApiInterfaces = <ApiInterfaceModel>[].obs;
  var selectedApiInterfaces = <ApiInterfaceModel>[].obs;

  // 热门商品数据 (保留兼容性)
  var hotProducts = <ProductModel>[].obs;
  var selectedProducts = <ProductModel>[].obs;

  // 加载状态
  var isLoading = false.obs;

  // 底部导航索引
  var currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    isLoading.value = true;

    // 模拟加载轮播图数据
    bannerList.value = [
      BannerModel(
        id: '1',
        title: 'API数据交易平台',
        imageUrl: 'https://picsum.photos/400/200?random=1',
      ),
      BannerModel(
        id: '2',
        title: '实时数据接口',
        imageUrl: 'https://picsum.photos/400/200?random=2',
      ),
      BannerModel(
        id: '3',
        title: '高质量API服务',
        imageUrl: 'https://picsum.photos/400/200?random=3',
      ),
    ];

    // 模拟加载热门API接口数据
    hotApiInterfaces.value = [
      ApiInterfaceModel(
        id: 'api_1',
        name: '天气预报API',
        description: '实时天气数据查询接口，支持全球城市',
        category: '生活服务',
        price: 0.01,
        originalPrice: 0.02,
        endpoint: '/weather/current',
        methods: ['GET'],
        callsPerMonth: 10000,
        responseTime: 150.0,
        reliability: 99.9,
        isHot: true,
        isFree: false,
        tileColor: const Color(0xFF2196F3),
        icon: Icons.wb_sunny,
      ),
      ApiInterfaceModel(
        id: 'api_2',
        name: '身份证验证API',
        description: '实名身份证信息验证接口',
        category: '数据验证',
        price: 0.5,
        originalPrice: 0.8,
        endpoint: '/identity/verify',
        methods: ['POST'],
        callsPerMonth: 5000,
        responseTime: 200.0,
        reliability: 99.8,
        isHot: true,
        isFree: false,
        tileColor: const Color(0xFF4CAF50),
        icon: Icons.verified_user,
      ),
      ApiInterfaceModel(
        id: 'api_3',
        name: '股票行情API',
        description: '实时股票价格和行情数据',
        category: '金融数据',
        price: 0.05,
        originalPrice: 0.1,
        endpoint: '/stock/realtime',
        methods: ['GET', 'POST'],
        callsPerMonth: 50000,
        responseTime: 100.0,
        reliability: 99.9,
        isHot: true,
        isFree: false,
        tileColor: const Color(0xFFFF5722),
        icon: Icons.trending_up,
      ),
      ApiInterfaceModel(
        id: 'api_4',
        name: '快递查询API',
        description: '支持各大快递公司的物流查询',
        category: '物流服务',
        price: 0.02,
        originalPrice: 0.03,
        endpoint: '/express/track',
        methods: ['GET'],
        callsPerMonth: 20000,
        responseTime: 300.0,
        reliability: 99.5,
        isHot: true,
        isFree: false,
        tileColor: const Color(0xFF9C27B0),
        icon: Icons.local_shipping,
      ),
    ];

    // 模拟加载精选API接口数据
    selectedApiInterfaces.value = [
      ApiInterfaceModel(
        id: 'api_5',
        name: '手机号归属地API',
        description: '查询手机号码归属地信息',
        category: '通信服务',
        price: 0.01,
        endpoint: '/phone/location',
        methods: ['GET'],
        callsPerMonth: 15000,
        responseTime: 120.0,
        reliability: 99.7,
        isFree: false,
        tileColor: const Color(0xFF607D8B),
        icon: Icons.phone_android,
      ),
      ApiInterfaceModel(
        id: 'api_6',
        name: '汇率转换API',
        description: '实时汇率查询和货币转换',
        category: '金融数据',
        price: 0.0,
        endpoint: '/currency/convert',
        methods: ['GET'],
        callsPerMonth: 30000,
        responseTime: 80.0,
        reliability: 99.9,
        isFree: true,
        tileColor: const Color(0xFF795548),
        icon: Icons.currency_exchange,
      ),
      ApiInterfaceModel(
        id: 'api_7',
        name: 'IP地址查询API',
        description: '根据IP地址查询地理位置信息',
        category: '网络服务',
        price: 0.005,
        endpoint: '/ip/location',
        methods: ['GET'],
        callsPerMonth: 25000,
        responseTime: 100.0,
        reliability: 99.8,
        isFree: false,
        tileColor: const Color(0xFF3F51B5),
        icon: Icons.location_on,
      ),
      ApiInterfaceModel(
        id: 'api_8',
        name: '文本翻译API',
        description: '支持100+语言的智能翻译',
        category: 'AI服务',
        price: 0.02,
        endpoint: '/translate/text',
        methods: ['POST'],
        callsPerMonth: 12000,
        responseTime: 500.0,
        reliability: 99.6,
        isFree: false,
        tileColor: const Color(0xFFE91E63),
        icon: Icons.translate,
      ),
    ];

    // 模拟加载热门商品数据
    hotProducts.value = [
      ProductModel(
        id: '1',
        name: 'iPhone 15 Pro',
        imageUrl: 'https://picsum.photos/200/200?random=10',
        price: 7999.0,
        originalPrice: 8999.0,
        isHot: true,
      ),
      ProductModel(
        id: '2',
        name: 'MacBook Air',
        imageUrl: 'https://picsum.photos/200/200?random=11',
        price: 8999.0,
        originalPrice: 9999.0,
        isHot: true,
      ),
      ProductModel(
        id: '3',
        name: 'AirPods Pro',
        imageUrl: 'https://picsum.photos/200/200?random=12',
        price: 1999.0,
        originalPrice: 2299.0,
        isHot: true,
      ),
      ProductModel(
        id: '4',
        name: 'iPad Pro',
        imageUrl: 'https://picsum.photos/200/200?random=13',
        price: 6999.0,
        originalPrice: 7999.0,
        isHot: true,
      ),
    ];

    // 模拟加载精选商品数据
    selectedProducts.value = [
      ProductModel(
        id: '5',
        name: 'Apple Watch',
        imageUrl: 'https://picsum.photos/200/200?random=14',
        price: 2999.0,
        originalPrice: 3299.0,
      ),
      ProductModel(
        id: '6',
        name: 'Magic Keyboard',
        imageUrl: 'https://picsum.photos/200/200?random=15',
        price: 799.0,
        originalPrice: 899.0,
      ),
      ProductModel(
        id: '7',
        name: 'Magic Mouse',
        imageUrl: 'https://picsum.photos/200/200?random=16',
        price: 599.0,
        originalPrice: 699.0,
      ),
      ProductModel(
        id: '8',
        name: 'HomePod mini',
        imageUrl: 'https://picsum.photos/200/200?random=17',
        price: 749.0,
        originalPrice: 849.0,
      ),
    ];

    isLoading.value = false;
  }

  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void onProductTap(ProductModel product) {
    Get.snackbar(
      '商品详情',
      '点击了商品: ${product.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onApiInterfaceTap(ApiInterfaceModel apiInterface) {
    Get.snackbar(
      'API接口详情',
      '${apiInterface.name}\n${apiInterface.description}\n价格: ¥${apiInterface.price.toStringAsFixed(3)}/次',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
