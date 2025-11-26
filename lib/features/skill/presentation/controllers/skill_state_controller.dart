import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/features/skill/application/use_cases/skill_use_cases.dart';
import 'package:df_admin_mobile/features/skill/domain/entities/skill.dart';

/// SkillStateController - 技能状态控制器
class SkillStateController extends GetxController {
  // Use Cases
  final GetSkillsUseCase _getSkillsUseCase;
  final GetSkillsByCategoryUseCase _getSkillsByCategoryUseCase;
  final GetUserSkillsUseCase _getUserSkillsUseCase;
  final AddUserSkillUseCase _addUserSkillUseCase;
  final UpdateUserSkillProficiencyUseCase _updateUserSkillProficiencyUseCase;
  final RemoveUserSkillUseCase _removeUserSkillUseCase;
  final SearchSkillsUseCase _searchSkillsUseCase;

  SkillStateController({
    required GetSkillsUseCase getSkillsUseCase,
    required GetSkillsByCategoryUseCase getSkillsByCategoryUseCase,
    required GetUserSkillsUseCase getUserSkillsUseCase,
    required AddUserSkillUseCase addUserSkillUseCase,
    required UpdateUserSkillProficiencyUseCase
        updateUserSkillProficiencyUseCase,
    required RemoveUserSkillUseCase removeUserSkillUseCase,
    required SearchSkillsUseCase searchSkillsUseCase,
  })  : _getSkillsUseCase = getSkillsUseCase,
        _getSkillsByCategoryUseCase = getSkillsByCategoryUseCase,
        _getUserSkillsUseCase = getUserSkillsUseCase,
        _addUserSkillUseCase = addUserSkillUseCase,
        _updateUserSkillProficiencyUseCase = updateUserSkillProficiencyUseCase,
        _removeUserSkillUseCase = removeUserSkillUseCase,
        _searchSkillsUseCase = searchSkillsUseCase;

  // Reactive State
  final skills = <Skill>[].obs;
  final userSkills = <UserSkill>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  /// 获取所有技能
  Future<void> getSkills() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getSkillsUseCase();
    result.fold(
      onSuccess: (data) {
        skills.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 按类别获取技能
  Future<void> getSkillsByCategory(String category) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getSkillsByCategoryUseCase(
      GetSkillsByCategoryParams(category: category),
    );
    result.fold(
      onSuccess: (data) {
        skills.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 获取用户技能列表
  Future<void> getUserSkills(String userId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getUserSkillsUseCase(
      GetUserSkillsParams(userId: userId),
    );
    result.fold(
      onSuccess: (data) {
        userSkills.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 添加用户技能
  Future<bool> addUserSkill(String userId, AddUserSkillRequest request) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _addUserSkillUseCase(
      AddUserSkillParams(userId: userId, request: request),
    );

    return result.fold<bool>(
      onSuccess: (data) {
        userSkills.add(data);
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 更新用户技能熟练度
  Future<bool> updateUserSkillProficiency(
    String userId,
    String skillId,
    String proficiencyLevel,
    int? yearsOfExperience,
  ) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _updateUserSkillProficiencyUseCase(
      UpdateUserSkillProficiencyParams(
        userId: userId,
        skillId: skillId,
        proficiencyLevel: proficiencyLevel,
        yearsOfExperience: yearsOfExperience,
      ),
    );

    return result.fold<bool>(
      onSuccess: (data) {
        final index = userSkills.indexWhere((e) => e.skillId == skillId);
        if (index != -1) {
          userSkills[index] = data;
        }
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 删除用户技能
  Future<bool> removeUserSkill(String userId, String skillId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _removeUserSkillUseCase(
      RemoveUserSkillParams(userId: userId, skillId: skillId),
    );

    return result.fold<bool>(
      onSuccess: (_) {
        userSkills.removeWhere((e) => e.skillId == skillId);
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 搜索技能
  Future<void> searchSkills(String query) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _searchSkillsUseCase(
      SearchSkillsParams(query: query),
    );
    result.fold(
      onSuccess: (data) {
        skills.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    skills.clear();
    userSkills.clear();
    isLoading.value = false;
    errorMessage.value = null;
    
    super.onClose();
  }
}
