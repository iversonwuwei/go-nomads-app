import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/controllers/manage_cost_page_controller.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text('$cityName - 费用管理'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: controller.navigateToAddCost,
            tooltip: '添加费用',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.contentController.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.dollarSign, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无费用数据',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.navigateToAddCost,
                  icon: const Icon(FontAwesomeIcons.plus),
                  label: const Text('添加第一条费用'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.contentController.expenses.length,
          itemBuilder: (context, index) {
            final expense = controller.contentController.expenses[index];
            final categoryName = controller.getCategoryName(expense.category);
            final categoryIcon = _getCategoryIcon(expense.category);
            final categoryColor = controller.getCategoryColor(expense.category);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: categoryColor,
                  child: Icon(categoryIcon, color: Colors.white, size: 20),
                ),
                title: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (expense.description != null && expense.description!.isNotEmpty)
                      Text(
                        expense.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.calendar, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          controller.formatDate(expense.date),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          expense.currency,
                          style: TextStyle(
                            fontSize: 12,
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
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.trash, color: Colors.red),
                            onPressed: () => controller.deleteExpense(expense.id),
                            tooltip: '删除',
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
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        onPressed: controller.navigateToAddCost,
        tooltip: '添加费用',
        child: const Icon(FontAwesomeIcons.plus),
      ),
    );
  }
}
