import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../config/app_colors.dart';
import '../controllers/city_detail_controller.dart';
import '../controllers/coworking_controller.dart';
import '../generated/app_localizations.dart';
import '../models/coworking_space_model.dart';
import '../models/user_city_content_models.dart';
import '../services/user_city_content_api_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/skeletons/skeletons.dart';
import 'add_cost_page.dart';
import 'add_coworking_page.dart';
import 'add_review_page.dart';
import 'coworking_detail_page.dart';
import 'create_travel_plan_page.dart';
import 'hotel_list_page.dart';

/// 城市详情�?- 完整�?Nomads.com 风格标签页系�?
class CityDetailPage extends StatefulWidget {
  final String cityId;
  final String cityName;
  final String cityImage;
  final double overallScore;
  final int reviewCount;

  const CityDetailPage({
    super.key,
    this.cityId = '',
    this.cityName = '',
    this.cityImage = '',
    this.overallScore = 0.0,
    this.reviewCount = 0,
  });

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  late PageController _pageController;
  int _currentPage = 0;

  // �?Get.arguments 或构造函数获取参�?
  late final String cityId;
  late final String cityName;
  late final String cityImage;
  late final double overallScore;
  late final int reviewCount;

  @override
  void initState() {
    super.initState();

    // 优先从 Get.arguments 获取参数,如果没有则使用构造函数参数
    final args = Get.arguments as Map<String, dynamic>?;
    cityId = args?['cityId'] ?? widget.cityId;
    cityName = args?['cityName'] ?? widget.cityName;
    cityImage = args?['cityImage'] ?? widget.cityImage;
    overallScore = args?['overallScore'] ?? widget.overallScore;
    reviewCount = args?['reviewCount'] ?? widget.reviewCount;

    _pageController = PageController();
  }

  // 获取城市展示图片列表
  List<String> _getCityImages() {
    // 基于城市主图片生成多张展示图�?
    // 使用不同的Unsplash参数来获取该城市的不同视角图�?
    final baseImage = cityImage;

    // 如果主图片是Unsplash链接，生成系列图�?
    if (baseImage.contains('unsplash.com')) {
      // 提取图片ID
      final uri = Uri.parse(baseImage);
      final photoId = uri.pathSegments
          .lastWhere(
            (segment) => segment.startsWith('photo-'),
            orElse: () => 'photo-default',
          )
          .replaceAll('photo-', '');

      return [
        baseImage, // 主图�?
        'https://images.unsplash.com/$photoId?w=800&h=600&fit=crop&crop=entropy&q=80',
        'https://images.unsplash.com/$photoId?w=800&h=600&fit=crop&crop=edges&q=80',
        'https://images.unsplash.com/$photoId?w=800&h=600&fit=crop&crop=faces&q=80',
      ];
    }

    // 如果不是Unsplash，返回主图片和一些通用城市图片
    return [
      baseImage,
      'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
      'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800',
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    print('🗑�?City detail page disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.put(CityDetailController());
    // ✅ 使用城市 UUID 作为 cityId (后端 user_city_content API 需要 UUID)
    controller.currentCityId.value = cityId; // ✅ 修复:使用 UUID 而不是 cityName
    controller.currentCityName.value = cityName;

    // 加载用户内容
    controller.loadUserContent();

    return DefaultTabController(
      length:
          10, // 10个标�?Scores, Guide, Pros&Cons, Reviews, Cost, Photos, Weather, Hotels, Neighborhoods, Coworking)
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
                          // PageView carousel - 城市图片轮播
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: _getCityImages().length,
                            itemBuilder: (context, index) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  // 城市图片
                                  Image.network(
                                    _getCityImages()[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: const Color(0xFFFF4458),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // 渐变遮罩�?
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          // Page indicators - 动态生�?
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _getCityImages().length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: _buildIndicator(index),
                                  ),
                                ),
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

                  // 标签页导�?
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
                                Text(l10n.scores),
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
                          Tab(text: l10n.guide),
                          Tab(text: l10n.prosAndCons),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n.reviews),
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
                                Text(l10n.cost),
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
                                Text(l10n.photos),
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
                          Tab(text: l10n.weather),
                          Tab(text: l10n.hotels),
                          Tab(text: l10n.neighborhoods),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n.coworking),
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
                  return const CityDetailSkeleton();
                }

                return TabBarView(
                  children: [
                    _buildScoresTab(context, controller),
                    _buildGuideTab(controller),
                    _buildProsConsTab(controller),
                    _buildReviewsTab(controller),
                    _buildCostTab(controller),
                    _buildPhotosTab(controller),
                    _buildWeatherTab(controller),
                    _buildHotelsTab(controller),
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
                    // 跳转到创建旅行计划页�?
                    Get.to(
                      () => CreateTravelPlanPage(
                        cityId: cityId,
                        cityName: cityName,
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
  Widget _buildScoresTab(
      BuildContext context, CityDetailController controller) {
    final l10n = AppLocalizations.of(context)!;
    final scores = controller.scores.value;
    if (scores == null) {
      return Center(child: Text(l10n.noData));
    }

    final scoreItems = [
      {'icon': Icons.star, 'label': l10n.overall, 'value': scores.overall},
      {
        'icon': Icons.favorite,
        'label': l10n.qualityOfLife,
        'value': scores.qualityOfLife
      },
      {
        'icon': Icons.family_restroom,
        'label': l10n.familyScore,
        'value': scores.familyScore
      },
      {
        'icon': Icons.people,
        'label': l10n.community,
        'value': scores.communityScore
      },
      {
        'icon': Icons.security,
        'label': l10n.safety,
        'value': scores.safetyScore
      },
      {
        'icon': Icons.female,
        'label': l10n.womenSafety,
        'value': scores.womenSafety
      },
      {
        'icon': Icons.flag,
        'label': l10n.lgbtqSafety,
        'value': scores.lgbtqSafety
      },
      {'icon': Icons.celebration, 'label': l10n.fun, 'value': scores.funScore},
      {
        'icon': Icons.directions_walk,
        'label': l10n.walkability,
        'value': scores.walkability
      },
      {
        'icon': Icons.nightlife,
        'label': l10n.nightlife,
        'value': scores.nightlife
      },
      {
        'icon': Icons.language,
        'label': l10n.englishSpeaking,
        'value': scores.englishSpeaking
      },
      {
        'icon': Icons.restaurant,
        'label': l10n.foodSafety,
        'value': scores.foodSafety
      },
      {'icon': Icons.wifi, 'label': l10n.freeWiFi, 'value': scores.freeWiFi},
      {
        'icon': Icons.laptop,
        'label': l10n.placesToWork,
        'value': scores.placesToWork
      },
      {
        'icon': Icons.local_hospital,
        'label': l10n.hospitals,
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
      return Center(child: Text(AppLocalizations.of(context)!.loadingGuide));
    }

    return _buildGuideContent(context, guide);
  }

  Widget _buildGuideContent(BuildContext context, guide) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        Text(
          l10n.overview,
          style: const TextStyle(
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
                  const Text('💡',
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
    return Obx(() {
      final realUserReviews = controller.userReviews; // ✅ 只使用后端真实评论

      // 如果正在加载
      if (controller.isLoadingUserContent.value && realUserReviews.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // 如果为空
      if (realUserReviews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rate_review, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No reviews yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to write a review!',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshReviews,
        child: ListView.builder(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
          itemCount: realUserReviews.length, // ✅ 只显示真实评论
          itemBuilder: (context, index) {
            final review = realUserReviews[index]; // ✅ 直接使用真实评论
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                        // ✅ 有头像显示头像,没有头像显示用户名首字母
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFF4458),
                          backgroundImage: review.userAvatar != null &&
                                  review.userAvatar!.isNotEmpty
                              ? NetworkImage(review.userAvatar!)
                              : null,
                          child: review.userAvatar == null ||
                                  review.userAvatar!.isEmpty
                              ? Text(
                                  review.username.isNotEmpty
                                      ? review.username
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                review.username, // ✅ 使用真实用户名
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                if (review.visitDate != null)
                                  Text(
                                    'Visited ${_formatDate(review.visitDate!)}',
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
                    // ✅ 始终显示图片区域（有图显示图片，无图显示占位符）
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: review.photoUrls.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: review.photoUrls.length,
                              itemBuilder: (context, photoIndex) {
                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          review.photoUrls[photoIndex]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                            ),
                    ),
                      const SizedBox(height: 8),
                      Text(
                        'Posted ${_formatDate(review.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
            );
          },
        ),
      );
    });
  }

  // Cost of Living 标签
  Widget _buildCostTab(CityDetailController controller) {
    return Obx(() {
      final communityCost = controller.communityCostSummary.value; // ✅ 使用后端真实数据

      // 如果数据还在加载中
      if (controller.isLoadingUserContent.value && communityCost == null) {
        return const Center(child: CircularProgressIndicator());
      }

      // 使用默认值（如果为 null）
      final total = communityCost?.total ?? 0.0;
      final contributorCount = communityCost?.contributorCount ?? 0;
      final totalExpenseCount = communityCost?.totalExpenseCount ?? 0;
      final accommodation = communityCost?.accommodation ?? 0.0;
      final food = communityCost?.food ?? 0.0;
      final transportation = communityCost?.transportation ?? 0.0;
      final activity = communityCost?.activity ?? 0.0;
      final shopping = communityCost?.shopping ?? 0.0;
      final other = communityCost?.other ?? 0.0;

      return ListView(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        children: [
          // ✅ 社区综合费用统计 - 始终显示
          Row(
            children: [
              const Flexible(
                child: Text(
                  'Community Cost Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$contributorCount contributor${contributorCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Average Community Cost',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on $totalExpenseCount real expense${totalExpenseCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 费用分类明细 - 始终显示所有分类（即使为 0）
          _buildCostCategoryCard(
            category: 'Accommodation',
            amount: accommodation,
            icon: Icons.hotel,
            color: Colors.purple,
          ),
          _buildCostCategoryCard(
            category: 'Food',
            amount: food,
            icon: Icons.restaurant,
            color: Colors.orange,
          ),
          _buildCostCategoryCard(
            category: 'Transportation',
            amount: transportation,
            icon: Icons.directions_car,
            color: Colors.blue,
          ),
          _buildCostCategoryCard(
            category: 'Activity',
            amount: activity,
            icon: Icons.local_activity,
            color: Colors.green,
          ),
          _buildCostCategoryCard(
            category: 'Shopping',
            amount: shopping,
            icon: Icons.shopping_bag,
            color: Colors.pink,
          ),
          _buildCostCategoryCard(
            category: 'Other',
            amount: other,
            icon: Icons.more_horiz,
            color: Colors.grey,
          ),
          const SizedBox(height: 32),
        ], // children 数组闭合
      ); // ListView 闭合
    }); // Obx 闭合
  }

  // 费用分类卡片 - 参照 Recent Community Expenses 的设计
  Widget _buildCostCategoryCard({
    required String category,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF4458),
          ),
        ),
      ),
    );
  }

  // Photos 标签
  Widget _buildPhotosTab(CityDetailController controller) {
    return Obx(() {
      final realUserPhotos = controller.userPhotos; // ✅ 只使用后端真实照片

      // 如果正在加载
      if (controller.isLoadingUserContent.value && realUserPhotos.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // 如果为空
      if (realUserPhotos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No photos yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share a photo!',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshPhotos,
        child: GridView.builder(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: realUserPhotos.length, // ✅ 只显示真实照片
          itemBuilder: (context, index) {
            final photo = realUserPhotos[index]; // ✅ 直接使用真实照片
              return GestureDetector(
                onTap: () => _showPhotoDetail(photo),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(photo.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // 用户头像标识
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
              ),
            );
          },
        ),
      );
    });
  }

  /// 显示照片详情对话框
  void _showPhotoDetail(UserCityPhoto photo) {
    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 照片
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                photo.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // 信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo.caption != null) ...[
                    Text(
                      photo.caption!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (photo.location != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          photo.location!,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Uploaded ${_formatDate(photo.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Weather 标签
  Widget _buildWeatherTab(CityDetailController controller) {
    final weather = controller.weather.value;
    final l10n = AppLocalizations.of(context)!;
    if (weather == null) {
      return Center(child: Text(l10n.noData));
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
                '${l10n.feelsLike} ${weather.feelsLike.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.sevenDayForecast,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        Text(
                            '${AppLocalizations.of(context)!.safety}: ${neighborhood.safetyScore}'),
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

  /// Coworking 标签�?
  Widget _buildCoworkingTab(CityDetailController controller) {
    final coworkingController = Get.put(CoworkingController());

    // 延迟执行筛�?避免�?build 期间修改状�?
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coworkingController.filterByCity(cityName);
    });

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
                  // 名称和评�?
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

  // Hotels Tab - 显示城市的酒店列表
  Widget _buildHotelsTab(CityDetailController controller) {
    final parsedCityId = int.tryParse(cityId);
    print(
        '🏨 Hotels Tab - cityId: $cityId, parsed: $parsedCityId, cityName: $cityName');

    return HotelListPage(
      cityId: parsedCityId,
      cityName: cityName,
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

  // ========== 分享对话框方�?==========

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
                    AppToast.info(
                      'Score submission feature will be available soon!',
                      title: 'Coming Soon',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.startRating),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享指南信息
  /// 分享评论 - 跳转到独立页面
  void _showShareReviewDialog() async {
    final result = await Get.to(() => AddReviewPage(
          cityId: cityId,
          cityName: cityName,
        ));

    // 如果提交成功,刷新评论列表
    if (result != null && result['success'] == true) {
      final controller = Get.find<CityDetailController>();
      controller.loadUserContent();

      print('Review submitted successfully: ${result['review']}');
    }
  }

  /// 分享费用信息
  void _showShareCostDialog() async {
    final result = await Get.to(
      () => AddCostPage(
        cityId: cityId,
        cityName: cityName,
      ),
    );

    // 如果提交成功,刷新费用列表
    if (result != null && result['success'] == true) {
      final controller = Get.find<CityDetailController>();
      controller.loadUserContent();

      print('Expenses submitted successfully: ${result['expenses']}');
    }
  }

  /// 分享照片
  void _showSharePhotoDialog() async {
    // 显示选择对话框
    final source = await Get.dialog<ImageSource>(
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(result: ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)!.camera),
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
                      onPressed: () => Get.back(result: ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: Text(AppLocalizations.of(context)!.gallery),
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

    if (source == null) return;

    await _pickAndUploadImage(source);
  }

  /// 选择并上传图片
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // TODO: 实现图片上传功能
        // 1. 上传图片到存储服务 (Supabase Storage 或 CDN)
        // 2. 获取图片URL
        // 3. 调用 API 保存照片记录

        // 临时实现: 使用占位符 URL
        final apiService = UserCityContentApiService();
        await apiService.addCityPhoto(
          cityId: cityId,
          imageUrl:
              'https://via.placeholder.com/800x600.png?text=${Uri.encodeComponent(image.name)}',
          caption: null,
          location: null,
          takenAt: null,
        );

        // 刷新照片列表
        final controller = Get.find<CityDetailController>();
        await controller.refreshPhotos();

        AppToast.success(
          'Photo uploaded successfully!',
          title: 'Success',
        );
      }
    } catch (e) {
      AppToast.error(
        'Failed to upload photo: $e',
        title: 'Error',
      );
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// 添加 Coworking Space
  void _showAddCoworkingPage() async {
    final result = await Get.to(() => AddCoworkingPage(
          cityName: cityName,
          cityId: cityId,
        ));
    if (result != null) {
      AppToast.success(
        'Your coworking space will be reviewed and added soon!',
        title: 'Success',
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
            : Colors.white.withValues(alpha: 0.4),
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
