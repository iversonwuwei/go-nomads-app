import 'package:get/get.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';

/// AI Chat 页面绑定
/// 注册页面所需的依赖
class AiChatBinding extends Bindings {
  @override
  void dependencies() {
    // AI Chat Service
    Get.lazyPut<AiChatService>(() => AiChatService());
    
    // SignalR Service (单例，避免重复连接)
    Get.put<SignalRService>(SignalRService(), permanent: true);

    // AI Chat Controller
    Get.lazyPut<AiChatController>(
      () => AiChatController(
        Get.find<AiChatService>(),
        Get.find<AuthStateController>(),
        Get.find<SignalRService>(),
      ),
    );
  }
}
