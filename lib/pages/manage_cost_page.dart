import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/user_city_content/domain/entities/user_city_content.dart';
import '../features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import '../services/token_storage_service.dart';
import 'add_cost_page.dart';

/// Cost 数据管理列表页面
class ManageCostPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const ManageCostPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<ManageCostPage> createState() => _ManageCostPageState();
}

class _ManageCostPageState extends State<ManageCostPage> {
  final RxBool canDelete = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadData();
  }

  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final controller = Get.find<UserCityContentStateController>();
      await controller.loadCityExpenses(widget.cityId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条费用记录吗？此操作可以恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final controller = Get.find<UserCityContentStateController>();
      final success =
          await controller.deleteExpense(widget.cityId, expenseId);

      if (success) {
        Get.snackbar(
          '成功',
          '费用记录已删除',
          backgroundColor: Colors.green[100],
          duration: const Duration(seconds: 2),
        );
        await _loadData();
      } else {
        Get.snackbar('失败', '删除失败,请重试');
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return '餐饮';
      case ExpenseCategory.transport:
        return '交通';
      case ExpenseCategory.accommodation:
        return '住宿';
      case ExpenseCategory.activity:
        return '活动';
      case ExpenseCategory.shopping:
        return '购物';
      case ExpenseCategory.other:
        return '其他';
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_bus;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.activity:
        return Icons.local_activity;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.accommodation:
        return Colors.purple;
      case ExpenseCategory.activity:
        return Colors.green;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserCityContentStateController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - 费用管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Get.to(() => AddCostPage(
                    cityId: widget.cityId,
                    cityName: widget.cityName,
                  ));
              if (result != null && result['success'] == true) {
                await _loadData();
              }
            },
            tooltip: '添加费用',
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_money, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无费用数据',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.to(() => AddCostPage(
                          cityId: widget.cityId,
                          cityName: widget.cityName,
                        ));
                    if (result != null && result['success'] == true) {
                      await _loadData();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('添加第一条费用'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.expenses.length,
          itemBuilder: (context, index) {
            final expense = controller.expenses[index];
            final categoryName = _getCategoryName(expense.category);
            final categoryIcon = _getCategoryIcon(expense.category);
            final categoryColor = _getCategoryColor(expense.category);

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
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      Text(
                        expense.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(expense.date),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                    if (canDelete.value) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteExpense(expense.id),
                        tooltip: '删除',
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => AddCostPage(
                cityId: widget.cityId,
                cityName: widget.cityName,
              ));
          if (result != null && result['success'] == true) {
            await _loadData();
          }
        },
        tooltip: '添加费用',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
