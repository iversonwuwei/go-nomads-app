import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:go_nomads_app/pages/assign_moderator/widgets/assign_moderator_app_bar.dart';
import 'package:go_nomads_app/pages/assign_moderator/widgets/assign_moderator_bottom_bar.dart';
import 'package:go_nomads_app/pages/assign_moderator/widgets/assign_moderator_search_bar.dart';
import 'package:go_nomads_app/pages/assign_moderator/widgets/assign_moderator_user_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 指定版主页面 - 使用 GetView 模式
class AssignModeratorPage extends GetView<AssignModeratorController> {
  const AssignModeratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AssignModeratorAppBar(controller: controller),
      body: Column(
        children: [
          // 搜索栏
          AssignModeratorSearchBar(controller: controller),

          // 分割线
          Divider(height: 1, color: Colors.grey[300]),

          // 用户列表
          const Expanded(
            child: AssignModeratorUserList(),
          ),

          // 底部操作栏
          AssignModeratorBottomBar(controller: controller),
        ],
      ),
    );
  }
}
