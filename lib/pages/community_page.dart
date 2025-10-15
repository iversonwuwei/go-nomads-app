import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/community_controller.dart';
import '../generated/app_localizations.dart';
import '../models/community_model.dart';
import '../widgets/skeleton_loader.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.put(CommunityController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Community',
            style: TextStyle(
              color: Color(0xFF1a1a1a),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFFF4458),
            unselectedLabelColor: Color(0xFF6b7280),
            indicatorColor: Color(0xFFFF4458),
            tabs: [
              Tab(text: 'Trip Reports'),
              Tab(text: 'Recommendations'),
              Tab(text: 'Q&A'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const SkeletonLoader(type: SkeletonType.community);
          }

          return TabBarView(
            children: [
              _buildTripReportsTab(controller, isMobile),
              _buildRecommendationsTab(controller, isMobile),
              _buildQATab(controller, isMobile),
            ],
          );
        }),
      ),
    );
  }

  // Trip Reports Tab
  Widget _buildTripReportsTab(CommunityController controller, bool isMobile) {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          itemCount: controller.tripReports.length,
          itemBuilder: (context, index) {
            final report = controller.tripReports[index];
            return _buildTripReportCard(report, controller, isMobile);
          },
        ));
  }

  Widget _buildTripReportCard(
      TripReport report, CommunityController controller, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      report.userAvatar ?? 'https://i.pravatar.cc/300'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${report.city}, ${report.country} • ${_formatDuration(report.startDate, report.endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        report.overallRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Photos
          if (report.photos.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: report.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(report.photos[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Title and Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Ratings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: report.ratings.entries.map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key.capitalize!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < entry.value.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 12,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Pros & Cons
          if (report.pros.isNotEmpty || report.cons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (report.pros.isNotEmpty) ...[
                    _buildProConSection('Pros', report.pros, Colors.green),
                    if (report.cons.isNotEmpty) const SizedBox(height: 12),
                  ],
                  if (report.cons.isNotEmpty)
                    _buildProConSection('Cons', report.cons, Colors.red),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                InkWell(
                  onTap: () => controller.toggleLikeTripReport(report.id),
                  child: Row(
                    children: [
                      Icon(
                        controller.likedReports.contains(report.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: controller.likedReports.contains(report.id)
                            ? const Color(0xFFFF4458)
                            : const Color(0xFF6b7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${report.likes}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    const Icon(Icons.comment_outlined,
                        size: 20, color: Color(0xFF6b7280)),
                    const SizedBox(width: 6),
                    Text(
                      '${report.comments}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _formatTimeAgo(report.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9ca3af),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProConSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title == 'Pros' ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 4),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            )),
      ],
    );
  }

  // Recommendations Tab
  Widget _buildRecommendationsTab(
      CommunityController controller, bool isMobile) {
    return Column(
      children: [
        // Category Filter
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.categories.map((category) {
                    final isSelected =
                        controller.selectedCategory.value == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedCategory.value = category;
                          }
                        },
                        selectedColor: const Color(0xFFFF4458),
                        backgroundColor: const Color(0xFFF3F4F6),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6b7280),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ),

        // Recommendations List
        Expanded(
          child: Obx(() {
            final recs = controller.filteredRecommendations;
            return ListView.builder(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              itemCount: recs.length,
              itemBuilder: (context, index) {
                final rec = recs[index];
                return _buildRecommendationCard(rec, isMobile);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(CityRecommendation rec, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (rec.photos.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                rec.photos.first,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getCategoryColor(rec.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rec.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(rec.category),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Name and Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rec.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          rec.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        Text(
                          ' (${rec.reviewCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9ca3af),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (rec.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    rec.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6b7280),
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Info Row
                Row(
                  children: [
                    if (rec.priceRange != null) ...[
                      Text(
                        rec.priceRange!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xFF6b7280)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rec.address ?? rec.city,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6b7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Tags
                if (rec.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: rec.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Q&A Tab
  Widget _buildQATab(CommunityController controller, bool isMobile) {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          itemCount: controller.questions.length,
          itemBuilder: (context, index) {
            final question = controller.questions[index];
            return _buildQuestionCard(question, controller, isMobile);
          },
        ));
  }

  Widget _buildQuestionCard(
      Question question, CommunityController controller, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                    question.userAvatar ?? 'https://i.pravatar.cc/300'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.userName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    Text(
                      question.city,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9ca3af),
                      ),
                    ),
                  ],
                ),
              ),
              if (question.hasAcceptedAnswer)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'Solved',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            question.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Text(
            question.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6b7280),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Tags
          if (question.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              children: question.tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF4458),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              InkWell(
                onTap: () => controller.toggleUpvoteQuestion(question.id),
                child: Row(
                  children: [
                    Icon(
                      controller.upvotedQuestions.contains(question.id)
                          ? Icons.arrow_upward
                          : Icons.arrow_upward_outlined,
                      size: 18,
                      color: controller.upvotedQuestions.contains(question.id)
                          ? const Color(0xFFFF4458)
                          : const Color(0xFF6b7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${question.upvotes}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.comment_outlined,
                  size: 16, color: Color(0xFF6b7280)),
              const SizedBox(width: 4),
              Text(
                '${question.answerCount} answers',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6b7280),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(question.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9ca3af),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Restaurant':
        return const Color(0xFFEC4899);
      case 'Cafe':
        return const Color(0xFF8B5CF6);
      case 'Coworking':
        return const Color(0xFF6366F1);
      case 'Activity':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6b7280);
    }
  }

  String _formatDuration(DateTime start, DateTime end) {
    final months = (end.year - start.year) * 12 + end.month - start.month;
    if (months == 0) return '1 month';
    return '$months months';
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }
}
