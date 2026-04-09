import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/repositories/i_migration_workspace_repository.dart';
import 'package:go_nomads_app/features/migration_workspace/infrastructure/repositories/migration_workspace_repository.dart';
import 'package:go_nomads_app/features/migration_workspace/presentation/controllers/migration_workspace_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';

class MigrationWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IMigrationWorkspaceRepository>()) {
      Get.lazyPut<IMigrationWorkspaceRepository>(
        () => MigrationWorkspaceRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    BindingHelper.putFresh<MigrationWorkspaceController>(
      () => MigrationWorkspaceController(Get.find<IMigrationWorkspaceRepository>()),
    );
  }
}