import 'dart:developer';

import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/infrastructure/models/event_type_dto.dart';

/// Meetup DTO - 基础设施层数据传输对象
class MeetupDto {
  final String id;
  final String title;
  final String type; // 兼容字段
  final EventTypeDto? eventType; // 完整的 EventType 对象
  final String description;
  final String city;
  final String cityId;
  final String? cityName;
  final String country;
  final String venue;
  final String venueAddress;
  final DateTime dateTime;
  final DateTime? endTime;
  final int maxAttendees;
  final int currentAttendees;
  final String organizerId;
  final String organizerName;
  final String? organizerAvatar;
  final String? imageUrl;
  final List<String> images;
  final List<String> attendeeIds;
  final bool isJoined;
  final bool isOrganizer;
  final String status;
  final DateTime createdAt;

  MeetupDto({
    required this.id,
    required this.title,
    required this.type,
    this.eventType, // 可选
    required this.description,
    required this.city,
    required this.cityId,
    this.cityName,
    required this.country,
    required this.venue,
    required this.venueAddress,
    required this.dateTime,
    this.endTime,
    required this.maxAttendees,
    required this.currentAttendees,
    required this.organizerId,
    required this.organizerName,
    this.organizerAvatar,
    this.imageUrl,
    required this.images,
    required this.attendeeIds,
    required this.isJoined,
    required this.isOrganizer,
    required this.status,
    required this.createdAt,
  });

  factory MeetupDto.fromJson(Map<String, dynamic> json) {
    // 处理 organizer 对象
    String? organizerName;
    String? organizerId;
    String? organizerAvatar;
    if (json['organizer'] != null && json['organizer'] is Map) {
      final organizer = json['organizer'] as Map<String, dynamic>;
      organizerName = organizer['name'] as String?;
      organizerId = organizer['id'] as String?;
      organizerAvatar = organizer['avatar'] as String? ?? organizer['avatarUrl'] as String?;
    }
    organizerName ??= json['organizerName'] as String? ?? json['creatorName'] as String?;
    organizerId ??= json['organizerId'] as String? ?? json['creatorId'] as String?;
    organizerAvatar ??= json['organizerAvatar'] as String?;

    // 处理 city 对象
    String? cityName;
    String? cityId;
    String? country;
    if (json['city'] != null && json['city'] is Map) {
      final city = json['city'] as Map<String, dynamic>;
      cityName = city['name'] as String?;
      cityId = city['id'] as String?;
      country = city['country'] as String?;
    }
    cityName ??= json['cityName'] as String? ?? json['location'] as String?;
    cityId ??= json['cityId'] as String?;
    country ??= json['country'] as String?;

    // 🔍 解析 EventType 对象
    EventTypeDto? eventTypeDto;
    if (json['eventType'] != null && json['eventType'] is Map) {
      try {
        eventTypeDto = EventTypeDto.fromJson(json['eventType'] as Map<String, dynamic>);
      } catch (e) {
        log('⚠️ 解析 eventType 失败: $e');
      }
    }

    return MeetupDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? json['category'] as String? ?? '',
      eventType: eventTypeDto, // 传入解析的 eventType
      description: json['description'] as String? ?? '',
      city: cityName ?? '',
      cityId: cityId ?? '',
      cityName: cityName,
      country: country ?? '',
      venue: json['location'] as String? ?? json['venue'] as String? ?? '',
      venueAddress: json['address'] as String? ?? json['venueAddress'] as String? ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : json['startTime'] != null
              ? DateTime.parse(json['startTime'] as String)
              : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      maxAttendees: (json['maxAttendees'] as num?)?.toInt() ?? (json['maxParticipants'] as num?)?.toInt() ?? 0,
      currentAttendees: (json['currentAttendees'] as num?)?.toInt() ?? (json['participantCount'] as num?)?.toInt() ?? 0,
      organizerId: organizerId ?? '',
      organizerName: organizerName ?? '',
      organizerAvatar: organizerAvatar,
      imageUrl: json['imageUrl'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      attendeeIds: (json['attendeeIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isJoined: json['isJoined'] as bool? ?? json['isParticipant'] as bool? ?? false,
      isOrganizer: json['isOrganizer'] as bool? ?? false,
      status: json['status'] as String? ?? 'upcoming',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    )..printDebugInfo();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'city': city,
      'cityId': cityId,
      'cityName': cityName,
      'country': country,
      'venue': venue,
      'venueAddress': venueAddress,
      'dateTime': dateTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerAvatar': organizerAvatar,
      'imageUrl': imageUrl,
      'images': images,
      'attendeeIds': attendeeIds,
      'isJoined': isJoined,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 转换为领域实体
  Meetup toDomain() {
    return Meetup(
      id: id,
      title: title,
      type: MeetupType.fromString(type),
      eventType: eventType?.toDomain(), // 转换 EventType
      description: description,
      location: Location(
        city: city,
        cityId: cityId,
        cityName: cityName,
        country: country,
      ),
      venue: Venue(
        name: venue,
        address: venueAddress,
      ),
      schedule: Schedule(
        startTime: dateTime,
        endTime: endTime,
      ),
      capacity: Capacity(
        maxAttendees: maxAttendees,
        currentAttendees: currentAttendees,
      ),
      organizer: Organizer(
        id: organizerId,
        name: organizerName,
        avatarUrl: organizerAvatar,
      ),
      images: imageUrl != null ? [imageUrl!, ...images] : images,
      attendeeIds: attendeeIds,
      status: MeetupStatus.fromString(status),
      createdAt: createdAt,
      isJoined: isJoined, // 传递 isJoined 信息
      isOrganizer: isOrganizer, // 传递 isOrganizer 信息
    );
  }

  void printDebugInfo() {
    log('🔍 MeetupDto.fromJson:');
    log('   title: $title');
    log('   isJoined: $isJoined');
    log('   isOrganizer: $isOrganizer');
    log('   organizerId: $organizerId');
  }
}
