import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/features/innovation_project/domain/repositories/i_innovation_project_repository.dart';
import 'package:go_nomads_app/features/innovation_project/infrastructure/models/innovation_project_dto.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// 创新项目仓储实现
class InnovationProjectRepository implements IInnovationProjectRepository {
  final HttpService _httpService;

  /// API 基础路径
  static const String _basePath = '/innovations';

  InnovationProjectRepository(this._httpService);

  @override
  Future<Result<List<InnovationProject>>> getProjects({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? stage,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (category != null) queryParams['category'] = category;
      if (stage != null) queryParams['stage'] = stage;
      if (search != null) queryParams['search'] = search;

      final response = await _httpService.get(
        _basePath,
        queryParameters: queryParams,
      );

      // HttpService 拦截器会自动解包 ApiResponse，response.data 已经是内层的 data 字段
      // 即 {items: [...], total: 3, page: 1, pageSize: 20, totalPages: 1}
      final pagedData = response.data as Map<String, dynamic>;
      final items = (pagedData['items'] as List)
          .map((json) {
            try {
              return InnovationListItemDto.fromJson(json as Map<String, dynamic>).toSimpleDomain();
            } catch (parseError) {
              print('解析项目失败: $parseError, json: $json');
              rethrow;
            }
          })
          .toList();
      return Success(items);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e, stackTrace) {
      print('获取项目列表异常: $e');
      print('堆栈: $stackTrace');
      return Failure(UnknownException('获取项目列表失败: $e'));
    }
  }

  @override
  Future<Result<InnovationProject>> getProjectById(String projectId) async {
    try {
      final response = await _httpService.get('$_basePath/$projectId');

      // HttpService 拦截器会自动解包，response.data 已经是项目数据
      final project =
          InnovationProjectDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      return Success(project);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取项目详情失败: $e'));
    }
  }

  @override
  Future<Result<InnovationProject>> createProject(
      CreateInnovationRequest request) async {
    try {
      final response = await _httpService.post(
        _basePath,
        data: request.toJson(),
      );

      // HttpService 拦截器会自动解包
      final project =
          InnovationProjectDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      return Success(project);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('创建项目失败: $e'));
    }
  }

  @override
  Future<Result<InnovationProject>> updateProject(
      String projectId, Map<String, dynamic> projectData) async {
    try {
      final response = await _httpService.put(
        '$_basePath/$projectId',
        data: projectData,
      );

      // HttpService 拦截器会自动解包
      final project =
          InnovationProjectDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      return Success(project);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('更新项目失败: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProject(String projectId) async {
    try {
      await _httpService.delete('$_basePath/$projectId');
      // HttpService 拦截器会自动处理错误，成功则直接返回
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('删除项目失败: $e'));
    }
  }

  @override
  Future<Result<List<InnovationProject>>> getProjectsByUser(
      String userId) async {
    try {
      final response = await _httpService.get('$_basePath/user/$userId');

      // HttpService 拦截器会自动解包
      final projects = (response.data as List)
          .map((json) => InnovationListItemDto.fromJson(json as Map<String, dynamic>).toSimpleDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取用户项目列表失败: $e'));
    }
  }

  @override
  Future<Result<List<InnovationProject>>> getMyProjects({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _httpService.get(
        '$_basePath/my',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      // HttpService 拦截器会自动解包
      final projects = (response.data as List)
          .map((json) => InnovationListItemDto.fromJson(json as Map<String, dynamic>).toSimpleDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取我的项目失败: $e'));
    }
  }

  @override
  Future<Result<List<InnovationProject>>> searchProjects(String query) async {
    return getProjects(search: query);
  }

  @override
  Future<Result<List<TeamMember>>> getTeamMembers(String projectId) async {
    try {
      // 通过获取项目详情来获取团队成员
      final result = await getProjectById(projectId);
      return result.fold(
        onSuccess: (project) => Success(project.team),
        onFailure: (error) => Failure(error),
      );
    } catch (e) {
      return Failure(UnknownException('获取团队成员失败: $e'));
    }
  }

  @override
  Future<Result<TeamMember>> addTeamMember(
      String projectId, Map<String, dynamic> memberData) async {
    try {
      final response = await _httpService.post(
        '$_basePath/$projectId/team',
        data: memberData,
      );

      // HttpService 拦截器会自动解包
      final member = TeamMemberDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      return Success(member);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('添加团队成员失败: $e'));
    }
  }

  @override
  Future<Result<void>> removeTeamMember(
      String projectId, String memberId) async {
    try {
      await _httpService.delete(
        '$_basePath/$projectId/team/$memberId',
      );
      // HttpService 拦截器会自动处理错误
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('移除团队成员失败: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleLike(String projectId) async {
    try {
      final response = await _httpService.post('$_basePath/$projectId/like');

      // HttpService 拦截器会自动解包
      final isLiked = (response.data as Map<String, dynamic>)['isLiked'] as bool;
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
      final response = await _httpService.get(
        '$_basePath/popular',
        queryParameters: {'limit': limit},
      );

      // HttpService 拦截器会自动解包
      final projects = (response.data as List)
          .map((json) => InnovationListItemDto.fromJson(json as Map<String, dynamic>).toSimpleDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取热门项目失败: $e'));
    }
  }

  @override
  Future<Result<List<InnovationProject>>> getFeaturedProjects(int limit) async {
    try {
      final response = await _httpService.get(
        '$_basePath/featured',
        queryParameters: {'limit': limit},
      );

      // HttpService 拦截器会自动解包
      final projects = (response.data as List)
          .map((json) => InnovationListItemDto.fromJson(json as Map<String, dynamic>).toSimpleDomain())
          .toList();
      return Success(projects);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取精选项目失败: $e'));
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
