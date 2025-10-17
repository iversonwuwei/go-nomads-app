import 'services/database/account_dao.dart';

/// 临时脚本：删除指定邮箱的账户
void main() async {
  print('🗑️ 开始删除账户...');

  final accountDao = AccountDao();

  // 先创建表（如果需要）
  await accountDao.createAccountTables();

  // 删除指定邮箱的账户
  final success = await accountDao.deleteAccountByEmail('waldenwuwei@163.com');

  if (success) {
    print('✅ 账户删除成功！');
  } else {
    print('❌ 账户删除失败！');
  }

  // 列出所有剩余账户
  print('\n📋 剩余账户列表：');
  final accounts = await accountDao.getAllAccounts();
  if (accounts.isEmpty) {
    print('   （无账户）');
  } else {
    for (var account in accounts) {
      print('   - ${account['username']} (${account['email']})');
    }
  }
}
