import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/features/innovation_project/domain/repositories/i_innovation_project_repository.dart';
import 'package:go_nomads_app/features/innovation_project/infrastructure/models/innovation_project_dto.dart';

/// 获取所有项目用例
class GetProjectsUseCase {
  final IInnovationProjectRepository _repository;

  GetProjectsUseCase(this._repository);

  Future<Result<List<InnovationProject>>> call({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? stage,
    String? search,
  }) {
    return _repository.getProjects(
      page: page,
      pageSize: pageSize,
      category: category,
      stage: stage,
      search: search,
    );
  }
}

class GetProjectsPageUseCase {
  final IInnovationProjectRepository _repository;

  GetProjectsPageUseCase(this._repository);

  Future<Result<InnovationProjectPageResult>> call({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? stage,
    String? search,
  }) {
    return _repository.getProjectsPage(
      page: page,
      pageSize: pageSize,
      category: category,
      stage: stage,
      search: search,
    );
  }
}

/// 获取项目详情用例
class GetProjectByIdUseCase {
  final IInnovationProjectRepository _repository;

  GetProjectByIdUseCase(this._repository);

  Future<Result<InnovationProject>> call(GetProjectByIdParams params) {
    return _repository.getProjectById(params.projectId);
  }
}

class GetProjectByIdParams {
  final String projectId;

  GetProjectByIdParams({required this.projectId});
}

/// 创建项目用例
class CreateProjectUseCase {
  final IInnovationProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  Future<Result<InnovationProject>> call(CreateProjectParams params) {
    return _repository.createProject(params.request);
  }
}

class CreateProjectParams {
  final CreateInnovationRequest request;

  CreateProjectParams({required this.request});
}

/// 更新项目用例
class UpdateProjectUseCase {
  final IInnovationProjectRepository _repository;

  UpdateProjectUseCase(this._repository);

  Future<Result<InnovationProject>> call(UpdateProjectParams params) {
    return _repository.updateProject(params.projectId, params.projectData);
  }
}

class UpdateProjectParams {
  final String projectId;
  final Map<String, dynamic> projectData;

  UpdateProjectParams({
    required this.projectId,
    required this.projectData,
  });
}

/// 删除项目用例
class DeleteProjectUseCase {
  final IInnovationProjectRepository _repository;

  DeleteProjectUseCase(this._repository);

  Future<Result<void>> call(DeleteProjectParams params) {
    return _repository.deleteProject(params.projectId);
  }
}

class DeleteProjectParams {
  final String projectId;

  DeleteProjectParams({required this.projectId});
}

/// 获取用户项目列表用例
class GetProjectsByUserUseCase {
  final IInnovationProjectRepository _repository;

  GetProjectsByUserUseCase(this._repository);

  Future<Result<List<InnovationProject>>> call(GetProjectsByUserParams params) {
    return _repository.getProjectsByUser(params.userId);
  }
}

class GetProjectsByUserParams {
  final String userId;

  GetProjectsByUserParams({required this.userId});
}

/// 获取我的项目用例
class GetMyProjectsUseCase {
  final IInnovationProjectRepository _repository;

  GetMyProjectsUseCase(this._repository);

  Future<Result<List<InnovationProject>>> call({
    int page = 1,
    int pageSize = 20,
  }) {
    return _repository.getMyProjects(page: page, pageSize: pageSize);
  }
}

/// 搜索项目用例
class SearchProjectsUseCase {
  final IInnovationProjectRepository _repository;

  SearchProjectsUseCase(this._repository);

  Future<Result<List<InnovationProject>>> call(SearchProjectsParams params) {
    return _repository.searchProjects(params.query);
  }
}

class SearchProjectsParams {
  final String query;

  SearchProjectsParams({required this.query});
}

/// 获取团队成员用例
class GetTeamMembersUseCase {
  final IInnovationProjectRepository _repository;

  GetTeamMembersUseCase(this._repository);

  Future<Result<List<TeamMember>>> call(GetTeamMembersParams params) {
    return _repository.getTeamMembers(params.projectId);
  }
}

class GetTeamMembersParams {
  final String projectId;

  GetTeamMembersParams({required this.projectId});
}

/// 添加团队成员用例
class AddTeamMemberUseCase {
  final IInnovationProjectRepository _repository;

  AddTeamMemberUseCase(this._repository);

  Future<Result<TeamMember>> call(AddTeamMemberParams params) {
    return _repository.addTeamMember(params.projectId, params.memberData);
  }
}

class AddTeamMemberParams {
  final String projectId;
  final Map<String, dynamic> memberData;

  AddTeamMemberParams({
    required this.projectId,
    required this.memberData,
  });
}

/// 移除团队成员用例
class RemoveTeamMemberUseCase {
  final IInnovationProjectRepository _repository;

  RemoveTeamMemberUseCase(this._repository);

  Future<Result<void>> call(RemoveTeamMemberParams params) {
    return _repository.removeTeamMember(params.projectId, params.memberId);
  }
}

class RemoveTeamMemberParams {
  final String projectId;
  final String memberId;

  RemoveTeamMemberParams({
    required this.projectId,
    required this.memberId,
  });
}

/// 点赞/取消点赞用例
class ToggleLikeUseCase {
  final IInnovationProjectRepository _repository;

  ToggleLikeUseCase(this._repository);

  Future<Result<bool>> call(ToggleLikeParams params) {
    return _repository.toggleLike(params.projectId);
  }
}

class ToggleLikeParams {
  final String projectId;

  ToggleLikeParams({required this.projectId});
}

/// 获取热门项目用例
class GetPopularProjectsUseCase {
  final IInnovationProjectRepository _repository;

  GetPopularProjectsUseCase(this._repository);

  Future<Result<List<InnovationProject>>> call(
      GetPopularProjectsParams params) {
    return _repository.getPopularProjects(params.limit);
  }
}

class GetPopularProjectsParams {
  final int limit;

  GetPopularProjectsParams({required this.limit});
}

/// 获取精选项目用例
class GetFeaturedProjectsUseCase {
  final IInnovationProjectRepository _repository;

  GetFeaturedProjectsUseCase(this._repository);

  Future<Result<List<InnovationProject>>> call(
      GetFeaturedProjectsParams params) {
    return _repository.getFeaturedProjects(params.limit);
  }
}

class GetFeaturedProjectsParams {
  final int limit;

  GetFeaturedProjectsParams({required this.limit});
}
