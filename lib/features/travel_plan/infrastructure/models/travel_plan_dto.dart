import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';

/// TravelPlan DTO - 基础设施层数据传输对象
/// 完整的AI生成旅行计划数据传输对象
class TravelPlanDto {
  final String id;
  final String cityId;
  final String cityName;
  final String cityImage;
  final String createdAt;
  final int duration; // 旅行天数
  final String budget; // 预算等级: low, medium, high
  final String travelStyle; // 旅行风格: adventure, relaxation, culture, nightlife
  final List<String> interests; // 兴趣标签
  final String? departureLocation; // 出发地
  final String? departureDate; // 出发日期

  // 计划详情
  final TransportationPlanDto transportation;
  final AccommodationPlanDto accommodation;
  final List<DailyItineraryDto> dailyItineraries;
  final List<AttractionDto> attractions;
  final List<RestaurantDto> restaurants;
  final List<String> tips;
  final BudgetBreakdownDto budgetBreakdown;

  TravelPlanDto({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.cityImage,
    required this.createdAt,
    required this.duration,
    required this.budget,
    required this.travelStyle,
    required this.interests,
    this.departureLocation,
    this.departureDate,
    required this.transportation,
    required this.accommodation,
    required this.dailyItineraries,
    required this.attractions,
    required this.restaurants,
    required this.tips,
    required this.budgetBreakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityId': cityId,
      'cityName': cityName,
      'cityImage': cityImage,
      'createdAt': createdAt,
      'duration': duration,
      'budget': budget,
      'travelStyle': travelStyle,
      'interests': interests,
      'departureLocation': departureLocation,
      'departureDate': departureDate,
      'transportation': transportation.toJson(),
      'accommodation': accommodation.toJson(),
      'dailyItineraries': dailyItineraries.map((e) => e.toJson()).toList(),
      'attractions': attractions.map((e) => e.toJson()).toList(),
      'restaurants': restaurants.map((e) => e.toJson()).toList(),
      'tips': tips,
      'budgetBreakdown': budgetBreakdown.toJson(),
    };
  }

  factory TravelPlanDto.fromJson(Map<String, dynamic> json) {
    return TravelPlanDto(
      id: json['id']?.toString() ?? '',
      cityId: json['cityId']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      cityImage: json['cityImage']?.toString() ?? '',
      createdAt: _toDateTimeString(json['createdAt']),
      duration: _toInt(json['duration']),
      budget: json['budget']?.toString() ?? '',
      travelStyle: json['travelStyle']?.toString() ?? '',
      interests: _toStringList(json['interests']),
      departureLocation: json['departureLocation']?.toString(),
      departureDate: json['departureDate']?.toString(),
      transportation: json['transportation'] is Map<String, dynamic>
          ? TransportationPlanDto.fromJson(json['transportation'] as Map<String, dynamic>)
          : TransportationPlanDto.empty(),
      accommodation: json['accommodation'] is Map<String, dynamic>
          ? AccommodationPlanDto.fromJson(json['accommodation'] as Map<String, dynamic>)
          : AccommodationPlanDto.empty(),
      dailyItineraries: _toMapList(json['dailyItineraries']).map(DailyItineraryDto.fromJson).toList(),
      attractions: _toMapList(json['attractions']).map(AttractionDto.fromJson).toList(),
      restaurants: _toMapList(json['restaurants']).map(RestaurantDto.fromJson).toList(),
      tips: _toStringList(json['tips']),
      budgetBreakdown: json['budgetBreakdown'] is Map<String, dynamic>
          ? BudgetBreakdownDto.fromJson(json['budgetBreakdown'] as Map<String, dynamic>)
          : BudgetBreakdownDto.empty(),
    );
  }

  /// 转换为领域实体
  TravelPlan toDomain() {
    return TravelPlan(
      id: id,
      destination: Destination(
        cityId: cityId,
        cityName: cityName,
        cityImage: cityImage,
      ),
      metadata: PlanMetadata(
        createdAt: DateTime.parse(createdAt),
        duration: duration,
        budgetLevel: BudgetLevel.fromString(budget),
        style: TravelStyle.fromString(travelStyle),
        interests: interests,
      ),
      transportation: transportation.toDomain(),
      accommodation: accommodation.toDomain(),
      dailyItineraries: dailyItineraries.map((e) => e.toDomain()).toList(),
      attractions: attractions.map((e) => e.toDomain()).toList(),
      restaurants: restaurants.map((e) => e.toDomain()).toList(),
      tips: tips,
      budget: budgetBreakdown.toDomain(),
      status: PlanStatus.planning, // 默认状态
      departureLocation: departureLocation,
      departureDate: departureDate != null ? DateTime.tryParse(departureDate!) : null,
    );
  }
}

/// TransportationPlan DTO - 交通计划
class TransportationPlanDto {
  final String arrivalMethod; // 到达方式
  final String arrivalDetails;
  final double estimatedCost;
  final String localTransport; // 当地交通方式
  final String localTransportDetails;
  final double dailyTransportCost;

  TransportationPlanDto({
    required this.arrivalMethod,
    required this.arrivalDetails,
    required this.estimatedCost,
    required this.localTransport,
    required this.localTransportDetails,
    required this.dailyTransportCost,
  });

  factory TransportationPlanDto.empty() {
    return TransportationPlanDto(
      arrivalMethod: '',
      arrivalDetails: '',
      estimatedCost: 0,
      localTransport: '',
      localTransportDetails: '',
      dailyTransportCost: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arrivalMethod': arrivalMethod,
      'arrivalDetails': arrivalDetails,
      'estimatedCost': estimatedCost,
      'localTransport': localTransport,
      'localTransportDetails': localTransportDetails,
      'dailyTransportCost': dailyTransportCost,
    };
  }

  factory TransportationPlanDto.fromJson(Map<String, dynamic> json) {
    return TransportationPlanDto(
      arrivalMethod: json['arrivalMethod']?.toString() ?? '',
      arrivalDetails: json['arrivalDetails']?.toString() ?? '',
      estimatedCost: _toDouble(json['estimatedCost']),
      localTransport: json['localTransport']?.toString() ?? '',
      localTransportDetails: json['localTransportDetails']?.toString() ?? '',
      dailyTransportCost: _toDouble(json['dailyTransportCost']),
    );
  }

  TripTransportation toDomain() {
    return TripTransportation(
      arrival: ArrivalPlan(
        method: arrivalMethod,
        details: arrivalDetails,
        estimatedCost: estimatedCost,
      ),
      localTransport: LocalTransportPlan(
        method: localTransport,
        details: localTransportDetails,
        dailyCost: dailyTransportCost,
      ),
    );
  }
}

/// AccommodationPlan DTO - 住宿计划
class AccommodationPlanDto {
  final String type; // hostel, hotel, apartment, etc.
  final String recommendation;
  final String area; // 推荐区域
  final double pricePerNight;
  final List<String> amenities;
  final String bookingTips;

  AccommodationPlanDto({
    required this.type,
    required this.recommendation,
    required this.area,
    required this.pricePerNight,
    required this.amenities,
    required this.bookingTips,
  });

  factory AccommodationPlanDto.empty() {
    return AccommodationPlanDto(
      type: '',
      recommendation: '',
      area: '',
      pricePerNight: 0,
      amenities: const [],
      bookingTips: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'recommendation': recommendation,
      'area': area,
      'pricePerNight': pricePerNight,
      'amenities': amenities,
      'bookingTips': bookingTips,
    };
  }

  factory AccommodationPlanDto.fromJson(Map<String, dynamic> json) {
    return AccommodationPlanDto(
      type: json['type']?.toString() ?? '',
      recommendation: json['recommendation']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      pricePerNight: _toDouble(json['pricePerNight']),
      amenities: _toStringList(json['amenities']),
      bookingTips: json['bookingTips']?.toString() ?? '',
    );
  }

  TripAccommodation toDomain() {
    return TripAccommodation(
      type: AccommodationType.fromString(type),
      recommendation: recommendation,
      recommendedArea: area,
      pricePerNight: pricePerNight,
      amenities: amenities,
      bookingTips: bookingTips,
    );
  }
}

/// DailyItinerary DTO - 每日行程
class DailyItineraryDto {
  final int day;
  final String theme;
  final List<ActivityDto> activities;
  final String notes;

  DailyItineraryDto({
    required this.day,
    required this.theme,
    required this.activities,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'theme': theme,
      'activities': activities.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory DailyItineraryDto.fromJson(Map<String, dynamic> json) {
    return DailyItineraryDto(
      day: _toInt(json['day']),
      theme: json['theme']?.toString() ?? '',
      activities: _toMapList(json['activities']).map(ActivityDto.fromJson).toList(),
      notes: json['notes']?.toString() ?? '',
    );
  }

  DailyItinerary toDomain() {
    return DailyItinerary(
      day: day,
      theme: theme,
      activities: activities.map((e) => e.toDomain()).toList(),
      notes: notes,
    );
  }
}

/// Activity DTO - 活动
class ActivityDto {
  final String time;
  final String name;
  final String description;
  final String location;
  final double estimatedCost;
  final int duration; // 分钟

  ActivityDto({
    required this.time,
    required this.name,
    required this.description,
    required this.location,
    required this.estimatedCost,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'name': name,
      'description': description,
      'location': location,
      'estimatedCost': estimatedCost,
      'duration': duration,
    };
  }

  factory ActivityDto.fromJson(Map<String, dynamic> json) {
    return ActivityDto(
      time: json['time']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      estimatedCost: _toDouble(json['estimatedCost']),
      duration: _toInt(json['duration']),
    );
  }

  PlannedActivity toDomain() {
    return PlannedActivity(
      time: time,
      name: name,
      description: description,
      location: location,
      estimatedCost: estimatedCost,
      duration: duration,
    );
  }
}

/// Attraction DTO - 景点
class AttractionDto {
  final String name;
  final String description;
  final String category;
  final double rating;
  final String location;
  final double entryFee;
  final String bestTime;
  final String image;

  AttractionDto({
    required this.name,
    required this.description,
    required this.category,
    required this.rating,
    required this.location,
    required this.entryFee,
    required this.bestTime,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'rating': rating,
      'location': location,
      'entryFee': entryFee,
      'bestTime': bestTime,
      'image': image,
    };
  }

  factory AttractionDto.fromJson(Map<String, dynamic> json) {
    return AttractionDto(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      rating: _toDouble(json['rating']),
      location: json['location']?.toString() ?? '',
      entryFee: _toDouble(json['entryFee']),
      bestTime: json['bestTime']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  AttractionRecommendation toDomain() {
    return AttractionRecommendation(
      name: name,
      description: description,
      category: category,
      rating: rating,
      location: location,
      entryFee: entryFee,
      bestTime: bestTime,
      image: image,
    );
  }
}

/// Restaurant DTO - 餐厅
class RestaurantDto {
  final String name;
  final String cuisine;
  final String description;
  final double rating;
  final String priceRange;
  final String location;
  final String specialty;
  final String image;

  RestaurantDto({
    required this.name,
    required this.cuisine,
    required this.description,
    required this.rating,
    required this.priceRange,
    required this.location,
    required this.specialty,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cuisine': cuisine,
      'description': description,
      'rating': rating,
      'priceRange': priceRange,
      'location': location,
      'specialty': specialty,
      'image': image,
    };
  }

  factory RestaurantDto.fromJson(Map<String, dynamic> json) {
    return RestaurantDto(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cuisine: json['cuisine']?.toString() ?? '',
      rating: _toDouble(json['rating']),
      priceRange: json['priceRange']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  RestaurantRecommendation toDomain() {
    return RestaurantRecommendation(
      name: name,
      cuisine: cuisine,
      description: description,
      rating: rating,
      priceRange: PriceRange.fromString(priceRange),
      location: location,
      specialty: specialty,
      image: image,
    );
  }
}

/// BudgetBreakdown DTO - 预算明细
class BudgetBreakdownDto {
  final double transportation;
  final double accommodation;
  final double food;
  final double activities;
  final double miscellaneous;
  final double total;
  final String currency;

  BudgetBreakdownDto({
    required this.transportation,
    required this.accommodation,
    required this.food,
    required this.activities,
    required this.miscellaneous,
    required this.total,
    this.currency = 'USD',
  });

  factory BudgetBreakdownDto.empty() {
    return BudgetBreakdownDto(
      transportation: 0,
      accommodation: 0,
      food: 0,
      activities: 0,
      miscellaneous: 0,
      total: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transportation': transportation,
      'accommodation': accommodation,
      'food': food,
      'activities': activities,
      'miscellaneous': miscellaneous,
      'total': total,
      'currency': currency,
    };
  }

  factory BudgetBreakdownDto.fromJson(Map<String, dynamic> json) {
    return BudgetBreakdownDto(
      transportation: _toDouble(json['transportation']),
      accommodation: _toDouble(json['accommodation']),
      food: _toDouble(json['food']),
      activities: _toDouble(json['activities']),
      miscellaneous: _toDouble(json['miscellaneous']),
      total: _toDouble(json['total']),
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  TripBudget toDomain() {
    return TripBudget(
      transportation: transportation,
      accommodation: accommodation,
      food: food,
      activities: activities,
      miscellaneous: miscellaneous,
      currency: currency,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? 0;
  }

  return 0;
}

String _toDateTimeString(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }

  if (value is DateTime) {
    return value.toIso8601String();
  }

  return DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.where((item) => item != null).map((item) => item.toString()).toList();
  }

  return const [];
}

List<Map<String, dynamic>> _toMapList(dynamic value) {
  if (value is List) {
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  return const [];
}
