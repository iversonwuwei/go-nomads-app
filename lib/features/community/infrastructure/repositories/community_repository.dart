import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/community/domain/entities/trip_report.dart';
import 'package:df_admin_mobile/features/community/domain/repositories/i_community_repository.dart';

/// Community Repository Implementation - 社区功能仓储实现
/// 目前使用 Mock 数据,未来替换为真实 API 调用
class CommunityRepository implements ICommunityRepository {
  // Mock data storage
  List<TripReport>? _cachedTripReports;
  List<CityRecommendation>? _cachedRecommendations;
  List<Question>? _cachedQuestions;
  final Map<String, List<Answer>> _cachedAnswers = {};

  // Liked/Upvoted tracking
  final Set<String> _likedReports = {};
  final Set<String> _upvotedQuestions = {};
  final Set<String> _upvotedAnswers = {};

  @override
  Future<Result<List<TripReport>>> getTripReports({String? city}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize mock data if needed
      _cachedTripReports ??= _generateMockTripReports();

      // Apply city filter if provided
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

  @override
  Future<Result<List<CityRecommendation>>> getRecommendations({
    String? city,
    String? category,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize mock data if needed
      _cachedRecommendations ??= _generateMockRecommendations();

      // Apply filters
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize mock data if needed
      _cachedQuestions ??= _generateMockQuestions();

      // Apply city filter if provided
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Initialize mock answers if needed
      if (!_cachedAnswers.containsKey(questionId)) {
        _cachedAnswers[questionId] = _generateMockAnswers(questionId);
      }

      return Result.success(_cachedAnswers[questionId]!);
    } catch (e) {
      return Result.failure(NetworkException('获取答案失败: $e'));
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      // Find the question
      final index =
          _cachedQuestions?.indexWhere((q) => q.id == questionId) ?? -1;
      if (index == -1) {
        return Result.failure(NotFoundException('问题不存在'));
      }

      final question = _cachedQuestions![index];

      // Toggle upvote state
      final wasUpvoted = _upvotedQuestions.contains(questionId);
      if (wasUpvoted) {
        _upvotedQuestions.remove(questionId);
      } else {
        _upvotedQuestions.add(questionId);
      }

      // Create updated question
      final updatedQuestion = Question(
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

      // Update cache
      _cachedQuestions![index] = updatedQuestion;

      return Result.success(updatedQuestion);
    } catch (e) {
      return Result.failure(NetworkException('切换点赞失败: $e'));
    }
  }

  @override
  Future<Result<Answer>> toggleUpvoteAnswer(String answerId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      // Find the answer across all questions
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

      // Toggle upvote state
      final wasUpvoted = _upvotedAnswers.contains(answerId);
      if (wasUpvoted) {
        _upvotedAnswers.remove(answerId);
      } else {
        _upvotedAnswers.add(answerId);
      }

      // Create updated answer
      final updatedAnswer = Answer(
        id: targetAnswer.id,
        questionId: targetAnswer.questionId,
        userId: targetAnswer.userId,
        userName: targetAnswer.userName,
        userAvatar: targetAnswer.userAvatar,
        content: targetAnswer.content,
        upvotes:
            wasUpvoted ? targetAnswer.upvotes - 1 : targetAnswer.upvotes + 1,
        isAccepted: targetAnswer.isAccepted,
        createdAt: targetAnswer.createdAt,
        isUpvoted: !wasUpvoted,
      );

      // Update cache
      final answers = _cachedAnswers[questionId]!;
      final index = answers.indexWhere((a) => a.id == answerId);
      answers[index] = updatedAnswer;

      return Result.success(updatedAnswer);
    } catch (e) {
      return Result.failure(NetworkException('切换点赞失败: $e'));
    }
  }

  // ============= MOCK DATA GENERATORS =============

  List<TripReport> _generateMockTripReports() {
    return [
      TripReport(
        id: '1',
        userId: 'user1',
        userName: 'Sarah Chen',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        city: 'Chiang Mai',
        country: 'Thailand',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 30)),
        overallRating: 4.8,
        ratings: {
          'Cost of Living': 5.0,
          'Internet Speed': 4.5,
          'Coworking Spaces': 5.0,
          'Community': 4.5,
          'Safety': 5.0,
        },
        title: '在清迈的一个月 - 数字游民天堂',
        content: '''
清迈是我去过的最适合数字游民的城市之一。生活成本低,网络快速稳定,咖啡馆和共享办公空间遍地都是。

老城区非常适合居住,步行就能到达大部分地方。我最喜欢的是 Nimman 区域,那里有很多现代化的咖啡馆和餐厅。

当地人非常友好,英语普及率也不错。周末可以去山上的寺庙或者参加周日夜市。

唯一的缺点是3-4月的烧山季节,空气质量会变差。建议避开这个时间段。
        ''',
        photos: [
          'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648',
          'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a',
        ],
        pros: [
          '生活成本极低',
          '网络速度快',
          '共享办公空间多',
          '社区活跃',
          '食物美味便宜',
        ],
        cons: [
          '3-4月空气质量差',
          '语言障碍(少数)',
          '夏季非常热',
        ],
        likes: 234,
        comments: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        isLiked: false,
      ),
      TripReport(
        id: '2',
        userId: 'user2',
        userName: 'Marco Silva',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        city: 'Lisbon',
        country: 'Portugal',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().subtract(const Duration(days: 60)),
        overallRating: 4.5,
        ratings: {
          'Cost of Living': 3.5,
          'Internet Speed': 4.5,
          'Coworking Spaces': 4.0,
          'Community': 5.0,
          'Safety': 5.0,
        },
        title: '里斯本 - 欧洲的数字游民中心',
        content: '''
里斯本现在是欧洲最受欢迎的数字游民目的地之一。城市充满活力,有着丰富的历史和文化。

共享办公空间质量很高,如 Second Home Lisboa 和 Impact Hub。网络速度不错,大部分咖啡馆都有 WiFi。

生活成本比北欧低很多,但最近几年在上涨。住宿可能有点贵,建议提前预订。

周末可以去 Sintra 或 Cascais,交通很方便。数字游民社区很活跃,经常有各种活动和聚会。
        ''',
        photos: [
          'https://images.unsplash.com/photo-1555881400-74d7acaacd8b',
          'https://images.unsplash.com/photo-1598950323655-f51b5eb7d9e3',
        ],
        pros: [
          '欧洲签证友好',
          '数字游民社区活跃',
          '文化丰富',
          '气候宜人',
          '共享办公空间质量高',
        ],
        cons: [
          '生活成本上涨',
          '住宿较贵',
          '夏季游客太多',
        ],
        likes: 189,
        comments: 32,
        createdAt: DateTime.now().subtract(const Duration(days: 55)),
        isLiked: false,
      ),
    ];
  }

  List<CityRecommendation> _generateMockRecommendations() {
    return [
      // Chiang Mai Recommendations
      CityRecommendation(
        id: 'rec1',
        city: 'Chiang Mai',
        name: 'Punspace Nimman',
        category: 'Coworking',
        description: '''
清迈最受欢迎的共享办公空间之一,位于时尚的 Nimman 区域。

设施包括:
• 高速网络 (100+ Mbps)
• 舒适的座位和工位
• 会议室
• 打印机和扫描仪
• 免费咖啡和茶
• 空调环境
• 24小时门禁

非常适合远程工作,周围有很多咖啡馆和餐厅。数字游民社区活跃,经常有活动。
        ''',
        rating: 4.8,
        reviewCount: 342,
        priceRange: '\$\$',
        address:
            'Nimmana Haeminda Rd Lane 1, Tambon Su Thep, Amphoe Mueang Chiang Mai',
        photos: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c',
        ],
        website: 'https://punspace.com',
        tags: ['Fast WiFi', 'Community', 'Coffee', '24/7 Access'],
        userId: 'user1',
        userName: 'Sarah Chen',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
      CityRecommendation(
        id: 'rec2',
        city: 'Chiang Mai',
        name: 'Ristr8to Lab',
        category: 'Cafe',
        description: '''
世界级的咖啡馆,曾获得拉花艺术世界冠军。

特色:
• 精品咖啡,多种冲煮方式
• 拉花艺术表演
• 舒适的工作环境
• 快速 WiFi
• 户外座位

非常适合远程工作,咖啡质量一流。环境安静,有很多电源插座。
        ''',
        rating: 4.9,
        reviewCount: 567,
        priceRange: '\$\$',
        address: '15/3 Nimmanhaemin Road Soi 3',
        photos: [
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
        ],
        website: 'https://www.facebook.com/ristr8to',
        tags: ['Specialty Coffee', 'WiFi', 'Latte Art', 'Quiet'],
        userId: 'user3',
        userName: 'Alex Kim',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
      ),
      // Lisbon Recommendations
      CityRecommendation(
        id: 'rec3',
        city: 'Lisbon',
        name: 'Second Home Lisboa',
        category: 'Coworking',
        description: '''
里斯本最美的共享办公空间,位于 Mercado da Ribeira 市场内。

特色:
• 屡获殊荣的设计
• 超过 1000 种植物
• 高速网络
• 活动和工作坊
• 与市场共享,可以直接买美食
• 社区氛围极好

价格偏高,但物有所值。非常适合创意工作者和企业家。
        ''',
        rating: 4.7,
        reviewCount: 234,
        priceRange: '\$\$\$',
        address: 'Avenida 24 de Julho, 1200-479 Lisboa',
        photos: [
          'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
        ],
        website: 'https://secondhome.io/location/lisboa',
        tags: ['Design', 'Community', 'Events', 'Market'],
        userId: 'user2',
        userName: 'Marco Silva',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
      ),
      // Bangkok Recommendation
      CityRecommendation(
        id: 'rec4',
        city: 'Bangkok',
        name: 'Or Tor Kor Market',
        category: 'Restaurant',
        description: '''
曼谷最好的传统市场之一,CNN 评选为全球最佳生鲜市场。

特色:
• 新鲜的热带水果
• 地道泰国美食
• 干净卫生
• 价格合理
• 位置便利(MRT Kamphaeng Phet 站)

一定要尝试芒果糯米饭和各种热带水果。午餐时间有很多熟食摊位。
        ''',
        rating: 4.6,
        reviewCount: 1823,
        priceRange: '\$',
        address: '101 Kamphaeng Phet Rd, Chatuchak, Bangkok',
        photos: [
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1',
        ],
        website: null,
        tags: ['Market', 'Local Food', 'Fresh Produce', 'Authentic'],
        userId: 'user4',
        userName: 'Emma Wong',
        userAvatar: 'https://i.pravatar.cc/150?img=4',
      ),
    ];
  }

  List<Question> _generateMockQuestions() {
    return [
      Question(
        id: 'q1',
        userId: 'user5',
        userName: 'David Park',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        city: 'Chiang Mai',
        title: '清迈 Nimman 区和老城区,哪个更适合数字游民?',
        content: '''
我计划下个月去清迈待3个月,在纠结住 Nimman 还是老城区。

我的需求:
• 步行可达共享办公空间和咖啡馆
• 周边有餐厅和便利店
• 相对安静,适合工作
• 预算: 每月 15000-20000 泰铢

有经验的朋友能分享一下建议吗?
        ''',
        tags: ['Accommodation', 'Chiang Mai', 'Digital Nomad', 'Nimman'],
        upvotes: 23,
        answerCount: 7,
        hasAcceptedAnswer: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isUpvoted: false,
      ),
      Question(
        id: 'q2',
        userId: 'user6',
        userName: 'Sophie Laurent',
        userAvatar: 'https://i.pravatar.cc/150?img=6',
        city: 'Bali',
        title: '巴厘岛的签证政策更新了吗?',
        content: '''
我看到新闻说印尼要推出数字游民签证,但不确定具体政策。

有人知道:
1. 是否已经正式实施?
2. 申请条件和费用?
3. 停留时间?
4. 能否多次入境?

目前还是用落地签待30天比较保险吗?
        ''',
        tags: ['Visa', 'Bali', 'Indonesia', 'Digital Nomad Visa'],
        upvotes: 45,
        answerCount: 12,
        hasAcceptedAnswer: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isUpvoted: false,
      ),
      Question(
        id: 'q3',
        userId: 'user7',
        userName: 'Lucas Müller',
        userAvatar: 'https://i.pravatar.cc/150?img=7',
        city: 'Lisbon',
        title: '里斯本的物价最近涨了很多吗?',
        content: '''
上次去里斯本是2020年,现在想再去,但听说物价涨了不少。

特别想了解:
• 住宿 (一室公寓)
• 餐饮 (普通餐厅)
• 共享办公空间
• 交通

每月预算 2000 欧够吗(不包括住宿)?
        ''',
        tags: ['Cost of Living', 'Lisbon', 'Budget', 'Accommodation'],
        upvotes: 31,
        answerCount: 9,
        hasAcceptedAnswer: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isUpvoted: false,
      ),
    ];
  }

  List<Answer> _generateMockAnswers(String questionId) {
    // Generate different answers based on question
    if (questionId == 'q1') {
      return [
        Answer(
          id: 'a1_1',
          questionId: questionId,
          userId: 'user1',
          userName: 'Sarah Chen',
          userAvatar: 'https://i.pravatar.cc/150?img=1',
          content: '''
我在清迈住了6个月,两个区域都住过。

**Nimman 区域优点:**
• 现代化,咖啡馆和餐厅很多
• Punspace 等共享办公空间步行可达
• 晚上娱乐选择多
• 比较国际化

**老城区优点:**
• 更有文化氛围
• 生活成本稍低
• 寺庙和市场多
• 更安静

你的预算在两个区域都够用。我个人更推荐 Nimman,因为工作环境更好,但如果想体验更地道的清迈,老城区也不错。

可以先在 Nimman 住一个月,如果不喜欢再换到老城区。
          ''',
          upvotes: 15,
          isAccepted: true,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          isUpvoted: false,
        ),
        Answer(
          id: 'a1_2',
          questionId: questionId,
          userId: 'user8',
          userName: 'Tom Anderson',
          userAvatar: 'https://i.pravatar.cc/150?img=8',
          content: '''
我推荐老城区!Nimman 太吵了,到处都是游客。

老城区虽然传统,但有很多不错的咖啡馆,而且房租便宜。我住在 Phra Singh 寺附近,每月只要 12000 泰铢,包水电网络。

骑摩托车去 Nimman 也就10分钟,不用担心距离。
          ''',
          upvotes: 8,
          isAccepted: false,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isUpvoted: false,
        ),
      ];
    }
    return [];
  }
}
