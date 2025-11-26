import 'package:df_admin_mobile/core/domain/result.dart';

import 'package:df_admin_mobile/features/interest/domain/entities/interest.dart';

/// Interest Repository Interface - 兴趣仓储接口
abstract class IInterestRepository {
  /// 获取所有兴趣列表
  Future<Result<List<Interest>>> getInterests();

  /// 获取兴趣详情
  Future<Result<Interest>> getInterestById(String id);

  /// 按类别获取兴趣列表
  Future<Result<List<Interest>>> getInterestsByCategory(String category);

  /// 获取用户的兴趣列表
  Future<Result<List<UserInterest>>> getUserInterests(String userId);

  /// 添加用户兴趣
  Future<Result<UserInterest>> addUserInterest(
    String userId,
    AddUserInterestRequest request,
  );

  /// 更新用户兴趣强度级别
  Future<Result<UserInterest>> updateUserInterestIntensity(
    String userId,
    String interestId,
    String intensityLevel,
  );

  /// 删除用户兴趣
  Future<Result<void>> removeUserInterest(
    String userId,
    String interestId,
  );

  /// 搜索兴趣
  Future<Result<List<Interest>>> searchInterests(String query);
}
