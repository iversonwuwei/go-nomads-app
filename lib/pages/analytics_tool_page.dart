import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/copyright_widget.dart';

class AnalyticsToolPage extends StatelessWidget {
  const AnalyticsToolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AnalyticsController controller = Get.put(AnalyticsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.textSecondary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '分析工具',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w300,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined,
                color: AppColors.textSecondary),
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon:
                const Icon(Icons.tune_outlined, color: AppColors.textSecondary),
            onPressed: () => _showTimeRangeDialog(controller),
          ),
          const SizedBox(width: 8),
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                strokeWidth: 2,
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 时间范围选择器
                _buildTimeRangeSelector(controller),

                const SizedBox(height: 20),

                // 大类商品概览
                _buildOverviewCards(controller),

                const SizedBox(height: 20),

                // 主要K线图区域
                _buildKLineChart(controller),

                const SizedBox(height: 20),

                // 商品列表详情
                _buildCommodityList(controller),

                const SizedBox(height: 24),

                // 版权信息
                const CopyrightWidget(useTopMargin: false),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeRangeSelector(AnalyticsController controller) {
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          child: InkWell(
            onTap: () => _showTimeRangeDialog(controller),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 12),
                const Text(
                  '时间范围',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.selectedTimeRange.value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_outlined,
                    color: AppColors.textTertiary, size: 18),
              ],
            ),
          ),
        ));
  }

  Widget _buildOverviewCards(AnalyticsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final stats = controller.getOverviewStats();
        return Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                '大类商品',
                '${stats['totalCategories']}',
                Icons.category_outlined,
                const Color(0xFF64B5F6), // 低饱和蓝
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                '平均涨幅',
                '${stats['averageChange'].toStringAsFixed(2)}%',
                Icons.trending_up_outlined,
                const Color(0xFF81C784), // 低饱和绿
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                '成交量',
                '${stats['totalVolume']}',
                Icons.bar_chart_outlined,
                const Color(0xFFFFB74D), // 低饱和橙
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKLineChart(AnalyticsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图表标题
          Row(
            children: [
              const Icon(Icons.show_chart_outlined,
                  color: AppColors.textPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                '大类商品走势图',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '实时',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 模拟K线图区域
          _buildChartCanvas(controller),

          const SizedBox(height: 16),

          // 图例
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildChartCanvas(AnalyticsController controller) {
    return Obx(() {
      return Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: CustomPaint(
          painter: KLinePainter(controller.kLineData.toList()),
          size: const Size(double.infinity, 280),
        ),
      );
    });
  }

  Widget _buildChartLegend() {
    final List<Map<String, dynamic>> legends = [
      {'label': '电子产品', 'color': const Color(0xFF64B5F6)},
      {'label': '服装纺织', 'color': const Color(0xFF81C784)},
      {'label': '食品饮料', 'color': const Color(0xFFFFB74D)},
      {'label': '化工原料', 'color': const Color(0xFFE57373)},
      {'label': '机械设备', 'color': const Color(0xFFBA68C8)},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: legends.map((legend) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: legend['color'],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              legend['label'],
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCommodityList(AnalyticsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '商品详情',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // 只在这里使用Obx，响应commodities列表的变化
          Obx(() => Column(
                children: controller.commodities.map((commodity) {
                  return _buildCommodityItem(commodity);
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildCommodityItem(Map<String, dynamic> commodity) {
    final isPositive = commodity['change'] >= 0;
    final changeColor =
        isPositive ? const Color(0xFF81C784) : const Color(0xFFE57373);
    final changeIcon =
        isPositive ? Icons.trending_up_outlined : Icons.trending_down_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          // 商品图标
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: commodity['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              commodity['icon'],
              color: commodity['color'],
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity['name'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '当前价格: ¥${commodity['price']}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // 涨跌信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(changeIcon, color: changeColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''}${commodity['change'].toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '成交量: ${commodity['volume']}',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimeRangeDialog(AnalyticsController controller) {
    final timeRanges = [
      {'label': '最近 7 天', 'value': '7d'},
      {'label': '最近 30 天', 'value': '30d'},
      {'label': '最近 3 个月', 'value': '3m'},
      {'label': '最近 1 年', 'value': '1y'},
    ];

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text(
          '选择时间范围',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timeRanges.map((range) {
            return Obx(() {
              final isSelected =
                  controller.selectedTimeRange.value == range['value'];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.updateTimeRange(range['value']!);
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_outlined
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            range['label']!,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }
}

// 自定义K线图绘制器
class KLinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  KLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // 网格线画笔
    final gridPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 绘制水平网格线
    for (int i = 0; i <= 5; i++) {
      final y = size.height / 5 * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 绘制垂直网格线
    for (int i = 0; i <= 6; i++) {
      final x = size.width / 6 * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // 趋势线颜色
    final trendColors = [
      const Color(0xFF64B5F6), // 天蓝
      const Color(0xFF81C784), // 绿灰
      const Color(0xFFFFB74D), // 橙灰
      const Color(0xFFE57373), // 红灰
      const Color(0xFFBA68C8), // 紫灰
    ];

    // 绘制每个商品的趋势线
    for (int i = 0; i < data.length; i++) {
      final commodity = data[i];
      final points = commodity['points'] as List<double>;

      if (points.isEmpty) continue;

      final linePaint = Paint()
        ..color = trendColors[i % trendColors.length]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();

      // 找到最大值和最小值用于归一化
      final maxValue = points.reduce((a, b) => a > b ? a : b);
      final minValue = points.reduce((a, b) => a < b ? a : b);
      final range = maxValue - minValue;

      for (int j = 0; j < points.length; j++) {
        final x = size.width / (points.length - 1) * j;
        final normalizedValue =
            range > 0 ? (points[j] - minValue) / range : 0.5;
        final y = size.height -
            (normalizedValue * size.height * 0.8 + size.height * 0.1);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
