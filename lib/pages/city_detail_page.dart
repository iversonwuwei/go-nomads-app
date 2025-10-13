import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../controllers/city_detail_controller.dart';
import '../controllers/coworking_controller.dart';
import '../models/coworking_space_model.dart';
import '../widgets/skeleton_loader.dart';
import 'add_coworking_page.dart';
import 'coworking_detail_page.dart';
import 'create_travel_plan_page.dart';

/// 城市详情页 - 完整的 Nomads.com 风格标签页系统
class CityDetailPage extends StatefulWidget {
  final String cityId;
  final String cityName;
  final String cityImage;
  final double overallScore;
  final int reviewCount;

  const CityDetailPage({
    super.key,
    required this.cityId,
    required this.cityName,
    required this.cityImage,
    required this.overallScore,
    required this.reviewCount,
  });

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isPageActive = true; // 追踪页面是否处于活动状态

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _isPageActive = false; // 标记页面已销毁
    _pageController.dispose();
    // 地图视图会在原生层自动销毁
    print('🗑️ City detail page disposed, map view will be destroyed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CityDetailController());
    controller.currentCityId.value = widget.cityId;
    controller.currentCityName.value = widget.cityName;

    return DefaultTabController(
      length:
          9, // 修正为9个标签(Scores, Guide, Pros&Cons, Reviews, Cost, Photos, Weather, Neighborhoods, Coworking)
      child: Scaffold(
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // 大图 Banner
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_outlined,
                          color: AppColors.backButtonLight),
                      onPressed: () => Get.back(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        widget.cityName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // PageView carousel
                          PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            children: [
                              // City Image with gradient
                              Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    widget.cityImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(color: Colors.grey[300]);
                                    },
                                  ),
                                  // Gradient overlay only on image page
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Map view (no gradient overlay)
                              _buildMapView(),
                            ],
                          ),
                          // Page indicators - positioned at bottom
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildIndicator(0),
                                  const SizedBox(width: 8),
                                  _buildIndicator(1),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 评分信息
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4458),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.overallScore.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.reviewCount} reviews',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {},
                            color: const Color(0xFFFF4458),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {},
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 标签页导航
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        isScrollable: true,
                        labelColor: const Color(0xFFFF4458),
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: const Color(0xFFFF4458),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Scores'),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _showShareScoreDialog(),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    child:
                                        const Icon(Icons.add_circle, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Tab(text: 'Guide'),
                          const Tab(text: 'Pros & Cons'),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Reviews'),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _showShareReviewDialog(),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    child:
                                        const Icon(Icons.add_circle, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Cost'),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _showShareCostDialog(),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    child:
                                        const Icon(Icons.add_circle, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Photos'),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _showSharePhotoDialog(),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    child:
                                        const Icon(Icons.add_circle, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Tab(text: 'Weather'),
                          const Tab(text: 'Neighborhoods'),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Coworking'),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _showAddCoworkingPage(),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    child:
                                        const Icon(Icons.add_circle, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Obx(() {
                if (controller.isLoading.value) {
                  return const SkeletonLoader(type: SkeletonType.detail);
                }

                return TabBarView(
                  children: [
                    _buildScoresTab(controller),
                    _buildGuideTab(controller),
                    _buildProsConsTab(controller),
                    _buildReviewsTab(controller),
                    _buildCostTab(controller),
                    _buildPhotosTab(controller),
                    _buildWeatherTab(controller),
                    _buildNeighborhoodsTab(controller),
                    _buildCoworkingTab(controller),
                  ],
                );
              }),
            ),

            // Floating AI Travel Plan Button
            Positioned(
              bottom: 16,
              right: 16,
              child: Material(
                elevation: 6,
                shadowColor: const Color(0xFFFF4458).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: () {
                    // 跳转到创建旅行计划页面
                    Get.to(
                      () => CreateTravelPlanPage(
                        cityId: widget.cityId,
                        cityName: widget.cityName,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'AI Travel Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Scores 标签
  Widget _buildScoresTab(CityDetailController controller) {
    final scores = controller.scores.value;
    if (scores == null) {
      return const Center(child: Text('No data'));
    }

    final scoreItems = [
      {'icon': Icons.star, 'label': 'Overall', 'value': scores.overall},
      {
        'icon': Icons.favorite,
        'label': 'Quality of Life',
        'value': scores.qualityOfLife
      },
      {
        'icon': Icons.family_restroom,
        'label': 'Family Score',
        'value': scores.familyScore
      },
      {
        'icon': Icons.people,
        'label': 'Community',
        'value': scores.communityScore
      },
      {'icon': Icons.security, 'label': 'Safety', 'value': scores.safetyScore},
      {
        'icon': Icons.female,
        'label': 'Women Safety',
        'value': scores.womenSafety
      },
      {
        'icon': Icons.flag,
        'label': 'LGBTQ+ Safety',
        'value': scores.lgbtqSafety
      },
      {'icon': Icons.celebration, 'label': 'Fun', 'value': scores.funScore},
      {
        'icon': Icons.directions_walk,
        'label': 'Walkability',
        'value': scores.walkability
      },
      {
        'icon': Icons.nightlife,
        'label': 'Nightlife',
        'value': scores.nightlife
      },
      {
        'icon': Icons.language,
        'label': 'English Speaking',
        'value': scores.englishSpeaking
      },
      {
        'icon': Icons.restaurant,
        'label': 'Food Safety',
        'value': scores.foodSafety
      },
      {'icon': Icons.wifi, 'label': 'Free WiFi', 'value': scores.freeWiFi},
      {
        'icon': Icons.laptop,
        'label': 'Places to Work',
        'value': scores.placesToWork
      },
      {
        'icon': Icons.local_hospital,
        'label': 'Hospitals',
        'value': scores.hospitals
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      itemCount: scoreItems.length,
      itemBuilder: (context, index) {
        final item = scoreItems[index];
        return _buildScoreItem(
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          score: item['value'] as double,
        );
      },
    );
  }

  Widget _buildScoreItem({
    required IconData icon,
    required String label,
    required double score,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF4458), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: score / 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF4458),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Digital Nomad Guide 标签
  Widget _buildGuideTab(CityDetailController controller) {
    final guide = controller.guide.value;
    if (guide == null) {
      return const Center(child: Text('Loading guide...'));
    }

    return _buildGuideContent(guide);
  }

  Widget _buildGuideContent(guide) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          guide.overview,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Best Areas to Stay',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...guide.bestAreas.map((area) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF4458),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      area,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
        const Text(
          'Essential Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...guide.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•',
                      style: TextStyle(fontSize: 18, color: Color(0xFFFF4458))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // Pros & Cons 标签
  Widget _buildProsConsTab(CityDetailController controller) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        const Text(
          'Pros',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...controller.prosList.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.text,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_upward,
                            size: 16, color: Color(0xFFFF4458)),
                        Text(
                          '${item.upvotes}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 24),
        const Text(
          'Cons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...controller.consList.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.text,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_upward,
                            size: 16, color: Color(0xFFFF4458)),
                        Text(
                          '${item.upvotes}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // Reviews 标签
  Widget _buildReviewsTab(CityDetailController controller) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      itemCount: controller.reviews.length,
      itemBuilder: (context, index) {
        final review = controller.reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(review.userAvatar),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${review.stayDuration} days',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${review.rating}'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                if (review.photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.photos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(review.photos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Cost of Living 标签
  Widget _buildCostTab(CityDetailController controller) {
    final cost = controller.costOfLiving.value;
    if (cost == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4458),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Average Monthly Cost',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${cost.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCostItem('🏠 Accommodation', cost.accommodation),
        _buildCostItem('🍔 Food', cost.food),
        _buildCostItem('🚕 Transportation', cost.transportation),
        _buildCostItem('🎭 Entertainment', cost.entertainment),
        _buildCostItem('💪 Gym', cost.gym),
        _buildCostItem('💻 Coworking', cost.coworking),
      ],
    );
  }

  Widget _buildCostItem(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Photos 标签
  Widget _buildPhotosTab(CityDetailController controller) {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: controller.photos.length,
      itemBuilder: (context, index) {
        final photo = controller.photos[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(photo.url),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  // Weather 标签
  Widget _buildWeatherTab(CityDetailController controller) {
    final weather = controller.weather.value;
    if (weather == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '${weather.currentTemp.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Feels like ${weather.feelsLike.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '7-Day Forecast',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...weather.forecast.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${day.date.month}/${day.date.day}'),
                  ),
                  Icon(
                    day.condition == 'rainy'
                        ? Icons.water_drop
                        : Icons.wb_sunny,
                    color:
                        day.condition == 'rainy' ? Colors.blue : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                      '${day.low.toStringAsFixed(0)}° - ${day.high.toStringAsFixed(0)}°'),
                ],
              ),
            )),
      ],
    );
  }

  // Neighborhoods 标签
  Widget _buildNeighborhoodsTab(CityDetailController controller) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      itemCount: controller.neighborhoods.length,
      itemBuilder: (context, index) {
        final neighborhood = controller.neighborhoods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  neighborhood.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      neighborhood.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      neighborhood.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.security,
                            size: 16, color: Color(0xFFFF4458)),
                        const SizedBox(width: 4),
                        Text('Safety: ${neighborhood.safetyScore}'),
                        const SizedBox(width: 16),
                        const Icon(Icons.attach_money,
                            size: 16, color: Color(0xFFFF4458)),
                        const SizedBox(width: 4),
                        Text(
                            '\$${neighborhood.rentPrice.toStringAsFixed(0)}/mo'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Coworking 标签页
  Widget _buildCoworkingTab(CityDetailController controller) {
    final coworkingController = Get.put(CoworkingController());
    coworkingController.filterByCity(widget.cityName);

    return Obx(() {
      if (coworkingController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (coworkingController.filteredSpaces.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elegant illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF4458).withValues(alpha: 0.08),
                        const Color(0xFFFF4458).withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circles
                      Positioned(
                        top: 40,
                        right: 40,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 30,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF4458).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Main icon
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'No coworking spaces yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Help build the community',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Minimalist add button
                InkWell(
                  onTap: _showAddCoworkingPage,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add First Space',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: coworkingController.filteredSpaces.length,
        itemBuilder: (context, index) {
          final space = coworkingController.filteredSpaces[index];
          return _buildCoworkingSpaceCard(space);
        },
      );
    });
  }

  Widget _buildCoworkingSpaceCard(CoworkingSpace space) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => CoworkingDetailPage(space: space));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 空间图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      space.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.business, size: 48),
                        );
                      },
                    ),
                  ),
                ),
                // Verified 徽章
                if (space.isVerified)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 空间信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称和评分
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 评分
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              space.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 地址
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 关键指标
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCoworkingInfoChip(
                        Icons.wifi,
                        '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                        Colors.blue,
                      ),
                      if (space.pricing.monthlyRate != null)
                        _buildCoworkingInfoChip(
                          Icons.attach_money,
                          '\$${space.pricing.monthlyRate!.toStringAsFixed(0)}/mo',
                          Colors.green,
                        ),
                      if (space.amenities.has24HourAccess)
                        _buildCoworkingInfoChip(
                          Icons.access_time,
                          '24/7',
                          Colors.orange,
                        ),
                      if (space.pricing.hasFreeTrial)
                        _buildCoworkingInfoChip(
                          Icons.local_offer,
                          'Free Trial',
                          const Color(0xFFFF4458),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoworkingInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ========== 分享对话框方法 ==========

  /// 分享评分信息
  void _showShareScoreDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Share Your Scores',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Help the community by rating different aspects of ${widget.cityName}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Score submission feature will be available soon!',
                      backgroundColor: const Color(0xFFFF4458),
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Start Rating'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享指南信息
  /// 分享评论
  void _showShareReviewDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final RxList<XFile> selectedImages = <XFile>[].obs;
    final RxDouble rating = 0.0.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rate_review,
                    color: Color(0xFFFF4458), size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Write a Review',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your experience in ${widget.cityName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating section
                        const Text(
                          'Rating',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Obx(() => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (index) {
                                  final fullStar = index < rating.value.floor();
                                  final halfStar = index < rating.value &&
                                      index >= rating.value.floor() &&
                                      rating.value % 1 != 0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Stack(
                                        children: [
                                          // 显示星星图标
                                          Icon(
                                            fullStar
                                                ? Icons.star
                                                : halfStar
                                                    ? Icons.star_half
                                                    : Icons.star_border,
                                            color: const Color(0xFFFF4458),
                                            size: 36,
                                          ),
                                          // 左半边点击区域
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            bottom: 0,
                                            width: 18,
                                            child: GestureDetector(
                                              onTap: () {
                                                rating.value = index + 0.5;
                                              },
                                              behavior: HitTestBehavior.opaque,
                                            ),
                                          ),
                                          // 右半边点击区域
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            bottom: 0,
                                            width: 18,
                                            child: GestureDetector(
                                              onTap: () {
                                                rating.value =
                                                    (index + 1).toDouble();
                                              },
                                              behavior: HitTestBehavior.opaque,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              )),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Obx(() => Text(
                                rating.value == 0
                                    ? 'Tap to rate'
                                    : '${rating.value.toStringAsFixed(1)}/5 stars',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              )),
                        ),
                        const SizedBox(height: 20),
                        // Title input
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'Enter review title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF4458),
                                width: 2,
                              ),
                            ),
                          ),
                          maxLength: 100,
                        ),
                        const SizedBox(height: 16),
                        // Content input
                        TextField(
                          controller: contentController,
                          decoration: InputDecoration(
                            labelText: 'Content',
                            hintText: 'Share your experience...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF4458),
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 5,
                          maxLength: 500,
                        ),
                        const SizedBox(height: 16),
                        // Images section
                        Row(
                          children: [
                            const Text(
                              'Photos (Max 5)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Obx(() => Text(
                                  '${selectedImages.length}/5',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Image grid
                        Obx(() => Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...selectedImages.map((image) => Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image:
                                                  FileImage(File(image.path)),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () =>
                                                selectedImages.remove(image),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                if (selectedImages.length < 5)
                                  GestureDetector(
                                    onTap: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final List<XFile> images =
                                          await picker.pickMultiImage(
                                        maxWidth: 1920,
                                        maxHeight: 1080,
                                        imageQuality: 85,
                                      );

                                      final remainingSlots =
                                          5 - selectedImages.length;
                                      final imagesToAdd =
                                          images.take(remainingSlots).toList();
                                      selectedImages.addAll(imagesToAdd);
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFFF4458),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.add_photo_alternate,
                                        color: Color(0xFFFF4458),
                                        size: 32,
                                      ),
                                    ),
                                  ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (rating.value == 0) {
                            Get.snackbar(
                              'Error',
                              'Please select a rating',
                              backgroundColor: const Color(0xFFFF4458),
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (titleController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter a title',
                              backgroundColor: const Color(0xFFFF4458),
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (contentController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter content',
                              backgroundColor: const Color(0xFFFF4458),
                              colorText: Colors.white,
                            );
                            return;
                          }

                          Get.back();
                          // TODO: 提交评论到服务器
                          Get.snackbar(
                            'Success',
                            'Review submitted!\\nRating: ${rating.value.toStringAsFixed(1)}/5\\nTitle: ${titleController.text}\\nContent: ${contentController.text}\\nImages: ${selectedImages.length}',
                            backgroundColor: const Color(0xFF10B981),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4458),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 分享费用信息
  void _showShareCostDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_money,
                  color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Share Cost Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Help others by sharing your living costs in ${widget.cityName}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Cost submission feature will be available soon!',
                      backgroundColor: const Color(0xFFFF4458),
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Share Costs'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享照片
  void _showSharePhotoDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_camera,
                  color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Upload Photos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your favorite photos from ${widget.cityName}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF4458),
                        side: const BorderSide(color: Color(0xFFFF4458)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4458),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // TODO: 上传图片到服务器
        Get.snackbar(
          'Success',
          'Photo selected: ${image.name}\nUpload feature coming soon!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: const Color(0xFFFF4458),
        colorText: Colors.white,
      );
    }
  }

  /// 添加 Coworking Space
  void _showAddCoworkingPage() async {
    final result = await Get.to(() => AddCoworkingPage(
          cityName: widget.cityName,
          cityId: widget.cityId,
        ));
    if (result != null) {
      Get.snackbar(
        '✅ Success',
        'Your coworking space will be reviewed and added soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Build map view widget
  Widget _buildMapView() {
    // 只在页面活动且当前显示地图页面时才创建地图
    if (!_isPageActive || _currentPage != 1) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100],
        child: const Center(
          child: Text(
            'Swipe to view map',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (Platform.isAndroid) {
      // Android: 使用原生高德地图 (Hybrid Composition 模式)
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100], // 地图背景色
        child: PlatformViewLink(
          viewType: 'amap_city_view',
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<
                  OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            print(
                '🗺️ Creating Amap view for ${widget.cityName} (id: ${params.id})');
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'amap_city_view',
              layoutDirection: TextDirection.ltr,
              creationParams: {
                'cityName': widget.cityName,
              },
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener((int id) {
                print(
                    '✅ Amap view created with id: $id for ${widget.cityName}');
              })
              ..create();
          },
        ),
      );
    } else {
      // iOS 或其他平台: 显示占位符
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[100]!,
              Colors.grey[200]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Grid pattern background
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
            // Map content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Location icon with animation
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF4458).withOpacity(0.1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on,
                        size: 60,
                        color: Color(0xFFFF4458),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // City name
                  Text(
                    widget.cityName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Map view (iOS)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Build page indicator
  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// 分享社区信息
}

// SliverAppBarDelegate for pinned tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

/// Grid painter for map background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
