import '../../../../core/core.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/iuser_repository.dart';

/// 批量获取用户信息用例
class BatchGetUsersUseCase extends UseCase<List<User>, BatchGetUsersParams> {
  final IUserRepository _repository;

  BatchGetUsersUseCase(this._repository);

  @override
  Future<Result<List<User>>> execute(BatchGetUsersParams params) async {
    // 验证参数
    if (params.userIds.isEmpty) {
      return const Success([]);
    }

    // 执行仓储操作
    return await _repository.batchGetUsers(params.userIds);
  }
}

/// 批量获取用户参数
class BatchGetUsersParams extends UseCaseParams {
  final List<String> userIds;

  const BatchGetUsersParams({required this.userIds});
}

/// 获取单个用户用例
class GetUserUseCase extends UseCase<User, GetUserParams> {
  final IUserRepository _repository;

  GetUserUseCase(this._repository);

  @override
  Future<Result<User>> execute(GetUserParams params) async {
    // 验证参数
    if (params.userId.isEmpty) {
      return Failure(ValidationException('用户ID不能为空', code: 'EMPTY_USER_ID'));
    }

    return await _repository.getUser(params.userId);
  }
}

/// 获取用户参数
class GetUserParams extends UseCaseParams {
  final String userId;

  const GetUserParams({required this.userId});
}

/// 获取当前用户信息用例（User 领域）
class GetUserProfileUseCase extends NoParamsUseCase<User> {
  final IUserRepository _repository;

  GetUserProfileUseCase(this._repository);

  @override
  Future<Result<User>> execute(NoParams params) async {
    return await _repository.getCurrentUser();
  }
}

/// 更新用户信息用例
class UpdateUserUseCase extends UseCase<User, UpdateUserParams> {
  final IUserRepository _repository;

  UpdateUserUseCase(this._repository);

  @override
  Future<Result<User>> execute(UpdateUserParams params) async {
    // 验证参数
    if (params.userId.isEmpty) {
      return Failure(ValidationException('用户ID不能为空', code: 'EMPTY_USER_ID'));
    }

    if (params.updates.isEmpty) {
      return Failure(ValidationException('更新内容不能为空', code: 'EMPTY_UPDATES'));
    }

    return await _repository.updateUser(params.userId, params.updates);
  }
}

/// 更新用户参数
class UpdateUserParams extends UseCaseParams {
  final String userId;
  final Map<String, dynamic> updates;

  const UpdateUserParams({
    required this.userId,
    required this.updates,
  });
}

/// 搜索用户用例
class SearchUsersUseCase extends UseCase<List<User>, SearchUsersParams> {
  final IUserRepository _repository;

  SearchUsersUseCase(this._repository);

  @override
  Future<Result<List<User>>> execute(SearchUsersParams params) async {
    // 验证参数
    if (params.query.trim().isEmpty) {
      return Failure(ValidationException('搜索关键词不能为空', code: 'EMPTY_QUERY'));
    }

    if (params.query.length < 2) {
      return Failure(ValidationException(
        '搜索关键词至少需要2个字符',
        code: 'QUERY_TOO_SHORT',
      ));
    }

    return await _repository.searchUsers(
      query: params.query,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// 搜索用户参数
class SearchUsersParams extends UseCaseParams {
  final String query;
  final int page;
  final int pageSize;

  const SearchUsersParams({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
  });
}
