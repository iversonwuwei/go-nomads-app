import 'package:df_admin_mobile/pages/add_coworking_page.dart';
import 'package:df_admin_mobile/pages/coworking_list_page.dart';
import 'package:df_admin_mobile/services/cities_api_service.dart';
import 'package:df_admin_mobile/services/coworking_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';

/// Coworking Home Page
/// 共享办公空间首页 - 城市选择
class CoworkingHomePage extends StatefulWidget {
  const CoworkingHomePage({super.key});

  @override
  State<CoworkingHomePage> createState() => _CoworkingHomePageState();
}

class _CoworkingHomePageState extends State<CoworkingHomePage> {
  final CitiesApiService _citiesApiService = CitiesApiService();
  final CoworkingApiService _coworkingApiService = CoworkingApiService();
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

      // 1. 获取所有城市 (分页获取,这里先获取前100个)
      print('🏙️ 开始获取城市列表...');
      final citiesResponse = await _citiesApiService.getCities(
        page: 1,
        pageSize: 100,
      );

      final cities = citiesResponse['items'] as List<dynamic>;
      print('✅ 获取到 ${cities.length} 个城市');

      if (cities.isEmpty) {
        setState(() {
          _cities = [];
          _isLoading = false;
        });
        return;
      }

      // 2. 批量获取所有城市的 coworking 数量 (性能优化: 1次API调用代替N次)
      final cityIds = cities.map((c) => c['id'] as String).toList();
      print('📊 批量获取 ${cityIds.length} 个城市的 Coworking 数量...');
      
      final countMap = await _coworkingApiService.getCoworkingCountByCities(cityIds);
      print('✅ 成功获取批量统计数据: ${countMap.length} 个城市有 Coworking 空间');

      // 3. 组装城市数据,只保留有 coworking 空间的城市
      List<Map<String, dynamic>> citiesWithCount = [];

      for (var city in cities) {
        final cityId = city['id'] as String;
        final count = countMap[cityId] ?? 0;

        // 只添加有 coworking 空间的城市
        if (count > 0) {
          citiesWithCount.add({
            'id': cityId,
            'name': city['name'] as String,
            'country': city['country'] as String? ?? '',
            'image': city['imageUrl'] as String? ??
                'https://images.unsplash.com/photo-1449824913935-59a10b8d2000',
            'spaces': count,
          });
        }
      }

      print('✅ 找到 ${citiesWithCount.length} 个有 Coworking 空间的城市');

      setState(() {
        _cities = citiesWithCount;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 加载城市数据失败: $e');
      setState(() => _isLoading = false);
      AppToast.error('加载失败,请稍后重试');
    }
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
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
                            Icons.business,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.coworkingSpaces,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.workspace,
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

                // Create Space Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCoworkingPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 24),
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

                const SizedBox(height: 24),

                // Section Title
                Row(
                  children: [
                    const Icon(
                      Icons.explore,
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

                const SizedBox(height: 16),

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
