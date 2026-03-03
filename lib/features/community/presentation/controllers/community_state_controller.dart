import 'dart:developer';

import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/community/domain/entities/trip_report.dart';
import 'package:go_nomads_app/features/community/domain/repositories/i_community_repository.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// Community State Controller - 社区功能状态控制器 (DDD 架构)
/// 管理旅行报告、城市推荐、问答功能
class CommunityStateController extends GetxController {
  // Dependencies
  final ICommunityRepository _repository;

  CommunityStateController({
    required ICommunityRepository repository,
  }) : _repository = repository;

  // ============= STATE =============

  /// 旅行报告列表
  final RxList<TripReport> tripReports = <TripReport>[].obs;

  /// 城市推荐列表
  final RxList<CityRecommendation> recommendations = <CityRecommendation>[].obs;

  /// 问题列表
  final RxList<Question> questions = <Question>[].obs;

  /// 答案映射 (questionId -> answers)
  final RxMap<String, List<Answer>> answers = <String, List<Answer>>{}.obs;

  /// 选中的推荐类别
  final RxString selectedCategory = 'All'.obs;

  /// 选中的城市
  final RxString selectedCity = 'All Cities'.obs;

  /// 加载状态
  final RxBool isLoading = true.obs;

  /// 推荐类别列表
  final List<String> categories = [
    'All',
    'Restaurant',
    'Cafe',
    'Coworking',
    'Activity',
  ];

  // ============= COMPUTED PROPERTIES =============

  /// 根据选中类别过滤的推荐列表
  List<CityRecommendation> get filteredRecommendations {
    if (selectedCategory.value == 'All') {
      return recommendations;
    }
    return recommendations
        .where((rec) => rec.category == selectedCategory.value)
        .toList();
  }

  /// 热门旅行报告
  List<TripReport> get popularTripReports {
    return tripReports.where((report) => report.isPopular).toList();
  }

  /// 最近的问题
  List<Question> get recentQuestions {
    return questions.where((q) => q.isRecent).toList();
  }

  /// 未解决的问题
  List<Question> get unresolvedQuestions {
    return questions.where((q) => !q.isResolved).toList();
  }

  // ============= LIFECYCLE =============

  @override
  void onInit() {
    super.onInit();
    loadCommunityData();
  }

  // ============= DATA LOADING =============

  /// 加载所有社区数据
  Future<void> loadCommunityData() async {
    isLoading.value = true;

    try {
      // 并行加载所有数据
      final results = await Future.wait([
        _loadTripReports(),
        _loadRecommendations(),
        _loadQuestions(),
      ]);

      // 检查是否所有请求都成功
      final allSuccess = results.every((result) => result);
      if (!allSuccess) {
        AppToast.error('部分数据加载失败');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载旅行报告
  Future<bool> _loadTripReports() async {
    final result = await _repository.getTripReports(
      city: selectedCity.value == 'All Cities' ? null : selectedCity.value,
    );

    return result.fold(
      onSuccess: (reports) {
        tripReports.value = reports;
        return true;
      },
      onFailure: (error) {
        log('加载旅行报告失败: ${error.message}');
        return false;
      },
    );
  }

  /// 加载城市推荐
  Future<bool> _loadRecommendations() async {
    final result = await _repository.getRecommendations(
      city: selectedCity.value == 'All Cities' ? null : selectedCity.value,
    );

    return result.fold(
      onSuccess: (recs) {
        recommendations.value = recs;
        return true;
      },
      onFailure: (error) {
        log('加载推荐失败: ${error.message}');
        return false;
      },
    );
  }

  /// 加载问题列表
  Future<bool> _loadQuestions() async {
    final result = await _repository.getQuestions(
      city: selectedCity.value == 'All Cities' ? null : selectedCity.value,
    );

    return result.fold(
      onSuccess: (qs) {
        questions.value = qs;
        return true;
      },
      onFailure: (error) {
        log('加载问题失败: ${error.message}');
        return false;
      },
    );
  }

  /// 加载问题的答案
  Future<void> loadAnswers(String questionId) async {
    // 如果已经加载过,直接返回
    if (answers.containsKey(questionId)) {
      return;
    }

    final result = await _repository.getAnswers(questionId);

    result.fold(
      onSuccess: (answerList) {
        answers[questionId] = answerList;
      },
      onFailure: (error) {
        log('加载答案失败: ${error.message}');
        AppToast.error('加载答案失败: ${error.message}');
      },
    );
  }

  // ============= USER ACTIONS =============

  /// 切换旅行报告的点赞状态
  Future<void> toggleLikeTripReport(String reportId) async {
    // 乐观更新: 先更新 UI
    final index = tripReports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;

    final report = tripReports[index];
    final wasLiked = report.isLiked;

    // 临时更新 UI
    final tempReport = TripReport(
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

    tripReports[index] = tempReport;

    // 调用后端
    final result = await _repository.toggleLikeTripReport(reportId);

    result.fold(
      onSuccess: (updatedReport) {
        // 用后端返回的数据更新
        tripReports[index] = updatedReport;
      },
      onFailure: (error) {
        // 失败则回滚
        tripReports[index] = report;
        AppToast.error('操作失败: ${error.message}');
      },
    );
  }

  /// 切换问题的点赞状态
  Future<void> toggleUpvoteQuestion(String questionId) async {
    // 乐观更新: 先更新 UI
    final index = questions.indexWhere((q) => q.id == questionId);
    if (index == -1) return;

    final question = questions[index];
    final wasUpvoted = question.isUpvoted;

    // 临时更新 UI
    final tempQuestion = Question(
      id: question.id,
      userId: question.userId,
      userName: question.userName,
      userAvatar: question.userAvatar,
      city: question.city,
      title: question.title,
      content: question.content,
      tags: question.tags,
      upvotes: wasUpvoted ? question.upvotes - 1 : question.upvotes + 1,
      answerCount: question.answerCount,
      hasAcceptedAnswer: question.hasAcceptedAnswer,
      createdAt: question.createdAt,
      isUpvoted: !wasUpvoted,
    );

    questions[index] = tempQuestion;

    // 调用后端
    final result = await _repository.toggleUpvoteQuestion(questionId);

    result.fold(
      onSuccess: (updatedQuestion) {
        // 用后端返回的数据更新
        questions[index] = updatedQuestion;
      },
      onFailure: (error) {
        // 失败则回滚
        questions[index] = question;
        AppToast.error('操作失败: ${error.message}');
      },
    );
  }

  /// 切换答案的点赞状态
  Future<void> toggleUpvoteAnswer(String questionId, String answerId) async {
    // 查找答案
    final answerList = answers[questionId];
    if (answerList == null) return;

    final index = answerList.indexWhere((a) => a.id == answerId);
    if (index == -1) return;

    final answer = answerList[index];
    final wasUpvoted = answer.isUpvoted;

    // 临时更新 UI
    final tempAnswer = Answer(
      id: answer.id,
      questionId: answer.questionId,
      userId: answer.userId,
      userName: answer.userName,
      userAvatar: answer.userAvatar,
      content: answer.content,
      upvotes: wasUpvoted ? answer.upvotes - 1 : answer.upvotes + 1,
      isAccepted: answer.isAccepted,
      createdAt: answer.createdAt,
      isUpvoted: !wasUpvoted,
    );

    answerList[index] = tempAnswer;
    answers[questionId] = List.from(answerList); // 触发响应式更新

    // 调用后端
    final result = await _repository.toggleUpvoteAnswer(answerId);

    result.fold(
      onSuccess: (updatedAnswer) {
        // 用后端返回的数据更新
        answerList[index] = updatedAnswer;
        answers[questionId] = List.from(answerList);
      },
      onFailure: (error) {
        // 失败则回滚
        answerList[index] = answer;
        answers[questionId] = List.from(answerList);
        AppToast.error('操作失败: ${error.message}');
      },
    );
  }

  /// 切换推荐类别
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  /// 切换城市过滤
  Future<void> changeCity(String city) async {
    if (selectedCity.value == city) return;

    selectedCity.value = city;
    await loadCommunityData(); // 重新加载数据
  }

  /// 刷新数据
  @override
  Future<void> refresh() async {
    await loadCommunityData();
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    tripReports.clear();
    recommendations.clear();
    questions.clear();
    answers.clear();
    
    // 重置选择状态
    selectedCategory.value = 'All';
    selectedCity.value = 'All Cities';
    
    // 重置加载状态
    isLoading.value = true;
    
    super.onClose();
  }
}
