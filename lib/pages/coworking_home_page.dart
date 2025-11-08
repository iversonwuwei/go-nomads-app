import 'package:df_admin_mobile/pages/add_coworking_page.dart';
import 'package:df_admin_mobile/pages/coworking_list_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../core/core.dart';
import '../features/city/application/use_cases/city_use_cases.dart';
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
  final GetCitiesWithCoworkingCountUseCase _getCitiesUseCase =
      Get.find<GetCitiesWithCoworkingCountUseCase>();
  List<Map<String, dynamic>> _cities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCitiesWithCoworkingCount();
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

  /// 刷新数据(仅重新加载数据,不重建整个页面)
  Future<void> _refreshData() async {
    await _loadCitiesWithCoworkingCount();
  }

  /// 加载城市及其coworking空间数量
  /// 使用 City 域的 UseCase
  Future<void> _loadCitiesWithCoworkingCount() async {
    try {
      setState(() => _isLoading = true);

      print('🏙️ 开始获取城市列表(含Coworking数量)...');

      // 使用 UseCase 获取数据
      final result = await _getCitiesUseCase.execute(
        const GetCitiesWithCoworkingCountParams(
          page: 1,
          pageSize: 100,
        ),
      );

      // 处理结果
      switch (result) {
        case Success(:final data):
          final cities = data['items'] as List<dynamic>;
          print('✅ 获取到 ${cities.length} 个城市');

          if (cities.isEmpty) {
            setState(() {
              _cities = [];
              _isLoading = false;
            });
            return;
          }

          // 组装城市数据,只保留有 coworking 空间的城市
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

          print('✅ 找到 ${citiesWithCount.length} 个有 Coworking 空间的城市');

          setState(() {
            _cities = citiesWithCount;
            _isLoading = false;
          });

        case Failure(:final exception):
          print('❌ 加载城市数据失败: ${exception.message}');
          setState(() => _isLoading = false);
          AppToast.error('加载失败: ${exception.message}');
      }
    } catch (e) {
      print('❌ 加载城市数据异常: $e');
      setState(() => _isLoading = false);
      AppToast.error('加载失败,请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coworkingSpaces),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Create Space Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // 等待添加页面返回,如果返回 true 则刷新数据
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCoworkingPage(),
                        ),
                      );

                      // 如果成功添加了 Coworking,刷新城市列表
                      if (result == true && mounted) {
                        await _refreshData();
                      }
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
        onTap: () async {
          // 等待列表页返回,如果返回 true 则刷新城市列表
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoworkingListPage(
                cityId: city['id'],
                cityName: city['name'],
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
