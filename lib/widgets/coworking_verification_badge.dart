import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingVerificationBadge extends StatelessWidget {
  CoworkingVerificationBadge({
    super.key,
    required this.space,
    this.onVerified,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final CoworkingSpace space;
  final void Function(CoworkingSpace updatedSpace)? onVerified;
  final EdgeInsetsGeometry padding;

  final CoworkingStateController _coworkingController =
      Get.find<CoworkingStateController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();

  bool get _isCreator {
    if (space.isOwner) {
      return true;
    }

    final currentUser = _userStateController.currentUser.value;
    if (currentUser == null) return false;
    if (space.createdBy == null || space.createdBy!.isEmpty) return false;
    return currentUser.id.toLowerCase() == space.createdBy!.toLowerCase();
  }

  bool get _canCurrentUserVerify {
    final currentUser = _userStateController.currentUser.value;
    if (currentUser == null) return false;
    if (space.isVerified) return false;
    if (_isCreator) return false;
    return true;
  }

  Future<void> _handleTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = _userStateController.currentUser.value;
    if (currentUser == null) {
      AppToast.error(l10n.coworkingVerifyLoginRequired);
      return;
    }

    if (!_canCurrentUserVerify) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.coworkingVerifyTitle),
          content: Text(l10n.coworkingVerifyMessage(space.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final result = await _coworkingController.submitVerification(space.id);

    switch (result) {
      case Success(:final data):
        onVerified?.call(data);
        AppToast.success(l10n.coworkingVerifySuccess);
      case Failure(:final exception):
        final message = exception.message.isNotEmpty
            ? exception.message
            : l10n.coworkingVerifyFailed;
        AppToast.error(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isVerifying =
          _coworkingController.verifyingCoworkingIds.contains(space.id);
      final bool canTap = _canCurrentUserVerify && !isVerifying;

      final Color backgroundColor =
          space.isVerified ? Colors.blue : Colors.grey;
      final IconData iconData = space.isVerified
          ? FontAwesomeIcons.solidCircleCheck
          : FontAwesomeIcons.circleCheck;
      final String label = space.isVerified ? l10n.verified : l10n.unverified;

      final badge = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isVerifying)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(iconData, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

      if (!canTap) {
        return badge;
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleTap(context),
          child: badge,
        ),
      );
    });
  }
}
