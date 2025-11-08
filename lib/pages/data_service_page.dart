import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/data_service_controller.dart';
import '../features/meetup/domain/entities/meetup.dart';
import '../features/meetup/infrastructure/repositories/meetup_repository.dart';
import '../features/meetup/presentation/controllers/meetup_state_controller.dart';
import '../features/user/presentation/controllers/user_state_controller.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';
import '../widgets/app_toast.dart';
import '../widgets/copyright_widget.dart';
import 'city_detail_page.dart';
import 'create_meetup_page.dart';
import 'global_map_page.dart';

class DataServicePage extends StatefulWidget {
  final bool scrollToCities;

  const DataServicePage({super.key, this.scrollToCities = false});

  @override
  State<DataServicePage> createState() => _DataServicePageState();
}

class _DataServicePageState extends State<DataServicePage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _citiesListKey = GlobalKey();
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);
    // 监听搜索框内容变化以更新清除按钮
    _searchController.addListener(() {
      setState(() {}); // 触发重建以显示/隐藏清除按钮
    });
  }

  @override
  void dispose() {
    // 移除生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 当应用回到前台时刷新数据
    if (state == AppLifecycleState.resumed) {
      print('📱 应用回到前台,刷新首页数据');
      final controller = Get.find<DataServiceController>();
      controller.refreshData();
    }
  }

  // 页面回退时的刷新逻辑会在路由导航时处�?
  // 我们在每次页面可见时都刷新数�?
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 检查页面是否从其他页面回退
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // 延迟执行，避免在build过程中调�?
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 只在非首次加载时刷新（首次加载已经在controller初始化时执行�?
        final controller = Get.find<DataServiceController>();
        if (controller.dataItems.isNotEmpty || controller.meetups.isNotEmpty) {
          print('🔄 页面回到前台,刷新数据');
          controller.refreshData();
        }
      });
    }
  }

  /// 检查登录状态，未登录则跳转到登录页
  bool _checkLoginAndNavigate(VoidCallback onLoggedIn) {
    final userStateController = Get.find<UserStateController>();

    print('🔒 DataServicePage: 检查登录状态');
    print('   当前登录状态: ${userStateController.isLoggedIn}');

    if (!userStateController.isLoggedIn) {
      print('�?用户未登录，跳转到登录页');
      AppToast.info(
        'Please login to access this feature',
        title: 'Login Required',
      );
      Get.toNamed(AppRoutes.login);
      return false;
    }

    print('�?用户已登录，执行操作');
    onLoggedIn();
    return true;
  }

  void _scrollToCitiesList() {
    if (_hasScrolled) return;
    _hasScrolled = true;

    // 等待布局完成后滚�?
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
    // 使用 Get.find() 获取已经初始化的 Controller，而不是创建新实例
    final DataServiceController controller = Get.find<DataServiceController>();
    final MeetupStateController meetupController =
        Get.find<MeetupStateController>();
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Builder(builder: (context) {
        // 数据加载完成，如果需要滚动则执行滚动
        if (widget.scrollToCities && !_hasScrolled) {
          _scrollToCitiesList();
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Hero区域 - Nomads.com风格
            SliverToBoxAdapter(
              child: _buildHeroSection(isMobile, l10n),
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

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

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
                child: _buildMeetupsSection(
                    controller, meetupController, isMobile),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),

            // 特性列�?
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
  Widget _buildHeroSection(bool isMobile, AppLocalizations l10n) {
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
                  // Logo和标题区�?
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
                        l10n.goNomad,
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

                  // 副标�?
                  Text(
                    l10n.joinGlobalCommunity,
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
                    l10n.livingTravelingWorld,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: isMobile ? 32 : 40),

                  // 三个服务卡片
                  _buildServiceCards(isMobile, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 紧凑型服务卡�?- 响应式网格布局
  Widget _buildServiceCards(bool isMobile, AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据屏幕宽度决定布局
    // 超小�?<400px): 2�?�?
    // 小屏(400-768px): 2�?�?
    // 中屏(768-1024px): 4�?�?
    // 大屏(>1024px): 4�?�?
    final isVerySmall = screenWidth < 400;
    final useGridLayout = screenWidth < 768;

    if (useGridLayout) {
      // 2x2 网格布局
      return Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // 第一�? Cities + Coworkings
            Row(
              children: [
                Expanded(
                  child: _buildCompactCard(
                    isMobile: true,
                    icon: Icons.location_city_rounded,
                    title: l10n.cities,
                    color: const Color(0xFFFF4458),
                    onTap: () => _checkLoginAndNavigate(
                        () => Get.toNamed(AppRoutes.cityList)),
                    isCompact: isVerySmall,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactCard(
                    isMobile: true,
                    icon: Icons.business_center_rounded,
                    title: l10n.coworks,
                    color: const Color(0xFF6366F1),
                    onTap: () => _checkLoginAndNavigate(
                        () => Get.toNamed(AppRoutes.coworking)),
                    isCompact: isVerySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第二�? Meetups + Innovation
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildCompactCard(
                        isMobile: true,
                        icon: Icons.groups_rounded,
                        title: l10n.meetups,
                        color: const Color(0xFF10B981),
                        onTap: () => _checkLoginAndNavigate(
                            () => Get.toNamed(AppRoutes.meetupsList)),
                        isCompact: isVerySmall,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildCompactCard(
                        isMobile: true,
                        icon: Icons.lightbulb_outline,
                        title: l10n.innovation,
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _checkLoginAndNavigate(
                            () => Get.toNamed(AppRoutes.innovation)),
                        isCompact: isVerySmall,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // 1x4 横向布局(桌面�?
      return Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cities
            Expanded(
              child: _buildCompactCard(
                isMobile: false,
                icon: Icons.location_city_rounded,
                title: l10n.cities,
                color: const Color(0xFFFF4458),
                onTap: () => _checkLoginAndNavigate(
                    () => Get.toNamed(AppRoutes.cityList)),
              ),
            ),

            const SizedBox(width: 12),

            // Coworkings
            Expanded(
              child: _buildCompactCard(
                isMobile: false,
                icon: Icons.business_center_rounded,
                title: l10n.coworks,
                color: const Color(0xFF6366F1),
                onTap: () => _checkLoginAndNavigate(
                    () => Get.toNamed(AppRoutes.coworking)),
              ),
            ),

            const SizedBox(width: 12),

            // Meetups
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return _buildCompactCard(
                    isMobile: false,
                    icon: Icons.groups_rounded,
                    title: l10n.meetups,
                    color: const Color(0xFF10B981),
                    onTap: () => _checkLoginAndNavigate(
                        () => Get.toNamed(AppRoutes.meetupsList)),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // Innovation
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return _buildCompactCard(
                    isMobile: false,
                    icon: Icons.lightbulb_outline,
                    title: l10n.innovation,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => _checkLoginAndNavigate(
                        () => Get.toNamed(AppRoutes.innovation)),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  // 紧凑型卡片组�?
  Widget _buildCompactCard({
    required bool isMobile,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 16 : (isMobile ? 20 : 24),
          horizontal: isCompact ? 12 : (isMobile ? 16 : 20),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 10 : 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isCompact ? 28 : (isMobile ? 32 : 36),
              ),
            ),
            SizedBox(height: isCompact ? 8 : (isMobile ? 12 : 14)),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 12 : (isMobile ? 13 : 15),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 底部特性亮点列�?
  Widget _buildFeatureHighlights(bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {
        'icon': '🏆',
        'text': l10n.attendMeetupsInCities,
      },
      {
        'icon': '❤️',
        'text': l10n.meetNewPeople,
      },
      {
        'icon': '📊',
        'text': l10n.researchDestinations,
      },
      {
        'icon': '🌍',
        'text': l10n.keepTrackTravels,
      },
      {
        'icon': '💬',
        'text': l10n.joinCommunityChat,
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

  // 工具栏 - 只保留地图功能
  Widget _buildToolbar(DataServiceController controller) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.popular,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        // 全球地图按钮
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.mapLocationDot,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: () {
            Get.to(() => const GlobalMapPage());
          },
        ),
      ],
    );
  }

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
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search cities...',
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
              onSubmitted: (value) {
                // 按回车键也触发搜索
                if (value.trim().isNotEmpty) {
                  controller.searchCities(value.trim());
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // 搜索按钮
          InkWell(
            onTap: () {
              final searchText = _searchController.text.trim();
              if (searchText.isNotEmpty) {
                controller.searchCities(searchText);
              } else {
                controller.refreshCities();
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // 清除按钮
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                _searchController.clear();
                controller.refreshCities();
                setState(() {}); // 更新 UI
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 数据网格 Sliver
  Widget _buildDataGridSliver(DataServiceController controller, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final items = controller.filteredItems;
      final isGrid = controller.isGridView.value;
      final crossAxisCount = isMobile ? 2 : 4;
      final isLoadingCities = controller.isLoadingCities.value;

      // 显示加载中状态
      if (isLoadingCities) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loading,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 如果城市列表为空，显示空状�?
      if (items.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildEmptyCitiesState(isMobile, l10n),
        );
      }

      // 限制最多显�?个城�?(暂时改成6,方便测试)
      final displayItems = items.length > 6 ? items.sublist(0, 6) : items;
      final hasMore = items.length > 6;

      // 调试信息
      debugPrint(
          '城市总数: ${items.length}, 显示�? ${displayItems.length}, 显示按钮: $hasMore');

      if (isGrid) {
        return SliverList(
          delegate: SliverChildListDelegate([
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: isMobile ? 0.68 : 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                return _DataCard(data: displayItems[index]);
              },
            ),
            if (hasMore) ...[
              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _checkLoginAndNavigate(
                      () => Get.toNamed(AppRoutes.cityList)),
                  icon: const Icon(
                    Icons.location_city_outlined,
                    size: 20,
                    color: Color(0xFFFF4458),
                  ),
                  label: Text(
                    l10n.viewAllCities,
                    style: const TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    side: const BorderSide(
                      color: Color(0xFFFF4458),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ]),
        );
      } else {
        return SliverList(
          delegate: SliverChildListDelegate([
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                return _DataListItem(data: displayItems[index]);
              },
            ),
            if (hasMore) ...[
              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _checkLoginAndNavigate(
                      () => Get.toNamed(AppRoutes.cityList)),
                  icon: const Icon(
                    Icons.location_city_outlined,
                    size: 20,
                    color: Color(0xFFFF4458),
                  ),
                  label: Text(
                    l10n.viewAllCities,
                    style: const TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    side: const BorderSide(
                      color: Color(0xFFFF4458),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ]),
        );
      }
    });
  }

  // Meetups 部分 - Nomads.com 风格
  Widget _buildMeetupsSection(DataServiceController controller,
      MeetupStateController meetupController, bool isMobile) {
    return Obx(() {
      final upcomingMeetups = meetupController.upcomingMeetups;
      final isLoadingMeetups = controller.isLoadingMeetups.value;

      // 显示加载中状态
      if (isLoadingMeetups) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                  ),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.loading,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }

      // 如果活动列表为空，显示空状�?
      if (upcomingMeetups.isEmpty) {
        return _buildEmptyMeetupsState(isMobile);
      }

      return Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;

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
                      Text(
                        l10n.nextMeetups,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.upcomingEventsCount(upcomingMeetups.length),
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
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CreateMeetupPage(),
                                      ),
                                    )
                                : () {
                                    AppToast.warning(
                                      l10n.pleaseLoginToCreateMeetup,
                                      title: l10n.loginRequired,
                                    );
                                  },
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                                isMobile ? l10n.create : l10n.createMeetup),
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
                        OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(AppRoutes.meetupsList);
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Color(0xFFFF4458),
                          ),
                          label: Text(
                            l10n.viewAllMeetups,
                            style: const TextStyle(
                              color: Color(0xFFFF4458),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            side: const BorderSide(
                              color: Color(0xFFFF4458),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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

              // 移动端的 View all 按钮
              if (isMobile) ...[
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.toNamed(AppRoutes.meetupsList);
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Color(0xFFFF4458),
                        ),
                        label: Text(
                          l10n.viewAllMeetups,
                          style: const TextStyle(
                            color: Color(0xFFFF4458),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          side: const BorderSide(
                            color: Color(0xFFFF4458),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      );
    });
  }

  // 空城市列表状�?
  Widget _buildEmptyCitiesState(bool isMobile, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: isMobile ? 100 : 120,
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_city_rounded,
              size: isMobile ? 50 : 60,
              color: const Color(0xFFFF4458),
            ),
          ),

          SizedBox(height: isMobile ? 24 : 32),

          // 标题
          Text(
            l10n.noCitiesYet,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // 描述
          Text(
            'Start exploring by adding your first city',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          SizedBox(height: isMobile ? 32 : 40),

          // 添加按钮
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(AppRoutes.cityList);
            },
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(
              l10n.browseCities,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 空活动列表状�?
  Widget _buildEmptyMeetupsState(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: isMobile ? 100 : 120,
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_rounded,
              size: isMobile ? 50 : 60,
              color: const Color(0xFF10B981),
            ),
          ),

          SizedBox(height: isMobile ? 24 : 32),

          // 标题
          Text(
            'No Meetups Available',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // 描述
          Text(
            'Be the first to create a meetup and connect\nwith fellow nomads in your city',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          SizedBox(height: isMobile ? 32 : 40),

          // 添加按钮
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateMeetupPage(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              'Create Meetup',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
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
    final userStateController = Get.find<UserStateController>();
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        // 单击跳转到城市详情页面
        print('🏙️ [DEBUG] City card tapped: ${widget.data}');
        print(
            '🏙️ [DEBUG] cityId will be: ${widget.data['id']?.toString() ?? widget.data['city']?.toString() ?? "EMPTY"}');

        // 检查登录状态
        if (!userStateController.isLoggedIn) {
          AppToast.warning(
            l10n.pleaseLoginToCreateMeetup,
            title: l10n.loginRequired,
          );
          Get.toNamed(AppRoutes.login);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetailPage(
              cityId: widget.data['id']?.toString() ??
                  widget.data['city']?.toString() ??
                  '',
              cityName: widget.data['city']?.toString() ?? 'Unknown City',
              cityImage: widget.data['image']?.toString() ?? '',
              overallScore: (widget.data['overall'] as num?)?.toDouble() ?? 0.0,
              reviewCount: (widget.data['reviews'] as num?)?.toInt() ?? 0,
            ),
          ),
        );
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
                // 顶部：排名、徽章和网�?- 防止溢出
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧：排�?+ 徽章 - 使用 Flexible 防止溢出
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
                      // 右侧：网�?- 移动端简化显�?
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

                // 底部:城市信息
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 城市�?
                        Text(
                          widget.data['city'] ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        // 国家
                        Text(
                          widget.data['country'] ?? '',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isMobile ? 12 : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 4 : 8),
                        // 综合得分
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFFBBF24),
                              size: isMobile ? 16 : 18,
                            ),
                            SizedBox(width: isMobile ? 3 : 4),
                            Text(
                              (widget.data['overall'] as num?)
                                      ?.toStringAsFixed(1) ??
                                  '0.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: isMobile ? 3 : 4),
                            Text(
                              '综合得分',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isMobile ? 11 : 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 4 : 8),
                        // 天气和价�?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 天气信息
                            Row(
                              children: [
                                Text(
                                  _getWeatherIcon(widget.data['weather']),
                                  style:
                                      TextStyle(fontSize: isMobile ? 16 : 18),
                                ),
                                SizedBox(width: isMobile ? 3 : 6),
                                Text(
                                  '${widget.data['temperature'] ?? '--'}°',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 13 : 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            // 价格
                            if (widget.data['price'] != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 6 : 8,
                                  vertical: isMobile ? 3 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '\$${widget.data['price']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 11 : 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
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

  // 获取天气图标
  String _getWeatherIcon(String? weather) {
    if (weather == null) {
      return '☀️';
    }
    final w = weather.toLowerCase();
    if (w.contains('sun') || w.contains('clear')) {
      return '☀️';
    }
    if (w.contains('cloud')) return '☁️';
    if (w.contains('rain')) {
      return '🌧️';
    }
    if (w.contains('storm')) return '⛈️';
    if (w.contains('snow')) return '❄️';
    return '☀️';
  }
}

// 详情悬浮�?- 透明蒙层风格
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
        child: Stack(
          children: [
            // 顶部左侧 - 收藏图标
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            // 顶部右侧 - 关闭按钮
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // 底部 - 评分�?
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMetricBar(
                      '�?Overall', data['overall'], const Color(0xFFFBBF24)),
                  const SizedBox(height: 6),
                  _buildMetricBar(
                      '💰 Cost', data['cost'], const Color(0xFF4ADE80)),
                  const SizedBox(height: 6),
                  _buildMetricBar('📡 Internet', data['internetScore'],
                      const Color(0xFFFBBF24)),
                  const SizedBox(height: 6),
                  _buildMetricBar(
                      '👍 乐趣', data['liked'], const Color(0xFF4ADE80)),
                  const SizedBox(height: 6),
                  _buildMetricBar(
                      '🛡�?Safety', data['safety'], const Color(0xFF4ADE80)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // 背景�?- 深色半透明
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              // 进度�?
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value / 5.0, // �?0-5 分转换为 0-1 比例
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 列表项（列表视图�?
class _DataListItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DataListItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        // 单击跳转到城市详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetailPage(
              cityId: data['id']?.toString() ?? data['city']?.toString() ?? '',
              cityName: data['city']?.toString() ?? 'Unknown City',
              cityImage: data['image']?.toString() ?? '',
              overallScore: (data['score'] as num?)?.toDouble() ?? 0.0,
              reviewCount: (data['reviews'] as num?)?.toInt() ?? 0,
            ),
          ),
        );
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
            // 缩略�?
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
                Text(
                  l10n.perMonth,
                  style: const TextStyle(
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

// Meetup 卡片 - Nomads.com 风格
class _MeetupCard extends StatefulWidget {
  final Meetup meetup;
  final DataServiceController controller;
  final bool isMobile;

  const _MeetupCard({
    required this.meetup,
    required this.controller,
    required this.isMobile,
  });

  @override
  State<_MeetupCard> createState() => _MeetupCardState();
}

class _MeetupCardState extends State<_MeetupCard> {
  // 卡片自己的状�?- 符合 DDD 原则
  late bool _isJoined;

  // 从 widget.meetup 获取最新的参与人数
  int get _currentAttendees {
    return widget.meetup.capacity.currentAttendees;
  }

  int get _maxAttendees {
    return widget.meetup.capacity.maxAttendees;
  }

  @override
  void initState() {
    super.initState();

    // 调试：打印 meetup 数据
    print('🔍 MeetupCard initState:');
    print('   ID: ${widget.meetup.id}');
    print('   Title: ${widget.meetup.title}');
    print('   Attendees: $_currentAttendees / $_maxAttendees');

    // 从 controller 获取初始 joined 状�?
    final meetupIdInt = int.tryParse(widget.meetup.id) ?? 0;
    _isJoined = widget.controller.rsvpedMeetups.contains(meetupIdInt);
    print('   最终状�?_isJoined: $_isJoined');
  }

  @override
  void didUpdateWidget(_MeetupCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当 widget 更新时，检查数据是否变化
    if (oldWidget.meetup.id == widget.meetup.id) {
      // 同一个 meetup，从 controller 更新参与状�?
      final meetupIdInt = int.tryParse(widget.meetup.id) ?? 0;
      final newIsJoined = widget.controller.rsvpedMeetups.contains(meetupIdInt);
      if (_isJoined != newIsJoined) {
        print(
            '🔄 Meetup ${widget.meetup.title} 参与状态更�? $_isJoined -> $newIsJoined');
        setState(() {
          _isJoined = newIsJoined;
        });
      }

      // 参与人数会通过 getter 自动获取最新值，无需手动更新
      print(
          '🔄 Meetup ${widget.meetup.title} 数据更新: $_currentAttendees / $_maxAttendees');
    }
  }

  Future<void> _handleToggleJoin(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final userStateController = Get.find<UserStateController>();

    // 检查登录状�?
    if (!userStateController.isLoggedIn) {
      AppToast.warning(
        l10n.pleaseLoginToCreateMeetup,
        title: l10n.loginRequired,
      );
      Get.toNamed(AppRoutes.login);
      return;
    }

    // 获取 meetup id
    final meetupIdString = widget.meetup.id;
    final meetupIdInt = int.tryParse(meetupIdString) ?? 0;

    final isJoining = !_isJoined;

    try {
      // 使用 MeetupRepository 替代直接调用 API
      final meetupRepository = MeetupRepository();

      if (isJoining) {
        // 加入活动
        await meetupRepository.rsvpToMeetup(meetupIdString);
      } else {
        // 退出活动
        await meetupRepository.cancelRsvp(meetupIdString);
      }

      // API 调用成功，更新全局 rsvpedMeetups 列表
      widget.controller.toggleRSVP(meetupIdInt);

      // 更新卡片自己的状�?
      setState(() {
        _isJoined = isJoining;
      });

      // 显示成功消息
      if (_isJoined) {
        AppToast.success(
          l10n.joinedSuccessfully,
          title: l10n.joined,
        );
      } else {
        AppToast.info(
          l10n.youLeftMeetup,
          title: l10n.leftMeetup,
        );
      }
    } catch (e) {
      print('❌ API 调用失败: $e');
      AppToast.error(
        _isJoined ? '退出活动失败' : '加入活动失败',
        title: '操作失败',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.meetup.schedule.startTime;

    return InkWell(
      onTap: () {
        // TODO: MeetupDetailPage 需要迁移到使用 Meetup 实体
        // Get.to(() => MeetupDetailPage(meetup: widget.meetup));
        AppToast.info('Meetup detail page is under migration');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: widget.isMobile ? 280 : 320,
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
            // 图片和类型标�?
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    widget.meetup.images.isNotEmpty
                        ? widget.meetup.images.first
                        : 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
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
                      color: _getTypeColor(widget.meetup.type.value),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.meetup.type.value,
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
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    widget.meetup.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // 日期、地点、组织�?- 合并为紧凑显�?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期和时�?
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 地点
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.meetup.venue.name.isNotEmpty
                                  ? widget.meetup.venue.name
                                  : widget.meetup.location.city,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 参加人数和组织�?- 合并为一�?
                  Row(
                    children: [
                      // 参加人数
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_currentAttendees',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // 剩余名额
                      if ((_maxAttendees - _currentAttendees) > 0)
                        Text(
                          '${_maxAttendees - _currentAttendees} left',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF4458),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                      // 组织�?
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                widget.meetup.organizer.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Going/RSVP+Chat 按钮逻辑 - 使用本地状�?
                  // 如果已加入，显示 RSVP（已确认状态）+ Join Chat 两个按钮
                  if (_isJoined)
                    Row(
                      children: [
                        // RSVP 按钮（已确认状态，点击可取消）
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () => _handleToggleJoin(context),
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
                                    const EdgeInsets.symmetric(horizontal: 6),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                  ),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'RSVP\'d',
                                      style: TextStyle(
                                        fontSize: 12,
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
                        const SizedBox(width: 6),
                        // Join Chat 按钮
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () {
                                // 跳转到聊天页面并加入该城市的聊天�?
                                // 检查登录状�?
                                final userStateController =
                                    Get.find<UserStateController>();
                                final l10n = AppLocalizations.of(context)!;
                                if (!userStateController.isLoggedIn) {
                                  AppToast.warning(
                                    l10n.pleaseLoginToCreateMeetup,
                                    title: l10n.loginRequired,
                                  );
                                  Get.toNamed(AppRoutes.login);
                                  return;
                                }

                                Get.toNamed(
                                  AppRoutes.cityChat,
                                  arguments: {
                                    'city': widget.meetup.location.city,
                                    'country': widget.meetup.location.country,
                                    'meetupId': widget.meetup.id,
                                    'meetupTitle': widget.meetup.title,
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
                                    const EdgeInsets.symmetric(horizontal: 6),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 14,
                                  ),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'Chat',
                                      style: TextStyle(
                                        fontSize: 12,
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
                    )
                  else
                    // 如果未加入，显示单个 Going 按钮
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _handleToggleJoin(context),
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
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Going',
                              style: TextStyle(
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
            ),
          ],
        ),
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
