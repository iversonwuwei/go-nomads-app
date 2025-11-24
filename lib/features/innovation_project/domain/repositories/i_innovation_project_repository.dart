import 'package:df_admin_mobile/core/domain/result.dart';

import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';

/// 创新项目仓储接口
abstract class IInnovationProjectRepository {
  /// 获取所有项目列表
  Future<Result<List<InnovationProject>>> getProjects();

  /// 根据ID获取项目详情
  Future<Result<InnovationProject>> getProjectById(int projectId);

  /// 创建新项目
  Future<Result<InnovationProject>> createProject(
      Map<String, dynamic> projectData);

  /// 更新项目
  Future<Result<InnovationProject>> updateProject(
      int projectId, Map<String, dynamic> projectData);

  /// 删除项目
  Future<Result<void>> deleteProject(int projectId);

  /// 获取用户的项目列表
  Future<Result<List<InnovationProject>>> getProjectsByUser(int userId);

  /// 搜索项目
  Future<Result<List<InnovationProject>>> searchProjects(String query);

  /// 获取项目团队成员
  Future<Result<List<TeamMember>>> getTeamMembers(int projectId);

  /// 添加团队成员
  Future<Result<TeamMember>> addTeamMember(
      int projectId, Map<String, dynamic> memberData);

  /// 移除团队成员
  Future<Result<void>> removeTeamMember(int projectId, String memberName);

  /// 点赞/取消点赞项目
  Future<Result<bool>> toggleLike(int projectId);

  /// 获取热门项目
  Future<Result<List<InnovationProject>>> getPopularProjects(int limit);
}
