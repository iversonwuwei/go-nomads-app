import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/membership/domain/entities/ai_usage_check.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_level.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_plan.dart';
import 'package:go_nomads_app/features/membership/domain/entities/user_membership.dart';
import 'package:go_nomads_app/features/membership/domain/repositories/membership_repository.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';

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

  /// 是否为月付模式（false = 年付）
  final _isMonthlyBilling = false.obs;

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

  /// 是否为月付模式
  bool get isMonthlyBilling => _isMonthlyBilling.value;
  RxBool get isMonthlyBillingRx => _isMonthlyBilling;

  /// 切换计费周期
  void toggleBillingCycle() => _isMonthlyBilling.value = !_isMonthlyBilling.value;

  /// 设置计费周期
  void setMonthlyBilling(bool isMonthly) => _isMonthlyBilling.value = isMonthly;

  /// 当前选中的计费天数
  int get billingDurationDays => _isMonthlyBilling.value ? 30 : 365;

  /// 当前会员的计费周期
  BillingCycle get currentBillingCycle => _membership.value?.billingCycle ?? BillingCycle.yearly;

  /// 是否可以切换到月付（年付会员在有效期内不能切换为月付）
  bool get canSwitchToMonthly {
    final m = _membership.value;
    if (m == null) return true;
    // 年付会员在有效期内不能切换为月付
    if (m.isYearly && m.isActive) return false;
    return true;
  }

  /// 是否可以切换到年付（月付用户可以随时升级为年付）
  bool get canSwitchToYearly => true;

  /// 检查指定计划卡片是否应该置灰（当前计划 + 匹配的计费周期 tab）
  bool shouldGreyOutPlan(int planLevel) {
    final m = _membership.value;
    if (m == null) return false;
    // 只有当计划等级匹配 AND 计费周期匹配当前 tab 时才置灰
    if (m.level.levelValue != planLevel) return false;
    if (!m.isActive) return false;
    // 当前 tab 的计费周期与用户实际计费周期一致时置灰
    if (_isMonthlyBilling.value && m.isMonthly) return true;
    if (!_isMonthlyBilling.value && m.isYearly) return true;
    return false;
  }

  /// 获取当前选中的 BillingCycle 枚举
  BillingCycle get selectedBillingCycle => _isMonthlyBilling.value ? BillingCycle.monthly : BillingCycle.yearly;

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
    // ⚡ 优化：不在初始化时加载计划列表，改为按需加载
    // 计划列表将在用户进入会员页面时加载

    // 尝试从 UserStateController 获取会员信息（如果用户已登录）
    _syncFromUserState();

    // 监听用户状态变化，自动同步会员信息
    _setupUserStateListener();

    log('🎬 MembershipStateController 初始化完成（延迟加载模式）');
  }

  /// 确保计划数据已加载（供页面调用）
  Future<void> ensurePlansLoaded() async {
    if (_plans.isEmpty && !_isLoadingPlans.value) {
      log('📦 MembershipStateController: 触发计划列表加载');
      await loadPlans();
    }
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
        if (user == null) {
          // 用户登出，清除会员信息
          _membership.value = null;
          log('🚪 用户登出，清除会员状态');
        } else if (user.membership != null) {
          // 用户信息中包含会员数据，直接使用
          _membership.value = user.membership;
          log('✅ 从用户信息同步会员状态: ${user.membership!.level.name}');
        } else {
          // 新用户登录但没有会员数据，清除旧数据并重新加载
          _membership.value = null;
          log('⚠️ 新用户无会员数据，尝试加载');
          loadMembership();
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
  Future<bool> upgradeMembership(MembershipLevel level, {BillingCycle? billingCycle}) async {
    if (_isUpgrading.value) return false;

    _isUpgrading.value = true;
    _errorMessage.value = null;

    final cycle = billingCycle ?? selectedBillingCycle;

    try {
      final result = await _repository.upgradeMembership(level, billingCycle: cycle);
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

    // 付费会员过期检查
    if (membership.level != MembershipLevel.free && membership.isExpired) {
      return '您的会员已过期，请续费后使用';
    }

    // 检查 AI 使用次数限制
    final limit = membership.level.aiUsageLimit;
    if (limit > 0 && membership.aiUsageThisMonth >= limit) {
      if (membership.level == MembershipLevel.free) {
        return '免费用户本月 AI 使用次数已达上限 ($limit 次)，升级会员可获得更多次数';
      }
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

  /// 检查 AI 配额（从后端获取最新状态）
  Future<AiUsageCheck> checkAiQuota() async {
    // Admin 用户直接返回无限制
    final isAdmin = await TokenStorageService().isAdmin();
    if (isAdmin) {
      log('✅ Admin 用户，AI 无限制');
      return const AiUsageCheck(
        canUse: true,
        level: MembershipLevel.premium,
        limit: -1,
        used: 0,
        remaining: -1,
        isUnlimited: true,
      );
    }

    final result = await _repository.checkAiUsage();
    return result.fold(
      onSuccess: (check) {
        log('✅ AI 配额检查: ${check.usageMessage}');
        return check;
      },
      onFailure: (_) => AiUsageCheck.free(),
    );
  }

  /// 尝试使用 AI（检查配额并记录使用）
  /// 返回 true 表示可以继续，false 表示配额不足
  Future<bool> tryUseAI() async {
    // Admin 用户无限制
    final isAdmin = await TokenStorageService().isAdmin();
    if (isAdmin) {
      return true;
    }

    // 先检查配额
    final check = await checkAiQuota();

    if (!check.canUse) {
      log('❌ AI 配额不足: ${check.usageMessage}');
      return false;
    }

    // 记录使用
    await incrementAIUsage();
    return true;
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
