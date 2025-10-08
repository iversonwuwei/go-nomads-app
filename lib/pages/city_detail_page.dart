import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/city_detail_controller.dart';

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
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 大图 Banner
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_outlined, color: AppColors.backButtonLight),
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
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF4458),
                ),
              );
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
      {'icon': Icons.favorite, 'label': 'Quality of Life', 'value': scores.qualityOfLife},
      {'icon': Icons.family_restroom, 'label': 'Family Score', 'value': scores.familyScore},
      {'icon': Icons.people, 'label': 'Community', 'value': scores.communityScore},
      {'icon': Icons.security, 'label': 'Safety', 'value': scores.safetyScore},
      {'icon': Icons.female, 'label': 'Women Safety', 'value': scores.womenSafety},
      {'icon': Icons.flag, 'label': 'LGBTQ+ Safety', 'value': scores.lgbtqSafety},
      {'icon': Icons.celebration, 'label': 'Fun', 'value': scores.funScore},
      {'icon': Icons.directions_walk, 'label': 'Walkability', 'value': scores.walkability},
      {'icon': Icons.nightlife, 'label': 'Nightlife', 'value': scores.nightlife},
      {'icon': Icons.language, 'label': 'English Speaking', 'value': scores.englishSpeaking},
      {'icon': Icons.restaurant, 'label': 'Food Safety', 'value': scores.foodSafety},
      {'icon': Icons.wifi, 'label': 'Free WiFi', 'value': scores.freeWiFi},
      {'icon': Icons.laptop, 'label': 'Places to Work', 'value': scores.placesToWork},
      {'icon': Icons.local_hospital, 'label': 'Hospitals', 'value': scores.hospitals},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
              const Text('•', style: TextStyle(fontSize: 18, color: Color(0xFFFF4458))),
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
      padding: const EdgeInsets.all(16),
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
                    const Icon(Icons.arrow_upward, size: 16, color: Color(0xFFFF4458)),
                    Text(
                      '${item.upvotes}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    const Icon(Icons.arrow_upward, size: 16, color: Color(0xFFFF4458)),
                    Text(
                      '${item.upvotes}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(16),
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
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      padding: const EdgeInsets.all(16),
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
    );
  }

  // Weather 标签
  Widget _buildWeatherTab(CityDetailController controller) {
    final weather = controller.weather.value;
    if (weather == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
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
                day.condition == 'rainy' ? Icons.water_drop : Icons.wb_sunny,
                color: day.condition == 'rainy' ? Colors.blue : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('${day.low.toStringAsFixed(0)}° - ${day.high.toStringAsFixed(0)}°'),
            ],
          ),
        )),
      ],
    );
  }

  // Neighborhoods 标签
  Widget _buildNeighborhoodsTab(CityDetailController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.neighborhoods.length,
      itemBuilder: (context, index) {
        final neighborhood = controller.neighborhoods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                        const Icon(Icons.security, size: 16, color: Color(0xFFFF4458)),
                        const SizedBox(width: 4),
                        Text('Safety: ${neighborhood.safetyScore}'),
                        const SizedBox(width: 16),
                        const Icon(Icons.attach_money, size: 16, color: Color(0xFFFF4458)),
                        const SizedBox(width: 4),
                        Text('\$${neighborhood.rentPrice.toStringAsFixed(0)}/mo'),
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
