import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/city/application/use_cases/city_use_cases.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_coworking_page.dart';
import 'package:df_admin_mobile/pages/coworking_list_page.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// Coworking Home Page
/// 共享办公空间首页 - 城市选择（无限滚动）
class CoworkingHomePage extends StatefulWidget {
  const CoworkingHomePage({super.key});

  @override
  State<CoworkingHomePage> createState() => _CoworkingHomePageState();
}

class _CoworkingHomePageState extends State<CoworkingHomePage>
    with RouteAwareRefreshMixin<CoworkingHomePage> {
  final List<Map<String, dynamic>> _cities = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCitiesWithCoworkingCount();
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
        return isNight
            ? FontAwesomeIcons.cloudMoonRain
            : FontAwesomeIcons.cloudSunRain;
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

  /// 根据天气代码返回对应的图标颜色
  Color _getWeatherIconColor(String? weatherIcon) {
    if (weatherIcon == null) return const Color(0xFFFF9800); // 鲜艳橙色

    final code = weatherIcon.replaceAll(RegExp(r'[dn]$'), '');
    final isNight = weatherIcon.endsWith('n');

    switch (code) {
      case '01': // clear sky - 晴天
        return isNight
            ? const Color(0xFF5C6BC0) // 鲜艳靛蓝 (夜晚)
            : const Color(0xFFFFA726); // 鲜艳橙色 (白天)
      case '02': // few clouds - 少云
        return isNight
            ? const Color(0xFF7E57C2) // 鲜艳紫色 (夜晚)
            : const Color(0xFF42A5F5); // 鲜艳蓝色 (白天)
      case '03': // scattered clouds - 多云
        return const Color(0xFF66BB6A); // 鲜艳绿色
      case '04': // broken clouds - 阴天
        return const Color(0xFF78909C); // 蓝灰色
      case '09': // shower rain - 阵雨
        return const Color(0xFF29B6F6); // 鲜艳浅蓝
      case '10': // rain - 雨
        return const Color(0xFF1E88E5); // 鲜艳蓝色
      case '11': // thunderstorm - 雷暴
        return const Color(0xFF9C27B0); // 鲜艳紫色
      case '13': // snow - 雪
        return const Color(0xFF26C6DA); // 鲜艳青色
      case '50': // mist - 雾霾
        return const Color(0xFF8D6E63); // 棕色
      default:
        return const Color(0xFFFFA726); // 默认鲜艳橙色
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
    // 页面恢复时不自动刷新，避免并发请求
    // 只在数据为空时才加载
    if (_cities.isEmpty) {
      log('🔄 CoworkingHome: 数据为空，重新加载');
      await _refreshData();
    } else {
      log('✅ CoworkingHome: 使用缓存数据，跳过刷新');
    }
  }

  /// 加载城市列表（首次加载或刷新）
  Future<void> _loadCitiesWithCoworkingCount() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final getCitiesUseCase = Get.find<GetCitiesWithCoworkingCountUseCase>();
      final result = await getCitiesUseCase.execute(
        GetCitiesWithCoworkingCountParams(
          page: 1,
          pageSize: _pageSize,
        ),
      );

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          final items = data['items'] as List<dynamic>? ?? [];
          final processedCities = _processCityData(data);
          setState(() {
            _cities.clear();
            _cities.addAll(processedCities);
            _currentPage = 1;
            // 使用原始返回数据长度判断是否还有更多
            _hasMoreData = items.length >= _pageSize;
            _isLoading = false;
          });
          log('✅ 首次加载 ${processedCities.length} 个城市');

        case Failure(:final exception):
          log('❌ 加载城市数据失败: ${exception.message}');
          setState(() {
            _isLoading = false;
          });
          AppToast.error('加载失败: ${exception.message}');
      }
    } catch (e) {
      log('❌ 加载城市数据异常: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppToast.error('加载失败，请重试');
    }
  }

  /// 加载更多城市（分页）
  Future<void> _loadMoreCities() async {
    if (!mounted || _isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final getCitiesUseCase = Get.find<GetCitiesWithCoworkingCountUseCase>();
      final nextPage = _currentPage + 1;

      final result = await getCitiesUseCase.execute(
        GetCitiesWithCoworkingCountParams(
          page: nextPage,
          pageSize: _pageSize,
        ),
      );

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          final items = data['items'] as List<dynamic>? ?? [];
          final processedCities = _processCityData(data);
          setState(() {
            _cities.addAll(processedCities);
            _currentPage = nextPage;
            // 使用原始返回数据长度判断是否还有更多
            _hasMoreData = items.length >= _pageSize;
            _isLoadingMore = false;
          });
          log('✅ 加载更多: 第 $nextPage 页, ${processedCities.length} 个城市');

        case Failure(:final exception):
          log('❌ 加载更多失败: ${exception.message}');
          setState(() {
            _isLoadingMore = false;
          });
          AppToast.error('加载更多失败');
      }
    } catch (e) {
      log('❌ 加载更多异常: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// 处理城市数据，只保留有 coworking 空间的城市
  List<Map<String, dynamic>> _processCityData(Map<String, dynamic> data) {
    final cities = data['items'] as List<dynamic>? ?? [];
    List<Map<String, dynamic>> citiesWithCount = [];

    for (var city in cities) {
      // 处理 coworkingCount 可能是字符串或整数的情况
      final coworkingCountValue = city['coworkingCount'];
      final count = coworkingCountValue is int
          ? coworkingCountValue
          : (coworkingCountValue is String
              ? int.tryParse(coworkingCountValue) ?? 0
              : 0);

      // 只添加有 coworking 空间的城市
      if (count > 0) {
        // 提取天气信息
        final weather = city['weather'] as Map<String, dynamic>?;
        final temperature = weather?['temperature']?.toDouble();
        final weatherIcon = weather?['weatherIcon'] as String?;
        final weatherDesc = weather?['weatherDescription'] as String?;

        citiesWithCount.add({
          'id': city['id'] as String,
          'name': city['name'] as String,
          'country': city['country'] as String? ?? '',
          'image': city['imageUrl'] as String? ??
              'https://images.unsplash.com/photo-1449824913935-59a10b8d2000',
          'spaces': count,
          'temperature': temperature,
          'weatherIcon': weatherIcon,
          'weatherDescription': weatherDesc,
        });
      }
    }

    return citiesWithCount;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 顶部内容：添加按钮和标题
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Create Space Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddCoworkingPage(),
                                  ),
                                );

                                if (result == true && mounted) {
                                  await _refreshData();
                                }
                              },
                              icon: const Icon(FontAwesomeIcons.circlePlus,
                                  size: 24),
                              label: Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Text(
                                    l10n.addCoworkingSpace,
                                    style: const TextStyle(
                                      fontSize: 16,
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Section Title
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.compass,
                                color: Color(0xFF6366F1),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '选择城市',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // City Grid
                  if (_cities.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            '暂无共享办公空间数据',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
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
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),

                  // No More Data Indicator
                  if (!_hasMoreData && _cities.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            '没有更多数据了',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom Padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCityCard(BuildContext context, Map<String, dynamic> city) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
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
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // 添加调试日志
          log('🏙️ 点击城市卡片:');
          log('   城市ID: ${city['id']}');
          log('   城市名称: ${city['name']}');
          log('   Coworking数量: ${city['spaces']}');

          // 等待列表页返回,如果返回 true 则刷新城市列表
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoworkingListPage(
                cityId: city['id'],
                cityName: city['name'],
                countryName: city['country'] as String?,
              ),
            ),
          );

          // 如果在列表页添加了新的 Coworking,刷新城市列表
          if (result == true && mounted) {
            await _refreshData();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: Image.network(
                      city['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(FontAwesomeIcons.city, size: 50),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${city['spaces']} ${l10n.coworkingSpaces}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 13,
                        color: const Color(0xFFEF5350), // 鲜艳红色
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          city['country'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // 天气信息
                  if (city['temperature'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          FaIcon(
                            _getWeatherIcon(city['weatherIcon']),
                            size: 14,
                            color: _getWeatherIconColor(city['weatherIcon']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${city['temperature']?.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (city['weatherDescription'] != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '·',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                city['weatherDescription'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
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
}
