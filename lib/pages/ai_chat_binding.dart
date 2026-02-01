import 'package:get/get.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/pages/ai_chat_controller.dart';
import 'package:go_nomads_app/services/ai_chat_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';

class AiChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiChatService>(() => AiChatService());
    // SignalRService 是单例工厂，Get 保留引用，避免重复连接
    Get.put<SignalRService>(SignalRService(), permanent: true);

    Get.lazyPut<AiChatController>(
      () => AiChatController(
        Get.find<AiChatService>(),
        Get.find<AuthStateController>(),
        Get.find<SignalRService>(),
      ),
    );
  }
}
