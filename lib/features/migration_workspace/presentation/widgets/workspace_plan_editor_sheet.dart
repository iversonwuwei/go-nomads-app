import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

class WorkspacePlanEditResult {
  final String stage;
  final String? focusNote;
  final List<MigrationChecklistItem> checklist;
  final List<MigrationTimelineItem> timeline;

  const WorkspacePlanEditResult({
    required this.stage,
    required this.focusNote,
    required this.checklist,
    required this.timeline,
  });
}

Future<WorkspacePlanEditResult?> showWorkspacePlanEditor(
  BuildContext context,
  TravelPlanSummary plan,
) async {
  final l10n = AppLocalizations.of(context)!;
  final stageController = TextEditingController(text: plan.migrationStage);
  final noteController = TextEditingController(text: plan.focusNote ?? '');
  final checklistController = TextEditingController(
    text: plan.checklist
        .map((item) => '${item.isCompleted ? '[x]' : '[ ]'} ${item.title}')
        .join('\n'),
  );
  final timelineController = TextEditingController(
    text: plan.timeline.map((item) {
      final datePrefix = item.targetDate == null
          ? ''
          : '${item.targetDate!.year.toString().padLeft(4, '0')}-${item.targetDate!.month.toString().padLeft(2, '0')}-${item.targetDate!.day.toString().padLeft(2, '0')} | ';
      return '$datePrefix${item.title}';
    }).join('\n'),
  );

  try {
    return await AppBottomDrawer.show<WorkspacePlanEditResult>(
      context,
      title: l10n.migrationWorkspaceEditTitle,
      subtitle: plan.cityName,
      child: Column(
        children: [
          TextField(
            controller: stageController,
            decoration: InputDecoration(labelText: l10n.migrationWorkspaceStageLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.notes),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: checklistController,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.migrationWorkspaceChecklistLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: timelineController,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.migrationWorkspaceTimelineLabel),
          ),
        ],
      ),
      footer: AppBottomDrawerActionRow(
        secondaryLabel: l10n.cancel,
        onSecondaryPressed: () => Get.back<WorkspacePlanEditResult?>(),
        primaryLabel: l10n.saveChanges,
        onPrimaryPressed: () {
          final focusNote = noteController.text.trim();
          Get.back<WorkspacePlanEditResult>(
            result: WorkspacePlanEditResult(
              stage: stageController.text.trim(),
              focusNote: focusNote.isEmpty ? null : focusNote,
              checklist: _parseChecklist(checklistController.text),
              timeline: _parseTimeline(timelineController.text),
            ),
          );
        },
      ),
    );
  } finally {
    stageController.dispose();
    noteController.dispose();
    checklistController.dispose();
    timelineController.dispose();
  }
}

List<MigrationChecklistItem> _parseChecklist(String raw) {
  return raw
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) {
    final isCompleted = line.startsWith('[x]') || line.startsWith('[X]');
    final title = line.replaceFirst(RegExp(r'^\[(x|X| )\]\s*'), '').trim();
    return MigrationChecklistItem(
      id: title.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
      title: title,
      isCompleted: isCompleted,
    );
  }).toList();
}

List<MigrationTimelineItem> _parseTimeline(String raw) {
  return raw
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) {
    final segments = line.split('|').map((item) => item.trim()).toList();
    DateTime? targetDate;
    String title;
    if (segments.length > 1) {
      targetDate = DateTime.tryParse(segments.first);
      title = segments.sublist(1).join(' | ');
    } else {
      title = line;
    }

    return MigrationTimelineItem(
      id: title.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
      title: title,
      status: 'pending',
      targetDate: targetDate,
    );
  }).toList();
}
