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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 城市图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: isMobile ? 80 : 120,
                        height: isMobile ? 80 : 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(isMobile);
                        },
                      )
                    : _buildPlaceholderImage(isMobile),
              ),

              const SizedBox(width: 16),

              // 城市信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 城市名称和评分
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            city.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (city.overallScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.solidStar,
                                  color: Colors.orange,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  city.overallScore!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 国家
                    if (city.country != null)
                      Text(
                        city.country!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),

                    const SizedBox(height: 12),

                    // 详细信息
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (city.averageCost != null)
                          _buildInfoChip(
                            FontAwesomeIcons.dollarSign,
                            '\$${city.averageCost!.toInt()}/mo',
                            Colors.green,
                            isMobile,
                          ),
                        if (city.internetScore != null)
                          _buildInfoChip(
                            FontAwesomeIcons.wifi,
                            '${(city.internetScore! * 20).toInt()} Mbps',
                            Colors.blue,
                            isMobile,
                          ),
                        if (city.temperature != null)
                          _buildInfoChip(
                            FontAwesomeIcons.temperatureHalf,
                            '${city.temperature}°C',
                            Colors.orange,
                            isMobile,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 操作按钮
              Column(
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.solidHeart, color: Colors.red),
                    onPressed: () => _unfavoriteCity(city, l10n),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.arrowRight,
                      color: Colors.white70,
                    ),
                    onPressed: () => _navigateToCityDetail(city),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isMobile) {
    return Container(
      width: isMobile ? 80 : 120,
      height: isMobile ? 80 : 120,
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

  Widget _buildInfoChip(IconData icon, String label, Color color, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: isMobile ? 14 : 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ],
    );
  }
}
