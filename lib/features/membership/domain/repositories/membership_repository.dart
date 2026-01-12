import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/ai_usage_check.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_plan.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';

/// 会员仓库接口
abstract class MembershipRepository {
  /// 获取所有会员计划
  Future<Result<List<MembershipPlan>>> getPlans();

  /// 获取指定等级的会员计划
  Future<Result<MembershipPlan>> getPlanByLevel(int level);

  /// 获取当前用户的会员信息
  Future<Result<UserMembership>> getCurrentMembership();

  /// 升级会员等级
  Future<Result<UserMembership>> upgradeMembership(MembershipLevel level);

  /// 取消自动续费
  Future<Result<void>> cancelAutoRenew();

  /// 恢复自动续费
  Future<Result<void>> enableAutoRenew();

  /// 增加 AI 使用次数
  Future<Result<UserMembership>> incrementAiUsage();

  /// 检查 AI 使用配额
  Future<Result<AiUsageCheck>> checkAiUsage();

  /// 缴纳版主保证金
  Future<Result<UserMembership>> payModeratorDeposit(double amount);

  /// 获取支付链接
  Future<Result<String>> getPaymentUrl(MembershipLevel level);
}
