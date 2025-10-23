import 'package:flutter/material.dart';

import '../services/nomads_auth_service.dart';

/// Refresh Token 使用示例
class RefreshTokenExample {
  final NomadsAuthService _authService = NomadsAuthService();

  /// 示例 1: 手动刷新当前用户的 token
  Future<void> manualRefreshCurrentUser() async {
    print('=== 示例 1: 手动刷新当前用户的 token ===');
    
    final success = await _authService.refreshToken();
    
    if (success) {
      print('✅ Token 刷新成功，可以继续使用应用');
    } else {
      print('❌ Token 刷新失败，需要重新登录');
      // 跳转到登录页
      // Get.offAllNamed(AppRoutes.login);
    }
  }

  /// 示例 2: 刷新指定用户的 token
  Future<void> manualRefreshSpecificUser(String userId) async {
    print('=== 示例 2: 刷新指定用户的 token ===');
    print('用户ID: $userId');
    
    final success = await _authService.refreshToken(userId);
    
    if (success) {
      print('✅ 用户 $userId 的 token 刷新成功');
    } else {
      print('❌ 用户 $userId 的 token 刷新失败');
    }
  }

  /// 示例 3: 在 API 请求前检查并自动刷新
  Future<void> checkAndRefreshBeforeApiCall() async {
    print('=== 示例 3: API 请求前自动检查和刷新 ===');
    
    // 检查登录状态（会自动刷新过期的 token）
    final isLoggedIn = await _authService.checkLoginStatus();
    
    if (!isLoggedIn) {
      print('❌ 登录状态检查失败，需要重新登录');
      // Get.offAllNamed(AppRoutes.login);
      return;
    }
    
    print('✅ 登录状态有效，可以进行 API 请求');
    // 执行 API 请求
    // final data = await someApiService.fetchData();
  }

  /// 示例 4: 在页面初始化时刷新 token
  /// 
  /// 用于需要保证最新 token 的页面（如支付页面）
  Future<void> refreshOnPageInit() async {
    print('=== 示例 4: 页面初始化时刷新 token ===');
    
    try {
      // 方式1: 强制刷新（不管是否过期）
      final refreshed = await _authService.refreshToken();
      
      if (refreshed) {
        print('✅ Token 已更新到最新');
      } else {
        print('⚠️ Token 刷新失败，使用现有 token');
      }
      
      // 方式2: 只在需要时刷新（推荐）
      final isValid = await _authService.checkLoginStatus();
      
      if (!isValid) {
        print('❌ 登录状态无效');
        // 处理登录失效
      }
    } catch (e) {
      print('❌ 刷新异常: $e');
    }
  }

  /// 示例 5: 带错误处理的完整刷新流程
  Future<bool> refreshWithErrorHandling() async {
    print('=== 示例 5: 带错误处理的完整刷新流程 ===');
    
    try {
      final success = await _authService.refreshToken();
      
      if (success) {
        print('✅ Token 刷新成功');
        return true;
      } else {
        print('⚠️ Token 刷新失败');
        
        // 可以尝试重新登录
        _showLoginDialog();
        return false;
      }
    } catch (e) {
      print('❌ 刷新异常: $e');
      
      // 检查异常类型
      if (e.toString().contains('Network')) {
        print('网络连接失败，请检查网络');
        _showNetworkError();
      } else if (e.toString().contains('401')) {
        print('认证失败，需要重新登录');
        _showLoginDialog();
      } else {
        print('未知错误: $e');
        _showGeneralError();
      }
      
      return false;
    }
  }

  void _showLoginDialog() {
    print('显示登录对话框');
    // 实际实现中显示对话框或跳转到登录页
  }

  void _showNetworkError() {
    print('显示网络错误提示');
    // 实际实现中显示错误提示
  }

  void _showGeneralError() {
    print('显示通用错误提示');
    // 实际实现中显示错误提示
  }
}

/// Widget 示例：在 StatefulWidget 中使用 refresh token
class RefreshTokenWidget extends StatefulWidget {
  const RefreshTokenWidget({super.key});

  @override
  State<RefreshTokenWidget> createState() => _RefreshTokenWidgetState();
}

class _RefreshTokenWidgetState extends State<RefreshTokenWidget> {
  final NomadsAuthService _authService = NomadsAuthService();
  bool _isRefreshing = false;
  String _message = '准备就绪';

  @override
  void initState() {
    super.initState();
    _checkTokenStatus();
  }

  /// 检查 token 状态
  Future<void> _checkTokenStatus() async {
    setState(() {
      _isRefreshing = true;
      _message = '正在检查 token 状态...';
    });

    final isValid = await _authService.checkLoginStatus();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _message = isValid ? '✅ Token 有效' : '❌ Token 无效';
      });
    }
  }

  /// 手动刷新 token
  Future<void> _refreshToken() async {
    setState(() {
      _isRefreshing = true;
      _message = '正在刷新 token...';
    });

    final success = await _authService.refreshToken();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _message = success ? '✅ 刷新成功' : '❌ 刷新失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh Token 示例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRefreshing)
              const CircularProgressIndicator()
            else
              Text(
                _message,
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isRefreshing ? null : _checkTokenStatus,
              child: const Text('检查 Token 状态'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRefreshing ? null : _refreshToken,
              child: const Text('手动刷新 Token'),
            ),
          ],
        ),
      ),
    );
  }
}
