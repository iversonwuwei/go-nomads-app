import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'city_detail_page.dart';

/// 收藏夹页面 - 管理收藏的城市
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with RouteAwareRefreshMixin<FavoritesPage> {
  late final CityStateController _cityController;
  late final UserStateController _userController;

  String _sortBy = 'score'; // score, price, name
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cityController = Get.find<CityStateController>();
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
    await _cityController.loadFavoriteCities();
    setState(() => _isLoading = false);
  }

  List<City> get _sortedCities {
    final cities = List<City>.from(_cityController.favoriteCities);
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
                  '${_cityController.favoriteCities.length} ${l10n.cities}',
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
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
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
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
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
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(FontAwesomeIcons.check, color: Colors.orange, size: 20),
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
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.heart,
                  size: isMobile ? 80 : 120,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.noFavorites,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.exploreCities,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 32),
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
                      borderRadius: BorderRadius.circular(12),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToCityDetail(city),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：图片 + 基本信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 城市图片（更大尺寸）
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FontAwesomeIcons.solidStar, color: Color(0xFFFBBF24), size: 10),
                                const SizedBox(width: 3),
                                Text(
                                  city.overallScore!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 14),

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

                        const SizedBox(height: 4),

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
                              const SizedBox(width: 8),
                            ],
                            // 版主状态徽章
                            _buildModeratorBadge(city, isMobile),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // 核心指标行
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
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
                    icon: const Icon(FontAwesomeIcons.solidHeart, color: Colors.red, size: 20),
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
                  const SizedBox(width: 8),
                  _buildBottomStat(
                    FontAwesomeIcons.userGroup,
                    '${city.meetupCount ?? 0}',
                    'Meetups',
                    Colors.purple,
                    isMobile,
                  ),
                  const SizedBox(width: 8),
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
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(width: 4),
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

  /// 版主状态徽章
  Widget _buildModeratorBadge(City city, bool isMobile) {
    final hasModerator = city.moderatorId != null;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 5 : 6,
        vertical: isMobile ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: hasModerator ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasModerator ? const Color(0xFF10B981) : Colors.orange,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasModerator ? FontAwesomeIcons.userCheck : FontAwesomeIcons.userXmark,
            color: hasModerator ? const Color(0xFF10B981) : Colors.orange,
            size: isMobile ? 8 : 10,
          ),
          SizedBox(width: isMobile ? 3 : 4),
          Text(
            hasModerator ? '版主' : '待版主',
            style: TextStyle(
              color: hasModerator ? const Color(0xFF10B981) : Colors.orange,
              fontSize: isMobile ? 9 : 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(4),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isMobile ? 12 : 14),
          const SizedBox(width: 4),
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
      child: const Icon(
        FontAwesomeIcons.city,
        color: Colors.white54,
        size: 40,
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
      AppToast.success(
        l10n.favoriteRemoved,
        title: l10n.removeFromFavorites,
      );
    }
  }
}
