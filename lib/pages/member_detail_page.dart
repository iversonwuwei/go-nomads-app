import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/data_service_controller.dart';
import '../models/user_model.dart' as models;
import 'direct_chat_page.dart';

class MemberDetailPage extends StatelessWidget {
  final models.UserModel user;

  const MemberDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with User Avatar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF1a1a1a),
                  size: 20,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // User Avatar
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFF4458).withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'user_avatar_${user.id}',
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 73,
                            backgroundImage: NetworkImage(
                              user.avatarUrl ?? 'https://i.pravatar.cc/300',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Verified Badge (if verified)
                  if (user.isVerified)
                    Positioned(
                      top: 180,
                      right: 0,
                      left: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Username
                  Center(
                    child: Column(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9ca3af),
                          ),
                        ),
                        if (user.currentCity != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Color(0xFFFF4458),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.currentCity}, ${user.currentCountry ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6b7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bio Section
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    _buildSectionTitle('About'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        user.bio!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Color(0xFF4b5563),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Interests Section
                  if (user.interests.isNotEmpty) ...[
                    _buildSectionTitle('Interests'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.interests.map((interest) {
                        return _buildTag(
                          interest,
                          const Color(0xFFFF4458),
                          Colors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Skills Section
                  if (user.skills.isNotEmpty) ...[
                    _buildSectionTitle('Skills'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.skills.map((skill) {
                        return _buildTag(
                          skill,
                          const Color(0xFF3B82F6),
                          Colors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Badges Section
                  if (user.badges.isNotEmpty) ...[
                    _buildSectionTitle('Badges'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: user.badges.length,
                        itemBuilder: (context, index) {
                          final badge = user.badges[index];
                          return _buildBadgeCard(badge);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Stats Section
                  _buildSectionTitle('Stats'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Cities',
                          user.stats.citiesLived.toString(),
                          Icons.location_city,
                          const Color(0xFFFF4458),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Countries',
                          user.stats.countriesVisited.toString(),
                          Icons.flag,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Meetups',
                          user.stats.meetupsAttended.toString(),
                          Icons.people,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Invite 按钮
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showMeetupInviteDialog(context),
                          icon: const Icon(Icons.event),
                          label: const Text('Invite'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Message 按钮
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 跳转到一对一聊天页面
                            Get.to(() => DirectChatPage(user: user));
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4458),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Add to favorites
                            Get.snackbar(
                              'Favorite',
                              'Added ${user.name} to favorites',
                              backgroundColor: const Color(0xFF10B981),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 8,
                            );
                          },
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Color(0xFFFF4458),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBadgeCard(models.Badge badge) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              badge.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1a1a1a),
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6b7280),
            ),
          ),
        ],
      ),
    );
  }

  // 显示 Meetup 邀请对话框
  void _showMeetupInviteDialog(BuildContext context) {
    final controller = Get.find<DataServiceController>();
    final myMeetups = controller.upcomingMeetups;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.event,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite ${user.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1a1a1a),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Select a meetup to invite',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Meetup 列表
              Expanded(
                child: myMeetups.isEmpty
                    ? _buildEmptyMeetupState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: myMeetups.length,
                        itemBuilder: (context, index) {
                          final meetup = myMeetups[index];
                          return _buildMeetupInviteCard(context, meetup);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 空状态
  Widget _buildEmptyMeetupState() {
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
            const Text(
              'No upcoming meetups',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a meetup first to invite members',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6b7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(Get.context!);
                Get.toNamed('/create-meetup');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Meetup'),
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
  }

  // Meetup 邀请卡片
  Widget _buildMeetupInviteCard(
      BuildContext context, Map<String, dynamic> meetup) {
    final date = meetup['date'] as DateTime;
    final dateStr = '${date.month}/${date.day}';
    final attendees = meetup['attendees'] as int;
    final maxAttendees = meetup['maxAttendees'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
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
                // 日期标签
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateStr.split('/')[0],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        dateStr.split('/')[1],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Meetup 信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 类型标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meetup['type'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF4458),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 标题
                      Text(
                        meetup['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a1a),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // 地点和人数
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF6b7280),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meetup['venue'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6b7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: attendees >= maxAttendees
                                ? const Color(0xFFFF4458)
                                : const Color(0xFF6b7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$attendees/$maxAttendees',
                            style: TextStyle(
                              fontSize: 13,
                              color: attendees >= maxAttendees
                                  ? const Color(0xFFFF4458)
                                  : const Color(0xFF6b7280),
                              fontWeight: attendees >= maxAttendees
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // 箭头图标
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF6b7280),
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
    Navigator.pop(context); // 关闭对话框

    // 显示确认对话框
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.send,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Send Invitation',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite ${user.name} to:',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6b7280),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meetup['title'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xFF6b7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(meetup['date'] as DateTime).month}/${(meetup['date'] as DateTime).day} at ${meetup['time']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF6b7280),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meetup['venue'] as String,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6b7280)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back(); // 关闭确认对话框

              // 显示成功消息
              Get.snackbar(
                'Invitation Sent! 🎉',
                '${user.name} has been invited to ${meetup['title']}',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF10B981),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 3),
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
              );
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Send Invite'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
