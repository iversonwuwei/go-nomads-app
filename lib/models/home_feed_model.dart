import 'city_feed_model.dart';
import 'meetup_feed_model.dart';

/// 首页聚合数据模型
class HomeFeedModel {
  final List<CityFeedModel> cities;
  final List<MeetupFeedModel> meetups;
  final DateTime timestamp;
  final bool hasMoreCities;
  final bool hasMoreMeetups;

  HomeFeedModel({
    required this.cities,
    required this.meetups,
    required this.timestamp,
    required this.hasMoreCities,
    required this.hasMoreMeetups,
  });

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    return HomeFeedModel(
      cities: (json['cities'] as List<dynamic>?)
              ?.map((e) => CityFeedModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meetups: (json['meetups'] as List<dynamic>?)
              ?.map((e) => MeetupFeedModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      hasMoreCities: json['hasMoreCities'] as bool? ?? false,
      hasMoreMeetups: json['hasMoreMeetups'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cities': cities.map((e) => e.toJson()).toList(),
      'meetups': meetups.map((e) => e.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'hasMoreCities': hasMoreCities,
      'hasMoreMeetups': hasMoreMeetups,
    };
  }

  /// 辅助方法: 判断是否为空
  bool get isEmpty => cities.isEmpty && meetups.isEmpty;

  /// 辅助方法: 判断是否有数据
  bool get isNotEmpty => !isEmpty;

  /// 辅助方法: 获取城市总数
  int get cityCount => cities.length;

  /// 辅助方法: 获取活动总数
  int get meetupCount => meetups.length;

  /// 辅助方法: 创建空的首页数据
  factory HomeFeedModel.empty() {
    return HomeFeedModel(
      cities: [],
      meetups: [],
      timestamp: DateTime.now(),
      hasMoreCities: false,
      hasMoreMeetups: false,
    );
  }
}
