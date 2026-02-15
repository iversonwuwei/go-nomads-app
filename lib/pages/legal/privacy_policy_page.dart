import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 隐私政策页面 - 完整展示隐私政策内容
///
/// 工信部合规要求：用户应能随时查阅完整的隐私政策文本。
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.privacyPolicy),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 生效日期
            Text(
              '生效日期：2026 年 2 月 10 日',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            const _SectionTitle('引言'),
            const _SectionBody(
              '欢迎使用「行途」（Go Nomads）。行途是一款专为数字游民打造的一站式社区与服务平台，'
              '提供城市探索、共享办公空间查询、社区活动、即时通讯、AI 行程规划等功能。'
              '我们深知个人信息对您的重要性，并将竭尽全力保护您的隐私安全。'
              '本隐私政策详细说明了我们在您使用行途移动应用程序（iOS/Android）、网站及相关服务时，'
              '如何收集、使用、存储、共享和保护您的个人信息。'
              '使用我们的服务即表示您同意本政策中描述的数据处理方式。',
            ),

            const _SectionTitle('一、我们收集的信息'),
            const _SectionBody(
              '我们可能收集以下类型的信息：\n\n'
              '1. 您主动提供的信息\n'
              '• 账号信息：手机号码、邮箱地址、用户名、头像、个人简介等注册与个人资料信息。\n'
              '• 社区内容：您发布的帖子、评论、活动信息、共享办公空间评价等用户生成内容。\n'
              '• 通讯信息：您通过即时聊天功能发送的消息内容（端到端加密传输）。\n'
              '• 支付信息：当您使用付费功能时，我们会收集必要的交易信息，但不直接存储您的银行卡号或支付密码。\n'
              '• 行程数据：您在 AI 行程规划功能中输入的旅行偏好和目的地信息。\n\n'
              '2. 自动收集的信息\n'
              '• 设备信息：设备型号、操作系统版本、唯一设备标识符、屏幕分辨率、语言设置。\n'
              '• 日志信息：访问时间、浏览页面、崩溃日志、功能使用频率。\n'
              '• 网络信息：IP 地址、网络类型、运营商信息。\n\n'
              '3. 经您授权后收集的信息\n'
              '• 位置信息：用于推荐附近城市、共享办公空间和活动（仅在您授权后收集）。\n'
              '• 相机与相册：用于拍摄和选择头像照片、社区内容图片。\n'
              '• 麦克风：用于聊天中录制和发送语音消息。\n'
              '• 日历：用于将活动和聚会添加到日历并设置提醒。\n'
              '• 通知权限：用于推送活动提醒、消息通知等。',
            ),

            const _SectionTitle('二、信息使用方式'),
            const _SectionBody(
              '我们收集的信息将用于以下用途：\n\n'
              '• 提供核心服务：账号注册与登录、城市信息展示、共享办公空间查询、社区功能、即时通讯、AI 行程规划。\n'
              '• 个性化体验：根据您的位置和偏好推荐城市、办公空间和社区活动。\n'
              '• 服务改进：分析服务使用情况与性能数据，优化产品功能与用户体验。\n'
              '• 安全保障：识别与防范欺诈行为、垃圾信息及安全威胁，保护您的账号安全。\n'
              '• 通知与沟通：发送服务通知、活动提醒和安全警报。\n'
              '• 付费功能：处理订阅和付费交易，提供客户支持。\n'
              '• 法律合规：遵守适用的法律法规要求。',
            ),

            const _SectionTitle('三、信息共享与披露'),
            const _SectionBody(
              '我们不会出售您的个人信息。仅在以下情形下，我们可能会与第三方共享您的信息：\n\n'
              '• 服务提供商：我们与受信任的第三方合作来运营服务，包括云存储（服务器托管）、消息推送、支付处理和数据分析服务商。'
              '这些合作方仅能在为我们提供服务的范围内访问您的信息，并受到严格的数据保护协议约束。\n\n'
              '• 社区互动：您在社区中公开发布的内容（帖子、评价、活动信息）对其他用户可见，请谨慎分享个人敏感信息。\n\n'
              '• 法律要求：当法律法规要求、政府部门依法调查或为保护我们及用户的合法权益时，我们可能会披露您的信息。\n\n'
              '• 业务转让：如发生合并、收购或资产出售，您的信息可能作为交易资产的一部分被转移，届时我们会通知您。\n\n'
              '• 征得同意：在上述情形之外，我们将在征得您明确同意后才共享您的信息。',
            ),

            const _SectionTitle('四、第三方SDK说明'),
            const _SectionBody(
              '为实现应用相关功能，我们集成了以下第三方SDK：\n\n'
              '【地图与定位类】\n'
              '• 高德定位SDK（北京市 高德软件有限公司）— 提供定位服务，可能收集精确/粗略位置信息、设备信息。'
              '隐私政策：https://lbs.amap.com/pages/privacy/\n'
              '• 高德轻量版地图SDK（北京市 高德软件有限公司）— 提供基础地图显示功能，可能收集位置信息、设备信息。'
              '隐私政策：https://lbs.amap.com/pages/privacy/\n'
              '• 高德地图SDK（北京市 高德软件有限公司）— 提供完整地图交互功能，可能收集位置信息、WIFI信息、设备信息。'
              '隐私政策：https://lbs.amap.com/pages/privacy/\n'
              '• Google Location Services（Google LLC）— 提供海外定位服务。'
              '隐私政策：https://policies.google.com/privacy\n\n'
              '【第三方登录类】\n'
              '• 微信OpenSDK（深圳市腾讯计算机系统有限公司）— 提供微信登录和分享功能。'
              '隐私政策：https://weixin.qq.com/cgi-bin/readtemplate?t=weixin_agreement&s=privacy\n'
              '• Google Account Login（Google LLC）— 提供Google账号登录功能。'
              '隐私政策：https://policies.google.com/privacy\n\n'
              '【社交通讯类】\n'
              '• 抖音开放平台SDK（北京微播视界科技有限公司）— 提供抖音登录功能，可能收集设备信息。'
              '隐私政策：https://www.douyin.com/agreements/?id=6773901168964798477\n'
              '• 腾讯云即时通信IM SDK（腾讯科技（深圳）有限公司）— 提供即时通信服务，可能收集存储信息。'
              '隐私政策：https://cloud.tencent.com/document/product/269/90455\n\n'
              '【基础功能类】\n'
              '• OkHttp3（Square）、Okio（Square）、谷歌Gson（Google）、ApacheHttp（Apache）、'
              'ReLinker（Keepsafe）、Sanselan（Apache）、图片压缩库（Compressor）、'
              'BouncyCastle — 基础网络通信、数据处理与加密功能，不主动收集个人信息。\n\n'
              '上述第三方SDK可能会按照其各自的隐私政策收集必要信息，请参阅各SDK的隐私政策了解详情。',
            ),

            const _SectionTitle('五、数据存储与安全'),
            const _SectionBody(
              '• 存储位置：您的数据存储在位于安全数据中心的云服务器上，我们选择符合行业安全标准的云服务提供商。\n\n'
              '• 存储期限：我们仅在实现本政策所述目的所需的最短时间内保留您的个人信息。'
              '当您注销账号后，我们将在合理期限内删除或匿名化您的个人数据，法律法规另有要求的除外。\n\n'
              '• 安全措施：我们采用业界标准的安全技术保护您的数据，包括但不限于：\n'
              '  — HTTPS/TLS 加密传输\n'
              '  — 数据库加密存储\n'
              '  — 访问控制与权限管理\n'
              '  — 定期安全审计与漏洞扫描\n'
              '  — 消息通讯端到端加密\n\n'
              '• 安全事件：尽管我们尽力保护数据安全，但无法保证绝对安全。'
              '如发生数据泄露，我们将按照法律要求及时通知受影响的用户并采取补救措施。',
            ),

            const _SectionTitle('六、您的权利'),
            const _SectionBody(
              '根据适用的数据保护法律，您享有以下权利：\n\n'
              '• 访问权：您可以随时在应用内查看和访问您的个人资料信息。\n'
              '• 更正权：您可以在个人设置中修改、更新您的账号信息和个人资料。\n'
              '• 删除权：您可以申请删除您的账号及关联的个人数据。请通过「设置 > 账号 > 注销账号」操作，'
              '或发送邮件至 hi@gonomads.app 提交删除请求。我们将在 15 个工作日内处理。\n'
              '• 数据导出：您可以申请导出您的个人数据副本，我们将以通用格式提供。\n'
              '• 撤回同意：您可以随时在设备系统设置中撤回位置、相机、通知等权限的授权。'
              '撤回同意不影响此前基于您同意的处理行为的合法性。\n'
              '• 限制处理：在特定情况下，您有权要求我们限制对您个人信息的处理。\n\n'
              '如需行使上述权利，请联系 hi@gonomads.app，我们将在核实您的身份后尽快处理。',
            ),

            const _SectionTitle('七、儿童隐私'),
            const _SectionBody(
              '行途的服务面向 16 周岁及以上的用户。我们不会在知情的情况下收集 16 周岁以下儿童的个人信息。'
              '如果我们发现无意中收集了儿童的个人信息，将立即采取措施删除相关数据。'
              '如果您是家长或监护人，发现您的孩子在未经同意的情况下向我们提供了个人信息，'
              '请联系 hi@gonomads.app，我们将及时处理。',
            ),

            const _SectionTitle('八、隐私政策变更'),
            const _SectionBody(
              '我们可能会不时更新本隐私政策，以反映服务变化或法律法规的要求。'
              '更新后的政策将在本页面发布，并更新顶部的「生效日期」。'
              '对于重大变更，我们将通过应用内通知、推送消息或电子邮件等方式提前告知您。'
              '建议您定期查阅本政策，了解我们最新的隐私保护措施。'
              '继续使用我们的服务即表示您接受更新后的隐私政策。',
            ),

            const _SectionTitle('九、联系我们'),
            const _SectionBody(
              '如果您对本隐私政策有任何疑问、意见或请求，欢迎通过以下方式联系我们：\n\n'
              '• 电子邮件：hi@gonomads.app\n'
              '• 应用内反馈：设置 > 帮助与反馈\n\n'
              '我们将在收到您的请求后 15 个工作日内予以回复。感谢您对行途的信任与支持。',
            ),

            const SizedBox(height: 24),
            const CopyrightWidget(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
