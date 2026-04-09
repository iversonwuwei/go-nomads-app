import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/entities/migration_workspace.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';

abstract class IMigrationWorkspaceRepository {
  Future<Result<MigrationWorkspace>> getMigrationWorkspace({
    int page = 1,
    int pageSize = 20,
  });

  Future<Result<MigrationWorkspace>> savePlanState({
    required String planId,
    required String stage,
    String? focusNote,
    List<MigrationChecklistItem> checklist = const [],
    List<MigrationTimelineItem> timeline = const [],
  });
}
