/// Meetup 领域实体
/// 代表数字游民聚会活动的核心领域对象
class Meetup {
  final String id;
  final String title;
  final MeetupType type;
  final String description;
  final Location location;
  final Venue venue;
  final Schedule schedule;
  final Capacity capacity;
  final Organizer organizer;
  final List<String> images;
  final List<String> attendeeIds;
  final MeetupStatus status;
  final DateTime createdAt;

  Meetup({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.location,
    required this.venue,
    required this.schedule,
    required this.capacity,
    required this.organizer,
    required this.images,
    required this.attendeeIds,
    required this.status,
    required this.createdAt,
  });

  // === 业务逻辑方法 ===

  /// 是否即将开始 (24小时内)
  bool get isStartingSoon {
    final now = DateTime.now();
    final difference = schedule.startTime.difference(now);
    return difference.inHours > 0 && difference.inHours <= 24;
  }

  /// 是否已结束
  bool get isEnded => schedule.startTime.isBefore(DateTime.now());

  /// 是否正在进行中
  bool get isOngoing {
    final now = DateTime.now();
    if (schedule.endTime == null) {
      return false;
    }
    return now.isAfter(schedule.startTime) && now.isBefore(schedule.endTime!);
  }

  /// 是否即将到来
  bool get isUpcoming => schedule.startTime.isAfter(DateTime.now());

  /// 检查用户是否可以加入
  bool canJoin(String userId) {
    // 已结束或正在进行的活动不能加入
    if (isEnded || isOngoing) return false;

    // 已满员不能加入
    if (capacity.isFull) return false;

    // 已经是参与者不能重复加入
    if (attendeeIds.contains(userId)) return false;

    return true;
  }

  /// 检查用户是否可以取消参与
  bool canLeave(String userId) {
    // 不是参与者不能取消
    if (!attendeeIds.contains(userId)) return false;

    // 活动已结束不能取消
    if (isEnded) return false;

    return true;
  }

  /// 检查用户是否是组织者
  bool isOrganizer(String userId) {
    return organizer.id == userId;
  }

  /// 检查用户是否可以编辑活动
  bool canEdit(String userId) {
    // 只有组织者可以编辑
    if (!isOrganizer(userId)) return false;

    // 已结束的活动不能编辑
    if (isEnded) return false;

    return true;
  }

  /// 检查用户是否可以取消活动
  bool canCancel(String userId) {
    // 只有组织者可以取消
    if (!isOrganizer(userId)) return false;

    // 已结束的活动不能取消
    if (isEnded) return false;

    return true;
  }

  /// 获取活动参与率
  double get participationRate {
    if (capacity.maxAttendees == 0) return 0;
    return capacity.currentAttendees / capacity.maxAttendees;
  }

  /// 是否接近满员 (80%以上)
  bool get isNearlyFull => participationRate >= 0.8;

  /// 获取活动时长 (小时)
  double? get durationInHours {
    if (schedule.endTime == null) return null;
    return schedule.endTime!.difference(schedule.startTime).inMinutes / 60.0;
  }
}

/// 活动类型值对象
class MeetupType {
  final String value;

  const MeetupType._(this.value);

  static const networking = MeetupType._('networking');
  static const workshop = MeetupType._('workshop');
  static const social = MeetupType._('social');
  static const coworking = MeetupType._('coworking');
  static const sports = MeetupType._('sports');
  static const culture = MeetupType._('culture');
  static const other = MeetupType._('other');

  static MeetupType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'networking':
        return networking;
      case 'workshop':
        return workshop;
      case 'social':
        return social;
      case 'coworking':
        return coworking;
      case 'sports':
        return sports;
      case 'culture':
        return culture;
      default:
        return other;
    }
  }

  @override
  String toString() => value;
}

/// 位置信息值对象
class Location {
  final String city;
  final String cityId;
  final String? cityName;
  final String country;

  Location({
    required this.city,
    required this.cityId,
    this.cityName,
    required this.country,
  });

  /// 获取完整位置描述
  String get fullDescription {
    final parts = [cityName ?? city, country].where((p) => p.isNotEmpty);
    return parts.join(', ');
  }
}

/// 场地信息值对象
class Venue {
  final String name;
  final String address;

  Venue({
    required this.name,
    required this.address,
  });

  /// 获取完整场地信息
  String get fullInfo => '$name - $address';
}

/// 时间安排值对象
class Schedule {
  final DateTime startTime;
  final DateTime? endTime;

  Schedule({
    required this.startTime,
    this.endTime,
  });

  /// 格式化开始时间
  String get formattedStartTime {
    final date = startTime;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }

  /// 获取距离开始的时间
  Duration get timeUntilStart => startTime.difference(DateTime.now());

  /// 获取距离结束的时间
  Duration? get timeUntilEnd {
    if (endTime == null) return null;
    return endTime!.difference(DateTime.now());
  }
}

/// 容量信息值对象
class Capacity {
  final int maxAttendees;
  final int currentAttendees;

  Capacity({
    required this.maxAttendees,
    required this.currentAttendees,
  });

  /// 剩余名额
  int get remainingSlots => maxAttendees - currentAttendees;

  /// 是否已满
  bool get isFull => currentAttendees >= maxAttendees;

  /// 是否有名额
  bool get hasSlots => currentAttendees < maxAttendees;

  /// 获取占用率 (0-1)
  double get occupancyRate {
    if (maxAttendees == 0) return 0;
    return currentAttendees / maxAttendees;
  }
}

/// 组织者信息值对象
class Organizer {
  final String id;
  final String name;
  final String? avatarUrl;

  Organizer({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
}

/// 活动状态值对象
class MeetupStatus {
  final String value;

  const MeetupStatus._(this.value);

  static const upcoming = MeetupStatus._('upcoming');
  static const ongoing = MeetupStatus._('ongoing');
  static const completed = MeetupStatus._('completed');
  static const cancelled = MeetupStatus._('cancelled');

  static MeetupStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return upcoming;
      case 'ongoing':
        return ongoing;
      case 'completed':
        return completed;
      case 'cancelled':
        return cancelled;
      default:
        return upcoming;
    }
  }

  @override
  String toString() => value;
}
