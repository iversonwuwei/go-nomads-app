import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/budget/domain/repositories/i_budget_center_repository.dart';
import 'package:go_nomads_app/features/budget/infrastructure/repositories/budget_center_repository.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/repositories/i_migration_workspace_repository.dart';
import 'package:go_nomads_app/features/migration_workspace/infrastructure/repositories/migration_workspace_repository.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/repositories/i_inbox_summary_repository.dart';
import 'package:go_nomads_app/features/navigation_hub/infrastructure/repositories/inbox_summary_repository.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/controllers/inbox_hub_controller.dart';
import 'package:go_nomads_app/features/visa/domain/repositories/i_visa_center_repository.dart';
import 'package:go_nomads_app/features/visa/infrastructure/repositories/visa_center_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

class InboxHubBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IMigrationWorkspaceRepository>()) {
      Get.lazyPut<IMigrationWorkspaceRepository>(
        () => MigrationWorkspaceRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IBudgetCenterRepository>()) {
      Get.lazyPut<IBudgetCenterRepository>(
        () => BudgetCenterRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IVisaCenterRepository>()) {
      Get.lazyPut<IVisaCenterRepository>(
        () => VisaCenterRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IInboxSummaryRepository>()) {
      Get.lazyPut<IInboxSummaryRepository>(
        () => InboxSummaryRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    BindingHelper.putFresh<InboxHubController>(
      () => InboxHubController(
        Get.find<IInboxSummaryRepository>(),
        Get.find<IMigrationWorkspaceRepository>(),
        Get.find<IBudgetCenterRepository>(),
        Get.find<IVisaCenterRepository>(),
      ),
    );
  }
}