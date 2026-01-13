import 'package:cached_network_image/cached_network_image.dart';
import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 城市列表卡片组件
class CityListCard extends StatelessWidget {
  final City city;
  final bool isMobile;
  final bool isFollowed;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  const CityListCard({
    super.key,
    required this.city,
    required this.isMobile,
    required this.isFollowed,
    required this.onTap,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🏙️ City: ${city.name}, ReviewCount: ${city.reviewCount}, AverageCost: ${city.averageCost}, OverallScore: ${city.overallScore}');

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: city.imageUrl != null && city.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: city.imageUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 900,
                            memCacheHeight: 900,
                            placeholder: (_, __) => Container(color: Colors.grey[200]),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(FontAwesomeIcons.imagePortrait, size: 48),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(FontAwesomeIcons.imagePortrait, size: 48),
                          ),
                  ),
                ),
                // 左上角：生成图片按钮（仅管理员可见）
                Obx(() {
                  final authController = Get.find<AuthStateController>();
                  final user = authController.currentUser.value;
                  final isAdmin = user?.role.toLowerCase() == 'admin';

                  if (!isAdmin) return const SizedBox.shrink();

                  return Positioned(
                    top: 12,
                    left: 12,
                    child: _GenerateImageButton(
                      cityId: city.id,
                      cityName: city.name,
                    ),
                  );
                }),
                // 右上角：关注按钮
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildFollowButton(),
                ),
              ],
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
                              city.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(FontAwesomeIcons.locationDot, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  city.country ?? '',
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
                              FontAwesomeIcons.star,
                              size: 16,
                              color: Color(0xFFFF4458),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (city.overallScore ?? 0.0).toStringAsFixed(1),
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

                  // 指标标签（单行可滚动）
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 💰 月均花费
                        _buildInfoChip(
                          FontAwesomeIcons.dollarSign,
                          city.averageCost != null && city.averageCost! > 0
                              ? '\$${city.averageCost!.toInt()}/mo'
                              : '\$0/mo',
                          city.averageCost != null && city.averageCost! > 0 ? Colors.green : Colors.grey,
                        ),
                        // 📶 网络评分
                        if (city.internetScore != null && city.internetScore! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.wifi,
                            city.internetScore!.toStringAsFixed(1),
                            _getScoreColor(city.internetScore!),
                          ),
                        ],
                        // 🛡️ 安全评分
                        if (city.safetyScore != null && city.safetyScore! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.shield,
                            city.safetyScore!.toStringAsFixed(1),
                            _getScoreColor(city.safetyScore!),
                          ),
                        ],
                        // 👥 社区活跃度
                        if (city.communityScore != null && city.communityScore! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.peopleGroup,
                            city.communityScore!.toStringAsFixed(1),
                            _getScoreColor(city.communityScore!),
                          ),
                        ],
                        // 💻 Coworking 空间数量
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          FontAwesomeIcons.laptop,
                          '${city.coworkingCount ?? 0}',
                          (city.coworkingCount ?? 0) > 0 ? Colors.blue : Colors.grey,
                        ),
                        // 🎉 Meetup 数量
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          FontAwesomeIcons.userGroup,
                          '${city.meetupCount ?? 0}',
                          (city.meetupCount ?? 0) > 0 ? Colors.purple : Colors.grey,
                        ),
                        // 💬 评论数量
                        if (city.reviewCount != null && city.reviewCount! > 0) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            FontAwesomeIcons.comments,
                            '${city.reviewCount}',
                            Colors.teal,
                          ),
                        ],
                        // 👤 版主状态
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          city.hasModerator ? FontAwesomeIcons.userShield : FontAwesomeIcons.userSlash,
                          city.hasModerator ? 'Mod' : 'No Mod',
                          city.hasModerator ? Colors.green : Colors.grey,
                        ),
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

  // 关注按钮
  Widget _buildFollowButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 阻止事件冒泡到外层 InkWell
      onTap: onFollowTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isFollowed ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.heart,
              size: 16,
              color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 4),
            Text(
              isFollowed ? '已关注' : '关注',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 根据评分获取颜色
  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
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
}

/// 生成城市图片按钮组件
class _GenerateImageButton extends StatelessWidget {
  final String cityId;
  final String cityName;

  const _GenerateImageButton({
    required this.cityId,
    required this.cityName,
  });

  Future<void> _generateImages() async {
    final cityController = Get.find<CityStateController>();

    // 检查是否正在生成
    if (cityController.isGeneratingImages(cityId)) return;

    // 检查登录状态
    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning(
        'Please login to generate images',
        title: 'Login Required',
      );
      Get.toNamed(AppRoutes.login);
      return;
    }

    // 检查是否是管理员
    final user = authController.currentUser.value;
    final userRole = user?.role.toLowerCase() ?? '';
    if (userRole != 'admin') {
      AppToast.warning(
        'Only administrators can generate images',
        title: 'Permission Denied',
      );
      return;
    }

    AppToast.info(
      'AI image generation task created for $cityName.\nYou will be notified when complete.',
      title: 'Task Created',
    );

    final result = await cityController.generateCityImages(cityId);

    result.fold(
      onSuccess: (data) {
        final taskData = data['data'] as Map<String, dynamic>?;
        final taskId = taskData?['taskId'] as String? ?? '';
        debugPrint('🖼️ Image generation task created: taskId=$taskId');
      },
      onFailure: (exception) {
        AppToast.error(
          exception.message,
          title: 'Task Creation Failed',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityController = Get.find<CityStateController>();

    return Obx(() {
      final isGenerating = cityController.isGeneratingImages(cityId);

      return GestureDetector(
        behavior: HitTestBehavior.opaque, // 阻止事件冒泡到外层 InkWell
        onTap: isGenerating ? null : _generateImages,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isGenerating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      FontAwesomeIcons.arrowsRotate,
                      color: Colors.white,
                      size: 14,
                    ),
              const SizedBox(width: 4),
              Text(
                isGenerating ? '生成中...' : '更新图片',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
