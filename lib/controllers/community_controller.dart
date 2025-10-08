import 'package:get/get.dart';

import '../models/community_model.dart';

class CommunityController extends GetxController {
  // Trip Reports
  final RxList<TripReport> tripReports = <TripReport>[].obs;
  final RxList<String> likedReports = <String>[].obs;

  // City Recommendations
  final RxList<CityRecommendation> recommendations = <CityRecommendation>[].obs;
  final RxString selectedCategory = 'All'.obs;

  // Q&A
  final RxList<Question> questions = <Question>[].obs;
  final RxList<String> upvotedQuestions = <String>[].obs;

  final RxBool isLoading = true.obs;
  final RxString selectedCity = 'All Cities'.obs;

  final List<String> categories = [
    'All',
    'Restaurant',
    'Cafe',
    'Coworking',
    'Activity'
  ];

  @override
  void onInit() {
    super.onInit();
    loadCommunityData();
  }

  // Load all community data
  void loadCommunityData() {
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      tripReports.value = _generateMockTripReports();
      recommendations.value = _generateMockRecommendations();
      questions.value = _generateMockQuestions();
      isLoading.value = false;
    });
  }

  // Toggle like on trip report
  void toggleLikeTripReport(String reportId) {
    if (likedReports.contains(reportId)) {
      likedReports.remove(reportId);
      final index = tripReports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        final report = tripReports[index];
        tripReports[index] = TripReport(
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
          likes: report.likes - 1,
          comments: report.comments,
          createdAt: report.createdAt,
          isLiked: false,
        );
      }
    } else {
      likedReports.add(reportId);
      final index = tripReports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        final report = tripReports[index];
        tripReports[index] = TripReport(
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
          likes: report.likes + 1,
          comments: report.comments,
          createdAt: report.createdAt,
          isLiked: true,
        );
      }
    }
    tripReports.refresh();
  }

  // Toggle upvote on question
  void toggleUpvoteQuestion(String questionId) {
    if (upvotedQuestions.contains(questionId)) {
      upvotedQuestions.remove(questionId);
      final index = questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        final question = questions[index];
        questions[index] = Question(
          id: question.id,
          userId: question.userId,
          userName: question.userName,
          userAvatar: question.userAvatar,
          city: question.city,
          title: question.title,
          content: question.content,
          tags: question.tags,
          upvotes: question.upvotes - 1,
          answerCount: question.answerCount,
          hasAcceptedAnswer: question.hasAcceptedAnswer,
          createdAt: question.createdAt,
          isUpvoted: false,
        );
      }
    } else {
      upvotedQuestions.add(questionId);
      final index = questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        final question = questions[index];
        questions[index] = Question(
          id: question.id,
          userId: question.userId,
          userName: question.userName,
          userAvatar: question.userAvatar,
          city: question.city,
          title: question.title,
          content: question.content,
          tags: question.tags,
          upvotes: question.upvotes + 1,
          answerCount: question.answerCount,
          hasAcceptedAnswer: question.hasAcceptedAnswer,
          createdAt: question.createdAt,
          isUpvoted: true,
        );
      }
    }
    questions.refresh();
  }

  // Filter recommendations by category
  List<CityRecommendation> get filteredRecommendations {
    if (selectedCategory.value == 'All') {
      return recommendations;
    }
    return recommendations.where((r) => r.category == selectedCategory.value).toList();
  }

  // Generate mock trip reports
  List<TripReport> _generateMockTripReports() {
    return [
      TripReport(
        id: 'report_001',
        userId: 'user_002',
        userName: 'Sarah Kim',
        userAvatar: 'https://i.pravatar.cc/300?img=5',
        city: 'Chiang Mai',
        country: 'Thailand',
        startDate: DateTime(2024, 8, 1),
        endDate: DateTime(2024, 10, 31),
        overallRating: 4.8,
        ratings: {
          'cost': 5.0,
          'internet': 4.5,
          'safety': 4.8,
          'food': 4.9,
          'community': 4.7,
        },
        title: '3 Months in Chiang Mai: A Digital Nomad\'s Paradise',
        content: 'Chiang Mai exceeded all my expectations! The combination of affordability, fast internet, amazing food, and welcoming community makes it perfect for remote work. I stayed in Nimman area which is the digital nomad hub...',
        photos: [
          'https://images.unsplash.com/photo-1598954982835-4e8b83949850?w=800',
          'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800',
          'https://images.unsplash.com/photo-1563492065180-f03487b29fe7?w=800',
        ],
        pros: [
          'Extremely affordable (\$500-800/month all-in)',
          'Fast WiFi at cafes and coworking spaces',
          'Amazing street food and restaurants',
          'Friendly local and expat community',
          'Perfect weather from Nov-Feb',
        ],
        cons: [
          'Burning season (March-April) has poor air quality',
          'Can get too touristy in old town',
          'Limited nightlife compared to Bangkok',
        ],
        likes: 245,
        comments: 38,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TripReport(
        id: 'report_002',
        userId: 'user_003',
        userName: 'Mike Johnson',
        userAvatar: 'https://i.pravatar.cc/300?img=12',
        city: 'Lisbon',
        country: 'Portugal',
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 8, 15),
        overallRating: 4.6,
        ratings: {
          'cost': 3.5,
          'internet': 4.8,
          'safety': 4.9,
          'food': 4.8,
          'community': 4.5,
        },
        title: 'Lisbon Summer: Beautiful but Expensive',
        content: 'Spent an amazing summer working from Lisbon. The city is absolutely gorgeous with incredible food and wine. However, it\'s become quite expensive compared to a few years ago...',
        photos: [
          'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=800',
          'https://images.unsplash.com/photo-1585208798174-6cedd86e019a?w=800',
        ],
        pros: [
          'Stunning architecture and views',
          'Excellent public transportation',
          'Great coworking scene',
          'Perfect summer weather',
          'Friendly locals who speak English',
        ],
        cons: [
          'Getting expensive (\$1200-1800/month)',
          'Lots of tourists in summer',
          'Hills make walking challenging',
        ],
        likes: 189,
        comments: 27,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ];
  }

  // Generate mock recommendations
  List<CityRecommendation> _generateMockRecommendations() {
    return [
      CityRecommendation(
        id: 'rec_001',
        city: 'Chiang Mai',
        name: 'Punspace Nimman',
        category: 'Coworking',
        description: 'Premier coworking space in Nimman with fast WiFi, meeting rooms, and a rooftop terrace.',
        rating: 4.8,
        reviewCount: 156,
        priceRange: '\$\$',
        address: 'Nimman Road, Chiang Mai',
        photos: ['https://images.unsplash.com/photo-1497366216548-37526070297c?w=800'],
        website: 'https://punspace.com',
        tags: ['WiFi', 'Coffee', 'Meeting Rooms', 'Rooftop'],
        userId: 'user_002',
        userName: 'Sarah Kim',
        userAvatar: 'https://i.pravatar.cc/300?img=5',
      ),
      CityRecommendation(
        id: 'rec_002',
        city: 'Chiang Mai',
        name: 'Ristr8to Lab',
        category: 'Cafe',
        description: 'Award-winning specialty coffee. Perfect for working with great WiFi and delicious food.',
        rating: 4.9,
        reviewCount: 243,
        priceRange: '\$\$',
        address: 'Nimmanhaemin Road',
        photos: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800'],
        tags: ['Coffee', 'WiFi', 'Breakfast', 'Specialty Coffee'],
        userId: 'user_003',
        userName: 'Mike Johnson',
        userAvatar: 'https://i.pravatar.cc/300?img=12',
      ),
      CityRecommendation(
        id: 'rec_003',
        city: 'Lisbon',
        name: 'Second Home Lisboa',
        category: 'Coworking',
        description: 'Beautiful coworking space in Mercado da Ribeira with stunning design and great community.',
        rating: 4.7,
        reviewCount: 198,
        priceRange: '\$\$\$',
        address: 'Mercado da Ribeira, Lisbon',
        photos: ['https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800'],
        tags: ['Premium', 'Design', 'Community', 'Events'],
        userId: 'user_004',
        userName: 'Emma Davis',
        userAvatar: 'https://i.pravatar.cc/300?img=9',
      ),
      CityRecommendation(
        id: 'rec_004',
        city: 'Bangkok',
        name: 'Or Tor Kor Market',
        category: 'Restaurant',
        description: 'The best fresh market in Bangkok with incredible street food and produce.',
        rating: 4.9,
        reviewCount: 312,
        priceRange: '\$',
        address: 'Chatuchak, Bangkok',
        photos: ['https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800'],
        tags: ['Street Food', 'Market', 'Authentic', 'Cheap'],
        userId: 'user_005',
        userName: 'Carlos Silva',
        userAvatar: 'https://i.pravatar.cc/300?img=14',
      ),
    ];
  }

  // Generate mock questions
  List<Question> _generateMockQuestions() {
    return [
      Question(
        id: 'q_001',
        userId: 'user_006',
        userName: 'Lisa Chen',
        userAvatar: 'https://i.pravatar.cc/300?img=20',
        city: 'Chiang Mai',
        title: 'Best area to stay in Chiang Mai for first-timers?',
        content: 'I\'m planning my first trip to Chiang Mai next month. Should I stay in Nimman or Old Town? I want to be close to coworking spaces and good cafes but also experience the local culture.',
        tags: ['accommodation', 'first-time', 'location'],
        upvotes: 15,
        answerCount: 8,
        hasAcceptedAnswer: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Question(
        id: 'q_002',
        userId: 'user_007',
        userName: 'David Park',
        userAvatar: 'https://i.pravatar.cc/300?img=15',
        city: 'Bali',
        title: 'Recommended visa options for staying 6 months in Bali?',
        content: 'What are the current visa options for digital nomads wanting to stay in Bali for 6 months? Is the B211 still the best option?',
        tags: ['visa', 'legal', 'long-term'],
        upvotes: 28,
        answerCount: 12,
        hasAcceptedAnswer: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Question(
        id: 'q_003',
        userId: 'user_008',
        userName: 'Anna Martinez',
        userAvatar: 'https://i.pravatar.cc/300?img=25',
        city: 'Lisbon',
        title: 'Is Lisbon still worth it with the rising prices?',
        content: 'I visited Lisbon in 2020 and loved it. Planning to return but I\'ve heard prices have skyrocketed. Is it still a good value for digital nomads?',
        tags: ['budget', 'cost-of-living'],
        upvotes: 42,
        answerCount: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}
