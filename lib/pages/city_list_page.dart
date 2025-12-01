import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'city_detail_page.dart';
import 'global_map_page.dart';

/// 城市列表页面 - 支持国家、城市和搜索筛选
class CityListPage extends StatefulWidget {
  const CityListPage({super.key});

  @override
  State<CityListPage> createState() => _CityListPageState();
}

class _CityListPageState extends State<CityListPage> with RouteAwareRefreshMixin<CityListPage> {
  final CityStateController controller = Get.find<CityStateController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _followedCities = {}; // 城市关注状态
  bool _isLoadingFollowedCities = false;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // 页面初始化时，清空搜索条件并从后端重新加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏙️ CityListPage 初始化，清空搜索条件并加载最新城市数据');
      // 清空搜索条件
      _searchQuery = '';
      _searchController.clear();
      controller.searchQuery.value = '';
      // 重新加载数据
      controller.loadInitialCities(refresh: true);
    });

    // 异步加载数据,不阻塞页面显示
    Future.microtask(() => _loadFollowedCities());

    // 监听筛选器变化
    ever(controller.selectedRegions, (_) => setState(() {}));
    ever(controller.selectedCountries, (_) => setState(() {}));
    ever(controller.minPrice, (_) => setState(() {}));
    ever(controller.maxPrice, (_) => setState(() {}));
    ever(controller.minInternet, (_) => setState(() {}));
    ever(controller.minRating, (_) => setState(() {}));
    ever(controller.cities, (_) => _syncFollowedStatusFromController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    // 注意：不再清除共享控制器的 searchQuery，每个页面管理自己的搜索状态
    super.dispose();
  }

  // 滚动监听
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // 当滚动到距离底部300像素时开始加载更多
    if (currentScroll >= maxScroll - 300) {
      controller.loadMoreCities();
    }
  }

  // 获取筛选后的城市列表
  // 注意: 搜索功能现在由后端 API 处理,不再在前端筛选
  List<City> get _filteredCities {
    return controller.filteredCities;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    // 清除所有筛选器并重新加载默认数据
    controller.clearFilters();
  }

  @override
  Future<void> onRouteResume() async {
    // 返回页面时清空搜索条件
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    controller.searchQuery.value = '';
    await controller.loadInitialCities();
    _syncFollowedStatusFromController();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.exploreCities,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const AppBackButton(),
        actions: [
          // 全球地图按钮
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.mapLocationDot,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              Get.to(() => const GlobalMapPage());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: SafeArea(
        top: false, // AppBar 已经处理了顶部
        child: Obx(() {
          // 加载中状态
          if (controller.isLoading.value) {
            return const CityListSkeleton();
          }

          // 错误状态
          if (controller.hasError.value) {
            return _buildErrorState();
          }

          return Column(
            children: [
              // 筛选栏
              _buildFilterBar(isMobile),

              // 城市列表
              Expanded(
                child: _filteredCities.isEmpty ? _buildEmptyState() : _buildCityList(isMobile),
              ),
            ],
          );
        }),
      ),
    );
  }

  // 筛选栏
  Widget _buildFilterBar(bool isMobile) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          color: Colors.white,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            children: [
              // 搜索框
              _buildSearchField(),
              const SizedBox(height: 12),

              // 筛选状态
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    final hasFilters = controller.hasActiveFilters || _searchQuery.isNotEmpty;
                    if (!hasFilters) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.filtered,
                        style: const TextStyle(
                          color: Color(0xFFFF4458),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 搜索框 - 参考 data_service_page 的设计
  Widget _buildSearchField() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
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
              const Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchCityOrCountry,
                    hintStyle: const TextStyle(
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (value) {
                    // 按回车键触发搜索
                    if (value.trim().isNotEmpty) {
                      controller.searchCities(value.trim());
                    } else {
                      // 搜索框为空时，清除所有筛选器
                      controller.clearFilters();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // 清除按钮
              if (_searchQuery.isNotEmpty)
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                    // 清除搜索和所有筛选器，重新加载默认数据
                    controller.clearFilters();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      FontAwesomeIcons.xmark,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              // 搜索按钮
              InkWell(
                onTap: () {
                  final searchText = _searchController.text.trim();
                  if (searchText.isNotEmpty) {
                    controller.searchCities(searchText);
                  } else {
                    // 搜索框为空时，清除所有筛选器
                    controller.clearFilters();
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.search,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 城市列表
  Widget _buildCityList(bool isMobile) {
    return Obx(() => ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            100, // 底部留白给导航栏
          ),
          itemCount: controller.cities.length + (controller.hasMoreData ? 1 : 0), // +1 for loading indicator
          itemBuilder: (context, index) {
            // 加载指示器
            if (index == controller.cities.length) {
              return _buildLoadingIndicator();
            }

            final city = controller.cities[index];
            return _buildCityCard(city, isMobile);
          },
        ));
  }

  // 加载指示器
  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (!controller.isLoadingMore.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '加载更多城市...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 城市卡片
  Widget _buildCityCard(City city, bool isMobile) {
    // 调试日志
    print(
        '🏙️ City: ${city.name}, ReviewCount: ${city.reviewCount}, AverageCost: ${city.averageCost}, OverallScore: ${city.overallScore}');

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CityDetailPage(
                cityId: city.id,
                cityName: city.name,
                cityImage: city.imageUrl ?? 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
                overallScore: city.overallScore ?? 0.0,
                reviewCount: city.reviewCount ?? 0,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: city.imageUrl != null && city.imageUrl!.isNotEmpty
                        ? Image.network(
                            city.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(FontAwesomeIcons.imagePortrait, size: 48),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(FontAwesomeIcons.imagePortrait, size: 48),
                          ),
                  ),
                ),
                // 左上角：生成图片按钮（仅管理员可见）
                Obx(() {
                  final authController = Get.find<AuthStateController>();
                  final user = authController.currentUser.value;
                  final isAdmin = user?.role.toLowerCase() == 'admin';

                  if (!isAdmin) return const SizedBox.shrink();

                  return Positioned(
                    top: 12,
                    left: 12,
                    child: _GenerateImageButton(
                      cityId: city.id,
                      cityName: city.name,
                    ),
                  );
                }),
                // 右上角：关注按钮
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildFollowButton(city),
                ),
              ],
            ),

            // 城市信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 城市名和国家
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(FontAwesomeIcons.locationDot, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  city.country ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 评分
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              FontAwesomeIcons.star,
                              size: 16,
                              color: Color(0xFFFF4458),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (city.overallScore ?? 0.0).toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF4458),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 关键指标
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        FontAwesomeIcons.sun,
                        '${_truncateToOneDecimal(city.temperature ?? 0)}°',
                        Colors.orange,
                      ),
                      // 使用后端返回的真实平均花费数据
                      _buildInfoChip(
                        FontAwesomeIcons.dollarSign,
                        '${city.averageCost != null && city.averageCost! > 0 ? city.averageCost!.toInt() : 0}',
                        city.averageCost != null && city.averageCost! > 0 ? Colors.green : Colors.grey,
                      ),
                      if (city.airQualityIndex != null)
                        _buildInfoChip(
                          FontAwesomeIcons.wind,
                          'AQI ${city.airQualityIndex}',
                          _getAqiColor(city.airQualityIndex!),
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

  // 信息标签
  Widget _buildInfoChip(IconData icon, String label, Color color) {
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

  // 获取AQI颜色
  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }

  // 错误状态
  Widget _buildErrorState() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.circleExclamation,
                    size: 64,
                    color: Color(0xFFFF4458),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.loadFailed,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      controller.errorMessage.value?.isNotEmpty == true
                          ? controller.errorMessage.value!
                          : l10n.networkError,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    controller.loadInitialCities();
                  },
                  icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
                  label: Text(l10n.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 空状态
  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 64,
                    color: Color(0xFFFF4458),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.noCitiesFound,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.tryAdjustingFilters,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
                  label: Text(l10n.clearFilters),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 截断数字到小数点后一位(不四舍五入)
  String _truncateToOneDecimal(num value) {
    final truncated = (value * 10).truncate() / 10;
    return truncated.toStringAsFixed(1);
  }

  // 构建关注按钮
  Widget _buildFollowButton(City city) {
    final isFollowed = _isCityFollowed(city);

    return GestureDetector(
      onTap: () => _toggleFollow(city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isFollowed ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFollowed ? FontAwesomeIcons.heart : FontAwesomeIcons.heart,
              size: 16,
              color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 4),
            Text(
              isFollowed ? '已关注' : '关注',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCityFollowed(City city) {
    return _followedCities[city.id] ?? city.isFavorite;
  }

  // 切换关注状态
  void _toggleFollow(City city) async {
    final cityId = city.id;
    if (_isLoadingFollowedCities) {
      return; // 正在加载时不允许操作
    }

    final previousState = _followedCities[cityId] ?? false;

    // 乐观更新 UI
    setState(() {
      _followedCities[cityId] = !previousState;
    });

    try {
      // 使用 CityStateController 的 toggleCityFavorite 方法
      final result = await controller.toggleCityFavorite(cityId);

      result.fold(
        onSuccess: (_) {
          final isNowFollowed = _followedCities[cityId] ?? false;
          AppToast.success(isNowFollowed ? '已关注该城市' : '已取消关注');
          print('✅ 城市关注状态切换成功: cityId=$cityId, followed=$isNowFollowed');
        },
        onFailure: (error) {
          // 操作失败,恢复之前的状态
          setState(() {
            _followedCities[cityId] = previousState;
          });
          AppToast.error('操作失败，请重试');
          print('❌ 切换关注状态失败: $error');
        },
      );
    } catch (e) {
      print('❌ 切换关注状态失败: $e');
      // 发生错误,恢复之前的状态
      setState(() {
        _followedCities[cityId] = previousState;
      });
      AppToast.error('操作失败: $e');
    }
  }

  void _syncFollowedStatusFromController() {
    if (!mounted) return;
    setState(() {
      for (final city in controller.cities) {
        _followedCities[city.id] = city.isFavorite;
      }
    });
  }

  /// 加载用户已关注的城市列表
  Future<void> _loadFollowedCities() async {
    if (_isLoadingFollowedCities) return;

    _isLoadingFollowedCities = true;
    try {
      // 使用 CityStateController 的 loadUserFavoriteCityIds 方法
      final result = await controller.loadUserFavoriteCityIds();

      result.fold(
        onSuccess: (cityIds) {
          setState(() {
            _followedCities.clear();
            for (var cityId in cityIds) {
              _followedCities[cityId] = true;
            }
          });
          print('✅ 已加载 ${cityIds.length} 个关注的城市');
        },
        onFailure: (error) {
          print('❌ 加载关注城市列表失败: $error');
        },
      );
    } catch (e) {
      print('❌ 加载关注城市列表失败: $e');
    } finally {
      _isLoadingFollowedCities = false;
    }
  }
}

// 城市筛选抽屉
// ignore: unused_element
class _CityFilterDrawer extends StatelessWidget {
  final CityStateController controller;

  const _CityFilterDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.filters,
                  style: const TextStyle(
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
                      child: Text(
                        l10n.reset,
                        style: const TextStyle(
                          color: Color(0xFFFF4458),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.xmark),
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
                  _buildSectionTitle(l10n.region),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.availableRegions.map((region) {
                          final isSelected = controller.selectedRegions.contains(region);
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
                            selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 24),

                  // 国家筛选
                  _buildSectionTitle(l10n.country),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.availableCountries.map((country) {
                          final isSelected = controller.selectedCountries.contains(country);
                          return FilterChip(
                            label: Text(country),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedCountries.add(country);
                              } else {
                                controller.selectedCountries.remove(country);
                              }
                            },
                            selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 24),

                  // 城市筛选
                  _buildSectionTitle(l10n.city),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.availableCities.map((city) {
                          final isSelected = controller.selectedCities.contains(city);
                          return FilterChip(
                            label: Text(city),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedCities.add(city);
                              } else {
                                controller.selectedCities.remove(city);
                              }
                            },
                            selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 24),

                  // 价格筛选
                  _buildSectionTitle(l10n.monthlyCost),
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
                  _buildSectionTitle(l10n.minimumInternetSpeed),
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
                  _buildSectionTitle(l10n.minimumOverallRating),
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
                  _buildSectionTitle(l10n.climate),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.availableClimates.map((climate) {
                          final isSelected = controller.selectedClimates.contains(climate);
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
                            selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 24),

                  // AQI筛选
                  _buildSectionTitle(l10n.maximumAirQualityIndex),
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
                                _getAQILabel(controller.maxAqi.value, context),
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
              final count = controller.filteredCities.length;
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
                    l10n.showCities(count),
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

  String _getAQILabel(int aqi, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (aqi <= 50) return l10n.aqiGood;
    if (aqi <= 100) return l10n.aqiModerate;
    if (aqi <= 150) return l10n.aqiUnhealthyForSensitive;
    if (aqi <= 200) return l10n.aqiUnhealthy;
    if (aqi <= 300) return l10n.aqiVeryUnhealthy;
    return l10n.aqiHazardous;
  }
}

/// 生成城市图片按钮组件
class _GenerateImageButton extends StatelessWidget {
  final String cityId;
  final String cityName;

  const _GenerateImageButton({
    required this.cityId,
    required this.cityName,
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

    // 检查是否是管理员（只有管理员可以生成图片）
    final user = authController.currentUser.value;
    final userRole = user?.role.toLowerCase() ?? '';
    if (userRole != 'admin') {
      AppToast.warning(
        'Only administrators can generate images',
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
        print('🖼️ Image generation task created: taskId=$taskId');
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isGenerating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      FontAwesomeIcons.arrowsRotate,
                      color: Colors.white,
                      size: 14,
                    ),
              const SizedBox(width: 4),
              Text(
                isGenerating ? '生成中...' : '更新图片',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
