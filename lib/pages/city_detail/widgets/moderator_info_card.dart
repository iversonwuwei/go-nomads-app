import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:df_admin_mobile/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:df_admin_mobile/features/membership/presentation/pages/membership_plan_page.dart';
import 'package:df_admin_mobile/pages/apply_moderator/apply_moderator.dart';
import 'package:df_admin_mobile/pages/assign_moderator/assign_moderator.dart';
import 'package:df_admin_mobile/pages/member_detail_page.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 版主信息卡片 - 显示在城市详情页的版主区域
///
/// 功能:
/// - 显示当前版主信息（如有）
/// - 提供申请成为版主的入口
/// - 提供更换版主的入口（仅版主/管理员可见）
class ModeratorInfoCard extends StatelessWidget {
  const ModeratorInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cityController = Get.find<CityDetailStateController>();
      final city = cityController.currentCity.value;

      if (city == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: city.hasModerator ? _buildModeratorInfo(context, city) : _buildApplyModeratorSection(context, city),
      );
    });
  }

  /// 构建版主信息区域（已有版主）
  Widget _buildModeratorInfo(BuildContext context, City city) {
    final moderator = city.moderator;
    final isCurrentUserModerator = city.isCurrentUserModerator;
    final isAdmin = city.isCurrentUserAdmin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            Icon(
              FontAwesomeIcons.userShield,
              color: AppColors.cityPrimary,
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              '城市版主',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            // 版主状态徽章
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.check,
                    size: 10,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '已认证',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 版主信息卡片
        InkWell(
          onTap: moderator != null ? () => Get.to(() => MemberDetailPage(userId: moderator.id)) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cityPrimary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: moderator?.avatar != null
                        ? SafeNetworkImage(
                            imageUrl: moderator!.avatar!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.cityPrimary.withValues(alpha: 0.1),
                            child: Icon(
                              FontAwesomeIcons.user,
                              size: 20,
                              color: AppColors.cityPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // 版主名称和信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moderator?.name ?? '未知版主',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (moderator?.stats != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${moderator!.stats!.countriesVisited} 个国家 · ${moderator.stats!.citiesVisited} 个城市',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 箭头
                Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),

        // 更换版主按钮（仅管理员或当前版主可见）
        if (isAdmin || isCurrentUserModerator) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showTransferModeratorDialog(context, city),
            icon: Icon(
              FontAwesomeIcons.arrowRightArrowLeft,
              size: 14,
            ),
            label: const Text('转让版主'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 构建申请版主区域（无版主）
  Widget _buildApplyModeratorSection(BuildContext context, City city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            Icon(
              FontAwesomeIcons.userSlash,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              '城市版主',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            // 无版主状态徽章
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.exclamation,
                    size: 10,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '待认领',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 提示信息
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.lightbulb,
                size: 16,
                color: Colors.orange[700],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '这座城市正在寻找版主！如果你熟悉这里，可以申请成为版主，帮助其他数字游民了解这座城市。',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 申请按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToApplyModerator(context, city),
            icon: Icon(
              FontAwesomeIcons.userPlus,
              size: 14,
            ),
            label: const Text('申请成为版主'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// 导航到申请版主页面
  void _navigateToApplyModerator(BuildContext context, City city) {
    // 检查会员等级，只有 Pro 及以上才能申请版主
    final membershipController = Get.find<MembershipStateController>();

    if (!membershipController.canApplyModerator) {
      _showUpgradeMembershipDialog(context);
      return;
    }

    Get.to(
      () => const ApplyModeratorPage(),
      binding: ApplyModeratorBinding(),
      arguments: city,
    );
  }

  /// 显示升级会员对话框
  void _showUpgradeMembershipDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.crown,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('需要升级会员'),
          ],
        ),
        content: const Text(
          '申请成为城市版主需要 Pro 会员或更高等级。\n\n'
          '升级到 Pro 会员后，您将获得：\n'
          '• 申请成为城市版主的资格\n'
          '• 更多 AI 使用次数\n'
          '• 专属会员徽章\n'
          '• 更多高级功能',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('稍后再说'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.to(() => const MembershipPlanPage());
            },
            icon: const Icon(FontAwesomeIcons.arrowUp, size: 14),
            label: const Text('立即升级'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 导航到指定版主页面（转让版主）
  void _showTransferModeratorDialog(BuildContext context, City city) {
    Get.to(
      () => const AssignModeratorPage(),
      binding: AssignModeratorBinding(),
      arguments: city,
    );
  }
}
