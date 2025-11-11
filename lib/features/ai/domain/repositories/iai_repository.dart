import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart';

/// AI服务Repository接口
///
/// 职责:
/// - 生成AI旅行计划 (标准和流式)
/// - 生成数字游民指南 (标准和流式)
/// - 检索旅行计划
///
/// 特性:
/// - 支持SSE流式生成 (实时进度更新)
/// - 支持标准异步生成
/// - 旅行计划24小时缓存
abstract class IAiRepository {
  // ==================== 旅行计划 ====================

  /// 生成旅行计划 (标准方式)
  ///
  /// 参数:
  /// - [cityId]: 城市ID
  /// - [cityName]: 城市名称
  /// - [cityImage]: 城市图片URL
  /// - [duration]: 旅行天数 (1-30天)
  /// - [budget]: 预算级别 ('low', 'medium', 'high')
  /// - [travelStyle]: 旅行风格 ('adventure', 'relaxation', 'culture', 'nightlife')
  /// - [interests]: 兴趣列表
  /// - [departureLocation]: 出发地 (可选)
  /// - [customBudget]: 自定义预算金额 (可选)
  /// - [currency]: 货币单位 (可选)
  /// - [selectedAttractions]: 指定景点 (可选)
  ///
  /// 返回: Result<TravelPlan>
  ///
  /// 超时: 3分钟 (AI生成时间)
  Future<Result<TravelPlan>> generateTravelPlan({
    required String cityId,
    required String cityName,
    required String cityImage,
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
  });

  /// 生成旅行计划 (流式方式)
  ///
  /// 使用Server-Sent Events实时推送生成进度
  ///
  /// 参数: 与generateTravelPlan相同 +
  /// - [onProgress]: 进度回调 (消息, 进度百分比)
  /// - [onData]: 成功回调 (完整TravelPlan)
  /// - [onError]: 错误回调 (错误消息)
  ///
  /// 事件类型:
  /// - 'start': 开始生成
  /// - 'analyzing': 分析中
  /// - 'generating': 生成中
  /// - 'success': 完成 (触发onData)
  /// - 'error': 失败 (触发onError)
  Future<Result<void>> generateTravelPlanStream({
    required String cityId,
    required String cityName,
    required String cityImage,
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
    required Function(String message, int progress) onProgress,
    required Function(TravelPlan plan) onData,
    required Function(String error) onError,
  });

  /// 根据ID获取旅行计划
  ///
  /// 参数:
  /// - [planId]: 计划ID
  ///
  /// 返回: Result<TravelPlan>
  ///
  /// 注意: 计划24小时后过期
  Future<Result<TravelPlan>> getTravelPlanById(String planId);

  // ==================== 数字游民指南 ====================

  /// 生成数字游民指南 (标准方式)
  ///
  /// 参数:
  /// - [cityId]: 城市ID
  /// - [cityName]: 城市名称
  ///
  /// 返回: Result<DigitalNomadGuide>
  ///
  /// 超时: 3分钟 (AI生成时间)
  Future<Result<DigitalNomadGuide>> generateDigitalNomadGuide({
    required String cityId,
    required String cityName,
  });

  /// 生成数字游民指南 (流式方式)
  ///
  /// 使用Server-Sent Events实时推送生成进度
  ///
  /// 参数:
  /// - [cityId]: 城市ID
  /// - [cityName]: 城市名称
  /// - [onProgress]: 进度回调 (消息, 进度百分比)
  /// - [onData]: 成功回调 (完整DigitalNomadGuide)
  /// - [onError]: 错误回调 (错误消息)
  ///
  /// 事件类型:
  /// - 'start': 开始生成
  /// - 'progress': 生成进度
  /// - 'success': 完成 (触发onData)
  /// - 'error': 失败 (触发onError)
  Future<Result<void>> generateDigitalNomadGuideStream({
    required String cityId,
    required String cityName,
    required Function(String message, int progress) onProgress,
    required Function(DigitalNomadGuide guide) onData,
    required Function(String error) onError,
  });
}
