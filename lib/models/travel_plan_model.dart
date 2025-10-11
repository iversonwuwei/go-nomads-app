// 旅行计划模型

/// 旅行计划
class TravelPlan {
  final String id;
  final String cityId;
  final String cityName;
  final String cityImage;
  final DateTime createdAt;
  final int duration; // 旅行天数
  final String budget; // 预算等级: low, medium, high
  final String travelStyle; // 旅行风格: adventure, relaxation, culture, nightlife
  final List<String> interests; // 兴趣标签

  // 计划详情
  final TransportationPlan transportation;
  final AccommodationPlan accommodation;
  final List<DailyItinerary> dailyItineraries;
  final List<Attraction> attractions;
  final List<Restaurant> restaurants;
  final List<String> tips;
  final BudgetBreakdown budgetBreakdown;

  TravelPlan({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.cityImage,
    required this.createdAt,
    required this.duration,
    required this.budget,
    required this.travelStyle,
    required this.interests,
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
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'budget': budget,
      'travelStyle': travelStyle,
      'interests': interests,
      'transportation': transportation.toJson(),
      'accommodation': accommodation.toJson(),
      'dailyItineraries': dailyItineraries.map((e) => e.toJson()).toList(),
      'attractions': attractions.map((e) => e.toJson()).toList(),
      'restaurants': restaurants.map((e) => e.toJson()).toList(),
      'tips': tips,
      'budgetBreakdown': budgetBreakdown.toJson(),
    };
  }

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      cityImage: json['cityImage'],
      createdAt: DateTime.parse(json['createdAt']),
      duration: json['duration'],
      budget: json['budget'],
      travelStyle: json['travelStyle'],
      interests: List<String>.from(json['interests']),
      transportation: TransportationPlan.fromJson(json['transportation']),
      accommodation: AccommodationPlan.fromJson(json['accommodation']),
      dailyItineraries: (json['dailyItineraries'] as List)
          .map((e) => DailyItinerary.fromJson(e))
          .toList(),
      attractions: (json['attractions'] as List)
          .map((e) => Attraction.fromJson(e))
          .toList(),
      restaurants: (json['restaurants'] as List)
          .map((e) => Restaurant.fromJson(e))
          .toList(),
      tips: List<String>.from(json['tips']),
      budgetBreakdown: BudgetBreakdown.fromJson(json['budgetBreakdown']),
    );
  }
}

/// 交通计划
class TransportationPlan {
  final String arrivalMethod; // 到达方式
  final String arrivalDetails;
  final double estimatedCost;
  final String localTransport; // 当地交通方式
  final String localTransportDetails;
  final double dailyTransportCost;

  TransportationPlan({
    required this.arrivalMethod,
    required this.arrivalDetails,
    required this.estimatedCost,
    required this.localTransport,
    required this.localTransportDetails,
    required this.dailyTransportCost,
  });

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

  factory TransportationPlan.fromJson(Map<String, dynamic> json) {
    return TransportationPlan(
      arrivalMethod: json['arrivalMethod'],
      arrivalDetails: json['arrivalDetails'],
      estimatedCost: json['estimatedCost'].toDouble(),
      localTransport: json['localTransport'],
      localTransportDetails: json['localTransportDetails'],
      dailyTransportCost: json['dailyTransportCost'].toDouble(),
    );
  }
}

/// 住宿计划
class AccommodationPlan {
  final String type; // hostel, hotel, apartment, etc.
  final String recommendation;
  final String area; // 推荐区域
  final double pricePerNight;
  final List<String> amenities;
  final String bookingTips;

  AccommodationPlan({
    required this.type,
    required this.recommendation,
    required this.area,
    required this.pricePerNight,
    required this.amenities,
    required this.bookingTips,
  });

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

  factory AccommodationPlan.fromJson(Map<String, dynamic> json) {
    return AccommodationPlan(
      type: json['type'],
      recommendation: json['recommendation'],
      area: json['area'],
      pricePerNight: json['pricePerNight'].toDouble(),
      amenities: List<String>.from(json['amenities']),
      bookingTips: json['bookingTips'],
    );
  }
}

/// 每日行程
class DailyItinerary {
  final int day;
  final String theme;
  final List<Activity> activities;
  final String notes;

  DailyItinerary({
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

  factory DailyItinerary.fromJson(Map<String, dynamic> json) {
    return DailyItinerary(
      day: json['day'],
      theme: json['theme'],
      activities: (json['activities'] as List)
          .map((e) => Activity.fromJson(e))
          .toList(),
      notes: json['notes'],
    );
  }
}

/// 活动
class Activity {
  final String time;
  final String name;
  final String description;
  final String location;
  final double estimatedCost;
  final int duration; // 分钟

  Activity({
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

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      time: json['time'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      estimatedCost: json['estimatedCost'].toDouble(),
      duration: json['duration'],
    );
  }
}

/// 景点
class Attraction {
  final String name;
  final String description;
  final String category;
  final double rating;
  final String location;
  final double entryFee;
  final String bestTime;
  final String image;

  Attraction({
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

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      name: json['name'],
      description: json['description'],
      category: json['category'],
      rating: json['rating'].toDouble(),
      location: json['location'],
      entryFee: json['entryFee'].toDouble(),
      bestTime: json['bestTime'],
      image: json['image'],
    );
  }
}

/// 餐厅
class Restaurant {
  final String name;
  final String cuisine;
  final String description;
  final double rating;
  final String priceRange;
  final String location;
  final String specialty;
  final String image;

  Restaurant({
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

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      description: json['description'],
      cuisine: json['cuisine'],
      rating: json['rating'].toDouble(),
      priceRange: json['priceRange'],
      location: json['location'],
      specialty: json['specialty'],
      image: json['image'],
    );
  }
}

/// 预算明细
class BudgetBreakdown {
  final double transportation;
  final double accommodation;
  final double food;
  final double activities;
  final double miscellaneous;
  final double total;
  final String currency;

  BudgetBreakdown({
    required this.transportation,
    required this.accommodation,
    required this.food,
    required this.activities,
    required this.miscellaneous,
    required this.total,
    this.currency = 'USD',
  });

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

  factory BudgetBreakdown.fromJson(Map<String, dynamic> json) {
    return BudgetBreakdown(
      transportation: json['transportation'].toDouble(),
      accommodation: json['accommodation'].toDouble(),
      food: json['food'].toDouble(),
      activities: json['activities'].toDouble(),
      miscellaneous: json['miscellaneous'].toDouble(),
      total: json['total'].toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }
}
