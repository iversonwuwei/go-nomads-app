import '../../../../core/domain/result.dart';
import '../entities/weather.dart';

/// Weather Repository 接口 (Domain Layer)
///
/// 定义天气数据访问的抽象接口
abstract class IWeatherRepository {
  /// 获取城市天气数据
  ///
  /// [cityId] 城市ID
  /// [includeForecast] 是否包含天气预报
  /// [days] 预报天数
  Future<Result<Weather>> getCityWeather(
    String cityId, {
    bool includeForecast = true,
    int days = 7,
  });
}
