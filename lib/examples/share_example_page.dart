import 'package:df_admin_mobile/widgets/share_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 分享功能测试页面示例
/// 
/// 这个示例展示了如何在任何页面中使用分享功能
class ShareExamplePage extends StatelessWidget {
  const ShareExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分享功能示例'),
        actions: [
          // 在 AppBar 中添加分享按钮
          IconButton(
            icon: const Icon(FontAwesomeIcons.shareNodes),
            onPressed: () => _showShare(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '点击右上角分享按钮\n或下方按钮测试分享功能',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showShare(context),
              icon: const Icon(FontAwesomeIcons.shareNodes),
              label: const Text('分享此页面'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示分享底部抽屉
  void _showShare(BuildContext context) {
    ShareBottomSheet.show(
      context,
      title: '行途 - 数字游民城市探索应用',
      description: '发现全球最适合数字游民的城市，探索最佳Coworking空间，连接全球数字游民社区。',
      imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000',
      shareUrl: 'https://nomadcities.app',
    );
  }
}

/// 在路由中使用示例：
/// 
/// Get.to(() => ShareExamplePage());
/// 
/// 或者在任何页面的按钮中：
/// 
/// ```dart
/// IconButton(
///   icon: Icon(FontAwesomeIcons.shareNodes),
///   onPressed: () {
///     ShareBottomSheet.show(
///       context,
///       title: '您的标题',
///       description: '您的描述',
///       shareUrl: '您的链接',
///     );
///   },
/// )
/// ```
