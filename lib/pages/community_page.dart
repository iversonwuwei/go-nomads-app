import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/community/domain/entities/trip_report.dart';
import 'package:go_nomads_app/features/community/presentation/controllers/community_state_controller.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityStateController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Community',
            style: TextStyle(
              color: Color(0xFF1a1a1a),
              fontSize: 20.sp,
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
        body: SafeArea(
          top: false, // AppBar 已经处理了顶部
          child: Obx(() {
            return AppLoadingSwitcher(
              isLoading: controller.isLoading.value,
              loading: const CommunitySkeleton(),
              child: TabBarView(
                children: [
                  _buildTripReportsTab(controller, isMobile),
                  _buildRecommendationsTab(controller, isMobile),
                  _buildQATab(controller, isMobile),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Trip Reports Tab
  Widget _buildTripReportsTab(CommunityStateController controller, bool isMobile) {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            isMobile ? 16 : 24,
            isMobile ? 16 : 24,
            100, // 底部留白给导航栏
          ),
          itemCount: controller.tripReports.length,
          itemBuilder: (context, index) {
            final report = controller.tripReports[index];
            return _buildTripReportCard(report, controller, isMobile);
          },
        ));
  }

  Widget _buildTripReportCard(TripReport report, CommunityStateController controller, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                SafeCircleAvatar(
                  imageUrl: report.userAvatar,
                  radius: 20,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.userName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${report.city}, ${report.country} • ${_formatDuration(report.startDate, report.endDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.star, size: 14.r, color: Color(0xFFF59E0B)),
                      SizedBox(width: 4.w),
                      Text(
                        report.overallRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13.sp,
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
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: report.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 300.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  report.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Ratings
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.w,
              children: report.ratings.entries.map((entry) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key.capitalize!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      ...List.generate(
                        5,
                        (i) {
                          final starValue = i + 1;
                          final rating = entry.value;
                          IconData iconData;
                          Color starColor;

                          if (rating >= starValue) {
                            iconData = FontAwesomeIcons.solidStar;
                            starColor = const Color(0xFFF59E0B);
                          } else if (rating > starValue - 1 && rating < starValue) {
                            iconData = FontAwesomeIcons.starHalfStroke;
                            starColor = const Color(0xFFF59E0B);
                          } else {
                            iconData = FontAwesomeIcons.star;
                            starColor = const Color(0xFFF59E0B).withValues(alpha: 0.3);
                          }

                          return Icon(iconData, size: 12.r, color: starColor);
                        },
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
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  if (report.pros.isNotEmpty) ...[
                    _buildProConSection('Pros', report.pros, Colors.green),
                    if (report.cons.isNotEmpty) SizedBox(height: 12.h),
                  ],
                  if (report.cons.isNotEmpty) _buildProConSection('Cons', report.cons, Colors.red),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                InkWell(
                  onTap: () => controller.toggleLikeTripReport(report.id),
                  child: Row(
                    children: [
                      Icon(
                        report.isLiked ? FontAwesomeIcons.heart : FontAwesomeIcons.heart,
                        size: 20.r,
                        color: report.isLiked ? const Color(0xFFFF4458) : const Color(0xFF6b7280),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${report.likes}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.comment, size: 20.r, color: Color(0xFF6b7280)),
                    SizedBox(width: 6.w),
                    Text(
                      '${report.comments}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _formatTimeAgo(report.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
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
              title == 'Pros' ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.ban,
              size: 16.r,
              color: color,
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(left: 22.w, bottom: 4.h),
              child: Text(
                '• $item',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            )),
      ],
    );
  }

  // Recommendations Tab
  Widget _buildRecommendationsTab(CommunityStateController controller, bool isMobile) {
    return Column(
      children: [
        // Category Filter
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.categories.map((category) {
                    final isSelected = controller.selectedCategory.value == category;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
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
                          color: isSelected ? Colors.white : const Color(0xFF6b7280),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
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
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.network(
                rec.photos.first,
                width: double.infinity,
                height: 180.h,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(rec.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    rec.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(rec.category),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Name and Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rec.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.star, size: 16.r, color: Color(0xFFF59E0B)),
                        SizedBox(width: 4.w),
                        Text(
                          rec.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        Text(
                          ' (${rec.reviewCount})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF9ca3af),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (rec.description != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    rec.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xFF6b7280),
                      height: 1.4,
                    ),
                  ),
                ],

                SizedBox(height: 12.h),

                // Info Row
                Row(
                  children: [
                    if (rec.priceRange != null) ...[
                      Text(
                        rec.priceRange!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    Icon(FontAwesomeIcons.locationDot, size: 14.r, color: Color(0xFF6b7280)),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        rec.fullAddress,
                        style: TextStyle(
                          fontSize: 12.sp,
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
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.w,
                    children: rec.tags.map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11.sp,
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
  Widget _buildQATab(CommunityStateController controller, bool isMobile) {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            isMobile ? 16 : 24,
            isMobile ? 16 : 24,
            100, // 底部留白给导航栏
          ),
          itemCount: controller.questions.length,
          itemBuilder: (context, index) {
            final question = controller.questions[index];
            return _buildQuestionCard(question, controller, isMobile);
          },
        ));
  }

  Widget _buildQuestionCard(Question question, CommunityStateController controller, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
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
              SafeCircleAvatar(
                imageUrl: question.userAvatar,
                radius: 16,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.userName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    Text(
                      question.city,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF9ca3af),
                      ),
                    ),
                  ],
                ),
              ),
              if (question.hasAcceptedAnswer)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.circleCheck, size: 12.r, color: Color(0xFF10B981)),
                      SizedBox(width: 4.w),
                      Text(
                        'Solved',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),

          // Title
          Text(
            question.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),

          SizedBox(height: 8.h),

          // Content
          Text(
            question.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF6b7280),
              height: 1.4,
            ),
          ),

          SizedBox(height: 12.h),

          // Tags
          if (question.tags.isNotEmpty)
            Wrap(
              spacing: 6.w,
              children: question.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF4458),
                    ),
                  ),
                );
              }).toList(),
            ),

          SizedBox(height: 12.h),

          // Stats
          Row(
            children: [
              InkWell(
                onTap: () => controller.toggleUpvoteQuestion(question.id),
                child: Row(
                  children: [
                    Icon(
                      question.isUpvoted ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowUp,
                      size: 18.r,
                      color: question.isUpvoted ? const Color(0xFFFF4458) : const Color(0xFF6b7280),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${question.upvotes}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              Icon(FontAwesomeIcons.comment, size: 16.r, color: Color(0xFF6b7280)),
              SizedBox(width: 4.w),
              Text(
                '${question.answerCount} answers',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF6b7280),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(question.createdAt),
                style: TextStyle(
                  fontSize: 11.sp,
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
