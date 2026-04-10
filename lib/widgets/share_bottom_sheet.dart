import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_icons.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/locale_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/social_sdk_service.dart';
import 'package:go_nomads_app/utils/app_logo_util.dart';
import 'package:go_nomads_app/utils/qq_share_util.dart';
import 'package:go_nomads_app/utils/wechat_share_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 分享通道类型
enum ShareChannelType {
  none,
  wechat, // 微信（微信好友、朋友圈）
  qq, // QQ（QQ 好友、QQ 空间）
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
    return AppBottomDrawer.show<void>(
      context,
      maxHeightFactor: 0.72,
      contentPadding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: ShareBottomSheet(
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

  /// App Logo 缩略图缓存
  Uint8List? _logoThumbnail;
  Uri? _logoFileUri;

  String get title => widget.title;
  String get description => widget.description;
  String get shareUrl => widget.shareUrl;

  @override
  void initState() {
    super.initState();
    _loadAppLogo();
  }

  /// 加载 App Logo 作为分享缩略图
  Future<void> _loadAppLogo() async {
    _logoThumbnail = await AppLogoUtil.getThumbnail();
    _logoFileUri = await AppLogoUtil.getFileUri();
  }

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_expandedChannel != ShareChannelType.none)
                GestureDetector(
                  onTap: () => _toggleSubChannel(ShareChannelType.none),
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Icon(AppIcons.back, size: 18.sp, color: AppColors.icon),
                  ),
                ),
              Text(
                _getTitle(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        _buildShareContent(context, isChinese),
        SizedBox(height: 12.h),
      ],
    );
  }

  /// 获取标题
  String _getTitle() {
    switch (_expandedChannel) {
      case ShareChannelType.wechat:
        return AppLocalizations.of(Get.context!)!.shareToWechat;
      case ShareChannelType.qq:
        return AppLocalizations.of(Get.context!)!.shareToQQ;
      case ShareChannelType.none:
        return AppLocalizations.of(Get.context!)!.shareTo;
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
      case ShareChannelType.qq:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.qq,
              label: AppLocalizations.of(context)!.qqFriends,
              color: const Color(0xFF12B7F5),
              onTap: () => _shareToQQFriend(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.qq,
              label: AppLocalizations.of(context)!.qqZone,
              color: const Color(0xFFFECE00),
              onTap: () => _shareToQzone(context),
            ),
          ],
        );
      case ShareChannelType.wechat:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.weixin,
              label: AppLocalizations.of(context)!.wechatFriends,
              color: const Color(0xFF09B83E),
              onTap: () => _shareToWeChatFriend(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.circleNotch,
              label: AppLocalizations.of(context)!.moments,
              color: const Color(0xFF09B83E),
              onTap: () => _shareToWeChatMoments(context),
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
              label: AppLocalizations.of(context)!.copyLink,
              color: Colors.grey[700]!,
              onTap: () => _copyLink(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.shareNodes,
              label: AppLocalizations.of(context)!.systemShare,
              color: Colors.blue[700]!,
              onTap: () => _shareSystem(context),
            ),
            _buildShareOption(
              context,
              icon: FontAwesomeIcons.envelope,
              label: AppLocalizations.of(context)!.email,
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
                label: AppLocalizations.of(context)!.wechat,
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
                label: AppLocalizations.of(context)!.weibo,
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
      // 使用微信 SDK 直接分享，带上 App Logo 缩略图
      await WechatShareUtil.shareToWeChat(
        url: shareUrl,
        title: title,
        description: description,
        thumbnail: _logoThumbnail,
        toTimeline: false,
      );
    } else {
      final shareText = '$title\n$description\n$shareUrl';
      await Share.share(shareText);
      if (context.mounted) {
        AppToast.info(AppLocalizations.of(context)!.wechatNotInstalledSystemShare);
      }
    }
  }

  /// 分享到朋友圈
  void _shareToWeChatMoments(BuildContext context) async {
    Navigator.pop(context);

    final isInstalled = await SocialSdkService.isWechatInstalled();
    if (isInstalled) {
      // 使用微信 SDK 直接分享到朋友圈，带上 App Logo 缩略图
      await WechatShareUtil.shareToWeChat(
        url: shareUrl,
        title: title,
        description: description,
        thumbnail: _logoThumbnail,
        toTimeline: true,
      );
    } else {
      final shareText = '$title\n$description\n$shareUrl';
      await Share.share(shareText);
      if (context.mounted) {
        AppToast.info(AppLocalizations.of(context)!.wechatNotInstalledSystemShare);
      }
    }
  }

  /// 分享到 QQ 好友
  void _shareToQQFriend(BuildContext context) async {
    Navigator.pop(context);

    await QQShareUtil.shareToQQFriend(
      url: shareUrl,
      title: title,
      summary: description,
      imageUri: _logoFileUri,
    );
  }

  /// 分享到 QQ 空间
  void _shareToQzone(BuildContext context) async {
    Navigator.pop(context);

    await QQShareUtil.shareToQzone(
      url: shareUrl,
      title: title,
      summary: description,
      imageUri: _logoFileUri,
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
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
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
                        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
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
                color: AppColors.textSecondary,
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
  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: shareUrl));
    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);
    AppToast.success(AppLocalizations.of(context)!.linkCopied);
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
          AppToast.error(AppLocalizations.of(context)!.cannotOpenShareLink);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppToast.error(AppLocalizations.of(context)!.shareFailedWithError(e.toString()));
      }
    }
  }
}
