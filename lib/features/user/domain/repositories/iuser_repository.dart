import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/features/user/domain/entities/nomad_stats.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';

/// 用户仓储接口
///
/// 定义用户数据访问的抽象接口
abstract class IUserRepository implements IRepository {
  @override
  String get repositoryName => 'UserRepository';

  /// 批量获取用户信息
  Future<Result<List<User>>> batchGetUsers(List<String> userIds);

  /// 获取单个用户信息
  Future<Result<User>> getUser(String userId);

  /// 获取当前登录用户信息
  Future<Result<User>> getCurrentUser();

  /// 更新用户信息
  Future<Result<User>> updateUser(String userId, Map<String, dynamic> updates);

  /// 搜索用户
  Future<Result<List<User>>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  // ==================== 收藏城市相关方法 ====================

  /// 检查城市是否已收藏
  Future<Result<bool>> isCityFavorited(String cityId);

  /// 添加收藏城市
  Future<Result<bool>> addFavoriteCity(String cityId);

  /// 移除收藏城市
  Future<Result<bool>> removeFavoriteCity(String cityId);

  /// 切换收藏状态
  Future<Result<bool>> toggleFavoriteCity(String cityId);

  /// 获取用户收藏的城市ID列表
  Future<Result<List<String>>> getUserFavoriteCityIds();

  // ==================== 用户统计数据相关方法 ====================

  /// 获取当前用户的游牧统计数据
  Future<Result<NomadStats>> getCurrentUserStats();

  /// 获取指定用户的游牧统计数据
  Future<Result<NomadStats>> getUserStats(String userId);

  /// 更新当前用户的游牧统计数据
  Future<Result<NomadStats>> updateCurrentUserStats(NomadStats stats);
}
