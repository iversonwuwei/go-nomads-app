import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

import 'city_detail/city_detail.dart';

/// 收藏夹页面 - 管理收藏的城市
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with RouteAwareRefreshMixin<FavoritesPage> {
  static const int _pageSize = 20;

  late final CityStateController _cityController;
  late final ICityRepository _cityRepository;
  late final UserStateController _userController;

  String _sortBy = 'score'; // score, price, name
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalCount = 0;
  final List<City> _favoriteCities = <City>[];

  @override
  void initState() {
    super.initState();
    _cityController = Get.find<CityStateController>();
    _cityRepository = Get.find<ICityRepository>();
    _userController = Get.find<UserStateController>();
    _loadFavorites();
  }

  @override
  Future<void> onRouteResume() async {
    // 页面恢复时刷新收藏数据，确保数据同步
    log('🔄 FavoritesPage: 页面恢复，刷新收藏数据');
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final result = await _cityRepository.getFavoriteCitiesPage(
      page: 1,
      pageSize: _pageSize,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
      _currentPage = 1;
    });

    result.fold(
      onSuccess: (data) {
        setState(() {
          _favoriteCities
            ..clear()
            ..addAll(data.items);
          _totalCount = data.totalCount;
          _currentPage = data.page;
        });
      },
      onFailure: (exception) {
        AppToast.error(exception.message);
      },
    );
  }

  bool get _hasMoreFavorites => _favoriteCities.length < _totalCount;

  Future<void> _loadMoreFavorites() async {
    if (_isLoadingMore || !_hasMoreFavorites) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    final result = await _cityRepository.getFavoriteCitiesPage(
      page: _currentPage + 1,
      pageSize: _pageSize,
    );

    if (!mounted) {
      return;
    }

    result.fold(
      onSuccess: (data) {
        setState(() {
          _favoriteCities.addAll(
            data.items.where((item) => _favoriteCities.every((existing) => existing.id != item.id)),
          );
          _totalCount = data.totalCount;
          _currentPage = data.page;
          _isLoadingMore = false;
        });
      },
      onFailure: (exception) {
        setState(() {
          _isLoadingMore = false;
        });
        AppToast.error(exception.message);
      },
    );
  }

  List<City> get _sortedCities {
    final cities = List<City>.from(_favoriteCities);
    switch (_sortBy) {
      case 'price':
        cities.sort((a, b) => (a.averageCost ?? 0).compareTo(b.averageCost ?? 0));
        break;
      case 'name':
        cities.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'score':
      default:
        cities.sort((a, b) => (b.overallScore ?? 0).compareTo(a.overallScore ?? 0));
        break;
    }
    return cities;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.favorites,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_totalCount ${l10n.cities}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            )),
        leading: const AppBackButton(color: AppColors.backButtonLight),
        actions: [
          // 排序按钮
          PopupMenuButton<String>(
            icon: const Icon(FontAwesomeIcons.arrowDownShortWide, color: Colors.white),
            color: const Color(0xFF1a1a1a),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return [
                _buildPopupMenuItem('score', l10n.ranking, FontAwesomeIcons.star),
                _buildPopupMenuItem('price', l10n.price, FontAwesomeIcons.dollarSign),
                _buildPopupMenuItem('name', l10n.name, FontAwesomeIcons.arrowDownAZ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const AppSceneLoading(scene: AppLoadingScene.cityList, fullScreen: true)
          : Obx(() {
              final cities = _sortedCities;
              if (cities.isEmpty) {
                return _buildEmptyState(isMobile);
              }
              return RefreshIndicator(
                onRefresh: _loadFavorites,
                color: Colors.orange,
                child: ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  itemCount: cities.length + 1,
                  itemBuilder: (context, index) {
                    if (index == cities.length) {
                      return _buildLoadMoreIndicator(isMobile);
                    }

                    if (index >= cities.length - 3 && _hasMoreFavorites) {
                      _loadMoreFavorites();
                    }

                    final city = cities[index];
                    return _buildFavoriteCard(city, isMobile);
                  },
                ),
              );
            }),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.white70,
            size: 20.r,
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(FontAwesomeIcons.check, color: Colors.orange, size: 20.r),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.heart,
                  size: isMobile ? 80 : 120,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.noFavorites,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.exploreCities,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.dataService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 32 : 48,
                      vertical: isMobile ? 16 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    l10n.exploreCities,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
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

  Widget _buildFavoriteCard(City city, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = city.portraitImageUrl ?? city.imageUrl ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToCityDetail(city),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：图片 + 基本信息
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 城市图片（更大尺寸）
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: isMobile ? 100 : 140,
                                height: isMobile ? 100 : 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage(isMobile);
                                },
                              )
                            : _buildPlaceholderImage(isMobile),
                      ),
                      // 综合评分角标
                      if (city.overallScore != null)
                        Positioned(
                          top: 6.h,
                          left: 6.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FontAwesomeIcons.solidStar, color: Color(0xFFFBBF24), size: 10.r),
                                SizedBox(width: 3.w),
                                Text(
                                  city.overallScore!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(width: 14.w),

                  // 城市基本信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 城市名称
                        Text(
                          city.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4.h),

                        // 国家 + 版主状态
                        Row(
                          children: [
                            if (city.country != null) ...[
                              Flexible(
                                child: Text(
                                  city.country!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: isMobile ? 13 : 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                          ],
                        ),

                        SizedBox(height: 10.h),

                        // 核心指标行
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.w,
                          children: [
                            // 月均花费
                            if (city.averageCost != null && city.averageCost! > 0)
                              _buildStatChip(
                                FontAwesomeIcons.dollarSign,
                                '\$${city.averageCost!.toInt()}/mo',
                                Colors.green,
                                isMobile,
                              ),
                            // 网络评分
                            if (city.internetScore != null)
                              _buildStatChip(
                                FontAwesomeIcons.wifi,
                                city.internetScore!.toStringAsFixed(1),
                                Colors.blue,
                                isMobile,
                              ),
                            // 温度
                            if (city.temperature != null)
                              _buildStatChip(
                                FontAwesomeIcons.temperatureHalf,
                                '${city.temperature!.round()}°C',
                                Colors.orange,
                                isMobile,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 收藏按钮
                  IconButton(
                    icon: Icon(FontAwesomeIcons.solidHeart, color: Colors.red, size: 20.r),
                    onPressed: () => _unfavoriteCity(city, l10n),
                    tooltip: l10n.removeFromFavorites,
                  ),
                ],
              ),
            ),

            // 底部：数字游民指标
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  // 左侧统计信息
                  _buildBottomStat(
                    FontAwesomeIcons.laptop,
                    '${city.coworkingCount ?? 0}',
                    'Coworking',
                    Colors.blue,
                    isMobile,
                  ),
                  SizedBox(width: 8.w),
                  _buildBottomStat(
                    FontAwesomeIcons.userGroup,
                    '${city.meetupCount ?? 0}',
                    'Meetups',
                    Colors.purple,
                    isMobile,
                  ),
                  SizedBox(width: 8.w),
                  _buildBottomStat(
                    FontAwesomeIcons.comment,
                    '${city.reviewCount ?? 0}',
                    l10n.reviews,
                    Colors.teal,
                    isMobile,
                  ),
                  const Spacer(),
                  // 进入详情按钮（居右）
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.viewDetails,
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: isMobile ? 11 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(FontAwesomeIcons.arrowRight, color: Colors.orange, size: isMobile ? 10 : 12),
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

  /// 构建统计小标签
  Widget _buildStatChip(IconData icon, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isMobile ? 10 : 12),
          SizedBox(width: isMobile ? 3 : 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部统计项（只显示图标和数字）
  Widget _buildBottomStat(IconData icon, String value, String label, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isMobile ? 12 : 14),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isMobile) {
    return Container(
      width: isMobile ? 100 : 140,
      height: isMobile ? 100 : 140,
      color: Colors.white.withValues(alpha: 0.1),
      child: Icon(
        FontAwesomeIcons.city,
        color: Colors.white54,
        size: 40.r,
      ),
    );
  }

  void _navigateToCityDetail(City city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPage(
          cityId: city.id,
          cityName: city.name,
          cityImages: city.landscapeImageUrls ?? [],
          cityImage: city.portraitImageUrl ?? city.imageUrl ?? '',
          overallScore: city.overallScore ?? 0.0,
          reviewCount: city.reviewCount ?? 0,
        ),
      ),
    );
  }

  Future<void> _unfavoriteCity(City city, AppLocalizations l10n) async {
    final result = await _userController.removeFavoriteCity(city.id);
    if (result) {
      // 从收藏列表中移除
      _cityController.favoriteCities.removeWhere((c) => c.id == city.id);
      setState(() {
        _favoriteCities.removeWhere((c) => c.id == city.id);
        _totalCount = (_totalCount - 1).clamp(0, 1 << 31);
      });

      if (_hasMoreFavorites) {
        _loadMoreFavorites();
      }

      AppToast.success(
        l10n.favoriteRemoved,
        title: l10n.removeFromFavorites,
      );
    }
  }

  Widget _buildLoadMoreIndicator(bool isMobile) {
    if (_isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(child: AppLoadingWidget(fullScreen: false)),
      );
    }

    if (!_hasMoreFavorites) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
        child: Center(
          child: Text(
            '已加载全部收藏城市',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: isMobile ? 12 : 13,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
