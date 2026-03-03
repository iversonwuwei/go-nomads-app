import 'package:go_nomads_app/core/domain/result.dart';

import 'package:go_nomads_app/features/skill/domain/entities/skill.dart';
import 'package:go_nomads_app/features/skill/domain/repositories/i_skill_repository.dart';

/// GetSkillsUseCase - 获取技能列表用例
class GetSkillsUseCase {
  final ISkillRepository _repository;

  GetSkillsUseCase(this._repository);

  Future<Result<List<Skill>>> call() async {
    return await _repository.getSkills();
  }
}

/// GetSkillsByCategoryUseCase - 按类别获取技能用例
class GetSkillsByCategoryUseCase {
  final ISkillRepository _repository;

  GetSkillsByCategoryUseCase(this._repository);

  Future<Result<List<Skill>>> call(GetSkillsByCategoryParams params) async {
    return await _repository.getSkillsByCategory(params.category);
  }
}

class GetSkillsByCategoryParams {
  final String category;

  GetSkillsByCategoryParams({required this.category});
}

/// GetUserSkillsUseCase - 获取用户技能列表用例
class GetUserSkillsUseCase {
  final ISkillRepository _repository;

  GetUserSkillsUseCase(this._repository);

  Future<Result<List<UserSkill>>> call(GetUserSkillsParams params) async {
    return await _repository.getUserSkills(params.userId);
  }
}

class GetUserSkillsParams {
  final String userId;

  GetUserSkillsParams({required this.userId});
}

/// AddUserSkillUseCase - 添加用户技能用例
class AddUserSkillUseCase {
  final ISkillRepository _repository;

  AddUserSkillUseCase(this._repository);

  Future<Result<UserSkill>> call(AddUserSkillParams params) async {
    return await _repository.addUserSkill(
      params.userId,
      params.request,
    );
  }
}

class AddUserSkillParams {
  final String userId;
  final AddUserSkillRequest request;

  AddUserSkillParams({
    required this.userId,
    required this.request,
  });
}

/// UpdateUserSkillProficiencyUseCase - 更新用户技能熟练度用例
class UpdateUserSkillProficiencyUseCase {
  final ISkillRepository _repository;

  UpdateUserSkillProficiencyUseCase(this._repository);

  Future<Result<UserSkill>> call(
      UpdateUserSkillProficiencyParams params) async {
    return await _repository.updateUserSkillProficiency(
      params.userId,
      params.skillId,
      params.proficiencyLevel,
      params.yearsOfExperience,
    );
  }
}

class UpdateUserSkillProficiencyParams {
  final String userId;
  final String skillId;
  final String proficiencyLevel;
  final int? yearsOfExperience;

  UpdateUserSkillProficiencyParams({
    required this.userId,
    required this.skillId,
    required this.proficiencyLevel,
    this.yearsOfExperience,
  });
}

/// RemoveUserSkillUseCase - 删除用户技能用例
class RemoveUserSkillUseCase {
  final ISkillRepository _repository;

  RemoveUserSkillUseCase(this._repository);

  Future<Result<void>> call(RemoveUserSkillParams params) async {
    return await _repository.removeUserSkill(
      params.userId,
      params.skillId,
    );
  }
}

class RemoveUserSkillParams {
  final String userId;
  final String skillId;

  RemoveUserSkillParams({
    required this.userId,
    required this.skillId,
  });
}

/// SearchSkillsUseCase - 搜索技能用例
class SearchSkillsUseCase {
  final ISkillRepository _repository;

  SearchSkillsUseCase(this._repository);

  Future<Result<List<Skill>>> call(SearchSkillsParams params) async {
    return await _repository.searchSkills(params.query);
  }
}

class SearchSkillsParams {
  final String query;

  SearchSkillsParams({required this.query});
}
