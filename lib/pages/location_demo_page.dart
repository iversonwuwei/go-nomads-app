import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/location_controller.dart';
import '../widgets/location_widgets.dart';

/// 位置服务演示页面
class LocationDemoPage extends StatelessWidget {
  const LocationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化位置控制器
    final controller = Get.put(LocationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('位置服务'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 位置信息卡片
            const LocationInfoWidget(),

            const SizedBox(height: 24),

            // 位置详情
            const Text(
              '位置详情',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Obx(() {
              final position = controller.currentPosition.value;
              
              if (position == null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      '暂无位置信息',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('纬度', position.latitude.toStringAsFixed(6)),
                    const Divider(height: 24),
                    _buildInfoRow('经度', position.longitude.toStringAsFixed(6)),
                    const Divider(height: 24),
                    _buildInfoRow('精度', '±${position.accuracy.toStringAsFixed(1)}m'),
                    const Divider(height: 24),
                    _buildInfoRow('海拔', '${position.altitude.toStringAsFixed(1)}m'),
                    const Divider(height: 24),
                    _buildInfoRow('速度', '${position.speed.toStringAsFixed(1)}m/s'),
                    const Divider(height: 24),
                    _buildInfoRow(
                      '时间',
                      position.timestamp.toString().split('.')[0],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // 距离计算示例
            const Text(
              '距离计算',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // 示例城市
            _buildCityDistanceCard(
              controller,
              '北京',
              'China',
              39.9042,
              116.4074,
              Icons.location_city,
            ),

            const SizedBox(height: 12),

            _buildCityDistanceCard(
              controller,
              '上海',
              'China',
              31.2304,
              121.4737,
              Icons.apartment,
            ),

            const SizedBox(height: 12),

            _buildCityDistanceCard(
              controller,
              '深圳',
              'China',
              22.5431,
              114.0579,
              Icons.business,
            ),

            const SizedBox(height: 24),

            // 操作按钮
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final isAutoUpdating = controller.isAutoUpdating.value;
                
                return ElevatedButton.icon(
                  onPressed: () {
                    if (isAutoUpdating) {
                      controller.stopAutoUpdate();
                    } else {
                      controller.startAutoUpdate();
                    }
                  },
                  icon: Icon(
                    isAutoUpdating ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    isAutoUpdating ? '停止自动更新(5秒/次)' : '开始自动更新(5秒/次)',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAutoUpdating 
                        ? Colors.orange 
                        : const Color(0xFFFF4458),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.refreshLocation(),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  '手动刷新位置',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4458),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.openLocationSettings(),
                icon: const Icon(Icons.settings, color: AppColors.textSecondary),
                label: const Text(
                  '位置设置',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCityDistanceCard(
    LocationController controller,
    String cityName,
    String country,
    double lat,
    double lng,
    IconData icon,
  ) {
    return Obx(() {
      final distance = controller.calculateDistanceToCity(lat, lng);
      final distanceText = controller.formatDistance(distance);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF4458),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    country,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                distanceText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
