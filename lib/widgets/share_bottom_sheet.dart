import 'dart:developer';

import 'package:df_admin_mobile/controllers/locale_controller.dart';
import 'package:df_admin_mobile/services/social_sdk_service.dart';
import 'package:df_admin_mobile/utils/qq_share_util.dart';
import 'package:df_admin_mobile/utils/wechat_share_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 分享通道类型
enum ShareChannelType {
  none,
  wechat, // 微信（微信好友、朋友圈）
  qq, // QQ（QQ好友、QQ空间）
}

/// 分享底部抽屉
/// 支持分享到国内外主流社交平台
class ShareBottomSheet extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String shareUrl;

  const ShareBottomSheet({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.shareUrl,
  });

  /// 显示分享底部抽屉
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    String? imageUrl,
    required String shareUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        title: title,
        description: description,
        imageUrl: imageUrl,
        shareUrl: shareUrl,
      ),
    );
  }

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  /// 当前展开的子通道类型
  ShareChannelType _expandedChannel = ShareChannelType.none;

  String get title => widget.title;
  String get description => widget.description;
  String get shareUrl => widget.shareUrl;

  /// 判断是否为中国区用户
  bool get _isChineseUser {
    try {
      final localeController = Get.find<LocaleController>();
      final locale = localeController.locale.value;
      return locale.languageCode == 'zh' ||
          locale.countryCode == 'CN' ||
          locale.countryCode == 'HK' ||
          locale.countryCode == 'MO' ||
          locale.countryCode == 'TW';
    } catch (_) {
      final systemLocale = Get.deviceLocale;
      return systemLocale?.languageCode == 'zh';
    }
  }

  /// 切换子通道展示
  void _toggleSubChannel(ShareChannelType type) {
    setState(() {
      if (_expandedChannel == type) {
        _expandedChannel = ShareChannelType.none;
      } else {
        _expandedChannel = type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = _isChineseUser;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖动条
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // 标题
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_expandedChannel != ShareChannelType.none)
                    GestureDetector(
                      onTap: () => _toggleSubChannel(ShareChannelType.none),
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Icon(Icons.arrow_back_ios, size: 18.sp, color: Colors.grey),
                      ),
                    ),
                  Text(
                    _getTitle(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // 分享选项
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildShareContent(context, isChinese),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// 获取标题
  String _getTitle() {
    switch (_expandedChannel) {
      case ShareChannelType.wechat:
        return '分享到微信';
      case ShareChannelType.qq:
        return '分享到QQ';
      case ShareChannelType.none:
        return '分享到';
    }
  }

  /// 构建分享内容
  Widget _buildShareContent(BuildContext context, bool isChinese) {
    // 如果有展开的子通道，显示子通道
    if (_expandedChannel != ShareChannelType.none) {
      return _buildSubChannels(context);
    }

    // 否则显示主通道
    return _buildMainChannels(context, isChinese);
  }

  /// 构建子通道
  Widget _buildSubChannels(BuildContext context) {
    switch (_expandedChannel) {
      case ShareChannelType.wechat:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.weixin,
              label: '微信好友',
              color: const Color(0xFF09B83E),
              onTap: () => _shareToWeChatFriend(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.circleNotch,
              label: '朋友圈',
              color: const Color(0xFF09B83E),
              onTap: () => _shareToWeChatMoments(context),
            ),
          ],
        );
      case ShareChannelType.qq:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.qq,
              label: 'QQ好友',
              color: const Color(0xFF12B7F5),
              onTap: () => _shareToQQFriend(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.star,
              label: 'QQ空间',
              color: const Color(0xFFFECE00),
              onTap: () => _shareToQZone(context),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  /// 构建主通道
  Widget _buildMainChannels(BuildContext context, bool isChinese) {
    return Column(
      children: [
        // 第一行：通用工具
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.link,
              label: '复制链接',
              color: Colors.grey[700]!,
              onTap: () => _copyLink(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.shareNodes,
              label: '系统分享',
              color: Colors.blue[700]!,
              onTap: () => _shareSystem(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.envelope,
              label: '邮件',
              color: Colors.orange[700]!,
              onTap: () => _shareToEmail(context),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // 根据地区显示不同平台
        if (isChinese) ...[
          // 中国区：只显示国内平台
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.weixin,
                label: '微信',
                color: const Color(0xFF09B83E),
                onTap: () => _toggleSubChannel(ShareChannelType.wechat),
                hasSubChannel: true,
              ),
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.qq,
                label: 'QQ',
                color: const Color(0xFF12B7F5),
                onTap: () => _toggleSubChannel(ShareChannelType.qq),
                hasSubChannel: true,
              ),
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.weibo,
                label: '微博',
                color: const Color(0xFFE6162D),
                onTap: () => _shareToWeibo(context),
              ),
            ],
          ),
        ] else ...[
          // 国际区：只显示国际平台
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.whatsapp,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareToWhatsApp(context),
              ),
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.telegram,
                label: 'Telegram',
                color: const Color(0xFF0088CC),
                onTap: () => _shareToTelegram(context),
              ),
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.twitter,
                label: 'Twitter',
                color: const Color(0xFF1DA1F2),
                onTap: () => _shareToTwitter(context),
              ),
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () => _shareToFacebook(context),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // 第二排国际平台
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.reddit,
                label: 'Reddit',
                color: const Color(0xFFFF4500),
                onTap: () => _shareToReddit(context),
              ),
              _buildShareOption(
                context,
                icon: FontAwesomeIcons.linkedin,
                label: 'LinkedIn',
                color: const Color(0xFF0A66C2),
                onTap: () => _shareToLinkedIn(context),
              ),
              // 占位保持对齐
              SizedBox(width: 70.w),
              SizedBox(width: 70.w),
            ],
          ),
        ],
      ],
    );
  }

  /// 分享到微信好友
  void _shareToWeChatFriend(BuildContext context) async {
    log('📤 _shareToWeChatFriend 被调用');
    Navigator.pop(context);

    // 检查微信是否安装
    final isInstalled = await SocialSdkService.isWechatInstalled();
    log('📤 微信安装状态: $isInstalled');
    if (isInstalled) {
      // 使用微信 SDK 直接分享
      await WechatShareUtil.shareToWeChat(
        url: shareUrl,
        title: title,
        description: description,
        toTimeline: false, // 发送给好友
      );
    } else {
      // 微信未安装，使用系统分享
      final shareText = '$title\n$description\n$shareUrl';
      await Share.share(shareText);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('微信未安装，已使用系统分享'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  /// 分享到朋友圈
  void _shareToWeChatMoments(BuildContext context) async {
    Navigator.pop(context);

    // 检查微信是否安装
    final isInstalled = await SocialSdkService.isWechatInstalled();
    if (isInstalled) {
      // 使用微信 SDK 直接分享到朋友圈
      await WechatShareUtil.shareToWeChat(
        url: shareUrl,
        title: title,
        description: description,
        toTimeline: true, // 发送到朋友圈
      );
    } else {
      // 微信未安装，使用系统分享
      final shareText = '$title\n$description\n$shareUrl';
      await Share.share(shareText);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('微信未安装，已使用系统分享'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  /// 分享到QQ好友
  void _shareToQQFriend(BuildContext context) async {
    Navigator.pop(context);

    // 尝试使用 QQ URL Scheme 唤醒 QQ 分享
    await QQShareUtil.shareToQQFriend(
      url: shareUrl,
      title: title,
      description: description,
    );
  }

  /// 分享到QQ空间
  void _shareToQZone(BuildContext context) async {
    Navigator.pop(context);

    // 使用 QQShareUtil 唤醒 QQ空间分享
    await QQShareUtil.shareToQZone(
      url: shareUrl,
      title: title,
      description: description,
    );
  }

  /// 构建分享选项
  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool hasSubChannel = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 70.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24.sp,
                  ),
                ),
                // 有子通道时显示箭头指示
                if (hasSubChannel)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 复制链接
  void _copyLink(BuildContext context) {
    Share.share(shareUrl);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('链接已复制'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 系统分享
  void _shareSystem(BuildContext context) async {
    final shareText = '$title\n\n$description\n\n$shareUrl';
    await Share.share(shareText);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  /// 分享到 Twitter
  void _shareToTwitter(BuildContext context) async {
    final text = Uri.encodeComponent('$title - $description');
    final url = Uri.encodeComponent(shareUrl);
    final twitterUrl = 'https://twitter.com/intent/tweet?text=$text&url=$url';

    await _launchUrl(context, twitterUrl);
  }

  /// 分享到 Facebook
  void _shareToFacebook(BuildContext context) async {
    final url = Uri.encodeComponent(shareUrl);
    final facebookUrl = 'https://www.facebook.com/sharer/sharer.php?u=$url';

    await _launchUrl(context, facebookUrl);
  }

  /// 分享到微博
  void _shareToWeibo(BuildContext context) async {
    final text = Uri.encodeComponent('$title - $description');
    final url = Uri.encodeComponent(shareUrl);
    final weiboUrl = 'https://service.weibo.com/share/share.php?title=$text&url=$url';

    await _launchUrl(context, weiboUrl);
  }

  /// 分享到 Telegram
  void _shareToTelegram(BuildContext context) async {
    final text = Uri.encodeComponent('$title\n$description');
    final url = Uri.encodeComponent(shareUrl);
    final telegramUrl = 'https://t.me/share/url?url=$url&text=$text';

    await _launchUrl(context, telegramUrl);
  }

  /// 分享到 WhatsApp
  void _shareToWhatsApp(BuildContext context) async {
    final text = Uri.encodeComponent('$title\n$description\n$shareUrl');
    final whatsappUrl = 'https://wa.me/?text=$text';

    await _launchUrl(context, whatsappUrl);
  }

  /// 分享到 Reddit
  void _shareToReddit(BuildContext context) async {
    final titleEncoded = Uri.encodeComponent(title);
    final url = Uri.encodeComponent(shareUrl);
    final redditUrl = 'https://reddit.com/submit?title=$titleEncoded&url=$url';

    await _launchUrl(context, redditUrl);
  }

  /// 分享到 LinkedIn
  void _shareToLinkedIn(BuildContext context) async {
    final url = Uri.encodeComponent(shareUrl);
    final linkedinUrl = 'https://www.linkedin.com/sharing/share-offsite/?url=$url';

    await _launchUrl(context, linkedinUrl);
  }

  /// 分享到邮件
  void _shareToEmail(BuildContext context) async {
    final subject = Uri.encodeComponent(title);
    final body = Uri.encodeComponent('$description\n\n$shareUrl');
    final emailUrl = 'mailto:?subject=$subject&body=$body';

    await _launchUrl(context, emailUrl);
  }

  /// 启动 URL
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('无法打开分享链接'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
