/// Meetup 模型
class MeetupModel {
  final String id;
  final String title;
  final String type;
  final String description;
  final String city;
  final String country;
  final String venue;
  final String venueAddress;
  final DateTime dateTime;
  final int maxAttendees;
  final int currentAttendees;
  final String organizerId;
  final String organizerName;
  final String organizerAvatar;
  final String? imageUrl; // 封面图片URL（用于列表页）
  final List<String> images; // 完整图片数组（用于详情页）
  final List<String> attendeeIds;
  final bool isJoined;
  final DateTime createdAt;

  MeetupModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.city,
    required this.country,
    required this.venue,
    required this.venueAddress,
    required this.dateTime,
    required this.maxAttendees,
    required this.currentAttendees,
    required this.organizerId,
    required this.organizerName,
    required this.organizerAvatar,
    this.imageUrl,
    required this.images,
    required this.attendeeIds,
    required this.isJoined,
    required this.createdAt,
  });

  factory MeetupModel.fromJson(Map<String, dynamic> json) {
    return MeetupModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      venue: json['venue'] ?? '',
      venueAddress: json['venueAddress'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      maxAttendees: json['maxAttendees'] ?? 0,
      currentAttendees: json['currentAttendees'] ?? 0,
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      organizerAvatar: json['organizerAvatar'] ?? '',
      imageUrl: json['imageUrl'],
      images: List<String>.from(json['images'] ?? []),
      attendeeIds: List<String>.from(json['attendeeIds'] ?? []),
      isJoined: json['isJoined'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'city': city,
      'country': country,
      'venue': venue,
      'venueAddress': venueAddress,
      'dateTime': dateTime.toIso8601String(),
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerAvatar': organizerAvatar,
      'imageUrl': imageUrl,
      'images': images,
      'attendeeIds': attendeeIds,
      'isJoined': isJoined,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MeetupModel copyWith({
    String? id,
    String? title,
    String? type,
    String? description,
    String? city,
    String? country,
    String? venue,
    String? venueAddress,
    DateTime? dateTime,
    int? maxAttendees,
    int? currentAttendees,
    String? organizerId,
    String? organizerName,
    String? organizerAvatar,
    String? imageUrl,
    List<String>? images,
    List<String>? attendeeIds,
    bool? isJoined,
    DateTime? createdAt,
  }) {
    return MeetupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      city: city ?? this.city,
      country: country ?? this.country,
      venue: venue ?? this.venue,
      venueAddress: venueAddress ?? this.venueAddress,
      dateTime: dateTime ?? this.dateTime,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerAvatar: organizerAvatar ?? this.organizerAvatar,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 计算剩余名额
  int get remainingSlots => maxAttendees - currentAttendees;

  // 是否已满
  bool get isFull => currentAttendees >= maxAttendees;

  // 是否即将开始(24小时内)
  bool get isStartingSoon {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    return difference.inHours > 0 && difference.inHours <= 24;
  }

  // 是否已结束
  bool get isEnded => dateTime.isBefore(DateTime.now());
}
