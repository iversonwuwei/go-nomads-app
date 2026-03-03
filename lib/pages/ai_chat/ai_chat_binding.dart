import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';

/// AI Chat 页面绑定
///
/// 每次进入页面时创建全新控制器，确保聊天状态干净。
class AiChatBinding extends Bindings {
  @override
  void dependencies() {
    // AI Chat Service（每次全新创建）
    if (Get.isRegistered<AiChatService>()) {
      Get.delete<AiChatService>(force: true);
    }
    Get.lazyPut<AiChatService>(() => AiChatService());

    // SignalR Service (单例，持久化)
    if (!Get.isRegistered<SignalRService>()) {
      Get.put<SignalRService>(SignalRService(), permanent: true);
    }

    // AI Chat Controller（每次全新创建）
    BindingHelper.putFresh<AiChatController>(
      () => AiChatController(
        Get.find<AiChatService>(),
        Get.find<AuthStateController>(),
        Get.find<SignalRService>(),
      ),
    );
  }
}
