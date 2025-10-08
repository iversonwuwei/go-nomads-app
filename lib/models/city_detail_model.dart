// City Detail Models - Nomads.com 城市详情页数据模型

/// 城市评分详细数据
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

  CityScores({
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
}

/// 城市优缺点
class ProsCons {
  final String id;
  final String text;
  final int upvotes;
  final int downvotes;
  final bool isPro; // true = pro, false = con

  ProsCons({
    required this.id,
    required this.text,
    required this.upvotes,
    required this.downvotes,
    required this.isPro,
  });
}

/// 城市评论
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
  final int stayDuration; // days
  final int likes;
  final int comments;
  final DateTime createdAt;
  final Map<String, double>? categoryRatings; // cost, internet, safety, food, community

  CityReview({
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
}

/// 生活成本明细
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
  
  // 住宿选项
  final double? airbnbCost;
  final double? hotelCost;
  final double? apartmentCost;
  
  CostOfLiving({
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
}

/// 天气数据
class WeatherData {
  final double currentTemp;
  final double feelsLike;
  final double humidity;
  final String condition; // sunny, cloudy, rainy, etc.
  final int aqi;
  final List<DailyForecast> forecast;
  final MonthlyClimate monthlyClimate;
  final String bestSeason;

  WeatherData({
    required this.currentTemp,
    required this.feelsLike,
    required this.humidity,
    required this.condition,
    required this.aqi,
    required this.forecast,
    required this.monthlyClimate,
    required this.bestSeason,
  });
}

class DailyForecast {
  final DateTime date;
  final double high;
  final double low;
  final String condition;
  final int precipitation;

  DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.condition,
    required this.precipitation,
  });
}

class MonthlyClimate {
  final Map<String, double> avgTemperature; // month -> temp
  final Map<String, int> rainfall; // month -> mm
  
  MonthlyClimate({
    required this.avgTemperature,
    required this.rainfall,
  });
}

/// 城市照片
class CityPhoto {
  final String id;
  final String url;
  final String userId;
  final String userName;
  final String? caption;
  final String? location; // specific place in city
  final int likes;
  final DateTime uploadedAt;

  CityPhoto({
    required this.id,
    required this.url,
    required this.userId,
    required this.userName,
    this.caption,
    this.location,
    required this.likes,
    required this.uploadedAt,
  });
}

/// 趋势数据
class TrendsData {
  final List<TrendPoint> visitTrend;
  final List<TrendPoint> scoreTrend;
  final List<TrendPoint> costTrend;
  final List<TrendPoint> popularityTrend;

  TrendsData({
    required this.visitTrend,
    required this.scoreTrend,
    required this.costTrend,
    required this.popularityTrend,
  });
}

class TrendPoint {
  final DateTime date;
  final double value;

  TrendPoint({
    required this.date,
    required this.value,
  });
}

/// 人口统计
class Demographics {
  final int population;
  final int populationDensity; // per km²
  final double foreignerPercentage;
  final int digitalNomadCount;
  final Map<String, double> ageDistribution; // age_group -> percentage
  final double malePercentage;
  final double femalePercentage;
  final String educationLevel;

  Demographics({
    required this.population,
    required this.populationDensity,
    required this.foreignerPercentage,
    required this.digitalNomadCount,
    required this.ageDistribution,
    required this.malePercentage,
    required this.femalePercentage,
    required this.educationLevel,
  });
}

/// 社区/区域
class Neighborhood {
  final String id;
  final String name;
  final String description;
  final double safetyScore;
  final double rentPrice; // avg monthly
  final double nightlifeScore;
  final List<String> amenities;
  final String imageUrl;
  final Map<String, bool> features; // walkable, quiet, trendy, etc.

  Neighborhood({
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
}

/// 共享办公空间
class CoworkingSpace {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final double price; // per day
  final double internetSpeed;
  final List<String> amenities;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String? websiteUrl;

  CoworkingSpace({
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
}

/// 城市视频
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
  final int duration; // seconds

  CityVideo({
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
}

/// 数字游民指南
class DigitalNomadGuide {
  final String cityId;
  final String cityName;
  final String overview;
  final VisaInfo visaInfo;
  final List<String> bestAreas;
  final List<String> workspaceRecommendations;
  final List<String> tips;
  final Map<String, String> essentialInfo; // SIM cards, banks, etc.

  DigitalNomadGuide({
    required this.cityId,
    required this.cityName,
    required this.overview,
    required this.visaInfo,
    required this.bestAreas,
    required this.workspaceRecommendations,
    required this.tips,
    required this.essentialInfo,
  });
}

class VisaInfo {
  final String type;
  final int duration; // days
  final String requirements;
  final double cost;
  final String process;

  VisaInfo({
    required this.type,
    required this.duration,
    required this.requirements,
    required this.cost,
    required this.process,
  });
}

/// 附近城市
class NearbyCity {
  final String id;
  final String name;
  final String country;
  final double distance; // km
  final String transportation;
  final double travelTime; // hours
  final double overallScore;
  final String imageUrl;

  NearbyCity({
    required this.id,
    required this.name,
    required this.country,
    required this.distance,
    required this.transportation,
    required this.travelTime,
    required this.overallScore,
    required this.imageUrl,
  });
}
