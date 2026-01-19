import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/verification_eligibility.dart';
import 'package:go_nomads_app/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingVerificationBadge extends StatelessWidget {
  CoworkingVerificationBadge({
    super.key,
    required this.space,
    this.onVerified,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.darkTheme = false,
  });

  final CoworkingSpace space;
  final void Function(CoworkingSpace updatedSpace)? onVerified;
  final EdgeInsetsGeometry padding;
  final bool darkTheme;

  final CoworkingStateController _coworkingController = Get.find<CoworkingStateController>();
  final UserStateController _userStateController = Get.find<UserStateController>();

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

    // 检查是否登录
    if (currentUser == null) {
      AppToast.error(l10n.coworkingVerifyLoginRequired);
      return;
    }

    // 前端基本检查
    if (!_canCurrentUserVerify) {
      if (space.isVerified) {
        AppToast.info(l10n.coworkingVerifySpaceVerified);
      } else if (_isCreator) {
        AppToast.warning(l10n.coworkingVerifyIsCreator);
      }
      return;
    }

    // 调用后端 API 检查验证资格
    final eligibilityResult = await _coworkingController.checkVerificationEligibility(space.id);

    // 检查 context 是否仍然有效
    if (!context.mounted) return;

    switch (eligibilityResult) {
      case Success(:final data):
        if (!data.canVerify) {
          // 根据原因代码显示对应的提示
          _showEligibilityError(context, data, l10n);
          return;
        }
        // 可以验证，显示确认对话框
        _showVerificationDialog(context, l10n);
      case Failure(:final exception):
        // API 调用失败，显示错误
        AppToast.error(exception.message);
    }
  }

  void _showEligibilityError(BuildContext context, VerificationEligibility eligibility, AppLocalizations l10n) {
    switch (eligibility.reasonCode) {
      case 'ALREADY_VOTED':
        AppToast.warning(l10n.coworkingVerifyAlreadyVoted);
        break;
      case 'IS_CREATOR':
        AppToast.warning(l10n.coworkingVerifyIsCreator);
        break;
      case 'SPACE_VERIFIED':
        AppToast.info(l10n.coworkingVerifySpaceVerified);
        break;
      default:
        AppToast.error(eligibility.reason ?? l10n.coworkingVerifyFailed);
    }
  }

  Future<void> _showVerificationDialog(BuildContext context, AppLocalizations l10n) async {
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
        final message = exception.message.isNotEmpty ? exception.message : l10n.coworkingVerifyFailed;
        AppToast.error(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isVerifying = _coworkingController.verifyingCoworkingIds.contains(space.id);
      // 未验证的空间允许点击（包括创建者，点击时会显示提示）
      final bool canTap = !space.isVerified && !isVerifying;

      // 获取实时验证人数（优先使用实时数据）
      final int verificationVotes = _coworkingController.getVerificationVotes(space);

      // 深色主题样式（用于图片上层显示）
      Color backgroundColor;
      if (darkTheme) {
        backgroundColor = space.isVerified ? Colors.blue.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3);
      } else {
        backgroundColor = space.isVerified ? Colors.blue : Colors.grey;
      }
      
      final IconData iconData = space.isVerified ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circleCheck;
      final String label = space.isVerified ? l10n.verified : l10n.unverified;

      final badge = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: darkTheme
              ? Border.all(
                  color: space.isVerified ? Colors.blue.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
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
            // 显示验证人数（未验证时显示）
            if (!space.isVerified) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$verificationVotes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
