import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../features/user/domain/entities/user.dart' as models;
import '../widgets/app_toast.dart';
import 'direct_chat_page.dart';
import 'invite_to_meetup_page.dart';

class MemberDetailPage extends StatelessWidget {
  final models.UserModel user;

  const MemberDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      color: Colors.black.withValues(alpha: 0.1),
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
                          const Color(0xFFFF4458).withValues(alpha: 0.1),
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
                                color: Colors.black.withValues(alpha: 0.2),
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
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.verified,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                    _buildSectionTitle(AppLocalizations.of(context)!.about),
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
                  _buildInterestsSection(context),
                  const SizedBox(height: 24),

                  // Skills Section
                  _buildSkillsSection(context),
                  const SizedBox(height: 24),

                  // Badges Section
                  _buildBadgesSection(context),
                  const SizedBox(height: 24),

                  // Travel History Section
                  _buildTravelHistorySection(context),
                  const SizedBox(height: 24),

                  // Stats Section
                  _buildSectionTitle(AppLocalizations.of(context)!.stats),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.cities,
                          user.stats.citiesLived.toString(),
                          Icons.location_city,
                          const Color(0xFFFF4458),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.countries,
                          user.stats.countriesVisited.toString(),
                          Icons.flag,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.meetups,
                          user.stats.meetupsAttended.toString(),
                          Icons.people,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Row(
                        children: [
                          // Invite 按钮
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  Get.to(() => InviteToMeetupPage(user: user)),
                              icon: const Icon(Icons.event),
                              label: Text(l10n.inviteToMeetup),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                              label: Text(l10n.sendMessage),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4458),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                AppToast.success(
                                  l10n.favoriteAdded,
                                  title: l10n.favorites,
                                );
                              },
                              icon: const Icon(
                                Icons.favorite_border,
                                color: Color(0xFFFF4458),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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

  Widget _buildBadgeCard(models.Badge badge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.15),
            const Color(0xFFFFA500).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB020).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Icon
          Text(
            badge.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),

          // Badge Name
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final crossAxisCount = isMobile ? 3 : 5;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFF3E0),
                const Color(0xFFFFE0B2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFB020),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB020).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFF6F00),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.badges,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              user.badges.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          AppLocalizations.of(context)!.noBadgesYet,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                const Color(0xFFFF6F00).withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: user.badges.length,
                      itemBuilder: (context, index) {
                        return _buildBadgeCard(user.badges[index]);
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTravelHistorySection(BuildContext context) {
    // 显示最多 5 条记录
    final displayedHistory = user.travelHistory.take(5).toList();
    final hasMore = user.travelHistory.length > 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2196F3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.travel_explore,
                color: Color(0xFF1976D2),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.travelHistory,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          user.travelHistory.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      AppLocalizations.of(context)!.noTravelHistoryYet,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1976D2).withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedHistory.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildTravelHistoryCard(
                            displayedHistory[index], context);
                      },
                    ),
                    if (hasMore) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            // TODO: Navigate to full travel history page
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 18,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.viewAllTrips,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTravelHistoryCard(
      models.TravelHistory travel, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF8E1),
            const Color(0xFFFFF3CD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9800),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Country Flag
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFE082),
                  const Color(0xFFFFD54F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFA726),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                _getCountryFlag(travel.country),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // City and Country Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City Name
                Text(
                  travel.city,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 4),

                // Country
                Text(
                  travel.country,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6b7280),
                  ),
                ),
                const SizedBox(height: 8),

                // Date Range
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFFFF6F00),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(travel.startDate, travel.endDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9ca3af),
                      ),
                    ),
                  ],
                ),

                // Rating (if available)
                if (travel.rating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < travel.rating! ? Icons.star : Icons.star_border,
                        size: 16,
                        color: const Color(0xFFFF9800),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryFlag(String country) {
    final flagMap = {
      'Thailand': '🇹🇭',
      'Portugal': '🇵🇹',
      'Indonesia': '🇮🇩',
      'Mexico': '🇲🇽',
      'Spain': '🇪🇸',
      'Vietnam': '🇻🇳',
      'Japan': '🇯🇵',
      'United States': '🇺🇸',
      'USA': '🇺🇸',
      'United Kingdom': '🇬🇧',
      'UK': '🇬🇧',
      'France': '🇫🇷',
      'Germany': '🇩🇪',
      'Italy': '🇮🇹',
      'Netherlands': '🇳🇱',
      'Canada': '🇨🇦',
      'Australia': '🇦🇺',
      'New Zealand': '🇳🇿',
      'Singapore': '🇸🇬',
      'Malaysia': '🇲🇾',
      'South Korea': '🇰🇷',
      'China': '🇨🇳',
    };

    return flagMap[country] ?? '🌍';
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) return '';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final startMonth = months[startDate.month - 1];
    final startYear = startDate.year;

    if (endDate == null) {
      return '$startMonth $startYear - Present';
    }

    final endMonth = months[endDate.month - 1];
    final endYear = endDate.year;

    if (startYear == endYear) {
      return '$startMonth - $endMonth $startYear';
    }

    return '$startMonth $startYear - $endMonth $endYear';
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
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

  Widget _buildInterestsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFCE4EC),
            const Color(0xFFF8BBD0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE91E63),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Color(0xFFC2185B),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.interests,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          user.interests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No interests added yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFC2185B).withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.interests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF4458),
                            const Color(0xFFE91E63),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFF4458).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (interest.icon != null) ...[
                            Text(
                              interest.icon!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            interest.interestName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2196F3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars,
                color: Color(0xFF1976D2),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.skills,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          user.skills.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No skills added yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1976D2).withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6),
                            const Color(0xFF1976D2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (skill.icon != null) ...[
                            Text(
                              skill.icon!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            skill.skillName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
