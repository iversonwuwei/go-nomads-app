import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';

/// 更新活动 Use Case
class UpdateMeetupUseCase {
  final IMeetupRepository _repository;

  UpdateMeetupUseCase(this._repository);

  /// 执行更新活动
  Future<Meetup> execute({
    required String meetupId,
    String? title,
    String? description,
    String? cityId,
    String? venue,
    String? venueAddress,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    int? maxAttendees,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('🎯 执行 UpdateMeetupUseCase...');
      print('   活动ID: $meetupId');

      // 构建更新数据
      final Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (cityId != null) updates['cityId'] = cityId;
      if (venue != null) updates['location'] = venue;
      if (venueAddress != null) updates['address'] = venueAddress;
      if (category != null) updates['category'] = category;
      if (startTime != null) updates['startTime'] = startTime.toIso8601String();
      if (endTime != null) updates['endTime'] = endTime.toIso8601String();
      if (maxAttendees != null) updates['maxParticipants'] = maxAttendees;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (images != null) updates['images'] = images;
      if (tags != null) updates['tags'] = tags;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;

      print('   更新字段: ${updates.keys.toList()}');

      // 调用 Repository 更新活动
      final meetup = await _repository.updateMeetup(meetupId, updates);

      print('✅ 活动更新成功: ${meetup.id}');
      return meetup;
    } catch (e) {
      print('❌ UpdateMeetupUseCase 执行失败: $e');
      rethrow;
    }
  }
}
