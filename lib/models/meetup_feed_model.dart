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
  final bool isParticipant; // 当前用户是否已参加

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
    this.isParticipant = false, // 默认未参加
  });

  factory MeetupFeedModel.fromJson(Map<String, dynamic> json) {
    // 调试：打印 organizer 数据
    print('🔍 [MeetupFeedModel] 解析 JSON:');
    print('   title: ${json['title']}');
    print('   organizer type: ${json['organizer']?.runtimeType}');
    print('   organizer value: ${json['organizer']}');
    
    // 尝试从 organizer 对象中获取名称，如果没有则使用 creatorName
    String? organizerName;
    if (json['organizer'] != null && json['organizer'] is Map) {
      organizerName =
          (json['organizer'] as Map<String, dynamic>)['name'] as String?;
      print('   ✅ 从 organizer.name 获取: $organizerName');
    }
    organizerName ??= json['creatorName'] as String?;
    print('   最终 organizerName: $organizerName');

    // 尝试从 organizer 对象中获取 ID，如果没有则使用 creatorId
    String? organizerId;
    if (json['organizer'] != null && json['organizer'] is Map) {
      organizerId =
          (json['organizer'] as Map<String, dynamic>)['id'] as String?;
    }
    organizerId ??= json['creatorId'] as String?;
    
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
      creatorId: organizerId,
      creatorName: organizerName,
      isParticipant: json['isParticipant'] as bool? ?? false,
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
      'isParticipant': isParticipant,
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
