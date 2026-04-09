import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/manage_pros_cons_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

import 'pros_and_cons_add_page.dart';

/// Pros & Cons 数据管理列表页面
/// 需要 StatefulWidget 因为 TabController 需要 SingleTickerProviderStateMixin
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

class _ManageProsConsPageState extends State<ManageProsConsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ManageProsConsPageController _controller;

  static String _generateTag(String cityId) => 'ManageProsConsPage_$cityId';

  ManageProsConsPageController _useController() {
    final tag = _generateTag(widget.cityId);
    if (Get.isRegistered<ManageProsConsPageController>(tag: tag)) {
      return Get.find<ManageProsConsPageController>(tag: tag);
    }
    return Get.put(
      ManageProsConsPageController(
        cityId: widget.cityId,
        cityName: widget.cityName,
      ),
      tag: tag,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = _useController();

    // 同步 TabController 和 Controller 的索引
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.updateTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final items = _buildNavItems(l10n);

          return AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final currentIndex = _tabController.index;
              final currentItem = items[currentIndex];

              return Column(
                children: [
                  _buildHeader(l10n),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                    child: _ProsConsCompactToolbar(
                      items: items,
                      currentIndex: currentIndex,
                      currentItem: currentItem,
                      onTabSelected: _switchTab,
                      onAddPressed: () async {
                        await Get.to(() => ProsAndConsAddPage(
                              cityId: widget.cityId,
                              cityName: widget.cityName,
                              initialTab: currentIndex,
                            ));
                        await _controller.loadData();
                      },
                    ),
                  ),
                  Expanded(
                    child: AppLoadingSwitcher(
                      isLoading: _controller.isLoading.value,
                      loading: const ManageListSkeleton(),
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
                          child: currentIndex == 0 ? _buildProsList(l10n) : _buildConsList(l10n),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.manageProsConsPageTitle(widget.cityName),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.prosAndCons,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            label: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  List<_ProsConsNavItem> _buildNavItems(AppLocalizations l10n) {
    final prosCount = _controller.prosConsController.prosList.length;
    final consCount = _controller.prosConsController.consList.length;

    return [
      _ProsConsNavItem(
        index: 0,
        label: l10n.pros,
        subtitle: '$prosCount entries',
        description: l10n.prosConsNoProsSubtitle,
        icon: FontAwesomeIcons.circleCheck,
        accent: const Color(0xFF2F6A48),
        count: prosCount,
      ),
      _ProsConsNavItem(
        index: 1,
        label: l10n.cons,
        subtitle: '$consCount entries',
        description: l10n.prosConsNoConsSubtitle,
        icon: FontAwesomeIcons.circleInfo,
        accent: const Color(0xFF7B3559),
        count: consCount,
      ),
    ];
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
    _controller.updateTabIndex(index);
  }

  Widget _buildProsList(AppLocalizations l10n) {
    final prosConsController = _controller.prosConsController;

    return Obx(() {
      if (prosConsController.prosList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.circleCheck, size: 80.r, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text(
                l10n.prosConsNoProsTitle,
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.prosConsNoProsSubtitle,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: prosConsController.prosList.length,
        itemBuilder: (context, index) {
          final item = prosConsController.prosList[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(FontAwesomeIcons.check, color: Colors.white),
              ),
              title: Text(
                item.text,
                style: TextStyle(fontSize: 15.sp),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.arrowUp, size: 16.r, color: Colors.green[700]),
                      SizedBox(width: 4.w),
                      Text(item.upvotes.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 16.w),
                      Icon(FontAwesomeIcons.arrowDown, size: 16.r, color: Colors.red[700]),
                      SizedBox(width: 4.w),
                      Text(item.downvotes.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '创建于: ${_controller.formatDate(item.createdAt)}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: Obx(() => _controller.canDelete.value
                  ? IconButton(
                      icon: const Icon(FontAwesomeIcons.trash, color: Colors.red),
                      onPressed: () => _controller.deletePros(item.id),
                      tooltip: '删除',
                    )
                  : const SizedBox.shrink()),
            ),
          );
        },
      );
    });
  }

  Widget _buildConsList(AppLocalizations l10n) {
    final prosConsController = _controller.prosConsController;

    return Obx(() {
      if (prosConsController.consList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.circleInfo, size: 80.r, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text(
                l10n.prosConsNoConsTitle,
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.prosConsNoConsSubtitle,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: prosConsController.consList.length,
        itemBuilder: (context, index) {
          final item = prosConsController.consList[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(FontAwesomeIcons.xmark, color: Colors.white),
              ),
              title: Text(
                item.text,
                style: TextStyle(fontSize: 15.sp),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.arrowUp, size: 16.r, color: Colors.green[700]),
                      SizedBox(width: 4.w),
                      Text(item.upvotes.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 16.w),
                      Icon(FontAwesomeIcons.arrowDown, size: 16.r, color: Colors.red[700]),
                      SizedBox(width: 4.w),
                      Text(item.downvotes.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '创建于: ${_controller.formatDate(item.createdAt)}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: Obx(() => _controller.canDelete.value
                  ? IconButton(
                      icon: const Icon(FontAwesomeIcons.trash, color: Colors.red),
                      onPressed: () => _controller.deleteCons(item.id),
                      tooltip: '删除',
                    )
                  : const SizedBox.shrink()),
            ),
          );
        },
      );
    });
  }
}

class _ProsConsNavItem {
  const _ProsConsNavItem({
    required this.index,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
    required this.count,
  });

  final int index;
  final String label;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
  final int count;
}

class _ProsConsPill extends StatelessWidget {
  const _ProsConsPill({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _ProsConsNavItem item;
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
              FaIcon(
                item.icon,
                size: 12.sp,
                color: isActive ? Colors.white : item.accent,
              ),
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

class _ProsConsCompactToolbar extends StatelessWidget {
  const _ProsConsCompactToolbar({
    required this.items,
    required this.currentIndex,
    required this.currentItem,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  final List<_ProsConsNavItem> items;
  final int currentIndex;
  final _ProsConsNavItem currentItem;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

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
                      currentItem.description,
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
              FilledButton.tonalIcon(
                onPressed: onAddPressed,
                icon: const Icon(FontAwesomeIcons.plus),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  foregroundColor: currentItem.accent,
                  backgroundColor: currentItem.accent.withValues(alpha: 0.12),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
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
                  child: _ProsConsPill(
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
