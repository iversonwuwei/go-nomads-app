import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/features/user/domain/repositories/iuser_repository.dart';

/// 添加收藏城市用例
class AddFavoriteCityUseCase extends UseCase<bool, AddFavoriteCityParams> {
  final IUserRepository _repository;

  AddFavoriteCityUseCase(this._repository);

  @override
  Future<Result<bool>> execute(AddFavoriteCityParams params) async {
    return await _repository.addFavoriteCity(params.cityId);
  }
}

class AddFavoriteCityParams {
  final String cityId;

  AddFavoriteCityParams(this.cityId);
}

/// 移除收藏城市用例
class RemoveFavoriteCityUseCase
    extends UseCase<bool, RemoveFavoriteCityParams> {
  final IUserRepository _repository;

  RemoveFavoriteCityUseCase(this._repository);

  @override
  Future<Result<bool>> execute(RemoveFavoriteCityParams params) async {
    return await _repository.removeFavoriteCity(params.cityId);
  }
}

class RemoveFavoriteCityParams {
  final String cityId;

  RemoveFavoriteCityParams(this.cityId);
}

/// 检查城市是否已收藏用例
class IsCityFavoritedUseCase extends UseCase<bool, IsCityFavoritedParams> {
  final IUserRepository _repository;

  IsCityFavoritedUseCase(this._repository);

  @override
  Future<Result<bool>> execute(IsCityFavoritedParams params) async {
    return await _repository.isCityFavorited(params.cityId);
  }
}

class IsCityFavoritedParams {
  final String cityId;

  IsCityFavoritedParams(this.cityId);
}

/// 获取用户收藏的城市ID列表用例
class GetFavoriteCityIdsUseCase extends UseCase<List<String>, NoParams> {
  final IUserRepository _repository;

  GetFavoriteCityIdsUseCase(this._repository);

  @override
  Future<Result<List<String>>> execute(NoParams params) async {
    return await _repository.getUserFavoriteCityIds();
  }
}

/// 切换收藏状态用例
class ToggleFavoriteCityUseCase
    extends UseCase<bool, ToggleFavoriteCityParams> {
  final IUserRepository _repository;

  ToggleFavoriteCityUseCase(this._repository);

  @override
  Future<Result<bool>> execute(ToggleFavoriteCityParams params) async {
    return await _repository.toggleFavoriteCity(params.cityId);
  }
}

class ToggleFavoriteCityParams {
  final String cityId;

  ToggleFavoriteCityParams(this.cityId);
}
