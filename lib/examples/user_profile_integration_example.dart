import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/modular_user_profile_page.dart';
import '../services/database/user_profile_dao.dart';

/// 用户资料系统快速集成示例
///
/// 使用方法：
/// 1. 在应用启动时初始化数据库表
/// 2. 在需要的地方调用导航方法
class UserProfileIntegrationExample {
  /// 步骤1：在应用启动时初始化数据库表
  ///
  /// 在 main.dart 或 database_initializer.dart 中调用
  static Future<void> initializeDatabase() async {
    print('🔧 初始化用户资料数据库表...');

    final userProfileDao = UserProfileDao();
    await userProfileDao.createUserProfileTables();

    print('✅ 用户资料模块表创建完成');
    print('   - user_basic_info');
    print('   - nomad_stats');
    print('   - user_skills');
    print('   - user_interests');
    print('   - user_social_links');
    print('   - travel_plans');
    print('   - user_badges');
    print('   - travel_history');
  }

  /// 步骤2：从任何页面导航到用户资料页面
  ///
  /// 示例1：从 Drawer 导航
  static Widget buildDrawerMenuItem(int currentAccountId) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text('我的资料'),
      onTap: () {
        Get.back(); // 关闭 Drawer
        Get.to(() => ModularUserProfilePage(
              accountId: currentAccountId,
              username: '当前用户', // 可选
            ));
      },
    );
  }

  /// 示例2：从底部导航栏导航
  static void navigateFromBottomNav(int currentAccountId) {
    Get.to(() => ModularUserProfilePage(
          accountId: currentAccountId,
        ));
  }

  /// 示例3：从登录成功后导航
  static void navigateAfterLogin(int accountId, String username) {
    Get.offAll(() => ModularUserProfilePage(
          accountId: accountId,
          username: username,
        ));
  }

  /// 示例4：从注册成功后导航（引导用户完善资料）
  static void navigateAfterRegister(int accountId, String username) {
    // 可以先显示欢迎对话框
    Get.dialog(
      AlertDialog(
        title: const Text('🎉 注册成功！'),
        content: const Text('欢迎加入！现在完善您的个人资料，让其他数字游民更好地了解您。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('稍后'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // 关闭对话框
              Get.to(() => ModularUserProfilePage(
                    accountId: accountId,
                    username: username,
                  ));
            },
            child: const Text('立即完善'),
          ),
        ],
      ),
    );
  }

  /// 示例5：创建一个浮动按钮快速访问
  static Widget buildFloatingActionButton(int currentAccountId) {
    return FloatingActionButton(
      onPressed: () {
        Get.to(() => ModularUserProfilePage(
              accountId: currentAccountId,
            ));
      },
      tooltip: '我的资料',
      child: const Icon(Icons.person),
    );
  }

  /// 示例6：在设置页面添加入口
  static Widget buildSettingsListTile(int currentAccountId) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: const Text('个人资料'),
        subtitle: const Text('编辑您的基本信息、技能、兴趣等'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Get.to(() => ModularUserProfilePage(
                accountId: currentAccountId,
              ));
        },
      ),
    );
  }
}

/// 在 main.dart 中使用示例
/// 
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // 初始化数据库
///   await UserProfileIntegrationExample.initializeDatabase();
///   
///   runApp(const MyApp());
/// }
/// ```

/// 在 Drawer 中使用示例
/// 
/// ```dart
/// Drawer(
///   child: ListView(
///     children: [
///       UserAccountsDrawerHeader(...),
///       
///       // 添加资料入口
///       UserProfileIntegrationExample.buildDrawerMenuItem(currentAccountId),
///       
///       // 其他菜单项...
///     ],
///   ),
/// )
/// ```

/// 在登录成功后使用示例
/// 
/// ```dart
/// // 在 login_page.dart 中
/// void _login() async {
///   final account = await _accountDao.login(email, password);
///   
///   if (account != null) {
///     // 保存登录状态
///     final accountId = account['id'] as int;
///     final username = account['username'] as String;
///     
///     // 导航到资料页面
///     UserProfileIntegrationExample.navigateAfterLogin(accountId, username);
///   }
/// }
/// ```

/// 在注册成功后使用示例
/// 
/// ```dart
/// // 在 register_page.dart 中
/// void _register() async {
///   final accountId = await _accountDao.registerAccount(
///     email,
///     username,
///     password,
///     name,
///   );
///   
///   if (accountId != null) {
///     // 显示欢迎对话框并引导完善资料
///     UserProfileIntegrationExample.navigateAfterRegister(accountId, username);
///   }
/// }
/// ```
