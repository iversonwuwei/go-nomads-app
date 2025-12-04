import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_plan.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';
import 'package:df_admin_mobile/features/membership/domain/repositories/membership_repository.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:get/get.dart';

/// 会员状态控制器
///
/// 管理用户会员状态、权限检查、升级流程
/// 优先从 UserStateController 获取会员信息（随用户信息一起返回）
/// 如果用户信息中没有会员数据，则降级到独立 API 请求
class MembershipStateController extends GetxController {
  final MembershipRepository _repository;

  MembershipStateController(this._repository);

  // ==================== 可观察状态 ====================

  /// 当前会员信息
  final _membership = Rx<UserMembership?>(null);

  /// 会员计划列表
  final _plans = <MembershipPlan>[].obs;

  /// 是否正在加载会员信息
  final _isLoading = false.obs;

  /// 是否正在加载计划列表
  final _isLoadingPlans = false.obs;

  /// 是否正在升级
  final _isUpgrading = false.obs;

  /// 错误信息
  final _errorMessage = Rx<String?>(null);

  /// 加载计划失败的错误信息
  final _plansError = Rx<String?>(null);

  /// UserStateController 监听器
  Worker? _userStateWorker;

  // ==================== Getters ====================

  /// 当前会员信息
  UserMembership? get membership => _membership.value;
  Rx<UserMembership?> get membershipRx => _membership;

  /// 会员计划列表
  List<MembershipPlan> get plans => _plans;
  RxList<MembershipPlan> get plansRx => _plans;

  /// 付费计划列表（不包含 Free）
  List<MembershipPlan> get paidPlans => _plans.where((p) => p.level > 0).toList();

  /// 当前会员等级
  MembershipLevel get level => _membership.value?.level ?? MembershipLevel.free;

  /// 是否为付费会员
  bool get isPaidMember => _membership.value?.isPaidMember ?? false;

  /// 会员是否有效
  bool get isActive => _membership.value?.isActive ?? false;

  /// 是否可以使用 AI
  bool get canUseAI => _membership.value?.canUseAI ?? false;

  /// AI 剩余使用次数
  int get aiUsageRemaining => _membership.value?.aiUsageRemaining ?? 0;

  /// 是否可以申请版主
  bool get canApplyModerator => _membership.value?.canApplyModerator ?? false;

  /// 会员剩余天数
  int get remainingDays => _membership.value?.remainingDays ?? 0;

  /// 是否即将过期
  bool get isExpiringSoon => _membership.value?.isExpiringSoon ?? false;

  /// 是否正在加载会员信息
  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;

  /// 是否正在加载计划列表
  bool get isLoadingPlans => _isLoadingPlans.value;
  RxBool get isLoadingPlansRx => _isLoadingPlans;

  /// 是否正在升级
  bool get isUpgrading => _isUpgrading.value;
  RxBool get isUpgradingRx => _isUpgrading;

  /// 错误信息
  String? get errorMessage => _errorMessage.value;

  /// 加载计划失败的错误信息
  String? get plansError => _plansError.value;

  /// 是否有计划加载错误
  bool get hasPlansError => _plansError.value != null && _plans.isEmpty;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    // 加载会员计划列表（独立请求，不依赖用户信息）
    loadPlans();

    // 尝试从 UserStateController 获取会员信息
    _syncFromUserState();

    // 监听用户状态变化，自动同步会员信息
    _setupUserStateListener();
  }

  @override
  void onClose() {
    _userStateWorker?.dispose();
    super.onClose();
  }

  /// 设置用户状态监听器
  void _setupUserStateListener() {
    if (Get.isRegistered<UserStateController>()) {
      final userController = Get.find<UserStateController>();
      _userStateWorker = ever(userController.currentUser, (user) {
        if (user != null && user.membership != null) {
          // 用户信息中包含会员数据，直接使用
          _membership.value = user.membership;
          log('✅ 从用户信息同步会员状态: ${user.membership!.level.name}');
        }
      });
    }
  }

  /// 从 UserStateController 同步会员信息
  void _syncFromUserState() {
    if (Get.isRegistered<UserStateController>()) {
      final userController = Get.find<UserStateController>();
      final user = userController.currentUser.value;

      if (user != null && user.membership != null) {
        _membership.value = user.membership;
        log('✅ 从用户信息初始化会员状态: ${user.membership!.level.name}');
        return;
      }
    }

    // 如果用户信息中没有会员数据，降级到独立 API 请求
    log('⚠️ 用户信息中无会员数据，使用独立 API 加载');
    loadMembership();
  }

  // ==================== 业务方法 ====================

  /// 加载会员计划列表
  Future<void> loadPlans() async {
    _isLoadingPlans.value = true;
    _plansError.value = null;

    try {
      final result = await _repository.getPlans();
      result.fold(
        onSuccess: (plans) {
          _plans.assignAll(plans);
          _plansError.value = null;
          log('✅ 加载会员计划成功: ${plans.length} 个');
        },
        onFailure: (exception) {
          _plansError.value = exception.message;
          log('❌ 加载会员计划失败: ${exception.message}');
        },
      );
    } finally {
      _isLoadingPlans.value = false;
    }
  }

  /// 根据等级获取计划
  MembershipPlan? getPlanByLevel(int level) {
    return _plans.where((p) => p.level == level).firstOrNull;
  }

  /// 加载会员信息
  Future<void> loadMembership() async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      final result = await _repository.getCurrentMembership();
      result.fold(
        onSuccess: (membership) {
          _membership.value = membership;
          log('✅ 加载会员信息成功: ${membership.level.name}');
        },
        onFailure: (exception) {
          _errorMessage.value = exception.message;
          log('❌ 加载会员信息失败: ${exception.message}');
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// 升级会员
  Future<bool> upgradeMembership(MembershipLevel level) async {
    if (_isUpgrading.value) return false;

    _isUpgrading.value = true;
    _errorMessage.value = null;

    try {
      final result = await _repository.upgradeMembership(level);
      return result.fold(
        onSuccess: (membership) {
          _membership.value = membership;
          log('✅ 会员升级成功: ${level.name}');
          return true;
        },
        onFailure: (exception) {
          _errorMessage.value = exception.message;
          log('❌ 会员升级失败: ${exception.message}');
          return false;
        },
      );
    } finally {
      _isUpgrading.value = false;
    }
  }

  /// 检查是否可以使用 AI 功能
  /// 返回 null 表示可以使用，否则返回提示信息
  String? checkAIAccess() {
    final membership = _membership.value;

    if (membership == null) {
      return '请先登录';
    }

    if (!membership.level.canUseAI) {
      return '升级到 Basic 会员即可使用 AI 功能';
    }

    if (membership.isExpired) {
      return '您的会员已过期，请续费后使用';
    }

    final limit = membership.level.aiUsageLimit;
    if (limit > 0 && membership.aiUsageThisMonth >= limit) {
      return '本月 AI 使用次数已达上限 ($limit 次)，升级会员可获得更多次数';
    }

    return null; // 可以使用
  }

  /// 检查是否可以申请版主
  /// 返回 null 表示可以申请，否则返回提示信息
  String? checkModeratorAccess() {
    final membership = _membership.value;

    if (membership == null) {
      return '请先登录';
    }

    if (!membership.level.canApplyModerator) {
      return '升级到 Pro 或 Premium 会员才能申请成为版主';
    }

    if (membership.isExpired) {
      return '您的会员已过期，请续费后申请';
    }

    return null; // 可以申请
  }

  /// 获取版主保证金金额
  int getModeratorDepositAmount() {
    return _membership.value?.level.moderatorDeposit ?? 0;
  }

  /// 增加 AI 使用次数
  Future<void> incrementAIUsage() async {
    final result = await _repository.incrementAiUsage();
    result.onSuccess((membership) {
      _membership.value = membership;
    });
  }

  /// 缴纳版主保证金
  Future<bool> payModeratorDeposit(double amount) async {
    _isUpgrading.value = true;
    try {
      final result = await _repository.payModeratorDeposit(amount);
      return result.fold(
        onSuccess: (membership) {
          _membership.value = membership;
          return true;
        },
        onFailure: (exception) {
          _errorMessage.value = exception.message;
          return false;
        },
      );
    } finally {
      _isUpgrading.value = false;
    }
  }

  /// 取消自动续费
  Future<bool> cancelAutoRenew() async {
    final result = await _repository.cancelAutoRenew();
    if (result.isSuccess) {
      await loadMembership();
      return true;
    }
    return false;
  }

  /// 开启自动续费
  Future<bool> enableAutoRenew() async {
    final result = await _repository.enableAutoRenew();
    if (result.isSuccess) {
      await loadMembership();
      return true;
    }
    return false;
  }

  /// 获取支付链接
  Future<String?> getPaymentUrl(MembershipLevel level) async {
    final result = await _repository.getPaymentUrl(level);
    return result.dataOrNull;
  }

  /// 清除会员信息（用于退出登录）
  void clearMembership() {
    _membership.value = null;
    _errorMessage.value = null;
  }
}
