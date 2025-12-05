import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

class _ProsAndConsAddPageState extends State<ProsAndConsAddPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ProsConsStateController _prosConsController;

  // 本地状态管理
  final TextEditingController prosTextController = TextEditingController();
  final TextEditingController consTextController = TextEditingController();
  final RxBool isAddingPros = false.obs;
  final RxBool isAddingCons = false.obs;
  final RxBool canDelete = false.obs;

  bool get hasChanges =>
      prosTextController.text.isNotEmpty ||
      consTextController.text.isNotEmpty ||
      _prosConsController.prosList.isNotEmpty ||
      _prosConsController.consList.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _prosConsController = Get.find<ProsConsStateController>();
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
    // 直接调用 controller 加载数据，不需要同步到本地列表
    await _prosConsController.loadCityProsCons(widget.cityId);
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
      final success = await _prosConsController.addPros(
        cityId: widget.cityId,
        text: prosTextController.text.trim(),
      );

      if (success) {
        prosTextController.clear();
        AppToast.success('优点已添加');

        // 重新加载数据
        await _loadData();
      } else {
        AppToast.error('添加优点失败，请重试');
      }
    } catch (e) {
      AppToast.error('添加失败: $e');
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
            style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _prosConsController.deleteProsCons(widget.cityId, id, true);

      if (success) {
        AppToast.success('优点已删除');
        await _loadData();
      } else {
        AppToast.error('删除失败，请重试');
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
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
            style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _prosConsController.deleteProsCons(widget.cityId, id, false);

      if (success) {
        AppToast.success('挑战已删除');
        await _loadData();
      } else {
        AppToast.error('删除失败，请重试');
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
    }
  }

  Future<void> _handleVote(String id, bool isPro) async {
    if (id.isEmpty) return;

    // Flutter 只需要传 isUpvote=true 给后端
    // 后端会自动判断：没投过就创建，投过就删除（取消）
    final success = await _prosConsController.upvote(id, isPro);
    if (success) {
      await _loadData(); // 重新加载数据以获取最新的投票状态和投票数
    } else {
      final message = _prosConsController.error.value ?? '操作失败，请稍后再试';
      AppToast.error(message);
    }
  }

  Widget _buildVoteChip({
    required int count,
    required VoidCallback? onTap,
    bool? currentUserVoted, // null=未登录/未投票, true=已点赞, false=已点踩
  }) {
    // 如果是点赞按钮且用户已点赞，则显示激活状态
    final bool isActive = currentUserVoted == true;
    final Color activeColor = const Color(0xFFFF4458);
    final Color inactiveColor = Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFEEF2) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? activeColor.withValues(alpha: 0.4) : inactiveColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.thumbsUp,
                size: 18,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
              Text(
                '投票',
                style: TextStyle(fontSize: 10, color: activeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 添加挑战
  Future<void> addCons() async {
    if (consTextController.text.trim().isEmpty) return;

    isAddingCons.value = true;
    try {
      // 调用后端 API 保存数据
      final success = await _prosConsController.addCons(
        cityId: widget.cityId,
        text: consTextController.text.trim(),
      );

      if (success) {
        consTextController.clear();
        AppToast.success('挑战已添加');

        // 重新加载数据
        await _loadData();
      } else {
        AppToast.error('添加挑战失败，请重试');
      }
    } catch (e) {
      AppToast.error('添加失败: $e');
    } finally {
      isAddingCons.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text('${widget.cityName} - 添加乐趣'),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(hasChanges);
            } else {
              Get.back(result: hasChanges, closeOverlays: false);
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Colors.white,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: const Border(
              bottom: BorderSide(
                color: Colors.white,
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
                  color: Colors.black.withValues(alpha: 0.08),
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
                        FontAwesomeIcons.lightbulb,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                  color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              FontAwesomeIcons.circlePlus,
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
            child: _prosConsController.isLoadingPros.value
                ? const Center(child: CircularProgressIndicator())
                : _prosConsController.prosList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.circleCheck, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无优点',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _prosConsController.prosList.length,
                        itemBuilder: (context, index) {
                          final item = _prosConsController.prosList[index];
                          final itemId = item.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.circleCheck,
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
                                  _buildVoteChip(
                                    count: item.upvotes,
                                    onTap: itemId.isEmpty ? null : () => _handleVote(itemId, true),
                                    currentUserVoted: item.currentUserVoted,
                                  ),
                                  if (canDelete.value) const SizedBox(width: 8),
                                  if (canDelete.value)
                                    IconButton(
                                      icon: const Icon(FontAwesomeIcons.trash, color: Colors.red, size: 20),
                                      onPressed: () => deletePros(item.id),
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
                  color: Colors.black.withValues(alpha: 0.08),
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
                        FontAwesomeIcons.circleInfo,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                  color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              FontAwesomeIcons.circlePlus,
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
            child: _prosConsController.isLoadingCons.value
                ? const Center(child: CircularProgressIndicator())
                : _prosConsController.consList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.ban, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无挑战',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _prosConsController.consList.length,
                        itemBuilder: (context, index) {
                          final item = _prosConsController.consList[index];
                          final itemId = item.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.ban,
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
                                  _buildVoteChip(
                                    count: item.upvotes,
                                    onTap: itemId.isEmpty ? null : () => _handleVote(itemId, false),
                                    currentUserVoted: item.currentUserVoted,
                                  ),
                                  if (canDelete.value) const SizedBox(width: 8),
                                  if (canDelete.value)
                                    IconButton(
                                      icon: const Icon(FontAwesomeIcons.trash, color: Colors.red, size: 20),
                                      onPressed: () => deleteCons(item.id),
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
