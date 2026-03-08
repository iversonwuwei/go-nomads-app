import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_cost/add_cost_page.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/pages/manage_cost_page.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// Cost Tab - 费用标签页
/// 使用 GetView 绑定 CityDetailController
class CostTab extends GetView<CityDetailController> {
  @override
  final String? tag;

  const CostTab({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contentController = Get.find<UserCityContentStateController>();

    return Obx(() {
      final communityCost = contentController.costSummary.value;
      final isLoadingInitial = contentController.isLoadingCostSummary.value && communityCost == null;

      // 使用默认值
      final total = communityCost?.total ?? 0.0;
      final contributorCount = communityCost?.contributorCount ?? 0;
      final totalExpenseCount = communityCost?.totalExpenseCount ?? 0;
      final accommodation = communityCost?.accommodation ?? 0.0;
      final food = communityCost?.food ?? 0.0;
      final transportation = communityCost?.transportation ?? 0.0;
      final activity = communityCost?.activity ?? 0.0;
      final shopping = communityCost?.shopping ?? 0.0;
      final other = communityCost?.other ?? 0.0;

      final content = RefreshIndicator(
        onRefresh: () => contentController.loadCityCostSummary(controller.cityId),
        child: ListView(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 96.h),
          children: [
            // 标题和贡献者
            _CostHeader(
              l10n: l10n,
              contributorCount: contributorCount,
            ),
            SizedBox(height: 16.h),

            // 总费用卡片
            _TotalCostCard(
              l10n: l10n,
              total: total,
              totalExpenseCount: totalExpenseCount,
            ),
            SizedBox(height: 24.h),

            // 费用分类
            _CostCategoryCard(
                category: l10n.accommodation,
                amount: accommodation,
                icon: FontAwesomeIcons.hotel,
                color: Colors.purple),
            _CostCategoryCard(category: l10n.food, amount: food, icon: FontAwesomeIcons.utensils, color: Colors.orange),
            _CostCategoryCard(
                category: l10n.transportation, amount: transportation, icon: FontAwesomeIcons.car, color: Colors.blue),
            _CostCategoryCard(
                category: l10n.activity, amount: activity, icon: FontAwesomeIcons.ticket, color: Colors.green),
            _CostCategoryCard(
                category: l10n.shopping, amount: shopping, icon: FontAwesomeIcons.bagShopping, color: Colors.pink),
            _CostCategoryCard(category: 'Other', amount: other, icon: FontAwesomeIcons.ellipsis, color: Colors.grey),
            SizedBox(height: 32.h),
          ],
        ),
      );

      return AppLoadingSwitcher(
        isLoading: isLoadingInitial,
        loading: const CostTabSkeleton(),
        child: content,
      );
    });
  }

  /// 跳转到添加/管理费用页面
  static Future<void> navigateToAddCost({
    required String cityId,
    required String cityName,
    required bool isAdminOrModerator,
  }) async {
    final contentController = Get.find<UserCityContentStateController>();

    if (isAdminOrModerator) {
      await Get.to(() => ManageCostPage(
            cityId: cityId,
            cityName: cityName,
          ));
    } else {
      await Get.to(() => AddCostPage(
            cityId: cityId,
            cityName: cityName,
          ));
    }
    contentController.loadCityExpenses(cityId);
    contentController.loadCityCostSummary(cityId);
  }
}

/// 费用标题
class _CostHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final int contributorCount;

  const _CostHeader({
    required this.l10n,
    required this.contributorCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.communityCostSummary,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$contributorCount ${contributorCount != 1 ? l10n.contributors : l10n.contributor}',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// 总费用卡片
class _TotalCostCard extends StatelessWidget {
  final AppLocalizations l10n;
  final double total;
  final int totalExpenseCount;

  const _TotalCostCard({
    required this.l10n,
    required this.total,
    required this.totalExpenseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            l10n.averageCommunityCost,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            '\$${total.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.basedOnRealExpenses(totalExpenseCount, totalExpenseCount != 1 ? 's' : ''),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// 费用分类卡片
class _CostCategoryCard extends StatelessWidget {
  final String category;
  final double amount;
  final IconData icon;
  final Color color;

  const _CostCategoryCard({
    required this.category,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.cityPrimary,
          ),
        ),
      ),
    );
  }
}
