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
    }
  }

  String get title {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return '一键值机';
      case AutomationScenario.calendarSync:
        return '行程同步';
      case AutomationScenario.expenseRecord:
        return '记账';
      case AutomationScenario.visaReminder:
        return '签证提醒';
      case AutomationScenario.formFill:
        return '表格预填';
      case AutomationScenario.workMode:
        return '工作模式';
      case AutomationScenario.meetingPrep:
        return '会议准备';
      case AutomationScenario.collectMaterial:
        return '素材收集';
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
        return '💼';
      case AutomationScenario.meetingPrep:
        return '🎥';
      case AutomationScenario.collectMaterial:
        return '📎';
    }
  }

  String get description {
    switch (this) {
      case AutomationScenario.flightCheckin:
        return '自动打开航司App完成值机';
      case AutomationScenario.calendarSync:
        return '将订单同步到系统日历';
      case AutomationScenario.expenseRecord:
        return '自动记录支出到记账本';
      case AutomationScenario.visaReminder:
        return '设置签证到期提醒';
      case AutomationScenario.formFill:
        return '自动填写表单信息';
      case AutomationScenario.workMode:
        return '打开工作App，设置免打扰';
      case AutomationScenario.meetingPrep:
        return '准备会议投屏和资料';
      case AutomationScenario.collectMaterial:
        return '保存文章到笔记软件';
    }
  }
}
