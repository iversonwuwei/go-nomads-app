import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/data_service_controller.dart';
import '../widgets/copyright_widget.dart';
import '../widgets/skeleton_loader.dart';
import 'city_detail_page.dart';
import 'city_list_page.dart';
import 'coworking_home_page.dart';

class DataServicePage extends StatefulWidget {
  final bool scrollToCities;

  const DataServicePage({super.key, this.scrollToCities = false});

  @override
  State<DataServicePage> createState() => _DataServicePageState();
}

class _DataServicePageState extends State<DataServicePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _citiesListKey = GlobalKey();
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCitiesList() {
    if (_hasScrolled) return;
    _hasScrolled = true;

    // 等待布局完成后滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        final RenderBox? renderBox =
            _citiesListKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && _scrollController.hasClients) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final scrollPosition = _scrollController.position.pixels +
              position -
              100; // 100px offset for better UX

          _scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final DataServiceController controller = Get.put(DataServiceController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonLoader(type: SkeletonType.list);
        }

        // 数据加载完成后,如果需要滚动则执行滚动
        if (widget.scrollToCities && !_hasScrolled) {
          _scrollToCitiesList();
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Hero区域 - Nomads.com风格
            SliverToBoxAdapter(
              child: _buildHeroSection(isMobile),
            ),

            // 搜索和筛选栏
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 20,
                ),
                child: _buildSearchBar(controller, isMobile),
              ),
            ),

            // 视图切换和排序工具栏
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                ),
                child: _buildToolbar(controller),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 城市列表锚点 (用于滚动定位)
            SliverToBoxAdapter(
              child: Container(
                key: _citiesListKey,
                height: 0,
              ),
            ),

            // 数据卡片网格
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
              ),
              sliver: _buildDataGridSliver(controller, isMobile),
            ),

            // 底部间距
            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Meetups 部分 - Nomads.com 风格
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                ),
                child: _buildMeetupsSection(controller, isMobile),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),

            // 特性列表
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: isMobile ? 10 : 20,
                ),
                child: _buildFeatureHighlights(isMobile),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // 版权信息
            const SliverToBoxAdapter(
              child: CopyrightWidget(useTopMargin: false),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      }),
    );
  }

  // Hero区域 - 完全复刻Nomads.com
  Widget _buildHeroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 主要内容
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 48,
                vertical: isMobile ? 40 : 60,
              ),
              child: Column(
                children: [
                  // Logo和标题区域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.public,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Go nomad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 42,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 24 : 32),

                  // 副标题
                  Text(
                    'Join a global community of remote workers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'living and traveling around the world',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: isMobile ? 32 : 48),

                  // 用户头像圈
                  _buildUserAvatars(),

                  SizedBox(height: isMobile ? 40 : 60),

                  // 双梯形按钮组
                  _buildTrapezoidButtons(isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 现代卡片式双按钮组
  Widget _buildTrapezoidButtons(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 600,
      child: Row(
        children: [
          // 左侧卡片 - Cities
          Expanded(
            child: _buildActionCard(
              context: context,
              isMobile: isMobile,
              icon: Icons.location_city_rounded,
              title: 'Cities',
              subtitle: 'Find your perfect nomad destination',
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => Get.to(() => const CityListPage()),
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // 右侧卡片 - Coworking
          Expanded(
            child: _buildActionCard(
              context: context,
              isMobile: isMobile,
              icon: Icons.business_center_rounded,
              title: 'Coworkings',
              subtitle: 'Discover inspiring workspaces',
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => Get.to(() => const CoworkingHomePage()),
            ),
          ),
        ],
      ),
    );
  }

  // 行动卡片组件
  Widget _buildActionCard({
    required BuildContext context,
    required bool isMobile,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isMobile ? 28 : 32,
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // 标题
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // 副标题
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // 箭头按钮
              Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: isMobile ? 18 : 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 底部特性亮点列表
  Widget _buildFeatureHighlights(bool isMobile) {
    final features = [
      {
        'icon': '🏆',
        'text': 'Attend 363 meetups/year in 100+ cities',
      },
      {
        'icon': '❤️',
        'text': 'Meet new people for dating and friends',
      },
      {
        'icon': '📊',
        'text':
            'Research destinations and find your best place to live and work',
      },
      {
        'icon': '🌍',
        'text': 'Keep track of your travels and record where you\'ve been',
      },
      {
        'icon': '💬',
        'text': 'Join community chat and find your community on the road',
      },
    ];

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji 图标
                Text(
                  feature['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                // 文字描述
                Expanded(
                  child: Text(
                    feature['text']!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 15 : 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 用户头像圈
  Widget _buildUserAvatars() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final avatarSize = 40.0; // 每个头像的直径
        final overlapOffset = 14.0; // 重叠偏移量
        final totalWidth = (avatarSize * 8) - (overlapOffset * 7); // 计算总宽度
        final startPosition = (screenWidth - totalWidth) / 2; // 计算起始位置以居中

        return SizedBox(
          height: 50,
          width: screenWidth,
          child: Stack(
            children: List.generate(8, (index) {
              return Positioned(
                left: startPosition + (index * (avatarSize - overlapOffset)),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color.lerp(
                      const Color(0xFF6366F1),
                      const Color(0xFFEC4899),
                      index / 7,
                    ),
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // 工具栏 - 视图切换和排序
  Widget _buildToolbar(DataServiceController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Popular',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            // 筛选按钮 - Nomads.com 风格
            Obx(() => Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: controller.hasActiveFilters
                        ? const Color(0xFFFF4458).withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.hasActiveFilters
                          ? const Color(0xFFFF4458)
                          : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.tune_outlined,
                          color: controller.hasActiveFilters
                              ? const Color(0xFFFF4458)
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => _showFilterDrawer(controller),
                      ),
                      if (controller.hasActiveFilters)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4458),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
            // Grid/List 视图切换
            Obx(() => IconButton(
                  icon: Icon(
                    controller.isGridView.value
                        ? Icons.view_list_outlined
                        : Icons.grid_view_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: controller.toggleView,
                )),
            // 排序
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_outlined,
                  color: AppColors.textSecondary, size: 20),
              onSelected: controller.changeSortBy,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'popular', child: Text('Popular')),
                const PopupMenuItem(value: 'cost', child: Text('Cost')),
                const PopupMenuItem(value: 'internet', child: Text('Internet')),
                const PopupMenuItem(value: 'safety', child: Text('Safety')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 显示筛选抽屉
  void _showFilterDrawer(DataServiceController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterDrawer(controller: controller),
    );
  }

  // 显示创建 Meetup 对话框
  // 搜索栏
  Widget _buildSearchBar(DataServiceController controller, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_outlined,
              color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search or filter',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              // 打开过滤器对话框
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Color(0xFFFF4458), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // 数据网格 Sliver
  Widget _buildDataGridSliver(DataServiceController controller, bool isMobile) {
    return Obx(() {
      final items = controller.filteredItems;
      final isGrid = controller.isGridView.value;
      final crossAxisCount = isMobile ? 2 : 4;

      if (isGrid) {
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 0.68 : 0.72, // 移动端更高一些以容纳所有内容
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _DataCard(data: items[index]);
            },
            childCount: items.length,
          ),
        );
      } else {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _DataListItem(data: items[index]);
            },
            childCount: items.length,
          ),
        );
      }
    });
  }

  // Meetups 部分 - Nomads.com 风格
  Widget _buildMeetupsSection(DataServiceController controller, bool isMobile) {
    return Obx(() {
      final upcomingMeetups = controller.upcomingMeetups;

      if (upcomingMeetups.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next meetups',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${upcomingMeetups.length} upcoming events',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Create Meetup 按钮
                  Obx(() => ElevatedButton.icon(
                        onPressed: controller.isLoggedIn.value
                            ? () => Get.toNamed('/create-meetup')
                            : () {
                                Get.snackbar(
                                  '🔐 Login Required',
                                  'Please login to create a meetup',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(isMobile ? 'Create' : 'Create Meetup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4458),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 8 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )),
                  if (!isMobile) const SizedBox(width: 12),
                  if (!isMobile)
                    TextButton(
                      onPressed: () {
                        // TODO: 导航到完整的 meetups 页面
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: Color(0xFFFF4458),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Meetups 列表（横向滚动）
          SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: upcomingMeetups.length,
              itemBuilder: (context, index) {
                final meetup = upcomingMeetups[index];
                return _MeetupCard(
                  meetup: meetup,
                  controller: controller,
                  isMobile: isMobile,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// 数据卡片（网格视图）
class _DataCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const _DataCard({required this.data});

  @override
  State<_DataCard> createState() => _DataCardState();
}

class _DataCardState extends State<_DataCard> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return GestureDetector(
      onTap: () {
        // 单击跳转到城市详情页面
        Get.to(() => CityDetailPage(
              cityId: widget.data['id']?.toString() ?? '',
              cityName: widget.data['name']?.toString() ?? 'Unknown City',
              cityImage: widget.data['image']?.toString() ?? '',
              overallScore: (widget.data['score'] as num?)?.toDouble() ?? 0.0,
              reviewCount: (widget.data['reviews'] as num?)?.toInt() ?? 0,
            ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: showDetails
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: showDetails ? 0.08 : 0.03),
              blurRadius: showDetails ? 12 : 8,
              offset: Offset(0, showDetails ? 4 : 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.data['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                // 渐变遮罩
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 内容 - 完全复刻 Nomads.com 设计
            Stack(
              children: [
                // 顶部：排名、徽章和网速 - 防止溢出
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧：排名 + 徽章 - 使用 Flexible 防止溢出
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 4 : 6,
                                  vertical: isMobile ? 2 : 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${widget.data['rank']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 10 : 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (widget.data['badge'] != null &&
                                widget.data['badge'].toString().isNotEmpty) ...[
                              SizedBox(width: isMobile ? 3 : 6),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 4 : 6,
                                      vertical: isMobile ? 2 : 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.data['badge'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 8 : 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: isMobile ? 3 : 8),
                      // 右侧：网速 - 移动端简化显示
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 3 : 6,
                            vertical: isMobile ? 2 : 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '📡',
                              style: TextStyle(fontSize: isMobile ? 7 : 10),
                            ),
                            SizedBox(width: isMobile ? 1 : 3),
                            Text(
                              '${widget.data['internet']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 7 : 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 底部：完整的 Nomads.com 信息 - 紧凑布局防止溢出
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 城市名称 - 响应式字体大小
                      Text(
                        widget.data['city'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          height: 1.1,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 国家
                      Text(
                        widget.data['country'],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: isMobile ? 4 : 6),

                      // 5个核心评分图标 - Nomads.com 风格
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildScoreIcon('⭐️', widget.data['overall']),
                          _buildScoreIcon('💵', widget.data['cost']),
                          _buildScoreIcon('📡', widget.data['internetScore']),
                          _buildScoreIcon('👍', widget.data['liked']),
                          _buildScoreIcon('👮', widget.data['safety']),
                        ],
                      ),

                      SizedBox(height: isMobile ? 3 : 5),

                      // 天气行：体感温度 + AQI - 超紧凑布局，防止溢出
                      Row(
                        children: [
                          Icon(
                            _getWeatherIcon(widget.data['weather']),
                            color: Colors.white,
                            size: isMobile ? 10 : 12,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${widget.data['temperature']}°',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 9 : 10,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                  ),
                                ),
                                // 高温标识
                                if (widget.data['feelsLike'] >= 35) ...[
                                  const SizedBox(width: 2),
                                  Text('🥵',
                                      style: TextStyle(
                                          fontSize: isMobile ? 9 : 10,
                                          height: 1)),
                                ],
                              ],
                            ),
                          ),
                          const Spacer(),
                          // AQI
                          if (widget.data['aqi'] != null) ...[
                            Text(
                              'AQI${widget.data['aqi']}',
                              style: TextStyle(
                                color: _getAQIColor(widget.data['aqi']),
                                fontSize: isMobile ? 7 : 9,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            if (widget.data['aqiLevel'] != null &&
                                widget.data['aqiLevel']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(width: 2),
                              Text(
                                widget.data['aqiLevel'],
                                style: TextStyle(
                                    fontSize: isMobile ? 9 : 10, height: 1),
                              ),
                            ],
                          ],
                        ],
                      ),

                      SizedBox(height: isMobile ? 3 : 5),

                      // 价格 - 移动端简化布局
                      Row(
                        children: [
                          Text(
                            '\$${widget.data['price']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 12 : 16,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '/ mo',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 7 : 9,
                              height: 1,
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 4),
                            const Text(
                              'FOR A NOMAD',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                height: 1,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (isMobile) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 8,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Double tap for details',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 6,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // 点击显示详情弹窗
            if (showDetails)
              Positioned.fill(
                child: _DetailOverlay(
                  data: widget.data,
                  onClose: () => setState(() => showDetails = false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny_outlined;
      case 'cloudy':
        return Icons.cloud_outlined;
      case 'rainy':
        return Icons.water_drop_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  // 构建评分图标 - Nomads.com 风格（紧凑版）
  Widget _buildScoreIcon(String emoji, double score) {
    // score 范围 0-5，计算进度条填充比例
    final isGood = score >= 4.0;
    final isMedium = score >= 3.0 && score < 4.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 1.5),
        Container(
          width: 28,
          height: 2.5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 5,
            child: Container(
              decoration: BoxDecoration(
                color: isGood
                    ? Colors.green
                    : isMedium
                        ? Colors.orange
                        : Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 获取 AQI 颜色
  Color _getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }
}

// 详情悬浮层
class _DetailOverlay extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onClose;

  const _DetailOverlay({
    required this.data,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // 阻止点击穿透到下层
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 顶部图标行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 收藏图标
                const Icon(Icons.favorite_border_outlined,
                    color: Colors.white, size: 24),
                // 关闭按钮
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close_outlined,
                      color: Colors.white.withValues(alpha: 0.7), size: 24),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 评分指标
            _buildMetricBar('⭐ Overall', data['overall'], _getColor('overall')),
            const SizedBox(height: 10),
            _buildMetricBar('💰 Cost', data['cost'], _getColor('cost')),
            const SizedBox(height: 10),
            _buildMetricBar(
                '📡 Internet', data['internetScore'], _getColor('internet')),
            const SizedBox(height: 10),
            _buildMetricBar('👍 Liked', data['liked'], _getColor('liked')),
            const SizedBox(height: 10),
            _buildMetricBar('🛡️ Safety', data['safety'], _getColor('safety')),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              // 背景条
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // 进度条
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColor(String metric) {
    switch (metric) {
      case 'overall':
      case 'cost':
      case 'safety':
        return const Color(0xFF4ADE80); // 绿色
      case 'internet':
        return const Color(0xFFEF4444); // 红色
      case 'liked':
        return const Color(0xFFFBBF24); // 黄色
      default:
        return const Color(0xFF4ADE80);
    }
  }
}

// 列表项（列表视图）
class _DataListItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DataListItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 单击跳转到城市详情页面
        Get.to(() => CityDetailPage(
              cityId: data['id']?.toString() ?? '',
              cityName: data['name']?.toString() ?? 'Unknown City',
              cityImage: data['image']?.toString() ?? '',
              overallScore: (data['score'] as num?)?.toDouble() ?? 0.0,
              reviewCount: (data['reviews'] as num?)?.toInt() ?? 0,
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 缩略图
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                data['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['city'],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['country'],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // 价格
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${data['price']}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'per month',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 筛选抽屉 - Nomads.com 风格
class _FilterDrawer extends StatelessWidget {
  final DataServiceController controller;

  const _FilterDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部栏
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.resetFilters();
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Color(0xFFFF4458),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 筛选选项（可滚动）
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 地区筛选
                  _buildSectionTitle('Region'),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.availableRegions.map((region) {
                          final isSelected =
                              controller.selectedRegions.contains(region);
                          return FilterChip(
                            label: Text(region),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedRegions.add(region);
                              } else {
                                controller.selectedRegions.remove(region);
                              }
                            },
                            selectedColor:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 24),

                  // 价格筛选
                  _buildSectionTitle('Monthly Cost'),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${controller.minPrice.value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '\$${controller.maxPrice.value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: RangeValues(
                              controller.minPrice.value,
                              controller.maxPrice.value,
                            ),
                            min: 0,
                            max: 5000,
                            divisions: 50,
                            activeColor: const Color(0xFFFF4458),
                            inactiveColor: AppColors.borderLight,
                            onChanged: (values) {
                              controller.minPrice.value = values.start;
                              controller.maxPrice.value = values.end;
                            },
                          ),
                        ],
                      )),

                  const SizedBox(height: 24),

                  // 网速筛选
                  _buildSectionTitle('Minimum Internet Speed'),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${controller.minInternet.value.toInt()} Mbps',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Slider(
                            value: controller.minInternet.value,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            activeColor: const Color(0xFFFF4458),
                            inactiveColor: AppColors.borderLight,
                            onChanged: (value) {
                              controller.minInternet.value = value;
                            },
                          ),
                        ],
                      )),

                  const SizedBox(height: 24),

                  // 评分筛选
                  _buildSectionTitle('Minimum Overall Rating'),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                controller.minRating.value.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '⭐️',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Slider(
                            value: controller.minRating.value,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            activeColor: const Color(0xFFFF4458),
                            inactiveColor: AppColors.borderLight,
                            onChanged: (value) {
                              controller.minRating.value = value;
                            },
                          ),
                        ],
                      )),

                  const SizedBox(height: 24),

                  // 气候筛选
                  _buildSectionTitle('Climate'),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.availableClimates.map((climate) {
                          final isSelected =
                              controller.selectedClimates.contains(climate);
                          return FilterChip(
                            label: Text(climate),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedClimates.add(climate);
                              } else {
                                controller.selectedClimates.remove(climate);
                              }
                            },
                            selectedColor:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 24),

                  // AQI筛选
                  _buildSectionTitle('Maximum Air Quality Index'),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'AQI ${controller.maxAqi.value}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getAQILabel(controller.maxAqi.value),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: controller.maxAqi.value.toDouble(),
                            min: 0,
                            max: 500,
                            divisions: 10,
                            activeColor: const Color(0xFFFF4458),
                            inactiveColor: AppColors.borderLight,
                            onChanged: (value) {
                              controller.maxAqi.value = value.toInt();
                            },
                          ),
                        ],
                      )),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 底部应用按钮
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Obx(() {
              final count = controller.filteredItems.length;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Show $count ${count == 1 ? 'city' : 'cities'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _getAQILabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}

// Meetup 卡片 - Nomads.com 风格
class _MeetupCard extends StatelessWidget {
  final Map<String, dynamic> meetup;
  final DataServiceController controller;
  final bool isMobile;

  const _MeetupCard({
    required this.meetup,
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final date = meetup['date'] as DateTime;
    final attendees = meetup['attendees'] as int;
    final maxAttendees = meetup['maxAttendees'] as int;
    final spotsLeft = maxAttendees - attendees;

    return Container(
      width: isMobile ? 280 : 320,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片和类型标签
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  meetup['image'],
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(meetup['type']),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    meetup['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 城市和日期
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meetup['city'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 标题
                Text(
                  meetup['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // 参加人数
                Row(
                  children: [
                    // 头像堆叠
                    SizedBox(
                      height: 24,
                      width: 60,
                      child: Stack(
                        children: List.generate(
                          3,
                          (index) => Positioned(
                            left: index * 15.0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/150?img=${index + 10}',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$attendees going',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (spotsLeft > 0)
                      Text(
                        '$spotsLeft spots left',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF4458),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // RSVP 按钮或 Going/Join Chat 按钮
                Obx(() {
                  final isRSVPed =
                      controller.rsvpedMeetups.contains(meetup['id']);

                  // 如果已 RSVP，显示两个按钮
                  if (isRSVPed) {
                    return Row(
                      children: [
                        // Going 按钮
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () =>
                                  controller.toggleRSVP(meetup['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF4458),
                                elevation: 0,
                                side: const BorderSide(
                                  color: Color(0xFFFF4458),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Going',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Join Chat 按钮
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {
                                // 跳转到聊天页面并加入该城市的聊天室
                                Get.toNamed(
                                  '/city-chat',
                                  arguments: {
                                    'city': meetup['city'],
                                    'country': meetup['country'],
                                    'meetupId': meetup['id'],
                                    'meetupTitle': meetup['title'],
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4458),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Join Chat',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // 如果未 RSVP，显示单个 RSVP 按钮
                  return SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => controller.toggleRSVP(meetup['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4458),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'RSVP',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Drinks':
        return const Color(0xFFFF4458);
      case 'Coworking':
        return const Color(0xFF6366F1);
      case 'Dinner':
        return const Color(0xFFEC4899);
      case 'Activity':
        return const Color(0xFF10B981);
      case 'Workshop':
        return const Color(0xFFF59E0B);
      case 'Networking':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
