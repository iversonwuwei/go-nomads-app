import 'package:go_nomads_app/core/domain/result.dart';

import 'package:go_nomads_app/features/skill/domain/entities/skill.dart';

/// Skill Repository Interface - 技能仓储接口
abstract class ISkillRepository {
  /// 获取所有技能列表
  Future<Result<List<Skill>>> getSkills();

  /// 获取技能详情
  Future<Result<Skill>> getSkillById(String id);

  /// 按类别获取技能列表
  Future<Result<List<Skill>>> getSkillsByCategory(String category);

  /// 获取用户的技能列表
  Future<Result<List<UserSkill>>> getUserSkills(String userId);

  /// 添加用户技能
  Future<Result<UserSkill>> addUserSkill(
    String userId,
    AddUserSkillRequest request,
  );

  /// 更新用户技能熟练度
  Future<Result<UserSkill>> updateUserSkillProficiency(
    String userId,
    String skillId,
    String proficiencyLevel,
    int? yearsOfExperience,
  );

  /// 删除用户技能
  Future<Result<void>> removeUserSkill(
    String userId,
    String skillId,
  );

  /// 搜索技能
  Future<Result<List<Skill>>> searchSkills(String query);
}
