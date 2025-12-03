import 'dart:convert';
import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_plan.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';
import 'package:df_admin_mobile/features/membership/domain/repositories/membership_repository.dart';
import 'package:df_admin_mobile/features/membership/infrastructure/dtos/user_membership_dto.dart';
import 'package:df_admin_mobile/features/membership/infrastructure/services/membership_api_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 会员仓库实现
/// 
/// 使用后端 API 进行会员管理，本地缓存作为降级方案
class MembershipRepositoryImpl implements MembershipRepository {
  static const String _membershipKey = 'user_membership';
  static const String _plansKey = 'membership_plans';
  
  final TokenStorageService _tokenService;
  final MembershipApiService _apiService = MembershipApiService();
  
  MembershipRepositoryImpl(this._tokenService);
  
  /// 获取当前用户 ID
  Future<String> _getUserId() async {
    final userId = await _tokenService.getUserId();
    return userId ?? 'anonymous';
  }

  @override
  Future<Result<List<MembershipPlan>>> getPlans() async {
    try {
      // 从后端 API 获取会员计划
      final responses = await _apiService.getPlans();
      final plans = responses.map((r) => _apiService.toPlanEntity(r)).toList();
      
      // 缓存到本地
      await _savePlans(plans);
      
      log('✅ 获取会员计划成功: ${plans.length} 个');
      return Result.success(plans);
    } catch (e) {
      log('⚠️ 从 API 获取会员计划失败，尝试本地缓存: $e');
      
      // 降级到本地缓存
      final cachedPlans = await _loadCachedPlans();
      if (cachedPlans.isNotEmpty) {
        return Result.success(cachedPlans);
      }
      
      // 无法获取会员计划，返回错误
      return Result.failure(NetworkException('无法获取会员计划，请检查网络连接'));
    }
  }

  @override
  Future<Result<MembershipPlan>> getPlanByLevel(int level) async {
    try {
      final response = await _apiService.getPlanByLevel(level);
      final plan = _apiService.toPlanEntity(response);
      return Result.success(plan);
    } catch (e) {
      log('❌ 获取会员计划失败: $e');
      
      // 尝试从缓存获取
      final cachedPlans = await _loadCachedPlans();
      final plan = cachedPlans.where((p) => p.level == level).firstOrNull;
      if (plan != null) {
        return Result.success(plan);
      }
      
      return Result.failure(BusinessLogicException('未找到会员计划'));
    }
  }

  @override
  Future<Result<UserMembership>> getCurrentMembership() async {
    try {
      // 尝试从后端 API 获取
      final response = await _apiService.getMembership();
      final dto = _apiService.toUserMembershipDto(response);
      final membership = dto.toDomain();
      
      // 同步到本地缓存
      await _saveMembership(membership);
      
      return Result.success(membership);
    } catch (e) {
      log('⚠️ 从 API 获取会员信息失败，尝试本地缓存: $e');
      
      // 降级到本地缓存
      try {
        final prefs = await SharedPreferences.getInstance();
        final json = prefs.getString(_membershipKey);
        
        if (json != null) {
          final data = jsonDecode(json) as Map<String, dynamic>;
          final dto = UserMembershipDto.fromJson(data);
          return Result.success(dto.toDomain());
        }
      } catch (cacheError) {
        log('❌ 本地缓存读取也失败: $cacheError');
      }
      
      // 最终降级返回免费会员
      final userId = await _getUserId();
      return Result.success(UserMembership.free(userId));
    }
  }

  @override
  Future<Result<UserMembership>> upgradeMembership(MembershipLevel level) async {
    try {
      // 调用后端 API 进行升级
      final response = await _apiService.upgradeMembership(
        level: level.index,
        durationDays: 365,
      );
      
      final dto = _apiService.toUserMembershipDto(response);
      final membership = dto.toDomain();
      
      // 同步到本地缓存
      await _saveMembership(membership);
      
      log('✅ 会员升级成功: ${level.name}');
      return Result.success(membership);
    } catch (e) {
      log('❌ 会员升级失败: $e');
      return Result.failure(BusinessLogicException('升级会员失败: $e'));
    }
  }

  @override
  Future<Result<void>> cancelAutoRenew() async {
    try {
      await _apiService.setAutoRenew(false);
      
      // 更新本地缓存
      final current = await getCurrentMembership();
      if (current.isSuccess) {
        final membership = current.dataOrNull!;
        final updated = membership.copyWith(autoRenew: false);
        await _saveMembership(updated);
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(BusinessLogicException('取消自动续费失败: $e'));
    }
  }

  @override
  Future<Result<void>> enableAutoRenew() async {
    try {
      await _apiService.setAutoRenew(true);
      
      // 更新本地缓存
      final current = await getCurrentMembership();
      if (current.isSuccess) {
        final membership = current.dataOrNull!;
        final updated = membership.copyWith(autoRenew: true);
        await _saveMembership(updated);
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(BusinessLogicException('开启自动续费失败: $e'));
    }
  }

  @override
  Future<Result<UserMembership>> incrementAiUsage() async {
    try {
      // 调用后端 API 记录使用
      final success = await _apiService.recordAiUsage();
      
      if (success) {
        // 重新获取最新会员信息
        return getCurrentMembership();
      } else {
        return Result.failure(BusinessLogicException('AI 使用次数已达上限'));
      }
    } catch (e) {
      return Result.failure(BusinessLogicException('更新AI使用次数失败: $e'));
    }
  }

  @override
  Future<Result<UserMembership>> payModeratorDeposit(double amount) async {
    try {
      // 调用后端 API 缴纳保证金
      final response = await _apiService.payDeposit(amount);
      
      final dto = _apiService.toUserMembershipDto(response);
      final membership = dto.toDomain();
      
      // 同步到本地缓存
      await _saveMembership(membership);
      
      log('✅ 版主保证金缴纳成功: \$$amount');
      return Result.success(membership);
    } catch (e) {
      return Result.failure(BusinessLogicException('缴纳保证金失败: $e'));
    }
  }

  @override
  Future<Result<String>> getPaymentUrl(MembershipLevel level) async {
    try {
      // TODO: 调用后端 API 获取支付链接
      // 目前返回模拟链接
      final userId = await _getUserId();
      final url = 'https://payment.example.com/membership/${level.name}?user=$userId';
      return Result.success(url);
    } catch (e) {
      return Result.failure(BusinessLogicException('获取支付链接失败: $e'));
    }
  }

  /// 保存会员信息到本地
  Future<void> _saveMembership(UserMembership membership) async {
    final prefs = await SharedPreferences.getInstance();
    final dto = UserMembershipDto.fromDomain(membership);
    final json = jsonEncode(dto.toJson());
    await prefs.setString(_membershipKey, json);
  }

  /// 保存会员计划到本地缓存
  Future<void> _savePlans(List<MembershipPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = plans.map((p) => {
      'id': p.id,
      'level': p.level,
      'name': p.name,
      'description': p.description,
      'priceYearly': p.priceYearly,
      'priceMonthly': p.priceMonthly,
      'currency': p.currency,
      'icon': p.icon,
      'color': p.color,
      'features': p.features,
      'aiUsageLimit': p.aiUsageLimit,
      'canUseAI': p.canUseAI,
      'canApplyModerator': p.canApplyModerator,
      'moderatorDeposit': p.moderatorDeposit,
    }).toList();
    await prefs.setString(_plansKey, jsonEncode(jsonList));
  }

  /// 从本地缓存加载会员计划
  Future<List<MembershipPlan>> _loadCachedPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_plansKey);
      if (json == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(json);
      return jsonList.map((j) => MembershipPlan(
        id: j['id'] as String? ?? '',
        level: j['level'] as int? ?? 0,
        name: j['name'] as String? ?? '',
        description: j['description'] as String?,
        priceYearly: (j['priceYearly'] as num?)?.toDouble() ?? 0,
        priceMonthly: (j['priceMonthly'] as num?)?.toDouble() ?? 0,
        currency: j['currency'] as String? ?? 'USD',
        icon: j['icon'] as String?,
        color: j['color'] as String?,
        features: (j['features'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        aiUsageLimit: j['aiUsageLimit'] as int? ?? 0,
        canUseAI: j['canUseAI'] as bool? ?? false,
        canApplyModerator: j['canApplyModerator'] as bool? ?? false,
        moderatorDeposit: (j['moderatorDeposit'] as num?)?.toDouble() ?? 0,
      )).toList();
    } catch (e) {
      log('❌ 加载缓存会员计划失败: $e');
      return [];
    }
  }
}
