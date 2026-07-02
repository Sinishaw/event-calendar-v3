import 'package:event_calendar_v2/common/globals.dart';
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
