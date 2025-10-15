import 'package:df_admin_mobile/pages/coworking_list_page.dart';
import 'package:df_admin_mobile/services/data/city_data_service.dart';
import 'package:df_admin_mobile/services/data/coworking_data_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';

/// Coworking Home Page
/// 共享办公空间首页 - 城市选择
class CoworkingHomePage extends StatefulWidget {
  const CoworkingHomePage({super.key});

  @override
  State<CoworkingHomePage> createState() => _CoworkingHomePageState();
}

class _CoworkingHomePageState extends State<CoworkingHomePage> {
  final CityDataService _cityService = CityDataService();
  final CoworkingDataService _coworkingService = CoworkingDataService();
  List<Map<String, dynamic>> _cities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCitiesWithCoworkingCount();
  }

  /// 加载城市及其coworking空间数量
  Future<void> _loadCitiesWithCoworkingCount() async {
    try {
      setState(() => _isLoading = true);

      // 获取所有城市
      final cities = await _cityService.getAllCities();

      // 为每个城市统计coworking空间数量
      List<Map<String, dynamic>> citiesWithCount = [];

      for (var city in cities) {
        final coworkings =
            await _coworkingService.getCoworkingsByCity(city['id']);

        // 只添加有coworking空间的城市
        if (coworkings.isNotEmpty) {
          citiesWithCount.add({
            'id': city['id'], // 保持为整数
            'name': city['name'],
            'country': city['country'],
            'image': city['image_url'],
            'spaces': coworkings.length,
          });
        }
      }

      setState(() {
        _cities = citiesWithCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cities: $e');
      setState(() => _isLoading = false);
      // 使用备用数据
      _loadMockData();
    }
  }

  /// 加载模拟数据(备用)
  void _loadMockData() {
    setState(() {
      _cities = [
        {
          'id': '1',
          'name': 'Bangkok',
          'country': 'Thailand',
          'image':
              'https://images.unsplash.com/photo-1508009603885-50cf7c579365',
          'spaces': 0,
        },
        {
          'id': '2',
          'name': 'Chiang Mai',
          'country': 'Thailand',
          'image':
              'https://images.unsplash.com/photo-1598963166121-c4ec0d7c0179',
          'spaces': 0,
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(
              l10n.coworkingSpaces,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[500]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.business_center,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.workspace,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.coworkingSpaces,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withAlpha(230),
                              height: 1.4,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // City Grid
                _cities.isEmpty
                    ? Center(
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
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _cities.length,
                        itemBuilder: (context, index) {
                          final city = _cities[index];
                          return _buildCityCard(context, city);
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildCityCard(BuildContext context, Map<String, dynamic> city) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoworkingListPage(
                cityId: city['id'],
                cityName: city['name'],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: Image.network(
                    city['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.location_city, size: 50),
                      );
                    },
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
              padding: const EdgeInsets.all(4),
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
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
