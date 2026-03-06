import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/features/city/application/use_cases/city_use_cases.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_page.dart';
import 'package:go_nomads_app/pages/coworking_list_page.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

/// Coworking Home Page
/// 共享办公空间首页 - 城市选择（无限滚动）
class CoworkingHomePage extends StatefulWidget {
  const CoworkingHomePage({super.key});

  @override
  State<CoworkingHomePage> createState() => _CoworkingHomePageState();
}

class _CoworkingHomePageState extends State<CoworkingHomePage> with RouteAwareRefreshMixin<CoworkingHomePage> {
  final List<Map<String, dynamic>> _cities = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _isInitialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 注意：不在 initState 中调用依赖 context 的方法（如 AppLocalizations.of(context)）
    // 数据加载移到 didChangeDependencies 中
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialLoadDone) {
      _isInitialLoadDone = true;
      _loadCitiesWithCoworkingCount();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听 - 触发加载更多
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // 当滚动到距离底部 200 像素时加载更多
    if (currentScroll >= maxScroll - 200 && !_isLoadingMore && _hasMoreData) {
      _loadMoreCities();
    }
  }

  /// 根据天气代码返回对应的 FontAwesome 图标
  IconData _getWeatherIcon(String? weatherIcon) {
    if (weatherIcon == null) return FontAwesomeIcons.cloudSun;

    // OpenWeatherMap 图标代码格式: 01d, 01n, 02d, 02n, etc.
    final code = weatherIcon.replaceAll(RegExp(r'[dn]$'), '');
    final isNight = weatherIcon.endsWith('n');

    switch (code) {
      case '01': // clear sky
        return isNight ? FontAwesomeIcons.moon : FontAwesomeIcons.sun;
      case '02': // few clouds
        return isNight ? FontAwesomeIcons.cloudMoon : FontAwesomeIcons.cloudSun;
      case '03': // scattered clouds
        return FontAwesomeIcons.cloud;
      case '04': // broken clouds
        return FontAwesomeIcons.cloudSun;
      case '09': // shower rain
        return FontAwesomeIcons.cloudShowersHeavy;
      case '10': // rain
        return isNight ? FontAwesomeIcons.cloudMoonRain : FontAwesomeIcons.cloudSunRain;
      case '11': // thunderstorm
        return FontAwesomeIcons.cloudBolt;
      case '13': // snow
        return FontAwesomeIcons.snowflake;
      case '50': // mist
        return FontAwesomeIcons.smog;
      default:
        return FontAwesomeIcons.cloudSun;
    }
  }

  /// 刷新数据 - 重置分页从第一页开始
  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _cities.clear();
    });
    await _loadCitiesWithCoworkingCount();
  }

  @override
  Future<void> onRouteResume() async {
    // 页面恢复时刷新数据，确保数据同步
    log('🔄 CoworkingHome: 页面恢复，刷新数据');
    await _refreshData();
  }

  /// 加载城市列表（首次加载或刷新）
  /// 优化：后端直接返回有 coworking 空间的城市列表（含数量），一次请求搞定
  Future<void> _loadCitiesWithCoworkingCount() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      final getCitiesUseCase = Get.find<GetCitiesWithCoworkingUseCase>();
      final result = await getCitiesUseCase.execute(
        GetCitiesWithCoworkingParams(
          page: 1,
          pageSize: _pageSize,
        ),
      );

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          final processedCities = _processCityBasicData(data);
          setState(() {
            _cities.clear();
            _cities.addAll(processedCities);
            _currentPage = 1;
            _hasMoreData = data.length >= _pageSize;
            _isLoading = false;
          });
          log('✅ 加载 ${processedCities.length} 个有 Coworking 空间的城市（含数量）');

        case Failure(:final exception):
          log('❌ 加载城市数据失败: ${exception.message}');
          setState(() {
            _isLoading = false;
          });
          AppToast.error('${l10n.loadFailed}: ${exception.message}');
      }
    } catch (e) {
      log('❌ 加载城市数据异常: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppToast.error(l10n.loadFailed);
    }
  }

  /// 加载更多城市（分页）
  /// 优化：后端直接返回有 coworking 空间的城市列表（含数量）
  Future<void> _loadMoreCities() async {
    if (!mounted || _isLoadingMore || !_hasMoreData) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final getCitiesUseCase = Get.find<GetCitiesWithCoworkingUseCase>();
      final nextPage = _currentPage + 1;

      final result = await getCitiesUseCase.execute(
        GetCitiesWithCoworkingParams(
          page: nextPage,
          pageSize: _pageSize,
        ),
      );

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          final processedCities = _processCityBasicData(data);
          setState(() {
            _cities.addAll(processedCities);
            _currentPage = nextPage;
            _hasMoreData = data.length >= _pageSize;
            _isLoadingMore = false;
          });
          log('✅ 加载更多: 第 $nextPage 页, ${processedCities.length} 个城市（含数量）');

        case Failure(:final exception):
          log('❌ 加载更多失败: ${exception.message}');
          setState(() {
            _isLoadingMore = false;
          });
          AppToast.error(l10n.loadFailed);
      }
    } catch (e) {
      log('❌ 加载更多异常: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// 处理城市基础数据（后端已返回 coworking 数量）
  List<Map<String, dynamic>> _processCityBasicData(List<dynamic> cities) {
    List<Map<String, dynamic>> processedCities = [];

    for (var city in cities) {
      // City 实体对象处理
      final cityId = city.id as String? ?? '';
      final cityName = city.name as String? ?? '';
      final cityCountry = city.country as String? ?? '';
      final cityImage = city.imageUrl as String? ?? 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000';
      final temperature = city.temperature?.toDouble();
      final weatherDesc = city.weather as String?;
      // 后端已经返回 coworkingCount，直接使用
      final coworkingCount = city.coworkingCount as int? ?? 0;

      processedCities.add({
        'id': cityId,
        'name': cityName,
        'country': cityCountry,
        'image': cityImage,
        'spaces': coworkingCount, // 直接使用后端返回的数量
        'temperature': temperature,
        'weatherIcon': null, // City 实体没有 weatherIcon
        'weatherDescription': weatherDesc,
      });
    }

    return processedCities;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.coworkingSpaces),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: AppLoadingSwitcher(
        isLoading: _isLoading && _cities.isEmpty,
        loading: _buildSkeletonGrid(),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 顶部内容：添加按钮和标题
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Create Space Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await NavigationUtil.toWithCallback<bool>(
                              page: () => AddCoworkingPage(),
                              onResult: (result) async {
                                if (result.needsRefresh && mounted) {
                                  await _refreshData();
                                }
                              },
                            );
                          },
                          icon: Icon(FontAwesomeIcons.circlePlus, size: 24.r),
                          label: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.addCoworkingSpace,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Section Title
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.compass,
                            color: Color(0xFF6366F1),
                            size: 24.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '选择城市',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),

              // City Grid
              if (_cities.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0.w),
                      child: Text(
                        '暂无共享办公空间数据',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.w,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final city = _cities[index];
                        return _buildCityCard(context, city);
                      },
                      childCount: _cities.length,
                    ),
                  ),
                ),

              // Loading More Indicator
              if (_isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              // No More Data Indicator
              if (!_hasMoreData && _cities.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Center(
                      child: Text(
                        '没有更多数据了',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom Padding
              SliverToBoxAdapter(
                child: SizedBox(height: 16.h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard(BuildContext context, Map<String, dynamic> city) {
    final l10n = AppLocalizations.of(context)!;

    // 直接使用后端返回的数量
    final spacesCount = city['spaces'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () async {
            // 添加调试日志
            log('🏙️ 点击城市卡片:');
            log('   城市ID: ${city['id']}');
            log('   城市名称: ${city['name']}');
            log('   Coworking数量: $spacesCount');

            // 等待列表页返回,如果返回 true 则刷新城市列表
            await NavigationUtil.toWithCallback<bool>(
              page: () => CoworkingListPage(
                cityId: city['id'],
                cityName: city['name'],
                countryName: city['country'] as String?,
              ),
              onResult: (result) async {
                // 如果在列表页添加了新的 Coworking,刷新城市列表
                if (result.needsRefresh && mounted) {
                  await _refreshData();
                }
              },
            );
          },
          child: _buildCityCardContent(context, city, spacesCount, l10n),
        ),
      ),
    );
  }

  Widget _buildCityCardContent(
    BuildContext context,
    Map<String, dynamic> city,
    int spacesCount,
    AppLocalizations l10n,
  ) {
    return Stack(
      children: [
        // 背景图片 - 填满整个卡片
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: city['image'] ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget: (context, url, error) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(FontAwesomeIcons.city, size: 48.r, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        // 渐变遮罩
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
        ),
        // 底部信息面板
        Positioned(
          left: 10.w,
          right: 10.w,
          bottom: 10.h,
          child: _buildHeroInfoPanel(city, spacesCount, l10n),
        ),
      ],
    );
  }

  Widget _buildHeroInfoPanel(Map<String, dynamic> city, int spacesCount, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 第一行：城市名称 + Coworking 数量徽章
          Row(
            children: [
              Expanded(
                child: Text(
                  city['name'],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              // Coworking 数量徽章 - 醒目显示
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$spacesCount 空间',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // 国家和天气信息
          Row(
            children: [
              Icon(
                FontAwesomeIcons.locationDot,
                size: 10.r,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  city['country'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 天气信息
              if (city['temperature'] != null) ...[
                SizedBox(width: 6.w),
                Icon(
                  _getWeatherIcon(city['weatherIcon']),
                  size: 11.r,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                SizedBox(width: 3.w),
                Text(
                  '${city['temperature']?.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 骨架屏网格（加载时显示）
  Widget _buildSkeletonGrid() {
    return const AppSceneLoading(scene: AppLoadingScene.cityList, fullScreen: true);
  }
}
