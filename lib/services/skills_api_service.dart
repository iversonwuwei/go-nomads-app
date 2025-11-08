import '../features/skill/infrastructure/models/skill_dto.dart';
import 'http_service.dart';

/// 技能 API 服务
class SkillsApiService {
  final HttpService _httpService = HttpService();

  /// 获取所有技能
  Future<List<SkillDto>> getAllSkills() async {
    try {
      final response = await _httpService.get('/skills');

      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data
            .map((json) => SkillDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to get skills');
    } catch (e) {
      print('❌ Error getting skills: $e');
      rethrow;
    }
  }

  /// 获取按类别分组的技能
  Future<List<SkillsByCategoryDto>> getSkillsByCategory() async {
    try {
      final response = await _httpService.get('/skills/by-category');

      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data
            .map((json) =>
                SkillsByCategoryDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to get skills by category');
    } catch (e, stackTrace) {
      print('❌ Error getting skills by category: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 根据类别获取技能
  Future<List<SkillDto>> getSkillsBySpecificCategory(String category) async {
    try {
      final response = await _httpService.get('/skills/category/$category');

      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data
            .map((json) => SkillDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to get skills for category');
    } catch (e) {
      print('❌ Error getting skills for category $category: $e');
      rethrow;
    }
  }

  /// 获取单个技能详情
  Future<SkillDto> getSkill(String id) async {
    try {
      final response = await _httpService.get('/skills/$id');

      // HttpService 已经解包了 ApiResponse，response.data 直接是数据对象
      if (response.statusCode == 200 && response.data != null) {
        return SkillDto.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to get skill');
    } catch (e) {
      print('❌ Error getting skill $id: $e');
      rethrow;
    }
  }

  /// 获取当前用户的技能
  Future<List<UserSkillDto>> getCurrentUserSkills() async {
    try {
      final response = await _httpService.get('/skills/me');

      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data
            .map((json) => UserSkillDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to get user skills');
    } catch (e) {
      print('❌ Error getting user skills: $e');
      rethrow;
    }
  }

  /// 批量添加用户技能
  Future<List<UserSkillDto>> addUserSkillsBatch(
      List<AddUserSkillRequestDto> requests) async {
    try {
      final response = await _httpService.post(
        '/skills/me/batch',
        data: requests.map((r) => r.toJson()).toList(),
      );

      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> resultData = response.data as List;
        return resultData
            .map((json) => UserSkillDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to add user skills');
    } catch (e) {
      print('❌ Error adding user skills: $e');
      rethrow;
    }
  }

  /// 删除用户技能
  Future<void> deleteUserSkill(String skillId) async {
    try {
      final response = await _httpService.delete('/skills/me/$skillId');

      if (response.statusCode == 200) {
        return;
      }

      throw Exception('Failed to delete user skill');
    } catch (e) {
      print('❌ Error deleting user skill $skillId: $e');
      rethrow;
    }
  }

  /// 更新用户技能
  Future<UserSkill> updateUserSkill(
    String skillId,
    String? proficiencyLevel,
    int? yearsOfExperience,
  ) async {
    try {
      final response = await _httpService.put(
        '/skills/me/$skillId',
        data: {
          'proficiencyLevel': proficiencyLevel,
          'yearsOfExperience': yearsOfExperience,
        },
      );

      // HttpService 已经解包了 ApiResponse，response.data 直接是数据对象
      if (response.statusCode == 200 && response.data != null) {
        return UserSkill.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to update user skill');
    } catch (e) {
      print('❌ Error updating user skill $skillId: $e');
      rethrow;
    }
  }
}
