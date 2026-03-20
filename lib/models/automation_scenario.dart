import 'package:flutter/material.dart';

/// OpenClaw 场景分类
enum ScenarioCategory {
  /// 差旅自动化
  travel,

  /// 远程办公
  remoteWork,

  /// 记账报销
  finance,

  /// 签证合规
  visa,

  /// 万能插件
  universal,
}

extension ScenarioCategoryExtension on ScenarioCategory {
  String get title {
    switch (this) {
      case ScenarioCategory.travel:
        return '差旅自动化';
      case ScenarioCategory.remoteWork:
        return '远程办公';
      case ScenarioCategory.finance:
        return '记账报销';
      case ScenarioCategory.visa:
        return '签证合规';
      case ScenarioCategory.universal:
        return '万能插件';
    }
  }

  String get subtitle {
    switch (this) {
      case ScenarioCategory.travel:
        return '值机、行程同步一键搞定';
      case ScenarioCategory.remoteWork:
        return '专注模式、会议准备自动化';
      case ScenarioCategory.finance:
        return '自动记账、发票整理';
      case ScenarioCategory.visa:
        return '签证到期提醒，避免非法滞留';
      case ScenarioCategory.universal:
        return '自定义任意 App 自动化脚本';
    }
  }

  String get icon {
    switch (this) {
      case ScenarioCategory.travel:
        return '✈️';
      case ScenarioCategory.remoteWork:
        return '💻';
      case ScenarioCategory.finance:
        return '💰';
      case ScenarioCategory.visa:
        return '🛂';
      case ScenarioCategory.universal:
        return '🔌';
    }
  }

  Color get color {
    switch (this) {
      case ScenarioCategory.travel:
        return const Color(0xFF0EA5E9);
      case ScenarioCategory.remoteWork:
        return const Color(0xFF8B5CF6);
      case ScenarioCategory.finance:
        return const Color(0xFFF59E0B);
      case ScenarioCategory.visa:
        return const Color(0xFFEF4444);
      case ScenarioCategory.universal:
        return const Color(0xFF10B981);
    }
  }

  List<AutomationScenario> get scenarios {
    switch (this) {
      case ScenarioCategory.travel:
        return [AutomationScenario.flightCheckin, AutomationScenario.calendarSync];
      case ScenarioCategory.remoteWork:
        return [AutomationScenario.workMode, AutomationScenario.meetingPrep];
      case ScenarioCategory.finance:
        return [AutomationScenario.expenseRecord, AutomationScenario.invoiceOrganize];
      case ScenarioCategory.visa:
        return [AutomationScenario.visaReminder];
      case ScenarioCategory.universal:
        return [AutomationScenario.customScript, AutomationScenario.formFill, AutomationScenario.collectMaterial];
    }
  }
}

/// OpenClaw 自动化场景枚举
enum AutomationScenario {
  /// 一键值机
  flightCheckin,

  /// 行程同步
  calendarSync,

  /// 记账
  expenseRecord,

  /// 签证提醒
  visaReminder,

  /// 表格预填
  formFill,

  /// 工作模式
  workMode,

  /// 会议准备
  meetingPrep,

  /// 素材收集
  collectMaterial,

  /// 发票整理
  invoiceOrganize,

  /// 任意 App 脚本
  customScript,
}

extension AutomationScenarioExtension on AutomationScenario {
  String get name {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return 'flight_checkin';
      case AutomationScenario.calendarSync:
        return 'calendar_sync';
      case AutomationScenario.expenseRecord:
        return 'expense_record';
      case AutomationScenario.visaReminder:
        return 'visa_reminder';
      case AutomationScenario.formFill:
        return 'form_fill';
      case AutomationScenario.workMode:
        return 'work_mode';
      case AutomationScenario.meetingPrep:
        return 'meeting_prep';
      case AutomationScenario.collectMaterial:
        return 'collect_material';
      case AutomationScenario.invoiceOrganize:
        return 'invoice_organize';
      case AutomationScenario.customScript:
        return 'custom_script';
    }
  }

  String get title {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return '一键值机';
      case AutomationScenario.calendarSync:
        return '行程同步';
      case AutomationScenario.expenseRecord:
        return '支付即记账';
      case AutomationScenario.visaReminder:
        return '续签提醒';
      case AutomationScenario.formFill:
        return '表格预填';
      case AutomationScenario.workMode:
        return '专注模式';
      case AutomationScenario.meetingPrep:
        return '会议助手';
      case AutomationScenario.collectMaterial:
        return '素材收集';
      case AutomationScenario.invoiceOrganize:
        return '发票整理';
      case AutomationScenario.customScript:
        return '自定义脚本';
    }
  }

  String get icon {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return '✈️';
      case AutomationScenario.calendarSync:
        return '📅';
      case AutomationScenario.expenseRecord:
        return '💰';
      case AutomationScenario.visaReminder:
        return '🛂';
      case AutomationScenario.formFill:
        return '📝';
      case AutomationScenario.workMode:
        return '🧘';
      case AutomationScenario.meetingPrep:
        return '🎥';
      case AutomationScenario.collectMaterial:
        return '📎';
      case AutomationScenario.invoiceOrganize:
        return '🧾';
      case AutomationScenario.customScript:
        return '⚙️';
    }
  }

  String get description {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return '打开航司 App → 读取行程 → 点击值机 → 保存登机牌';
      case AutomationScenario.calendarSync:
        return '打开携程 → 读取订单详情 → 打开日历 → 创建事件';
      case AutomationScenario.expenseRecord:
        return '监听支付通知 → 提取金额 → 打开记账 App 填单';
      case AutomationScenario.visaReminder:
        return '读取签证信息 → 打开系统日历 → 设置多次提醒';
      case AutomationScenario.formFill:
        return '自动填写表单信息';
      case AutomationScenario.workMode:
        return '关闭社交 App → 打开飞书 → 设置免打扰 → 调亮度';
      case AutomationScenario.meetingPrep:
        return '打开腾讯会议 → 检查麦克风 → 打开 Notion 模板';
      case AutomationScenario.collectMaterial:
        return '保存文章到笔记软件';
      case AutomationScenario.invoiceOrganize:
        return '打开微信卡包 → 筛选发票 → 打开邮件 → 添加附件发送';
      case AutomationScenario.customScript:
        return '自定义任意 App 定时任务与自动化脚本';
    }
  }

  /// 用户指令示例（用于引导用户输入）
  String get exampleCommand {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return '帮我值机明天下午去上海的航班';
      case AutomationScenario.calendarSync:
        return '把携程的订单同步到系统日历';
      case AutomationScenario.expenseRecord:
        return '刚才那笔 50 元记入餐饮';
      case AutomationScenario.visaReminder:
        return '泰国签证还有 30 天到期，帮我设提醒';
      case AutomationScenario.formFill:
        return '帮我自动填写入境申报表';
      case AutomationScenario.workMode:
        return '开始工作模式';
      case AutomationScenario.meetingPrep:
        return '准备 10 点的产品评审会';
      case AutomationScenario.collectMaterial:
        return '把这篇文章保存到 Notion';
      case AutomationScenario.invoiceOrganize:
        return '把本周的发票都发到财务邮箱';
      case AutomationScenario.customScript:
        return '每天早上 9 点自动打开得到 App 听书';
    }
  }

  /// 价值说明
  String get valuePoint {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return '节省操作时间，避免错过值机';
      case AutomationScenario.calendarSync:
        return '无需携程 API，数据掌握在自己手中';
      case AutomationScenario.expenseRecord:
        return '无需银行 API，通过通知栏自动化';
      case AutomationScenario.visaReminder:
        return '避免非法滞留风险';
      case AutomationScenario.formFill:
        return '减少重复手动输入';
      case AutomationScenario.workMode:
        return '物理级防沉迷，快速进入心流';
      case AutomationScenario.meetingPrep:
        return '避免开会手忙脚乱忘开麦';
      case AutomationScenario.collectMaterial:
        return '随时收藏灵感素材';
      case AutomationScenario.invoiceOrganize:
        return '解决报销痛点，适合自由职业者';
      case AutomationScenario.customScript:
        return '将 Go Nomads 变成手机任务调度中心';
    }
  }

  ScenarioCategory get category {
    switch (this) {
      case AutomationScenario.flightCheckin:
      case AutomationScenario.calendarSync:
        return ScenarioCategory.travel;
      case AutomationScenario.workMode:
      case AutomationScenario.meetingPrep:
        return ScenarioCategory.remoteWork;
      case AutomationScenario.expenseRecord:
      case AutomationScenario.invoiceOrganize:
        return ScenarioCategory.finance;
      case AutomationScenario.visaReminder:
        return ScenarioCategory.visa;
      case AutomationScenario.formFill:
      case AutomationScenario.collectMaterial:
      case AutomationScenario.customScript:
        return ScenarioCategory.universal;
    }
  }
}
