import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/data_service_controller.dart';
import '../generated/app_localizations.dart';
import '../models/user_model.dart' as models;
import '../widgets/app_toast.dart';
import 'create_meetup_page.dart';

class InviteToMeetupPage extends StatelessWidget {
  final models.UserModel user;

  const InviteToMeetupPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DataServiceController>();
    final myMeetups = controller.upcomingMeetups;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a1a1a)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.invite} ${user.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
            Text(
              l10n.selectMeetup,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6b7280),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: myMeetups.isEmpty
          ? _buildEmptyMeetupState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myMeetups.length,
              itemBuilder: (context, index) {
                final meetup = myMeetups[index];
                return _buildMeetupInviteCard(context, meetup);
              },
            ),
    );
  }

  // 空状�?
  Widget _buildEmptyMeetupState() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: const Color(0xFF6b7280).withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noData,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.createMeetup,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6b7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateMeetupPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createMeetup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Meetup 邀请卡�?
  Widget _buildMeetupInviteCard(
    BuildContext context,
    Map<String, dynamic> meetup,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _inviteToMeetup(context, meetup),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Meetup Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: Color(0xFF10B981),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                // Meetup Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meetup['title'] ?? 'Untitled Meetup',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF6b7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            meetup['date'] != null
                                ? '${(meetup['date'] as DateTime).month}/${(meetup['date'] as DateTime).day}/${(meetup['date'] as DateTime).year}'
                                : 'Date TBD',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFF6b7280),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meetup['location'] ?? 'Location TBD',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6b7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF9ca3af),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 邀请到 Meetup
  void _inviteToMeetup(BuildContext context, Map<String, dynamic> meetup) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.confirm,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                '${l10n.invite} ${user.name}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6b7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetup['title'] ?? 'Untitled Meetup',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF6b7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meetup['date'] != null
                              ? '${(meetup['date'] as DateTime).month}/${(meetup['date'] as DateTime).day}/${(meetup['date'] as DateTime).year}${meetup['time'] != null ? ' at ${meetup['time']}' : ''}'
                              : 'Date TBD',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          color: Color(0xFF6b7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 实现实际的邀请逻辑
                        Navigator.pop(context);
                        AppToast.success(
                          '${user.name} ${l10n.sendInvitation}',
                          title: l10n.success,
                        );
                        // 返回上一�?
                        Navigator.pop(Get.context!);
                      },
                      icon: const Icon(Icons.send, size: 18),
                      label: Text(l10n.sendInvitation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
