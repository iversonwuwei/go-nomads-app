import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/analytics_controller.dart';

class AnalyticsToolPage extends StatelessWidget {
  const AnalyticsToolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AnalyticsController controller = Get.put(AnalyticsController());
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '商品分析工具',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showTimeRangeDialog(controller),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // 时间范围选择器
              _buildTimeRangeSelector(controller),
              
              // 大类商品概览
              _buildOverviewCards(controller),
              
              // 主要K线图区域
              _buildKLineChart(controller),
              
              // 商品列表详情
              _buildCommodityList(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimeRangeSelector(AnalyticsController controller) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: GestureDetector(
        onTap: () => _showTimeRangeDialog(controller),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.white70, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              '时间范围：',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
            Expanded(
              child: Obx(() => Text(
                controller.selectedTimeRange.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              )),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(AnalyticsController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final stats = controller.getOverviewStats();
        return Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                '大类商品',
                '${stats['totalCategories']}',
                Icons.category,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildOverviewCard(
                '平均涨幅',
                '${stats['averageChange'].toStringAsFixed(2)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildOverviewCard(
                '成交量',
                '${stats['totalVolume']}',
                Icons.bar_chart,
                Colors.orange,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKLineChart(AnalyticsController controller) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图表标题
          Row(
            children: [
              Icon(Icons.show_chart, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '大类商品走势图',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '实时',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // 模拟K线图区域
          Container(
            height: 300.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: CustomPaint(
              painter: KLinePainter(controller.kLineData),
              size: Size(double.infinity, 300.h),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 图例
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final List<Map<String, dynamic>> legends = [
      {'label': '电子产品', 'color': Colors.blue},
      {'label': '服装纺织', 'color': Colors.green},
      {'label': '食品饮料', 'color': Colors.orange},
      {'label': '化工原料', 'color': Colors.red},
      {'label': '机械设备', 'color': Colors.purple},
    ];

    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: legends.map((legend) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: legend['color'],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              legend['label'],
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCommodityList(AnalyticsController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品详情',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() => Column(
            children: controller.commodities.map((commodity) {
              return _buildCommodityItem(commodity);
            }).toList(),
          )),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildCommodityItem(Map<String, dynamic> commodity) {
    final isPositive = commodity['change'] >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // 商品图标
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: commodity['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              commodity['icon'],
              color: commodity['color'],
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '当前价格: ¥${commodity['price']}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
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
                  Icon(changeIcon, color: changeColor, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '${isPositive ? '+' : ''}${commodity['change'].toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '成交量: ${commodity['volume']}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimeRangeDialog(AnalyticsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          '选择时间范围',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            '最近7天',
            '最近30天',
            '最近3个月',
            '最近1年',
          ].map((range) {
            return ListTile(
              title: Text(
                range,
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                controller.updateTimeRange(range);
                Get.back();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// 自定义K线图绘制器
class KLinePainter extends CustomPainter {
  final RxList<Map<String, dynamic>> data;

  KLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 绘制网格线
    _drawGrid(canvas, size);

    // 绘制多条商品走势线
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
    
    for (int i = 0; i < 5; i++) {
      paint.color = colors[i];
      _drawTrendLine(canvas, size, i, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // 垂直网格线
    for (int i = 0; i <= 7; i++) {
      final x = (size.width / 7) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // 水平网格线
    for (int i = 0; i <= 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  void _drawTrendLine(Canvas canvas, Size size, int lineIndex, Paint paint) {
    final path = Path();
    final pointCount = 30;
    final baseValue = 100 + lineIndex * 10;
    
    for (int i = 0; i < pointCount; i++) {
      final x = (size.width / (pointCount - 1)) * i;
      // 模拟价格波动
      final noise = math.sin(i * 0.3 + lineIndex) * 20 + math.cos(i * 0.1) * 10;
      final trend = i * 0.5; // 整体上升趋势
      final y = size.height - ((baseValue + noise + trend) / (baseValue + 50)) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}