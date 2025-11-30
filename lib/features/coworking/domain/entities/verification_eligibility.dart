/// 验证资格检查结果实体
class VerificationEligibility {
  /// 是否可以验证
  final bool canVerify;

  /// 不能验证的原因
  final String? reason;

  /// 原因代码: ALREADY_VERIFIED, IS_CREATOR, ALREADY_VOTED, SPACE_VERIFIED
  final String? reasonCode;

  /// 该 Coworking 空间是否已经是已验证状态
  final bool isSpaceVerified;

  /// 当前投票数
  final int currentVotes;

  const VerificationEligibility({
    required this.canVerify,
    this.reason,
    this.reasonCode,
    this.isSpaceVerified = false,
    this.currentVotes = 0,
  });

  /// 从 JSON 解析
  factory VerificationEligibility.fromJson(Map<String, dynamic> json) {
    return VerificationEligibility(
      canVerify: json['canVerify'] as bool? ?? false,
      reason: json['reason'] as String?,
      reasonCode: json['reasonCode'] as String?,
      isSpaceVerified: json['isSpaceVerified'] as bool? ?? false,
      currentVotes: json['currentVotes'] as int? ?? 0,
    );
  }

  /// 获取本地化的原因消息
  String getLocalizedReason({
    String? alreadyVoted,
    String? isCreator,
    String? spaceVerified,
    String? defaultMessage,
  }) {
    switch (reasonCode) {
      case 'ALREADY_VOTED':
        return alreadyVoted ?? reason ?? '您已经为该共享空间提交过认证';
      case 'IS_CREATOR':
        return isCreator ?? reason ?? '创建者不能为自己的共享空间认证';
      case 'SPACE_VERIFIED':
        return spaceVerified ?? reason ?? '该共享空间已通过认证';
      default:
        return reason ?? defaultMessage ?? '无法验证';
    }
  }
}
