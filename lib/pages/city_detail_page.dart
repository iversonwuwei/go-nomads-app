import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/city_detail_controller.dart';
import '../widgets/skeleton_loader.dart';
import 'travel_plan_page.dart';

/// 城市详情页 - 完整的 Nomads.com 风格标签页系统
class CityDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final controller = Get.put(CityDetailController());
    controller.currentCityId.value = cityId;
    controller.currentCityName.value = cityName;

    return DefaultTabController(
      length: 8, // 简化为8个主要标签
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
                        cityName,
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
                          Image.network(
                            cityImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.grey[300]);
                            },
                          ),
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
                                  overallScore.toStringAsFixed(1),
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
                            '$reviewCount reviews',
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
                        tabs: const [
                          Tab(text: 'Scores'),
                          Tab(text: 'Guide'),
                          Tab(text: 'Pros & Cons'),
                          Tab(text: 'Reviews'),
                          Tab(text: 'Cost'),
                          Tab(text: 'Photos'),
                          Tab(text: 'Weather'),
                          Tab(text: 'Neighborhoods'),
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
                  onTap: () => _showTravelPlanDialog(controller),
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

    return Stack(
      children: [
        ListView.builder(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
          itemCount: scoreItems.length,
          itemBuilder: (context, index) {
            final item = scoreItems[index];
            return _buildScoreItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              score: item['value'] as double,
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'scores_add',
            backgroundColor: const Color(0xFFFF4458),
            onPressed: () => _showShareScoreDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
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

    return Stack(
      children: [
        _buildGuideContent(guide),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'guide_add',
            backgroundColor: const Color(0xFFFF4458),
            onPressed: () => _showShareGuideDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideContent(guide) {
    return ListView(
      padding: const EdgeInsets.all(16),
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
    return Stack(
      children: [
        ListView(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
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
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'proscons_add',
            backgroundColor: const Color(0xFFFF4458),
            onPressed: () => _showShareProsConsDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Reviews 标签
  Widget _buildReviewsTab(CityDetailController controller) {
    return Stack(
      children: [
        ListView.builder(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
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
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'reviews_add',
            backgroundColor: const Color(0xFFFF4458),
            onPressed: () => _showShareReviewDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Cost of Living 标签
  Widget _buildCostTab(CityDetailController controller) {
    final cost = controller.costOfLiving.value;
    if (cost == null) {
      return const Center(child: Text('No data'));
    }

    return Stack(
      children: [
        ListView(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
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
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'cost_add',
            backgroundColor: const Color(0xFFFF4458),
            onPressed: () => _showShareCostDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
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
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(8),
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
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'photos_add',
            backgroundColor: const Color(0xFFFF4458),
            onPressed: () => _showSharePhotoDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Weather 标签
  Widget _buildWeatherTab(CityDetailController controller) {
    final weather = controller.weather.value;
    if (weather == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
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
    return Stack(
      children: [
        ListView.builder(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
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
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'neighborhoods_add',
            backgroundColor: const Color(0xFFFF4458),
            onPressed: () => _showShareNeighborhoodDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// 显示旅行计划生成对话框
  void _showTravelPlanDialog(CityDetailController controller) {
    int duration = 7;
    String budget = 'medium';
    String travelStyle = 'culture';
    List<String> interests = [];
    String departureLocation = '';
    bool isLoadingLocation = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFF4458),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Travel Planner',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Generate personalized plan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Departure Location
                    const Text(
                      'Departure Location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter your departure city',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFF4458),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: departureLocation.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          departureLocation = '';
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {
                                departureLocation = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: isLoadingLocation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFF4458),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                    color: Color(0xFFFF4458),
                                  ),
                            onPressed: isLoadingLocation
                                ? null
                                : () async {
                                    setState(() {
                                      isLoadingLocation = true;
                                    });
                                    try {
                                      final permission =
                                          await Geolocator.checkPermission();
                                      if (permission ==
                                              LocationPermission.denied ||
                                          permission ==
                                              LocationPermission
                                                  .deniedForever) {
                                        await Geolocator.requestPermission();
                                      }
                                      final position =
                                          await Geolocator.getCurrentPosition();
                                      // 这里可以使用反向地理编码获取城市名称
                                      // 暂时使用坐标作为位置标识
                                      setState(() {
                                        departureLocation =
                                            'Current Location (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})';
                                      });
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error',
                                        'Failed to get current location',
                                        backgroundColor: Colors.red.shade100,
                                        colorText: Colors.red.shade900,
                                      );
                                    } finally {
                                      setState(() {
                                        isLoadingLocation = false;
                                      });
                                    }
                                  },
                            tooltip: 'Use current location',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tip: Enter your departure city for more accurate travel time and route planning',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Duration
                    const Text(
                      'Trip Duration',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: duration.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '$duration days',
                      activeColor: const Color(0xFFFF4458),
                      onChanged: (value) {
                        setState(() => duration = value.toInt());
                      },
                    ),
                    Text(
                      '$duration days',
                      style: const TextStyle(
                        color: Color(0xFFFF4458),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Budget
                    const Text(
                      'Budget Level',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBudgetChip('Low', budget == 'low', () {
                            setState(() => budget = 'low');
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBudgetChip('Medium', budget == 'medium',
                              () {
                            setState(() => budget = 'medium');
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBudgetChip('High', budget == 'high', () {
                            setState(() => budget = 'high');
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Travel Style
                    const Text(
                      'Travel Style',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStyleChip(
                            'Culture', Icons.museum, travelStyle == 'culture',
                            () {
                          setState(() => travelStyle = 'culture');
                        }),
                        _buildStyleChip('Adventure', Icons.hiking,
                            travelStyle == 'adventure', () {
                          setState(() => travelStyle = 'adventure');
                        }),
                        _buildStyleChip('Relaxation', Icons.spa,
                            travelStyle == 'relaxation', () {
                          setState(() => travelStyle = 'relaxation');
                        }),
                        _buildStyleChip('Nightlife', Icons.nightlife,
                            travelStyle == 'nightlife', () {
                          setState(() => travelStyle = 'nightlife');
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Interests
                    const Text(
                      'Interests (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Food',
                        'Shopping',
                        'Photography',
                        'History',
                        'Nature',
                        'Art'
                      ]
                          .map((interest) => FilterChip(
                                label: Text(interest),
                                selected: interests.contains(interest),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      interests.add(interest);
                                    } else {
                                      interests.remove(interest);
                                    }
                                  });
                                },
                                selectedColor: const Color(0xFFFF4458)
                                    .withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFFFF4458),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.to(
                            () => TravelPlanPage(
                              cityId: controller.currentCityId.value,
                              cityName: controller.currentCityName.value,
                              duration: duration,
                              budget: budget,
                              travelStyle: travelStyle,
                              interests: interests,
                              departureLocation: departureLocation.isEmpty
                                  ? null
                                  : departureLocation,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4458),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Generate AI Plan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetChip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF4458) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFFF4458) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleChip(
      String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF4458).withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFFF4458) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? const Color(0xFFFF4458) : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFFF4458) : Colors.grey[700],
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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
                'Help the community by rating different aspects of $cityName',
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
  void _showShareGuideDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book, color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Share Your Guide Tips',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Share helpful tips about living in $cityName',
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
                      'Guide submission feature will be available soon!',
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
                  child: const Text('Add Guide Tip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享优缺点
  void _showShareProsConsDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.balance, color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Share Pros & Cons',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Share what you love or dislike about $cityName',
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
                      'Pros & Cons submission feature will be available soon!',
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
                  child: const Text('Add Your Opinion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享评论
  void _showShareReviewDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rate_review, color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Write a Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your experience in $cityName with photos',
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
                      'Review submission feature will be available soon!',
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
                  child: const Text('Write Review'),
                ),
              ),
            ],
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
                'Help others by sharing your living costs in $cityName',
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
                'Share your favorite photos from $cityName',
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
                      'Photo upload feature will be available soon!',
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
                  child: const Text('Upload Photos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享社区信息
  void _showShareNeighborhoodDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_city,
                  color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Share Neighborhood Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Share insights about neighborhoods in $cityName',
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
                      'Neighborhood submission feature will be available soon!',
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
                  child: const Text('Add Neighborhood'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
