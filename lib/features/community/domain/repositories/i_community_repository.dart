import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/community/domain/entities/trip_report.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';

/// Community Repository Interface - 社区功能仓储接口
abstract class ICommunityRepository {
  /// 获取 Community 首页 meetup preview
  /// [city] 可选城市过滤
  Future<Result<List<Meetup>>> getMeetups({String? city});

  /// 获取旅行报告列表
  /// [city] 可选城市过滤
  Future<Result<List<TripReport>>> getTripReports({String? city});

  /// 获取城市推荐列表
  /// [city] 可选城市过滤
  /// [category] 可选类别过滤: Restaurant, Cafe, Coworking, Activity
  Future<Result<List<CityRecommendation>>> getRecommendations({
    String? city,
    String? category,
  });

  /// 获取问题列表
  /// [city] 可选城市过滤
  Future<Result<List<Question>>> getQuestions({String? city});

  /// 获取问题的答案列表
  /// [questionId] 问题ID
  Future<Result<List<Answer>>> getAnswers(String questionId);

  Future<Result<Question>> createQuestion({
    required String city,
    required String title,
    required String content,
    List<String> tags = const [],
  });

  Future<Result<Answer>> createAnswer({
    required String questionId,
    required String content,
  });

  /// 切换旅行报告的点赞状态
  /// [reportId] 报告ID
  /// 返回更新后的报告
  Future<Result<TripReport>> toggleLikeTripReport(String reportId);

  /// 切换问题的点赞状态
  /// [questionId] 问题ID
  /// 返回更新后的问题
  Future<Result<Question>> toggleUpvoteQuestion(String questionId);

  /// 切换答案的点赞状态
  /// [answerId] 答案ID
  /// 返回更新后的答案
  Future<Result<Answer>> toggleUpvoteAnswer(String answerId);
}
