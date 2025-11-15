import '../../../../core/domain/result.dart';
import '../entities/simple_user.dart';

/// User Management Repository Interface
abstract class IUserManagementRepository {
  /// 获取用户列表（分页）
  Future<Result<List<SimpleUser>>> getUsers({
    required int page,
    required int pageSize,
  });

  /// 搜索用户（按名称或邮箱，可筛选角色）
  Future<Result<List<SimpleUser>>> searchUsers({
    String? query,
    String? role,
    required int page,
    required int pageSize,
  });

  /// 更改用户角色
  Future<Result<SimpleUser>> changeUserRole({
    required String userId,
    required String roleId,
  });

  /// 批量更改用户角色
  Future<Result<List<SimpleUser>>> batchChangeUserRole({
    required List<String> userIds,
    required String roleId,
  });

  /// 获取所有角色
  Future<Result<List<RoleInfo>>> getAllRoles();
}

/// Role Information Value Object
class RoleInfo {
  final String id;
  final String name;
  final String? description;

  RoleInfo({
    required this.id,
    required this.name,
    this.description,
  });
}
