import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/community/domain/entities/trip_report.dart';
import 'package:go_nomads_app/features/community/infrastructure/models/community_dto.dart';
import 'package:go_nomads_app/features/community/domain/repositories/i_community_repository.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/models/meetup_dto.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// Community Repository Implementation - 社区功能仓储实现
class CommunityRepository implements ICommunityRepository {
  final HttpService _httpService = HttpService();
  Future<void>? _snapshotLoadFuture;

  List<Meetup>? _cachedMeetups;
  List<TripReport>? _cachedTripReports;
  List<CityRecommendation>? _cachedRecommendations;
  List<Question>? _cachedQuestions;
  final Map<String, List<Answer>> _cachedAnswers = {};

  // Liked/Upvoted tracking
  final Set<String> _likedReports = {};

  @override
  Future<Result<List<Meetup>>> getMeetups({String? city}) async {
    try {
      await _refreshSnapshot();

      if (city != null && city != 'All Cities') {
        final filtered = _cachedMeetups!
            .where((meetup) => meetup.location.city == city || meetup.location.cityName == city)
            .toList();
        return Result.success(filtered);
      }

      return Result.success(_cachedMeetups!);
    } catch (e) {
      return Result.failure(NetworkException('获取活动失败: $e'));
    }
  }

  @override
  Future<Result<List<TripReport>>> getTripReports({String? city}) async {
    try {
      await _refreshSnapshot();

      if (city != null && city != 'All Cities') {
        final filtered =
            _cachedTripReports!.where((report) => report.city == city).toList();
        return Result.success(filtered);
      }

      return Result.success(_cachedTripReports!);
    } catch (e) {
      return Result.failure(NetworkException('获取旅行报告失败: $e'));
    }
  }

  Future<void> _refreshSnapshot() {
    if (_snapshotLoadFuture != null) {
      return _snapshotLoadFuture!;
    }

    final future = _loadSnapshot();
    _snapshotLoadFuture = future;
    return future.whenComplete(() => _snapshotLoadFuture = null);
  }

  Future<void> _loadSnapshot() async {
    final response = await _httpService.get(ApiConfig.communitySnapshotCurrentEndpoint);
    final payload = response.data;

    if (payload is! Map) {
      _cachedMeetups = <Meetup>[];
      _cachedTripReports = <TripReport>[];
      _cachedRecommendations = <CityRecommendation>[];
      _cachedQuestions = <Question>[];
      _cachedAnswers.clear();
      return;
    }

    final data = Map<String, dynamic>.from(payload);
    _cachedMeetups = _parseMeetups(data['upcomingMeetups']);
    _cachedTripReports = _parseTripReports(data['fieldNotes']);
    _cachedRecommendations = _parseRecommendations(data['recommendations']);
    _cachedAnswers.clear();
    _cachedQuestions = _parseQuestions(data['questions']);
  }

  List<Meetup> _parseMeetups(dynamic rawMeetups) {
    if (rawMeetups is! List) {
      return const <Meetup>[];
    }

    return rawMeetups
        .whereType<Map>()
        .map((item) => MeetupDto.fromJson(Map<String, dynamic>.from(item)).toDomain())
        .toList(growable: false);
  }

  List<TripReport> _parseTripReports(dynamic rawFieldNotes) {
    if (rawFieldNotes is! List) {
      return const <TripReport>[];
    }

    return rawFieldNotes
        .whereType<Map>()
        .map((item) => TripReportDto.fromJson(Map<String, dynamic>.from(item)).toDomain())
        .toList(growable: false);
  }

  List<CityRecommendation> _parseRecommendations(dynamic rawRecommendations) {
    if (rawRecommendations is! List) {
      return const <CityRecommendation>[];
    }

    return rawRecommendations
        .whereType<Map>()
        .map((item) => CityRecommendationDto.fromJson(Map<String, dynamic>.from(item)).toDomain())
        .toList(growable: false);
  }

  List<Question> _parseQuestions(dynamic rawQuestions) {
    if (rawQuestions is! List) {
      return const <Question>[];
    }

    return rawQuestions.whereType<Map>().map((item) {
      final json = Map<String, dynamic>.from(item);
      final questionId = json['id']?.toString() ?? '';
      final rawAnswers = json.remove('answers');

      if (questionId.isNotEmpty) {
        _cachedAnswers[questionId] = _parseAnswers(questionId, rawAnswers);
      }

      return QuestionDto.fromJson(json).toDomain();
    }).toList(growable: false);
  }

  List<Answer> _parseAnswers(String questionId, dynamic rawAnswers) {
    if (rawAnswers is! List) {
      return const <Answer>[];
    }

    return rawAnswers
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          json['questionId'] ??= questionId;
          return AnswerDto.fromJson(json).toDomain();
        })
        .toList(growable: false);
  }

  @override
  Future<Result<List<CityRecommendation>>> getRecommendations({
    String? city,
    String? category,
  }) async {
    try {
      await _refreshSnapshot();

      var filtered = _cachedRecommendations!;

      if (city != null && city != 'All Cities') {
        filtered = filtered.where((rec) => rec.city == city).toList();
      }

      if (category != null && category != 'All') {
        filtered = filtered.where((rec) => rec.category == category).toList();
      }

      return Result.success(filtered);
    } catch (e) {
      return Result.failure(NetworkException('获取推荐失败: $e'));
    }
  }

  @override
  Future<Result<List<Question>>> getQuestions({String? city}) async {
    try {
      await _refreshSnapshot();

      if (city != null && city != 'All Cities') {
        final filtered =
            _cachedQuestions!.where((q) => q.city == city).toList();
        return Result.success(filtered);
      }

      return Result.success(_cachedQuestions!);
    } catch (e) {
      return Result.failure(NetworkException('获取问题失败: $e'));
    }
  }

  @override
  Future<Result<List<Answer>>> getAnswers(String questionId) async {
    try {
      if (!_cachedAnswers.containsKey(questionId)) {
        await _refreshSnapshot();
      }

      return Result.success(_cachedAnswers[questionId] ?? const <Answer>[]);
    } catch (e) {
      return Result.failure(NetworkException('获取答案失败: $e'));
    }
  }

  @override
  Future<Result<Question>> createQuestion({
    required String city,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.communityQuestionsEndpoint,
        data: {
          'city': city,
          'title': title,
          'content': content,
          'tags': tags,
        },
      );

      if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
        return Result.failure(const ServerException('发布问题失败'));
      }

      final question = QuestionDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      _cachedQuestions = [question, ...?_cachedQuestions];
      _cachedAnswers[question.id] = const <Answer>[];

      return Result.success(question);
    } catch (e) {
      return Result.failure(NetworkException('发布问题失败: $e'));
    }
  }

  @override
  Future<Result<Answer>> createAnswer({
    required String questionId,
    required String content,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.communityQuestionAnswersEndpoint(questionId),
        data: {
          'content': content,
        },
      );

      if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
        return Result.failure(const ServerException('发布回答失败'));
      }

      final answer = AnswerDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      final currentAnswers = [...?_cachedAnswers[questionId]];
      currentAnswers.add(answer);
      _cachedAnswers[questionId] = currentAnswers;

      final index = _cachedQuestions?.indexWhere((question) => question.id == questionId) ?? -1;
      if (index != -1) {
        final question = _cachedQuestions![index];
        _cachedQuestions![index] = Question(
          id: question.id,
          userId: question.userId,
          userName: question.userName,
          userAvatar: question.userAvatar,
          city: question.city,
          title: question.title,
          content: question.content,
          tags: question.tags,
          upvotes: question.upvotes,
          answerCount: question.answerCount + 1,
          hasAcceptedAnswer: question.hasAcceptedAnswer,
          createdAt: question.createdAt,
          isUpvoted: question.isUpvoted,
        );
      }

      return Result.success(answer);
    } catch (e) {
      return Result.failure(NetworkException('发布回答失败: $e'));
    }
  }

  @override
  Future<Result<TripReport>> toggleLikeTripReport(String reportId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      // Find the report
      final index =
          _cachedTripReports?.indexWhere((r) => r.id == reportId) ?? -1;
      if (index == -1) {
        return Result.failure(NotFoundException('报告不存在'));
      }

      final report = _cachedTripReports![index];

      // Toggle like state
      final wasLiked = _likedReports.contains(reportId);
      if (wasLiked) {
        _likedReports.remove(reportId);
      } else {
        _likedReports.add(reportId);
      }

      // Create updated report
      final updatedReport = TripReport(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        userAvatar: report.userAvatar,
        city: report.city,
        country: report.country,
        startDate: report.startDate,
        endDate: report.endDate,
        overallRating: report.overallRating,
        ratings: report.ratings,
        title: report.title,
        content: report.content,
        photos: report.photos,
        pros: report.pros,
        cons: report.cons,
        likes: wasLiked ? report.likes - 1 : report.likes + 1,
        comments: report.comments,
        createdAt: report.createdAt,
        isLiked: !wasLiked,
      );

      // Update cache
      _cachedTripReports![index] = updatedReport;

      return Result.success(updatedReport);
    } catch (e) {
      return Result.failure(NetworkException('切换点赞失败: $e'));
    }
  }

  @override
  Future<Result<Question>> toggleUpvoteQuestion(String questionId) async {
    try {
      final response = await _httpService.post(ApiConfig.communityQuestionUpvoteEndpoint(questionId));
      if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
        return Result.failure(const ServerException('切换点赞失败'));
      }

      final updatedQuestion = QuestionDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      final index = _cachedQuestions?.indexWhere((q) => q.id == questionId) ?? -1;
      if (index == -1) {
        return Result.failure(NotFoundException('问题不存在'));
      }
      _cachedQuestions![index] = updatedQuestion;

      return Result.success(updatedQuestion);
    } catch (e) {
      return Result.failure(NetworkException('切换点赞失败: $e'));
    }
  }

  @override
  Future<Result<Answer>> toggleUpvoteAnswer(String answerId) async {
    try {
      final response = await _httpService.post(ApiConfig.communityAnswerUpvoteEndpoint(answerId));
      if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
        return Result.failure(const ServerException('切换点赞失败'));
      }

      final updatedAnswer = AnswerDto.fromJson(response.data as Map<String, dynamic>).toDomain();
      Answer? targetAnswer;
      String? questionId;

      for (final entry in _cachedAnswers.entries) {
        final index = entry.value.indexWhere((a) => a.id == answerId);
        if (index != -1) {
          targetAnswer = entry.value[index];
          questionId = entry.key;
          break;
        }
      }

      if (targetAnswer == null || questionId == null) {
        return Result.failure(NotFoundException('答案不存在'));
      }

      final answers = _cachedAnswers[questionId]!;
      final index = answers.indexWhere((a) => a.id == answerId);
      answers[index] = updatedAnswer;

      return Result.success(updatedAnswer);
    } catch (e) {
      return Result.failure(NetworkException('切换点赞失败: $e'));
    }
  }

}
