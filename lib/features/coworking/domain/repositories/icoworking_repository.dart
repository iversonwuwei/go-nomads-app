import '../../../../core/domain/result.dart';
import '../entities/coworking_space.dart';

/// Coworking Repository 接口
/// 定义 Coworking 数据访问契约
abstract class ICoworkingRepository {
  /// 获取城市的 Coworking 空间列表
  Future<Result<List<CoworkingSpace>>> getCoworkingSpacesByCity(
    String cityId, {
    int page = 1,
    int pageSize = 20,
  });

  /// 获取 Coworking 空间列表(分页)
  Future<Result<List<CoworkingSpace>>> getCoworkingSpaces({
    int page = 1,
    int pageSize = 20,
    String? cityId,
  });

  /// 获取单个 Coworking 空间详情
  Future<Result<CoworkingSpace>> getCoworkingById(String id);

  /// 获取城市的 Coworking 空间数量
  Future<Result<int>> getCityCoworkingCount(String cityId);

  /// 批量获取多个城市的 Coworking 空间数量
  Future<Result<Map<String, int>>> getCoworkingCountByCities(
    List<String> cityIds,
  );

  /// 创建新的 Coworking 空间
  Future<Result<CoworkingSpace>> createCoworkingSpace(CoworkingSpace space);

  /// 更新 Coworking 空间信息
  Future<Result<CoworkingSpace>> updateCoworkingSpace(
    String id,
    CoworkingSpace space,
  );

  /// 删除 Coworking 空间
  Future<Result<void>> deleteCoworkingSpace(String id);
}
