import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/innovation_project/infrastructure/models/innovation_project_dto.dart';

/// 创新项目仓储接口
abstract class IInnovationProjectRepository {
  /// 获取所有项目列表
  Future<Result<List<InnovationProject>>> getProjects({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? stage,
    String? search,
  });

  /// 根据ID获取项目详情
  Future<Result<InnovationProject>> getProjectById(String projectId);

  /// 创建新项目
  Future<Result<InnovationProject>> createProject(
      CreateInnovationRequest request);

  /// 更新项目
  Future<Result<InnovationProject>> updateProject(
      String projectId, Map<String, dynamic> projectData);

  /// 删除项目
  Future<Result<void>> deleteProject(String projectId);

  /// 获取用户的项目列表
  Future<Result<List<InnovationProject>>> getProjectsByUser(String userId);

  /// 获取我的项目列表
  Future<Result<List<InnovationProject>>> getMyProjects({
    int page = 1,
    int pageSize = 20,
  });

  /// 搜索项目
  Future<Result<List<InnovationProject>>> searchProjects(String query);

  /// 获取项目团队成员
  Future<Result<List<TeamMember>>> getTeamMembers(String projectId);

  /// 添加团队成员
  Future<Result<TeamMember>> addTeamMember(
      String projectId, Map<String, dynamic> memberData);

  /// 移除团队成员
  Future<Result<void>> removeTeamMember(String projectId, String memberId);

  /// 点赞/取消点赞项目
  Future<Result<bool>> toggleLike(String projectId);

  /// 获取热门项目
  Future<Result<List<InnovationProject>>> getPopularProjects(int limit);

  /// 获取精选项目
  Future<Result<List<InnovationProject>>> getFeaturedProjects(int limit);
}
