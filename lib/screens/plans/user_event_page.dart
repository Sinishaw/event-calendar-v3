import 'dart:convert';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/day_view/models/day_event.dart';
import 'package:event_calendar_v2/screens/day_view/utils/timeline_utils.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/all_day_strip.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/day_nav_header.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/day_timeline.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/widgets/date_picker_dialog_local.dart';
import 'package:event_calendar_v2/shared/widgets/time_picker_dialog_local.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/models/local_time_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'widgets/daily_user_event_list.dart';
import 'widgets/duration_picker.dart';
import 'widgets/event_category_picker.dart';
import 'widgets/notification_repeat_picker.dart';
import 'widgets/notification_schedule_picker.dart';

class UserEventPage extends StatefulWidget {
  static const String routeName = '/user_events';
  const UserEventPage({super.key, this.title, this.selectedEtDate, this.fetchLatestEventsCallback, this.eventToEdit});

  final String? title;
  final LocalDate? selectedEtDate;
  final Function? fetchLatestEventsCallback;
  final NotificationPayload? eventToEdit;

  bool get didNotificationLaunchApp => Globals.notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  State<UserEventPage> createState() => _UserEventPageState();
}

class _UserEventPageState extends State<UserEventPage> {
  String? eventTitle, eventNote;
  DateTime? initGcDate;
  LocalDate? _selectedEtDate, selectedGcDate;

  LocalTime? selectedEtTime, selectedGcTime, selectedGcTime24;
  int? scheduleGc24Hour;
  int? selectedEventTag, selectedRepeatOption, selectedNotificationSchedule;
  int _selectedDurationMinutes = 60;

  final _titleTextController = TextEditingController();
  final _bodyTextController = TextEditingController();
  late bool isGeezNumbers;

  // Day view embedded state
  bool _showDayView = false;
  late DateTime _dayViewDate;
  List<DayEvent> _dayViewEvents = [];
  bool _dayViewLoading = false;
  static const int _kDayViewInitialPage = 500;
  late PageController _dayPageController;
  late DateTime _dayPageBaseDate;
  final Map<int, ScrollController> _pageScrollControllers = {};
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  getSelectedDateCallBack(LocalDate etSelectedDate, LocalDate gcSelectedDate) {
    setState(() {
      _selectedEtDate = etSelectedDate;
      selectedGcDate = gcSelectedDate;
      if (gcSelectedDate.year != null && gcSelectedDate.month != null && gcSelectedDate.day != null) {
        _dayViewDate = DateTime(gcSelectedDate.year!, gcSelectedDate.month!, gcSelectedDate.day!);
      }
    });
  }

  getSelectedTimeCallBack(LocalTime etSelectedTime, LocalTime gcSelectedTime, LocalTime gcSelectedTime24) {
    debugPrint("------ ~ ET Time: ${etSelectedTime.hour}: ${etSelectedTime.minute}: ${etSelectedTime.period}");
    debugPrint("------ ~ GC Time: ${gcSelectedTime.hour}: ${gcSelectedTime.minute}: ${gcSelectedTime.period}");

    setState(() {
      selectedEtTime = etSelectedTime;
      selectedGcTime = gcSelectedTime;
      selectedGcTime24 = gcSelectedTime24;
    });
  }

  getSelectedCategoryCallBack(int index) {
    setState(() {
      selectedEventTag = index;
    });
  }

  getSelectedRecurrenceCallBack(int index) {
    setState(() {
      selectedRepeatOption = index;
    });
  }

  getSelectedNotificationScheduleCallBack(int index) {
    setState(() {
      selectedNotificationSchedule = index;
    });
  }

  _resetEntry({bool keepDate = false}) {
    ///Set title and note to empty
    _titleTextController.clear();
    _bodyTextController.clear();
    eventTitle = null;
    eventNote = null;

    if (!keepDate) {
      ///Initialize date and time picker to current date and time
      _selectedEtDate = LocalDate.date();
      selectedGcDate = LocalDate.date();

      LocalDate? gcDateConverted;
      if (widget.selectedEtDate != null) {
        gcDateConverted = MonthModel.toGc(
            year: widget.selectedEtDate!.year!, month: widget.selectedEtDate!.month!, day: widget.selectedEtDate!.day!);
      }

      DateTime gcDate = DateTime.now();

      if (gcDateConverted != null) {
        gcDate = DateTime(gcDateConverted.year!, gcDateConverted.month!, gcDateConverted.day!);
      }

      selectedGcDate!.year = gcDate.year;
      selectedGcDate!.month = gcDate.month;
      selectedGcDate!.day = gcDate.day;
      selectedGcDate!.weekDay = gcDate.weekday;

      LocalDate gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
      LocalDate etNow = MonthModel.toEc(year: gcNow.year!, month: gcNow.month!, day: gcNow.day!)!;

      _selectedEtDate!.year = etNow.year;
      _selectedEtDate!.month = etNow.month;
      _selectedEtDate!.day = etNow.day;
      _selectedEtDate!.weekDay = gcDate.weekday;
    }

    selectedEtTime = LocalTime.hourMinute12();
    selectedGcTime = LocalTime.hourMinute12();
    selectedGcTime24 = LocalTime.hourMinute24();

    DateTime gcNowTime = DateTime.now();
    selectedGcTime24!.hour = gcNowTime.hour;
    selectedGcTime24!.minute = gcNowTime.minute;

    selectedGcTime =
        LocalTime.hourMinute12(gcNowTime.hour, gcNowTime.minute, gcNowTime.hour < 12 ? TimePeriod.AM : TimePeriod.PM);

    ///Initialize default category selection [Normal Category]
    selectedEventTag = EventTagOption.regular.index;

    ///Initialize default category selection [Normal Category]
    selectedRepeatOption = NotificationRepeatOption.noRecurrence.index;

    ///Initialize default category selection [Normal Category]
    selectedNotificationSchedule = NotificationScheduleOption.onTime.index;

    _selectedDurationMinutes = 60;

    debugPrint("------ ET Selected ${_selectedEtDate!.year} -${_selectedEtDate!.month} -${_selectedEtDate!.day}");
    debugPrint("------ GC Selected ${selectedGcDate!.year} -${selectedGcDate!.month} -${selectedGcDate!.day}");
  }

  _getEtSelectedDateString() {
    if (_selectedEtDate == null) return null;
    return "${MonthGlobals.etMonthsLong[_selectedEtDate!.month! - 1]} ${isGeezNumbers ? GeezNumbers.geezNumbers[_selectedEtDate!.day! - 1] : _selectedEtDate!.day} , ${isGeezNumbers ? GeezNumbers.geezYears[_selectedEtDate!.year! - 1900] : _selectedEtDate!.year} ";
  }

  _getGcSelectedDateString() {
    if (selectedGcDate == null) return null;
    return "${MonthGlobals.gcMonthsLong[selectedGcDate!.month! - 1]} ${selectedGcDate!.day} , ${selectedGcDate!.year} ";
  }

  _getEtSelectedTimeString() {
    String result = "--:--Error";
    if (selectedEtTime!.hour == null) {
      result = MonthGlobals.getCurrentTimeEt(DateTime.now());
    } else {
      String hour = isGeezNumbers
          ? GeezNumbers.geezNumbers[selectedEtTime!.hour! - 1]
          : selectedEtTime!.hour! < 9
              ? "0${selectedEtTime!.hour}"
              : "${selectedEtTime!.hour}";

      ///Zero does not exist for geez and following is statement should support that to prevent exception
      String minute = isGeezNumbers
          ? selectedEtTime!.minute! != 0
              ? GeezNumbers.geezNumbers[selectedEtTime!.minute! - 1]
              : "00"
          : selectedEtTime!.minute! > 9
              ? "${selectedEtTime!.minute}"
              : "0${selectedEtTime!.minute}";
      result = "$hour : $minute : ${MonthGlobals.timePeriodEt[selectedEtTime!.period!.index]}";
    }
    return result;
  }

  _getGcSelectedTimeString() {
    String result = "--:--Error";
    if (selectedGcTime!.hour == null) {
      result = MonthGlobals.getCurrentTimeEt(DateTime.now());
    } else {
      selectedGcTime!.hour = selectedGcTime!.hour! > 12 ? selectedGcTime!.hour! - 12 : selectedGcTime!.hour;
      String hour = selectedGcTime!.hour! < 9 ? "0${selectedGcTime!.hour}" : "${selectedGcTime!.hour}";
      String minute = selectedGcTime!.minute! > 9 ? "${selectedGcTime!.minute}" : "0${selectedGcTime!.minute}";
      result = "$hour : $minute : ${MonthGlobals.timePeriodGc[selectedGcTime!.period!.index]}";
    }
    return result;
  }

  // ── Day view helpers ──────────────────────────────────────────────────────

  Future<void> _loadDayViewEvents(DateTime date) async {
    if (!mounted) return;
    setState(() => _dayViewLoading = true);
    final primary = Theme.of(context).primaryColor;
    final pending = await _notificationsPlugin.pendingNotificationRequests();
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

    if (mounted) {
      setState(() {
        _dayViewEvents = dayEvents;
        _dayViewLoading = false;
      });
      _scrollDayViewToCurrentTime();
    }
  }

  ScrollController _getScrollController(int page) =>
      _pageScrollControllers.putIfAbsent(page, () => ScrollController());

  void _scrollDayViewToCurrentTime() {
    final now = DateTime.now();
    final isToday = _dayViewDate.year == now.year &&
        _dayViewDate.month == now.month &&
        _dayViewDate.day == now.day;
    final page = _dayPageController.hasClients
        ? (_dayPageController.page?.round() ?? _kDayViewInitialPage)
        : _kDayViewInitialPage;
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

  void _onTimelineTimeLongPressed(DateTime time) {
    final hour24 = time.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final period = hour24 >= 12 ? TimePeriod.PM : TimePeriod.AM;
    int etHour;
    if (hour24 < 7) {
      etHour = hour24 + 6;
    } else if (hour24 < 19) {
      etHour = hour24 - 6;
    } else {
      etHour = hour24 - 18;
    }
    setState(() {
      selectedGcDate = LocalDate.detailed(time.year, time.month, time.day, time.weekday);
      _selectedEtDate = MonthModel.toEc(year: time.year, month: time.month, day: time.day);
      selectedGcTime = LocalTime.hourMinute12(hour12, time.minute, period);
      selectedGcTime24 = LocalTime.hourMinute24(hour: hour24, minute: time.minute);
      selectedEtTime = LocalTime.hourMinute12(etHour, time.minute, period);
      _showDayView = false;
    });
  }

  void _onDayViewEventLongPressed(DayEvent event) {
    if (event.payload == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserEventPage(eventToEdit: event.payload),
      ),
    ).then((_) => _loadDayViewEvents(_dayViewDate));
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _tabSwitcher(Color primaryColor, Color cardBg) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: cardBg.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  _tabPill(
                    label: l10n.formTab,
                    active: !_showDayView,
                    primaryColor: primaryColor,
                    onTap: () => setState(() => _showDayView = false),
                  ),
                  _tabPill(
                    label: l10n.dayViewTab,
                    active: _showDayView,
                    primaryColor: primaryColor,
                    onTap: () {
                      final gcDate = selectedGcDate;
                      final date = gcDate != null && gcDate.year != null
                          ? DateTime(gcDate.year!, gcDate.month!, gcDate.day!)
                          : DateTime.now();
                      final targetPage = _kDayViewInitialPage +
                          date.difference(_dayPageBaseDate).inDays;
                      setState(() {
                        _showDayView = true;
                        _dayViewDate = date;
                      });
                      if (_dayPageController.hasClients) {
                        _dayPageController.jumpToPage(targetPage);
                      }
                      _loadDayViewEvents(date);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _selectedDateBadge(primaryColor),
        ],
      ),
    );
  }

  Widget _selectedDateBadge(Color primaryColor) {
    String gcLine = '--';
    String etLine = '';

    final gcDate = selectedGcDate;
    if (gcDate?.month != null && gcDate?.day != null) {
      gcLine = '${MonthGlobals.gcMonthsShort[(gcDate!.month! - 1).clamp(0, 11)]} ${gcDate.day}';
    }

    if (_selectedEtDate?.month != null && _selectedEtDate?.day != null) {
      final monthName = MonthGlobals.etMonthsLong[(_selectedEtDate!.month! - 1).clamp(0, 12)] ?? '';
      final dayNum = isGeezNumbers
          ? GeezNumbers.geezNumbers[(_selectedEtDate!.day! - 1).clamp(0, 29)]
          : '${_selectedEtDate!.day}';
      etLine = '$monthName $dayNum';
    }

    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 64, maxWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              gcLine,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryColor),
            ),
          ),
          if (etLine.isNotEmpty)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                etLine,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withValues(alpha: 0.65),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabPill({
    required String label,
    required bool active,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : primaryColor.withOpacity(0.55),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildDayViewContent() {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          DayNavHeader(
            date: _dayViewDate,
            onDateChanged: (date) {
              final page = _kDayViewInitialPage +
                  date.difference(_dayPageBaseDate).inDays;
              _dayPageController.animateToPage(
                page,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Divider(height: 1, thickness: 0.5, color: theme.colorScheme.secondary),
          AllDayStrip(events: _dayViewEvents),
          Expanded(
            child: PageView.builder(
              controller: _dayPageController,
              onPageChanged: _onDayPageChanged,
              itemBuilder: (context, page) {
                final date = _dayPageBaseDate.add(
                    Duration(days: page - _kDayViewInitialPage));
                final isCurrentDay = date.year == _dayViewDate.year &&
                    date.month == _dayViewDate.month &&
                    date.day == _dayViewDate.day;
                if (isCurrentDay && _dayViewLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: theme.primaryColor, strokeWidth: 2),
                  );
                }
                return DayTimeline(
                  date: date,
                  events: isCurrentDay ? _dayViewEvents : const [],
                  scrollController: _getScrollController(page),
                  onTimeLongPressed:
                      isCurrentDay ? _onTimelineTimeLongPressed : null,
                  onEventLongPressed: _onDayViewEventLongPressed,
                  bottomPadding: bottomPadding + 24,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onDayPageChanged(int page) {
    final newDate = _dayPageBaseDate.add(Duration(days: page - _kDayViewInitialPage));
    final etDate = MonthModel.toEc(year: newDate.year, month: newDate.month, day: newDate.day);
    setState(() {
      _dayViewDate = newDate;
      selectedGcDate = LocalDate.detailed(newDate.year, newDate.month, newDate.day, newDate.weekday);
      if (etDate != null) {
        _selectedEtDate = LocalDate.detailed(etDate.year!, etDate.month!, etDate.day!, newDate.weekday);
      }
    });
    _loadDayViewEvents(newDate);
  }

  _dateTimePickerRow() {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;

    final textStyleMain = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.bodyLarge?.color,
    );
    final textStyleSub = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
    );

    return Row(
      children: [
        // Date Picker Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              showDialog(
                context: context,
                builder: (_) => DatePickerDialogLocal(
                  callback: getSelectedDateCallBack,
                  selectedEtDate: _selectedEtDate,
                  selectedGcDate: selectedGcDate,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.date,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getEtSelectedDateString() ?? MonthGlobals.getCurrentDateEt(),
                            style: textStyleMain,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getGcSelectedDateString() ?? MonthGlobals.getCurrentDateGc(),
                            style: textStyleSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Time Picker Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              showDialog(
                context: context,
                builder: (_) => TimePickerDialogLocal(
                  timeSetterCallback: getSelectedTimeCallBack,
                  initialGcTime: selectedGcTime,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.time,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getEtSelectedTimeString(),
                            style: textStyleMain,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getGcSelectedTimeString(),
                            style: textStyleSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _eventImportancePicker() {
    final theme = Theme.of(context);
    final selectedColor = Globals.categoryColorList[selectedEventTag!];
    final cardBg = theme.cardColor;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (_) => EventCategoryPicker(
            selectedOption: selectedEventTag,
            callback: getSelectedCategoryCallBack,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selectedColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.label_important_rounded,
                size: 16,
                color: selectedColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.importanceTag.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Globals.categoryList[selectedEventTag!],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _repeatNotificationPicker() {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (_) => NotificationRepeatPicker(
            selectedOption: selectedRepeatOption,
            callback: getSelectedRecurrenceCallBack,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.repeat_rounded,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.repeatNotification.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Globals.notificationRepeatOptionList[selectedRepeatOption!],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _notificationSchedulePicker() {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (_) => NotificationSchedulePicker(
            selectedOption: selectedNotificationSchedule,
            callback: getSelectedNotificationScheduleCallBack,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.scheduleNotification.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Globals.notificationScheduleOptionList[selectedNotificationSchedule!],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isEntryValid(DateTime gcSelectedDateTime) {
    String? message;
    bool isValidEntry = true;

    debugPrint("------ Title Controller Value: ${_titleTextController.value}");

    ///Prevent from scheduling passed date
    if (gcSelectedDateTime.isBefore(DateTime.now())) {
      message = AppLocalizations.of(context)!.pleaseSelectFutureDateOnly;
      isValidEntry = false;
    }
    if (_titleTextController.text.isEmpty) {
      message = AppLocalizations.of(context)!.eventTitleIsRequired;
      isValidEntry = false;
    }
    if (!isValidEntry) {
      Globals.showSnack(
        context: context,
        type: SnackMessageType.warning,
        message: message,
      );
    }

    return isValidEntry;
  }

  _saveEvent() async {
    List<int> minutesList = [0, 5, 10, 15, 30];

    debugPrint("------ SelectedNotificationScheduleMin: ${minutesList[selectedNotificationSchedule!]}");
    DateTime scheduleDate = DateTime(selectedGcDate!.year!, selectedGcDate!.month!, selectedGcDate!.day!,
        selectedGcTime24!.hour!, selectedGcTime24!.minute!);

    DateTime validationDate = DateTime(selectedGcDate!.year!, selectedGcDate!.month!, selectedGcDate!.day!,
            selectedGcTime24!.hour!, selectedGcTime24!.minute!)
        .subtract(Duration(minutes: minutesList[selectedNotificationSchedule!]));

    ///Validate entry and exit operation if entry is invalidated
    if (!_isEntryValid(validationDate)) return;

    if (widget.eventToEdit != null) {
      int oldNotificationId = widget.eventToEdit!.id!;
      int oldNotificationEarlyAlertId = oldNotificationId + 1;
      await NotificationService().cancelNotification(oldNotificationId);
      await NotificationService().cancelNotification(oldNotificationEarlyAlertId);
    }

    bool alertOnly = false;

    for (int i = 0; i < 2; i++) {
      ///Get unique next sequence of event Id
      int? id = Globals.getNextEventNumber();

      if (i == 0) {
        alertOnly = false;
      } else {
        if (minutesList[selectedNotificationSchedule!] > 0) {
          alertOnly = true;
          selectedGcTime24!.hour = validationDate.hour;
          selectedGcTime24!.minute = validationDate.minute;
        } else {
          break;
        }

        ///To differentiate between same message by jumping one offset (helps to cancel alerts only)
        Globals.getNextEventNumber();
      }

      NotificationPayload payload = _getNotificationPayload(
          id: id, gcSelectedDateTime: alertOnly ? validationDate : scheduleDate, alertOnly: alertOnly);
      String stringJsonPayload = jsonEncode(payload);

      switch (payload.repeatOption) {
        case NotificationRepeatOption.noRecurrence:
          {
            ///TODO: These notifications automatically deleted after they are triggered, so preserve using local json
            ///Notification source is null to indicate it belongs to user and not from company or user interest/topic
            await NotificationService().zonedScheduleNotification(
                id: id!,
                title: eventTitle,
                body: eventNote,
                date: alertOnly ? validationDate : scheduleDate,
                payload: stringJsonPayload,
                notificationSource: null);

            ///Update holiday view on home page month view
            if (widget.fetchLatestEventsCallback != null) widget.fetchLatestEventsCallback!();
          }
          break;
        case NotificationRepeatOption.daily:
          {
            debugPrint('------ Setting Daily Notification... ');

            ///Notification source is null to indicate it belongs to user and not from company or user interest/topic
            await NotificationService().scheduleDailyNotification(
                id: id!,
                time: selectedGcTime24!,
                title: eventTitle,
                body: eventNote,
                payload: stringJsonPayload,
                notificationSource: null);
            if (widget.fetchLatestEventsCallback != null) widget.fetchLatestEventsCallback!();
            debugPrint('------ Daily Notification is Set');
          }
          break;
        case NotificationRepeatOption.weekly:
          {
            ///Notification source is null to indicate it belongs to user and not from company or user interest/topic
            await NotificationService().scheduleWeeklyNotification(
                id: id!,
                title: eventTitle,
                body: eventNote,
                date: alertOnly ? validationDate : scheduleDate,
                time: selectedGcTime24!,
                payload: stringJsonPayload,
                notificationSource: null);
            if (widget.fetchLatestEventsCallback != null) widget.fetchLatestEventsCallback!();
          }
          break;

        default:
          return;
      }
    }
    if (widget.eventToEdit != null) {
      Globals.showSaveResultMessage(
          context: context,
          type: SnackMessageType.success,
          message: "",
          gcDate: selectedGcDate!,
          gcTime: selectedGcTime24!,
          etDate: _selectedEtDate);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        Globals.showSaveResultMessage(
            context: context,
            type: SnackMessageType.success,
            message: "",
            gcDate: selectedGcDate!,
            gcTime: selectedGcTime24!,
            etDate: _selectedEtDate);
        _resetEntry(keepDate: true);
      });
    }
  }

  getSelectedDurationCallBack(int minutes) {
    setState(() => _selectedDurationMinutes = minutes);
  }

  String _durationLabel(int minutes) {
    switch (minutes) {
      case 15: return '15 min';
      case 30: return '30 min';
      case 60: return '1 hr';
      case 120: return '2 hr';
      case 180: return '3 hr';
      default: return '$minutes min';
    }
  }

  Widget _durationPicker() {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (_) => DurationPicker(
            selectedOption: _selectedDurationMinutes,
            callback: getSelectedDurationCallBack,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timelapse_rounded, size: 16, color: primaryColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.duration.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _durationLabel(_selectedDurationMinutes),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  NotificationPayload _getNotificationPayload({int? id, required DateTime gcSelectedDateTime, bool alertOnly = false}) {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime now = DateTime.now();

    ///Construct the payload that would attach to local notification scheduler
    NotificationPayload payload = NotificationPayload(
        id: id,
        title: eventTitle,
        body: eventNote,
        createdDateTime: now,
        scheduledDateTime: gcSelectedDateTime,
        eventTagOption: EventTagOption.values[selectedEventTag!],
        scheduleOption: NotificationScheduleOption.values[selectedNotificationSchedule!],
        repeatOption: NotificationRepeatOption.values[selectedRepeatOption!],
        gD: gcSelectedDateTime.day,
        gM: gcSelectedDateTime.month,
        gY: gcSelectedDateTime.year,
        eD: _selectedEtDate!.day,
        eM: _selectedEtDate!.month,
        eY: _selectedEtDate!.year,
        weekday: gcSelectedDateTime.weekday,
        contentSource: ContentSource.UserTask,
        topic: "personal",
        age: 3,
        visible: alertOnly ? 'false' : 'true',
        durationMinutes: _selectedDurationMinutes);
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;

    MediaQueryData queryData = MediaQuery.of(context);
    const double tabSwitcherHeight = 48.0;
    double availableHeight =
        queryData.size.height - AppBar().preferredSize.height - queryData.padding.top - tabSwitcherHeight;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.eventToEdit != null
            ? AppLocalizations.of(context)!.editEventOrTask
            : AppLocalizations.of(context)!.addNewEventOrTask),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _tabSwitcher(primaryColor, cardBg),
          Expanded(
            child: _showDayView
                ? _buildDayViewContent()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (widget.eventToEdit != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.withValues(alpha: 0.15),
                                        Colors.orange.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          color: Colors.orange,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "${AppLocalizations.of(context)!.editEventOrTask}: ${widget.eventToEdit!.title}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.orange,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              // Title text input
                              TextField(
                                controller: _titleTextController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.titleRequired,
                                  prefixIcon: Icon(Icons.title_rounded, color: primaryColor.withOpacity(0.7)),
                                  suffixIcon: IconButton(
                                    onPressed: () => _titleTextController.clear(),
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                  ),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withOpacity(0.04) : primaryColor.withOpacity(0.04),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: primaryColor.withOpacity(0.12), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onChanged: (value) => eventTitle = value,
                              ),
                              const SizedBox(height: 12),
                              // Note text input
                              TextField(
                                controller: _bodyTextController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.note,
                                  prefixIcon: Icon(Icons.notes_rounded, color: primaryColor.withOpacity(0.7)),
                                  suffixIcon: IconButton(
                                    onPressed: () => _bodyTextController.clear(),
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                  ),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withOpacity(0.04) : primaryColor.withOpacity(0.04),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: primaryColor.withOpacity(0.12), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onChanged: (value) => eventNote = value,
                              ),
                              const SizedBox(height: 16),

                              // Row 1: Date & Time Pickers
                              _dateTimePickerRow(),
                              const SizedBox(height: 12),

                              // Row 2: Duration (left) & Importance Tag (right)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _durationPicker()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _eventImportancePicker()),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Row 3: Schedule Notification & Repeat Notification
                              Row(
                                children: [
                                  Expanded(child: _notificationSchedulePicker()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _repeatNotificationPicker()),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Row 4 Header: Plan List for the Day
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.planListForTheDay.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Divider(
                                      color: primaryColor.withOpacity(0.15),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Row 4: Daily events list
                              if (widget.eventToEdit == null) ...[
                                SizedBox(
                                  height: availableHeight / 1.9,
                                  child: DailyUserEventList(
                                    selectedEtDate: _selectedEtDate,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _showDayView
          ? null
          : GestureDetector(
              onLongPress: () => NotificationService().cancelAllNotifications(),
              child: FloatingActionButton(
                onPressed: () => _saveEvent(),
                backgroundColor: primaryColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.eventToEdit != null ? Icons.check_rounded : Icons.save_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
      floatingActionButtonLocation: const _CustomFABLocation(),
    );
  }

  isAndroidGranted() async {
    bool isNotificationEnabled = await NotificationService().isAndroidPermissionGranted();
    if (!isNotificationEnabled) {
      setState(
        () {
          //Not implemented
        },
      );
    }
  }

  _initEditMode() {
    final payload = widget.eventToEdit!;
    eventTitle = payload.title;
    _titleTextController.text = eventTitle ?? "";
    eventNote = payload.body;
    _bodyTextController.text = eventNote ?? "";

    _selectedEtDate = LocalDate.detailed(payload.eY, payload.eM, payload.eD, payload.weekday);
    selectedGcDate = LocalDate.detailed(payload.gY, payload.gM, payload.gD, payload.weekday);

    final schedDateTime = payload.scheduledDateTime ?? DateTime.now();

    selectedGcTime24 = LocalTime.hourMinute24(hour: schedDateTime.hour, minute: schedDateTime.minute);

    int gcHour12 = schedDateTime.hour > 12
        ? schedDateTime.hour - 12
        : (schedDateTime.hour == 0 ? 12 : schedDateTime.hour);
    TimePeriod gcPeriod = schedDateTime.hour < 12 ? TimePeriod.AM : TimePeriod.PM;
    selectedGcTime = LocalTime.hourMinute12(gcHour12, schedDateTime.minute, gcPeriod);

    int etHour = 0;
    if (schedDateTime.hour < 7) {
      etHour = schedDateTime.hour + 6;
    } else if (schedDateTime.hour < 19) {
      etHour = schedDateTime.hour - 6;
    } else {
      etHour = schedDateTime.hour - 18;
    }
    selectedEtTime = LocalTime.hourMinute12(etHour, schedDateTime.minute, gcPeriod);

    selectedEventTag = payload.eventTagOption?.index ?? EventTagOption.regular.index;
    selectedRepeatOption = payload.repeatOption?.index ?? NotificationRepeatOption.noRecurrence.index;
    selectedNotificationSchedule = payload.scheduleOption?.index ?? NotificationScheduleOption.onTime.index;
    _selectedDurationMinutes = payload.durationMinutes ?? 60;
  }

  @override
  void initState() {
    super.initState();
    NotificationService().requestPermissions();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    if (widget.eventToEdit != null) {
      _initEditMode();
    } else {
      _resetEntry(keepDate: false);
    }
    // Sync day view date to whatever date the form initialized with
    final gc = selectedGcDate;
    _dayViewDate = (gc != null && gc.year != null && gc.month != null && gc.day != null)
        ? DateTime(gc.year!, gc.month!, gc.day!)
        : DateTime.now();
    _dayPageBaseDate = _dayViewDate;
    _dayPageController = PageController(initialPage: _kDayViewInitialPage);
  }

  @override
  void dispose() {
    _dayPageController.dispose();
    for (final sc in _pageScrollControllers.values) {
      sc.dispose();
    }
    super.dispose();
  }
}

class _CustomFABLocation extends FloatingActionButtonLocation {
  const _CustomFABLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset standardOffset = FloatingActionButtonLocation.endFloat.getOffset(scaffoldGeometry);
    // Shift it down by 14 pixels to place it right at the top of the bottom menu with little space
    return Offset(standardOffset.dx, standardOffset.dy + 14);
  }
}
