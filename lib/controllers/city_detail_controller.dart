import 'package:get/get.dart';

import '../models/city_detail_model.dart';
import '../models/travel_plan_model.dart';
import '../models/user_city_content_models.dart';
import '../services/ai_api_service.dart';
import '../services/async_task_service.dart';
import '../services/user_city_content_api_service.dart';
import '../widgets/app_toast.dart';

/// 城市详情页控制器
class CityDetailController extends GetxController {
  // 当前城市ID
  var currentCityId = ''.obs;
  var currentCityName = ''.obs;

  // 当前选中的标签页
  var currentTabIndex = 0.obs;

  // 数据加载状态
  var isLoading = false.obs;

  // 各个标签页的数据
  var scores = Rx<CityScores?>(null);
  var prosList = <ProsCons>[].obs;
  var consList = <ProsCons>[].obs;
  var reviews = <CityReview>[].obs;
  var costOfLiving = Rx<CostOfLiving?>(null);
  var peopleInCity = <String>[].obs; // User IDs
  var photos = <CityPhoto>[].obs;
  var weather = Rx<WeatherData?>(null);
  var trends = Rx<TrendsData?>(null);
  var demographics = Rx<Demographics?>(null);
  var neighborhoods = <Neighborhood>[].obs;
  var coworkingSpaces = <CoworkingSpace>[].obs;
  var videos = <CityVideo>[].obs;
  var nearbyCities = <NearbyCity>[].obs;
  var similarCities = <NearbyCity>[].obs;
  var guide = Rx<DigitalNomadGuide?>(null);

  // 旅行计划生成状态
  var isGeneratingPlan = false.obs;
  var generatedPlan = Rx<TravelPlan?>(null);

  // 异步任务状态
  var currentTaskId = ''.obs;
  var taskProgress = 0.obs;
  var taskProgressMessage = ''.obs;

  // 用户生成内容 (新增)
  var userPhotos = <UserCityPhoto>[].obs;
  var userExpenses = <UserCityExpense>[].obs;
  var userReviews = <UserCityReview>[].obs;
  var cityContentStats = Rx<CityUserContentStats?>(null);
  var isLoadingUserContent = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 加载城市详情数据
    loadCityData();
  }

  /// 加载用户生成的内容 (照片、费用、评论)
  Future<void> loadUserContent() async {
    if (currentCityId.value.isEmpty) return;

    isLoadingUserContent.value = true;
    try {
      final apiService = UserCityContentApiService();

      // 并行加载所有用户内容
      final results = await Future.wait([
        apiService.getCityPhotos(cityId: currentCityId.value),
        apiService.getCityExpenses(cityId: currentCityId.value),
        apiService.getCityReviews(currentCityId.value),
        apiService.getCityStats(currentCityId.value),
      ]);

      userPhotos.value = results[0] as List<UserCityPhoto>;
      userExpenses.value = results[1] as List<UserCityExpense>;
      userReviews.value = results[2] as List<UserCityReview>;
      cityContentStats.value = results[3] as CityUserContentStats;

      print(
          '✅ 用户内容加载成功: ${userPhotos.length} photos, ${userExpenses.length} expenses, ${userReviews.length} reviews');
    } catch (e) {
      print('❌ 加载用户内容失败: $e');
      AppToast.error('Failed to load user content: $e');
    } finally {
      isLoadingUserContent.value = false;
    }
  }

  /// 刷新照片列表
  Future<void> refreshPhotos() async {
    if (currentCityId.value.isEmpty) return;

    try {
      final apiService = UserCityContentApiService();
      userPhotos.value =
          await apiService.getCityPhotos(cityId: currentCityId.value);

      // 同时刷新统计
      cityContentStats.value =
          await apiService.getCityStats(currentCityId.value);
    } catch (e) {
      print('❌ 刷新照片失败: $e');
    }
  }

  /// 刷新费用列表
  Future<void> refreshExpenses() async {
    if (currentCityId.value.isEmpty) return;

    try {
      final apiService = UserCityContentApiService();
      userExpenses.value =
          await apiService.getCityExpenses(cityId: currentCityId.value);

      // 同时刷新统计
      cityContentStats.value =
          await apiService.getCityStats(currentCityId.value);
    } catch (e) {
      print('❌ 刷新费用失败: $e');
    }
  }

  /// 刷新评论列表
  Future<void> refreshReviews() async {
    if (currentCityId.value.isEmpty) return;

    try {
      final apiService = UserCityContentApiService();
      userReviews.value = await apiService.getCityReviews(currentCityId.value);

      // 同时刷新统计
      cityContentStats.value =
          await apiService.getCityStats(currentCityId.value);
    } catch (e) {
      print('❌ 刷新评论失败: $e');
    }
  }

  /// 删除照片
  Future<void> deletePhoto(String photoId) async {
    try {
      final apiService = UserCityContentApiService();
      await apiService.deleteCityPhoto(
          cityId: currentCityId.value, photoId: photoId);

      // 从列表中移除
      userPhotos.removeWhere((photo) => photo.id == photoId);

      AppToast.success('Photo deleted successfully');

      // 刷新统计
      cityContentStats.value =
          await apiService.getCityStats(currentCityId.value);
    } catch (e) {
      print('❌ 删除照片失败: $e');
      AppToast.error('Failed to delete photo: $e');
    }
  }

  /// 删除费用
  Future<void> deleteExpense(String expenseId) async {
    try {
      final apiService = UserCityContentApiService();
      await apiService.deleteCityExpense(
          cityId: currentCityId.value, expenseId: expenseId);

      // 从列表中移除
      userExpenses.removeWhere((expense) => expense.id == expenseId);

      AppToast.success('Expense deleted successfully');

      // 刷新统计
      cityContentStats.value =
          await apiService.getCityStats(currentCityId.value);
    } catch (e) {
      print('❌ 删除费用失败: $e');
      AppToast.error('Failed to delete expense: $e');
    }
  }

  /// 删除评论
  Future<void> deleteReview() async {
    try {
      final apiService = UserCityContentApiService();
      await apiService.deleteMyCityReview(currentCityId.value);

      // 刷新评论列表
      await refreshReviews();

      AppToast.success('Review deleted successfully');
    } catch (e) {
      print('❌ 删除评论失败: $e');
      AppToast.error('Failed to delete review: $e');
    }
  }

  /// 加载城市数据
  void loadCityData() {
    isLoading.value = true;

    // 模拟加载数据
    Future.delayed(const Duration(milliseconds: 500), () {
      _generateMockData();
      isLoading.value = false;
    });
  }

  /// 切换标签页
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  /// 投票优缺点
  void voteProCon(String id, bool isUpvote) {
    // 更新投票
    // 实际应该调用 API 更新投票
    // final allItems = [...prosList, ...consList];
    // final item = allItems.firstWhere((item) => item.id == id);
  }

  /// 点赞评论
  void likeReview(String reviewId) {
    final index = reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      // 实际应该调用 API
    }
  }

  /// 点赞照片
  void likePhoto(String photoId) {
    final index = photos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      // 实际应该调用 API
    }
  }

  /// 生成模拟数据
  void _generateMockData() {
    // 生成评分数据
    scores.value = CityScores(
      overall: 4.55,
      qualityOfLife: 4.2,
      familyScore: 3.8,
      communityScore: 4.7,
      safetyScore: 4.3,
      womenSafety: 4.1,
      lgbtqSafety: 4.8,
      funScore: 4.5,
      walkability: 4.6,
      nightlife: 4.9,
      friendlyToForeigners: 4.7,
      englishSpeaking: 2.8,
      foodSafety: 4.1,
      lackOfCrime: 4.2,
      lackOfRacism: 2.5,
      educationLevel: 3.2,
      powerGrid: 4.8,
      climateVulnerability: 3.5,
      trafficSafety: 2.9,
      airlineScore: 4.3,
      lostLuggage: 4.7,
      hospitals: 4.8,
      happiness: 4.2,
      freeWiFi: 4.7,
      placesToWork: 4.9,
      acHeating: 4.6,
      freedomOfSpeech: 3.5,
      startupScore: 2.8,
    );

    // 生成优点
    prosList.value = [
      ProsCons(
        id: '1',
        text: 'Amazing street food culture with diverse options',
        upvotes: 156,
        downvotes: 12,
        isPro: true,
      ),
      ProsCons(
        id: '2',
        text: 'Very affordable cost of living',
        upvotes: 243,
        downvotes: 8,
        isPro: true,
      ),
      ProsCons(
        id: '3',
        text: 'Excellent coworking spaces and cafes with fast WiFi',
        upvotes: 198,
        downvotes: 15,
        isPro: true,
      ),
      ProsCons(
        id: '4',
        text: 'Vibrant nightlife and entertainment',
        upvotes: 187,
        downvotes: 22,
        isPro: true,
      ),
      ProsCons(
        id: '5',
        text: 'Easy to meet other digital nomads',
        upvotes: 221,
        downvotes: 9,
        isPro: true,
      ),
    ];

    // 生成缺点
    consList.value = [
      ProsCons(
        id: '6',
        text: 'Traffic can be extremely congested',
        upvotes: 289,
        downvotes: 34,
        isPro: false,
      ),
      ProsCons(
        id: '7',
        text: 'Air quality issues during certain months',
        upvotes: 167,
        downvotes: 23,
        isPro: false,
      ),
      ProsCons(
        id: '8',
        text: 'Very hot and humid weather year-round',
        upvotes: 201,
        downvotes: 45,
        isPro: false,
      ),
      ProsCons(
        id: '9',
        text: 'Language barrier can be challenging',
        upvotes: 134,
        downvotes: 56,
        isPro: false,
      ),
    ];

    // 生成评论
    reviews.value = [
      CityReview(
        id: 'r1',
        userId: 'user1',
        userName: 'Sarah Johnson',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        rating: 4.5,
        title: 'Amazing city for digital nomads!',
        content:
            'Spent 3 months here and absolutely loved it. The coworking scene is fantastic, food is incredible, and I met so many amazing people. The traffic is crazy though, but you get used to it.',
        photos: [
          'https://images.unsplash.com/photo-1528181304800-259b08848526?w=400',
          'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=400',
        ],
        visitDate: DateTime.now().subtract(const Duration(days: 90)),
        stayDuration: 90,
        likes: 45,
        comments: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        categoryRatings: {
          'cost': 4.8,
          'internet': 4.5,
          'safety': 4.2,
          'food': 4.9,
          'community': 4.7,
        },
      ),
      CityReview(
        id: 'r2',
        userId: 'user2',
        userName: 'Mike Chen',
        userAvatar: 'https://i.pravatar.cc/150?img=12',
        rating: 4.0,
        title: 'Great for short-term stays',
        content:
            'Perfect for a month or two. Very affordable and lots to do. The heat can be intense if you\'re not used to tropical weather.',
        photos: [
          'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=400',
        ],
        visitDate: DateTime.now().subtract(const Duration(days: 120)),
        stayDuration: 60,
        likes: 32,
        comments: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
    ];

    // 生成生活成本
    costOfLiving.value = CostOfLiving(
      total: 1563,
      accommodation: 600,
      food: 350,
      transportation: 80,
      entertainment: 200,
      gym: 50,
      coworking: 150,
      utilities: 50,
      groceries: 180,
      diningOut: 170,
      airbnbCost: 800,
      hotelCost: 1200,
      apartmentCost: 400,
    );

    // 生成天气数据
    weather.value = WeatherData(
      currentTemp: 32,
      feelsLike: 41,
      humidity: 71,
      condition: 'sunny',
      aqi: 56,
      forecast: List.generate(
          7,
          (index) => DailyForecast(
                date: DateTime.now().add(Duration(days: index)),
                high: 33 + (index % 3),
                low: 28 + (index % 2),
                condition: index % 3 == 0 ? 'rainy' : 'sunny',
                precipitation: index % 3 == 0 ? 60 : 10,
              )),
      monthlyClimate: MonthlyClimate(
        avgTemperature: {
          'Jan': 27,
          'Feb': 28,
          'Mar': 29,
          'Apr': 30,
          'May': 30,
          'Jun': 29,
          'Jul': 29,
          'Aug': 29,
          'Sep': 28,
          'Oct': 28,
          'Nov': 27,
          'Dec': 26,
        },
        rainfall: {
          'Jan': 10,
          'Feb': 20,
          'Mar': 30,
          'Apr': 70,
          'May': 200,
          'Jun': 150,
          'Jul': 160,
          'Aug': 180,
          'Sep': 300,
          'Oct': 240,
          'Nov': 50,
          'Dec': 10,
        },
      ),
      bestSeason: 'November to February',
    );

    // 生成照片
    photos.value = List.generate(
        12,
        (index) => CityPhoto(
              id: 'photo$index',
              url:
                  'https://images.unsplash.com/photo-${1528181304800 + index * 100}?w=400',
              userId: 'user${index % 5}',
              userName: ['Alex', 'Sam', 'Jordan', 'Taylor', 'Casey'][index % 5],
              caption: index % 3 == 0 ? 'Beautiful sunset view' : null,
              location: index % 2 == 0 ? 'Sukhumvit' : 'Silom',
              likes: 20 + index * 5,
              uploadedAt: DateTime.now().subtract(Duration(days: index * 2)),
            ));

    // 生成社区数据
    neighborhoods.value = [
      Neighborhood(
        id: 'n1',
        name: 'Sukhumvit',
        description:
            'Modern area with excellent public transport, shopping malls, and nightlife',
        safetyScore: 4.5,
        rentPrice: 800,
        nightlifeScore: 4.8,
        amenities: [
          'BTS/MRT',
          'Shopping malls',
          'Restaurants',
          'Bars',
          'Coworking'
        ],
        imageUrl:
            'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=400',
        features: {
          'walkable': true,
          'quiet': false,
          'trendy': true,
          'expat-friendly': true,
        },
      ),
      Neighborhood(
        id: 'n2',
        name: 'Silom',
        description:
            'Financial district with great food scene and rooftop bars',
        safetyScore: 4.6,
        rentPrice: 700,
        nightlifeScore: 4.7,
        amenities: ['BTS', 'Street food', 'Rooftop bars', 'Night market'],
        imageUrl:
            'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=400',
        features: {
          'walkable': true,
          'quiet': false,
          'trendy': true,
          'expat-friendly': true,
        },
      ),
    ];

    // 生成共享办公空间
    coworkingSpaces.value = [
      CoworkingSpace(
        id: 'c1',
        name: 'The Hive Thonglor',
        address: '1 Sukhumvit 55, Thonglor',
        rating: 4.7,
        reviewCount: 156,
        price: 15,
        internetSpeed: 100,
        amenities: ['High-speed WiFi', 'Meeting rooms', 'Coffee', 'Printing'],
        imageUrl:
            'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400',
        latitude: 13.7367,
        longitude: 100.5735,
        websiteUrl: 'https://thehive.co.th',
      ),
      CoworkingSpace(
        id: 'c2',
        name: 'HUBBA To',
        address: '29 Sukhumvit 26',
        rating: 4.6,
        reviewCount: 89,
        price: 12,
        internetSpeed: 80,
        amenities: ['WiFi', 'Cafe', 'Events', 'Community'],
        imageUrl:
            'https://images.unsplash.com/photo-1497366858526-0766cadbe8fa?w=400',
        latitude: 13.7308,
        longitude: 100.5691,
      ),
    ];

    // 生成附近城市
    nearbyCities.value = [
      NearbyCity(
        id: 'pattaya',
        name: 'Pattaya',
        country: 'Thailand',
        distance: 147,
        transportation: 'Bus',
        travelTime: 2,
        overallScore: 3.5,
        imageUrl:
            'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=400',
      ),
      NearbyCity(
        id: 'ayutthaya',
        name: 'Ayutthaya',
        country: 'Thailand',
        distance: 76,
        transportation: 'Train',
        travelTime: 1.5,
        overallScore: 3.2,
        imageUrl:
            'https://images.unsplash.com/photo-1598135753163-6167c1a1ad65?w=400',
      ),
    ];

    // 生成数字游民指南
    guide.value = DigitalNomadGuide(
      cityId: currentCityId.value,
      cityName: currentCityName.value,
      overview:
          'Bangkok is one of the most popular digital nomad destinations in Southeast Asia, offering an unbeatable combination of affordability, infrastructure, and vibrant culture.',
      visaInfo: VisaInfo(
        type: 'Tourist Visa',
        duration: 60,
        requirements: 'Valid passport, proof of accommodation, return ticket',
        cost: 35,
        process: 'Apply online or at embassy',
      ),
      bestAreas: [
        'Sukhumvit (modern, convenient)',
        'Silom (business district)',
        'Ari (hipster, local)',
        'Thonglor (upscale, expat-friendly)',
      ],
      workspaceRecommendations: [
        'The Hive - Multiple locations',
        'HUBBA - Community focused',
        'AIS D.C. - Spacious and modern',
        'Launchpad - Startup vibe',
      ],
      tips: [
        'Get a local SIM card (AIS or DTAC) for reliable internet',
        'Use Grab or Bolt for transportation',
        'Learn basic Thai phrases',
        'Join Facebook groups for digital nomads',
        'Be prepared for hot and humid weather',
      ],
      essentialInfo: {
        'SIM Card': 'Available at 7-Eleven, 200-500 THB/month',
        'Bank': 'Bangkok Bank offers tourist accounts',
        'Transport': 'BTS/MRT trains, Grab taxis',
        'Healthcare': 'Excellent private hospitals (Bumrungrad, Samitivej)',
        'Coworking': '\$150-300/month for hot desk',
      },
    );
  }

  /// 生成AI旅行计划
  Future<TravelPlan?> generateTravelPlan({
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
  }) async {
    isGeneratingPlan.value = true;

    try {
      print('🎯 开始调用AI服务生成旅行计划...');

      // 调用AI API生成旅行计划
      final aiService = AiApiService();
      final plan = await aiService.generateTravelPlan(
        cityId: currentCityId.value,
        cityName: currentCityName.value,
        cityImage:
            'https://images.unsplash.com/photo-1528181304800-259b08848526?w=800',
        duration: duration,
        budget: budget,
        travelStyle: travelStyle,
        interests: interests,
        departureLocation: departureLocation,
      );

      generatedPlan.value = plan;

      print('✅ AI旅行计划生成成功!');

      // 显示成功消息
      AppToast.success(
        'Travel plan generated successfully!',
        title: 'Success',
      );

      return plan;
    } catch (e) {
      print('❌ AI旅行计划生成失败: $e');

      AppToast.error(
        'Failed to generate travel plan: ${e.toString()}',
        title: 'Error',
      );
      return null;
    } finally {
      isGeneratingPlan.value = false;
    }
  }

  /// 流式生成AI旅行计划 (支持实时进度更新)
  Future<void> generateTravelPlanStream({
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    required Function(String message, int progress) onProgress,
    required Function(TravelPlan plan) onData,
    required Function(String error) onError,
  }) async {
    isGeneratingPlan.value = true;

    try {
      print('🎯 [流式] 开始调用AI服务生成旅行计划...');

      final aiService = AiApiService();
      await aiService.generateTravelPlanStream(
        cityId: currentCityId.value,
        cityName: currentCityName.value,
        cityImage:
            'https://images.unsplash.com/photo-1528181304800-259b08848526?w=800',
        duration: duration,
        budget: budget,
        travelStyle: travelStyle,
        interests: interests,
        departureLocation: departureLocation,
        onProgress: onProgress,
        onData: (TravelPlan plan) {
          // 保存到状态
          generatedPlan.value = plan;

          // 显示成功消息
          AppToast.success(
            'Travel plan generated successfully!',
            title: 'Success',
          );

          // 回调
          onData(plan);
        },
        onError: onError,
      );
    } catch (e) {
      print('❌ [流式] AI旅行计划生成失败: $e');
      onError('Failed to generate: ${e.toString()}');
    } finally {
      isGeneratingPlan.value = false;
    }
  }

  /// 异步生成AI旅行计划 (使用任务队列 + SignalR)
  ///
  /// 这是推荐的方式,使用后台任务队列异步处理
  /// 支持 SignalR 实时进度更新和轮询回退机制
  Future<String?> generateTravelPlanAsync({
    required int duration,
    required String budget, // "low", "medium", "high"
    required String
        travelStyle, // "adventure", "relaxation", "culture", "nightlife"
    required List<String> interests,
    required Function(int progress, String message) onProgress,
  }) async {
    isGeneratingPlan.value = true;
    taskProgress.value = 0;
    taskProgressMessage.value = '正在创建任务...';

    try {
      print('🚀 开始异步生成旅行计划...');

      final asyncTaskService = AsyncTaskService();

      // 连接 SignalR (如果尚未连接)
      if (!asyncTaskService.signalR.isConnected) {
        try {
          await asyncTaskService.signalR.connect('http://localhost:8009');
          print('✅ SignalR 已连接');
        } catch (e) {
          print('⚠️ SignalR 连接失败,将使用轮询模式: $e');
        }
      }

      // 1. 创建任务并等待完成
      final finalStatus = await asyncTaskService.createAndWaitForCompletion(
        cityId: currentCityId.value,
        cityName: currentCityName.value,
        duration: duration,
        budget: budget,
        travelStyle: travelStyle,
        interests: interests,
        onProgress: (status) {
          // 更新进度
          taskProgress.value = status.progress;
          taskProgressMessage.value = status.progressMessage ?? '';

          print('📊 任务进度: ${status.progress}% - ${status.progressMessage}');

          // 回调通知UI
          onProgress(status.progress, status.progressMessage ?? '');
        },
      );

      if (finalStatus.isCompleted && finalStatus.planId != null) {
        print('✅ 旅行计划生成成功! PlanId: ${finalStatus.planId}');

        // TODO: 从数据库加载完整的旅行计划数据
        // 这里可以调用另一个 API 获取完整计划详情

        AppToast.success(
          'Travel plan generated successfully!',
          title: 'Success',
        );

        return finalStatus.planId;
      } else {
        throw Exception('任务未完成或没有返回planId');
      }
    } catch (e) {
      print('❌ 异步生成失败: $e');

      AppToast.error(
        'Failed to generate travel plan: ${e.toString()}',
        title: 'Error',
      );

      return null;
    } finally {
      isGeneratingPlan.value = false;
      // 注意：不要在这里重置进度值，因为对话框可能还在显示
      // 让调用方（travel_plan_page）在关闭对话框后再重置
      // taskProgress.value = 0;
      // taskProgressMessage.value = '';
    }
  }

  /// 生成模拟旅行计划 (备用方法,仅用于开发测试)
  /// 注意: 改为 public 方法,供 TravelPlanPage 临时使用
  TravelPlan generateMockTravelPlan({
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
  }) {
    final cityName = currentCityName.value;

    // 根据预算设置价格倍数
    double budgetMultiplier =
        budget == 'low' ? 0.7 : (budget == 'high' ? 1.5 : 1.0);

    return TravelPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      cityId: currentCityId.value,
      cityName: cityName,
      cityImage:
          'https://images.unsplash.com/photo-1528181304800-259b08848526?w=800',
      createdAt: DateTime.now(),
      duration: duration,
      budget: budget,
      travelStyle: travelStyle,
      interests: interests,
      transportation: TransportationPlan(
        arrivalMethod: 'Flight',
        arrivalDetails:
            'Direct flight from major hub. Book 2-3 months in advance for best prices.',
        estimatedCost: 500 * budgetMultiplier,
        localTransport: 'BTS/MRT + Grab',
        localTransportDetails:
            'Use BTS Skytrain and MRT subway for main routes. Grab/Bolt for door-to-door.',
        dailyTransportCost: 10 * budgetMultiplier,
      ),
      accommodation: AccommodationPlan(
        type: budget == 'low'
            ? 'Hostel/Shared'
            : (budget == 'high'
                ? 'Hotel/Serviced Apartment'
                : 'Boutique Hotel/Airbnb'),
        recommendation: budget == 'low'
            ? 'Lub d Hostel - Social atmosphere, great for meeting people'
            : (budget == 'high'
                ? 'Anantara Riverside - Luxury resort with amazing views'
                : 'The Yard Hostel - Private rooms with boutique feel'),
        area: travelStyle == 'nightlife'
            ? 'Sukhumvit/Thonglor'
            : (travelStyle == 'culture'
                ? 'Old Town/Rattanakosin'
                : 'Silom/Sathorn'),
        pricePerNight: budget == 'low' ? 15 : (budget == 'high' ? 150 : 60),
        amenities: [
          'Free WiFi',
          'Air Conditioning',
          'Coworking Space',
          'Pool',
          'Gym'
        ],
        bookingTips:
            'Book directly for better rates. Look for monthly discounts if staying longer.',
      ),
      dailyItineraries: List.generate(duration, (index) {
        return DailyItinerary(
          day: index + 1,
          theme: _getDayTheme(index, travelStyle, interests),
          activities: _generateDayActivities(
              index, travelStyle, interests, budgetMultiplier),
          notes:
              'Stay hydrated and use sunscreen. Best to avoid rush hours (7-9am, 5-7pm).',
        );
      }),
      attractions: [
        Attraction(
          name: 'Grand Palace',
          description:
              'Stunning royal palace complex with intricate architecture',
          category: 'Historical',
          rating: 4.7,
          location: 'Rattanakosin Island',
          entryFee: 500 * budgetMultiplier,
          bestTime: 'Early morning (8-10am) to avoid crowds',
          image:
              'https://images.unsplash.com/photo-1528181304800-259b08848526?w=400',
        ),
        Attraction(
          name: 'Chatuchak Weekend Market',
          description:
              'Massive market with thousands of stalls selling everything',
          category: 'Shopping',
          rating: 4.6,
          location: 'Mo Chit',
          entryFee: 0,
          bestTime: 'Saturday or Sunday morning',
          image:
              'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=400',
        ),
        Attraction(
          name: 'Wat Arun',
          description:
              'Beautiful temple on the river with stunning sunset views',
          category: 'Temple',
          rating: 4.8,
          location: 'Thonburi',
          entryFee: 100 * budgetMultiplier,
          bestTime: 'Late afternoon for sunset',
          image:
              'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=400',
        ),
      ],
      restaurants: [
        Restaurant(
          name: 'Jay Fai',
          cuisine: 'Thai Street Food',
          description: 'Michelin-starred street food, famous for crab omelette',
          rating: 4.9,
          priceRange:
              budget == 'low' ? '\$' : (budget == 'high' ? '\$\$\$' : '\$\$'),
          location: 'Old Town',
          specialty: 'Crab Omelette, Drunken Noodles',
          image:
              'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
        ),
        Restaurant(
          name: 'Som Tam Nua',
          cuisine: 'Isaan (Northeastern Thai)',
          description: 'Authentic papaya salad and grilled chicken',
          rating: 4.7,
          priceRange: '\$',
          location: 'Siam Square',
          specialty: 'Som Tam (Papaya Salad), Gai Yang',
          image:
              'https://images.unsplash.com/photo-1562565652-a0d8f0c59eb4?w=400',
        ),
        Restaurant(
          name: 'Gaggan',
          cuisine: 'Progressive Indian',
          description: 'World-renowned fine dining experience',
          rating: 5.0,
          priceRange: '\$\$\$\$',
          location: 'Langsuan',
          specialty: 'Tasting Menu',
          image:
              'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
        ),
      ],
      tips: [
        '🌡️ Weather: Expect hot and humid conditions year-round. Dress light and breathable.',
        '💰 Money: ATMs widely available. Carry some cash for street food and markets.',
        '🚕 Transport: Download Grab app for easy transportation. BTS/MRT for main routes.',
        '👕 Dress Code: Cover shoulders and knees when visiting temples.',
        '📱 SIM Card: Get a local SIM at airport (AIS/DTAC) - 200-500 THB for unlimited data.',
        '🍜 Food: Street food is safe and delicious. Look for busy stalls.',
        '🗣️ Language: Learn basic Thai greetings. "Sawadee krap/ka" goes a long way.',
        '⚡ Adapter: Thailand uses Type A, B, C outlets (220V).',
      ],
      budgetBreakdown: BudgetBreakdown(
        transportation: (500 + (10 * duration)) * budgetMultiplier,
        accommodation: (budget == 'low' ? 15 : (budget == 'high' ? 150 : 60)) *
            duration.toDouble(),
        food: 30 * duration * budgetMultiplier,
        activities: 50 * duration * budgetMultiplier,
        miscellaneous: 20 * duration * budgetMultiplier,
        total: ((500 + (10 * duration)) +
                ((budget == 'low' ? 15 : (budget == 'high' ? 150 : 60)) *
                    duration) +
                (30 * duration) +
                (50 * duration) +
                (20 * duration)) *
            budgetMultiplier,
        currency: 'USD',
      ),
    );
  }

  String _getDayTheme(int day, String travelStyle, List<String> interests) {
    if (day == 0) return 'Arrival & Orientation';
    if (travelStyle == 'culture') {
      return ['Historical Temples', 'Local Markets', 'Art & Museums'][day % 3];
    } else if (travelStyle == 'nightlife') {
      return ['Rooftop Bars', 'Night Markets', 'Street Food Tour'][day % 3];
    } else if (travelStyle == 'adventure') {
      return ['Outdoor Activities', 'Island Hopping', 'Hiking'][day % 3];
    }
    return 'Exploration Day';
  }

  List<Activity> _generateDayActivities(int day, String travelStyle,
      List<String> interests, double budgetMultiplier) {
    if (day == 0) {
      return [
        Activity(
          time: '10:00 AM',
          name: 'Hotel Check-in',
          description: 'Settle into your accommodation and freshen up',
          location: 'Hotel',
          estimatedCost: 0,
          duration: 60,
        ),
        Activity(
          time: '12:00 PM',
          name: 'Lunch at Local Restaurant',
          description: 'Try authentic Thai cuisine at nearby restaurant',
          location: 'Near hotel',
          estimatedCost: 15 * budgetMultiplier,
          duration: 90,
        ),
        Activity(
          time: '2:00 PM',
          name: 'Walking Tour',
          description: 'Explore the neighborhood and get oriented',
          location: 'Local area',
          estimatedCost: 0,
          duration: 120,
        ),
      ];
    }

    return [
      Activity(
        time: '9:00 AM',
        name: 'Morning Temple Visit',
        description: 'Visit historic temple before crowds arrive',
        location: 'Old Town',
        estimatedCost: 5 * budgetMultiplier,
        duration: 120,
      ),
      Activity(
        time: '12:00 PM',
        name: 'Street Food Lunch',
        description: 'Sample local street food specialties',
        location: 'Food market',
        estimatedCost: 10 * budgetMultiplier,
        duration: 60,
      ),
      Activity(
        time: '2:00 PM',
        name: 'Market Shopping',
        description: 'Browse local markets for souvenirs and crafts',
        location: 'Chatuchak',
        estimatedCost: 20 * budgetMultiplier,
        duration: 150,
      ),
      Activity(
        time: '6:00 PM',
        name: 'Sunset River Cruise',
        description: 'Enjoy dinner cruise along the river',
        location: 'Chao Phraya River',
        estimatedCost: 40 * budgetMultiplier,
        duration: 120,
      ),
    ];
  }
}
