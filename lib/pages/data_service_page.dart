import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/core/sync/refreshable_controller.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/repositories/meetup_repository.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

import 'city_detail/city_detail.dart';
import 'create_meetup/create_meetup_page.dart';

class DataServicePage extends StatefulWidget {
  final bool scrollToCities;

  const DataServicePage({super.key, this.scrollToCities = false});

  @override
  State<DataServicePage> createState() => _DataServicePageState();
}

class _DataServicePageState extends State<DataServicePage>
    with WidgetsBindingObserver, RouteAwareRefreshMixin<DataServicePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _citiesListKey = GlobalKey();
  bool _hasScrolled = false;

  // 本地状态管理
  final bool _isGridView = true;

  // 本页面的搜索状态（独立于 CityListPage）
  String _localSearchQuery = '';
  List<City> _localCities = [];
  bool _isLocalSearching = false;

  // 获取领域层的 StateController（延迟初始化，避免在构建时查找）
  CityStateController? _cityControllerCache;
  CityStateController get _cityController {
    _cityControllerCache ??= Get.find<CityStateController>();
    return _cityControllerCache!;
  }

  MeetupStateController? _meetupControllerCache;
  MeetupStateController get _meetupController {
    _meetupControllerCache ??= Get.find<MeetupStateController>();
    return _meetupControllerCache!;
  }

  UserStateController? _userControllerCache;
  UserStateController get _userController {
    _userControllerCache ??= Get.find<UserStateController>();
    return _userControllerCache!;
  }

  @override
  void initState() {
    super.initState();
    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 首页不验证 token，直接加载数据
    // 如果有 token 会自动带上，没有就匿名访问
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('🏠 首页初始化，只加载城市数据（不加载活动）');
      // 只加载城市数据，活动数据按需加载
      _loadHomeCities();
    });

    // 监听控制器数据变化，同步到本地（仅在非搜索状态时）
    ever(_cityController.cities, (cities) {
      if (!_isLocalSearching && mounted) {
        setState(() {
          _localCities = cities.toList();
        });
      }
    });
  }

  /// 加载首页城市数据（不带搜索条件）
  Future<void> _loadHomeCities() async {
    try {
      // 首页加载时，清除控制器的搜索条件，确保加载全部城市
      _cityController.searchQuery.value = '';
      await _cityController.loadInitialCities(refresh: true);
      if (mounted) {
        setState(() {
          _localCities = _cityController.cities.toList();
        });
      }
    } catch (e) {
      log('⚠️ 城市数据加载失败，使用缓存数据: $e');
    }
  }

  @override
  void dispose() {
    // 移除生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _searchController.dispose();
    // 注意：不再清除共享控制器的 searchQuery，每个页面管理自己的搜索状态
    super.dispose();
  }

  /// 当从其他页面返回时，重新加载数据
  @override
  Future<void> onRouteResume() async {
    log('🔄 DataServicePage: 从其他页面返回，重新加载数据');
    _clearSearchOnReturn();

    // 并行加载城市和活动数据
    await Future.wait([
      _loadHomeCities(),
      _refreshMeetups(),
    ]);
  }

  /// 刷新 meetup 数据
  Future<void> _refreshMeetups() async {
    try {
      log('🔄 DataServicePage: 刷新 meetup 数据');
      await _meetupController.loadMeetups(isForceRefresh: true);
    } catch (e) {
      log('⚠️ DataServicePage: meetup 数据刷新失败: $e');
    }
  }

  /// 清除搜索状态（从 detail 页面返回时调用）
  void _clearSearchOnReturn() {
    log('🔍 DataServicePage: 清除搜索状态，当前 _localSearchQuery=$_localSearchQuery');
    if (mounted) {
      setState(() {
        _localSearchQuery = '';
        _isLocalSearching = false;
      });
      _searchController.clear();
      log('🔍 DataServicePage: 本地搜索状态已清除');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 当应用回到前台时，仅在城市数据为空时刷新
    if (state == AppLifecycleState.resumed) {
      if (_cityController.cities.isEmpty) {
        log('📱 应用回到前台，城市数据为空，刷新数据');
        _cityController.loadInitialCities(refresh: true).catchError((e) {
          log('⚠️ 城市数据加载失败: $e');
          return null;
        });
      } else {
        log('📱 应用回到前台，已有缓存数据，不刷新');
      }
    }
  }

  // 页面回退时的刷新逻辑会在路由导航时处理
  // 我们在每次页面可见时都刷新数据
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 检查页面是否从其他页面回退
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // 延迟执行，避免在build过程中调用
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 检查是否已有数据，使用缓存模式避免重复刷新
        if (_cityController.cities.isNotEmpty) {
          log('🔄 页面回到前台，使用缓存数据，不刷新');
          // 不刷新，避免并发请求
        }
      });
    }
  }

  /// 严格检查登录状态和 Token 有效性
  /// 在发起任何请求前就验证 token，而不是等到 HTTP 拦截器
  bool _checkLoginAndNavigate(VoidCallback onLoggedIn) {
    final authController = Get.find<AuthStateController>();

    log('🔒 [严格验证] 检查登录状态...');

    // 1️⃣ 检查登录状态
    if (!authController.isAuthenticated.value) {
      log('❌ 用户未登录');
      AppToast.warning(
        'Please login to access this feature',
        title: 'Login Required',
      );
      Get.toNamed(AppRoutes.login);
      return false;
    }

    // 2️⃣ 检查 Token 是否存在
    final token = authController.currentToken.value;
    if (token == null) {
      log('❌ Token 为空，清除登录状态');
      authController.isAuthenticated.value = false;
      authController.currentUser.value = null;

      AppToast.error(
        'Invalid session. Please login again.',
        title: 'Authentication Error',
      );
      Get.toNamed(AppRoutes.login);
      return false;
    }

    // 3️⃣ 检查 Token 是否过期 (关键检查！)
    if (token.isExpired) {
      log('❌ Token 已过期');
      log('   ExpiresAt: ${token.expiresAt}');
      log('   Current: ${DateTime.now()}');

      // 立即清除过期状态
      authController.isAuthenticated.value = false;
      authController.currentUser.value = null;
      authController.currentToken.value = null;

      // 异步清除存储
      authController.logout();

      AppToast.error(
        'Your session has expired. Please login again.',
        title: 'Session Expired',
      );
      Get.toNamed(AppRoutes.login);
      return false;
    }

    // ✅ 所有检查通过，执行操作
    log('✅ Token 验证通过，允许操作');
    log('   ExpiresAt: ${token.expiresAt}');
    log('   Remaining: ${token.expiresAt!.difference(DateTime.now()).inMinutes} minutes');

    onLoggedIn();
    return true;
  }

  /// 执行城市搜索（本页面独立搜索，不影响 CityListPage）
  Future<void> _performSearch(String query) async {
    log('🔍 [首页] 开始搜索城市: $query');

    setState(() {
      _localSearchQuery = query;
      _isLocalSearching = true;
    });

    // 使用 controller 的公共 searchCities 方法，但只更新本地状态
    // 注意：我们不直接调用 controller.searchCities() 因为它会修改共享状态
    // 所以通过 Repository 直接搜索
    final cityRepository = Get.find<ICityRepository>();
    final result = await cityRepository.searchCities(name: query, pageSize: 20);

    result.fold(
      onSuccess: (data) {
        if (mounted) {
          setState(() {
            _localCities = data;
          });
          AppToast.success(
            'Found ${data.length} cities',
            title: 'Search',
          );
        }
      },
      onFailure: (exception) {
        if (mounted) {
          AppToast.error(exception.message, title: 'Search Failed');
        }
      },
    );
  }

  /// 清除搜索（仅清除本页面的搜索状态）
  Future<void> _clearSearch() async {
    _searchController.clear();

    log('🧹 [首页] 清除搜索，重新加载全部城市');

    setState(() {
      _localSearchQuery = '';
      _isLocalSearching = false;
    });

    // 重新加载全部城市到本地
    await _loadHomeCities();
  }

  /// 搜索结果提示
  Widget _buildSearchResultHint(bool isMobile) {
    // 使用本地搜索状态，不使用 Obx
    if (_localSearchQuery.isEmpty) return const SizedBox.shrink();

    final cityCount = _localCities.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4458).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFFF4458).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: Color(0xFFFF4458),
            size: 20.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: 'Search results for ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: '"$_localSearchQuery"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF4458),
                    ),
                  ),
                  TextSpan(
                    text: ': ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: '$cityCount ${cityCount == 1 ? "city" : "cities"} found',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: _clearSearch,
            borderRadius: BorderRadius.circular(4.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                FontAwesomeIcons.xmark,
                color: AppColors.textSecondary,
                size: 18.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToCitiesList() {
    if (_hasScrolled) return;
    _hasScrolled = true;

    // 等待布局完成后滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        final RenderBox? renderBox = _citiesListKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && _scrollController.hasClients) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final scrollPosition = _scrollController.position.pixels + position - 100; // 100px offset for better UX

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
    // 使用领域层的 StateController
    final MeetupStateController meetupController = Get.find<MeetupStateController>();
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
                  vertical: 20.h,
                ),
                child: _buildSearchBar(isMobile),
              ),
            ),

            // 视图切换和排序工具栏
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                ),
                child: _buildToolbar(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 8.h)),

            // 搜索结果提示 - 使用本地搜索状态
            if (_localSearchQuery.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                  ),
                  child: _buildSearchResultHint(isMobile),
                ),
              ),

            if (_localSearchQuery.isNotEmpty) SliverToBoxAdapter(child: SizedBox(height: 8.h)),

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
              sliver: _buildDataGridSliver(isMobile),
            ),

            // 底部间距
            SliverToBoxAdapter(child: SizedBox(height: 40.h)),

            // Meetups 部分 - Nomads.com 风格
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                ),
                child: _buildMeetupsSection(meetupController, isMobile),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 60.h)),

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

            SliverToBoxAdapter(child: SizedBox(height: 40.h)),

            // 版权信息
            const SliverToBoxAdapter(
              child: CopyrightWidget(useTopMargin: false),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
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
                  // Logo和标题区域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          FontAwesomeIcons.earthAmericas,
                          color: Colors.white,
                          size: 32.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
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

                  // 副标题
                  Text(
                    l10n.joinGlobalCommunity,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.livingTravelingWorld,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5.sp,
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

  // 紧凑型服务卡片 - 响应式网格布局
  Widget _buildServiceCards(bool isMobile, AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据屏幕宽度决定布局
    // 超小屏(<400px): 2列布局
    // 小屏(400-768px): 2列布局
    // 中屏(768-1024px): 4列布局
    // 大屏(>1024px): 4列布局
    final isVerySmall = screenWidth < 400;
    final useGridLayout = screenWidth < 768;

    if (useGridLayout) {
      // 2x2 网格布局
      return Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // 第一行: Cities + Coworkings
            Row(
              children: [
                Expanded(
                  child: _buildCompactCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.city,
                    title: l10n.cities,
                    color: const Color(0xFFFF4458),
                    onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
                    isCompact: isVerySmall,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildCompactCard(
                    isMobile: true,
                    icon: FontAwesomeIcons.building,
                    title: l10n.coworks,
                    color: const Color(0xFF6366F1),
                    onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.coworking)),
                    isCompact: isVerySmall,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // 第二行: Meetups + Innovation
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildCompactCard(
                        isMobile: true,
                        icon: FontAwesomeIcons.userGroup,
                        title: l10n.meetups,
                        color: const Color(0xFF10B981),
                        onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.meetupsList)),
                        isCompact: isVerySmall,
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildCompactCard(
                        isMobile: true,
                        icon: FontAwesomeIcons.lightbulb,
                        title: l10n.innovation,
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.innovation)),
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
      // 1x4 横向布局(桌面端)
      return Container(
        constraints: BoxConstraints(maxWidth: 900),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cities
            Expanded(
              child: _buildCompactCard(
                isMobile: false,
                icon: FontAwesomeIcons.city,
                title: l10n.cities,
                color: const Color(0xFFFF4458),
                onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
              ),
            ),

            SizedBox(width: 12.w),

            // Coworkings
            Expanded(
              child: _buildCompactCard(
                isMobile: false,
                icon: FontAwesomeIcons.building,
                title: l10n.coworks,
                color: const Color(0xFF6366F1),
                onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.coworking)),
              ),
            ),

            SizedBox(width: 12.w),

            // Meetups
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return _buildCompactCard(
                    isMobile: false,
                    icon: FontAwesomeIcons.userGroup,
                    title: l10n.meetups,
                    color: const Color(0xFF10B981),
                    onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.meetupsList)),
                  );
                },
              ),
            ),

            SizedBox(width: 12.w),

            // Innovation
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return _buildCompactCard(
                    isMobile: false,
                    icon: FontAwesomeIcons.lightbulb,
                    title: l10n.innovation,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.innovation)),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  // 紧凑型卡片组件
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
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12.r,
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
                borderRadius: BorderRadius.circular(14.r),
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
                letterSpacing: 0.3.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 底部特性亮点列表
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
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji 图标
                Text(
                  feature['icon']!,
                  style: TextStyle(fontSize: 24.sp),
                ),
                SizedBox(width: 12.w),
                // 文字描述
                Expanded(
                  child: Text(
                    feature['text']!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 15 : 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0.2.sp,
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
  Widget _buildToolbar() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.popular,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        // 全球地图按钮
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.mapLocationDot,
            color: AppColors.textSecondary,
            size: 20.r,
          ),
          onPressed: () {
            Get.toNamed(AppRoutes.globalMap);
          },
        ),
      ],
    );
  }

  // 搜索栏
  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.textSecondary, size: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cities... (支持中英文搜索)',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
              ),
              onChanged: (value) {
                // 实时更新清除按钮的显示
                setState(() {});
              },
              onSubmitted: (value) {
                // 按回车键触发搜索
                if (value.trim().isNotEmpty) {
                  _performSearch(value.trim());
                }
              },
            ),
          ),
          SizedBox(width: 12.w),
          // 搜索按钮
          InkWell(
            onTap: () {
              final searchText = _searchController.text.trim();
              if (searchText.isNotEmpty) {
                _performSearch(searchText);
              } else {
                // 如果搜索框为空，清除搜索并重新加载全部城市
                _clearSearch();
              }
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // 清除按钮
          if (_searchController.text.isNotEmpty) ...[
            SizedBox(width: 8.w),
            InkWell(
              onTap: () {
                _clearSearch();
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  FontAwesomeIcons.xmark,
                  color: AppColors.textSecondary,
                  size: 18.r,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 数据网格 Sliver - 使用本地数据状态
  Widget _buildDataGridSliver(bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      // 使用本地城市列表，而不是共享的 controller.cities
      final items = _localCities;
      final isGrid = _isGridView;
      final crossAxisCount = isMobile ? 2 : 4;
      final isLoadingCities = _cityController.isLoading.value;

      // 显示加载中状态
      if (isLoadingCities) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.loading,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 如果城市列表为空，显示空状态
      if (items.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildEmptyCitiesState(isMobile, l10n),
        );
      }

      // 限制最多显示8个城市(暂时改成6,方便测试)
      final displayItems = items.length > 6 ? items.sublist(0, 6) : items;
      final hasMore = items.length > 6;

      // 调试信息
      debugPrint('城市总数: ${items.length}, 显示: ${displayItems.length}, 显示按钮: $hasMore');

      if (isGrid) {
        return SliverList(
          delegate: SliverChildListDelegate([
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: isMobile ? 0.68 : 0.72,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.w,
              ),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                return _DataCard(
                  data: displayItems[index],
                  onReturnFromDetail: _clearSearchOnReturn,
                );
              },
            ),
            if (hasMore) ...[
              SizedBox(height: 24.h),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
                  icon: Icon(
                    FontAwesomeIcons.city,
                    size: 20.r,
                    color: Color(0xFFFF4458),
                  ),
                  label: Text(
                    l10n.viewAllCities,
                    style: TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    side: BorderSide(
                      color: Color(0xFFFF4458),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
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
                return _DataListItem(
                  data: displayItems[index],
                  onReturnFromDetail: _clearSearchOnReturn,
                );
              },
            ),
            if (hasMore) ...[
              SizedBox(height: 24.h),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _checkLoginAndNavigate(() => Get.toNamed(AppRoutes.cityList)),
                  icon: Icon(
                    FontAwesomeIcons.city,
                    size: 20.r,
                    color: Color(0xFFFF4458),
                  ),
                  label: Text(
                    l10n.viewAllCities,
                    style: TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    side: BorderSide(
                      color: Color(0xFFFF4458),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
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
  Widget _buildMeetupsSection(MeetupStateController meetupController, bool isMobile) {
    return Obx(() {
      final upcomingMeetups = meetupController.upcomingMeetups;
      final loadState = meetupController.loadState.value;

      // 使用 loadState 判断加载状态，避免业务操作（create/update）误触发 loading
      final isDataLoading = loadState == LoadState.initial || loadState == LoadState.loading;

      // 显示加载中状态
      if (isDataLoading) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                  ),
                ),
                SizedBox(height: 16.h),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.loading,
                      style: TextStyle(
                        fontSize: 14.sp,
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

      // 如果活动列表为空，显示空状态
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
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.upcomingEventsCount(upcomingMeetups.length),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Create Meetup 按钮
                      Obx(() => ElevatedButton.icon(
                            onPressed: _userController.isLoggedIn
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CreateMeetupPage(),
                                      ),
                                    )
                                : () {
                                    AppToast.warning(
                                      l10n.pleaseLoginToCreateMeetup,
                                      title: l10n.loginRequired,
                                    );
                                  },
                            icon: Icon(FontAwesomeIcons.plus, size: 18.r),
                            label: Text(isMobile ? l10n.create : l10n.createMeetup),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4458),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: isMobile ? 8 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          )),
                      if (!isMobile) SizedBox(width: 12.w),
                      if (!isMobile)
                        OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(AppRoutes.meetupsList);
                          },
                          icon: Icon(
                            FontAwesomeIcons.arrowRight,
                            size: 20.r,
                            color: Color(0xFFFF4458),
                          ),
                          label: Text(
                            l10n.viewAllMeetups,
                            style: TextStyle(
                              color: Color(0xFFFF4458),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            side: BorderSide(
                              color: Color(0xFFFF4458),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Meetups 列表（横向滚动 + 无限加载）
              SizedBox(
                height: 300.h, // 减小卡片高度
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    // 当滚动到接近末尾时，加载更多数据
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8 &&
                        !_meetupController.isLoadingMore.value &&
                        _meetupController.hasMoreData) {
                      log('📜 接近滚动末尾，触发加载更多活动');
                      _meetupController.loadMoreMeetups();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingMeetups.length + (_meetupController.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 如果是最后一项且还有更多数据，显示加载指示器
                      if (index == upcomingMeetups.length) {
                        return Container(
                          width: 60.w,
                          margin: EdgeInsets.only(left: 12.w),
                          child: Center(
                            child: Obx(() => _meetupController.isLoadingMore.value
                                ? CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                                  )
                                : const SizedBox.shrink()),
                          ),
                        );
                      }

                      final meetup = upcomingMeetups[index];
                      return _MeetupCard(
                        meetup: meetup,
                        isMobile: isMobile,
                      );
                    },
                  ),
                ),
              ),

              // 移动端的 View all 按钮
              if (isMobile) ...[
                SizedBox(height: 16.h),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.toNamed(AppRoutes.meetupsList);
                        },
                        icon: Icon(
                          FontAwesomeIcons.arrowRight,
                          size: 20.r,
                          color: Color(0xFFFF4458),
                        ),
                        label: Text(
                          l10n.viewAllMeetups,
                          style: TextStyle(
                            color: Color(0xFFFF4458),
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          side: BorderSide(
                            color: Color(0xFFFF4458),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
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

  // 空城市列表状态
  Widget _buildEmptyCitiesState(bool isMobile, AppLocalizations l10n) {
    // 检查是否正在搜索
    final isSearching = _searchController.text.trim().isNotEmpty;

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
              isSearching ? FontAwesomeIcons.magnifyingGlass : FontAwesomeIcons.city,
              size: isMobile ? 50 : 60,
              color: const Color(0xFFFF4458),
            ),
          ),

          SizedBox(height: isMobile ? 24 : 32),

          // 标题
          Text(
            isSearching ? 'No cities found' : l10n.noCitiesYet,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 12.h),

          // 描述
          Text(
            isSearching
                ? 'Try searching with a different keyword\n(支持中英文搜索)'
                : 'Start exploring by adding your first city',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          SizedBox(height: isMobile ? 32 : 40),

          // 按钮
          if (isSearching) ...[
            // 搜索结果为空时显示清除按钮
            ElevatedButton.icon(
              onPressed: () {
                _clearSearch();
              },
              icon: const Icon(FontAwesomeIcons.xmark),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ] else ...[
            // 无城市时显示浏览按钮
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed(AppRoutes.cityList);
              },
              icon: Icon(FontAwesomeIcons.circlePlus, size: 20.r),
              label: Text(
                l10n.browseCities,
                style: TextStyle(
                  fontSize: 16.sp,
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
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 空活动列表状态
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
              FontAwesomeIcons.userGroup,
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

          SizedBox(height: 12.h),

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
            icon: Icon(FontAwesomeIcons.circlePlus, size: 20.r),
            label: Text(
              'Create Meetup',
              style: TextStyle(
                fontSize: 16.sp,
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
                borderRadius: BorderRadius.circular(8.r),
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
  final City data;
  final VoidCallback? onReturnFromDetail;

  const _DataCard({required this.data, this.onReturnFromDetail});

  @override
  State<_DataCard> createState() => _DataCardState();
}

class _DataCardState extends State<_DataCard> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final l10n = AppLocalizations.of(context)!;
    // 在构建时捕获回调，确保导航返回时仍可用
    final onReturnCallback = widget.onReturnFromDetail;

    return GestureDetector(
      onTap: () {
        // 单击跳转到城市详情页面
        log('🏙️ [DEBUG] City card tapped: ${widget.data}');
        log('🏙️ [DEBUG] cityId will be: ${widget.data.id}');

        // 检查登录状态
        final authController = Get.find<AuthStateController>();
        if (!authController.isAuthenticated.value) {
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
              cityId: widget.data.id,
              cityName: widget.data.name,
              cityImages: widget.data.landscapeImageUrls ?? [],
              cityImage: widget.data.imageUrl?.toString() ?? '',
              overallScore: (widget.data.overallScore as num?)?.toDouble() ?? 0.0,
              reviewCount: (widget.data.reviewCount as num?)?.toInt() ?? 0,
            ),
          ),
        ).then((_) {
          // 从 detail 页面返回时，通知父组件清除搜索
          log('🔙 [DEBUG] 从 CityDetailPage 返回，调用清除搜索回调');
          onReturnCallback?.call();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: showDetails ? AppColors.accent.withValues(alpha: 0.5) : AppColors.borderLight,
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
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.data.displayImageUrl),
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
                // 顶部：排名、徽章和网络 - 防止溢出
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  right: 8.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧：版主状态徽章
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 6, vertical: isMobile ? 2 : 3),
                              decoration: BoxDecoration(
                                color: widget.data.moderatorId != null
                                    ? const Color(0xFF10B981).withValues(alpha: 0.9)
                                    : Colors.orange.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.data.moderatorId != null
                                        ? FontAwesomeIcons.userCheck
                                        : FontAwesomeIcons.userXmark,
                                    color: Colors.white,
                                    size: isMobile ? 8 : 10,
                                  ),
                                  SizedBox(width: isMobile ? 2 : 4),
                                  Text(
                                    widget.data.moderatorId != null ? '已指定版主' : '待指定版主',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 8 : 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: isMobile ? 3 : 8),
                      // 右侧：刷新按钮 + 网络
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 刷新图片按钮（管理员或城市版主可见）
                          Obx(() {
                            final authController = Get.find<AuthStateController>();
                            final user = authController.currentUser.value;
                            final isAdmin = user?.role.toLowerCase() == 'admin';
                            final isCityModerator = widget.data.isCurrentUserModerator ||
                                (widget.data.moderatorId != null && widget.data.moderatorId == user?.id);

                            if (!isAdmin && !isCityModerator) return const SizedBox.shrink();

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _GenerateImageButton(
                                  cityId: widget.data.id,
                                  cityName: widget.data.name,
                                  isMobile: isMobile,
                                ),
                                SizedBox(width: isMobile ? 3 : 6),
                              ],
                            );
                          }),
                          // 网络 - 移动端简化显示
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 6, vertical: isMobile ? 2 : 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4.r),
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
                                  widget.data.displayInternetScore.toStringAsFixed(1),
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
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 城市名
                        Text(
                          widget.data.name,
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
                          widget.data.displayCountry,
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
                              FontAwesomeIcons.star,
                              color: const Color(0xFFFBBF24),
                              size: isMobile ? 16 : 18,
                            ),
                            SizedBox(width: isMobile ? 3 : 4),
                            Text(
                              widget.data.displayOverallScore.toStringAsFixed(1),
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
                        // 天气和价格
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 天气信息
                            Row(
                              children: [
                                Text(
                                  widget.data.weatherIcon,
                                  style: TextStyle(fontSize: isMobile ? 16 : 18),
                                ),
                                SizedBox(width: isMobile ? 3 : 6),
                                Text(
                                  '${widget.data.displayTemperature}°',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 13 : 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
}

// 详情悬浮卡 - 透明蒙层风格
class _DetailOverlay extends StatelessWidget {
  final City data;
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
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          children: [
            // 顶部左侧 - 收藏图标
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.heart,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ),

            // 顶部右侧 - 关闭按钮
            Positioned(
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.xmark,
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
              ),
            ),

            // 底部 - 评分条
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMetricBar('⭐ Overall', data.displayOverallScore, const Color(0xFFFBBF24)),
                  SizedBox(height: 6.h),
                  _buildMetricBar('💰 Cost', data.displayCostScore, const Color(0xFF4ADE80)),
                  SizedBox(height: 6.h),
                  _buildMetricBar('📡 Internet', data.displayInternetScore, const Color(0xFFFBBF24)),
                  SizedBox(height: 6.h),
                  _buildMetricBar('👍 乐趣', data.displayLikedScore, const Color(0xFF4ADE80)),
                  SizedBox(height: 6.h),
                  _buildMetricBar('🛡️ Safety', data.displaySafetyScore, const Color(0xFF4ADE80)),
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
          width: 85.w,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 3.r,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Stack(
            children: [
              // 背景条 - 深色半透明
              Container(
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              // 进度条
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value / 5.0, // 将 0-5 分转换为 0-1 比例
                child: Container(
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(9.r),
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

// 列表项（列表视图用）
class _DataListItem extends StatelessWidget {
  final City data;
  final VoidCallback? onReturnFromDetail;

  const _DataListItem({required this.data, this.onReturnFromDetail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 在构建时捕获回调，确保导航返回时仍可用
    final onReturnCallback = onReturnFromDetail;

    return GestureDetector(
      onTap: () {
        // 单击跳转到城市详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetailPage(
              cityId: data.id,
              cityName: data.name,
              cityImages: data.landscapeImageUrls ?? [],
              cityImage: data.displayImageUrl,
              overallScore: data.displayOverallScore,
              reviewCount: data.displayReviewCount,
            ),
          ),
        ).then((_) {
          // 从 detail 页面返回时，通知父组件清除搜索
          log('🔙 [DEBUG] 从 CityDetailPage 返回 (列表视图)，调用清除搜索回调');
          onReturnCallback?.call();
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 缩略图
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                data.displayImageUrl,
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16.w),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    data.displayCountry,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
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
                  '\$${data.displayAverageCost.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.perMonth,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10.sp,
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
class _MeetupCard extends StatelessWidget {
  final Meetup meetup;
  final bool isMobile;

  const _MeetupCard({
    required this.meetup,
    required this.isMobile,
  });

  // 获取 MeetupStateController
  MeetupStateController get _meetupController => Get.find<MeetupStateController>();

  // 从控制器响应式数据判断是否已加入
  bool _isJoined(RxList<String> rsvpedIds) {
    return rsvpedIds.contains(meetup.id) || meetup.isJoined;
  }

  Future<void> _handleToggleJoin(BuildContext context, bool isCurrentlyJoined) async {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthStateController>();

    // 检查登录状态
    if (!authController.isAuthenticated.value) {
      AppToast.warning(
        l10n.pleaseLoginToCreateMeetup,
        title: l10n.loginRequired,
      );
      Get.toNamed(AppRoutes.login);
      return;
    }

    // 获取 meetup id
    final meetupIdString = meetup.id;

    final isJoining = !isCurrentlyJoined;

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

      // API 调用成功后，更新 Controller 的 rsvpedMeetupIds
      if (isJoining) {
        log('✅ 成功加入活动: ${meetup.title}');
        if (!_meetupController.rsvpedMeetupIds.contains(meetup.id)) {
          _meetupController.rsvpedMeetupIds.add(meetup.id);
        }
      } else {
        log('✅ 成功退出活动: ${meetup.title}');
        _meetupController.rsvpedMeetupIds.remove(meetup.id);
      }

      // 显示成功消息
      if (isJoining) {
        AppToast.success(
          l10n.youHaveJoined(meetup.title),
          title: l10n.joined,
        );
      } else {
        AppToast.info(
          l10n.youLeft(meetup.title),
          title: l10n.leftMeetup,
        );
      }

      // 刷新聚会列表以获取最新的参与者数量
      _meetupController.refreshMeetups();
    } catch (e) {
      log('❌ API 调用失败: $e');

      // 特殊处理:如果是"已经参加"的错误,说明状态不同步,需要纠正前端状态
      final errorMessage = e.toString();
      if (errorMessage.contains('已经参加') || errorMessage.contains('already joined')) {
        log('⚠️ 检测到状态不同步:用户实际已加入,但前端状态为未加入,正在纠正...');
        // 更新 Controller
        if (!_meetupController.rsvpedMeetupIds.contains(meetup.id)) {
          _meetupController.rsvpedMeetupIds.add(meetup.id);
        }
        AppToast.info('您已经加入了这个活动');
        return;
      }

      // 特殊处理:如果是"未参加"的错误,说明状态不同步,需要纠正前端状态
      if (errorMessage.contains('未参加') ||
          errorMessage.contains('not joined') ||
          errorMessage.contains('not a participant')) {
        log('⚠️ 检测到状态不同步:用户实际未加入,但前端状态为已加入,正在纠正...');
        // 更新 Controller
        _meetupController.rsvpedMeetupIds.remove(meetup.id);
        AppToast.info('您尚未加入这个活动');
        return;
      }

      // 其他错误正常提示
      AppToast.error(
        isCurrentlyJoined ? '退出活动失败' : '加入活动失败',
        title: '操作失败',
      );
    }
  }

  Future<void> _handleCancelMeetup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final meetupRepository = Get.find<IMeetupRepository>();

    // 显示确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('取消活动'),
        content: const Text('确定要取消这个活动吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await meetupRepository.cancelMeetup(meetup.id);
      log('✅ 成功取消活动: ${meetup.title}');

      // 显示成功消息
      AppToast.success(
        '活动已取消',
        title: '成功',
      );

      // 刷新聚会列表
      _meetupController.refreshMeetups();
    } catch (e) {
      log('❌ 取消活动失败: $e');
      AppToast.error('取消活动失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = meetup.schedule.startTime;

    // 使用 Obx 监听 rsvpedMeetupIds 的变化
    return Obx(() {
      // 从响应式数据计算当前状态
      final isJoined = _isJoined(_meetupController.rsvpedMeetupIds);
      final currentAttendees = meetup.capacity.currentAttendees;
      final maxAttendees = meetup.capacity.maxAttendees;
      final isFull = currentAttendees >= maxAttendees;
      final authController = Get.find<AuthStateController>();
      final isOrganizer =
          authController.isAuthenticated.value && meetup.organizer.id == authController.currentUser.value?.id;

      return Container(
        width: isMobile ? 280 : 320,
        margin: EdgeInsets.only(right: 16.w),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片和类型标签 - 可点击跳转到详情
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.meetupDetail, arguments: meetup);
                },
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                      child: Image.network(
                        meetup.images.isNotEmpty
                            ? meetup.images.first
                            : 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
                        width: double.infinity,
                        height: 140.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _getTypeColor(meetup.eventType?.enName ?? meetup.type.value),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          meetup.eventType?.name ?? meetup.type.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 内容区域 - 可点击跳转到详情
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.meetupDetail, arguments: meetup);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6), // 按钮到卡片底部只留少量空间
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        meetup.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 6.h),

                      // 日期、地点、组织者 - 合并为紧凑显示
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 日期和时间
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.calendar,
                                size: 13.r,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          // 地点（场地 + 城市, 国家）
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.locationDot,
                                size: 13.r,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  [
                                    if (meetup.venue.name.isNotEmpty) meetup.venue.name,
                                    meetup.location.fullDescription,
                                  ].where((s) => s.isNotEmpty).join(', '),
                                  style: TextStyle(
                                    fontSize: 11.sp,
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

                      SizedBox(height: 8.h),

                      // 参加人数和组织者 - 合并为一行
                      Row(
                        children: [
                          // 参加人数
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.users,
                                size: 13.r,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$currentAttendees',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          // 剩余名额
                          if ((maxAttendees - currentAttendees) > 0)
                            Text(
                              '${maxAttendees - currentAttendees} left',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Color(0xFFFF4458),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const Spacer(),
                          // 组织者
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.user,
                                  size: 13.r,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 3.w),
                                Flexible(
                                  child: Text(
                                    meetup.organizer.name,
                                    style: TextStyle(
                                      fontSize: 11.sp,
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
                    ],
                  ),
                ),
              ),

              // 操作按钮区域
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: _buildActionButton(
                  context,
                  isJoined: isJoined,
                  isFull: isFull,
                  isOrganizer: isOrganizer,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 构建操作按钮 - 根据 status 和 isOrganizer 判断
  Widget _buildActionButton(
    BuildContext context, {
    required bool isJoined,
    required bool isFull,
    required bool isOrganizer,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final status = meetup.status; // status 已经是字符串类型,值为 'upcoming', 'ongoing', 'completed', 'cancelled'

    // 如果是组织者
    if (isOrganizer) {
      // 已取消的活动
      if (status == MeetupStatus.cancelled) {
        return SizedBox(
          width: double.infinity,
          height: 32.h,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.borderLight,
              foregroundColor: AppColors.textSecondary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              disabledBackgroundColor: AppColors.borderLight,
              disabledForegroundColor: AppColors.textSecondary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.ban, size: 14.r),
                SizedBox(width: 4.w),
                Text(
                  '已取消',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // 已完成的活动
      if (status == MeetupStatus.completed || meetup.isEnded) {
        return SizedBox(
          width: double.infinity,
          height: 32.h,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.borderLight,
              foregroundColor: AppColors.textSecondary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              disabledBackgroundColor: AppColors.borderLight,
              disabledForegroundColor: AppColors.textSecondary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.circleCheck, size: 14.r),
                SizedBox(width: 4.w),
                Text(
                  '已结束',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // 进行中或即将开始的活动 - 显示聊天按钮 + 取消按钮
      return Row(
        children: [
          // Chat 按钮 - 组织者始终可用
          Expanded(
            child: SizedBox(
              height: 32.h,
              child: OutlinedButton(
                onPressed: () {
                  final authController = Get.find<AuthStateController>();
                  if (!authController.isAuthenticated.value) {
                    AppToast.warning(
                      l10n.pleaseLoginToCreateMeetup,
                      title: l10n.loginRequired,
                    );
                    Get.toNamed(AppRoutes.login);
                    return;
                  }

                  // 跳转到群聊页面
                  Get.toNamed(
                    AppRoutes.cityChat,
                    arguments: {
                      'city': meetup.title,
                      'country': '${meetup.type} Meetup',
                      'meetupId': meetup.id,
                      'isMeetupChat': true,
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.message, size: 14.r),
                    SizedBox(width: 3.w),
                    Flexible(
                      child: Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 12.sp,
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
          SizedBox(width: 6.w),
          // 取消活动按钮
          Expanded(
            child: SizedBox(
              height: 32.h,
              child: ElevatedButton(
                onPressed: () => _handleCancelMeetup(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.ban, size: 14.r),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '取消活动',
                        style: TextStyle(
                          fontSize: 12.sp,
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

    // 不是组织者的情况
    // 已取消的活动
    if (status == MeetupStatus.cancelled) {
      return SizedBox(
        width: double.infinity,
        height: 32.h,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.borderLight,
            foregroundColor: AppColors.textSecondary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
            disabledBackgroundColor: AppColors.borderLight,
            disabledForegroundColor: AppColors.textSecondary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.ban, size: 14.r),
              SizedBox(width: 4.w),
              Text(
                '活动已取消',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 已完成的活动
    if (status == MeetupStatus.completed || meetup.isEnded) {
      return SizedBox(
        width: double.infinity,
        height: 32.h,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.borderLight,
            foregroundColor: AppColors.textSecondary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
            disabledBackgroundColor: AppColors.borderLight,
            disabledForegroundColor: AppColors.textSecondary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.circleCheck, size: 14.r),
              SizedBox(width: 4.w),
              Text(
                '活动已结束',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // upcoming 或 ongoing - 显示 Chat + Join/Leave 按钮
    return Row(
      children: [
        // Chat 按钮 - 只有加入了才能点击
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: OutlinedButton(
              onPressed: isJoined
                  ? () {
                      final authController = Get.find<AuthStateController>();
                      final l10n = AppLocalizations.of(context)!;
                      if (!authController.isAuthenticated.value) {
                        AppToast.warning(
                          l10n.pleaseLoginToCreateMeetup,
                          title: l10n.loginRequired,
                        );
                        Get.toNamed(AppRoutes.login);
                        return;
                      }

                      // 跳转到群聊页面
                      Get.toNamed(
                        AppRoutes.cityChat,
                        arguments: {
                          'city': meetup.title,
                          'country': '${meetup.type} Meetup',
                          'meetupId': meetup.id,
                          'isMeetupChat': true,
                        },
                      );
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: isJoined ? Colors.blue : Colors.grey,
                side: BorderSide(
                  color: isJoined ? Colors.blue : Colors.grey.shade300,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                backgroundColor: isJoined ? null : Colors.grey.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.message, size: 14.r),
                  SizedBox(width: 3.w),
                  Flexible(
                    child: Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 12.sp,
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
        SizedBox(width: 6.w),
        // Join/Leave 按钮
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: (isFull && !isJoined) ? null : () => _handleToggleJoin(context, isJoined),
              style: ElevatedButton.styleFrom(
                backgroundColor: isJoined ? AppColors.borderLight : const Color(0xFFFF4458),
                foregroundColor: isJoined ? AppColors.textSecondary : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                disabledBackgroundColor: AppColors.borderLight,
                disabledForegroundColor: AppColors.textSecondary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isJoined ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circlePlus,
                    size: 14.r,
                  ),
                  SizedBox(width: 3.w),
                  Flexible(
                    child: Text(
                      isFull && !isJoined
                          ? l10n.full
                          : isJoined
                              ? 'Leave'
                              : 'Join',
                      style: TextStyle(
                        fontSize: 12.sp,
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

  Color _getTypeColor(String type) {
    // 根据类型名称设置颜色（支持中英文）- 与 meetups_list_page 保持一致
    final typeLower = type.toLowerCase();
    if (typeLower.contains('coffee') || typeLower.contains('咖啡')) {
      return Colors.brown;
    } else if (typeLower.contains('coworking') ||
        typeLower.contains('business') ||
        typeLower.contains('共享办公') ||
        typeLower.contains('商务')) {
      return Colors.blue;
    } else if (typeLower.contains('activity') ||
        typeLower.contains('outdoor') ||
        typeLower.contains('户外') ||
        typeLower.contains('徒步')) {
      return Colors.green;
    } else if (typeLower.contains('language') || typeLower.contains('语言')) {
      return Colors.purple;
    } else if (typeLower.contains('social') ||
        typeLower.contains('社交') ||
        typeLower.contains('networking') ||
        typeLower.contains('网络')) {
      return Colors.orange;
    } else if (typeLower.contains('tech') ||
        typeLower.contains('workshop') ||
        typeLower.contains('技术') ||
        typeLower.contains('工作坊')) {
      return Colors.indigo;
    } else if (typeLower.contains('food') ||
        typeLower.contains('dinner') ||
        typeLower.contains('美食') ||
        typeLower.contains('饮品')) {
      return Colors.red;
    } else if (typeLower.contains('sports') ||
        typeLower.contains('fitness') ||
        typeLower.contains('运动') ||
        typeLower.contains('健身')) {
      return Colors.teal;
    } else if (typeLower.contains('culture') ||
        typeLower.contains('art') ||
        typeLower.contains('文化') ||
        typeLower.contains('艺术')) {
      return Colors.pink;
    } else if (typeLower.contains('yoga') ||
        typeLower.contains('meditation') ||
        typeLower.contains('瑜伽') ||
        typeLower.contains('冥想')) {
      return const Color(0xFF4CAF50);
    } else {
      // 默认颜色
      return const Color(0xFF9C27B0);
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// 生成城市图片按钮组件
class _GenerateImageButton extends StatelessWidget {
  final String cityId;
  final String cityName;
  final bool isMobile;

  const _GenerateImageButton({
    required this.cityId,
    required this.cityName,
    required this.isMobile,
  });

  Future<void> _generateImages() async {
    final cityController = Get.find<CityStateController>();

    // 检查是否正在生成
    if (cityController.isGeneratingImages(cityId)) return;

    // 检查登录状态
    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning(
        'Please login to generate images',
        title: 'Login Required',
      );
      Get.toNamed(AppRoutes.login);
      return;
    }

    // 检查是否是管理员或城市版主
    final user = authController.currentUser.value;
    final userRole = user?.role.toLowerCase() ?? '';
    final isAdmin = userRole == 'admin';

    // 检查是否为该城市的版主
    bool isCityModerator = false;
    try {
      final city = cityController.cities.firstWhereOrNull((c) => c.id == cityId) ??
          cityController.recommendedCities.firstWhereOrNull((c) => c.id == cityId) ??
          cityController.popularCities.firstWhereOrNull((c) => c.id == cityId);
      if (city != null) {
        isCityModerator = city.isCurrentUserModerator || (city.moderatorId != null && city.moderatorId == user?.id);
      }
    } catch (_) {}

    if (!isAdmin && !isCityModerator) {
      AppToast.warning(
        'Only administrators or city moderators can generate images',
        title: 'Permission Denied',
      );
      return;
    }

    AppToast.info(
      'AI image generation task created for $cityName.\nYou will be notified when complete.',
      title: 'Task Created',
    );

    final result = await cityController.generateCityImages(cityId);

    result.fold(
      onSuccess: (data) {
        // 异步模式：任务已创建，等待 SignalR 通知
        // 不需要在这里更新图片，SignalR 会推送更新
        final taskData = data['data'] as Map<String, dynamic>?;
        final taskId = taskData?['taskId'] as String? ?? '';
        log('🖼️ Image generation task created: taskId=$taskId');
        // 加载状态由 controller 管理，等待 SignalR 通知时自动结束
      },
      onFailure: (exception) {
        AppToast.error(
          exception.message,
          title: 'Task Creation Failed',
        );
        // 失败时 controller 已经移除了 cityId
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityController = Get.find<CityStateController>();

    return Obx(() {
      final isGenerating = cityController.isGeneratingImages(cityId);

      return GestureDetector(
        onTap: isGenerating ? null : _generateImages,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 4 : 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: isGenerating
              ? SizedBox(
                  width: isMobile ? 12 : 16,
                  height: isMobile ? 12 : 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  FontAwesomeIcons.arrowsRotate,
                  color: Colors.white,
                  size: isMobile ? 10 : 14,
                ),
        ),
      );
    });
  }
}
