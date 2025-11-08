import 'package:df_admin_mobile/core/domain/result.dart';

import '../../domain/entities/innovation_project.dart';
import '../../domain/repositories/i_innovation_project_repository.dart';

/// 获取所有项目用例
class GetProjectsUseCase {
  final IInnovationProjectRepository _repository;

  GetProjectsUseCase(this._repository);

  Future<Result<List<InnovationProject>>> call() {
    return _repository.getProjects();
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
  final int projectId;

  GetProjectByIdParams({required this.projectId});
}

/// 创建项目用例
class CreateProjectUseCase {
  final IInnovationProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  Future<Result<InnovationProject>> call(CreateProjectParams params) {
    return _repository.createProject(params.projectData);
  }
}

class CreateProjectParams {
  final Map<String, dynamic> projectData;

  CreateProjectParams({required this.projectData});
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
  final int projectId;
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
  final int projectId;

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
  final int userId;

  GetProjectsByUserParams({required this.userId});
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
  final int projectId;

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
  final int projectId;
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
    return _repository.removeTeamMember(params.projectId, params.memberName);
  }
}

class RemoveTeamMemberParams {
  final int projectId;
  final String memberName;

  RemoveTeamMemberParams({
    required this.projectId,
    required this.memberName,
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
  final int projectId;

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
