import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';
import '../widgets/app_toast.dart';
import 'city_detail_page.dart';

/// 收藏夹页面 - 管理收藏的城市
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // 模拟收藏的城市数据
  final List<Map<String, dynamic>> _favoriteCities = [
    {
      'city': 'Bangkok',
      'country': 'Thailand',
      'price': 800,
      'internet': 150,
      'temperature': 32,
      'rank': 1,
      'image':
          'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=800',
      'overall': 4.8,
      'addedDate': '2025-01-15',
    },
    {
      'city': 'Lisbon',
      'country': 'Portugal',
      'price': 1500,
      'internet': 120,
      'temperature': 22,
      'rank': 5,
      'image':
          'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=800',
      'overall': 4.6,
      'addedDate': '2025-01-10',
    },
    {
      'city': 'Bali',
      'country': 'Indonesia',
      'price': 900,
      'internet': 100,
      'temperature': 30,
      'rank': 3,
      'image':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
      'overall': 4.7,
      'addedDate': '2025-01-08',
    },
  ];

  String _sortBy = 'date'; // date, price, rank, name

  void _sortCities() {
    setState(() {
      switch (_sortBy) {
        case 'date':
          _favoriteCities.sort((a, b) =>
              b['addedDate'].toString().compareTo(a['addedDate'].toString()));
          break;
        case 'price':
          _favoriteCities.sort((a, b) => a['price'].compareTo(b['price']));
          break;
        case 'rank':
          _favoriteCities.sort((a, b) => a['rank'].compareTo(b['rank']));
          break;
        case 'name':
          _favoriteCities.sort(
              (a, b) => a['city'].toString().compareTo(b['city'].toString()));
          break;
      }
    });
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
        title: Column(
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
              '${_favoriteCities.length} ${l10n.cities}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonLight),
          onPressed: () => Get.back(),
        ),
        actions: [
          // 排序按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: const Color(0xFF1a1a1a),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _sortCities();
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return [
                _buildPopupMenuItem('date', l10n.date, Icons.calendar_today),
                _buildPopupMenuItem('price', l10n.price, Icons.attach_money),
                _buildPopupMenuItem('rank', l10n.ranking, Icons.star),
                _buildPopupMenuItem('name', l10n.name, Icons.sort_by_alpha),
              ];
            },
          ),
        ],
      ),
      body: _favoriteCities.isEmpty
          ? _buildEmptyState(isMobile)
          : ListView.builder(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              itemCount: _favoriteCities.length,
              itemBuilder: (context, index) {
                final city = _favoriteCities[index];
                return _buildFavoriteCard(city, isMobile, index);
              },
            ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, String label, IconData icon) {
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
            const Icon(Icons.check, color: Colors.orange, size: 20),
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
                  Icons.favorite_border,
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

  Widget _buildFavoriteCard(
      Map<String, dynamic> city, bool isMobile, int index) {
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CityDetailPage(
                cityId: city['city']?.toString() ?? '',
                cityName: city['city']?.toString() ?? '',
                cityImage: city['image']?.toString() ?? '',
                overallScore: (city['overall'] as num?)?.toDouble() ?? 0.0,
                reviewCount: 0,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 城市图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  city['image'],
                  width: isMobile ? 80 : 120,
                  height: isMobile ? 80 : 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: isMobile ? 80 : 120,
                      height: isMobile ? 80 : 120,
                      color: Colors.white.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.location_city,
                        color: Colors.white54,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // 城市信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 城市名称和排名
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            city['city'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                          child: Text(
                            '#${city['rank']}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 国家
                    Text(
                      city['country'],
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
                        _buildInfoChip(
                          Icons.attach_money,
                          '\$${city['price']}/mo',
                          Colors.green,
                          isMobile,
                        ),
                        _buildInfoChip(
                          Icons.wifi,
                          '${city['internet']} Mbps',
                          Colors.blue,
                          isMobile,
                        ),
                        _buildInfoChip(
                          Icons.thermostat,
                          '${city['temperature']}°C',
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
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      final l10n = AppLocalizations.of(context)!;
                      setState(() {
                        _favoriteCities.removeAt(index);
                      });
                      AppToast.success(
                        l10n.favoriteRemoved,
                        title: l10n.removeFromFavorites,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CityDetailPage(
                            cityId: city['city']?.toString() ?? '',
                            cityName: city['city']?.toString() ?? '',
                            cityImage: city['image']?.toString() ?? '',
                            overallScore:
                                (city['overall'] as num?)?.toDouble() ?? 0.0,
                            reviewCount: 0,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String label, Color color, bool isMobile) {
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
