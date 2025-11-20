import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/city/application/state_controllers/pros_cons_state_controller.dart';
import '../services/token_storage_service.dart';

/// Pros & Cons 添加页面
class ProsAndConsAddPage extends StatefulWidget {
  final String cityId;
  final String cityName;
  final int initialTab; // 初始显示的 tab (0=优点, 1=挑战)

  const ProsAndConsAddPage({
    super.key,
    required this.cityId,
    required this.cityName,
    this.initialTab = 0,
  });

  @override
  State<ProsAndConsAddPage> createState() => _ProsAndConsAddPageState();
}

class _ProsAndConsAddPageState extends State<ProsAndConsAddPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 本地状态管理
  final TextEditingController prosTextController = TextEditingController();
  final TextEditingController consTextController = TextEditingController();
  final RxBool isAddingPros = false.obs;
  final RxBool isAddingCons = false.obs;
  final RxBool isLoadingPros = false.obs;
  final RxBool isLoadingCons = false.obs;
  final RxList<dynamic> prosList = <dynamic>[].obs;
  final RxList<dynamic> consList = <dynamic>[].obs;
  final RxBool canDelete = false.obs;

  bool get hasChanges =>
      prosTextController.text.isNotEmpty ||
      consTextController.text.isNotEmpty ||
      prosList.isNotEmpty ||
      consList.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab, // 设置初始 tab
    );
    _checkPermissions();
    // 延迟到首帧之后再加载，避免在构建阶段触发 setState/Obx
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// 检查用户权限
  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  /// 加载已有数据
  Future<void> _loadData() async {
    final controller = Get.find<ProsConsStateController>();

    isLoadingPros.value = true;
    isLoadingCons.value = true;

    await controller.loadCityProsCons(widget.cityId);

    // 同步数据到本地列表
    prosList.value = controller.prosList
        .map((item) => {
              'id': item.id,
              'text': item.text,
              'upvotes': item.upvotes,
              'downvotes': item.downvotes,
              'userId': item.userId,
              'timestamp': item.createdAt.toIso8601String(),
            })
        .toList();

    consList.value = controller.consList
        .map((item) => {
              'id': item.id,
              'text': item.text,
              'upvotes': item.upvotes,
              'downvotes': item.downvotes,
              'userId': item.userId,
              'timestamp': item.createdAt.toIso8601String(),
            })
        .toList();

    isLoadingPros.value = false;
    isLoadingCons.value = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    prosTextController.dispose();
    consTextController.dispose();
    super.dispose();
  }

  /// 添加优点
  Future<void> addPros() async {
    if (prosTextController.text.trim().isEmpty) return;

    isAddingPros.value = true;
    try {
      // 调用后端 API 保存数据
      final controller = Get.find<ProsConsStateController>();
      final success = await controller.addPros(
        cityId: widget.cityId,
        text: prosTextController.text.trim(),
      );

      if (success) {
        prosTextController.clear();
        Get.snackbar('成功', '优点已添加', backgroundColor: Colors.green[100]);

        // 重新加载数据
        await _loadData();
      } else {
        Get.snackbar('失败', '添加优点失败，请重试');
      }
    } catch (e) {
      Get.snackbar('错误', '添加失败: $e');
    } finally {
      isAddingPros.value = false;
    }
  }

  /// 删除优点
  Future<void> deletePros(String id) async {
    // 确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条优点吗？'),
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
        Get.snackbar('成功', '优点已删除', backgroundColor: Colors.green[100]);
        await _loadData();
      } else {
        Get.snackbar('失败', '删除失败，请重试');
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }

  /// 删除挑战
  Future<void> deleteCons(String id) async {
    // 确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条挑战吗？'),
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
      final success = await controller.deleteProsCons(widget.cityId, id, false);

      if (success) {
        Get.snackbar('成功', '挑战已删除', backgroundColor: Colors.green[100]);
        await _loadData();
      } else {
        Get.snackbar('失败', '删除失败，请重试');
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }

  /// 添加挑战
  Future<void> addCons() async {
    if (consTextController.text.trim().isEmpty) return;

    isAddingCons.value = true;
    try {
      // 调用后端 API 保存数据
      final controller = Get.find<ProsConsStateController>();
      final success = await controller.addCons(
        cityId: widget.cityId,
        text: consTextController.text.trim(),
      );

      if (success) {
        consTextController.clear();
        Get.snackbar('成功', '挑战已添加', backgroundColor: Colors.green[100]);

        // 重新加载数据
        await _loadData();
      } else {
        Get.snackbar('失败', '添加挑战失败，请重试');
      }
    } catch (e) {
      Get.snackbar('错误', '添加失败: $e');
    } finally {
      isAddingCons.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - 添加乐趣'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back(result: hasChanges);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF4458),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: const Border(
              bottom: BorderSide(
                color: Color(0xFFFF4458),
                width: 3,
              ),
            ),
          ),
          tabs: const [
            Tab(text: '优点'),
            Tab(text: '挑战'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProsTab(),
          _buildConsTab(),
        ],
      ),
    );
  }

  // 优点标签页
  Widget _buildProsTab() {
    return Obx(() {
      return Column(
        children: [
          // 输入框区域 - 现代化设计
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 输入框
                Expanded(
                  child: TextField(
                    controller: prosTextController,
                    decoration: InputDecoration(
                      hintText: '分享这个城市的优点...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                    ),
                    maxLines: null,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                // 添加按钮
                isAddingPros.value
                    ? Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => addPros(),
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF4458).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // 列表区域
          Expanded(
            child: isLoadingPros.value
                ? const Center(child: CircularProgressIndicator())
                : prosList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无优点',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: prosList.length,
                        itemBuilder: (context, index) {
                          final item = prosList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['text'] ?? '',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          size: 16, color: Color(0xFFFF4458)),
                                      Text(
                                        '${item['upvotes'] ?? 0}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (canDelete.value) const SizedBox(width: 8),
                                  if (canDelete.value)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red, size: 20),
                                      onPressed: () => deletePros(item['id']),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    });
  }

  // 挑战标签页
  Widget _buildConsTab() {
    return Obx(() {
      return Column(
        children: [
          // 输入框区域 - 现代化设计
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 输入框
                Expanded(
                  child: TextField(
                    controller: consTextController,
                    decoration: InputDecoration(
                      hintText: '分享这个城市的挑战...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                    ),
                    maxLines: null,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                // 添加按钮
                isAddingCons.value
                    ? Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => addCons(),
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF4458).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // 列表区域
          Expanded(
            child: isLoadingCons.value
                ? const Center(child: CircularProgressIndicator())
                : consList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无挑战',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: consList.length,
                        itemBuilder: (context, index) {
                          final item = consList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['text'] ?? '',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          size: 16, color: Color(0xFFFF4458)),
                                      Text(
                                        '${item['upvotes'] ?? 0}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (canDelete.value) const SizedBox(width: 8),
                                  if (canDelete.value)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red, size: 20),
                                      onPressed: () => deleteCons(item['id']),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    });
  }
}
