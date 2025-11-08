/// 城市评分详细数据领域实体
class CityScores {
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

  const CityScores({
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

  /// 是否为高质量城市 (overall >= 4.0)
  bool get isHighQuality => overall >= 4.0;

  /// 是否为安全城市 (safety >= 4.0)
  bool get isSafe => safetyScore >= 4.0;

  /// 是否适合女性
  bool get isWomenFriendly => womenSafety >= 4.0;

  /// 是否适合LGBTQ+
  bool get isLgbtqFriendly => lgbtqSafety >= 4.0;

  /// 是否适合远程办公
  bool get isRemoteWorkFriendly => placesToWork >= 4.0 && freeWiFi >= 4.0;

  /// 生活质量评级
  String get qualityTier {
    if (qualityOfLife >= 4.5) return 'excellent';
    if (qualityOfLife >= 4.0) return 'great';
    if (qualityOfLife >= 3.5) return 'good';
    if (qualityOfLife >= 3.0) return 'fair';
    return 'poor';
  }
}

/// 城市优缺点领域实体
class ProsCons {
  final String id;
  final String userId;
  final String cityId;
  final String text;
  final int upvotes;
  final int downvotes;
  final bool isPro;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProsCons({
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

  /// 净投票数
  int get netVotes => upvotes - downvotes;

  /// 是否受欢迎 (net votes > 5)
  bool get isPopular => netVotes > 5;

  /// 是否有争议 (upvotes and downvotes both high)
  bool get isControversial => upvotes > 10 && downvotes > 10;

  /// 投票比率
  double get voteRatio {
    final total = upvotes + downvotes;
    return total > 0 ? upvotes / total : 0.0;
  }
}

/// 城市评论领域实体
class CityReview {
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

  const CityReview({
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

  /// 是否为高评分评论
  bool get isHighRating => rating >= 4.0;

  /// 是否为长期停留
  bool get isLongTermStay => stayDuration >= 30;

  /// 是否为短期访问
  bool get isShortTermVisit => stayDuration < 7;

  /// 是否最近访问 (within 6 months)
  bool get isRecentVisit => DateTime.now().difference(visitDate).inDays <= 180;

  /// 是否有照片
  bool get hasPhotos => photos.isNotEmpty;

  /// 是否受欢迎
  bool get isPopular => likes > 10 || comments > 5;

  /// 参与度评分
  double get engagementScore {
    return (likes * 1.0 + comments * 2.0) / 10.0;
  }
}

/// 生活成本明细领域实体
class CostOfLiving {
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

  const CostOfLiving({
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

  /// 是否为预算友好型城市 (total < 1500)
  bool get isBudgetFriendly => total < 1500;

  /// 是否为昂贵城市 (total > 3000)
  bool get isExpensive => total > 3000;

  /// 成本等级
  String get costTier {
    if (total < 1000) return 'very_low';
    if (total < 1500) return 'low';
    if (total < 2500) return 'medium';
    if (total < 4000) return 'high';
    return 'very_high';
  }

  /// 最便宜的住宿选项价格
  double? get cheapestAccommodation {
    final options =
        [airbnbCost, hotelCost, apartmentCost].whereType<double>().toList();
    return options.isEmpty ? null : options.reduce((a, b) => a < b ? a : b);
  }

  /// 日均成本
  double get dailyCost => total / 30;
}

/// 城市照片领域实体
class CityPhoto {
  final String id;
  final String url;
  final String userId;
  final String userName;
  final String? caption;
  final String? location;
  final int likes;
  final DateTime uploadedAt;

  const CityPhoto({
    required this.id,
    required this.url,
    required this.userId,
    required this.userName,
    this.caption,
    this.location,
    required this.likes,
    required this.uploadedAt,
  });

  /// 是否受欢迎
  bool get isPopular => likes > 20;

  /// 是否最近上传 (within 30 days)
  bool get isRecent => DateTime.now().difference(uploadedAt).inDays <= 30;

  /// 是否有说明
  bool get hasCaption => caption != null && caption!.isNotEmpty;

  /// 是否有位置标记
  bool get hasLocation => location != null && location!.isNotEmpty;
}

/// 趋势数据点领域实体
class TrendPoint {
  final DateTime date;
  final double value;

  const TrendPoint({
    required this.date,
    required this.value,
  });

  /// 是否为最近数据 (within 90 days)
  bool get isRecent => DateTime.now().difference(date).inDays <= 90;
}

/// 趋势数据领域实体
class TrendsData {
  final List<TrendPoint> visitTrend;
  final List<TrendPoint> scoreTrend;
  final List<TrendPoint> costTrend;
  final List<TrendPoint> popularityTrend;

  const TrendsData({
    required this.visitTrend,
    required this.scoreTrend,
    required this.costTrend,
    required this.popularityTrend,
  });

  /// 访问量是否在增长
  bool get isVisitIncreasing {
    if (visitTrend.length < 2) return false;
    final recent = visitTrend.last.value;
    final previous = visitTrend[visitTrend.length - 2].value;
    return recent > previous;
  }

  /// 评分是否在提升
  bool get isScoreImproving {
    if (scoreTrend.length < 2) return false;
    final recent = scoreTrend.last.value;
    final previous = scoreTrend[scoreTrend.length - 2].value;
    return recent > previous;
  }

  /// 成本是否在上升
  bool get isCostRising {
    if (costTrend.length < 2) return false;
    final recent = costTrend.last.value;
    final previous = costTrend[costTrend.length - 2].value;
    return recent > previous;
  }
}

/// 人口统计领域实体
class Demographics {
  final int population;
  final int populationDensity;
  final double foreignerPercentage;
  final int digitalNomadCount;
  final Map<String, double> ageDistribution;
  final double malePercentage;
  final double femalePercentage;
  final String educationLevel;

  const Demographics({
    required this.population,
    required this.populationDensity,
    required this.foreignerPercentage,
    required this.digitalNomadCount,
    required this.ageDistribution,
    required this.malePercentage,
    required this.femalePercentage,
    required this.educationLevel,
  });

  /// 是否为大城市 (population > 1M)
  bool get isMajorCity => population > 1000000;

  /// 是否人口密集
  bool get isDense => populationDensity > 5000;

  /// 是否有大量外国人
  bool get hasLargeForeignerCommunity => foreignerPercentage > 10;

  /// 是否有大量数字游民
  bool get hasLargeNomadCommunity => digitalNomadCount > 1000;

  /// 性别平衡度 (0-1, 1 = perfectly balanced)
  double get genderBalance {
    final diff = (malePercentage - femalePercentage).abs();
    return 1.0 - (diff / 100);
  }
}

/// 社区/区域领域实体
class Neighborhood {
  final String id;
  final String name;
  final String description;
  final double safetyScore;
  final double rentPrice;
  final double nightlifeScore;
  final List<String> amenities;
  final String imageUrl;
  final Map<String, bool> features;

  const Neighborhood({
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

  /// 是否安全
  bool get isSafe => safetyScore >= 4.0;

  /// 是否价格实惠
  bool get isAffordable => rentPrice < 1000;

  /// 是否有夜生活
  bool get hasNightlife => nightlifeScore >= 3.5;

  /// 便利设施数量
  int get amenityCount => amenities.length;

  /// 是否适合步行
  bool get isWalkable => features['walkable'] ?? false;

  /// 是否安静
  bool get isQuiet => features['quiet'] ?? false;

  /// 是否时尚
  bool get isTrendy => features['trendy'] ?? false;
}

/// 共享办公空间领域实体
class CoworkingSpace {
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

  const CoworkingSpace({
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

  /// 是否高评分
  bool get isHighlyRated => rating >= 4.5;

  /// 是否价格实惠
  bool get isAffordable => price < 15;

  /// 是否有快速网络
  bool get hasFastInternet => internetSpeed >= 50;

  /// 是否受欢迎 (many reviews)
  bool get isPopular => reviewCount > 20;

  /// 性价比评分
  double get valueScore {
    if (price == 0) return 0;
    return (rating * internetSpeed) / price;
  }
}

/// 城市视频领域实体
class CityVideo {
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

  const CityVideo({
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

  /// 是否受欢迎
  bool get isPopular => views > 1000;

  /// 是否最近上传 (within 30 days)
  bool get isRecent => DateTime.now().difference(uploadedAt).inDays <= 30;

  /// 喜欢率
  double get likeRate {
    return views > 0 ? likes / views : 0;
  }

  /// 是否为短视频
  bool get isShortVideo => duration < 300; // < 5 minutes

  /// 是否为长视频
  bool get isLongVideo => duration > 1800; // > 30 minutes
}

/// 签证信息领域实体
class VisaInfo {
  final String type;
  final int duration;
  final String requirements;
  final double cost;
  final String process;

  const VisaInfo({
    required this.type,
    required this.duration,
    required this.requirements,
    required this.cost,
    required this.process,
  });

  /// 是否为长期签证 (> 90 days)
  bool get isLongTerm => duration > 90;

  /// 是否免费
  bool get isFree => cost == 0;

  /// 是否为落地签
  bool get isVisaOnArrival =>
      type.toLowerCase().contains('arrival') ||
      type.toLowerCase().contains('落地签');

  /// 是否为电子签
  bool get isEVisa =>
      type.toLowerCase().contains('evisa') ||
      type.toLowerCase().contains('电子签');

  /// 每日成本
  double get dailyCost => duration > 0 ? cost / duration : 0;
}

/// 最佳区域推荐领域实体
class BestArea {
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

  const BestArea({
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

  /// 综合评分
  double get overallScore =>
      (entertainmentScore + tourismScore + (6 - economyScore) + cultureScore) /
      4;

  /// 是否适合娱乐
  bool get isGoodForEntertainment => entertainmentScore >= 4.0;

  /// 是否适合旅游
  bool get isGoodForTourism => tourismScore >= 4.0;

  /// 是否经济实惠 (越低越实惠)
  bool get isAffordable => economyScore <= 2.5;

  /// 是否有文化特色
  bool get hasCulturalValue => cultureScore >= 4.0;

  /// 是否为全能区域 (all scores >= 3.5)
  bool get isAllRounder =>
      entertainmentScore >= 3.5 &&
      tourismScore >= 3.5 &&
      economyScore >= 1.0 &&
      economyScore <= 4.0 &&
      cultureScore >= 3.5;
}

/// 数字游民指南领域实体
class DigitalNomadGuide {
  final String cityId;
  final String cityName;
  final String overview;
  final VisaInfo visaInfo;
  final List<BestArea> bestAreas;
  final List<String> workspaceRecommendations;
  final List<String> tips;
  final Map<String, String> essentialInfo;

  const DigitalNomadGuide({
    required this.cityId,
    required this.cityName,
    required this.overview,
    required this.visaInfo,
    required this.bestAreas,
    required this.workspaceRecommendations,
    required this.tips,
    required this.essentialInfo,
  });

  /// 是否有推荐区域
  bool get hasRecommendedAreas => bestAreas.isNotEmpty;

  /// 是否有工作空间推荐
  bool get hasWorkspaceRecommendations => workspaceRecommendations.isNotEmpty;

  /// 是否有实用提示
  bool get hasTips => tips.isNotEmpty;

  /// 是否为数字游民友好城市
  bool get isNomadFriendly =>
      visaInfo.duration >= 30 && hasWorkspaceRecommendations;

  /// 推荐区域数量
  int get recommendedAreaCount => bestAreas.length;

  /// 最佳区域 (highest overall score)
  BestArea? get topArea {
    if (bestAreas.isEmpty) return null;
    return bestAreas.reduce((a, b) => a.overallScore > b.overallScore ? a : b);
  }
}

/// 附近城市领域实体
class NearbyCity {
  final String id;
  final String name;
  final String country;
  final double distance;
  final String transportation;
  final double travelTime;
  final double overallScore;
  final String imageUrl;

  const NearbyCity({
    required this.id,
    required this.name,
    required this.country,
    required this.distance,
    required this.transportation,
    required this.travelTime,
    required this.overallScore,
    required this.imageUrl,
  });

  /// 是否为近距离 (< 100km)
  bool get isNearby => distance < 100;

  /// 是否为短途旅行 (< 2 hours)
  bool get isShortTrip => travelTime < 2.0;

  /// 是否为当日游
  bool get isDayTrip => isShortTrip && distance < 200;

  /// 是否高评分
  bool get isHighRated => overallScore >= 4.0;

  /// 平均速度 (km/h)
  double get averageSpeed {
    return travelTime > 0 ? distance / travelTime : 0;
  }
}
