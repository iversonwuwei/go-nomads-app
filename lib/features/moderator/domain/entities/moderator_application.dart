/// 版主申请实体
class ModeratorApplication {
  final String id;
  final String userId;
  final String cityId;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? processedBy;
  final DateTime? processedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 关联数据
  final String? userName;
  final String? userAvatar;
  final String? cityName;
  final String? cityNameEn;

  ModeratorApplication({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.reason,
    required this.status,
    this.processedBy,
    this.processedAt,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.cityName,
    this.cityNameEn,
  });

  factory ModeratorApplication.fromJson(Map<String, dynamic> json) {
    return ModeratorApplication(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cityId: json['city_id'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      processedBy: json['processed_by'] as String?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      cityName: json['city_name'] as String?,
      cityNameEn: json['city_name_en'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'city_id': cityId,
      'reason': reason,
      'status': status,
      'processed_by': processedBy,
      'processed_at': processedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_avatar': userAvatar,
      'city_name': cityName,
      'city_name_en': cityNameEn,
    };
  }

  /// 是否待处理
  bool get isPending => status == 'pending';

  /// 是否已通过
  bool get isApproved => status == 'approved';

  /// 是否已拒绝
  bool get isRejected => status == 'rejected';

  /// 获取状态文本
  String get statusText {
    switch (status) {
      case 'pending':
        return '待审核';
      case 'approved':
        return '已通过';
      case 'rejected':
        return '已拒绝';
      default:
        return status;
    }
  }
}
