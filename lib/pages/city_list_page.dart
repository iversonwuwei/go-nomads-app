import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/services/search_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'city_detail_page.dart';
import 'global_map_page.dart';

/// 城市列表页面 - 支持国家、城市和搜索筛选
/// ⭐ 使用独立的本地数据列表，与首页数据完全独立
class CityListPage extends StatefulWidget {
  const CityListPage({super.key});

  @override
  State<CityListPage> createState() => _CityListPageState();
}

class _CityListPageState extends State<CityListPage> with RouteAwareRefreshMixin<CityListPage> {
  // ⭐ 继续使用全局控制器（用于复杂功能如收藏、筛选等）
  // 但数据加载使用独立的 Repository 调用，不影响首页
  final CityStateController controller = Get.find<CityStateController>();
  final ICityRepository _cityRepository = Get.find<ICityRepository>();
  // 🔍 搜索服务 - 通过 Elasticsearch 提供高效搜索
  final SearchService _searchService = Get.find<SearchService>();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _followedCities = {}; // 城市关注状态
  bool _isLoadingFollowedCities = false;
  final List<Worker> _workers = []; // 存储 ever 监听器

  String _searchQuery = '';

  // ⭐ 独立的本地数据状态
  final RxList<City> _localCities = <City>[].obs;
  final RxBool _isLocalLoading = false.obs;
  final RxBool _isLocalLoadingMore = false.obs;
  final RxBool _hasLocalMore = true.obs;
  final Rx<String?> _localErrorMessage = Rx<String?>(null);
  int _localCurrentPage = 1;
  static const int _localPageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // ⭐ 页面初始化时，独立加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('🏙️ CityListPage 初始化，独立加载城市数据（不影响首页）');
      _loadLocalCities(refresh: true);
    });

    // 异步加载数据,不阻塞页面显示
    Future.microtask(() => _loadFollowedCities());

    // 监听本地城市列表变化
    _workers.add(ever(_localCities, (_) => _syncFollowedStatusFromController()));
  }

  @override
  void dispose() {
    // 取消所有 ever 监听器
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ⭐ 独立加载城市数据
  Future<void> _loadLocalCities({bool refresh = false}) async {
    if (_isLocalLoading.value && !refresh) return;

    _isLocalLoading.value = true;
    _localErrorMessage.value = null;
    _localCurrentPage = 1;

    try {
      if (_searchQuery.isNotEmpty) {
        // 有搜索词：先尝试 Elasticsearch，失败再用数据库
        await _searchCities(_searchQuery);
      } else {
        // 无搜索词：直接从数据库加载
        await _loadFromDatabase();
      }
    } catch (e) {
      _localErrorMessage.value = '加载失败: $e';
      log('❌ CityListPage: 加载异常 - $e');
    } finally {
      _isLocalLoading.value = false;
    }
  }

  /// 搜索城市：先 Elasticsearch，失败再数据库
  Future<void> _searchCities(String query) async {
    log('🔍 搜索城市: $query');

    // 1. 先尝试 Elasticsearch
    final esResult = await _searchService.searchCities(
      query: query,
      page: 1,
      pageSize: _localPageSize,
    );

    if (esResult.isSuccess) {
      final data = esResult.data!;
      final cities = data.items.map((item) => _convertSearchDocToCity(item.document)).toList();
      _localCities.assignAll(cities);
      _hasLocalMore.value = data.totalCount > cities.length;
      log('✅ ES搜索成功: ${cities.length} 个城市');
      AppToast.success('Found ${cities.length} cities (ES)');
      return;
    }

    // 2. Elasticsearch 失败，用数据库
    log('⚠️ ES搜索失败，回退到数据库');
    final dbResult = await _cityRepository.searchCities(name: query, pageSize: _localPageSize);

    dbResult.fold(
      onSuccess: (data) {
        _localCities.assignAll(data);
        _hasLocalMore.value = data.length >= _localPageSize;
        log('✅ 数据库搜索成功: ${data.length} 个城市');
        AppToast.warning('Found ${data.length} cities (DB fallback)');
      },
      onFailure: (error) {
        _localErrorMessage.value = error.message;
        log('❌ 数据库搜索失败: ${error.message}');
      },
    );
  }

  /// 从数据库加载城市（无搜索词时）
  Future<void> _loadFromDatabase() async {
    final result = await _cityRepository.getCities(page: 1, pageSize: _localPageSize);

    result.fold(
      onSuccess: (data) {
        _localCities.assignAll(data);
        _hasLocalMore.value = data.length >= _localPageSize;
        log('✅ 加载了 ${data.length} 个城市');
      },
      onFailure: (error) {
        _localErrorMessage.value = error.message;
        log('❌ 加载失败: ${error.message}');
      },
    );
  }

  /// 将 CitySearchDocument 转换为 City 对象
  City _convertSearchDocToCity(CitySearchDocument doc) {
    return City(
      id: doc.id,
      name: doc.name,
      nameEn: doc.nameEn,
      country: doc.country,
      region: doc.region,
      description: doc.description,
      latitude: doc.latitude ?? 0,
      longitude: doc.longitude ?? 0,
      imageUrl: doc.imageUrl,
      portraitImageUrl: doc.portraitImageUrl,
      timezone: doc.timeZone,
      currency: doc.currency,
      overallScore: doc.overallScore,
      internetScore: doc.internetQualityScore,
      safetyScore: doc.safetyScore,
      costScore: doc.costScore,
      communityScore: doc.communityScore,
      weatherScore: doc.weatherScore,
      tags: doc.tags,
    );
  }

  /// 清除搜索
  Future<void> _clearSearch() async {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    await _loadLocalCities(refresh: true);
  }

  // ⭐ 独立加载更多
  Future<void> _loadMoreLocalCities() async {
    if (_isLocalLoadingMore.value || !_hasLocalMore.value) return;

    _isLocalLoadingMore.value = true;

    try {
      if (_searchQuery.isNotEmpty) {
        // 有搜索词：先尝试 ES 加载更多
        final esResult = await _searchService.searchCities(
          query: _searchQuery,
          page: _localCurrentPage + 1,
          pageSize: _localPageSize,
        );

        if (esResult.isSuccess) {
          final data = esResult.data!;
          if (data.items.isEmpty) {
            _hasLocalMore.value = false;
          } else {
            final cities = data.items.map((item) => _convertSearchDocToCity(item.document)).toList();
            _localCities.addAll(cities);
            _localCurrentPage++;
            _hasLocalMore.value = _localCities.length < data.totalCount;
          }
          return;
        }
        // ES 失败则不加载更多（保持简单）
      }

      // 无搜索词或 ES 失败：从数据库加载更多
      final result = await _cityRepository.getCities(
        page: _localCurrentPage + 1,
        pageSize: _localPageSize,
      );

      result.fold(
        onSuccess: (data) {
          if (data.isEmpty) {
            _hasLocalMore.value = false;
          } else {
            _localCities.addAll(data);
            _localCurrentPage++;
            _hasLocalMore.value = data.length >= _localPageSize;
          }
        },
        onFailure: (error) {
          log('❌ 加载更多失败: ${error.message}');
        },
      );
    } finally {
      _isLocalLoadingMore.value = false;
    }
  }

  // 滚动监听
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // 当滚动到距离底部300像素时开始加载更多
    if (currentScroll >= maxScroll - 300) {
      _loadMoreLocalCities();
    }
  }

  void _clearFilters() {
    _clearSearch();
  }

  @override
  Future<void> onRouteResume() async {
    log('🔄 [城市列表] 页面返回，刷新数据');
    // 返回页面时清空搜索条件
    await _clearSearch();
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
          // 加载中状态（使用本地状态）
          if (_isLocalLoading.value) {
            return const CityListSkeleton();
          }

          // 错误状态（使用本地状态）
          if (_localErrorMessage.value != null) {
            return _buildErrorState();
          }

          return Column(
            children: [
              // 筛选栏
              _buildFilterBar(isMobile),

              // 城市列表（使用本地数据）
              Expanded(
                child: _localCities.isEmpty ? _buildEmptyState() : _buildCityList(isMobile),
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
                  // 使用本地搜索状态判断是否有筛选（不需要 Obx，因为 _searchQuery 通过 setState 更新）
                  if (_searchQuery.isNotEmpty)
                    Container(
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
                    ),
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
                      _loadLocalCities(refresh: true);
                    } else {
                      // 搜索框为空时，清除搜索并刷新
                      _clearSearch();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // 清除按钮
              if (_searchQuery.isNotEmpty)
                InkWell(
                  onTap: () {
                    _clearSearch();
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
                    _loadLocalCities(refresh: true);
                  } else {
                    // 搜索框为空时，清除搜索并刷新
                    _clearSearch();
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
    return Obx(() {
      // ⭐ 使用本地数据列表
      final cityList = _localCities.toList();

      return RefreshIndicator(
        onRefresh: () async {
          await _loadLocalCities(refresh: true);
        },
        color: const Color(0xFFFF4458),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            100, // 底部留白给导航栏
          ),
          itemCount: cityList.length + (_hasLocalMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // 加载指示器
            if (index == cityList.length) {
              return _buildLoadingIndicator();
            }

            final city = cityList[index];
            return _buildCityCard(city, isMobile);
          },
        ),
      );
    });
  }

  // 加载指示器
  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (!_isLocalLoadingMore.value) return const SizedBox.shrink();

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
    log('🏙️ City: ${city.name}, ReviewCount: ${city.reviewCount}, AverageCost: ${city.averageCost}, OverallScore: ${city.overallScore}');

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

                  // 指标标签（单行可滚动）- 数字游民核心关注指标
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 💰 月均花费
                        _buildInfoChip(
                          FontAwesomeIcons.dollarSign,
                          city.averageCost != null && city.averageCost! > 0
                              ? '\$${city.averageCost!.toInt()}/mo'
                              : '\$0/mo',
                          city.averageCost != null && city.averageCost! > 0 ? Colors.green : Colors.grey,
                        ),
                        // 📶 网络评分
                        if (city.internetScore != null && city.internetScore! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.wifi,
                            city.internetScore!.toStringAsFixed(1),
                            _getScoreColor(city.internetScore!),
                          ),
                        ],
                        // 🛡️ 安全评分
                        if (city.safetyScore != null && city.safetyScore! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.shield,
                            city.safetyScore!.toStringAsFixed(1),
                            _getScoreColor(city.safetyScore!),
                          ),
                        ],
                        // 👥 社区活跃度
                        if (city.communityScore != null && city.communityScore! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.peopleGroup,
                            city.communityScore!.toStringAsFixed(1),
                            _getScoreColor(city.communityScore!),
                          ),
                        ],
                        // 💻 Coworking 空间数量
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          FontAwesomeIcons.laptop,
                          '${city.coworkingCount ?? 0}',
                          (city.coworkingCount ?? 0) > 0 ? Colors.blue : Colors.grey,
                        ),
                        // 🎉 Meetup 数量
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          FontAwesomeIcons.userGroup,
                          '${city.meetupCount ?? 0}',
                          (city.meetupCount ?? 0) > 0 ? Colors.purple : Colors.grey,
                        ),
                        // 💬 评论数量
                        if (city.reviewCount != null && city.reviewCount! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.comments,
                            '${city.reviewCount}',
                            Colors.teal,
                          ),
                        ],
                        // 👤 版主状态
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          city.hasModerator ? FontAwesomeIcons.userShield : FontAwesomeIcons.userSlash,
                          city.hasModerator ? 'Mod' : 'No Mod',
                          city.hasModerator ? Colors.green : Colors.grey,
                        ),
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

  // 根据评分获取颜色
  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
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
                      _localErrorMessage.value?.isNotEmpty == true ? _localErrorMessage.value! : l10n.networkError,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _loadLocalCities(refresh: true);
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
    if (!mounted) return;
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
          log('✅ 城市关注状态切换成功: cityId=$cityId, followed=$isNowFollowed');
        },
        onFailure: (error) {
          // 操作失败,恢复之前的状态
          if (mounted) {
            setState(() {
              _followedCities[cityId] = previousState;
            });
          }
          AppToast.error('操作失败，请重试');
          log('❌ 切换关注状态失败: $error');
        },
      );
    } catch (e) {
      log('❌ 切换关注状态失败: $e');
      // 发生错误,恢复之前的状态
      if (mounted) {
        setState(() {
          _followedCities[cityId] = previousState;
        });
      }
      AppToast.error('操作失败: $e');
    }
  }

  void _syncFollowedStatusFromController() {
    if (!mounted) return;
    setState(() {
      // ⭐ 使用本地数据列表
      for (final city in _localCities) {
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

      // 检查组件是否仍然挂载
      if (!mounted) return;

      result.fold(
        onSuccess: (cityIds) {
          setState(() {
            _followedCities.clear();
            for (var cityId in cityIds) {
              _followedCities[cityId] = true;
            }
          });
          log('✅ 已加载 ${cityIds.length} 个关注的城市');
        },
        onFailure: (error) {
          log('❌ 加载关注城市列表失败: $error');
        },
      );
    } catch (e) {
      log('❌ 加载关注城市列表失败: $e');
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
