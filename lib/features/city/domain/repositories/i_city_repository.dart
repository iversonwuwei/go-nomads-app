import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_detail.dart';

/// 城市仓储接口 (Domain Layer)
/// 定义城市数据访问的抽象契约,不依赖具体实现
abstract class ICityRepository implements IRepository {
  /// 获取城市列表
  Future<Result<List<City>>> getCities({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? countryId,
  });

  /// 根据ID获取城市详情
  Future<Result<City>> getCityById(String cityId);

  /// 搜索城市
  Future<Result<List<City>>> searchCities({
    required String name,
    int pageNumber = 1,
    int pageSize = 20,
  });

  /// 获取热门城市
  Future<Result<List<City>>> getPopularCities({int limit = 10});

  /// 获取推荐城市
  Future<Result<List<City>>> getRecommendedCities({
    String? countryId,
    int limit = 10,
  });

  /// 收藏城市
  Future<Result<void>> favoriteCity(String cityId);

  /// 取消收藏城市
  Future<Result<void>> unfavoriteCity(String cityId);

  /// 检查城市是否被收藏
  Future<Result<bool>> isCityFavorited(String cityId);

  /// 获取用户收藏的城市列表
  Future<Result<List<City>>> getFavoriteCities();

  /// 获取用户收藏的城市ID列表
  Future<Result<List<String>>> getUserFavoriteCityIds();

  /// 获取城市优缺点列表
  ///
  /// [cityId] 城市ID
  /// [isPro] 可选筛选: true = 只返回优点, false = 只返回缺点, null = 返回全部
  Future<Result<List<ProsCons>>> getCityProsCons({
    required String cityId,
    bool? isPro,
  });

  /// 添加城市优缺点
  ///
  /// [cityId] 城市ID
  /// [text] 内容文本
  /// [isPro] true = 优点, false = 缺点
  Future<Result<ProsCons>> addProsCons({
    required String cityId,
    required String text,
    required bool isPro,
  });

  /// 为优缺点投票
  ///
  /// [id] ProsCons ID
  /// [isUpvote] true = 点赞, false = 点踩
  Future<Result<void>> voteProsCons({
    required String id,
    required bool isUpvote,
  });

  /// 删除优缺点（逻辑删除）
  ///
  /// [cityId] 城市ID
  /// [id] ProsCons ID
  /// 返回 void 表示删除成功
  Future<Result<void>> deleteProsCons(String cityId, String id);

  /// 获取所有国家列表
  Future<Result<List<Map<String, dynamic>>>> getCountries();

  /// 获取按国家分组的城市
  Future<Result<Map<String, dynamic>>> getCitiesGroupedByCountry();

  /// 获取城市列表（含 Coworking 数量）
  Future<Result<Map<String, dynamic>>> getCitiesWithCoworkingCount({
    int page = 1,
    int pageSize = 100,
  });

  /// 获取城市天气信息
  ///
  /// [cityId] 城市ID
  /// [includeForecast] 是否包含预报
  /// [days] 预报天数
  Future<Result<Map<String, dynamic>?>> getCityWeather(
    String cityId, {
    bool includeForecast = true,
    int days = 7,
  });

  /// 申请成为城市版主
  ///
  /// [cityId] 城市ID
  /// 返回 true 表示申请成功
  Future<Result<bool>> applyModerator(String cityId);

  /// 指定用户为城市版主（仅管理员）
  ///
  /// [cityId] 城市ID
  /// [userId] 用户ID
  /// 返回 true 表示指定成功
  Future<Result<bool>> assignModerator(String cityId, String userId);
}
