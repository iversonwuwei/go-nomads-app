import 'database/user_profile_dao.dart';
import 'database_service.dart';

/// 数据库初始化服务
///
/// ⚠️ 用途:仅用于初始化必要的数据库表结构(Token表、UserProfile表等)
/// ⚠️ 测试数据已移除:不再生成城市、活动、用户等测试数据
/// ⚠️ 数据来源:应用数据全部从后端API获取
class DatabaseInitializer {
  final DatabaseService _dbService = DatabaseService();
  final UserProfileDao _userProfileDao = UserProfileDao();

  /// 初始化数据库表结构
  ///
  /// [forceReset] 是否强制重置数据库(慎用,会清空所有本地数据)
  Future<void> initializeDatabase({bool forceReset = false}) async {
    // 如果需要强制重置,删除整个数据库文件并重新创建
    if (forceReset) {
      print('🔄 强制重置数据库...');
      await _dbService.deleteDatabase();
    }

    // 确保数据库已创建
    await _dbService.database;

    // 初始化用户资料模块表（8个独立的表）
    print('👤 初始化用户资料模块表...');
    await _userProfileDao.createUserProfileTables();
    print('✅ 用户资料模块表创建完成');

    print('✅ 数据库初始化完成！(仅表结构,无测试数据)');
  }
}
