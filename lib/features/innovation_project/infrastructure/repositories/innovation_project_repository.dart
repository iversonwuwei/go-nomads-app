import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/services/http_service.dart';

import '../../domain/entities/innovation_project.dart';
import '../../domain/repositories/i_innovation_project_repository.dart';
import '../models/innovation_project_dto.dart';

/// 创新项目仓储实现
class InnovationProjectRepository implements IInnovationProjectRepository {
  final HttpService _httpService;

  InnovationProjectRepository(this._httpService);

  @override
  Future<Result<List<InnovationProject>>> getProjects() async {
    try {
      final response = await _httpService.get('/innovation-projects');
      final projects = (response.data as List)
          .map((json) => InnovationProjectDto.fromJson(json).toDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取项目列表失败: $e'));
    }
  }

  @override
  Future<Result<InnovationProject>> getProjectById(int projectId) async {
    try {
      final response =
          await _httpService.get('/innovation-projects/$projectId');
      final project = InnovationProjectDto.fromJson(response.data).toDomain();
      return Success(project);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取项目详情失败: $e'));
    }
  }

  @override
  Future<Result<InnovationProject>> createProject(
      Map<String, dynamic> projectData) async {
    try {
      final response =
          await _httpService.post('/innovation-projects', data: projectData);
      final project = InnovationProjectDto.fromJson(response.data).toDomain();
      return Success(project);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('创建项目失败: $e'));
    }
  }

  @override
  Future<Result<InnovationProject>> updateProject(
      int projectId, Map<String, dynamic> projectData) async {
    try {
      final response = await _httpService.put('/innovation-projects/$projectId',
          data: projectData);
      final project = InnovationProjectDto.fromJson(response.data).toDomain();
      return Success(project);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('更新项目失败: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProject(int projectId) async {
    try {
      await _httpService.delete('/innovation-projects/$projectId');
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('删除项目失败: $e'));
    }
  }

  @override
  Future<Result<List<InnovationProject>>> getProjectsByUser(int userId) async {
    try {
      final response =
          await _httpService.get('/innovation-projects/user/$userId');
      final projects = (response.data as List)
          .map((json) => InnovationProjectDto.fromJson(json).toDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取用户项目列表失败: $e'));
    }
  }

  @override
  Future<Result<List<InnovationProject>>> searchProjects(String query) async {
    try {
      final response = await _httpService
          .get('/innovation-projects/search', queryParameters: {'q': query});
      final projects = (response.data as List)
          .map((json) => InnovationProjectDto.fromJson(json).toDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('搜索项目失败: $e'));
    }
  }

  @override
  Future<Result<List<TeamMember>>> getTeamMembers(int projectId) async {
    try {
      final response =
          await _httpService.get('/innovation-projects/$projectId/team');
      final members = (response.data as List)
          .map((json) => TeamMemberDto.fromJson(json).toDomain())
          .toList();
      return Success(members);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取团队成员失败: $e'));
    }
  }

  @override
  Future<Result<TeamMember>> addTeamMember(
      int projectId, Map<String, dynamic> memberData) async {
    try {
      final response = await _httpService
          .post('/innovation-projects/$projectId/team', data: memberData);
      final member = TeamMemberDto.fromJson(response.data).toDomain();
      return Success(member);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('添加团队成员失败: $e'));
    }
  }

  @override
  Future<Result<void>> removeTeamMember(
      int projectId, String memberName) async {
    try {
      await _httpService
          .delete('/innovation-projects/$projectId/team/$memberName');
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('移除团队成员失败: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleLike(int projectId) async {
    try {
      final response =
          await _httpService.post('/innovation-projects/$projectId/like');
      final isLiked = response.data['isLiked'] as bool;
      return Success(isLiked);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('点赞操作失败: $e'));
    }
  }

  @override
  Future<Result<List<InnovationProject>>> getPopularProjects(int limit) async {
    try {
      final response = await _httpService.get('/innovation-projects/popular',
          queryParameters: {'limit': limit});
      final projects = (response.data as List)
          .map((json) => InnovationProjectDto.fromJson(json).toDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取热门项目失败: $e'));
    }
  }

  /// 转换HTTP异常为领域异常
  DomainException _convertHttpException(HttpException e) {
    switch (e.statusCode) {
      case 400:
        return ValidationException(e.message);
      case 401:
      case 403:
        return UnauthorizedException(e.message);
      case 404:
        return NotFoundException(e.message);
      case 500:
      case 502:
      case 503:
        return ServerException(e.message);
      case null:
        return NetworkException(e.message);
      default:
        return UnknownException(e.message);
    }
  }
}
