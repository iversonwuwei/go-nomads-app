import 'package:get/get.dart';

/// 用户状态管理控制器
/// 管理当前登录用户的账户ID、用户名等信息
/// 注意：此版本仅在内存中保存状态，应用重启后会丢失
/// 建议：后续集成 shared_preferences 或其他持久化方案
class UserStateController extends GetxController {
  // 当前登录的账户ID
  final _accountId = Rx<int?>(null);

  // 当前用户名
  final _username = Rx<String?>(null);

  // 当前用户邮箱
  final _email = Rx<String?>(null);

  // 是否已登录
  final _isLoggedIn = false.obs;
  
  // 登录状态变化事件流（用于通知其他控制器）
  final _loginStateChanged = false.obs;

  // Getters
  int? get currentAccountId => _accountId.value;
  String? get username => _username.value;
  String? get email => _email.value;
  bool get isLoggedIn => _isLoggedIn.value;
  
  // 获取登录状态变化的响应式变量（用于监听）
  RxBool get loginStateChanged => _loginStateChanged;

  /// 登录成功后保存用户信息
  void login(int accountId, String username, {String? email}) {
    _accountId.value = accountId;
    _username.value = username;
    _email.value = email;
    _isLoggedIn.value = true;
    
    // 触发登录状态变化事件
    _loginStateChanged.toggle();

    print('✅ 用户登录成功: ID=$accountId, 用户名=$username');
    print('🔔 登录状态变化事件已触发');
  }

  /// 登出
  void logout() {
    _accountId.value = null;
    _username.value = null;
    _email.value = null;
    _isLoggedIn.value = false;
    
    // 触发登录状态变化事件
    _loginStateChanged.toggle();

    print('✅ 用户已登出');
    print('🔔 登出状态变化事件已触发');
  }

  /// 更新用户名
  void updateUsername(String newUsername) {
    _username.value = newUsername;
    print('✅ 用户名已更新: $newUsername');
  }

  /// 更新邮箱
  void updateEmail(String newEmail) {
    _email.value = newEmail;
    print('✅ 邮箱已更新: $newEmail');
  }

  /// 检查是否有登录用户
  bool hasCurrentUser() {
    return _accountId.value != null && _isLoggedIn.value;
  }

  /// 获取当前账户ID，如果未登录则返回null
  int? getAccountIdOrNull() {
    if (!hasCurrentUser()) {
      print('⚠️ 用户未登录');
      return null;
    }
    return _accountId.value;
  }

  /// 强制要求登录，如果未登录则返回null
  /// 使用示例：
  /// ```dart
  /// final accountId = Get.find<UserStateController>().requireLogin();
  /// if (accountId == null) {
  ///   Get.snackbar('提示', '请先登录');
  ///   return;
  /// }
  /// ```
  int? requireLogin() {
    if (!hasCurrentUser()) {
      print('⚠️ 需要登录');
      return null;
    }
    return _accountId.value;
  }
}
