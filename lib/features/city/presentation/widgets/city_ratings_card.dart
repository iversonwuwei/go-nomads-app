import 'package:df_admin_mobile/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 城市评分卡片组件 - 极简现代风格
class CityRatingsCard extends StatefulWidget {
  final String cityId;

  const CityRatingsCard({
    super.key,
    required this.cityId,
  });

  @override
  State<CityRatingsCard> createState() => _CityRatingsCardState();
}

class _CityRatingsCardState extends State<CityRatingsCard> {
  bool _hasLoaded = false;
  String? _lastCityId;

  @override
  void initState() {
    super.initState();
    // 在第一帧渲染后加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(CityRatingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 cityId 变化，重新加载数据
    if (oldWidget.cityId != widget.cityId) {
      print('🔄 [CityRatingsCard] cityId 变化: ${oldWidget.cityId} -> ${widget.cityId}');
      _hasLoaded = false;
      _lastCityId = null;
      _loadData();
    }
  }

  void _loadData() {
    // 如果已经加载过相同城市，跳过
    if (_hasLoaded && _lastCityId == widget.cityId) {
      print('⏭️ [CityRatingsCard] 已加载过相同城市，跳过');
      return;
    }

    print('📥 [CityRatingsCard] 开始加载数据: cityId=${widget.cityId}');
    final controller = Get.find<CityRatingController>();
    controller.loadCityRatings(widget.cityId);
    _hasLoaded = true;
    _lastCityId = widget.cityId;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityRatingController>();

    return Obx(() {
      print('🎨 [CityRatingsCard] 重新构建 UI:');
      print('  - isLoading: ${controller.isLoading.value}');
      print('  - statistics.length: ${controller.statistics.length}');
      print('  - categories.length: ${controller.categories.length}');

      // 加载中状态 - 显示骨架屏
      if (controller.isLoading.value) {
        print('  ➡️ 显示骨架屏');
        return _buildSkeletonLoader();
      }

      // 无数据状态
      if (controller.statistics.isEmpty) {
        print('  ➡️ 无数据，返回空白');
        return const SizedBox.shrink();
      }

      print('  ➡️ 显示评分列表 (${controller.statistics.length} 项)');

      // 正常显示数据
      return Container(
        color: Colors.white, // 确保背景色
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 评分项列表
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.statistics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final stat = controller.statistics[index];
                print('🎯 [CityRatingsCard] 渲染第 ${index + 1} 项: ${stat.categoryName}');
                return _buildRatingItem(context, controller, stat);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRatingItem(
    BuildContext context,
    CityRatingController controller,
    dynamic stat,
  ) {
    final userRating = stat.userRating ?? 0;
    final averageRating = stat.averageRating;

    print('🎯 [评分项] ${stat.categoryName}:');
    print('   - userRating: $userRating');
    print('   - averageRating: $averageRating');
    print('   - ratingCount: ${stat.ratingCount}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：评分项内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 评分项名称
                Row(
                  children: [
                    if (stat.icon != null) ...[
                      Icon(
                        _getIconData(stat.icon!),
                        size: 18,
                        color: const Color(0xFF666666),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        stat.categoryName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 星星评分
                Row(
                  children: [
                    // 如果刚完成提交，显示加权平均分的星星（高亮显示）
                    if (controller.completedCategoryId.value == stat.categoryId)
                      ...List.generate(5, (index) {
                        final isFilled = index < averageRating.floor();
                        final isHalfFilled = index == averageRating.floor() && averageRating % 1 >= 0.5;

                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < 4 ? 6 : 0,
                          ),
                          child: _buildCompletedStar(
                            isFilled: isFilled,
                            isHalfFilled: isHalfFilled,
                          ),
                        );
                      })
                    // 否则显示星星评分（可点击）
                    else
                      ...List.generate(5, (index) {
                        final isActive = index < userRating;
                        final isFilled = index < averageRating.floor();
                        final isHalfFilled = index == averageRating.floor() && averageRating % 1 >= 0.5;

                        return GestureDetector(
                          onTap: () {
                            controller.submitRating(stat.categoryId, index + 1);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < 4 ? 6 : 0,
                            ),
                            child: _buildStar(
                              isActive: isActive,
                              isFilled: isFilled,
                              isHalfFilled: isHalfFilled,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 右侧：加权平均分
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stat.ratingCount}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStar({
    required bool isActive,
    required bool isFilled,
    required bool isHalfFilled,
  }) {
    // 确定背景色 - 统一使用相同背景色
    Color backgroundColor;
    if (isFilled || isHalfFilled || isActive) {
      backgroundColor = const Color(0xFFFFE5E8); // 有评分:浅粉色背景
    } else {
      backgroundColor = Colors.grey[50]!; // 无评分:极浅灰背景
    }

    // 确定星星图标和颜色 - 统一使用相同颜色
    IconData starIcon;
    Color starColor;

    if (isFilled || isActive) {
      starIcon = FontAwesomeIcons.solidStar; // 实心星
      starColor = const Color(0xFFFF4458); // 红色
    } else if (isHalfFilled) {
      starIcon = FontAwesomeIcons.starHalfAlt; // 半星
      starColor = const Color(0xFFFF4458); // 红色
    } else {
      starIcon = FontAwesomeIcons.star; // 无评分：空心星
      starColor = Colors.grey[300]!; // 浅灰色
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        starIcon,
        size: 16,
        color: starColor,
      ),
    );
  }

  /// 构建完成状态的星星（提交成功后显示加权平均分）
  Widget _buildCompletedStar({
    required bool isFilled,
    required bool isHalfFilled,
  }) {
    // 确定星星图标
    IconData starIcon;
    if (isFilled) {
      starIcon = FontAwesomeIcons.solidStar; // 实心星
    } else if (isHalfFilled) {
      starIcon = FontAwesomeIcons.starHalfAlt; // 半星
    } else {
      starIcon = FontAwesomeIcons.star; // 空心星
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isFilled || isHalfFilled
            ? const Color(0xFF10B981) // 更柔和的绿色
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        starIcon,
        size: 16,
        color: isFilled || isHalfFilled ? Colors.white : Colors.grey[400],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'attach_money': FontAwesomeIcons.dollarSign,
      'wb_sunny': FontAwesomeIcons.sun,
      'directions_bus': FontAwesomeIcons.bus,
      'restaurant': FontAwesomeIcons.utensils,
      'security': FontAwesomeIcons.shieldHalved,
      'wifi': FontAwesomeIcons.wifi,
      'local_activity': FontAwesomeIcons.ticket,
      'local_hospital': FontAwesomeIcons.hospitalUser,
      'people': FontAwesomeIcons.users,
      'language': FontAwesomeIcons.globe,
    };
    return iconMap[iconName] ?? FontAwesomeIcons.star;
  }

  /// 骨架屏加载器
  Widget _buildSkeletonLoader() {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) => _buildSkeletonItem(),
      ),
    );
  }

  /// 单个评分项骨架
  Widget _buildSkeletonItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 名称骨架 - 带图标
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 80,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 星星骨架 - 使用实际尺寸 28x28
                Row(
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < 4 ? 6 : 0,
                      ),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 分数骨架
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 36,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 16,
                  height: 11,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
