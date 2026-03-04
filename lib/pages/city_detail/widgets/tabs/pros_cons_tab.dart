import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_detail.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/manage_pros_cons_page.dart';
import 'package:go_nomads_app/pages/pros_and_cons_add_page.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isLoading = prosConsController.isLoadingPros.value || prosConsController.isLoadingCons.value;

      if (isLoading) {
        return const ProsConsTabSkeleton();
      }

      return RefreshIndicator(
        onRefresh: () => prosConsController.loadCityProsCons(controller.cityId),
        child: ListView(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 80.h),
          children: [
            // 优点部分
            Text(
              '优点',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            if (prosConsController.prosList.isEmpty)
              _EmptyProsConsState(
                icon: FontAwesomeIcons.circleCheck,
                iconColor: Colors.green,
                title: l10n.prosConsNoProsTitle,
                subtitle: l10n.prosConsNoProsSubtitle,
                buttonText: l10n.prosConsAddPros,
                onTap: () => _showAddProsConsPage(context, initialTab: 0),
              )
            else
              ...prosConsController.prosList.map((item) => _ProsConsItem(
                    item: item,
                    isPro: true,
                    hasVoted: prosConsController.hasUserVoted(item.id),
                    onVote: () => _handleVote(prosConsController, item),
                  )),

            SizedBox(height: 24.h),

            // 挑战部分
            Text(
              '挑战',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            if (prosConsController.consList.isEmpty)
              _EmptyProsConsState(
                icon: FontAwesomeIcons.ban,
                iconColor: Colors.red,
                title: l10n.prosConsNoConsTitle,
                subtitle: l10n.prosConsNoConsSubtitle,
                buttonText: l10n.prosConsAddCons,
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
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Icon(
              isPro ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.ban,
              color: isPro ? Colors.green : Colors.red,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(item.text, style: TextStyle(fontSize: 15.sp)),
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
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: hasVoted ? Colors.green.withValues(alpha: 0.12) : const Color(0xFFFFEEF2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasVoted ? FontAwesomeIcons.solidThumbsUp : FontAwesomeIcons.thumbsUp,
                size: 18.r,
                color: color,
              ),
              SizedBox(height: 4.h),
              Text(
                '$count',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                hasVoted ? '取消' : '投票',
                style: TextStyle(fontSize: 10.sp, color: color),
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
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.r, color: iconColor.withValues(alpha: 0.4)),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(FontAwesomeIcons.plus, size: 18.r),
            label: Text(buttonText),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cityPrimary,
              side: const BorderSide(color: AppColors.cityPrimary),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            ),
          ),
        ],
      ),
    );
  }
}
