/// 版主申请实体
class ModeratorApplication {
  final String id;
  final String userId;
  final String cityId;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? processedBy;
  final String? processedByName;
  final DateTime? processedAt;
  final String? rejectionReason;
  final DateTime createdAt;

  // 关联数据
  final String? userName;
  final String? userAvatar;
  final String? cityName;

  ModeratorApplication({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.reason,
    required this.status,
    this.processedBy,
    this.processedByName,
    this.processedAt,
    this.rejectionReason,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.cityName,
  });

  factory ModeratorApplication.fromJson(Map<String, dynamic> json) {
    return ModeratorApplication(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      cityId: json['cityId']?.toString() ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      processedBy: json['processedBy']?.toString(),
      processedByName: json['processedByName'] as String?,
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      cityName: json['cityName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cityId': cityId,
      'reason': reason,
      'status': status,
      'processedBy': processedBy,
      'processedByName': processedByName,
      'processedAt': processedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'userAvatar': userAvatar,
      'cityName': cityName,
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
