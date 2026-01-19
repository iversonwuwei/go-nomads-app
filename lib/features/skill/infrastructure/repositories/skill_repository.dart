import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/skill/domain/entities/skill.dart';
import 'package:go_nomads_app/features/skill/domain/repositories/i_skill_repository.dart';
import 'package:go_nomads_app/features/skill/infrastructure/models/skill_dto.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// Skill Repository Implementation - 技能仓储实现
class SkillRepository implements ISkillRepository {
  final HttpService _httpService;

  SkillRepository(this._httpService);

  @override
  Future<Result<List<Skill>>> getSkills() async {
    try {
      final response = await _httpService.get('/skills');
      final List<dynamic> data = response.data as List<dynamic>;
      final skills = data
          .map((json) =>
              SkillDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(skills);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取技能列表失败: $e'));
    }
  }

  @override
  Future<Result<Skill>> getSkillById(String id) async {
    try {
      final response = await _httpService.get('/skills/$id');
      final skill =
          SkillDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      return Success(skill);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取技能详情失败: $e'));
    }
  }

  @override
  Future<Result<List<Skill>>> getSkillsByCategory(String category) async {
    try {
      final response = await _httpService.get('/skills/category/$category');
      final List<dynamic> data = response.data as List<dynamic>;
      final skills = data
          .map((json) =>
              SkillDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(skills);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('按类别获取技能列表失败: $e'));
    }
  }

  @override
  Future<Result<List<UserSkill>>> getUserSkills(String userId) async {
    try {
      final response = await _httpService.get('/skills/users/$userId');
      final List<dynamic> data = response.data as List<dynamic>;
      final userSkills = data
          .map((json) =>
              UserSkillDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(userSkills);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取用户技能列表失败: $e'));
    }
  }

  @override
  Future<Result<UserSkill>> addUserSkill(
    String userId,
    AddUserSkillRequest request,
  ) async {
    try {
      final response = await _httpService.post(
        '/skills/users/$userId',
        data: {
          'skillId': request.skillId,
          'proficiencyLevel': request.proficiencyLevel,
          'yearsOfExperience': request.yearsOfExperience,
        },
      );
      final userSkill =
          UserSkillDto.fromJson(response.data as Map<String, dynamic>)
              .toDomain();
      return Success(userSkill);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('添加用户技能失败: $e'));
    }
  }

  @override
  Future<Result<UserSkill>> updateUserSkillProficiency(
    String userId,
    String skillId,
    String proficiencyLevel,
    int? yearsOfExperience,
  ) async {
    try {
      final response = await _httpService.put(
        '/skills/users/$userId/$skillId',
        data: {
          'proficiencyLevel': proficiencyLevel,
          'yearsOfExperience': yearsOfExperience,
        },
      );
      final userSkill =
          UserSkillDto.fromJson(response.data as Map<String, dynamic>)
              .toDomain();
      return Success(userSkill);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('更新用户技能熟练度失败: $e'));
    }
  }

  @override
  Future<Result<void>> removeUserSkill(
    String userId,
    String skillId,
  ) async {
    try {
      await _httpService.delete('/skills/users/$userId/$skillId');
      return const Success(null);
    } on HttpException catch (e) {
      // 404 表示技能不存在，对于删除操作来说这是可接受的结果
      if (e.statusCode == 404) {
        return const Success(null);
      }
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('删除用户技能失败: $e'));
    }
  }

  @override
  Future<Result<List<Skill>>> searchSkills(String query) async {
    try {
      final response = await _httpService
          .get('/skills/search', queryParameters: {'q': query});
      final List<dynamic> data = response.data as List<dynamic>;
      final skills = data
          .map((json) =>
              SkillDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(skills);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('搜索技能失败: $e'));
    }
  }

  /// Convert HTTP exception to domain exception
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
