import 'package:df_admin_mobile/core/domain/result.dart';

import '../../domain/entities/interest.dart';
import '../../domain/repositories/i_interest_repository.dart';

/// GetInterestsUseCase - 获取兴趣列表用例
class GetInterestsUseCase {
  final IInterestRepository _repository;

  GetInterestsUseCase(this._repository);

  Future<Result<List<Interest>>> call() async {
    return await _repository.getInterests();
  }
}

/// GetInterestsByCategoryUseCase - 按类别获取兴趣用例
class GetInterestsByCategoryUseCase {
  final IInterestRepository _repository;

  GetInterestsByCategoryUseCase(this._repository);

  Future<Result<List<Interest>>> call(
      GetInterestsByCategoryParams params) async {
    return await _repository.getInterestsByCategory(params.category);
  }
}

class GetInterestsByCategoryParams {
  final String category;

  GetInterestsByCategoryParams({required this.category});
}

/// GetUserInterestsUseCase - 获取用户兴趣列表用例
class GetUserInterestsUseCase {
  final IInterestRepository _repository;

  GetUserInterestsUseCase(this._repository);

  Future<Result<List<UserInterest>>> call(GetUserInterestsParams params) async {
    return await _repository.getUserInterests(params.userId);
  }
}

class GetUserInterestsParams {
  final String userId;

  GetUserInterestsParams({required this.userId});
}

/// AddUserInterestUseCase - 添加用户兴趣用例
class AddUserInterestUseCase {
  final IInterestRepository _repository;

  AddUserInterestUseCase(this._repository);

  Future<Result<UserInterest>> call(AddUserInterestParams params) async {
    return await _repository.addUserInterest(
      params.userId,
      params.request,
    );
  }
}

class AddUserInterestParams {
  final String userId;
  final AddUserInterestRequest request;

  AddUserInterestParams({
    required this.userId,
    required this.request,
  });
}

/// UpdateUserInterestIntensityUseCase - 更新用户兴趣强度用例
class UpdateUserInterestIntensityUseCase {
  final IInterestRepository _repository;

  UpdateUserInterestIntensityUseCase(this._repository);

  Future<Result<UserInterest>> call(
      UpdateUserInterestIntensityParams params) async {
    return await _repository.updateUserInterestIntensity(
      params.userId,
      params.interestId,
      params.intensityLevel,
    );
  }
}

class UpdateUserInterestIntensityParams {
  final String userId;
  final String interestId;
  final String intensityLevel;

  UpdateUserInterestIntensityParams({
    required this.userId,
    required this.interestId,
    required this.intensityLevel,
  });
}

/// RemoveUserInterestUseCase - 删除用户兴趣用例
class RemoveUserInterestUseCase {
  final IInterestRepository _repository;

  RemoveUserInterestUseCase(this._repository);

  Future<Result<void>> call(RemoveUserInterestParams params) async {
    return await _repository.removeUserInterest(
      params.userId,
      params.interestId,
    );
  }
}

class RemoveUserInterestParams {
  final String userId;
  final String interestId;

  RemoveUserInterestParams({
    required this.userId,
    required this.interestId,
  });
}

/// SearchInterestsUseCase - 搜索兴趣用例
class SearchInterestsUseCase {
  final IInterestRepository _repository;

  SearchInterestsUseCase(this._repository);

  Future<Result<List<Interest>>> call(SearchInterestsParams params) async {
    return await _repository.searchInterests(params.query);
  }
}

class SearchInterestsParams {
  final String query;

  SearchInterestsParams({required this.query});
}
