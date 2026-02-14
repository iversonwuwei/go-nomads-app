import 'dart:developer';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/permission_purpose_dialog.dart';

/// 日历服务 - 用于将事件添加到设备日历
class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  Location? _currentLocation;

  /// 初始化时区 - 使用 device_calendar 内置的时区支持
  Future<void> _initializeTimezone() async {
    if (_currentLocation != null) return;

    try {
      // 使用 device_calendar 内置的本地时区
      _currentLocation = local;
      log('📅 [Calendar] 使用本地时区: ${_currentLocation?.name}');
    } catch (e) {
      log('📅 [Calendar] 获取时区失败，使用 UTC: $e');
      _currentLocation = UTC;
    }
  }

  /// 请求日历权限
  ///
  /// 隐私合规：在请求系统日历权限前，先展示用途说明对话框，
  /// 告知用户我们为什么需要访问日历（添加活动提醒）。
  Future<bool> requestPermissions() async {
    try {
      // 先检查是否已有权限
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
        return true;
      }

      // 权限未授予，先展示用途说明对话框
      final shouldRequest = await PermissionPurposeDialog.showCalendarPermissionPurpose();
      if (!shouldRequest) {
        log('📅 [Calendar] 用户在用途说明对话框中拒绝了日历权限');
        return false;
      }

      // 用户同意后，发起系统权限请求
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
    } catch (e) {
      log('📅 [Calendar] 请求权限失败: $e');
      return false;
    }
  }

  /// 获取可写入的日历列表
  Future<List<Calendar>> getWritableCalendars() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) return [];

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) {
        return [];
      }

      // 过滤出可写入的日历
      return calendarsResult.data!.where((calendar) => calendar.isReadOnly == false).toList();
    } catch (e) {
      log('📅 [Calendar] 获取日历列表失败: $e');
      return [];
    }
  }

  /// 添加 Meetup 事件到日历
  ///
  /// [title] 事件标题
  /// [description] 事件描述
  /// [location] 事件地点
  /// [startTime] 开始时间
  /// [endTime] 结束时间（可选，默认为开始时间后2小时）
  /// [reminderMinutes] 提前提醒的分钟数（默认30分钟）
  Future<CalendarAddResult> addMeetupToCalendar({
    required BuildContext context,
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    DateTime? endTime,
    int reminderMinutes = 30,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // 初始化时区
      await _initializeTimezone();

      // 请求权限
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        log('📅 [Calendar] 权限被拒绝');
        return CalendarAddResult(
          success: false,
          message: l10n.calendarPermissionDenied,
        );
      }

      // 获取可写入的日历
      final calendars = await getWritableCalendars();
      if (calendars.isEmpty) {
        log('📅 [Calendar] 没有可用日历');
        return CalendarAddResult(
          success: false,
          message: l10n.noCalendarAvailable,
        );
      }

      // 选择第一个可用日历（通常是默认日历）
      // 也可以显示对话框让用户选择
      final calendar = calendars.first;

      // 创建事件
      final event = Event(
        calendar.id,
        title: title,
        description: description ?? 'Meetup organized via Go Nomads',
        location: location,
        start: TZDateTime.from(startTime, _currentLocation!),
        end: TZDateTime.from(
          endTime ?? startTime.add(const Duration(hours: 2)),
          _currentLocation!,
        ),
        reminders: [Reminder(minutes: reminderMinutes)],
      );

      // 添加事件
      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);

      if (result?.isSuccess == true && result?.data != null) {
        log('📅 [Calendar] 事件添加成功: ${result!.data}');
        return CalendarAddResult(
          success: true,
          message: l10n.eventAddedToCalendar,
          eventId: result.data,
        );
      } else {
        final errorMessage = result?.errors.map((e) => e.errorMessage).join(', ') ?? 'Unknown error';
        log('📅 [Calendar] 添加事件失败: $errorMessage');
        return CalendarAddResult(
          success: false,
          message: l10n.failedToAddEvent(errorMessage),
        );
      }
    } catch (e) {
      log('📅 [Calendar] 添加事件异常: $e');
      return CalendarAddResult(
        success: false,
        message: l10n.failedToAddEvent(e.toString()),
      );
    }
  }

  /// 显示添加到日历的确认对话框
  Future<bool> showAddToCalendarDialog({
    required BuildContext context,
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFFF4458)),
            const SizedBox(width: 12),
            Text(l10n.addToCalendar),
          ],
        ),
        content: Text(l10n.addToCalendarMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.notNow,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.addToCalendarButton),
          ),
        ],
      ),
    );

    if (shouldAdd == true && context.mounted) {
      final result = await addMeetupToCalendar(
        context: context,
        title: title,
        description: description,
        location: location,
        startTime: startTime,
        endTime: endTime,
      );

      if (result.success) {
        AppToast.success(result.message);
      } else {
        AppToast.error(result.message);
      }

      return result.success;
    }

    return false;
  }
}

/// 日历添加结果
class CalendarAddResult {
  final bool success;
  final String message;
  final String? eventId;

  CalendarAddResult({
    required this.success,
    required this.message,
    this.eventId,
  });
}
