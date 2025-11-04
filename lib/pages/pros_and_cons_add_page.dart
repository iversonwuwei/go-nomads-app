import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pros_and_cons_add_controller.dart';

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
  late ProsAndConsAddController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab, // 设置初始 tab
    );

    // 初始化 Controller
    controller = Get.put(
      ProsAndConsAddController(
        cityId: widget.cityId,
        cityName: widget.cityName,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<ProsAndConsAddController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - 添加乐趣'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back(result: controller.hasChanges.value);
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
                    controller: controller.prosTextController,
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
                controller.isAddingPros.value
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
                          onTap: () => controller.addPros(),
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
            child: controller.isLoadingPros.value
                ? const Center(child: CircularProgressIndicator())
                : controller.prosList.isEmpty
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
                        itemCount: controller.prosList.length,
                        itemBuilder: (context, index) {
                          final item = controller.prosList[index];
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
                                      item.text,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          size: 16, color: Color(0xFFFF4458)),
                                      Text(
                                        '${item.upvotes}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
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
                    controller: controller.consTextController,
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
                controller.isAddingCons.value
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
                          onTap: () => controller.addCons(),
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
            child: controller.isLoadingCons.value
                ? const Center(child: CircularProgressIndicator())
                : controller.consList.isEmpty
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
                        itemCount: controller.consList.length,
                        itemBuilder: (context, index) {
                          final item = controller.consList[index];
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
                                      item.text,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          size: 16, color: Color(0xFFFF4458)),
                                      Text(
                                        '${item.upvotes}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
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
