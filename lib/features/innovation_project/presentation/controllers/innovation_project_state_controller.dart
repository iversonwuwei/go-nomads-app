import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:get/get.dart';

import '../../application/use_cases/innovation_project_use_cases.dart';
import '../../domain/entities/innovation_project.dart';

/// 创新项目状态控制器
class InnovationProjectStateController extends GetxController {
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;
  final GetProjectsByUserUseCase _getProjectsByUserUseCase;
  final SearchProjectsUseCase _searchProjectsUseCase;
  final GetTeamMembersUseCase _getTeamMembersUseCase;
  final AddTeamMemberUseCase _addTeamMemberUseCase;
  final RemoveTeamMemberUseCase _removeTeamMemberUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final GetPopularProjectsUseCase _getPopularProjectsUseCase;

  InnovationProjectStateController({
    required GetProjectsUseCase getProjectsUseCase,
    required GetProjectByIdUseCase getProjectByIdUseCase,
    required CreateProjectUseCase createProjectUseCase,
    required UpdateProjectUseCase updateProjectUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
    required GetProjectsByUserUseCase getProjectsByUserUseCase,
    required SearchProjectsUseCase searchProjectsUseCase,
    required GetTeamMembersUseCase getTeamMembersUseCase,
    required AddTeamMemberUseCase addTeamMemberUseCase,
    required RemoveTeamMemberUseCase removeTeamMemberUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    required GetPopularProjectsUseCase getPopularProjectsUseCase,
  })  : _getProjectsUseCase = getProjectsUseCase,
        _getProjectByIdUseCase = getProjectByIdUseCase,
        _createProjectUseCase = createProjectUseCase,
        _updateProjectUseCase = updateProjectUseCase,
        _deleteProjectUseCase = deleteProjectUseCase,
        _getProjectsByUserUseCase = getProjectsByUserUseCase,
        _searchProjectsUseCase = searchProjectsUseCase,
        _getTeamMembersUseCase = getTeamMembersUseCase,
        _addTeamMemberUseCase = addTeamMemberUseCase,
        _removeTeamMemberUseCase = removeTeamMemberUseCase,
        _toggleLikeUseCase = toggleLikeUseCase,
        _getPopularProjectsUseCase = getPopularProjectsUseCase;

  // 响应式状态
  final projects = <InnovationProject>[].obs;
  final currentProject = Rx<InnovationProject?>(null);
  final teamMembers = <TeamMember>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  /// 获取所有项目
  Future<void> getProjects() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getProjectsUseCase();

    result.fold(
      onSuccess: (data) {
        projects.value = data;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
      },
    );

    isLoading.value = false;
  }

  /// 获取项目详情
  Future<void> getProjectById(int projectId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getProjectByIdUseCase(
      GetProjectByIdParams(projectId: projectId),
    );

    result.fold(
      onSuccess: (data) {
        currentProject.value = data;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
      },
    );

    isLoading.value = false;
  }

  /// 创建项目
  Future<bool> createProject(Map<String, dynamic> projectData) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _createProjectUseCase(
      CreateProjectParams(projectData: projectData),
    );

    isLoading.value = false;

    return result.fold<bool>(
      onSuccess: (data) {
        projects.add(data);
        currentProject.value = data;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// 更新项目
  Future<bool> updateProject(
      int projectId, Map<String, dynamic> projectData) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _updateProjectUseCase(
      UpdateProjectParams(projectId: projectId, projectData: projectData),
    );

    isLoading.value = false;

    return result.fold<bool>(
      onSuccess: (data) {
        final index = projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          projects[index] = data;
        }
        currentProject.value = data;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// 删除项目
  Future<bool> deleteProject(int projectId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _deleteProjectUseCase(
      DeleteProjectParams(projectId: projectId),
    );

    isLoading.value = false;

    return result.fold<bool>(
      onSuccess: (_) {
        projects.removeWhere((p) => p.id == projectId);
        if (currentProject.value?.id == projectId) {
          currentProject.value = null;
        }
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// 获取用户的项目列表
  Future<void> getProjectsByUser(int userId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getProjectsByUserUseCase(
      GetProjectsByUserParams(userId: userId),
    );

    result.fold(
      onSuccess: (data) {
        projects.value = data;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
      },
    );

    isLoading.value = false;
  }

  /// 搜索项目
  Future<void> searchProjects(String query) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _searchProjectsUseCase(
      SearchProjectsParams(query: query),
    );

    result.fold(
      onSuccess: (data) {
        projects.value = data;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
      },
    );

    isLoading.value = false;
  }

  /// 获取团队成员
  Future<void> getTeamMembers(int projectId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getTeamMembersUseCase(
      GetTeamMembersParams(projectId: projectId),
    );

    result.fold(
      onSuccess: (data) {
        teamMembers.value = data;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
      },
    );

    isLoading.value = false;
  }

  /// 添加团队成员
  Future<bool> addTeamMember(
      int projectId, Map<String, dynamic> memberData) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _addTeamMemberUseCase(
      AddTeamMemberParams(projectId: projectId, memberData: memberData),
    );

    isLoading.value = false;

    return result.fold<bool>(
      onSuccess: (data) {
        teamMembers.add(data);
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// 移除团队成员
  Future<bool> removeTeamMember(int projectId, String memberName) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _removeTeamMemberUseCase(
      RemoveTeamMemberParams(projectId: projectId, memberName: memberName),
    );

    isLoading.value = false;

    return result.fold<bool>(
      onSuccess: (_) {
        teamMembers.removeWhere((m) => m.name == memberName);
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// 点赞/取消点赞
  Future<bool> toggleLike(int projectId) async {
    errorMessage.value = null;

    final result = await _toggleLikeUseCase(
      ToggleLikeParams(projectId: projectId),
    );

    return result.fold<bool>(
      onSuccess: (isLiked) {
        // 更新本地项目的点赞状态
        // Note: 需要创建新的项目实例来触发响应式更新
        // 这里简单返回结果,实际使用时可能需要刷新项目数据
        return isLiked;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// 获取热门项目
  Future<void> getPopularProjects({int limit = 10}) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getPopularProjectsUseCase(
      GetPopularProjectsParams(limit: limit),
    );

    result.fold(
      onSuccess: (data) {
        projects.value = data;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
      },
    );

    isLoading.value = false;
  }

  /// 清除错误消息
  void clearError() {
    errorMessage.value = null;
  }

  /// 清除当前项目
  void clearCurrentProject() {
    currentProject.value = null;
  }
}
