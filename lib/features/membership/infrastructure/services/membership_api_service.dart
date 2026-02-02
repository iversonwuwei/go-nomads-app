import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_plan.dart';
import 'package:go_nomads_app/features/membership/infrastructure/dtos/user_membership_dto.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:dio/dio.dart';

/// 会员服务 API 客户端
/// 用于会员信息获取、升级、续费等操作
/// 注意: 所有请求通过 Gateway 统一转发到 UserService
class MembershipApiService {
  static final MembershipApiService _instance = MembershipApiService._internal();
  factory MembershipApiService() => _instance;

  late final Dio _dio;
  final TokenStorageService _tokenService = TokenStorageService();

  MembershipApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}/api',
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 10000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加认证拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => log('🔵 [MembershipService via Gateway] $obj'),
    ));
  }

  /// 获取当前用户会员信息
  Future<MembershipResponse> getMembership() async {
    try {
      final response = await _dio.get('/v1/membership');
      return MembershipResponse.fromJson(response.data);
    } catch (e) {
      log('❌ 获取会员信息失败: $e');
      rethrow;
    }
  }

  /// 获取所有会员计划（公开接口，无需认证）
  Future<List<MembershipPlanResponse>> getPlans() async {
    try {
      final response = await _dio.get('/v1/membership/plans');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => MembershipPlanResponse.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      log('❌ 获取会员计划失败: $e');
      rethrow;
    }
  }

  /// 获取指定等级的会员计划
  Future<MembershipPlanResponse> getPlanByLevel(int level) async {
    try {
      final response = await _dio.get('/v1/membership/plans/$level');
      return MembershipPlanResponse.fromJson(response.data);
    } catch (e) {
      log('❌ 获取会员计划失败: $e');
      rethrow;
    }
  }

  /// 升级会员
  Future<MembershipResponse> upgradeMembership({
    required int level,
    int durationDays = 365,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/membership/upgrade',
        data: {
          'level': level,
          'durationDays': durationDays,
        },
      );
      return MembershipResponse.fromJson(response.data);
    } catch (e) {
      log('❌ 升级会员失败: $e');
      rethrow;
    }
  }

  /// 缴纳保证金
  Future<MembershipResponse> payDeposit(double amount) async {
    try {
      final response = await _dio.post(
        '/v1/membership/deposit',
        data: {'amount': amount},
      );
      return MembershipResponse.fromJson(response.data);
    } catch (e) {
      log('❌ 缴纳保证金失败: $e');
      rethrow;
    }
  }

  /// 设置自动续费
  Future<MembershipResponse> setAutoRenew(bool enabled) async {
    try {
      final response = await _dio.post(
        '/v1/membership/auto-renew',
        data: {'enabled': enabled},
      );
      return MembershipResponse.fromJson(response.data);
    } catch (e) {
      log('❌ 设置自动续费失败: $e');
      rethrow;
    }
  }

  /// 记录 AI 使用
  Future<bool> recordAiUsage() async {
    try {
      final response = await _dio.post('/v1/membership/ai-usage');
      return response.data['success'] as bool? ?? false;
    } catch (e) {
      log('❌ 记录 AI 使用失败: $e');
      return false;
    }
  }

  /// 检查 AI 使用配额
  Future<AiUsageCheckResponse> checkAiUsage() async {
    try {
      final response = await _dio.get('/v1/membership/ai-usage/check');
      return AiUsageCheckResponse.fromJson(response.data);
    } catch (e) {
      log('❌ 检查 AI 配额失败: $e');
      rethrow;
    }
  }

  /// 转换为 UserMembershipDto
  UserMembershipDto toUserMembershipDto(MembershipResponse response) {
    return UserMembershipDto(
      userId: response.userId,
      level: response.levelName.toLowerCase(),
      startDate: response.startDate?.toIso8601String(),
      expiryDate: response.expiryDate?.toIso8601String(),
      autoRenew: response.autoRenew,
      aiUsageThisMonth: response.aiUsageThisMonth,
      isModerator: response.canApplyModerator,
      moderatorDeposit: response.moderatorDeposit,
    );
  }

  /// 转换 MembershipPlanResponse 为领域实体
  MembershipPlan toPlanEntity(MembershipPlanResponse response) {
    return MembershipPlan(
      id: response.id,
      level: response.level,
      name: response.name,
      description: response.description,
      priceYearly: response.priceYearly,
      priceMonthly: response.priceMonthly,
      currency: response.currency,
      icon: response.icon,
      color: response.color,
      features: response.features,
      aiUsageLimit: response.aiUsageLimit,
      canUseAI: response.canUseAI,
      canApplyModerator: response.canApplyModerator,
      moderatorDeposit: response.moderatorDeposit,
    );
  }
}

/// 会员信息响应
class MembershipResponse {
  final String id;
  final String userId;
  final int level;
  final String levelName;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool autoRenew;
  final int aiUsageThisMonth;
  final int aiUsageLimit;
  final double? moderatorDeposit;
  final bool isActive;
  final bool isExpired;
  final int remainingDays;
  final bool isExpiringSoon;
  final bool canUseAI;
  final bool canApplyModerator;

  MembershipResponse({
    required this.id,
    required this.userId,
    required this.level,
    required this.levelName,
    this.startDate,
    this.expiryDate,
    this.autoRenew = false,
    this.aiUsageThisMonth = 0,
    this.aiUsageLimit = 0,
    this.moderatorDeposit,
    this.isActive = false,
    this.isExpired = false,
    this.remainingDays = 0,
    this.isExpiringSoon = false,
    this.canUseAI = false,
    this.canApplyModerator = false,
  });

  factory MembershipResponse.fromJson(Map<String, dynamic> json) {
    return MembershipResponse(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      levelName: json['levelName'] as String? ?? 'Free',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
      autoRenew: json['autoRenew'] as bool? ?? false,
      aiUsageThisMonth: json['aiUsageThisMonth'] as int? ?? 0,
      aiUsageLimit: json['aiUsageLimit'] as int? ?? 0,
      moderatorDeposit: (json['moderatorDeposit'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? false,
      isExpired: json['isExpired'] as bool? ?? false,
      remainingDays: json['remainingDays'] as int? ?? 0,
      isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
      canUseAI: json['canUseAI'] as bool? ?? false,
      canApplyModerator: json['canApplyModerator'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'level': level,
      'levelName': levelName,
      'startDate': startDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'autoRenew': autoRenew,
      'aiUsageThisMonth': aiUsageThisMonth,
      'aiUsageLimit': aiUsageLimit,
      'moderatorDeposit': moderatorDeposit,
      'isActive': isActive,
      'isExpired': isExpired,
      'remainingDays': remainingDays,
      'isExpiringSoon': isExpiringSoon,
      'canUseAI': canUseAI,
      'canApplyModerator': canApplyModerator,
    };
  }
}

/// 会员计划响应
class MembershipPlanResponse {
  final String id;
  final int level;
  final String name;
  final String? description;
  final double priceYearly;
  final double priceMonthly;
  final String currency;
  final String? icon;
  final String? color;
  final List<String> features;
  final int aiUsageLimit;
  final bool canUseAI;
  final bool canApplyModerator;
  final double moderatorDeposit;

  MembershipPlanResponse({
    required this.id,
    required this.level,
    required this.name,
    this.description,
    this.priceYearly = 0,
    this.priceMonthly = 0,
    this.currency = 'USD',
    this.icon,
    this.color,
    this.features = const [],
    this.aiUsageLimit = 0,
    this.canUseAI = false,
    this.canApplyModerator = false,
    this.moderatorDeposit = 0,
  });

  factory MembershipPlanResponse.fromJson(Map<String, dynamic> json) {
    return MembershipPlanResponse(
      id: json['id'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      priceYearly: (json['priceYearly'] as num?)?.toDouble() ?? 0,
      priceMonthly: (json['priceMonthly'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      features: (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      aiUsageLimit: json['aiUsageLimit'] as int? ?? 0,
      canUseAI: json['canUseAI'] as bool? ?? false,
      canApplyModerator: json['canApplyModerator'] as bool? ?? false,
      moderatorDeposit: (json['moderatorDeposit'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'name': name,
      'description': description,
      'priceYearly': priceYearly,
      'priceMonthly': priceMonthly,
      'currency': currency,
      'icon': icon,
      'color': color,
      'features': features,
      'aiUsageLimit': aiUsageLimit,
      'canUseAI': canUseAI,
      'canApplyModerator': canApplyModerator,
      'moderatorDeposit': moderatorDeposit,
    };
  }
}

/// AI 使用配额检查响应
class AiUsageCheckResponse {
  final bool canUse;
  final int level;
  final String levelName;
  final int limit;
  final int used;
  final int remaining;
  final bool isUnlimited;
  final DateTime? resetDate;

  AiUsageCheckResponse({
    required this.canUse,
    required this.level,
    required this.levelName,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.isUnlimited,
    this.resetDate,
  });

  factory AiUsageCheckResponse.fromJson(Map<String, dynamic> json) {
    return AiUsageCheckResponse(
      canUse: json['canUse'] as bool? ?? false,
      level: json['level'] as int? ?? 0,
      levelName: json['levelName'] as String? ?? 'Free',
      limit: json['limit'] as int? ?? 0,
      used: json['used'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 0,
      isUnlimited: json['isUnlimited'] as bool? ?? false,
      resetDate: json['resetDate'] != null ? DateTime.tryParse(json['resetDate'] as String) : null,
    );
  }
}
