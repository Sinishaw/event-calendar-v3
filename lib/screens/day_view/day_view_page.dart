import 'dart:convert';

import 'package:event_calendar_v2/screens/day_view/models/day_event.dart';
import 'package:event_calendar_v2/screens/day_view/utils/timeline_utils.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/all_day_strip.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/day_nav_header.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/day_timeline.dart';
import 'package:event_calendar_v2/screens/events/models/holiday_and_national_events.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/plans/user_event_page.dart';
import 'package:event_calendar_v2/shared/enums.dart';
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
  static const int _kInitialPage = 500;
  late PageController _pageController;
  late DateTime _baseDate;
  final Map<int, ScrollController> _pageScrollControllers = {};
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
    _baseDate = _currentDate;
    _pageController = PageController(initialPage: _kInitialPage);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final sc in _pageScrollControllers.values) {
      sc.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    final primary = Theme.of(context).primaryColor;
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    final date = _currentDate;
    final viewDate = DateTime(date.year, date.month, date.day);
    final dayEvents = <DayEvent>[];

    for (final req in pending) {
      try {
        final map = jsonDecode(req.payload ?? '{}') as Map<String, dynamic>;
        final payload = NotificationPayload.fromJson(map);
        final scheduled = payload.scheduledDateTime;
        if (scheduled == null) continue;
        if (payload.visible == 'false') continue;

        final scheduledDate = DateTime(scheduled.year, scheduled.month, scheduled.day);
        bool isForDate;
        DateTime startOnDate;

        switch (payload.repeatOption) {
          case NotificationRepeatOption.daily:
            isForDate = !viewDate.isBefore(scheduledDate);
            startOnDate = DateTime(date.year, date.month, date.day, scheduled.hour, scheduled.minute);
          case NotificationRepeatOption.weekly:
            isForDate = scheduled.weekday == date.weekday && !viewDate.isBefore(scheduledDate);
            startOnDate = DateTime(date.year, date.month, date.day, scheduled.hour, scheduled.minute);
          default:
            isForDate = scheduled.year == date.year &&
                scheduled.month == date.month &&
                scheduled.day == date.day;
            startOnDate = scheduled;
        }

        if (!isForDate) continue;
        dayEvents.add(DayEvent.fromNotificationPayload(payload, primary,
            overrideStartTime: startOnDate));
      } catch (_) {}
    }

    final et = MonthModel.toEc(year: date.year, month: date.month, day: date.day);
    if (et?.year != null && et?.month != null && et?.day != null) {
      final nationals = HolidayAndNationalEvents.getDailHolidays(et!.year!, et.month!, et.day!);
      for (int i = 0; i < nationals.length; i++) {
        dayEvents.add(DayEvent.fromNationalDay(nationals[i], i));
      }
    }

    if (mounted) {
      setState(() {
        _events = dayEvents;
        _loading = false;
      });
      _scrollToCurrentTime();
    }
  }

  ScrollController _getScrollController(int page) =>
      _pageScrollControllers.putIfAbsent(page, () => ScrollController());

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final isToday = _currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day;
    final page = _pageController.hasClients
        ? (_pageController.page?.round() ?? _kInitialPage)
        : _kInitialPage;
    final sc = _getScrollController(page);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!sc.hasClients) return;
      final viewport = sc.position.viewportDimension;
      if (isToday) {
        sc.animateTo(
          TimelineUtils.scrollOffsetForCurrentTime(viewport),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } else {
        const morningY = 8 * TimelineUtils.hourHeight;
        sc.jumpTo((morningY - viewport / 2).clamp(0.0, TimelineUtils.totalHeight));
      }
    });
  }

  void _onDateChanged(DateTime date) {
    final page = _kInitialPage + date.difference(_baseDate).inDays;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    final newDate = _baseDate.add(Duration(days: page - _kInitialPage));
    setState(() => _currentDate = newDate);
    _loadEvents();
  }

  void _onTimeLongPressed(DateTime selectedTime) {
    if (widget.onTimeSelected != null) {
      widget.onTimeSelected!(selectedTime);
      Navigator.of(context).pop(selectedTime);
    }
  }

  void _onEventLongPressed(DayEvent event) {
    if (event.payload == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserEventPage(eventToEdit: event.payload),
      ),
    ).then((_) => _loadEvents());
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
            Divider(height: 1, thickness: 0.5, color: Theme.of(context).colorScheme.secondary),
            AllDayStrip(events: _events),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, page) {
                  final date =
                      _baseDate.add(Duration(days: page - _kInitialPage));
                  final isCurrentDay = date.year == _currentDate.year &&
                      date.month == _currentDate.month &&
                      date.day == _currentDate.day;
                  if (isCurrentDay && _loading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  return DayTimeline(
                    date: date,
                    events: isCurrentDay ? _events : const [],
                    onTimeLongPressed: isCurrentDay ? _onTimeLongPressed : null,
                    onEventLongPressed: _onEventLongPressed,
                    scrollController: _getScrollController(page),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
