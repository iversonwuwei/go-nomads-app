/// 旅行计划摘要（用于列表显示）
class TravelPlanSummary {
  final String id;
  final String cityId;
  final String cityName;
  final String? cityImage;
  final int duration;
  final String budgetLevel;
  final String travelStyle;
  final String status;
  final DateTime? departureDate;
  final DateTime createdAt;
  final String migrationStage;
  final String? focusNote;
  final int completedTaskCount;
  final int totalTaskCount;
  final List<MigrationChecklistItem> checklist;
  final List<MigrationTimelineItem> timeline;

  const TravelPlanSummary({
    required this.id,
    required this.cityId,
    required this.cityName,
    this.cityImage,
    required this.duration,
    required this.budgetLevel,
    required this.travelStyle,
    required this.status,
    this.departureDate,
    required this.createdAt,
    this.migrationStage = '',
    this.focusNote,
    this.completedTaskCount = 0,
    this.totalTaskCount = 0,
    this.checklist = const [],
    this.timeline = const [],
  });

  factory TravelPlanSummary.fromJson(Map<String, dynamic> json) {
    final checklistJson = (json['checklist'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    final timelineJson = (json['timeline'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return TravelPlanSummary(
      id: json['id'] ?? '',
      cityId: json['cityId'] ?? '',
      cityName: json['cityName'] ?? '',
      cityImage: json['cityImage'],
      duration: json['duration'] ?? 0,
      budgetLevel: json['budgetLevel'] ?? '',
      travelStyle: json['travelStyle'] ?? '',
      status: json['status'] ?? '',
      departureDate: json['departureDate'] != null ? DateTime.parse(json['departureDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      migrationStage: json['migrationStage'] ?? '',
      focusNote: json['focusNote'],
      completedTaskCount: json['completedTaskCount'] ?? 0,
      totalTaskCount: json['totalTaskCount'] ?? 0,
      checklist: checklistJson.map(MigrationChecklistItem.fromJson).toList(),
      timeline: timelineJson.map(MigrationTimelineItem.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityId': cityId,
      'cityName': cityName,
      'cityImage': cityImage,
      'duration': duration,
      'budgetLevel': budgetLevel,
      'travelStyle': travelStyle,
      'status': status,
      'departureDate': departureDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'migrationStage': migrationStage,
      'focusNote': focusNote,
      'completedTaskCount': completedTaskCount,
      'totalTaskCount': totalTaskCount,
      'checklist': checklist.map((item) => item.toJson()).toList(),
      'timeline': timeline.map((item) => item.toJson()).toList(),
    };
  }

  bool get hasWorkspaceDetails =>
      migrationStage.isNotEmpty || focusNote != null || checklist.isNotEmpty || timeline.isNotEmpty;

  /// 格式化出行日期
  String? get formattedDepartureDate {
    if (departureDate == null) return null;
    return '${departureDate!.year}/${departureDate!.month.toString().padLeft(2, '0')}/${departureDate!.day.toString().padLeft(2, '0')}';
  }

  /// 获取预算级别显示文本
  String get budgetLevelDisplay {
    switch (budgetLevel.toLowerCase()) {
      case 'low':
        return '💰 Budget';
      case 'medium':
        return '💰💰 Mid-range';
      case 'high':
        return '💰💰💰 Luxury';
      default:
        return budgetLevel;
    }
  }

  /// 获取旅行风格显示文本
  String get travelStyleDisplay {
    switch (travelStyle.toLowerCase()) {
      case 'adventure':
        return '🏔️ Adventure';
      case 'relaxation':
        return '🏖️ Relaxation';
      case 'culture':
        return '🏛️ Culture';
      case 'nightlife':
        return '🎉 Nightlife';
      default:
        return travelStyle;
    }
  }

  /// 格式化创建时间
  String get formattedCreatedAt {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }
}

class MigrationChecklistItem {
  final String id;
  final String title;
  final bool isCompleted;

  const MigrationChecklistItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory MigrationChecklistItem.fromJson(Map<String, dynamic> json) {
    return MigrationChecklistItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };
}

class MigrationTimelineItem {
  final String id;
  final String title;
  final String status;
  final DateTime? targetDate;

  const MigrationTimelineItem({
    required this.id,
    required this.title,
    required this.status,
    required this.targetDate,
  });

  factory MigrationTimelineItem.fromJson(Map<String, dynamic> json) {
    return MigrationTimelineItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      targetDate: json['targetDate'] != null ? DateTime.tryParse(json['targetDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'targetDate': targetDate?.toIso8601String(),
      };
}
