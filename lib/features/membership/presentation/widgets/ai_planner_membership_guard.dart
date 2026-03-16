import 'package:flutter/material.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_planner_access_service.dart';

/// AI 旅行规划师页面会员守卫
class AiPlannerMembershipGuard extends StatefulWidget {
  final Widget child;

  const AiPlannerMembershipGuard({super.key, required this.child});

  @override
  State<AiPlannerMembershipGuard> createState() => _AiPlannerMembershipGuardState();
}

class _AiPlannerMembershipGuardState extends State<AiPlannerMembershipGuard> {
  bool _checking = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

  Future<void> _checkAccess() async {
    final allowed = await AiPlannerAccessService().ensureAccess(
      featureName: 'AI 旅行规划师',
      showUpgradeDialog: false,
    );

    if (!mounted) {
      return;
    }

    if (!allowed) {
      AiPlannerAccessService().redirectToMembership(featureName: 'AI 旅行规划师');
      setState(() {
        _checking = false;
        _allowed = false;
      });
      return;
    }

    setState(() {
      _checking = false;
      _allowed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_allowed) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    return widget.child;
  }
}