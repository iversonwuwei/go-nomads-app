import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/manage_cost_page_controller.dart';
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// Cost 数据管理列表页面
class ManageCostPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const ManageCostPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  static String _generateTag(String cityId) => 'ManageCostPage_$cityId';

  ManageCostPageController _useController() {
    final tag = _generateTag(cityId);
    if (Get.isRegistered<ManageCostPageController>(tag: tag)) {
      return Get.find<ManageCostPageController>(tag: tag);
    }
    return Get.put(
      ManageCostPageController(cityId: cityId, cityName: cityName),
      tag: tag,
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return FontAwesomeIcons.utensils;
      case ExpenseCategory.transport:
        return FontAwesomeIcons.bus;
      case ExpenseCategory.accommodation:
        return FontAwesomeIcons.hotel;
      case ExpenseCategory.activity:
        return FontAwesomeIcons.ticket;
      case ExpenseCategory.shopping:
        return FontAwesomeIcons.bagShopping;
      case ExpenseCategory.other:
        return FontAwesomeIcons.ellipsis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text(l10n.manageCostPageTitle(cityName)),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: controller.navigateToAddCost,
            tooltip: l10n.addCost,
          ),
        ],
      ),
      body: Obx(() {
        Widget content;

        if (controller.contentController.expenses.isEmpty) {
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.dollarSign, size: 80.r, color: Colors.grey[300]),
                SizedBox(height: 16.h),
                Text(
                  l10n.manageCostNoData,
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.navigateToAddCost,
                  icon: const Icon(FontAwesomeIcons.plus),
                  label: Text(l10n.manageCostAddFirst),
                ),
              ],
            ),
          );
        } else {
          content = ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.contentController.expenses.length,
            itemBuilder: (context, index) {
              final expense = controller.contentController.expenses[index];
              final categoryName = controller.getCategoryName(expense.category);
              final categoryIcon = _getCategoryIcon(expense.category);
              final categoryColor = controller.getCategoryColor(expense.category);

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: categoryColor,
                    child: Icon(categoryIcon, color: Colors.white, size: 18.r),
                  ),
                  title: Text(
                    categoryName,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      if (expense.description != null && expense.description!.isNotEmpty)
                        Text(
                          expense.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.calendar, size: 12.r, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text(
                            controller.formatDate(expense.date),
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            expense.amount.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            expense.currency,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Obx(() {
                        if (!controller.canDelete.value) return const SizedBox.shrink();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 8.w),
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.trash, color: Colors.red),
                              onPressed: () => controller.deleteExpense(expense.id),
                              tooltip: l10n.delete,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return AppLoadingSwitcher(
          isLoading: controller.isLoading.value,
          loading: const ManageListSkeleton(),
          child: content,
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        onPressed: controller.navigateToAddCost,
        tooltip: l10n.addCost,
        child: const Icon(FontAwesomeIcons.plus),
      ),
    );
  }
}
