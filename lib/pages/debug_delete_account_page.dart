import 'package:flutter/material.dart';

import '../services/database/account_dao.dart';
import '../widgets/app_toast.dart';

class DebugDeleteAccountPage extends StatefulWidget {
  const DebugDeleteAccountPage({super.key});

  @override
  State<DebugDeleteAccountPage> createState() => _DebugDeleteAccountPageState();
}

class _DebugDeleteAccountPageState extends State<DebugDeleteAccountPage> {
  final _accountDao = AccountDao();
  List<Map<String, dynamic>> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _loading = true;
    });
    final accounts = await _accountDao.getAllAccounts();
    setState(() {
      _accounts = accounts;
      _loading = false;
    });
  }

  Future<void> _deleteAccount(String email, String username) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除账户 $username ($email) 吗？\n此操作不可撤销！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _accountDao.deleteAccountByEmail(email);
      if (success) {
        if (mounted) {
          AppToast.success('账户已删除: $username');
          _loadAccounts(); // 重新加载列表
        }
      } else {
        if (mounted) {
          AppToast.error('删除失败');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户管理 - 调试'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? const Center(
                  child: Text(
                    '暂无账户',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAccounts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      final email = account['email'] as String;
                      final username = account['username'] as String;
                      final id = account['id'] as int;
                      final createdAt = account['created_at'] as String?;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Text(
                              username[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          title: Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('📧 $email'),
                              Text('🆔 ID: $id'),
                              if (createdAt != null)
                                Text('📅 创建: ${_formatTimestamp(createdAt)}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAccount(email, username),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final ms = int.parse(timestamp);
      final date = DateTime.fromMillisecondsSinceEpoch(ms);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // 如果解析失败，可能是ISO格式
      try {
        final date = DateTime.parse(timestamp);
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return timestamp;
      }
    }
  }
}
