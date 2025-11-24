import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_detail.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';

// ============================================================================
// 获取城市列表 Use Case
// ============================================================================

/// 获取城市列表用例
class GetCitiesUseCase extends UseCase<List<City>, GetCitiesParams> {
  final ICityRepository _repository;

  GetCitiesUseCase(this._repository);

  @override
  Future<Result<List<City>>> execute(GetCitiesParams params) async {
    // 参数验证
    if (params.pageSize <= 0) {
      return Failure(
        ValidationException('页大小必须大于0', code: 'INVALID_PAGE_SIZE'),
      );
    }

    if (params.page < 1) {
      return Failure(
        ValidationException('页码必须大于等于1', code: 'INVALID_PAGE'),
      );
    }

    // 调用 Repository
    return await _repository.getCities(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      countryId: params.countryId,
    );
  }
}

/// 获取城市列表参数
class GetCitiesParams extends UseCaseParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? countryId;

  const GetCitiesParams({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.countryId,
  });
}

// ============================================================================
// 获取城市详情 Use Case
// ============================================================================

/// 获取城市详情用例
class GetCityByIdUseCase extends UseCase<City, GetCityByIdParams> {
  final ICityRepository _repository;

  GetCityByIdUseCase(this._repository);

  @override
  Future<Result<City>> execute(GetCityByIdParams params) async {
    // 参数验证
    if (params.cityId.isEmpty) {
      return Failure(
        ValidationException('城市ID不能为空', code: 'EMPTY_CITY_ID'),
      );
    }

    return await _repository.getCityById(params.cityId);
  }
}

/// 获取城市详情参数
class GetCityByIdParams extends UseCaseParams {
  final String cityId;

  const GetCityByIdParams({required this.cityId});
}

// ============================================================================
// 搜索城市 Use Case
// ============================================================================

/// 搜索城市用例（City 领域）
/// 搜索城市参数（City 领域）
class SearchCitiesParams extends UseCaseParams {
  final String keyword;
  final int pageSize;
  final int pageNumber;

  SearchCitiesParams({
    required this.keyword,
    this.pageSize = 20,
    this.pageNumber = 1,
  });
}

class SearchCityListUseCase extends UseCase<List<City>, SearchCitiesParams> {
  final ICityRepository _repository;

  SearchCityListUseCase(this._repository);

  @override
  Future<Result<List<City>>> execute(SearchCitiesParams params) async {
    return await _repository.searchCities(
      name: params.keyword,
      pageSize: params.pageSize,
      pageNumber: params.pageNumber,
    );
  }
}

// ============================================================================
// 获取推荐城市 Use Case
// ============================================================================

/// 获取推荐城市用例
class GetRecommendedCitiesUseCase
    extends UseCase<List<City>, GetRecommendedCitiesParams> {
  final ICityRepository _repository;

  GetRecommendedCitiesUseCase(this._repository);

  @override
  Future<Result<List<City>>> execute(GetRecommendedCitiesParams params) async {
    // 参数验证
    if (params.limit <= 0) {
      return Failure(
        ValidationException('限制数量必须大于0', code: 'INVALID_LIMIT'),
      );
    }

    return await _repository.getRecommendedCities(
      countryId: params.countryId,
      limit: params.limit,
    );
  }
}

/// 获取推荐城市参数
class GetRecommendedCitiesParams extends UseCaseParams {
  final String? countryId;
  final int limit;

  const GetRecommendedCitiesParams({
    this.countryId,
    this.limit = 10,
  });
}

// ============================================================================
// 获取热门城市 Use Case
// ============================================================================

/// 获取热门城市用例
class GetPopularCitiesUseCase
    extends UseCase<List<City>, GetPopularCitiesParams> {
  final ICityRepository _repository;

  GetPopularCitiesUseCase(this._repository);

  @override
  Future<Result<List<City>>> execute(GetPopularCitiesParams params) async {
    // 参数验证
    if (params.limit <= 0) {
      return Failure(
        ValidationException('限制数量必须大于0', code: 'INVALID_LIMIT'),
      );
    }

    return await _repository.getPopularCities(limit: params.limit);
  }
}

/// 获取热门城市参数
class GetPopularCitiesParams extends UseCaseParams {
  final int limit;

  const GetPopularCitiesParams({this.limit = 10});
}

// ============================================================================
// 收藏城市 Use Case
// ============================================================================

/// 收藏城市用例
class FavoriteCityUseCase extends UseCase<void, FavoriteCityParams> {
  final ICityRepository _repository;

  FavoriteCityUseCase(this._repository);

  @override
  Future<Result<void>> execute(FavoriteCityParams params) async {
    // 参数验证
    if (params.cityId.isEmpty) {
      return Failure(
        ValidationException('城市ID不能为空', code: 'EMPTY_CITY_ID'),
      );
    }

    return await _repository.favoriteCity(params.cityId);
  }
}

/// 收藏城市参数
class FavoriteCityParams extends UseCaseParams {
  final String cityId;

  const FavoriteCityParams({required this.cityId});
}

// ============================================================================
// 取消收藏城市 Use Case
// ============================================================================

/// 取消收藏城市用例
class UnfavoriteCityUseCase extends UseCase<void, UnfavoriteCityParams> {
  final ICityRepository _repository;

  UnfavoriteCityUseCase(this._repository);

  @override
  Future<Result<void>> execute(UnfavoriteCityParams params) async {
    // 参数验证
    if (params.cityId.isEmpty) {
      return Failure(
        ValidationException('城市ID不能为空', code: 'EMPTY_CITY_ID'),
      );
    }

    return await _repository.unfavoriteCity(params.cityId);
  }
}

/// 取消收藏城市参数
class UnfavoriteCityParams extends UseCaseParams {
  final String cityId;

  const UnfavoriteCityParams({required this.cityId});
}

// ============================================================================
// 切换收藏状态 Use Case
// ============================================================================

/// 切换城市收藏状态用例 (便捷方法)
class ToggleCityFavoriteUseCase
    extends UseCase<bool, ToggleCityFavoriteParams> {
  final ICityRepository _repository;

  ToggleCityFavoriteUseCase(this._repository);

  @override
  Future<Result<bool>> execute(ToggleCityFavoriteParams params) async {
    // 参数验证
    if (params.cityId.isEmpty) {
      return Failure(
        ValidationException('城市ID不能为空', code: 'EMPTY_CITY_ID'),
      );
    }

    // 检查当前收藏状态
    final isFavoritedResult = await _repository.isCityFavorited(params.cityId);

    // 如果检查失败,直接返回错误
    if (isFavoritedResult is Failure<bool>) {
      return Failure(isFavoritedResult.exception);
    }

    final isFavorited = (isFavoritedResult as Success<bool>).data;

    // 根据当前状态执行相应操作
    if (isFavorited) {
      // 取消收藏
      final unfavoriteResult = await _repository.unfavoriteCity(params.cityId);
      return switch (unfavoriteResult) {
        Success() => const Success(false),
        Failure(:final exception) => Failure(exception),
      };
    } else {
      // 添加收藏
      final favoriteResult = await _repository.favoriteCity(params.cityId);
      return switch (favoriteResult) {
        Success() => const Success(true),
        Failure(:final exception) => Failure(exception),
      };
    }
  }
}

/// 切换收藏状态参数
class ToggleCityFavoriteParams extends UseCaseParams {
  final String cityId;

  const ToggleCityFavoriteParams({required this.cityId});
}

// ============================================================================
// 获取收藏城市列表 Use Case
// ============================================================================

/// 获取收藏城市列表用例
class GetFavoriteCitiesUseCase extends NoParamsUseCase<List<City>> {
  final ICityRepository _repository;

  GetFavoriteCitiesUseCase(this._repository);

  @override
  Future<Result<List<City>>> execute(NoParams params) async {
    return await _repository.getFavoriteCities();
  }
}

// ============================================================================
// 获取收藏城市ID列表 Use Case
// ============================================================================

/// 获取收藏城市ID列表用例
class GetUserFavoriteCityIdsUseCase extends NoParamsUseCase<List<String>> {
  final ICityRepository _repository;

  GetUserFavoriteCityIdsUseCase(this._repository);

  @override
  Future<Result<List<String>>> execute(NoParams params) async {
    return await _repository.getUserFavoriteCityIds();
  }
}

// ============================================================================
// 获取城市优缺点 Use Case
// ============================================================================

/// 获取城市优缺点用例
class GetCityProsConsUseCase
    extends UseCase<List<ProsCons>, GetCityProsConsParams> {
  final ICityRepository _repository;

  GetCityProsConsUseCase(this._repository);

  @override
  Future<Result<List<ProsCons>>> execute(GetCityProsConsParams params) async {
    // 参数验证
    if (params.cityId.isEmpty) {
      return Failure(
        ValidationException('城市ID不能为空', code: 'INVALID_CITY_ID'),
      );
    }

    // 调用 Repository
    return await _repository.getCityProsCons(
      cityId: params.cityId,
      isPro: params.isPro,
    );
  }
}

/// 获取城市优缺点参数
class GetCityProsConsParams extends UseCaseParams {
  final String cityId;
  final bool? isPro;

  const GetCityProsConsParams({
    required this.cityId,
    this.isPro,
  });

  List<Object?> get props => [cityId, isPro];
}

// ============================================================================
// 获取城市列表（含 Coworking 数量）Use Case
// ============================================================================

/// 获取城市列表（含 Coworking 数量）用例
class GetCitiesWithCoworkingCountUseCase
    extends UseCase<Map<String, dynamic>, GetCitiesWithCoworkingCountParams> {
  final ICityRepository _repository;

  GetCitiesWithCoworkingCountUseCase(this._repository);

  @override
  Future<Result<Map<String, dynamic>>> execute(
    GetCitiesWithCoworkingCountParams params,
  ) async {
    // 参数验证
    if (params.pageSize <= 0) {
      return Failure(
        ValidationException('页大小必须大于0', code: 'INVALID_PAGE_SIZE'),
      );
    }

    if (params.page < 1) {
      return Failure(
        ValidationException('页码必须大于等于1', code: 'INVALID_PAGE'),
      );
    }

    // 调用 Repository
    return await _repository.getCitiesWithCoworkingCount(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// 获取城市列表（含 Coworking 数量）参数
class GetCitiesWithCoworkingCountParams extends UseCaseParams {
  final int page;
  final int pageSize;

  const GetCitiesWithCoworkingCountParams({
    this.page = 1,
    this.pageSize = 100,
  });
}
