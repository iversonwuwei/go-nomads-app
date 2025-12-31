import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_cost/add_cost_page.dart';
import 'package:df_admin_mobile/pages/city_detail/city_detail_controller.dart';
import 'package:df_admin_mobile/pages/manage_cost_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

      // 加载中
      if (contentController.isLoadingCostSummary.value && communityCost == null) {
        return const Center(child: CircularProgressIndicator());
      }

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

      return RefreshIndicator(
        onRefresh: () => contentController.loadCityCostSummary(controller.cityId),
        child: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
          children: [
            // 标题和贡献者
            _CostHeader(
              l10n: l10n,
              contributorCount: contributorCount,
            ),
            const SizedBox(height: 16),

            // 总费用卡片
            _TotalCostCard(
              l10n: l10n,
              total: total,
              totalExpenseCount: totalExpenseCount,
            ),
            const SizedBox(height: 24),

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
            const SizedBox(height: 32),
          ],
        ),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$contributorCount ${contributorCount != 1 ? l10n.contributors : l10n.contributor}',
            style: TextStyle(
              fontSize: 11,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.averageCommunityCost,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.basedOnRealExpenses(totalExpenseCount, totalExpenseCount != 1 ? 's' : ''),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.cityPrimary,
          ),
        ),
      ),
    );
  }
}
