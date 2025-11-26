/// DDD基础 - 统一结果类型
///
/// 用于封装所有领域操作的返回结果,包括成功和失败情况
sealed class Result<T> {
  const Result();

  /// 创建成功结果
  static Success<T> success<T>(T data) => Success(data);

  /// 创建失败结果
  static Failure<T> failure<T>(DomainException exception) => Failure(exception);
}

/// 成功结果
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// 失败结果
class Failure<T> extends Result<T> {
  final DomainException exception;

  const Failure(this.exception);

  @override
  String toString() => 'Failure(exception: $exception)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          exception == other.exception;

  @override
  int get hashCode => exception.hashCode;
}

/// Result扩展方法
extension ResultExtensions<T> on Result<T> {
  /// 是否成功
  bool get isSuccess => this is Success<T>;

  /// 是否失败
  bool get isFailure => this is Failure<T>;

  /// 获取数据(如果成功)
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// 获取异常(如果失败)
  DomainException? get exceptionOrNull =>
      isFailure ? (this as Failure<T>).exception : null;

  /// 获取数据或默认值
  T getOrElse(T defaultValue) => dataOrNull ?? defaultValue;

  /// 获取数据或抛出异常
  T getOrThrow() {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else {
      throw (this as Failure<T>).exception;
    }
  }

  /// Map操作
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final exception) => Failure(exception),
    };
  }

  /// FlatMap操作
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(:final data) => transform(data),
      Failure(:final exception) => Failure(exception),
    };
  }

  /// Fold操作
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(DomainException exception) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final exception) => onFailure(exception),
    };
  }

  /// 执行副作用
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  Result<T> onFailure(void Function(DomainException exception) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).exception);
    }
    return this;
  }
}

/// 领域异常基类
abstract class DomainException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const DomainException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'DomainException(code: $code, message: $message, details: $details)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// 验证异常
class ValidationException extends DomainException {
  const ValidationException(super.message, {super.code, super.details});
}

/// 未找到异常
class NotFoundException extends DomainException {
  const NotFoundException(super.message, {super.code, super.details});
}

/// 未授权异常
class UnauthorizedException extends DomainException {
  const UnauthorizedException(super.message, {super.code, super.details});
}

/// 网络异常
class NetworkException extends DomainException {
  const NetworkException(super.message, {super.code, super.details});
}

/// 服务器异常
class ServerException extends DomainException {
  const ServerException(super.message, {super.code, super.details});
}

/// 业务逻辑异常
class BusinessLogicException extends DomainException {
  const BusinessLogicException(super.message, {super.code, super.details});
}

/// 未知异常
class UnknownException extends DomainException {
  const UnknownException(super.message, {super.code, super.details});
}
