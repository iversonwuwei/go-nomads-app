import '../database/meetup_dao.dart';

/// 活动数据服务
/// 提供活动数据的统一访问接口,从 SQLite 数据库读取和存储
class MeetupDataService {
  final MeetupDao _meetupDao = MeetupDao();

  /// 获取所有活动
  Future<List<Map<String, dynamic>>> getAllMeetups() async {
    return await _meetupDao.getAllMeetups();
  }

  /// 根据ID获取活动
  Future<Map<String, dynamic>?> getMeetupById(int id) async {
    return await _meetupDao.getMeetupById(id);
  }

  /// 按城市获取活动
  Future<List<Map<String, dynamic>>> getMeetupsByCity(int cityId) async {
    return await _meetupDao.getMeetupsByCity(cityId);
  }

  /// 按状态获取活动
  Future<List<Map<String, dynamic>>> getMeetupsByStatus(String status) async {
    return await _meetupDao.getMeetupsByStatus(status);
  }

  /// 创建新活动
  Future<int> createMeetup(Map<String, dynamic> meetupData) async {
    // 确保有默认状态
    if (!meetupData.containsKey('status')) {
      meetupData['status'] = 'upcoming';
    }

    // 确保时间格式正确
    if (meetupData.containsKey('start_time') &&
        meetupData['start_time'] is DateTime) {
      meetupData['start_time'] =
          (meetupData['start_time'] as DateTime).toIso8601String();
    }

    if (meetupData.containsKey('end_time') &&
        meetupData['end_time'] is DateTime) {
      meetupData['end_time'] =
          (meetupData['end_time'] as DateTime).toIso8601String();
    }

    return await _meetupDao.insertMeetup(meetupData);
  }

  /// 更新活动
  Future<int> updateMeetup(int id, Map<String, dynamic> meetupData) async {
    // 确保时间格式正确
    if (meetupData.containsKey('start_time') &&
        meetupData['start_time'] is DateTime) {
      meetupData['start_time'] =
          (meetupData['start_time'] as DateTime).toIso8601String();
    }

    if (meetupData.containsKey('end_time') &&
        meetupData['end_time'] is DateTime) {
      meetupData['end_time'] =
          (meetupData['end_time'] as DateTime).toIso8601String();
    }

    return await _meetupDao.updateMeetup(id, meetupData);
  }

  /// 删除活动
  Future<int> deleteMeetup(int id) async {
    return await _meetupDao.deleteMeetup(id);
  }

  /// 用户加入活动
  Future<void> joinMeetup(int meetupId, int userId) async {
    await _meetupDao.joinMeetup(meetupId, userId);
  }

  /// 用户退出活动
  Future<void> leaveMeetup(int meetupId, int userId) async {
    await _meetupDao.leaveMeetup(meetupId, userId);
  }

  /// 检查用户是否已加入活动
  Future<bool> hasUserJoined(int meetupId, int userId) async {
    return await _meetupDao.hasUserJoined(meetupId, userId);
  }

  /// 获取用户加入的所有活动
  Future<List<Map<String, dynamic>>> getUserJoinedMeetups(int userId) async {
    return await _meetupDao.getUserJoinedMeetups(userId);
  }

  /// 获取活动的所有参与者
  Future<List<Map<String, dynamic>>> getMeetupParticipants(int meetupId) async {
    return await _meetupDao.getMeetupParticipants(meetupId);
  }

  /// 获取即将到来的活动(未来30天内)
  Future<List<Map<String, dynamic>>> getUpcomingMeetups({int days = 30}) async {
    final allMeetups = await getMeetupsByStatus('upcoming');
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return allMeetups.where((meetup) {
      final startTime = meetup['start_time'] as String?;
      if (startTime == null) return false;

      try {
        final meetupDate = DateTime.parse(startTime);
        return meetupDate.isAfter(now) && meetupDate.isBefore(futureDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// 筛选活动
  Future<List<Map<String, dynamic>>> filterMeetups({
    int? cityId,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Map<String, dynamic>> meetups = await getAllMeetups();

    // 按城市筛选
    if (cityId != null) {
      meetups = meetups.where((meetup) {
        return meetup['city_id'] == cityId;
      }).toList();
    }

    // 按类别筛选
    if (category != null && category.isNotEmpty) {
      meetups = meetups.where((meetup) {
        final meetupCategory = meetup['category'] as String?;
        return meetupCategory != null && meetupCategory == category;
      }).toList();
    }

    // 按状态筛选
    if (status != null && status.isNotEmpty) {
      meetups = meetups.where((meetup) {
        final meetupStatus = meetup['status'] as String?;
        return meetupStatus != null && meetupStatus == status;
      }).toList();
    }

    // 按日期范围筛选
    if (startDate != null || endDate != null) {
      meetups = meetups.where((meetup) {
        final startTime = meetup['start_time'] as String?;
        if (startTime == null) return false;

        try {
          final meetupDate = DateTime.parse(startTime);

          if (startDate != null && meetupDate.isBefore(startDate)) {
            return false;
          }

          if (endDate != null && meetupDate.isAfter(endDate)) {
            return false;
          }

          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return meetups;
  }

  /// 搜索活动
  Future<List<Map<String, dynamic>>> searchMeetups(String keyword) async {
    final allMeetups = await getAllMeetups();
    final lowerKeyword = keyword.toLowerCase();

    return allMeetups.where((meetup) {
      final title = (meetup['title'] as String?)?.toLowerCase() ?? '';
      final description =
          (meetup['description'] as String?)?.toLowerCase() ?? '';
      final location = (meetup['location'] as String?)?.toLowerCase() ?? '';

      return title.contains(lowerKeyword) ||
          description.contains(lowerKeyword) ||
          location.contains(lowerKeyword);
    }).toList();
  }

  /// 排序活动
  List<Map<String, dynamic>> sortMeetups(
    List<Map<String, dynamic>> meetups,
    String sortBy,
  ) {
    final List<Map<String, dynamic>> sortedMeetups = List.from(meetups);

    switch (sortBy) {
      case 'date_asc':
        sortedMeetups.sort((a, b) {
          final dateA = DateTime.tryParse(a['start_time'] as String? ?? '');
          final dateB = DateTime.tryParse(b['start_time'] as String? ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });
        break;

      case 'date_desc':
        sortedMeetups.sort((a, b) {
          final dateA = DateTime.tryParse(a['start_time'] as String? ?? '');
          final dateB = DateTime.tryParse(b['start_time'] as String? ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
        break;

      case 'participants':
        sortedMeetups.sort((a, b) {
          final countA = a['current_participants'] as int? ?? 0;
          final countB = b['current_participants'] as int? ?? 0;
          return countB.compareTo(countA);
        });
        break;

      default:
        // 默认按日期升序
        sortedMeetups.sort((a, b) {
          final dateA = DateTime.tryParse(a['start_time'] as String? ?? '');
          final dateB = DateTime.tryParse(b['start_time'] as String? ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });
    }

    return sortedMeetups;
  }

  /// 获取活动类别列表
  Future<List<String>> getAllCategories() async {
    final meetups = await getAllMeetups();
    final categories = meetups
        .map((meetup) => meetup['category'] as String?)
        .where((category) => category != null)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
