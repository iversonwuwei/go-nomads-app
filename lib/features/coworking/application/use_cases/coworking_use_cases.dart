import '../../../../core/application/use_case.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/coworking_space.dart';
import '../../domain/repositories/icoworking_repository.dart';

/// 获取城市 Coworking 空间列表 Use Case
class GetCoworkingSpacesByCityUseCase
    extends UseCase<List<CoworkingSpace>, GetCoworkingSpacesByCityParams> {
  final ICoworkingRepository _repository;

  GetCoworkingSpacesByCityUseCase(this._repository);

  @override
  Future<Result<List<CoworkingSpace>>> execute(
    GetCoworkingSpacesByCityParams params,
  ) async {
    return await _repository.getCoworkingSpacesByCity(
      params.cityId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// 获取城市 Coworking 空间列表参数
class GetCoworkingSpacesByCityParams extends UseCaseParams {
  final String cityId;
  final int page;
  final int pageSize;

  const GetCoworkingSpacesByCityParams({
    required this.cityId,
    this.page = 1,
    this.pageSize = 100,
  });
}

/// 获取 Coworking 空间详情 Use Case
class GetCoworkingByIdUseCase
    extends UseCase<CoworkingSpace, GetCoworkingByIdParams> {
  final ICoworkingRepository _repository;

  GetCoworkingByIdUseCase(this._repository);

  @override
  Future<Result<CoworkingSpace>> execute(GetCoworkingByIdParams params) async {
    return await _repository.getCoworkingById(params.id);
  }
}

/// 获取 Coworking 空间详情参数
class GetCoworkingByIdParams extends UseCaseParams {
  final String id;

  const GetCoworkingByIdParams({required this.id});
}

/// 获取城市 Coworking 数量 Use Case
class GetCityCoworkingCountUseCase
    extends UseCase<int, GetCityCoworkingCountParams> {
  final ICoworkingRepository _repository;

  GetCityCoworkingCountUseCase(this._repository);

  @override
  Future<Result<int>> execute(GetCityCoworkingCountParams params) async {
    return await _repository.getCityCoworkingCount(params.cityId);
  }
}

/// 获取城市 Coworking 数量参数
class GetCityCoworkingCountParams extends UseCaseParams {
  final String cityId;

  const GetCityCoworkingCountParams({required this.cityId});
}
