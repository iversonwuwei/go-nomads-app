import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/data_service_controller.dart';
import '../widgets/skeleton_loader.dart';
import 'city_detail_page.dart';

/// 城市列表页面 - 支持国家、城市和搜索筛选
class CityListPage extends StatefulWidget {
  const CityListPage({super.key});

  @override
  State<CityListPage> createState() => _CityListPageState();
}

class _CityListPageState extends State<CityListPage> {
  final DataServiceController controller = Get.put(DataServiceController());
  final TextEditingController _searchController = TextEditingController();

  String _selectedCountry = 'All Countries';
  String _selectedCity = 'All Cities';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 获取筛选后的城市列表
  List<Map<String, dynamic>> get _filteredCities {
    var items = controller.dataItems.toList();

    // 按国家筛选
    if (_selectedCountry != 'All Countries') {
      items =
          items.where((item) => item['country'] == _selectedCountry).toList();
    }

    // 按城市筛选
    if (_selectedCity != 'All Cities') {
      items = items.where((item) => item['city'] == _selectedCity).toList();
    }

    // 按搜索关键词筛选
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      items = items.where((item) {
        final city = (item['city'] as String).toLowerCase();
        final country = (item['country'] as String).toLowerCase();
        return city.contains(query) || country.contains(query);
      }).toList();
    }

    return items;
  }

  // 获取可用城市列表（基于当前国家筛选）
  List<String> get _availableCities {
    if (_selectedCountry == 'All Countries') {
      return ['All Cities', ...controller.availableCities];
    }

    final cities = controller.dataItems
        .where((item) => item['country'] == _selectedCountry)
        .map((item) => item['city'] as String)
        .toSet()
        .toList()
      ..sort();

    return ['All Cities', ...cities];
  }

  void _clearFilters() {
    setState(() {
      _selectedCountry = 'All Countries';
      _selectedCity = 'All Cities';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Explore Cities',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonLoader(type: SkeletonType.list);
        }

        return Column(
          children: [
            // 筛选栏
            _buildFilterBar(isMobile),

            // 城市列表
            Expanded(
              child: _filteredCities.isEmpty
                  ? _buildEmptyState()
                  : _buildCityList(isMobile),
            ),
          ],
        );
      }),
    );
  }

  // 筛选栏
  Widget _buildFilterBar(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        children: [
          // 搜索框
          _buildSearchField(),
          const SizedBox(height: 12),

          // 筛选按钮行
          Row(
            children: [
              // 国家筛选
              Expanded(
                child: _buildCountryDropdown(),
              ),
              const SizedBox(width: 12),

              // 城市筛选
              Expanded(
                child: _buildCityDropdown(),
              ),
              const SizedBox(width: 12),

              // 清除筛选按钮
              IconButton(
                icon: const Icon(Icons.filter_alt_off),
                color: const Color(0xFFFF4458),
                tooltip: 'Clear filters',
                onPressed: _clearFilters,
              ),
            ],
          ),

          // 结果数量
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_filteredCities.length} cities found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_selectedCountry != 'All Countries' ||
                  _selectedCity != 'All Cities' ||
                  _searchQuery.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Filtered',
                    style: TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 搜索框
  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search city or country...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
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
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  // 国家下拉菜单
  Widget _buildCountryDropdown() {
    final countries = ['All Countries', ...controller.availableCountries];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          items: countries.map((country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Row(
                children: [
                  Icon(
                    country == 'All Countries' ? Icons.public : Icons.flag,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      country,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCountry = value!;
              // 如果改变国家，重置城市筛选
              if (value != 'All Countries') {
                _selectedCity = 'All Cities';
              }
            });
          },
        ),
      ),
    );
  }

  // 城市下拉菜单
  Widget _buildCityDropdown() {
    final cities = _availableCities;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: cities.contains(_selectedCity) ? _selectedCity : 'All Cities',
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          items: cities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Row(
                children: [
                  Icon(
                    city == 'All Cities'
                        ? Icons.location_city
                        : Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      city,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value!;
            });
          },
        ),
      ),
    );
  }

  // 城市列表
  Widget _buildCityList(bool isMobile) {
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        return _buildCityCard(city, isMobile);
      },
    );
  }

  // 城市卡片
  Widget _buildCityCard(Map<String, dynamic> city, bool isMobile) {
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
          Get.to(
            () => CityDetailPage(
              cityId: city['id']?.toString() ?? city['city'],
              cityName: city['city'],
              cityImage: city['image'],
              overallScore: (city['score'] as num?)?.toDouble() ?? 0.0,
              reviewCount: city['reviews'] ?? 0,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  city['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 48),
                    );
                  },
                ),
              ),
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
                              city['city'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  city['country'],
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
                              Icons.star,
                              size: 16,
                              color: Color(0xFFFF4458),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (city['score'] ?? 0.0).toString(),
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
                        Icons.wb_sunny,
                        '${city['temperature'] ?? 0}°',
                        Colors.orange,
                      ),
                      _buildInfoChip(
                        Icons.wifi,
                        '${city['internet'] ?? 0} Mbps',
                        Colors.blue,
                      ),
                      _buildInfoChip(
                        Icons.attach_money,
                        '\$${city['cost'] ?? 0}',
                        Colors.green,
                      ),
                      if (city['aqi'] != null)
                        _buildInfoChip(
                          Icons.air,
                          'AQI ${city['aqi']}',
                          _getAqiColor(city['aqi']),
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

  // 空状态
  Widget _buildEmptyState() {
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
                Icons.search_off,
                size: 64,
                color: Color(0xFFFF4458),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No cities found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or search query',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear Filters'),
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
  }
}
