import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_detail.dart';
import 'package:df_admin_mobile/pages/city_detail/city_detail_controller.dart';
import 'package:df_admin_mobile/pages/manage_pros_cons_page.dart';
import 'package:df_admin_mobile/pages/pros_and_cons_add_page.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// Pros & Cons Tab - 优缺点标签页
/// 使用 GetView 绑定 CityDetailController
class ProsConsTab extends GetView<CityDetailController> {
  @override
  final String? tag;

  const ProsConsTab({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final prosConsController = Get.find<ProsConsStateController>();

    return Obx(() {
      final isLoading = prosConsController.isLoadingPros.value || prosConsController.isLoadingCons.value;

      if (isLoading) {
        return const ProsConsTabSkeleton();
      }

      return RefreshIndicator(
        onRefresh: () => prosConsController.loadCityProsCons(controller.cityId),
        child: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
          children: [
            // 优点部分
            const Text(
              '优点',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (prosConsController.prosList.isEmpty)
              _EmptyProsConsState(
                icon: FontAwesomeIcons.circleCheck,
                iconColor: Colors.green,
                title: '还没有优点',
                subtitle: '分享你在这座城市的美好体验',
                buttonText: '添加优点',
                onTap: () => _showAddProsConsPage(context, initialTab: 0),
              )
            else
              ...prosConsController.prosList.map((item) => _ProsConsItem(
                    item: item,
                    isPro: true,
                    hasVoted: prosConsController.hasUserVoted(item.id),
                    onVote: () => _handleVote(prosConsController, item),
                  )),

            const SizedBox(height: 24),

            // 挑战部分
            const Text(
              '挑战',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (prosConsController.consList.isEmpty)
              _EmptyProsConsState(
                icon: FontAwesomeIcons.ban,
                iconColor: Colors.red,
                title: '还没有挑战',
                subtitle: '分享你遇到的困难和需要改进的地方',
                buttonText: '添加挑战',
                onTap: () => _showAddProsConsPage(context, initialTab: 1),
              )
            else
              ...prosConsController.consList.map((item) => _ProsConsItem(
                    item: item,
                    isPro: false,
                    hasVoted: prosConsController.hasUserVoted(item.id),
                    onVote: () => _handleVote(prosConsController, item),
                  )),
          ],
        ),
      );
    });
  }

  void _showAddProsConsPage(BuildContext context, {int initialTab = 0}) async {
    final prosConsController = Get.find<ProsConsStateController>();

    if (controller.isAdminOrModerator) {
      await Get.to(() => ManageProsConsPage(
            cityId: controller.cityId,
            cityName: controller.cityName,
          ));
    } else {
      await Get.to(() => ProsAndConsAddPage(
            cityId: controller.cityId,
            cityName: controller.cityName,
          ));
    }
    prosConsController.loadCityProsCons(controller.cityId);
  }

  void _handleVote(ProsConsStateController prosConsController, ProsCons item) async {
    // 使用 upvote 方法进行投票（如果已投票，会自动取消）
    await prosConsController.upvote(item.id, item.isPro);
  }
}

/// 优缺点项
class _ProsConsItem extends StatelessWidget {
  final ProsCons item;
  final bool isPro;
  final bool hasVoted;
  final VoidCallback onVote;

  const _ProsConsItem({
    required this.item,
    required this.isPro,
    required this.hasVoted,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isPro ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.ban,
              color: isPro ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.text, style: const TextStyle(fontSize: 15)),
            ),
            _VoteBadge(
              hasVoted: hasVoted,
              count: item.upvotes,
              onTap: onVote,
            ),
          ],
        ),
      ),
    );
  }
}

/// 投票徽章
class _VoteBadge extends StatelessWidget {
  final bool hasVoted;
  final int count;
  final VoidCallback? onTap;

  const _VoteBadge({
    required this.hasVoted,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = hasVoted ? Colors.green : AppColors.cityPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasVoted ? Colors.green.withValues(alpha: 0.12) : const Color(0xFFFFEEF2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasVoted ? FontAwesomeIcons.solidThumbsUp : FontAwesomeIcons.thumbsUp,
                size: 18,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                hasVoted ? '取消' : '投票',
                style: TextStyle(fontSize: 10, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 空状态组件
class _EmptyProsConsState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  const _EmptyProsConsState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: iconColor.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(FontAwesomeIcons.plus, size: 18),
            label: Text(buttonText),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cityPrimary,
              side: const BorderSide(color: AppColors.cityPrimary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
