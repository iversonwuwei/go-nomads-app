import '../../../../core/domain/result.dart';
import '../../domain/repositories/i_city_repository.dart';

/// 收藏/取消收藏城市用例
class ToggleCityFavoriteUseCase {
  final ICityRepository _repository;

  ToggleCityFavoriteUseCase(this._repository);

  Future<ToggleCityFavoriteResult> execute(String cityId) async {
    try {
      // 检查当前收藏状态
      final isFavoritedResult = await _repository.isCityFavorited(cityId);

      // 处理 Result
      if (isFavoritedResult is Failure<bool>) {
        return ToggleCityFavoriteResult.failure(
          '检查收藏状态失败: ${isFavoritedResult.exception.message}',
        );
      }

      final isFavorited = (isFavoritedResult as Success<bool>).data;

      if (isFavorited) {
        // 取消收藏
        final result = await _repository.unfavoriteCity(cityId);
        return switch (result) {
          Success() => ToggleCityFavoriteResult.success(
              isFavorited: false,
              message: '已取消收藏',
            ),
          Failure(:final exception) => ToggleCityFavoriteResult.failure(
              '取消收藏失败: ${exception.message}',
            ),
        };
      } else {
        // 添加收藏
        final result = await _repository.favoriteCity(cityId);
        return switch (result) {
          Success() => ToggleCityFavoriteResult.success(
              isFavorited: true,
              message: '收藏成功',
            ),
          Failure(:final exception) => ToggleCityFavoriteResult.failure(
              '收藏失败: ${exception.message}',
            ),
        };
      }
    } catch (e) {
      return ToggleCityFavoriteResult.failure('操作失败: ${e.toString()}');
    }
  }
}

class ToggleCityFavoriteResult {
  final bool isSuccess;
  final bool isFavorited;
  final String message;

  ToggleCityFavoriteResult._({
    required this.isSuccess,
    required this.isFavorited,
    required this.message,
  });

  factory ToggleCityFavoriteResult.success({
    required bool isFavorited,
    required String message,
  }) {
    return ToggleCityFavoriteResult._(
      isSuccess: true,
      isFavorited: isFavorited,
      message: message,
    );
  }

  factory ToggleCityFavoriteResult.failure(String message) {
    return ToggleCityFavoriteResult._(
      isSuccess: false,
      isFavorited: false,
      message: message,
    );
  }
}
