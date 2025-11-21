import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../features/coworking/domain/entities/coworking_review.dart';
import '../features/coworking/domain/repositories/icoworking_review_repository.dart';
import '../generated/app_localizations.dart';
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
  final List<CoworkingReview> _reviews = [];
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading.value &&
        _hasMore.value) {
      _loadMore();
    }
  }

  /// 加载评论
  Future<void> _loadReviews() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    try {
      final repository = Get.find<ICoworkingReviewRepository>();
      final reviews = await repository.getCoworkingReviews(
        coworkingId: widget.coworkingId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _reviews.addAll(reviews);
        _hasMore.value = reviews.length >= _pageSize;
      });
    } catch (e) {
      print('❌ 加载评论失败: $e');
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
    _currentPage++;
    await _loadReviews();
  }

  /// 刷新
  Future<void> _refresh() async {
    setState(() {
      _reviews.clear();
      _currentPage = 1;
      _hasMore.value = true;
    });
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviews,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.coworkingName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
        if (_isLoading.value && _reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_reviews.isEmpty) {
          return _buildEmptyState(l10n);
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _reviews.length + (_hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _reviews.length) {
                return _buildLoadingIndicator();
              }

              final review = _reviews[index];
              return _buildReviewCard(review, l10n);
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
          Icon(Icons.rate_review, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to write a review!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
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
            icon: const Icon(Icons.add),
            label: const Text('Write a Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 加载指示器
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  /// 评论卡片
  Widget _buildReviewCard(CoworkingReview review, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息和评分
            Row(
              children: [
                // 用户头像
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF4458),
                  backgroundImage: review.userAvatar != null &&
                          review.userAvatar!.isNotEmpty
                      ? NetworkImage(review.userAvatar!)
                      : null,
                  child: review.userAvatar == null || review.userAvatar!.isEmpty
                      ? Text(
                          review.username.isNotEmpty
                              ? review.username.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // 用户名和日期
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (review.visitDate != null)
                        Text(
                          'Visited ${_formatDate(review.visitDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                // 评分
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 验证标签
                if (review.isVerified) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pending, size: 14, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // 标题
            Text(
              review.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // 内容
            Text(
              review.content,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            // 图片
            if (review.hasPhotos) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photoUrls.length,
                  itemBuilder: (context, photoIndex) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 8),
            // 发布时间
            Text(
              'Posted ${_formatDate(review.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
