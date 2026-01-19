import 'package:go_nomads_app/core/domain/result.dart';

/// UseCase基类
///
/// 所有应用用例的抽象基类
/// R: 返回类型
/// P: 参数类型
abstract class UseCase<R, P> {
  /// 执行用例
  Future<Result<R>> execute(P params);

  /// 便捷调用方法
  Future<Result<R>> call(P params) => execute(params);
}

/// 无参数UseCase
abstract class NoParamsUseCase<R> extends UseCase<R, NoParams> {
  @override
  Future<Result<R>> call(NoParams params) => execute(params);
}

/// 无参数标记类
class NoParams {
  const NoParams();
}

/// UseCase参数基类
abstract class UseCaseParams {
  const UseCaseParams();
}
