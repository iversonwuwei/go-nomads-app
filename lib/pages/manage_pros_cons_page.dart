import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/city/application/state_controllers/pros_cons_state_controller.dart';
import '../services/token_storage_service.dart';
import 'pros_and_cons_add_page.dart';

/// Pros & Cons 数据管理列表页面
class ManageProsConsPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const ManageProsConsPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<ManageProsConsPage> createState() => _ManageProsConsPageState();
}

class _ManageProsConsPageState extends State<ManageProsConsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RxBool canDelete = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermissions();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final controller = Get.find<ProsConsStateController>();
      await controller.loadCityProsCons(widget.cityId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _deletePros(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条优点吗？此操作可以恢复。'),
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
      final controller = Get.find<ProsConsStateController>();
      final success = await controller.deleteProsCons(widget.cityId, id, true);

      if (success) {
        Get.snackbar(
          '成功',
          '优点已删除',
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

  Future<void> _deleteCons(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条挑战吗？此操作可以恢复。'),
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
      final controller = Get.find<ProsConsStateController>();
      final success =
          await controller.deleteProsCons(widget.cityId, id, false);

      if (success) {
        Get.snackbar(
          '成功',
          '挑战已删除',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - 优缺点管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '优点', icon: Icon(Icons.check_circle_outline)),
            Tab(text: '挑战', icon: Icon(Icons.info_outline)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Get.to(() => ProsAndConsAddPage(
                    cityId: widget.cityId,
                    cityName: widget.cityName,
                    initialTab: _tabController.index,
                  ));
              await _loadData();
            },
            tooltip: '添加',
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildProsList(),
            _buildConsList(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => ProsAndConsAddPage(
                cityId: widget.cityId,
                cityName: widget.cityName,
                initialTab: _tabController.index,
              ));
          await _loadData();
        },
        tooltip: '添加',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProsList() {
    final controller = Get.find<ProsConsStateController>();

    return Obx(() {
      if (controller.prosList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                '暂无优点数据',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.prosList.length,
        itemBuilder: (context, index) {
          final item = controller.prosList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: Text(
                item.text,
                style: const TextStyle(fontSize: 15),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward,
                          size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text('${item.upvotes}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Icon(Icons.arrow_downward,
                          size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text('${item.downvotes}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '创建于: ${_formatDate(item.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: canDelete.value
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deletePros(item.id),
                      tooltip: '删除',
                    )
                  : null,
            ),
          );
        },
      );
    });
  }

  Widget _buildConsList() {
    final controller = Get.find<ProsConsStateController>();

    return Obx(() {
      if (controller.consList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                '暂无挑战数据',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.consList.length,
        itemBuilder: (context, index) {
          final item = controller.consList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white),
              ),
              title: Text(
                item.text,
                style: const TextStyle(fontSize: 15),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward,
                          size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text('${item.upvotes}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Icon(Icons.arrow_downward,
                          size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text('${item.downvotes}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '创建于: ${_formatDate(item.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: canDelete.value
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteCons(item.id),
                      tooltip: '删除',
                    )
                  : null,
            ),
          );
        },
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
