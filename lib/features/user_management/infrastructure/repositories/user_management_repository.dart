import '../../../../core/domain/result.dart';
import '../../../../services/http_service.dart';
import '../../domain/entities/simple_user.dart';
import '../../domain/repositories/iuser_management_repository.dart';
import '../models/simple_user_dto.dart';

/// User Management Repository Implementation
class UserManagementRepository implements IUserManagementRepository {
  final HttpService _httpService;

  UserManagementRepository(this._httpService);

  @override
  Future<Result<List<SimpleUser>>> getUsers({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _httpService.get(
        '/users',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List?)
                ?.map((json) => SimpleUserDto.fromJson(json).toEntity())
                .toList() ??
            [];

        return Result.success(items);
      }

      return Result.failure(const ServerException('获取用户列表失败'));
    } catch (e) {
      return Result.failure(ServerException('获取用户列表失败: $e'));
    }
  }

  @override
  Future<Result<List<SimpleUser>>> searchUsers({
    String? query,
    String? role,
    required int page,
    required int pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }

      final response = await _httpService.get(
        '/users/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List?)
                ?.map((json) => SimpleUserDto.fromJson(json).toEntity())
                .toList() ??
            [];

        return Result.success(items);
      }

      return Result.failure(const ServerException('搜索用户失败'));
    } catch (e) {
      return Result.failure(ServerException('搜索用户失败: $e'));
    }
  }

  @override
  Future<Result<SimpleUser>> changeUserRole({
    required String userId,
    required String roleId,
  }) async {
    try {
      final response = await _httpService.patch(
        '/users/$userId/role',
        data: {'roleId': roleId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final user = SimpleUserDto.fromJson(response.data).toEntity();
        return Result.success(user);
      }

      return Result.failure(const ServerException('修改用户角色失败'));
    } catch (e) {
      return Result.failure(ServerException('修改用户角色失败: $e'));
    }
  }

  @override
  Future<Result<List<SimpleUser>>> batchChangeUserRole({
    required List<String> userIds,
    required String roleId,
  }) async {
    try {
      // 后端暂无批量接口，循环调用单个接口
      final updatedUsers = <SimpleUser>[];
      
      for (final userId in userIds) {
        final result = await changeUserRole(userId: userId, roleId: roleId);
        if (result.isSuccess) {
          updatedUsers.add(result.dataOrNull!);
        } else {
          return Result.failure(ServerException(
              '修改用户 $userId 的角色失败'));
        }
      }
      
      return Result.success(updatedUsers);
    } catch (e) {
      return Result.failure(ServerException('批量修改用户角色失败: $e'));
    }
  }

  @override
  Future<Result<List<RoleInfo>>> getAllRoles() async {
    try {
      final response = await _httpService.get('/roles');

      if (response.statusCode == 200 && response.data != null) {
        final roles = (response.data as List?)
                ?.map((json) => RoleInfo(
                      id: json['id'] as String,
                      name: json['name'] as String,
                      description: json['description'] as String?,
                    ))
                .toList() ??
            [];

        return Result.success(roles);
      }

      // 其他状态码视为失败但不抛出异常
      return Result.failure(
          ServerException('获取角色列表失败 (状态码: ${response.statusCode})'));
    } catch (e) {
      // 捕获所有异常（包括 404），返回友好的错误信息
      return Result.failure(
          ServerException('角色接口不可用，请确认后端 /api/v1/roles 接口已实现'));
    }
  }
}
