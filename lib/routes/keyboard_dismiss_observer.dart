import 'package:flutter/widgets.dart';

/// 路由观察器：在页面切换时自动关闭键盘
///
/// 解决真机测试时键盘在页面切换时不会自动消失的问题
class KeyboardDismissObserver extends NavigatorObserver {
  /// 关闭键盘的通用方法
  void _dismissKeyboard() {
    // 使用 FocusManager 取消当前焦点，从而关闭键盘
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // 新页面推入时关闭键盘
    _dismissKeyboard();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // 页面弹出时关闭键盘
    _dismissKeyboard();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // 页面替换时关闭键盘
    _dismissKeyboard();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    // 页面移除时关闭键盘
    _dismissKeyboard();
  }
}

/// 全局键盘关闭观察器实例
final KeyboardDismissObserver keyboardDismissObserver = KeyboardDismissObserver();
