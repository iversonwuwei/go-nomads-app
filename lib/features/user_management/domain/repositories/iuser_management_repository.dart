import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/user_management/domain/entities/simple_user.dart';

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

  /// 获取版主候选人列表（Pro及以上会员或Admin用户）
  Future<Result<List<ModeratorCandidate>>> getModeratorCandidates({
    String? query,
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

/// 版主候选人实体（Pro及以上会员或Admin用户）
class ModeratorCandidate {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final int membershipLevel;
  final String membershipLevelName;
  final bool isAdmin;
  final DateTime? createdAt;

  ModeratorCandidate({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.membershipLevel,
    required this.membershipLevelName,
    required this.isAdmin,
    this.createdAt,
  });

  factory ModeratorCandidate.fromJson(Map<String, dynamic> json) {
    return ModeratorCandidate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'user',
      membershipLevel: json['membershipLevel'] as int? ?? 0,
      membershipLevelName: json['membershipLevelName'] as String? ?? 'Free',
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  /// 获取显示标签（会员等级或Admin）
  String get displayBadge {
    if (isAdmin) return 'Admin';
    return membershipLevelName;
  }
}
