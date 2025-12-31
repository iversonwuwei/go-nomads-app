import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_review.dart' as review_entity;
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_repository.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_review_repository.dart';
import 'package:df_admin_mobile/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CoworkingDetailPageController extends GetxController {
  final CoworkingSpace initialSpace;

  CoworkingDetailPageController({required this.initialSpace});

  // State
  late final Rx<CoworkingSpace> space;
  final RxList<review_entity.CoworkingReview> comments = <review_entity.CoworkingReview>[].obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool hasDataChanged = false.obs;
  final RxInt currentImageIndex = 0.obs;

  final PageController pageController = PageController();

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  List<String> get allImages {
    final images = <String>[];
    images.add(space.value.spaceInfo.imageUrl);
    images.addAll(space.value.spaceInfo.images);
    return images;
  }

  bool get hasMultipleImages => allImages.length > 1;

  @override
  void onInit() {
    super.onInit();
    space = Rx<CoworkingSpace>(initialSpace);
    _setupDataChangeListeners();
    _loadComments();
    _subscribeVerificationUpdates();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('coworking', _handleDataChanged);
    log('✅ [CoworkingDetailPageController] 数据变更监听器已设置');
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 只处理当前空间的变更
    if (event.entityId != space.value.id) {
      return;
    }

    log('🔔 [Coworking详情] 收到数据变更通知: ${event.entityId} (${event.changeType})');

    switch (event.changeType) {
      case DataChangeType.updated:
        // 数据更新，重新加载详情
        reloadCoworkingDetail();
        break;
      case DataChangeType.deleted:
        // 被删除
        log('⚠️ [Coworking详情] 该空间已被删除');
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        reloadCoworkingDetail();
        break;
      case DataChangeType.created:
        // 新建通常不影响详情页
        break;
    }
  }

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    pageController.dispose();
    super.onClose();
  }

  /// 订阅验证人数实时更新
  Future<void> _subscribeVerificationUpdates() async {
    try {
      final controller = Get.find<CoworkingStateController>();
      await controller.subscribeCoworking(space.value.id);
      log('✅ 已订阅 Coworking ${space.value.id} 的验证人数更新');
    } catch (e) {
      log('❌ 订阅验证人数更新失败: $e');
    }
  }

  Future<void> loadComments() async => _loadComments();

  Future<void> _loadComments() async {
    isLoadingComments.value = true;

    try {
      final reviewRepository = Get.find<ICoworkingReviewRepository>();
      final reviews = await reviewRepository.getCoworkingReviews(
        coworkingId: space.value.id,
        page: 1,
        pageSize: 3,
      );

      comments.value = reviews;
    } catch (e) {
      log('加载评论失败: $e');
    } finally {
      isLoadingComments.value = false;
    }
  }

  /// 重新加载 Coworking 详情数据
  Future<void> reloadCoworkingDetail() async {
    try {
      final repository = Get.find<ICoworkingRepository>();
      final result = await repository.getCoworkingById(space.value.id);

      result.fold(
        onSuccess: (updatedSpace) {
          space.value = updatedSpace;
          log('✅ [CoworkingDetail] 重新加载详情成功');
        },
        onFailure: (exception) {
          log('❌ [CoworkingDetail] 重新加载详情失败: ${exception.message}');
        },
      );
    } catch (e) {
      log('❌ [CoworkingDetail] 重新加载详情异常: $e');
    }
  }

  void onPageChanged(int index) {
    currentImageIndex.value = index;
  }

  void updateSpace(CoworkingSpace updatedSpace) {
    space.value = updatedSpace;
  }

  void markDataChanged() {
    hasDataChanged.value = true;
  }

  /// 拨打电话
  Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');

    try {
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '无法拨打电话',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(phoneNumber, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('💡 提示：在真机上可以正常拨打', style: TextStyle(fontSize: 11)),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('错误: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 启动URL
  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 格式化日期
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
