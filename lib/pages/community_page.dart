import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/community/domain/entities/trip_report.dart';
import 'package:go_nomads_app/features/community/presentation/controllers/community_state_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_glass_icon_button.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_hero_banner.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_section_header.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final CommunityStateController _communityController;
  UserStateController? _userStateController;
  AiStateController? _aiStateController;
  final GlobalKey _intelligenceSectionKey = GlobalKey();
  final GlobalKey _circlesSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _communityController = Get.find<CommunityStateController>();
    if (Get.isRegistered<UserStateController>()) {
      _userStateController = Get.find<UserStateController>();
    }
    if (Get.isRegistered<AiStateController>()) {
      _aiStateController = Get.find<AiStateController>();
    }
  }

  Future<void> _handleRefresh() async {
    await _communityController.loadCommunityData();
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  User _buildLightweightUser({
    required String id,
    required String name,
    String? avatarUrl,
    String? city,
  }) {
    return User(
      id: id,
      name: name,
      username: name.toLowerCase().replaceAll(' ', '_'),
      avatarUrl: avatarUrl,
      currentCity: city,
      stats: TravelStats(
        citiesVisited: 0,
        countriesVisited: 0,
        reviewsWritten: 0,
        photosShared: 0,
        totalDistanceTraveled: 0,
      ),
      joinedDate: DateTime.now(),
    );
  }

  bool _isCurrentUser(String userId) => _userStateController?.currentUser.value?.id == userId;

  void _openDirectChat(User user) {
    Get.toNamed(AppRoutes.directChat, arguments: user);
  }

  void _openTripReportDetails(TripReport report) {
    final l10n = AppLocalizations.of(context)!;
    final reportAuthor = _buildLightweightUser(
      id: report.userId,
      name: report.userName,
      avatarUrl: report.userAvatar,
      city: report.city,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _TripReportDetailSheet(
          report: report,
          onLike: () => _communityController.toggleLikeTripReport(report.id),
          onOpenCityChat: () => Get.toNamed(AppRoutes.cityChat),
          onMessageAuthor: _isCurrentUser(report.userId) ? null : () => _openDirectChat(reportAuthor),
          openCityChatLabel: l10n.communityDetailOpenCityChat,
          messageAuthorLabel: l10n.communityDetailMessageAuthor,
          likeLabel: l10n.communityDetailLikeFieldNote,
        ),
      ),
    );
  }

  void _openQuestionDetails(Question question) {
    _communityController.loadAnswers(question.id);
    final asker = _buildLightweightUser(
      id: question.userId,
      name: question.userName,
      avatarUrl: question.userAvatar,
      city: question.city,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: Obx(() {
          final answers = _communityController.answers[question.id] ?? const <Answer>[];
          final isLoadingAnswers = _communityController.isLoadingAnswers(question.id);
          final l10n = AppLocalizations.of(context)!;

          return _QuestionDetailSheet(
            question: question,
            answers: answers,
            isLoadingAnswers: isLoadingAnswers,
            onUpvoteQuestion: () => _communityController.toggleUpvoteQuestion(question.id),
            onUpvoteAnswer: (answerId) => _communityController.toggleUpvoteAnswer(question.id, answerId),
            onOpenCityChat: () => Get.toNamed(AppRoutes.cityChat),
            onMessageAsker: _isCurrentUser(question.userId) ? null : () => _openDirectChat(asker),
            onMessageAnswerer: (answer) {
              if (_isCurrentUser(answer.userId) || answer.userId.isEmpty || answer.userId.startsWith('system-')) {
                return;
              }

              _openDirectChat(
                _buildLightweightUser(
                  id: answer.userId,
                  name: answer.userName,
                  avatarUrl: answer.userAvatar,
                  city: question.city,
                ),
              );
            },
            onCreateAnswer: () => _openCreateAnswerDialog(question),
            openCityChatLabel: l10n.communityDetailOpenCityChat,
            messageAskerLabel: l10n.communityDetailMessageAsker,
            messageAnswererLabel: l10n.communityDetailMessageAnswerer,
            upvoteLabel: l10n.communityDetailUpvoteQuestion,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final user = _userStateController?.currentUser.value;
          final latestTravelPlan = _aiStateController?.latestTravelPlan;
          final meetups = _communityController.meetups.take(3).toList(growable: false);
          final tripReports = (_communityController.popularTripReports.isNotEmpty
                  ? _communityController.popularTripReports
                  : _communityController.tripReports)
              .take(3)
              .toList(growable: false);
          final questionFeed = (_communityController.unresolvedQuestions.isNotEmpty
                  ? _communityController.unresolvedQuestions
                  : _communityController.questions)
              .take(3)
              .toList(growable: false);
          final focusCity = _resolveCityContext(
            user,
            latestTravelPlan,
            meetups,
            tripReports,
            questionFeed,
            fallbackCityLabel: l10n.communityRemoteBaseLabel,
          );
          final nextCoordinationCity = latestTravelPlan?.cityName ?? focusCity;
          final circles = _buildSuggestedCircles(
            l10n: l10n,
            user: user,
            latestTravelPlan: latestTravelPlan,
            meetups: meetups,
            tripReports: tripReports,
            questions: questionFeed,
          );
          final joinedCircleCount = circles.where((circle) => _communityController.isCircleJoined(circle.id)).length;
          final initialLoading = _communityController.isLoading.value &&
              _communityController.tripReports.isEmpty &&
              _communityController.questions.isEmpty;
          final laneCards = <_CommunityLaneCardData>[
            _CommunityLaneCardData(
              title: l10n.communityLayerMeetupsTitle,
              subtitle: '',
              highlight: meetups.length.toString(),
              actionLabel: meetups.isNotEmpty ? l10n.communityCirclesViewMeetups : l10n.communityCirclesCreateMeetup,
              icon: Icons.event_available_rounded,
              accentColor: const Color(0xFF457B9D),
              onPressed: () => Get.toNamed(meetups.isNotEmpty ? AppRoutes.meetupsList : AppRoutes.createMeetup),
            ),
            _CommunityLaneCardData(
              title: l10n.communityLayerCityChatTitle,
              subtitle: '',
              highlight: focusCity,
              actionLabel: l10n.communityCirclesExploreCities,
              icon: Icons.forum_rounded,
              accentColor: const Color(0xFF2A9D8F),
              onPressed: () => Get.toNamed(AppRoutes.cityChat),
            ),
            _CommunityLaneCardData(
              title: l10n.communityLayerQuestionsTitle,
              subtitle: '',
              highlight: questionFeed.length.toString(),
              actionLabel: l10n.communityLayerReviewAsks,
              icon: Icons.help_center_outlined,
              accentColor: const Color(0xFFE9C46A),
              onPressed: () => _scrollToSection(_intelligenceSectionKey),
            ),
            _CommunityLaneCardData(
              title: l10n.communityLayerCoordinationTitle,
              subtitle: '',
              highlight: nextCoordinationCity,
              actionLabel: l10n.communityCirclesOpenInbox,
              icon: Icons.handshake_outlined,
              accentColor: const Color(0xFFFF6B6B),
              onPressed: () => Get.toNamed(AppRoutes.conversations),
            ),
          ];

          return AppLoadingSwitcher(
            isLoading: initialLoading,
            loading: const CommunitySkeleton(),
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 14 : 22, 16, isMobile ? 14 : 22, 112),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CockpitHeroBanner(
                            icon: Icons.hub_rounded,
                            title: l10n.communityCirclesHeroTitle,
                            subtitle: '',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF1F2), Color(0xFFF7FAFC), Color(0xFFEAF4FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            trailing: CockpitGlassIconButton(
                              icon: Icons.refresh_rounded,
                              iconColor: AppColors.textPrimary,
                              onTap: _handleRefresh,
                            ),
                            metrics: [
                              CockpitHeroMetric(
                                icon: Icons.hub_rounded,
                                label: l10n.communityCirclesMetricCircles(circles.length.toString()),
                              ),
                              CockpitHeroMetric(
                                icon: Icons.event_available_rounded,
                                label: l10n.communityCirclesMetricMeetups(meetups.length.toString()),
                              ),
                              CockpitHeroMetric(
                                icon: Icons.edit_note_rounded,
                                label: l10n.communityCirclesMetricFieldNotes(tripReports.length.toString()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CockpitPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CockpitSectionHeader(
                                  title: l10n.communityLayersTitle,
                                ),
                                const SizedBox(height: 14),
                                if (isMobile)
                                  Column(
                                    children: laneCards
                                        .map(
                                          (lane) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _CommunityLaneCard(data: lane),
                                          ),
                                        )
                                        .toList(growable: false),
                                  )
                                else
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: laneCards
                                        .map(
                                          (lane) => SizedBox(
                                            width: 260,
                                            child: _CommunityLaneCard(data: lane),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ContentSection(
                            header: CockpitSectionHeader(
                              title: l10n.communityCirclesMeetupsTitle,
                            ),
                            emptyLabel: l10n.communityCirclesMeetupsEmpty,
                            hasItems: meetups.isNotEmpty,
                            children: meetups
                                .map(
                                  (meetup) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _MeetupTile(meetup: meetup),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            key: _intelligenceSectionKey,
                            child: CockpitPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CockpitSectionHeader(
                                    title: l10n.communityIntelligenceTitle,
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _MetaPill(icon: Icons.place_outlined, label: focusCity),
                                      _MetaPill(
                                        icon: Icons.help_outline_rounded,
                                        label: l10n.communityLayerQuestionsBadge(questionFeed.length.toString()),
                                      ),
                                      _MetaPill(
                                        icon: Icons.edit_note_rounded,
                                        label: l10n.communityCirclesMetricFieldNotes(tripReports.length.toString()),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _openCreateQuestionDialog(focusCity),
                                      icon: const Icon(Icons.add_comment_outlined),
                                      label: Text(l10n.communityCreateQuestionAction),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _PanelListSection(
                                    title: l10n.communityCirclesQuestionsTitle,
                                    subtitle: '',
                                    hasItems: questionFeed.isNotEmpty,
                                    emptyLabel: l10n.communityCirclesQuestionsEmpty,
                                    children: questionFeed
                                        .map(
                                          (question) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _QuestionTile(
                                              question: question,
                                              onTap: () => _openQuestionDetails(question),
                                            ),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                  const SizedBox(height: 20),
                                  _PanelListSection(
                                    title: l10n.communityCirclesFieldNotesTitle,
                                    subtitle: '',
                                    hasItems: tripReports.isNotEmpty,
                                    emptyLabel: l10n.communityCirclesFieldNotesEmpty,
                                    children: tripReports
                                        .map(
                                          (report) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _TripReportTile(
                                              report: report,
                                              onLike: () => _communityController.toggleLikeTripReport(report.id),
                                              onTap: () => _openTripReportDetails(report),
                                            ),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CockpitPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CockpitSectionHeader(
                                  title: l10n.communityCoordinationTitle,
                                  subtitle: l10n.communityCoordinationSubtitle,
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _MetaPill(icon: Icons.place_outlined, label: nextCoordinationCity),
                                    _MetaPill(
                                      icon: Icons.hub_rounded,
                                      label: l10n.communityCirclesMetricCircles(joinedCircleCount.toString()),
                                    ),
                                    _MetaPill(
                                      icon: Icons.event_available_rounded,
                                      label: l10n.communityCirclesMetricMeetups(meetups.length.toString()),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _QuickActionButton(
                                  icon: Icons.mark_email_unread_outlined,
                                  label: l10n.communityCirclesOpenInbox,
                                  onPressed: () => Get.toNamed(AppRoutes.conversations),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            key: _circlesSectionKey,
                            child: CockpitPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CockpitSectionHeader(
                                    title: l10n.communityCirclesSuggestedTitle,
                                    subtitle: l10n.communityCirclesSuggestedSubtitle,
                                  ),
                                  const SizedBox(height: 18),
                                  if (isMobile)
                                    Column(
                                      children: circles
                                          .map(
                                            (circle) => Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: _CircleCard(
                                                data: circle,
                                                joined: _communityController.isCircleJoined(circle.id),
                                                actionLabel: _communityController.isCircleJoined(circle.id)
                                                    ? l10n.communityCirclesOpen
                                                    : l10n.communityCirclesJoin,
                                                onPressed: () {
                                                  if (_communityController.isCircleJoined(circle.id)) {
                                                    Get.toNamed(AppRoutes.meetupsList);
                                                    return;
                                                  }
                                                  _communityController.toggleCircleMembership(circle.id);
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                    )
                                  else
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: circles
                                          .map(
                                            (circle) => SizedBox(
                                              width: 260,
                                              child: _CircleCard(
                                                data: circle,
                                                joined: _communityController.isCircleJoined(circle.id),
                                                actionLabel: _communityController.isCircleJoined(circle.id)
                                                    ? l10n.communityCirclesOpen
                                                    : l10n.communityCirclesJoin,
                                                onPressed: () {
                                                  if (_communityController.isCircleJoined(circle.id)) {
                                                    Get.toNamed(AppRoutes.meetupsList);
                                                    return;
                                                  }
                                                  _communityController.toggleCircleMembership(circle.id);
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  List<_CircleCardData> _buildSuggestedCircles({
    required AppLocalizations l10n,
    required User? user,
    required TravelPlanSummary? latestTravelPlan,
    required List<Meetup> meetups,
    required List<TripReport> tripReports,
    required List<Question> questions,
  }) {
    final city = _resolveCityContext(
      user,
      latestTravelPlan,
      meetups,
      tripReports,
      questions,
      fallbackCityLabel: l10n.communityRemoteBaseLabel,
    );
    final skill =
        user != null && user.skills.isNotEmpty ? user.skills.first.name : l10n.communityCirclesGeneralistLabel;

    return [
      _CircleCardData(
        id: 'city-circle',
        title: l10n.communityCircleCityTitle,
        subtitle: '',
        badge: city,
        accentColor: const Color(0xFFFF6B6B),
        icon: Icons.location_city_rounded,
      ),
      _CircleCardData(
        id: 'migration-circle',
        title: l10n.communityCircleMigrationTitle,
        subtitle: '',
        badge: latestTravelPlan?.formattedDepartureDate ?? l10n.communityCirclesFlexibleLabel,
        accentColor: const Color(0xFF457B9D),
        icon: Icons.alt_route_rounded,
      ),
      _CircleCardData(
        id: 'skill-circle',
        title: l10n.communityCircleSkillTitle,
        subtitle: '',
        badge: skill,
        accentColor: const Color(0xFF2A9D8F),
        icon: Icons.handshake_outlined,
      ),
      _CircleCardData(
        id: 'recurring-circle',
        title: l10n.communityCircleRecurringTitle,
        subtitle: '',
        badge: '${meetups.length}',
        accentColor: const Color(0xFFE9C46A),
        icon: Icons.event_repeat_rounded,
      ),
    ];
  }

  String _resolveCityContext(
    User? user,
    TravelPlanSummary? latestTravelPlan,
    List<Meetup> meetups,
    List<TripReport> tripReports,
    List<Question> questions, {
    required String fallbackCityLabel,
  }) {
    final candidates = <String?>[
      user?.currentCity,
      latestTravelPlan?.cityName,
      meetups.isNotEmpty ? meetups.first.location.cityName ?? meetups.first.location.city : null,
      tripReports.isNotEmpty ? tripReports.first.city : null,
      questions.isNotEmpty ? questions.first.city : null,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return fallbackCityLabel;
  }

  Future<void> _openCreateQuestionDialog(String city) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();

    try {
      await AppBottomDrawer.show<void>(
        context,
        title: l10n.communityCreateQuestionAction,
        subtitle: city,
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: l10n.title),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.description),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagsController,
              decoration: InputDecoration(labelText: l10n.communityTagLabel),
            ),
          ],
        ),
        footer: AppBottomDrawerActionRow(
          secondaryLabel: l10n.cancel,
          onSecondaryPressed: () => Get.back<void>(),
          primaryLabel: l10n.saveChanges,
          onPrimaryPressed: () {
            _communityController.createQuestion(
              city: city,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              tags: tagsController.text.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList(),
            );
            Get.back<void>();
          },
        ),
      );
    } finally {
      titleController.dispose();
      contentController.dispose();
      tagsController.dispose();
    }
  }

  Future<void> _openCreateAnswerDialog(Question question) async {
    final l10n = AppLocalizations.of(context)!;
    final contentController = TextEditingController();

    try {
      await AppBottomDrawer.show<void>(
        context,
        title: l10n.communityCreateAnswerAction,
        subtitle: question.title,
        child: TextField(
          controller: contentController,
          maxLines: 5,
          decoration: InputDecoration(labelText: l10n.answer),
        ),
        footer: AppBottomDrawerActionRow(
          secondaryLabel: l10n.cancel,
          onSecondaryPressed: () => Get.back<void>(),
          primaryLabel: l10n.saveChanges,
          onPrimaryPressed: () {
            _communityController.createAnswer(
              questionId: question.id,
              content: contentController.text.trim(),
            );
            Get.back<void>();
          },
        ),
      );
    } finally {
      contentController.dispose();
    }
  }
}

class _CommunityLaneCardData {
  final String title;
  final String subtitle;
  final String highlight;
  final String actionLabel;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onPressed;

  const _CommunityLaneCardData({
    required this.title,
    required this.subtitle,
    required this.highlight,
    required this.actionLabel,
    required this.icon,
    required this.accentColor,
    required this.onPressed,
  });
}

class _CommunityLaneCard extends StatelessWidget {
  final _CommunityLaneCardData data;

  const _CommunityLaneCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: data.accentColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                ),
                child: Icon(data.icon, color: data.accentColor),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  child: Text(
                    data.highlight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          if (data.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              data.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: data.onPressed,
            style: FilledButton.styleFrom(
              foregroundColor: data.accentColor,
              backgroundColor: Colors.white.withValues(alpha: 0.66),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              minimumSize: const Size(0, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(data.actionLabel),
          ),
        ],
      ),
    );
  }
}

class _CircleCardData {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final Color accentColor;
  final IconData icon;

  const _CircleCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.accentColor,
    required this.icon,
  });
}

class _CircleCard extends StatelessWidget {
  final _CircleCardData data;
  final bool joined;
  final String actionLabel;
  final VoidCallback onPressed;

  const _CircleCard({
    required this.data,
    required this.joined,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: data.accentColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                ),
                child: Icon(data.icon, color: data.accentColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                ),
                child: Text(
                  data.badge,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          if (data.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              data.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: joined ? data.accentColor : Colors.white.withValues(alpha: 0.66),
              foregroundColor: joined ? Colors.white : data.accentColor,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        minimumSize: const Size(0, 38),
        backgroundColor: Colors.white.withValues(alpha: 0.52),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }
}

class _PanelListSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool hasItems;
  final String emptyLabel;
  final List<Widget> children;

  const _PanelListSection({
    required this.title,
    required this.subtitle,
    required this.hasItems,
    required this.emptyLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          ),
        ],
        SizedBox(height: subtitle.isNotEmpty ? 12 : 10),
        if (!hasItems)
          Text(
            emptyLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          )
        else
          ...children,
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  final Widget header;
  final bool hasItems;
  final String emptyLabel;
  final List<Widget> children;

  const _ContentSection({
    required this.header,
    required this.hasItems,
    required this.emptyLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 14),
          if (!hasItems)
            Text(
              emptyLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _MeetupTile extends StatelessWidget {
  final Meetup meetup;

  const _MeetupTile({required this.meetup});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.meetupDetail, arguments: meetup),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF457B9D).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF457B9D).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
              ),
              child: const Icon(Icons.groups_2_rounded, color: Color(0xFF457B9D)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meetup.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meetup.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _MetaPill(icon: Icons.schedule_rounded, label: meetup.schedule.formattedStartTime),
                      _MetaPill(icon: Icons.place_outlined, label: meetup.location.fullDescription),
                      _MetaPill(
                        icon: Icons.people_outline_rounded,
                        label: '${meetup.capacity.currentAttendees}/${meetup.capacity.maxAttendees}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_outward_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TripReportTile extends StatelessWidget {
  final TripReport report;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _TripReportTile({
    required this.report,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4458).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SafeCircleAvatar(imageUrl: report.userAvatar, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatTripReportLocation(report)} • ${_formatTimeAgo(report.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    report.overallRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              report.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              report.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _MetaPill(icon: Icons.date_range_outlined, label: _formatTripWindow(report)),
                _MetaPill(icon: Icons.thumb_up_alt_outlined, label: '${report.likes} ${l10n.likes}'),
                _MetaPill(icon: Icons.forum_outlined, label: '${report.comments} ${l10n.comments}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onLike,
                  icon: Icon(
                    report.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: report.isLiked ? const Color(0xFFFF4458) : AppColors.textSecondary,
                  ),
                  label: Text(
                    '${report.likes}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_outward_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;

  const _QuestionTile({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE9C46A).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: question.hasAcceptedAnswer ? const Color(0xFFE8F5E9) : const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    question.hasAcceptedAnswer ? l10n.communityQuestionResolved : l10n.communityQuestionNeedsAnswer,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: question.hasAcceptedAnswer ? const Color(0xFF2E7D32) : const Color(0xFFED6C02),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _MetaPill(icon: Icons.place_outlined, label: question.city),
                _MetaPill(icon: Icons.thumb_up_alt_outlined, label: '${question.upvotes} ${l10n.likes}'),
                _MetaPill(icon: Icons.question_answer_outlined, label: '${question.answerCount} ${l10n.answers}'),
              ],
            ),
            if (question.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: question.tags
                    .take(4)
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                        ),
                        child: Text(
                          '#$tag',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_outward_rounded, size: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSheetShell extends StatelessWidget {
  final Widget child;

  const _DetailSheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripReportDetailSheet extends StatelessWidget {
  final TripReport report;
  final VoidCallback onLike;
  final VoidCallback onOpenCityChat;
  final VoidCallback? onMessageAuthor;
  final String openCityChatLabel;
  final String messageAuthorLabel;
  final String likeLabel;

  const _TripReportDetailSheet({
    required this.report,
    required this.onLike,
    required this.onOpenCityChat,
    required this.onMessageAuthor,
    required this.openCityChatLabel,
    required this.messageAuthorLabel,
    required this.likeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _DetailSheetShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.communityDetailFieldNoteTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SafeCircleAvatar(imageUrl: report.userAvatar, radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatTripReportLocation(report)} • ${_formatTimeAgo(report.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                  ),
                  child: Text(
                    report.overallRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              report.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _MetaPill(icon: Icons.date_range_outlined, label: _formatTripWindow(report)),
                _MetaPill(icon: Icons.thumb_up_alt_outlined, label: '${report.likes} ${l10n.likes}'),
                _MetaPill(icon: Icons.forum_outlined, label: '${report.comments} ${l10n.comments}'),
                _MetaPill(icon: Icons.photo_library_outlined, label: '${report.photos.length} ${l10n.photos}'),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              report.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
            ),
            if (report.ratings.isNotEmpty) ...[
              const SizedBox(height: 24),
              _DetailSectionTitle(title: l10n.communityDetailRatingsTitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: report.ratings.entries
                    .map(
                      (entry) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.56),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (report.pros.isNotEmpty) ...[
              const SizedBox(height: 24),
              _DetailSectionTitle(title: l10n.communityDetailProsTitle),
              const SizedBox(height: 10),
              ...report.pros.map((item) => _BulletLine(text: item, color: const Color(0xFF2A9D8F))),
            ],
            if (report.cons.isNotEmpty) ...[
              const SizedBox(height: 24),
              _DetailSectionTitle(title: l10n.communityDetailConsTitle),
              const SizedBox(height: 10),
              ...report.cons.map((item) => _BulletLine(text: item, color: const Color(0xFFFF6B6B))),
            ],
            if (report.photos.isNotEmpty) ...[
              const SizedBox(height: 24),
              _DetailSectionTitle(title: l10n.photos),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: report.photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SafeNetworkImage(
                      imageUrl: report.photos[index],
                      width: 160,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenCityChat,
                    icon: const Icon(Icons.forum_outlined),
                    label: Text(openCityChatLabel),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.56),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.72)),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                if (onMessageAuthor != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMessageAuthor,
                      icon: const Icon(Icons.mark_email_unread_outlined),
                      label: Text(messageAuthorLabel),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.56),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.72)),
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onLike,
                    icon: Icon(report.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                    label: Text(likeLabel),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDetailSheet extends StatelessWidget {
  final Question question;
  final List<Answer> answers;
  final bool isLoadingAnswers;
  final VoidCallback onUpvoteQuestion;
  final ValueChanged<String> onUpvoteAnswer;
  final VoidCallback onCreateAnswer;
  final VoidCallback onOpenCityChat;
  final VoidCallback? onMessageAsker;
  final ValueChanged<Answer> onMessageAnswerer;
  final String openCityChatLabel;
  final String messageAskerLabel;
  final String messageAnswererLabel;
  final String upvoteLabel;

  const _QuestionDetailSheet({
    required this.question,
    required this.answers,
    required this.isLoadingAnswers,
    required this.onUpvoteQuestion,
    required this.onUpvoteAnswer,
    required this.onCreateAnswer,
    required this.onOpenCityChat,
    required this.onMessageAsker,
    required this.onMessageAnswerer,
    required this.openCityChatLabel,
    required this.messageAskerLabel,
    required this.messageAnswererLabel,
    required this.upvoteLabel,
  });

  bool _canMessageAnswerer(Answer answer) {
    final userId = answer.userId.trim();
    return userId.isNotEmpty && !userId.startsWith('system-') && userId != question.userId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _DetailSheetShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.communityDetailQuestionTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _MetaPill(icon: Icons.place_outlined, label: question.city),
                _MetaPill(icon: Icons.thumb_up_alt_outlined, label: '${question.upvotes} ${l10n.likes}'),
                _MetaPill(icon: Icons.question_answer_outlined, label: '${question.answerCount} ${l10n.answers}'),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: question.hasAcceptedAnswer
                        ? const Color(0xFFE8F5E9).withValues(alpha: 0.72)
                        : const Color(0xFFFFF4E5).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                  ),
                  child: Text(
                    question.hasAcceptedAnswer ? l10n.communityQuestionResolved : l10n.communityQuestionNeedsAnswer,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: question.hasAcceptedAnswer ? const Color(0xFF2E7D32) : const Color(0xFFED6C02),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              question.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
            ),
            if (question.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: question.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.56),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                        ),
                        child: Text(
                          '#$tag',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 24),
            _DetailSectionTitle(title: l10n.communityDetailAnswersTitle),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onCreateAnswer,
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(l10n.communityCreateAnswerAction),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoadingAnswers)
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.communityDetailAnswersLoading,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              )
            else if (answers.isEmpty)
              Text(
                l10n.communityDetailAnswersEmpty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
              )
            else
              ...answers.map(
                (answer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnswerCard(
                    answer: answer,
                    onUpvote: () => onUpvoteAnswer(answer.id),
                    onMessage: _canMessageAnswerer(answer) ? () => onMessageAnswerer(answer) : null,
                    messageLabel: messageAnswererLabel,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenCityChat,
                    icon: const Icon(Icons.forum_outlined),
                    label: Text(openCityChatLabel),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.56),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.72)),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                if (onMessageAsker != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMessageAsker,
                      icon: const Icon(Icons.mark_email_unread_outlined),
                      label: Text(messageAskerLabel),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.56),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.72)),
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onUpvoteQuestion,
                    icon: Icon(question.isUpvoted ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined),
                    label: Text(upvoteLabel),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final Answer answer;
  final VoidCallback onUpvote;
  final VoidCallback? onMessage;
  final String messageLabel;

  const _AnswerCard({
    required this.answer,
    required this.onUpvote,
    required this.onMessage,
    required this.messageLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SafeCircleAvatar(imageUrl: answer.userAvatar, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimeAgo(answer.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (answer.isAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                  ),
                  child: Text(
                    l10n.communityQuestionResolved,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onUpvote,
                  icon: Icon(
                    answer.isUpvoted ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                    color: answer.isUpvoted ? const Color(0xFF457B9D) : AppColors.textSecondary,
                  ),
                  label: Text('${answer.upvotes} ${l10n.likes}'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (onMessage != null)
                  TextButton.icon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.mark_email_unread_outlined),
                    label: Text(messageLabel),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  final String title;

  const _DetailSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletLine({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}

String _formatTripReportLocation(TripReport report) {
  if (report.country.trim().isEmpty) {
    return report.city;
  }

  return '${report.city}, ${report.country}';
}

String _formatTripWindow(TripReport report) {
  final start = report.startDate;
  final end = report.endDate;
  return '${start.month}/${start.day} - ${end.month}/${end.day}';
}
