import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:go_nomads_app/controllers/manage_pros_cons_page_controller.dart';
import 'pros_and_cons_add_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text(l10n.manageProsConsPageTitle(widget.cityName)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '优点', icon: Icon(FontAwesomeIcons.circleCheck)),
            Tab(text: '挑战', icon: Icon(FontAwesomeIcons.circleInfo)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () async {
              await Get.to(() => ProsAndConsAddPage(
                    cityId: widget.cityId,
                    cityName: widget.cityName,
                    initialTab: _tabController.index,
                  ));
              await _controller.loadData();
            },
            tooltip: '添加',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const ManageListSkeleton();
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildProsList(),
            _buildConsList(),
          ],
        );
      }),
    );
  }

  Widget _buildProsList() {
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
                '暂无优点数据',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
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

  Widget _buildConsList() {
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
                '暂无挑战数据',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
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
