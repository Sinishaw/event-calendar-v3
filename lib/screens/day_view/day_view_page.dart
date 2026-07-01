import 'dart:convert';

import 'package:event_calendar_v2/screens/day_view/models/day_event.dart';
import 'package:event_calendar_v2/screens/day_view/utils/timeline_utils.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/all_day_strip.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/day_nav_header.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/day_timeline.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Google Calendar-style day view.
///
/// [initialDate] — the day to show on open.
/// [onTimeSelected] — called when the user long-presses a time slot.
///   If provided, the page pops immediately after calling it so the caller
///   receives the selected [DateTime] via [Navigator.pop].
///   If null, the page stays open after a long press (future: standalone mode).
class DayViewPage extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onTimeSelected;

  const DayViewPage({
    super.key,
    required this.initialDate,
    this.onTimeSelected,
  });

  @override
  State<DayViewPage> createState() => _DayViewPageState();
}

class _DayViewPageState extends State<DayViewPage> {
  late DateTime _currentDate;
  late ScrollController _scrollController;
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  List<DayEvent> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    final primary = Theme.of(context).primaryColor;
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    final dayEvents = <DayEvent>[];

    for (final req in pending) {
      try {
        final map = jsonDecode(req.payload ?? '{}') as Map<String, dynamic>;
        final payload = NotificationPayload.fromJson(map);
        final scheduled = payload.scheduledDateTime;
        if (scheduled == null) continue;
        if (scheduled.year == _currentDate.year &&
            scheduled.month == _currentDate.month &&
            scheduled.day == _currentDate.day) {
          dayEvents.add(DayEvent.fromNotificationPayload(payload, primary));
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _events = dayEvents;
        _loading = false;
      });
      _scrollToCurrentTime();
    }
  }

  void _scrollToCurrentTime() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final viewport = _scrollController.position.viewportDimension;
      final offset =
          TimelineUtils.scrollOffsetForCurrentTime(viewport);
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() => _currentDate = date);
    _loadEvents();
  }

  void _onTimeLongPressed(DateTime selectedTime) {
    if (widget.onTimeSelected != null) {
      widget.onTimeSelected!(selectedTime);
      Navigator.of(context).pop(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Day View',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            DayNavHeader(
              date: _currentDate,
              onDateChanged: _onDateChanged,
            ),
            const Divider(height: 1),
            AllDayStrip(events: _events),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : DayTimeline(
                      date: _currentDate,
                      events: _events,
                      onTimeLongPressed: _onTimeLongPressed,
                      scrollController: _scrollController,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
