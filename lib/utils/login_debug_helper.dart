import 'package:flutter/material.dart';

import '../services/database/token_dao.dart';
import '../services/nomads_auth_service.dart';

/// 登录状态调试工具
/// 用于检查热重启后的登录状态
class LoginDebugHelper {
  static final TokenDao _tokenDao = TokenDao();
  static final NomadsAuthService _authService = NomadsAuthService();

  /// 打印当前登录状态的详细信息
  static Future<void> printLoginStatus() async {
    print('\n${'=' * 60}');
    print('🔍 登录状态调试信息');
    print('=' * 60);

    // 1. 检查内存中的 token
    final memoryToken = _authService.currentToken;
    print('1️⃣ 内存中的 token:');
    if (memoryToken != null && memoryToken.isNotEmpty) {
      print('   ✅ 存在: ${memoryToken.substring(0, 20)}...');
    } else {
      print('   ❌ 不存在');
    }

    // 2. 检查 SQLite 中的 token
    print('\n2️⃣ SQLite 中的 token:');
    try {
      final latestToken = await _tokenDao.getLatestToken();
      if (latestToken != null) {
        print('   ✅ 找到 token:');
        print('      用户ID: ${latestToken['user_id']}');
        print('      Access Token: ${(latestToken['access_token'] as String).substring(0, 20)}...');
        print('      Token类型: ${latestToken['token_type']}');
        print('      过期时间: ${latestToken['expires_in']} 秒');
        print('      创建时间: ${latestToken['created_at']}');
        print('      更新时间: ${latestToken['updated_at']}');

        // 3. 检查是否过期
        final userId = latestToken['user_id'] as String;
        final isExpired = await _tokenDao.isTokenExpired(userId);
        print('\n3️⃣ Token 过期状态:');
        if (isExpired) {
          print('   ⏰ 已过期');
        } else {
          print('   ✅ 有效');
        }
      } else {
        print('   ❌ 未找到任何 token');
      }
    } catch (e) {
      print('   ❌ 查询失败: $e');
    }

    // 4. 使用 checkLoginStatus 检查
    print('\n4️⃣ checkLoginStatus() 结果:');
    try {
      final isLoggedIn = await _authService.checkLoginStatus();
      if (isLoggedIn) {
        print('   ✅ 已登录');
      } else {
        print('   ❌ 未登录');
      }
    } catch (e) {
      print('   ❌ 检查失败: $e');
    }

    print('=' * 60 + '\n');
  }

  /// 清除所有登录数据（用于测试）
  static Future<void> clearLoginData() async {
    print('\n🗑️ 清除所有登录数据...');
    await _authService.logout();
    print('✅ 登录数据已清除\n');
  }

  /// 显示调试信息的 Widget
  static Widget buildDebugButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await printLoginStatus();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('查看控制台日志了解登录状态详情'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      tooltip: '查看登录状态',
      child: const Icon(Icons.bug_report),
    );
  }
}

/// 登录状态调试页面
class LoginDebugPage extends StatefulWidget {
  const LoginDebugPage({super.key});

  @override
  State<LoginDebugPage> createState() => _LoginDebugPageState();
}

class _LoginDebugPageState extends State<LoginDebugPage> {
  String _status = '等待检查...';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
      _status = '正在检查...';
    });

    await LoginDebugHelper.printLoginStatus();

    final isLoggedIn = await NomadsAuthService().checkLoginStatus();

    if (mounted) {
      setState(() {
        _isChecking = false;
        _status = isLoggedIn ? '✅ 已登录' : '❌ 未登录';
      });
    }
  }

  Future<void> _clearData() async {
    setState(() {
      _isChecking = true;
      _status = '正在清除...';
    });

    await LoginDebugHelper.clearLoginData();

    if (mounted) {
      setState(() {
        _isChecking = false;
        _status = '🗑️ 数据已清除';
      });

      // 2秒后重新检查
      await Future.delayed(const Duration(seconds: 2));
      _checkStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录状态调试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isChecking)
              const CircularProgressIndicator()
            else
              Text(
                _status,
                style: const TextStyle(fontSize: 24),
              ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('重新检查'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _clearData,
              icon: const Icon(Icons.delete),
              label: const Text('清除登录数据'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '提示：\n'
                '1. 点击"重新检查"查看详细状态（查看控制台）\n'
                '2. 点击"清除登录数据"模拟退出登录\n'
                '3. 热重启后应该能看到登录状态保持',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
