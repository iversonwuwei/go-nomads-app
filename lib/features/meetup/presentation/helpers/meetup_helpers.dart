import '../../domain/entities/meetup.dart';

/// Meetup 辅助工具类
/// 从 DataServiceController 迁移的辅助方法
class MeetupHelpers {
  /// 从标题猜测活动类型
  /// 通过关键词检测推断活动类型
  static MeetupType guessMeetupType(String title) {
    final lowerTitle = title.toLowerCase();

    // 社交活动关键词
    if (lowerTitle.contains('drink') ||
        lowerTitle.contains('drinks') ||
        lowerTitle.contains('bar') ||
        lowerTitle.contains('beer') ||
        lowerTitle.contains('wine') ||
        lowerTitle.contains('party') ||
        lowerTitle.contains('social') ||
        lowerTitle.contains('happy hour')) {
      return MeetupType.social;
    }

    // 联合办公关键词
    if (lowerTitle.contains('cowork') ||
        lowerTitle.contains('co-work') ||
        lowerTitle.contains('work together') ||
        lowerTitle.contains('共同办公') ||
        lowerTitle.contains('协作')) {
      return MeetupType.coworking;
    }

    // 工作坊关键词
    if (lowerTitle.contains('workshop') ||
        lowerTitle.contains('training') ||
        lowerTitle.contains('course') ||
        lowerTitle.contains('class') ||
        lowerTitle.contains('学习') ||
        lowerTitle.contains('培训')) {
      return MeetupType.workshop;
    }

    // 人脉拓展关键词
    if (lowerTitle.contains('network') ||
        lowerTitle.contains('networking') ||
        lowerTitle.contains('meetup') ||
        lowerTitle.contains('connect') ||
        lowerTitle.contains('人脉') ||
        lowerTitle.contains('交流')) {
      return MeetupType.networking;
    }

    // 运动健身关键词
    if (lowerTitle.contains('sport') ||
        lowerTitle.contains('fitness') ||
        lowerTitle.contains('yoga') ||
        lowerTitle.contains('run') ||
        lowerTitle.contains('hiking') ||
        lowerTitle.contains('gym') ||
        lowerTitle.contains('运动') ||
        lowerTitle.contains('健身')) {
      return MeetupType.sports;
    }

    // 文化活动关键词
    if (lowerTitle.contains('culture') ||
        lowerTitle.contains('art') ||
        lowerTitle.contains('music') ||
        lowerTitle.contains('museum') ||
        lowerTitle.contains('exhibition') ||
        lowerTitle.contains('文化') ||
        lowerTitle.contains('艺术') ||
        lowerTitle.contains('音乐')) {
      return MeetupType.culture;
    }

    // 默认返回 other
    return MeetupType.other;
  }

  /// 将前端类型映射到后端 API 的 category
  static String mapTypeToCategory(MeetupType type) {
    switch (type.value) {
      case 'networking':
        return 'business';
      case 'workshop':
        return 'tech';
      case 'social':
        return 'social';
      case 'coworking':
        return 'business';
      case 'sports':
        return 'other';
      case 'culture':
        return 'other';
      case 'other':
      default:
        return 'other';
    }
  }

  /// 将 API category 映射回前端类型
  static MeetupType mapCategoryToType(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return MeetupType.networking;
      case 'tech':
        return MeetupType.workshop;
      case 'social':
        return MeetupType.social;
      default:
        return MeetupType.other;
    }
  }

  /// 格式化活动时间范围
  static String formatTimeRange(DateTime startTime, DateTime? endTime) {
    final startStr = _formatTime(startTime);

    if (endTime != null) {
      final endStr = _formatTime(endTime);
      return '$startStr - $endStr';
    }

    return startStr;
  }

  /// 格式化时间为 HH:mm 格式
  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 格式化活动日期
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == tomorrow) {
      return '明天';
    } else {
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      final weekday = weekdays[date.weekday - 1];
      return '${date.month}月${date.day}日 $weekday';
    }
  }

  /// 获取活动状态显示文本
  static String getStatusText(MeetupStatus status) {
    switch (status.value) {
      case 'upcoming':
        return '即将开始';
      case 'ongoing':
        return '进行中';
      case 'completed':
        return '已结束';
      case 'cancelled':
        return '已取消';
      default:
        return '未知';
    }
  }

  /// 获取活动类型显示文本
  static String getTypeText(MeetupType type) {
    switch (type.value) {
      case 'networking':
        return '人脉拓展';
      case 'workshop':
        return '工作坊';
      case 'social':
        return '社交活动';
      case 'coworking':
        return '联合办公';
      case 'sports':
        return '运动健身';
      case 'culture':
        return '文化活动';
      case 'other':
        return '其他';
      default:
        return '未知';
    }
  }

  /// 计算活动容量百分比
  static double getCapacityPercentage(Capacity capacity) {
    if (capacity.maxAttendees == 0) return 0.0;
    return (capacity.currentAttendees / capacity.maxAttendees * 100)
        .clamp(0.0, 100.0);
  }

  /// 获取容量状态文本
  static String getCapacityText(Capacity capacity) {
    return '${capacity.currentAttendees}/${capacity.maxAttendees}人';
  }

  /// 检查活动是否即将开始 (24小时内)
  static bool isStartingSoon(DateTime startTime) {
    final now = DateTime.now();
    final difference = startTime.difference(now);
    return difference.inHours > 0 && difference.inHours <= 24;
  }

  /// 检查活动是否已满员
  static bool isFull(Capacity capacity) {
    return capacity.currentAttendees >= capacity.maxAttendees;
  }

  /// 检查活动是否接近满员 (>80%)
  static bool isNearlyFull(Capacity capacity) {
    return getCapacityPercentage(capacity) >= 80.0;
  }
}
