import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart' as models;
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller_v2.dart';
import 'package:get/get.dart';

/// MemberDetailPage 控制器
class MemberDetailPageController extends GetxController {
  final models.User? initialUser;
  final String? userId;

  MemberDetailPageController({
    this.initialUser,
    this.userId,
  });

  late final UserStateControllerV2 _userController;
  late final AuthStateController _authController;
  
  final Rxn<models.User> user = Rxn<models.User>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  /// 判断当前显示的是否是登录用户自己
  bool get isCurrentUser {
    final currentUserId = _authController.currentUser.value?.id;
    final displayUserId = user.value?.id ?? userId;
    return currentUserId != null && displayUserId != null && currentUserId == displayUserId;
  }

  @override
  void onInit() {
    super.onInit();
    _userController = Get.find<UserStateControllerV2>();
    _authController = Get.find<AuthStateController>();
    user.value = initialUser;
    loadUserDetails();
  }

  /// 从后端获取完整的用户信息
  Future<void> loadUserDetails() async {
    final targetUserId = userId ?? initialUser?.id;
    if (targetUserId == null) {
      isLoading.value = false;
      errorMessage.value = '无法获取用户信息';
      return;
    }

    try {
      final loadedUser = await _userController.getUserById(targetUserId);
      if (loadedUser != null) {
        user.value = loadedUser;
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载用户信息失败';
    }
  }

  /// 重试加载
  void retry() {
    isLoading.value = true;
    errorMessage.value = null;
    loadUserDetails();
  }
}
