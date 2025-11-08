// Legacy model import removed - model no longer exists
// import '../../../../models/city_detail_model.dart' as legacy;
import '../../domain/entities/city_detail.dart' as entity;

// ============================================================
// 绫诲瀷鍒悕 - 鐢ㄤ簬鍚戝悗鍏煎鏃т唬鐮?
// ============================================================
// ============================================================
// 类型别名 - 用于向后兼容旧代码
// ============================================================
typedef CityScores = CityScoresDto;
typedef ProsCons = ProsConsDto;
typedef CityReview = CityReviewDto;
typedef CostOfLiving = CostOfLivingDto;
typedef CityPhoto = CityPhotoDto;
typedef TrendPoint = TrendPointDto;
typedef TrendsData = TrendsDataDto;
typedef Demographics = DemographicsDto;
typedef Neighborhood = NeighborhoodDto;
typedef CoworkingSpace = CoworkingSpaceDto;
typedef CityVideo = CityVideoDto;
typedef VisaInfo = VisaInfoDto;
typedef BestArea = BestAreaDto;
typedef NearbyCity = NearbyCityDto;
typedef DigitalNomadGuide = DigitalNomadGuideDto;

/// 鍩庡競璇勫垎璇︾粏鏁版嵁浼犺緭瀵硅薄
class CityScoresDto {
  final double overall;
  final double qualityOfLife;
  final double familyScore;
  final double communityScore;
  final double safetyScore;
  final double womenSafety;
  final double lgbtqSafety;
  final double funScore;
  final double walkability;
  final double nightlife;
  final double friendlyToForeigners;
  final double englishSpeaking;
  final double foodSafety;
  final double lackOfCrime;
  final double lackOfRacism;
  final double educationLevel;
  final double powerGrid;
  final double climateVulnerability;
  final double trafficSafety;
  final double airlineScore;
  final double lostLuggage;
  final double hospitals;
  final double happiness;
  final double freeWiFi;
  final double placesToWork;
  final double acHeating;
  final double freedomOfSpeech;
  final double startupScore;

  CityScoresDto({
    required this.overall,
    required this.qualityOfLife,
    required this.familyScore,
    required this.communityScore,
    required this.safetyScore,
    required this.womenSafety,
    required this.lgbtqSafety,
    required this.funScore,
    required this.walkability,
    required this.nightlife,
    required this.friendlyToForeigners,
    required this.englishSpeaking,
    required this.foodSafety,
    required this.lackOfCrime,
    required this.lackOfRacism,
    required this.educationLevel,
    required this.powerGrid,
    required this.climateVulnerability,
    required this.trafficSafety,
    required this.airlineScore,
    required this.lostLuggage,
    required this.hospitals,
    required this.happiness,
    required this.freeWiFi,
    required this.placesToWork,
    required this.acHeating,
    required this.freedomOfSpeech,
    required this.startupScore,
  });

  factory CityScoresDto.fromJson(Map<String, dynamic> json) {
    return CityScoresDto(
      overall: (json['overall'] as num).toDouble(),
      qualityOfLife: (json['qualityOfLife'] as num).toDouble(),
      familyScore: (json['familyScore'] as num).toDouble(),
      communityScore: (json['communityScore'] as num).toDouble(),
      safetyScore: (json['safetyScore'] as num).toDouble(),
      womenSafety: (json['womenSafety'] as num).toDouble(),
      lgbtqSafety: (json['lgbtqSafety'] as num).toDouble(),
      funScore: (json['funScore'] as num).toDouble(),
      walkability: (json['walkability'] as num).toDouble(),
      nightlife: (json['nightlife'] as num).toDouble(),
      friendlyToForeigners: (json['friendlyToForeigners'] as num).toDouble(),
      englishSpeaking: (json['englishSpeaking'] as num).toDouble(),
      foodSafety: (json['foodSafety'] as num).toDouble(),
      lackOfCrime: (json['lackOfCrime'] as num).toDouble(),
      lackOfRacism: (json['lackOfRacism'] as num).toDouble(),
      educationLevel: (json['educationLevel'] as num).toDouble(),
      powerGrid: (json['powerGrid'] as num).toDouble(),
      climateVulnerability: (json['climateVulnerability'] as num).toDouble(),
      trafficSafety: (json['trafficSafety'] as num).toDouble(),
      airlineScore: (json['airlineScore'] as num).toDouble(),
      lostLuggage: (json['lostLuggage'] as num).toDouble(),
      hospitals: (json['hospitals'] as num).toDouble(),
      happiness: (json['happiness'] as num).toDouble(),
      freeWiFi: (json['freeWiFi'] as num).toDouble(),
      placesToWork: (json['placesToWork'] as num).toDouble(),
      acHeating: (json['acHeating'] as num).toDouble(),
      freedomOfSpeech: (json['freedomOfSpeech'] as num).toDouble(),
      startupScore: (json['startupScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'qualityOfLife': qualityOfLife,
      'familyScore': familyScore,
      'communityScore': communityScore,
      'safetyScore': safetyScore,
      'womenSafety': womenSafety,
      'lgbtqSafety': lgbtqSafety,
      'funScore': funScore,
      'walkability': walkability,
      'nightlife': nightlife,
      'friendlyToForeigners': friendlyToForeigners,
      'englishSpeaking': englishSpeaking,
      'foodSafety': foodSafety,
      'lackOfCrime': lackOfCrime,
      'lackOfRacism': lackOfRacism,
      'educationLevel': educationLevel,
      'powerGrid': powerGrid,
      'climateVulnerability': climateVulnerability,
      'trafficSafety': trafficSafety,
      'airlineScore': airlineScore,
      'lostLuggage': lostLuggage,
      'hospitals': hospitals,
      'happiness': happiness,
      'freeWiFi': freeWiFi,
      'placesToWork': placesToWork,
      'acHeating': acHeating,
      'freedomOfSpeech': freedomOfSpeech,
      'startupScore': startupScore,
    };
  }

  CityScores toDomain() {
    return CityScores(
      overall: overall,
      qualityOfLife: qualityOfLife,
      familyScore: familyScore,
      communityScore: communityScore,
      safetyScore: safetyScore,
      womenSafety: womenSafety,
      lgbtqSafety: lgbtqSafety,
      funScore: funScore,
      walkability: walkability,
      nightlife: nightlife,
      friendlyToForeigners: friendlyToForeigners,
      englishSpeaking: englishSpeaking,
      foodSafety: foodSafety,
      lackOfCrime: lackOfCrime,
      lackOfRacism: lackOfRacism,
      educationLevel: educationLevel,
      powerGrid: powerGrid,
      climateVulnerability: climateVulnerability,
      trafficSafety: trafficSafety,
      airlineScore: airlineScore,
      lostLuggage: lostLuggage,
      hospitals: hospitals,
      happiness: happiness,
      freeWiFi: freeWiFi,
      placesToWork: placesToWork,
      acHeating: acHeating,
      freedomOfSpeech: freedomOfSpeech,
      startupScore: startupScore,
    );
  }
}

/// 鍩庡競浼樼己鐐规暟鎹紶杈撳璞?
class ProsConsDto {
  final String id;
  final String userId;
  final String cityId;
  final String text;
  final int upvotes;
  final int downvotes;
  final bool isPro;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProsConsDto({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.text,
    required this.upvotes,
    required this.downvotes,
    required this.isPro,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProsConsDto.fromJson(Map<String, dynamic> json) {
    return ProsConsDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      cityId: json['cityId'] as String,
      text: json['text'] as String? ?? '',
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      isPro: json['isPro'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cityId': cityId,
      'text': text,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'isPro': isPro,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  entity.ProsCons toDomain() {
    return entity.ProsCons(
      id: id,
      userId: userId,
      cityId: cityId,
      text: text,
      upvotes: upvotes,
      downvotes: downvotes,
      isPro: isPro,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // 别名方法,向后兼容
  entity.ProsCons toEntity() => toDomain();
}

/// 鍩庡競璇勮鏁版嵁浼犺緭瀵硅薄
class CityReviewDto {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String title;
  final String content;
  final List<String> photos;
  final DateTime visitDate;
  final int stayDuration;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final Map<String, double>? categoryRatings;

  CityReviewDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.title,
    required this.content,
    required this.photos,
    required this.visitDate,
    required this.stayDuration,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.categoryRatings,
  });

  factory CityReviewDto.fromJson(Map<String, dynamic> json) {
    return CityReviewDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      content: json['content'] as String,
      photos: List<String>.from(json['photos'] as List<dynamic>),
      visitDate: DateTime.parse(json['visitDate'] as String),
      stayDuration: json['stayDuration'] as int,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      categoryRatings: json['categoryRatings'] != null
          ? Map<String, double>.from(
              (json['categoryRatings'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'title': title,
      'content': content,
      'photos': photos,
      'visitDate': visitDate.toIso8601String(),
      'stayDuration': stayDuration,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'categoryRatings': categoryRatings,
    };
  }

  CityReview toDomain() {
    return CityReview(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      title: title,
      content: content,
      photos: photos,
      visitDate: visitDate,
      stayDuration: stayDuration,
      likes: likes,
      comments: comments,
      createdAt: createdAt,
      categoryRatings: categoryRatings,
    );
  }
}

/// 鐢熸椿鎴愭湰鏄庣粏鏁版嵁浼犺緭瀵硅薄
class CostOfLivingDto {
  final double total;
  final double accommodation;
  final double food;
  final double transportation;
  final double entertainment;
  final double gym;
  final double coworking;
  final double utilities;
  final double groceries;
  final double diningOut;
  final double? airbnbCost;
  final double? hotelCost;
  final double? apartmentCost;

  CostOfLivingDto({
    required this.total,
    required this.accommodation,
    required this.food,
    required this.transportation,
    required this.entertainment,
    required this.gym,
    required this.coworking,
    required this.utilities,
    required this.groceries,
    required this.diningOut,
    this.airbnbCost,
    this.hotelCost,
    this.apartmentCost,
  });

  factory CostOfLivingDto.fromJson(Map<String, dynamic> json) {
    return CostOfLivingDto(
      total: (json['total'] as num).toDouble(),
      accommodation: (json['accommodation'] as num).toDouble(),
      food: (json['food'] as num).toDouble(),
      transportation: (json['transportation'] as num).toDouble(),
      entertainment: (json['entertainment'] as num).toDouble(),
      gym: (json['gym'] as num).toDouble(),
      coworking: (json['coworking'] as num).toDouble(),
      utilities: (json['utilities'] as num).toDouble(),
      groceries: (json['groceries'] as num).toDouble(),
      diningOut: (json['diningOut'] as num).toDouble(),
      airbnbCost: json['airbnbCost'] != null
          ? (json['airbnbCost'] as num).toDouble()
          : null,
      hotelCost: json['hotelCost'] != null
          ? (json['hotelCost'] as num).toDouble()
          : null,
      apartmentCost: json['apartmentCost'] != null
          ? (json['apartmentCost'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'accommodation': accommodation,
      'food': food,
      'transportation': transportation,
      'entertainment': entertainment,
      'gym': gym,
      'coworking': coworking,
      'utilities': utilities,
      'groceries': groceries,
      'diningOut': diningOut,
      'airbnbCost': airbnbCost,
      'hotelCost': hotelCost,
      'apartmentCost': apartmentCost,
    };
  }

  CostOfLiving toDomain() {
    return CostOfLiving(
      total: total,
      accommodation: accommodation,
      food: food,
      transportation: transportation,
      entertainment: entertainment,
      gym: gym,
      coworking: coworking,
      utilities: utilities,
      groceries: groceries,
      diningOut: diningOut,
      airbnbCost: airbnbCost,
      hotelCost: hotelCost,
      apartmentCost: apartmentCost,
    );
  }
}

/// 鍩庡競鐓х墖鏁版嵁浼犺緭瀵硅薄
class CityPhotoDto {
  final String id;
  final String url;
  final String userId;
  final String userName;
  final String? caption;
  final String? location;
  final int likes;
  final DateTime uploadedAt;

  CityPhotoDto({
    required this.id,
    required this.url,
    required this.userId,
    required this.userName,
    this.caption,
    this.location,
    required this.likes,
    required this.uploadedAt,
  });

  factory CityPhotoDto.fromJson(Map<String, dynamic> json) {
    return CityPhotoDto(
      id: json['id'] as String,
      url: json['url'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      caption: json['caption'] as String?,
      location: json['location'] as String?,
      likes: json['likes'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'userId': userId,
      'userName': userName,
      'caption': caption,
      'location': location,
      'likes': likes,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  CityPhoto toDomain() {
    return CityPhoto(
      id: id,
      url: url,
      userId: userId,
      userName: userName,
      caption: caption,
      location: location,
      likes: likes,
      uploadedAt: uploadedAt,
    );
  }
}

/// 瓒嬪娍鏁版嵁鐐规暟鎹紶杈撳璞?
class TrendPointDto {
  final DateTime date;
  final double value;

  TrendPointDto({
    required this.date,
    required this.value,
  });

  factory TrendPointDto.fromJson(Map<String, dynamic> json) {
    return TrendPointDto(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  TrendPoint toDomain() {
    return TrendPoint(
      date: date,
      value: value,
    );
  }
}

/// 瓒嬪娍鏁版嵁鏁版嵁浼犺緭瀵硅薄
class TrendsDataDto {
  final List<TrendPointDto> visitTrend;
  final List<TrendPointDto> scoreTrend;
  final List<TrendPointDto> costTrend;
  final List<TrendPointDto> popularityTrend;

  TrendsDataDto({
    required this.visitTrend,
    required this.scoreTrend,
    required this.costTrend,
    required this.popularityTrend,
  });

  factory TrendsDataDto.fromJson(Map<String, dynamic> json) {
    return TrendsDataDto(
      visitTrend: (json['visitTrend'] as List<dynamic>)
          .map((e) => TrendPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      scoreTrend: (json['scoreTrend'] as List<dynamic>)
          .map((e) => TrendPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      costTrend: (json['costTrend'] as List<dynamic>)
          .map((e) => TrendPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularityTrend: (json['popularityTrend'] as List<dynamic>)
          .map((e) => TrendPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitTrend': visitTrend.map((e) => e.toJson()).toList(),
      'scoreTrend': scoreTrend.map((e) => e.toJson()).toList(),
      'costTrend': costTrend.map((e) => e.toJson()).toList(),
      'popularityTrend': popularityTrend.map((e) => e.toJson()).toList(),
    };
  }

  TrendsData toDomain() {
    return TrendsData(
      visitTrend: visitTrend.map((e) => e.toDomain()).toList(),
      scoreTrend: scoreTrend.map((e) => e.toDomain()).toList(),
      costTrend: costTrend.map((e) => e.toDomain()).toList(),
      popularityTrend: popularityTrend.map((e) => e.toDomain()).toList(),
    );
  }
}

/// 浜哄彛缁熻鏁版嵁浼犺緭瀵硅薄
class DemographicsDto {
  final int population;
  final int populationDensity;
  final double foreignerPercentage;
  final int digitalNomadCount;
  final Map<String, double> ageDistribution;
  final double malePercentage;
  final double femalePercentage;
  final String educationLevel;

  DemographicsDto({
    required this.population,
    required this.populationDensity,
    required this.foreignerPercentage,
    required this.digitalNomadCount,
    required this.ageDistribution,
    required this.malePercentage,
    required this.femalePercentage,
    required this.educationLevel,
  });

  factory DemographicsDto.fromJson(Map<String, dynamic> json) {
    return DemographicsDto(
      population: json['population'] as int,
      populationDensity: json['populationDensity'] as int,
      foreignerPercentage: (json['foreignerPercentage'] as num).toDouble(),
      digitalNomadCount: json['digitalNomadCount'] as int,
      ageDistribution: Map<String, double>.from(
        (json['ageDistribution'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      malePercentage: (json['malePercentage'] as num).toDouble(),
      femalePercentage: (json['femalePercentage'] as num).toDouble(),
      educationLevel: json['educationLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'population': population,
      'populationDensity': populationDensity,
      'foreignerPercentage': foreignerPercentage,
      'digitalNomadCount': digitalNomadCount,
      'ageDistribution': ageDistribution,
      'malePercentage': malePercentage,
      'femalePercentage': femalePercentage,
      'educationLevel': educationLevel,
    };
  }

  Demographics toDomain() {
    return Demographics(
      population: population,
      populationDensity: populationDensity,
      foreignerPercentage: foreignerPercentage,
      digitalNomadCount: digitalNomadCount,
      ageDistribution: ageDistribution,
      malePercentage: malePercentage,
      femalePercentage: femalePercentage,
      educationLevel: educationLevel,
    );
  }
}

/// 绀惧尯/鍖哄煙鏁版嵁浼犺緭瀵硅薄
class NeighborhoodDto {
  final String id;
  final String name;
  final String description;
  final double safetyScore;
  final double rentPrice;
  final double nightlifeScore;
  final List<String> amenities;
  final String imageUrl;
  final Map<String, bool> features;

  NeighborhoodDto({
    required this.id,
    required this.name,
    required this.description,
    required this.safetyScore,
    required this.rentPrice,
    required this.nightlifeScore,
    required this.amenities,
    required this.imageUrl,
    required this.features,
  });

  factory NeighborhoodDto.fromJson(Map<String, dynamic> json) {
    return NeighborhoodDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      safetyScore: (json['safetyScore'] as num).toDouble(),
      rentPrice: (json['rentPrice'] as num).toDouble(),
      nightlifeScore: (json['nightlifeScore'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List<dynamic>),
      imageUrl: json['imageUrl'] as String,
      features:
          Map<String, bool>.from(json['features'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'safetyScore': safetyScore,
      'rentPrice': rentPrice,
      'nightlifeScore': nightlifeScore,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'features': features,
    };
  }

  Neighborhood toDomain() {
    return Neighborhood(
      id: id,
      name: name,
      description: description,
      safetyScore: safetyScore,
      rentPrice: rentPrice,
      nightlifeScore: nightlifeScore,
      amenities: amenities,
      imageUrl: imageUrl,
      features: features,
    );
  }
}

/// 鍏变韩鍔炲叕绌洪棿鏁版嵁浼犺緭瀵硅薄
class CoworkingSpaceDto {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final double price;
  final double internetSpeed;
  final List<String> amenities;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String? websiteUrl;

  CoworkingSpaceDto({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.internetSpeed,
    required this.amenities,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.websiteUrl,
  });

  factory CoworkingSpaceDto.fromJson(Map<String, dynamic> json) {
    return CoworkingSpaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      price: (json['price'] as num).toDouble(),
      internetSpeed: (json['internetSpeed'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List<dynamic>),
      imageUrl: json['imageUrl'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      websiteUrl: json['websiteUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'price': price,
      'internetSpeed': internetSpeed,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'websiteUrl': websiteUrl,
    };
  }

  CoworkingSpace toDomain() {
    return CoworkingSpace(
      id: id,
      name: name,
      address: address,
      rating: rating,
      reviewCount: reviewCount,
      price: price,
      internetSpeed: internetSpeed,
      amenities: amenities,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      websiteUrl: websiteUrl,
    );
  }
}

/// 鍩庡競瑙嗛鏁版嵁浼犺緭瀵硅薄
class CityVideoDto {
  final String id;
  final String title;
  final String thumbnail;
  final String videoUrl;
  final String uploaderId;
  final String uploaderName;
  final int views;
  final int likes;
  final DateTime uploadedAt;
  final int duration;

  CityVideoDto({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    required this.uploaderId,
    required this.uploaderName,
    required this.views,
    required this.likes,
    required this.uploadedAt,
    required this.duration,
  });

  factory CityVideoDto.fromJson(Map<String, dynamic> json) {
    return CityVideoDto(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String,
      videoUrl: json['videoUrl'] as String,
      uploaderId: json['uploaderId'] as String,
      uploaderName: json['uploaderName'] as String,
      views: json['views'] as int,
      likes: json['likes'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'videoUrl': videoUrl,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'views': views,
      'likes': likes,
      'uploadedAt': uploadedAt.toIso8601String(),
      'duration': duration,
    };
  }

  CityVideo toDomain() {
    return CityVideo(
      id: id,
      title: title,
      thumbnail: thumbnail,
      videoUrl: videoUrl,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      views: views,
      likes: likes,
      uploadedAt: uploadedAt,
      duration: duration,
    );
  }
}

/// 绛捐瘉淇℃伅鏁版嵁浼犺緭瀵硅薄
class VisaInfoDto {
  final String type;
  final int duration;
  final String requirements;
  final double cost;
  final String process;

  VisaInfoDto({
    required this.type,
    required this.duration,
    required this.requirements,
    required this.cost,
    required this.process,
  });

  factory VisaInfoDto.fromJson(Map<String, dynamic> json) {
    // Support both PascalCase (C# backend) and camelCase (Dart frontend)
    return VisaInfoDto(
      type: json['Type'] ?? json['type'] ?? '',
      duration: json['Duration'] ?? json['duration'] ?? 0,
      requirements: json['Requirements'] ?? json['requirements'] ?? '',
      cost: ((json['Cost'] ?? json['cost']) ?? 0).toDouble(),
      process: json['Process'] ?? json['process'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration': duration,
      'requirements': requirements,
      'cost': cost,
      'process': process,
    };
  }

  VisaInfo toDomain() {
    return VisaInfo(
      type: type,
      duration: duration,
      requirements: requirements,
      cost: cost,
      process: process,
    );
  }
}

/// 鏈€浣冲尯鍩熸帹鑽愭暟鎹紶杈撳璞?
class BestAreaDto {
  final String name;
  final String description;
  final double entertainmentScore;
  final String entertainmentDescription;
  final double tourismScore;
  final String tourismDescription;
  final double economyScore;
  final String economyDescription;
  final double cultureScore;
  final String cultureDescription;

  BestAreaDto({
    required this.name,
    required this.description,
    required this.entertainmentScore,
    required this.entertainmentDescription,
    required this.tourismScore,
    required this.tourismDescription,
    required this.economyScore,
    required this.economyDescription,
    required this.cultureScore,
    required this.cultureDescription,
  });

  factory BestAreaDto.fromJson(Map<String, dynamic> json) {
    // Support both PascalCase (C# backend) and camelCase (Dart frontend)
    return BestAreaDto(
      name: json['Name'] ?? json['name'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      entertainmentScore:
          ((json['EntertainmentScore'] ?? json['entertainmentScore']) ?? 0)
              .toDouble(),
      entertainmentDescription: json['EntertainmentDescription'] ??
          json['entertainmentDescription'] ??
          '',
      tourismScore:
          ((json['TourismScore'] ?? json['tourismScore']) ?? 0).toDouble(),
      tourismDescription:
          json['TourismDescription'] ?? json['tourismDescription'] ?? '',
      economyScore:
          ((json['EconomyScore'] ?? json['economyScore']) ?? 0).toDouble(),
      economyDescription:
          json['EconomyDescription'] ?? json['economyDescription'] ?? '',
      cultureScore:
          ((json['CultureScore'] ?? json['cultureScore']) ?? 0).toDouble(),
      cultureDescription:
          json['CultureDescription'] ?? json['cultureDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'entertainmentScore': entertainmentScore,
      'entertainmentDescription': entertainmentDescription,
      'tourismScore': tourismScore,
      'tourismDescription': tourismDescription,
      'economyScore': economyScore,
      'economyDescription': economyDescription,
      'cultureScore': cultureScore,
      'cultureDescription': cultureDescription,
    };
  }

  BestArea toDomain() {
    return BestArea(
      name: name,
      description: description,
      entertainmentScore: entertainmentScore,
      entertainmentDescription: entertainmentDescription,
      tourismScore: tourismScore,
      tourismDescription: tourismDescription,
      economyScore: economyScore,
      economyDescription: economyDescription,
      cultureScore: cultureScore,
      cultureDescription: cultureDescription,
    );
  }
}

/// 鏁板瓧娓告皯鎸囧崡鏁版嵁浼犺緭瀵硅薄
class DigitalNomadGuideDto {
  final String cityId;
  final String cityName;
  final String overview;
  final VisaInfoDto visaInfo;
  final List<BestAreaDto> bestAreas;
  final List<String> workspaceRecommendations;
  final List<String> tips;
  final Map<String, String> essentialInfo;

  DigitalNomadGuideDto({
    required this.cityId,
    required this.cityName,
    required this.overview,
    required this.visaInfo,
    required this.bestAreas,
    required this.workspaceRecommendations,
    required this.tips,
    required this.essentialInfo,
  });

  factory DigitalNomadGuideDto.fromJson(Map<String, dynamic> json) {
    // Support both PascalCase (C# backend) and camelCase (Dart frontend)
    return DigitalNomadGuideDto(
      cityId: json['CityId'] ?? json['cityId'] ?? '',
      cityName: json['CityName'] ?? json['cityName'] ?? '',
      overview: json['Overview'] ?? json['overview'] ?? '',
      visaInfo:
          VisaInfoDto.fromJson(json['VisaInfo'] ?? json['visaInfo'] ?? {}),
      bestAreas: ((json['BestAreas'] ?? json['bestAreas']) as List<dynamic>?)
              ?.map(
                  (area) => BestAreaDto.fromJson(area as Map<String, dynamic>))
              .toList() ??
          [],
      workspaceRecommendations: List<String>.from(
          json['WorkspaceRecommendations'] ??
              json['workspaceRecommendations'] ??
              []),
      tips: List<String>.from(json['Tips'] ?? json['tips'] ?? []),
      essentialInfo: Map<String, String>.from(
          json['EssentialInfo'] ?? json['essentialInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'cityName': cityName,
      'overview': overview,
      'visaInfo': visaInfo.toJson(),
      'bestAreas': bestAreas.map((area) => area.toJson()).toList(),
      'workspaceRecommendations': workspaceRecommendations,
      'tips': tips,
      'essentialInfo': essentialInfo,
    };
  }

  DigitalNomadGuide toDomain() {
    return DigitalNomadGuide(
      cityId: cityId,
      cityName: cityName,
      overview: overview,
      visaInfo: visaInfo.toDomain(),
      bestAreas: bestAreas.map((area) => area.toDomain()).toList(),
      workspaceRecommendations: workspaceRecommendations,
      tips: tips,
      essentialInfo: essentialInfo,
    );
  }
}

/// 闄勮繎鍩庡競鏁版嵁浼犺緭瀵硅薄
class NearbyCityDto {
  final String id;
  final String name;
  final String country;
  final double distance;
  final String transportation;
  final double travelTime;
  final double overallScore;
  final String imageUrl;

  NearbyCityDto({
    required this.id,
    required this.name,
    required this.country,
    required this.distance,
    required this.transportation,
    required this.travelTime,
    required this.overallScore,
    required this.imageUrl,
  });

  factory NearbyCityDto.fromJson(Map<String, dynamic> json) {
    return NearbyCityDto(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      distance: (json['distance'] as num).toDouble(),
      transportation: json['transportation'] as String,
      travelTime: (json['travelTime'] as num).toDouble(),
      overallScore: (json['overallScore'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'distance': distance,
      'transportation': transportation,
      'travelTime': travelTime,
      'overallScore': overallScore,
      'imageUrl': imageUrl,
    };
  }

  NearbyCity toDomain() {
    return NearbyCity(
      id: id,
      name: name,
      country: country,
      distance: distance,
      transportation: transportation,
      travelTime: travelTime,
      overallScore: overallScore,
      imageUrl: imageUrl,
    );
  }
}
