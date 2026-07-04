import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/events/models/fixed_national_events_detail.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:flutter/material.dart';

/// Unified display model for the day view timeline.
/// Wraps any event source — currently calendar events (NotificationPayload).
/// Future sources (tasks, company content) add their own factory constructors.
class DayEvent {
  final int id;
  final String title;
  final String? body;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final EventTagOption tagOption;
  final bool isAllDay;
  final NotificationPayload? payload;

  const DayEvent({
    required this.id,
    required this.title,
    this.body,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.tagOption,
    this.isAllDay = false,
    this.payload,
  });

  /// Maps EventTagOption to its display color, matching daily_user_event_list logic.
  static Color colorForTag(EventTagOption tag, Color primaryColor) {
    if (tag == EventTagOption.national) return primaryColor;
    final index = tag.index;
    if (index < Globals.categoryColorList.length) {
      return Globals.categoryColorList[index];
    }
    return primaryColor;
  }

  factory DayEvent.fromNationalDay(FixedNationalEventsDetail holiday, int index) {
    final gc = holiday.gcDate ?? DateTime.now();
    final color = _colorForHolidayType(holiday.holidayType);
    return DayEvent(
      id: 90000 + index,
      title: holiday.name ?? '',
      startTime: DateTime(gc.year, gc.month, gc.day),
      endTime: DateTime(gc.year, gc.month, gc.day, 23, 59),
      color: color,
      tagOption: EventTagOption.national,
      isAllDay: true,
    );
  }

  static Color _colorForHolidayType(HolidayType? type) {
    switch (type) {
      case HolidayType.christian: return const Color(0xFFF5A623);
      case HolidayType.federal:   return const Color(0xFF078930);
      case HolidayType.muslim:    return const Color(0xFF009688);
      default:                    return const Color(0xFF7B61FF);
    }
  }

  factory DayEvent.fromNotificationPayload(
    NotificationPayload payload,
    Color primaryColor, {
    DateTime? overrideStartTime,
  }) {
    final start = overrideStartTime ?? payload.scheduledDateTime ?? DateTime.now();
    final tag = payload.eventTagOption ?? EventTagOption.regular;
    return DayEvent(
      id: payload.id ?? 0,
      title: payload.title ?? '',
      body: payload.body,
      startTime: start,
      endTime: start.add(Duration(minutes: payload.durationMinutes ?? 60)),
      color: colorForTag(tag, primaryColor),
      tagOption: tag,
      payload: payload,
    );
  }

  Duration get duration => endTime.difference(startTime);
}
