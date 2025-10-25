/// 活动简要信息模型 (用于首页 feed)
class MeetupFeedModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String location;
  final String cityId;
  final String? cityName;
  final int participantCount;
  final int? maxParticipants;
  final String? imageUrl;
  final String status;
  final String? creatorId;
  final String? creatorName;

  MeetupFeedModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.location,
    required this.cityId,
    this.cityName,
    required this.participantCount,
    this.maxParticipants,
    this.imageUrl,
    required this.status,
    this.creatorId,
    this.creatorName,
  });

  factory MeetupFeedModel.fromJson(Map<String, dynamic> json) {
    return MeetupFeedModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      location: json['location'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String?,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'upcoming',
      creatorId: json['creatorId'] as String?,
      creatorName: json['creatorName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'cityId': cityId,
      'cityName': cityName,
      'participantCount': participantCount,
      'maxParticipants': maxParticipants,
      'imageUrl': imageUrl,
      'status': status,
      'creatorId': creatorId,
      'creatorName': creatorName,
    };
  }

  /// 辅助方法: 判断活动是否已满员
  bool get isFull {
    if (maxParticipants == null) return false;
    return participantCount >= maxParticipants!;
  }

  /// 辅助方法: 获取剩余名额
  int? get remainingSlots {
    if (maxParticipants == null) return null;
    return maxParticipants! - participantCount;
  }

  /// 辅助方法: 格式化日期时间
  String get formattedDateTime {
    final date = startTime;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }
}
