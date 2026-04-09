import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/pros_and_cons_add_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Pros & Cons 添加页面
/// 注意: 由于 TabController 需要 TickerProvider，保持 StatefulWidget 结构
/// 但业务逻辑已移至 ProsAndConsAddPageController
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
  static const String _tag = 'ProsAndConsAddPage';
  late TabController _tabController;
  late ProsAndConsAddPageController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _controller = _useController();
  }

  ProsAndConsAddPageController _useController() {
    if (Get.isRegistered<ProsAndConsAddPageController>(tag: _tag)) {
      return Get.find<ProsAndConsAddPageController>(tag: _tag);
    }
    return Get.put(
      ProsAndConsAddPageController(
        cityId: widget.cityId,
        cityName: widget.cityName,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog(String title, String content) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// 删除优点
  Future<void> _deletePros(String id) async {
    final confirmed = await _showDeleteConfirmDialog('确认删除', '确定要删除这条优点吗？');
    if (confirmed) {
      await _controller.deletePros(id);
    }
  }

  /// 删除挑战
  Future<void> _deleteCons(String id) async {
    final confirmed = await _showDeleteConfirmDialog('确认删除', '确定要删除这条挑战吗？');
    if (confirmed) {
      await _controller.deleteCons(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text(l10n.prosConsAddPageTitle(widget.cityName)),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(_controller.hasChanges);
            } else {
              Get.back(result: _controller.hasChanges, closeOverlays: false);
            }
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final items = _buildNavItems(l10n);
          final currentIndex = _tabController.index;
          final currentItem = items[currentIndex];

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                child: _ProsConsAddCompactToolbar(
                  items: items,
                  currentIndex: currentIndex,
                  currentItem: currentItem,
                  onTabSelected: _switchTab,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentIndex),
                    child: currentIndex == 0 ? _buildProsTab() : _buildConsTab(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_ProsConsAddNavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      _ProsConsAddNavItem(
        index: 0,
        label: l10n.pros,
        subtitle: '${_controller.prosConsController.prosList.length} entries',
        description: l10n.prosConsAddProsHint,
        icon: FontAwesomeIcons.lightbulb,
        accent: const Color(0xFF2F6A48),
      ),
      _ProsConsAddNavItem(
        index: 1,
        label: l10n.cons,
        subtitle: '${_controller.prosConsController.consList.length} entries',
        description: l10n.prosConsAddConsHint,
        icon: FontAwesomeIcons.circleInfo,
        accent: const Color(0xFF7B3559),
      ),
    ];
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
  }

  Widget _buildVoteChip({
    required int count,
    required VoidCallback? onTap,
    bool? currentUserVoted,
  }) {
    final bool isActive = currentUserVoted == true;
    final Color activeColor = const Color(0xFFFF4458);
    final Color inactiveColor = Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFEEF2) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isActive ? activeColor.withValues(alpha: 0.4) : inactiveColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.thumbsUp,
                size: 18.r,
                color: isActive ? activeColor : inactiveColor,
              ),
              SizedBox(height: 4.h),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
              Text(
                '投票',
                style: TextStyle(fontSize: 10.sp, color: activeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 优点标签页
  Widget _buildProsTab() {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final prosConsController = _controller.prosConsController;
      return Column(
        children: [
          // 输入框区域 - 现代化设计
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16.r,
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
                    controller: _controller.prosTextController,
                    decoration: InputDecoration(
                      hintText: l10n.prosConsAddProsHint,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 12.h,
                      ),
                      prefixIcon: Icon(
                        FontAwesomeIcons.lightbulb,
                        color: Colors.grey[400],
                        size: 22.r,
                      ),
                    ),
                    maxLines: null,
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                // 添加按钮
                _controller.isAddingPros.value
                    ? Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
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
                          onTap: () => _controller.addPros(),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Ink(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              FontAwesomeIcons.circlePlus,
                              color: Colors.white,
                              size: 24.r,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // 列表区域
          Expanded(
            child: prosConsController.isLoadingPros.value
              ? const AppSceneLoading(scene: AppLoadingScene.reviews, fullScreen: true)
                : prosConsController.prosList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.circleCheck, size: 64.r, color: Colors.grey[300]),
                            SizedBox(height: 16.h),
                            Text(
                              '暂无优点',
                              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: prosConsController.prosList.length,
                        itemBuilder: (context, index) {
                          final item = prosConsController.prosList[index];
                          final itemId = item.id;
                          return Card(
                            margin: EdgeInsets.only(bottom: 12.h),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.circleCheck,
                                    color: Colors.green,
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      item.text,
                                      style: TextStyle(fontSize: 15.sp),
                                    ),
                                  ),
                                  _buildVoteChip(
                                    count: item.upvotes,
                                    onTap: itemId.isEmpty ? null : () => _controller.handleVote(itemId, true),
                                    currentUserVoted: item.currentUserVoted,
                                  ),
                                  if (_controller.canDelete.value) SizedBox(width: 8.w),
                                  if (_controller.canDelete.value)
                                    IconButton(
                                      icon: Icon(FontAwesomeIcons.trash, color: Colors.red, size: 20.r),
                                      onPressed: () => _deletePros(item.id),
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
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final prosConsController = _controller.prosConsController;
      return Column(
        children: [
          // 输入框区域 - 现代化设计
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16.r,
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
                    controller: _controller.consTextController,
                    decoration: InputDecoration(
                      hintText: l10n.prosConsAddConsHint,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 12.h,
                      ),
                      prefixIcon: Icon(
                        FontAwesomeIcons.circleInfo,
                        color: Colors.grey[400],
                        size: 22.r,
                      ),
                    ),
                    maxLines: null,
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                // 添加按钮
                _controller.isAddingCons.value
                    ? Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
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
                          onTap: () => _controller.addCons(),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Ink(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              FontAwesomeIcons.circlePlus,
                              color: Colors.white,
                              size: 24.r,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // 列表区域
          Expanded(
            child: prosConsController.isLoadingCons.value
              ? const AppSceneLoading(scene: AppLoadingScene.reviews, fullScreen: true)
                : prosConsController.consList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.ban, size: 64.r, color: Colors.grey[300]),
                            SizedBox(height: 16.h),
                            Text(
                              '暂无挑战',
                              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: prosConsController.consList.length,
                        itemBuilder: (context, index) {
                          final item = prosConsController.consList[index];
                          final itemId = item.id;
                          return Card(
                            margin: EdgeInsets.only(bottom: 12.h),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.ban,
                                    color: Colors.red,
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      item.text,
                                      style: TextStyle(fontSize: 15.sp),
                                    ),
                                  ),
                                  _buildVoteChip(
                                    count: item.upvotes,
                                    onTap: itemId.isEmpty ? null : () => _controller.handleVote(itemId, false),
                                    currentUserVoted: item.currentUserVoted,
                                  ),
                                  if (_controller.canDelete.value) SizedBox(width: 8.w),
                                  if (_controller.canDelete.value)
                                    IconButton(
                                      icon: Icon(FontAwesomeIcons.trash, color: Colors.red, size: 20.r),
                                      onPressed: () => _deleteCons(item.id),
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

class _ProsConsAddNavItem {
  const _ProsConsAddNavItem({
    required this.index,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final int index;
  final String label;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
}

class _ProsConsAddPill extends StatelessWidget {
  const _ProsConsAddPill({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _ProsConsAddNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? item.accent : Colors.white,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(item.icon, size: 12.sp, color: isActive ? Colors.white : item.accent),
              SizedBox(width: 8.w),
              Text(
                item.label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProsConsAddCompactToolbar extends StatelessWidget {
  const _ProsConsAddCompactToolbar({
    required this.items,
    required this.currentIndex,
    required this.currentItem,
    required this.onTabSelected,
  });

  final List<_ProsConsAddNavItem> items;
  final int currentIndex;
  final _ProsConsAddNavItem currentItem;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE7DED0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: currentItem.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: FaIcon(
                    currentItem.icon,
                    size: 14.sp,
                    color: currentItem.accent,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentItem.label,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      currentItem.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${currentIndex + 1}/${items.length}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 8.w),
                  child: _ProsConsAddPill(
                    item: item,
                    isActive: currentIndex == index,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
