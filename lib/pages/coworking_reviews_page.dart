import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_review.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_review_repository.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'add_coworking_review_page.dart';

/// Coworking Review 列表页面 - 无限滚动
class CoworkingReviewsPage extends StatefulWidget {
  final String coworkingId;
  final String coworkingName;

  const CoworkingReviewsPage({
    super.key,
    required this.coworkingId,
    required this.coworkingName,
  });

  @override
  State<CoworkingReviewsPage> createState() => _CoworkingReviewsPageState();
}

class _CoworkingReviewsPageState extends State<CoworkingReviewsPage> {
  final ScrollController _scrollController = ScrollController();
  final RxList<CoworkingReview> _reviews = <CoworkingReview>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs; // 加载更多状态
  final RxBool _hasMore = true.obs;
  final RxBool _isAdmin = false.obs;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 异步加载数据,不阻塞页面显示
    Future.microtask(() {
      _checkAdminStatus();
      _loadReviews();
    });
  }

  /// 检查当前用户是否是管理员
  Future<void> _checkAdminStatus() async {
    final tokenService = Get.find<TokenStorageService>();
    final role = await tokenService.getUserRole();
    _isAdmin.value = role == 'admin';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading.value &&
        !_isLoadingMore.value &&
        _hasMore.value) {
      _loadMore();
    }
  }

  /// 首次加载评论
  Future<void> _loadReviews() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    _currentPage = 1;
    _hasMore.value = true;

    try {
      final repository = Get.find<ICoworkingReviewRepository>();
      final reviews = await repository.getCoworkingReviews(
        coworkingId: widget.coworkingId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _reviews.assignAll(reviews);
      _hasMore.value = reviews.length >= _pageSize;
    } catch (e) {
      log('❌ 加载评论失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载评论失败: $e')),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载更多
  Future<void> _loadMore() async {
    if (_isLoadingMore.value || !_hasMore.value) return;

    _isLoadingMore.value = true;
    _currentPage++;

    try {
      final repository = Get.find<ICoworkingReviewRepository>();
      final reviews = await repository.getCoworkingReviews(
        coworkingId: widget.coworkingId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _reviews.addAll(reviews);
      _hasMore.value = reviews.length >= _pageSize;
    } catch (e) {
      log('❌ 加载更多评论失败: $e');
      // 加载失败时回退页码
      _currentPage--;
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// 刷新
  Future<void> _refresh() async {
    await _loadReviews();
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const AppBackButton(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviews,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              widget.coworkingName,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.circlePlus, size: 24),
            onPressed: () async {
              final result = await Get.to<bool>(
                () => AddCoworkingReviewPage(
                  coworkingId: widget.coworkingId,
                  coworkingName: widget.coworkingName,
                ),
              );
              if (result == true) {
                _refresh();
              }
            },
            tooltip: '添加评论',
          ),
        ],
      ),
      body: Obx(() {
        // 首次加载时显示中间加载指示器
        if (_isLoading.value && _reviews.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF007AFF),
            ),
          );
        }

        if (_reviews.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF007AFF),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: _buildEmptyState(l10n),
                  ),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF007AFF),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _reviews.length + (_hasMore.value || _isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _reviews.length) {
                return _buildLoadingIndicator();
              }

              final review = _reviews[index];
              return _buildReviewCard(review, index, l10n);
            },
          ),
        );
      }),
    );
  }

  /// 空状态
  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              FontAwesomeIcons.commentDots,
              size: 56,
              color: Color(0xFFC7C7CC),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to write a review',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () async {
              final result = await Get.to<bool>(
                () => AddCoworkingReviewPage(
                  coworkingId: widget.coworkingId,
                  coworkingName: widget.coworkingName,
                ),
              );
              if (result == true) {
                _refresh();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Write a Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 加载指示器
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF007AFF),
        ),
      ),
    );
  }

  /// 评论卡片 - 扁平化设计
  Widget _buildReviewCard(
    CoworkingReview review,
    int index,
    AppLocalizations l10n,
  ) {
    return Obx(() {
      // 只有管理员才能滑动删除
      if (_isAdmin.value) {
        return Dismissible(
          key: Key(review.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await Get.dialog<bool>(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Delete Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this review? This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3C3C43),
                        height: 1.4,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (direction) async {
            try {
              final repository = Get.find<ICoworkingReviewRepository>();
              await repository.deleteReview(review.id);
              _reviews.removeAt(index);
              AppToast.success('Review deleted');
            } catch (e) {
              AppToast.error('Failed to delete: $e');
              // 删除失败，刷新列表恢复
              _refresh();
            }
          },
          background: Container(
            color: const Color(0xFFFF3B30),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              FontAwesomeIcons.trash,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: _buildReviewCardContent(review, l10n),
        );
      }

      // 非管理员直接显示卡片
      return _buildReviewCardContent(review, l10n);
    });
  }

  /// 评论卡片内容
  Widget _buildReviewCardContent(
    CoworkingReview review,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // 可选：点击查看详情
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：用户信息和评分
                Row(
                  children: [
                    // 用户头像
                    SafeCircleAvatar(
                      imageUrl: review.userAvatar,
                      radius: 20,
                      backgroundColor: const Color(0xFFF2F2F7),
                      placeholder: Text(
                        review.username.isNotEmpty ? review.username.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      errorWidget: Text(
                        review.username.isNotEmpty ? review.username.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 用户名和访问日期
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.username,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (review.visitDate != null)
                            Text(
                              'Visited ${_formatDate(review.visitDate!)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 评分
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            FontAwesomeIcons.star,
                            color: Color(0xFFFFCC00),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 标题
                Text(
                  review.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // 内容
                Text(
                  review.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF3C3C43),
                    height: 1.4,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                // 图片
                if (review.hasPhotos) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.photoUrls.length,
                      itemBuilder: (context, photoIndex) {
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF2F2F7),
                            image: DecorationImage(
                              image: NetworkImage(review.photoUrls[photoIndex]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // 底部：状态和时间
                Row(
                  children: [
                    // 验证状态
                    if (review.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              FontAwesomeIcons.circleCheck,
                              size: 12,
                              color: Color(0xFF34C759),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF34C759),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              FontAwesomeIcons.clock,
                              size: 12,
                              color: Color(0xFFFF9500),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFF9500),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // 发布时间
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAEAEB2),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
