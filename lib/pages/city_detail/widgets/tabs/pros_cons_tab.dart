import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_detail.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/pages/manage_pros_cons_page.dart';
import 'package:go_nomads_app/pages/pros_and_cons_add_page.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

class ProsConsTab extends GetView<CityDetailController> {
  final String? customTag;

  const ProsConsTab({super.key, String? tag}) : customTag = tag;

  @override
  String? get tag => customTag;

  @override
  Widget build(BuildContext context) {
    final prosConsController = Get.find<ProsConsStateController>();
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isLoading = prosConsController.isLoadingPros.value || prosConsController.isLoadingCons.value;

      final content = RefreshIndicator(
        onRefresh: () => prosConsController.loadCityProsCons(controller.cityId),
        child: ListView(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h, bottom: 80.h),
          children: [
            // Header for Pros
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.feedbackSuccess.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    FontAwesomeIcons.solidThumbsUp,
                    color: AppColors.feedbackSuccessDark,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '有点',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            if (prosConsController.prosList.isEmpty)
              _EmptyProsConsState(
                icon: FontAwesomeIcons.solidThumbsUp,
                iconColor: Colors.green,
                title: l10n.prosConsNoProsTitle,
                subtitle: l10n.prosConsNoProsSubtitle,
                buttonText: l10n.prosConsAddPros,
                onTap: () => _showAddProsConsPage(context, initialTab: 0),
              )
            else
              ...prosConsController.prosList.map((item) => _ModernProsConsItem(
                    item: item,
                    isPro: true,
                    hasVoted: prosConsController.hasUserVoted(item.id),
                    onVote: () => _handleVote(prosConsController, item),
                  )),

            SizedBox(height: 32.h),

            // Header for Cons
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.feedbackError.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    FontAwesomeIcons.solidThumbsDown,
                    color: AppColors.feedbackErrorDark,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '挑战',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            if (prosConsController.consList.isEmpty)
              _EmptyProsConsState(
                icon: FontAwesomeIcons.solidThumbsDown,
                iconColor: Colors.red,
                title: l10n.prosConsNoConsTitle,
                subtitle: l10n.prosConsNoConsSubtitle,
                buttonText: l10n.prosConsAddCons,
                onTap: () => _showAddProsConsPage(context, initialTab: 1),
              )
            else
              ...prosConsController.consList.map((item) => _ModernProsConsItem(
                    item: item,
                    isPro: false,
                    hasVoted: prosConsController.hasUserVoted(item.id),
                    onVote: () => _handleVote(prosConsController, item),
                  )),
          ],
        ),
      );

      return AppLoadingSwitcher(
        isLoading: isLoading,
        loading: const ProsConsTabSkeleton(),
        child: content,
      );
    });
  }

  void _showAddProsConsPage(BuildContext context, {int initialTab = 0}) async {
    final prosConsController = Get.find<ProsConsStateController>();
    if (controller.isAdminOrModerator) {
      await Get.to(() => ManageProsConsPage(cityId: controller.cityId, cityName: controller.cityName));
    } else {
      await Get.to(() => ProsAndConsAddPage(cityId: controller.cityId, cityName: controller.cityName));
    }
    prosConsController.loadCityProsCons(controller.cityId);
  }

  void _handleVote(ProsConsStateController prosConsController, ProsCons item) async {
    await prosConsController.upvote(item.id, item.isPro);
  }
}

class _ModernProsConsItem extends StatelessWidget {
  final ProsCons item;
  final bool isPro;
  final bool hasVoted;
  final VoidCallback onVote;

  const _ModernProsConsItem({
    required this.item,
    required this.isPro,
    required this.hasVoted,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isPro ? AppColors.feedbackSuccessDark : AppColors.feedbackErrorDark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onVote,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: hasVoted ? primaryColor : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: hasVoted ? primaryColor.withValues(alpha: 0.12) : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPro ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                    size: 14.r,
                    color: hasVoted ? Colors.white : AppColors.textSecondary,
                  ),
                  if (item.upvotes > 0 || hasVoted) ...[
                    SizedBox(width: 6.w),
                    Text(
                      '${item.upvotes}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: hasVoted ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32.r, color: iconColor),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
