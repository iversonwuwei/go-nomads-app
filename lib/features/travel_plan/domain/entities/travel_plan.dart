/// 旅行计划聚合根
/// 代表完整的AI生成旅行计划,包含交通、住宿、行程、景点、餐厅等信息
class TravelPlan {
  final String id;
  final Destination destination;
  final PlanMetadata metadata;
  final TripTransportation transportation;
  final TripAccommodation accommodation;
  final List<DailyItinerary> dailyItineraries;
  final List<AttractionRecommendation> attractions;
  final List<RestaurantRecommendation> restaurants;
  final List<String> tips;
  final TripBudget budget;
  final PlanStatus status;
  final String? departureLocation; // 出发地
  final DateTime? departureDate; // 出发日期

  TravelPlan({
    required this.id,
    required this.destination,
    required this.metadata,
    required this.transportation,
    required this.accommodation,
    required this.dailyItineraries,
    required this.attractions,
    required this.restaurants,
    required this.tips,
    required this.budget,
    required this.status,
    this.departureLocation,
    this.departureDate,
  });

  // === 业务逻辑方法 ===

  /// 是否是计划中状态
  bool get isPlanning => status == PlanStatus.planning;

  /// 是否已确认
  bool get isConfirmed => status == PlanStatus.confirmed;

  /// 是否已完成
  bool get isCompleted => status == PlanStatus.completed;

  /// 是否已取消
  bool get isCancelled => status == PlanStatus.cancelled;

  /// 是否可以编辑
  bool get canEdit => isPlanning || isConfirmed;

  /// 是否可以取消
  bool get canCancel => isPlanning || isConfirmed;

  /// 获取总天数
  int get totalDays => metadata.duration;

  /// 获取总活动数量
  int get totalActivities {
    return dailyItineraries.fold(
      0,
      (sum, itinerary) => sum + itinerary.activities.length,
    );
  }

  /// 获取计划的完整度 (0-100)
  int get completeness {
    int score = 0;

    // 基本信息 (20分)
    score += 20;

    // 交通计划 (15分)
    if (transportation.hasArrivalPlan) score += 7;
    if (transportation.hasLocalTransportPlan) score += 8;

    // 住宿计划 (15分)
    if (accommodation.hasRecommendation) score += 15;

    // 每日行程 (30分)
    if (dailyItineraries.isNotEmpty) {
      final avgActivitiesPerDay = totalActivities / totalDays;
      if (avgActivitiesPerDay >= 3) {
        score += 30;
      } else {
        score += (avgActivitiesPerDay * 10).toInt();
      }
    }

    // 景点推荐 (10分)
    if (attractions.length >= 5) {
      score += 10;
    } else {
      score += (attractions.length * 2);
    }

    // 餐厅推荐 (5分)
    if (restaurants.length >= 5) {
      score += 5;
    } else {
      score += restaurants.length;
    }

    // 实用建议 (5分)
    if (tips.length >= 5) {
      score += 5;
    } else {
      score += tips.length;
    }

    return score.clamp(0, 100);
  }

  /// 是否适合预算
  bool isSuitableForBudget(double maxBudget) {
    return budget.total <= maxBudget;
  }

  /// 获取平均每日花费
  double get averageDailyCost {
    if (totalDays == 0) return 0;
    return budget.total / totalDays;
  }

  /// 获取指定天的行程
  DailyItinerary? getItineraryForDay(int day) {
    try {
      return dailyItineraries.firstWhere((itinerary) => itinerary.day == day);
    } catch (e) {
      return null;
    }
  }

  /// 获取高评分景点 (4.0+)
  List<AttractionRecommendation> get topRatedAttractions {
    return attractions.where((a) => a.rating >= 4.0).toList()..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// 获取高评分餐厅 (4.0+)
  List<RestaurantRecommendation> get topRatedRestaurants {
    return restaurants.where((r) => r.rating >= 4.0).toList()..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// 获取免费景点
  List<AttractionRecommendation> get freeAttractions {
    return attractions.where((a) => a.entryFee == 0).toList();
  }

  /// 按类别获取景点
  List<AttractionRecommendation> getAttractionsByCategory(String category) {
    return attractions.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// 按价格范围获取餐厅
  List<RestaurantRecommendation> getRestaurantsByPriceRange(PriceRange priceRange) {
    return restaurants.where((r) => r.priceRange == priceRange).toList();
  }
}

/// 目的地值对象
class Destination {
  final String cityId;
  final String cityName;
  final String? cityImage;

  Destination({
    required this.cityId,
    required this.cityName,
    this.cityImage,
  });

  String get displayName => cityName;
}

/// 计划元数据值对象
class PlanMetadata {
  final DateTime createdAt;
  final int duration; // 旅行天数
  final BudgetLevel budgetLevel;
  final TravelStyle style;
  final List<String> interests;

  PlanMetadata({
    required this.createdAt,
    required this.duration,
    required this.budgetLevel,
    required this.style,
    required this.interests,
  });

  /// 是否是短途旅行 (1-3天)
  bool get isShortTrip => duration <= 3;

  /// 是否是中途旅行 (4-7天)
  bool get isMediumTrip => duration >= 4 && duration <= 7;

  /// 是否是长途旅行 (8天以上)
  bool get isLongTrip => duration >= 8;
}

/// 预算等级枚举
enum BudgetLevel {
  low,
  medium,
  high;

  static BudgetLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return BudgetLevel.low;
      case 'medium':
        return BudgetLevel.medium;
      case 'high':
        return BudgetLevel.high;
      default:
        return BudgetLevel.medium;
    }
  }

  String get displayName {
    switch (this) {
      case BudgetLevel.low:
        return 'Budget';
      case BudgetLevel.medium:
        return 'Moderate';
      case BudgetLevel.high:
        return 'Luxury';
    }
  }

  @override
  String toString() => name;
}

/// 旅行风格枚举
enum TravelStyle {
  adventure,
  relaxation,
  culture,
  nightlife,
  foodie,
  nature,
  shopping;

  static TravelStyle fromString(String value) {
    switch (value.toLowerCase()) {
      case 'adventure':
        return TravelStyle.adventure;
      case 'relaxation':
        return TravelStyle.relaxation;
      case 'culture':
        return TravelStyle.culture;
      case 'nightlife':
        return TravelStyle.nightlife;
      case 'foodie':
        return TravelStyle.foodie;
      case 'nature':
        return TravelStyle.nature;
      case 'shopping':
        return TravelStyle.shopping;
      default:
        return TravelStyle.culture;
    }
  }

  String get emoji {
    switch (this) {
      case TravelStyle.adventure:
        return '🏔️';
      case TravelStyle.relaxation:
        return '🏖️';
      case TravelStyle.culture:
        return '🏛️';
      case TravelStyle.nightlife:
        return '🎉';
      case TravelStyle.foodie:
        return '🍜';
      case TravelStyle.nature:
        return '🌳';
      case TravelStyle.shopping:
        return '🛍️';
    }
  }

  @override
  String toString() => name;
}

/// 交通计划值对象
class TripTransportation {
  final ArrivalPlan? arrival;
  final LocalTransportPlan? localTransport;

  TripTransportation({
    this.arrival,
    this.localTransport,
  });

  bool get hasArrivalPlan => arrival != null;
  bool get hasLocalTransportPlan => localTransport != null;
}

/// 到达计划值对象
class ArrivalPlan {
  final String method; // flight, train, bus, car
  final String details;
  final double estimatedCost;

  ArrivalPlan({
    required this.method,
    required this.details,
    required this.estimatedCost,
  });
}

/// 当地交通计划值对象
class LocalTransportPlan {
  final String method; // public, taxi, rental, walking
  final String details;
  final double dailyCost;

  LocalTransportPlan({
    required this.method,
    required this.details,
    required this.dailyCost,
  });
}

/// 住宿计划值对象
class TripAccommodation {
  final AccommodationType type;
  final String recommendation;
  final String recommendedArea;
  final double pricePerNight;
  final List<String> amenities;
  final String? bookingTips;

  TripAccommodation({
    required this.type,
    required this.recommendation,
    required this.recommendedArea,
    required this.pricePerNight,
    required this.amenities,
    this.bookingTips,
  });

  bool get hasRecommendation => recommendation.isNotEmpty;

  double getTotalCost(int nights) => pricePerNight * nights;
}

/// 住宿类型枚举
enum AccommodationType {
  hostel,
  hotel,
  apartment,
  guesthouse,
  resort;

  static AccommodationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hostel':
        return AccommodationType.hostel;
      case 'hotel':
        return AccommodationType.hotel;
      case 'apartment':
        return AccommodationType.apartment;
      case 'guesthouse':
        return AccommodationType.guesthouse;
      case 'resort':
        return AccommodationType.resort;
      default:
        return AccommodationType.hotel;
    }
  }

  @override
  String toString() => name;
}

/// 每日行程值对象
class DailyItinerary {
  final int day;
  final String theme;
  final List<PlannedActivity> activities;
  final String? notes;

  DailyItinerary({
    required this.day,
    required this.theme,
    required this.activities,
    this.notes,
  });

  /// 获取总活动时长(分钟)
  int get totalDuration {
    return activities.fold(0, (sum, activity) => sum + activity.duration);
  }

  /// 获取总预估花费
  double get totalEstimatedCost {
    return activities.fold(0, (sum, activity) => sum + activity.estimatedCost);
  }

  /// 获取格式化的总时长
  String get formattedDuration {
    final hours = totalDuration ~/ 60;
    final minutes = totalDuration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// 计划活动值对象
class PlannedActivity {
  final String time;
  final String name;
  final String description;
  final String location;
  final double estimatedCost;
  final int duration; // 分钟

  PlannedActivity({
    required this.time,
    required this.name,
    required this.description,
    required this.location,
    required this.estimatedCost,
    required this.duration,
  });

  /// 获取格式化的时长
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// 景点推荐值对象
class AttractionRecommendation {
  final String name;
  final String description;
  final String category;
  final double rating;
  final String location;
  final double entryFee;
  final String bestTime;
  final String? image;

  AttractionRecommendation({
    required this.name,
    required this.description,
    required this.category,
    required this.rating,
    required this.location,
    required this.entryFee,
    required this.bestTime,
    this.image,
  });

  /// 是否免费
  bool get isFree => entryFee == 0;

  /// 是否高评分 (4.0+)
  bool get isHighlyRated => rating >= 4.0;

  /// 获取评分星级显示
  String get ratingStars {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final stars = '⭐' * fullStars;
    return hasHalfStar ? '$stars½' : stars;
  }
}

/// 餐厅推荐值对象
class RestaurantRecommendation {
  final String name;
  final String cuisine;
  final String description;
  final double rating;
  final PriceRange priceRange;
  final String location;
  final String specialty;
  final String? image;

  RestaurantRecommendation({
    required this.name,
    required this.cuisine,
    required this.description,
    required this.rating,
    required this.priceRange,
    required this.location,
    required this.specialty,
    this.image,
  });

  /// 是否高评分 (4.0+)
  bool get isHighlyRated => rating >= 4.0;

  /// 获取价格符号显示
  String get priceSymbol {
    switch (priceRange) {
      case PriceRange.budget:
        return '\$';
      case PriceRange.moderate:
        return '\$\$';
      case PriceRange.expensive:
        return '\$\$\$';
      case PriceRange.luxury:
        return '\$\$\$\$';
    }
  }
}

/// 价格范围枚举
enum PriceRange {
  budget,
  moderate,
  expensive,
  luxury;

  static PriceRange fromString(String value) {
    switch (value.toLowerCase()) {
      case 'budget':
      case '\$':
        return PriceRange.budget;
      case 'moderate':
      case '\$\$':
        return PriceRange.moderate;
      case 'expensive':
      case '\$\$\$':
        return PriceRange.expensive;
      case 'luxury':
      case '\$\$\$\$':
        return PriceRange.luxury;
      default:
        return PriceRange.moderate;
    }
  }

  @override
  String toString() => name;
}

/// 旅行预算值对象
class TripBudget {
  final double transportation;
  final double accommodation;
  final double food;
  final double activities;
  final double miscellaneous;
  final String currency;

  TripBudget({
    required this.transportation,
    required this.accommodation,
    required this.food,
    required this.activities,
    required this.miscellaneous,
    this.currency = 'USD',
  });

  /// 获取总预算
  double get total {
    return transportation + accommodation + food + activities + miscellaneous;
  }

  /// 获取各项占比
  Map<String, double> get breakdown {
    final totalAmount = total;
    if (totalAmount == 0) {
      return {
        'transportation': 0,
        'accommodation': 0,
        'food': 0,
        'activities': 0,
        'miscellaneous': 0,
      };
    }

    return {
      'transportation': (transportation / totalAmount * 100),
      'accommodation': (accommodation / totalAmount * 100),
      'food': (food / totalAmount * 100),
      'activities': (activities / totalAmount * 100),
      'miscellaneous': (miscellaneous / totalAmount * 100),
    };
  }

  /// 获取格式化的总预算
  String get formattedTotal => '$currency ${total.toStringAsFixed(2)}';

  /// 获取最大支出项
  String get largestExpenseCategory {
    final expenses = {
      'Transportation': transportation,
      'Accommodation': accommodation,
      'Food': food,
      'Activities': activities,
      'Miscellaneous': miscellaneous,
    };

    var maxCategory = 'Transportation';
    var maxAmount = 0.0;

    expenses.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        maxCategory = category;
      }
    });

    return maxCategory;
  }
}

/// 计划状态枚举
enum PlanStatus {
  planning, // 计划中
  confirmed, // 已确认
  completed, // 已完成
  cancelled; // 已取消

  static PlanStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'planning':
        return PlanStatus.planning;
      case 'confirmed':
        return PlanStatus.confirmed;
      case 'completed':
        return PlanStatus.completed;
      case 'cancelled':
        return PlanStatus.cancelled;
      default:
        return PlanStatus.planning;
    }
  }

  @override
  String toString() => name;
}
