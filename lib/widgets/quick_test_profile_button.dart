import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/modular_user_profile_page.dart';

/// 快速测试小部件 - 添加浮动按钮访问用户资料
///
/// 使用方法：
/// 在任何页面的 Scaffold 中添加：
/// ```dart
/// floatingActionButton: QuickTestProfileButton(),
/// ```
class QuickTestProfileButton extends StatelessWidget {
  const QuickTestProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // 使用测试账户 sarah.chen (ID=1)
        Get.to(() => const ModularUserProfilePage(
              accountId: 1,
              username: 'sarah.chen',
            ));
      },
      icon: const Icon(Icons.person),
      label: const Text('我的资料'),
      backgroundColor: Colors.blue,
    );
  }
}

/// 快速测试小部件 - 添加列表项访问用户资料
///
/// 使用方法：
/// 在任何 ListView 或 Column 中添加：
/// ```dart
/// QuickTestProfileListTile(),
/// ```
class QuickTestProfileListTile extends StatelessWidget {
  const QuickTestProfileListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: const Text(
          '📝 测试用户资料系统',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('点击查看 Sarah Chen 的完整资料'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.to(() => const ModularUserProfilePage(
                accountId: 1,
                username: 'sarah.chen',
              ));
        },
      ),
    );
  }
}

/// 快速测试小部件 - 在任意位置添加测试按钮
class QuickTestProfileButton2 extends StatelessWidget {
  const QuickTestProfileButton2({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Get.to(() => const ModularUserProfilePage(
              accountId: 1,
              username: 'sarah.chen',
            ));
      },
      icon: const Icon(Icons.person),
      label: const Text('测试用户资料'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
