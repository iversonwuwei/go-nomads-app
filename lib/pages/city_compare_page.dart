import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';
import '../widgets/app_toast.dart';

/// 城市对比页面 - 并排比较多个城市
class CityComparePage extends StatefulWidget {
  const CityComparePage({super.key});

  @override
  State<CityComparePage> createState() => _CityComparePageState();
}

class _CityComparePageState extends State<CityComparePage> {
  // 用于对比的城市列表（最多3个）
  final List<Map<String, dynamic>> _selectedCities = [
    {
      'city': 'Bangkok',
      'country': 'Thailand',
      'price': 800,
      'internet': 150,
      'temperature': 32,
      'rank': 1,
      'overall': 4.8,
      'cost': 4.9,
      'safety': 4.5,
      'food': 4.8,
      'nightlife': 4.7,
      'image':
          'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=800',
    },
    {
      'city': 'Lisbon',
      'country': 'Portugal',
      'price': 1500,
      'internet': 120,
      'temperature': 22,
      'rank': 5,
      'overall': 4.6,
      'cost': 4.2,
      'safety': 4.8,
      'food': 4.6,
      'nightlife': 4.5,
      'image':
          'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=800',
    },
    {
      'city': 'Bali',
      'country': 'Indonesia',
      'price': 900,
      'internet': 100,
      'temperature': 30,
      'rank': 3,
      'overall': 4.7,
      'cost': 4.8,
      'safety': 4.4,
      'food': 4.7,
      'nightlife': 4.6,
      'image':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    },
  ];

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
        title: Text(
          'Compare Cities',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonLight),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _selectedCities.length < 3
                ? () {
                    AppToast.info(
                      'Select cities from the explore page',
                      title: 'Add City',
                    );
                  }
                : null,
          ),
        ],
      ),
      body: _selectedCities.isEmpty
          ? _buildEmptyState(isMobile)
          : isMobile
              ? _buildMobileView()
              : _buildDesktopView(),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: isMobile ? 80 : 120,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Cities to Compare',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add cities to start comparing their features',
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
                'Explore Cities',
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
  }

  // 移动端视图 - 垂直滚动卡片
  Widget _buildMobileView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 对比指标说明
        _buildComparisonHeader(true),
        const SizedBox(height: 16),

        // 城市卡片
        ..._selectedCities.asMap().entries.map((entry) {
          final index = entry.key;
          final city = entry.value;
          return _buildCityComparisonCard(city, index, true);
        }),
      ],
    );
  }

  // 桌面端视图 - 横向对比表格
  Widget _buildDesktopView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonHeader(false),
          const SizedBox(height: 24),
          _buildComparisonTable(),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: isMobile ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Compare up to 3 cities side by side',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
          Text(
            '${_selectedCities.length}/3',
            style: TextStyle(
              color: Colors.orange,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityComparisonCard(
      Map<String, dynamic> city, int index, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // 城市头部
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  city['image'],
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 150,
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
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedCities.removeAt(index);
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city['city'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      city['country'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 对比指标
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMetricRow(
                    'Rank', '#${city['rank']}', Icons.star, Colors.orange),
                const Divider(color: Colors.white24, height: 24),
                _buildMetricRow('Monthly Cost', '\$${city['price']}',
                    Icons.attach_money, Colors.green),
                const Divider(color: Colors.white24, height: 24),
                _buildMetricRow('Internet', '${city['internet']} Mbps',
                    Icons.wifi, Colors.blue),
                const Divider(color: Colors.white24, height: 24),
                _buildMetricRow('Temperature', '${city['temperature']}°C',
                    Icons.thermostat, Colors.red),
                const Divider(color: Colors.white24, height: 24),
                _buildScoreRow('Overall', city['overall'], Colors.orange),
                const Divider(color: Colors.white24, height: 24),
                _buildScoreRow('Cost', city['cost'], Colors.green),
                const Divider(color: Colors.white24, height: 24),
                _buildScoreRow('Safety', city['safety'], Colors.purple),
                const Divider(color: Colors.white24, height: 24),
                _buildScoreRow('Food', city['food'], Colors.red),
                const Divider(color: Colors.white24, height: 24),
                _buildScoreRow('Nightlife', city['nightlife'], Colors.blue),
              ],
            ),
          ),

          // 查看详情按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.cityDetail, arguments: city);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, double score, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 5,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonTable() {
    return Table(
      border: TableBorder.all(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        // 头部 - 城市图片和名称
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a1a),
          ),
          children: [
            _buildTableHeaderCell(''),
            ..._selectedCities.map((city) => _buildCityHeaderCell(city)),
          ],
        ),

        // 排名
        _buildTableRow(
            'Rank', Icons.star, Colors.orange, (city) => '#${city['rank']}'),

        // 价格
        _buildTableRow('Monthly Cost', Icons.attach_money, Colors.green,
            (city) => '\$${city['price']}'),

        // 网速
        _buildTableRow('Internet', Icons.wifi, Colors.blue,
            (city) => '${city['internet']} Mbps'),

        // 温度
        _buildTableRow('Temperature', Icons.thermostat, Colors.red,
            (city) => '${city['temperature']}°C'),

        // 总体评分
        _buildScoreTableRow(
            'Overall', Colors.orange, (city) => city['overall']),

        // 成本评分
        _buildScoreTableRow('Cost', Colors.green, (city) => city['cost']),

        // 安全评分
        _buildScoreTableRow('Safety', Colors.purple, (city) => city['safety']),

        // 美食评分
        _buildScoreTableRow('Food', Colors.red, (city) => city['food']),

        // 夜生活评分
        _buildScoreTableRow(
            'Nightlife', Colors.blue, (city) => city['nightlife']),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCityHeaderCell(Map<String, dynamic> city) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              city['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.location_city,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            city['city'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            city['country'],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, IconData icon, Color color,
      String Function(Map<String, dynamic>) getValue) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ..._selectedCities.map((city) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                getValue(city),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            )),
      ],
    );
  }

  TableRow _buildScoreTableRow(String label, Color color,
      double Function(Map<String, dynamic>) getScore) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
        ..._selectedCities.map((city) {
          final score = getScore(city);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: score / 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
