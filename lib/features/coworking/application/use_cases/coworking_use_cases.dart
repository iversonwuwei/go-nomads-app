import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_repository.dart';

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

/// 获取 Coworking 空间列表（分页）Use Case
class GetCoworkingSpacesUseCase
    extends UseCase<List<CoworkingSpace>, GetCoworkingSpacesParams> {
  final ICoworkingRepository _repository;

  GetCoworkingSpacesUseCase(this._repository);

  @override
  Future<Result<List<CoworkingSpace>>> execute(
    GetCoworkingSpacesParams params,
  ) async {
    return await _repository.getCoworkingSpaces(
      page: params.page,
      pageSize: params.pageSize,
      cityId: params.cityId,
    );
  }
}

/// 获取 Coworking 空间列表参数
class GetCoworkingSpacesParams extends UseCaseParams {
  final int page;
  final int pageSize;
  final String? cityId;

  const GetCoworkingSpacesParams({
    this.page = 1,
    this.pageSize = 20,
    this.cityId,
  });
}

/// 创建 Coworking 空间 Use Case
class CreateCoworkingUseCase
    extends UseCase<CoworkingSpace, CreateCoworkingParams> {
  final ICoworkingRepository _repository;

  CreateCoworkingUseCase(this._repository);

  @override
  Future<Result<CoworkingSpace>> execute(CreateCoworkingParams params) async {
    // 基本验证
    if (params.space.name.isEmpty) {
      return Result.failure(
        ValidationException('空间名称不能为空', code: 'INVALID_NAME'),
      );
    }

    if (params.space.location.address.isEmpty) {
      return Result.failure(
        ValidationException('地址不能为空', code: 'INVALID_ADDRESS'),
      );
    }

    if (params.space.location.city.isEmpty) {
      return Result.failure(
        ValidationException('城市不能为空', code: 'INVALID_CITY'),
      );
    }

    return await _repository.createCoworkingSpace(params.space);
  }
}

/// 创建 Coworking 空间参数
class CreateCoworkingParams extends UseCaseParams {
  final CoworkingSpace space;

  const CreateCoworkingParams({required this.space});
}

/// 更新 Coworking 空间 Use Case
class UpdateCoworkingUseCase
    extends UseCase<CoworkingSpace, UpdateCoworkingParams> {
  final ICoworkingRepository _repository;

  UpdateCoworkingUseCase(this._repository);

  @override
  Future<Result<CoworkingSpace>> execute(UpdateCoworkingParams params) async {
    // 基本验证
    if (params.id.isEmpty) {
      return Result.failure(
        ValidationException('Coworking 空间ID不能为空', code: 'INVALID_ID'),
      );
    }

    if (params.space.name.isEmpty) {
      return Result.failure(
        ValidationException('空间名称不能为空', code: 'INVALID_NAME'),
      );
    }

    return await _repository.updateCoworkingSpace(params.id, params.space);
  }
}

/// 更新 Coworking 空间参数
class UpdateCoworkingParams extends UseCaseParams {
  final String id;
  final CoworkingSpace space;

  const UpdateCoworkingParams({
    required this.id,
    required this.space,
  });
}

/// 删除 Coworking 空间 Use Case
class DeleteCoworkingUseCase extends UseCase<void, DeleteCoworkingParams> {
  final ICoworkingRepository _repository;

  DeleteCoworkingUseCase(this._repository);

  @override
  Future<Result<void>> execute(DeleteCoworkingParams params) async {
    if (params.id.isEmpty) {
      return Result.failure(
        ValidationException('Coworking 空间ID不能为空', code: 'INVALID_ID'),
      );
    }

    return await _repository.deleteCoworkingSpace(params.id);
  }
}

/// 删除 Coworking 空间参数
class DeleteCoworkingParams extends UseCaseParams {
  final String id;

  const DeleteCoworkingParams({required this.id});
}

/// 提交 Coworking 认证 Use Case
class SubmitCoworkingVerificationUseCase
    extends UseCase<CoworkingSpace, SubmitCoworkingVerificationParams> {
  final ICoworkingRepository _repository;

  SubmitCoworkingVerificationUseCase(this._repository);

  @override
  Future<Result<CoworkingSpace>> execute(
    SubmitCoworkingVerificationParams params,
  ) async {
    if (params.coworkingId.isEmpty) {
      return Result.failure(
        ValidationException('Coworking 空间ID不能为空', code: 'INVALID_ID'),
      );
    }

    return _repository.submitVerification(params.coworkingId);
  }
}

/// 提交 Coworking 认证参数
class SubmitCoworkingVerificationParams extends UseCaseParams {
  final String coworkingId;

  const SubmitCoworkingVerificationParams({required this.coworkingId});
}
