import 'dart:typed_data';

import 'package:df_admin_mobile/controllers/locale_controller.dart';
import 'package:df_admin_mobile/utils/clipboard_share_util.dart';
import 'package:df_admin_mobile/utils/dingtalk_share_util.dart';
import 'package:df_admin_mobile/utils/email_share_util.dart';
import 'package:df_admin_mobile/utils/facebook_share_util.dart';
import 'package:df_admin_mobile/utils/image_save_util.dart';
import 'package:df_admin_mobile/utils/linkedin_share_util.dart';
import 'package:df_admin_mobile/utils/qq_share_util.dart';
import 'package:df_admin_mobile/utils/qzone_share_util.dart';
import 'package:df_admin_mobile/utils/share_card_generator.dart';
import 'package:df_admin_mobile/utils/sms_share_util.dart';
import 'package:df_admin_mobile/utils/system_share_util.dart';
import 'package:df_admin_mobile/utils/telegram_share_util.dart';
import 'package:df_admin_mobile/utils/twitter_share_util.dart';
import 'package:df_admin_mobile/utils/wechat_share_util.dart';
import 'package:df_admin_mobile/utils/weibo_share_util.dart';
import 'package:df_admin_mobile/utils/whatsapp_share_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

enum ShareChannel {
  system,
  copyLink,
  wechat,
  wechatTimeline,
  qq,
  qzone,
  weibo,
  dingtalk,
  whatsapp,
  telegram,
  twitter,
  facebook,
  linkedin,
  email,
  sms,
  saveImage,
}

class ShareService {
  final ShareCardGenerator _cardGenerator = ShareCardGenerator();

  /// 显示分享通道选择弹窗
  Future<void> showShareDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String url,
    String? imageUrl,
  }) async {
    final imageBytes = await _cardGenerator.generateShareCardImage(
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl,
    );

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => _ShareChannelSheet(
        title: title,
        description: description,
        url: url,
        imageBytes: imageBytes,
      ),
    );
  }
}

class _ShareChannelSheet extends StatelessWidget {
  final String title;
  final String description;
  final String url;
  final Uint8List? imageBytes;

  const _ShareChannelSheet({
    required this.title,
    required this.description,
    required this.url,
    this.imageBytes,
  });

  /// 判断是否为中国区用户
  bool get _isChineseUser {
    final localeController = Get.find<LocaleController>();
    final locale = localeController.locale.value;
    // 中国大陆、香港、澳门、台湾
    return locale.languageCode == 'zh' ||
        locale.countryCode == 'CN' ||
        locale.countryCode == 'HK' ||
        locale.countryCode == 'MO' ||
        locale.countryCode == 'TW';
  }

  /// 获取国内社交分享通道
  List<Widget> _buildChineseChannels() {
    return [
      _ShareButton(
        icon: FontAwesomeIcons.weixin,
        label: '微信',
        color: const Color(0xFF07C160),
        onTap: () => _share(ShareChannel.wechat),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.weixin,
        label: '朋友圈',
        color: const Color(0xFF07C160),
        onTap: () => _share(ShareChannel.wechatTimeline),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.qq,
        label: 'QQ',
        color: const Color(0xFF12B7F5),
        onTap: () => _share(ShareChannel.qq),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.qq,
        label: 'QQ空间',
        color: const Color(0xFFFECE00),
        onTap: () => _share(ShareChannel.qzone),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.weibo,
        label: '微博',
        color: const Color(0xFFE6162D),
        onTap: () => _share(ShareChannel.weibo),
      ),
    ];
  }

  /// 获取国际社交分享通道
  List<Widget> _buildInternationalChannels() {
    return [
      _ShareButton(
        icon: FontAwesomeIcons.whatsapp,
        label: 'WhatsApp',
        color: const Color(0xFF25D366),
        onTap: () => _share(ShareChannel.whatsapp),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.telegram,
        label: 'Telegram',
        color: const Color(0xFF0088CC),
        onTap: () => _share(ShareChannel.telegram),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.xTwitter,
        label: 'X/Twitter',
        color: Colors.black,
        onTap: () => _share(ShareChannel.twitter),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.facebook,
        label: 'Facebook',
        color: const Color(0xFF1877F2),
        onTap: () => _share(ShareChannel.facebook),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: FontAwesomeIcons.linkedin,
        label: 'LinkedIn',
        color: const Color(0xFF0A66C2),
        onTap: () => _share(ShareChannel.linkedin),
      ),
    ];
  }

  /// 获取通用分享通道（始终显示）
  List<Widget> _buildCommonChannels() {
    return [
      _ShareButton(
        icon: Icons.copy,
        label: '复制链接'.tr,
        color: Colors.grey,
        onTap: () => _share(ShareChannel.copyLink),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: Icons.email,
        label: '邮件'.tr,
        color: Colors.orange,
        onTap: () => _share(ShareChannel.email),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: Icons.save_alt,
        label: '保存图片'.tr,
        color: Colors.blue,
        onTap: () => _share(ShareChannel.saveImage),
      ),
      const SizedBox(width: 16),
      _ShareButton(
        icon: Icons.share,
        label: '更多'.tr,
        color: Colors.purple,
        onTap: () => _share(ShareChannel.system),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = _isChineseUser;

    // 根据地区决定显示顺序：优先显示当地常用通道
    final primaryChannels = isChinese ? _buildChineseChannels() : _buildInternationalChannels();
    final secondaryChannels = isChinese ? _buildInternationalChannels() : _buildChineseChannels();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('分享到'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // 第一行：当地常用社交
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: primaryChannels),
            ),
            const SizedBox(height: 16),
            // 第二行：其他地区社交
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: secondaryChannels),
            ),
            const SizedBox(height: 16),
            // 第三行：通用通道
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buildCommonChannels()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(ShareChannel channel) async {
    Get.back();
    switch (channel) {
      case ShareChannel.system:
        await SystemShareUtil.shareCard(text: '$title - $url', imageBytes: imageBytes);
        break;
      case ShareChannel.copyLink:
        await ClipboardShareUtil.copyLink(url: url, text: title);
        break;
      case ShareChannel.wechat:
        await WechatShareUtil.shareToWeChat(url: url, title: title, description: description, thumbnail: imageBytes);
        break;
      case ShareChannel.wechatTimeline:
        await WechatShareUtil.shareToWeChat(
            url: url, title: title, description: description, thumbnail: imageBytes, toTimeline: true);
        break;
      case ShareChannel.qq:
        await QQShareUtil.shareToQQ(url: url, title: title, summary: description, imageBytes: imageBytes);
        break;
      case ShareChannel.qzone:
        await QzoneShareUtil.shareToQzone(url: url, title: title, summary: description);
        break;
      case ShareChannel.weibo:
        await WeiboShareUtil.shareToWeibo(url: url, title: title, description: description, imageBytes: imageBytes);
        break;
      case ShareChannel.dingtalk:
        await DingTalkShareUtil.shareToDingTalk(url: url, title: title, content: description);
        break;
      case ShareChannel.whatsapp:
        await WhatsappShareUtil.shareToWhatsApp(text: '$title - $description', url: url);
        break;
      case ShareChannel.telegram:
        await TelegramShareUtil.shareToTelegram(text: '$title - $description', url: url);
        break;
      case ShareChannel.twitter:
        await TwitterShareUtil.shareToTwitter(text: '$title - $description', url: url);
        break;
      case ShareChannel.facebook:
        await FacebookShareUtil.shareToFacebook(url: url, quote: '$title - $description');
        break;
      case ShareChannel.linkedin:
        await LinkedInShareUtil.shareToLinkedIn(url: url, title: title, summary: description);
        break;
      case ShareChannel.email:
        await EmailShareUtil.shareViaEmail(subject: title, body: description, url: url);
        break;
      case ShareChannel.sms:
        await SmsShareUtil.shareViaSms(text: '$title: $description', url: url);
        break;
      case ShareChannel.saveImage:
        if (imageBytes != null) {
          await ImageSaveUtil.saveImageToGallery(imageBytes!);
        }
        break;
    }
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color ?? Theme.of(context).primaryColor,
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
