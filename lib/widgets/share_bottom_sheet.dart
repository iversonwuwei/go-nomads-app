import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 分享底部抽屉
/// 支持分享到国内外主流社交平台
class ShareBottomSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              child: Text(
                '分享到',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // 分享选项
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  // 第一行：国际平台
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
                  
                  // 第二行：国内平台
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShareOption(
                        context,
                        icon: FontAwesomeIcons.weixin,
                        label: '微信',
                        color: const Color(0xFF09B83E),
                        onTap: () => _shareToWeChat(context),
                      ),
                      _buildShareOption(
                        context,
                        icon: FontAwesomeIcons.weibo,
                        label: '微博',
                        color: const Color(0xFFE6162D),
                        onTap: () => _shareToWeibo(context),
                      ),
                      _buildShareOption(
                        context,
                        icon: FontAwesomeIcons.qq,
                        label: 'QQ',
                        color: const Color(0xFF12B7F5),
                        onTap: () => _shareToQQ(context),
                      ),
                      _buildShareOption(
                        context,
                        icon: FontAwesomeIcons.telegram,
                        label: 'Telegram',
                        color: const Color(0xFF0088CC),
                        onTap: () => _shareToTelegram(context),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // 第三行：其他平台
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
                      _buildShareOption(
                        context,
                        icon: FontAwesomeIcons.envelope,
                        label: '邮件',
                        color: Colors.orange[700]!,
                        onTap: () => _shareToEmail(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// 构建分享选项
  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
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

  /// 分享到微信（使用系统分享，因为微信需要 SDK）
  void _shareToWeChat(BuildContext context) async {
    final shareText = '$title\n$description\n$shareUrl';
    await Share.share(shareText);
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请在分享菜单中选择微信'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 分享到微博
  void _shareToWeibo(BuildContext context) async {
    final text = Uri.encodeComponent('$title - $description');
    final url = Uri.encodeComponent(shareUrl);
    final weiboUrl = 'https://service.weibo.com/share/share.php?title=$text&url=$url';
    
    await _launchUrl(context, weiboUrl);
  }

  /// 分享到 QQ（使用系统分享，因为 QQ 需要 SDK）
  void _shareToQQ(BuildContext context) async {
    final shareText = '$title\n$description\n$shareUrl';
    await Share.share(shareText);
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请在分享菜单中选择QQ'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
