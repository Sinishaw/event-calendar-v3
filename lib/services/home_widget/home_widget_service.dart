import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/screens/events/models/fixed_national_events_detail.dart';
import 'package:event_calendar_v2/screens/events/models/holiday_and_national_events.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Central place for all home-screen widget logic (Android + iOS).
///
/// Today it drives the date widget (full Ethiopian date on top, full Gregorian
/// date below). A future event-list widget adds its own provider + methods here
/// without disturbing this one.
///
/// The same `date_et` / `date_gc` strings feed both platforms: on Android the
/// `DateWidgetProvider` RemoteViews renders them; on iOS the `DateWidget`
/// WidgetKit extension reads them (plus a precomputed [_keyDateWindow] so the
/// timeline can roll over at midnight without the app) from the shared App
/// Group `UserDefaults`.
///
/// Localized Ethiopian month/weekday names come from [MonthGlobals], which is
/// only populated while the app runs (it needs a BuildContext). So when the app
/// is in the foreground we snapshot those names + the number-format preference
/// into SharedPreferences ([cacheLocalizedNames]); the background midnight task
/// ([updateDateWidget]) then rebuilds the strings from that cache using only
/// isolate-safe pieces ([MonthModel.toEc], [GeezNumbers], static English lists).
class HomeWidgetService {
  HomeWidgetService._();

  /// Android provider classes (relative + fully-qualified forms for home_widget).
  static const String androidProvider = 'DateWidgetProvider';
  static const String qualifiedAndroidProvider =
      'com.example.event_calendar_v2.DateWidgetProvider';
  static const String androidCardProvider = 'DateCardWidgetProvider';
  static const String qualifiedAndroidCardProvider =
      'com.example.event_calendar_v2.DateCardWidgetProvider';

  /// iOS WidgetKit widget kind (matches `StaticConfiguration(kind:)` in Swift).
  static const String iosWidgetName = 'DateWidget';

  /// Keys read by `DateWidgetProvider.kt` (Android) and `DateWidget.swift` (iOS)
  /// via home_widget's shared store.
  static const String _keyDateEt = 'date_et';
  static const String _keyDateGc = 'date_gc';

  /// Flat ET components for today, read by `DateCardWidgetProvider.kt` (Android).
  static const String _keyEtDay = 'et_day';
  static const String _keyEtWeekday = 'et_weekday';
  static const String _keyEtMonthYear = 'et_month_year';

  /// iOS-only: a JSON array of {d, et, gc} for today..+[_windowDays] so the
  /// WidgetKit timeline can roll the date over at midnight without the app.
  static const String _keyDateWindow = 'date_window';
  static const int _windowDays = 14;

  /// Cache keys so the background isolate can rebuild strings without a context.
  static const String _prefEtMonths = 'hw_et_months';
  static const String _prefEtWeekdays = 'hw_et_weekdays';
  static const String _prefNumberFormat = 'hw_number_format';

  /// Workmanager one-off task that fires just after local midnight.
  static const String midnightTaskName = 'dateWidgetRefresh';
  static const String _midnightTaskUnique = 'date_widget_midnight_refresh';

  /// Convenience refresh for in-app changes (number format, language): snapshot
  /// the current localized names and rebuild the widget. On Android it also
  /// (re)schedules the midnight Workmanager task; on iOS the WidgetKit timeline
  /// handles midnight rollover via the precomputed window. No-op on other
  /// platforms and never throws.
  ///
  /// For a language change, call this from a post-frame callback so the new
  /// localized names in [MonthGlobals] are in place before they're cached.
  static Future<void> refreshNow() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await cacheLocalizedNames();
      await updateDateWidget();
      if (Platform.isAndroid) await scheduleMidnightRefresh();
    } catch (e) {
      debugPrint('------ Date widget refresh failed: $e');
    }
  }

  /// Snapshot the currently-localized ET names + number format into prefs.
  /// Call while the app is in the foreground (names are populated by then).
  static Future<void> cacheLocalizedNames() async {
    final prefs = await SharedPreferences.getInstance();
    final etMonths = MonthGlobals.etMonthsLong.map((e) => e ?? '').toList();
    final etWeekdays = MonthGlobals.etWeekNamesLong.map((e) => e ?? '').toList();
    await prefs.setString(_prefEtMonths, jsonEncode(etMonths));
    await prefs.setString(_prefEtWeekdays, jsonEncode(etWeekdays));
    await prefs.setString(_prefNumberFormat, Utility.getNumberFormat());
  }

  /// Build both date strings for today and push them to the widget.
  /// Isolate-safe: reads only SharedPreferences + static/pure utilities, so it
  /// runs identically from the foreground and from the background midnight task.
  static Future<void> updateDateWidget() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final etString = _buildEtDateString(now, prefs);
    final gcString = _buildGcDateString(now);

    await HomeWidget.saveWidgetData<String>(_keyDateEt, etString);
    await HomeWidget.saveWidgetData<String>(_keyDateGc, gcString);

    // Flat ET components for the Android "date card" widget.
    await _saveEtComponents(now, prefs);

    // iOS: precompute a rich rolling window so the WidgetKit timeline can flip
    // the date, month grid, holiday context and event count at each midnight
    // without the app running (Swift can't rebuild the localized data itself).
    if (Platform.isIOS) {
      await HomeWidget.saveWidgetData<String>(
          _keyDateWindow, await _buildRichWindowJson(now, prefs));
    }

    await HomeWidget.updateWidget(
      androidName: androidProvider,
      qualifiedAndroidName: qualifiedAndroidProvider,
      iOSName: iosWidgetName,
    );
    // Second Android provider (date card) — same shared data.
    await HomeWidget.updateWidget(
      androidName: androidCardProvider,
      qualifiedAndroidName: qualifiedAndroidCardProvider,
    );
  }

  /// Today's Ethiopian day / weekday / "month year" as flat strings, numerals
  /// per the Geez/English setting. Read by `DateCardWidgetProvider.kt`.
  static Future<void> _saveEtComponents(
      DateTime now, SharedPreferences prefs) async {
    final et = MonthModel.toEc(year: now.year, month: now.month, day: now.day);
    if (et == null || et.year == null || et.month == null || et.day == null) {
      return;
    }
    final isGeez = (prefs.getString(_prefNumberFormat) ?? 'ግዕዝ') != 'Eng';
    final etMonths = _decodeList(prefs.getString(_prefEtMonths));
    final etWeekdays = _decodeList(prefs.getString(_prefEtWeekdays));

    final weekday = (etWeekdays.length == 7 &&
            etWeekdays[now.weekday - 1].isNotEmpty)
        ? etWeekdays[now.weekday - 1]
        : MonthGlobals.gcWeekNamesLong[now.weekday - 1];
    final mIdx = (et.month! - 1).clamp(0, 12);
    final monthName = (etMonths.length > mIdx && etMonths[mIdx].isNotEmpty)
        ? etMonths[mIdx]
        : (MonthGlobals.etMonthsLong[mIdx] ?? '');

    await HomeWidget.saveWidgetData<String>(
        _keyEtDay, _num(et.day!, isGeez, isDay: true));
    await HomeWidget.saveWidgetData<String>(_keyEtWeekday, weekday);
    await HomeWidget.saveWidgetData<String>(
        _keyEtMonthYear, '$monthName ${_num(et.year!, isGeez, isDay: false)}');
  }

  /// JSON array (today..+[_windowDays]) where each entry carries everything the
  /// iOS widget families need: full ET/GC strings (Small), holiday context +
  /// event count (Medium), and a month grid (Large). Built in the foreground
  /// where localized names/holidays/events are available.
  static Future<String> _buildRichWindowJson(
      DateTime now, SharedPreferences prefs) async {
    final isGeez = (prefs.getString(_prefNumberFormat) ?? 'ግዕዝ') != 'Eng';
    final etMonths = _decodeList(prefs.getString(_prefEtMonths));
    final etWeekdaysLong = _decodeList(prefs.getString(_prefEtWeekdays));
    final etWeekdaysShort =
        MonthGlobals.etWeekNamesShort.map((e) => e ?? '').toList();

    // Localized labels for the widget (read via the global context; the window
    // is built in the foreground). English fallbacks keep it non-blank.
    String tomorrowLabel = 'Tomorrow';
    String daysLabel = 'days';
    String noEventsLabel = 'No events';
    final ctx = Globals.context;
    if (ctx != null) {
      try {
        final l10n = AppLocalizations.of(ctx)!;
        tomorrowLabel = l10n.tomorrow;
        daysLabel = l10n.days;
        noEventsLabel = l10n.noEventIsFound;
      } catch (_) {}
    }

    // Holidays across the ET years the window can touch (sorted by GC date).
    final etToday =
        MonthModel.toEc(year: now.year, month: now.month, day: now.day);
    final holidays = <FixedNationalEventsDetail>[];
    if (etToday?.year != null) {
      holidays.addAll(HolidayAndNationalEvents.getAllYearlyHolidays(etToday!.year!));
      holidays.addAll(HolidayAndNationalEvents.getAllYearlyHolidays(etToday.year! + 1));
      holidays.removeWhere((h) => h.gcDate == null);
      holidays.sort((a, b) => a.gcDate!.compareTo(b.gcDate!));
    }

    // Pending user events, fetched once.
    List<NotificationPayload> events = [];
    try {
      events = await NotificationService().getAllNotificationsList();
    } catch (_) {}

    final today = DateTime(now.year, now.month, now.day);
    final entries = <Map<String, dynamic>>[];
    for (int i = 0; i <= _windowDays; i++) {
      final day = today.add(Duration(days: i));
      final et = MonthModel.toEc(year: day.year, month: day.month, day: day.day);
      final ctx = _holidayContextForGc(day, holidays);

      String etDayStr = '', etMonthName = '', etYearStr = '', etWeekday = '';
      if (et?.year != null && et?.month != null && et?.day != null) {
        final mIdx = (et!.month! - 1).clamp(0, 12);
        etMonthName = (etMonths.length > mIdx && etMonths[mIdx].isNotEmpty)
            ? etMonths[mIdx]
            : (MonthGlobals.etMonthsLong[mIdx] ?? '');
        etDayStr = _num(et.day!, isGeez, isDay: true);
        etYearStr = _num(et.year!, isGeez, isDay: false);
        etWeekday = (etWeekdaysLong.length == 7 &&
                etWeekdaysLong[day.weekday - 1].isNotEmpty)
            ? etWeekdaysLong[day.weekday - 1]
            : MonthGlobals.gcWeekNamesLong[day.weekday - 1];
      }

      entries.add({
        'd': _fmtGc(day),
        'et': _buildEtDateString(day, prefs),
        'gc': _buildGcDateString(day),
        // ET date components (Large corner, day rendered bold in Swift).
        'etWeekday': etWeekday,
        'etMonthName': etMonthName,
        'etDay': etDayStr,
        'etYear': etYearStr,
        // GC date components (always English, like the rest of the app).
        'gcWeekday': MonthGlobals.gcWeekNamesLong[day.weekday - 1],
        'gcMonthName': MonthGlobals.gcMonthsLong[day.month - 1],
        'gcDay': '${day.day}',
        'gcYear': '${day.year}',
        // Medium context.
        'holidayToday': ctx['name'],
        'nextHolidayName': ctx['nextName'],
        'nextHolidayInDays': ctx['nextDays'],
        'eventCount': _countEventsForGc(events, day),
        'daysLabel': daysLabel,
        'noEventsLabel': noEventsLabel,
        // Large agenda: this day's events, else the next day(s) with events.
        'agenda': _agendaFrom(
            events, day, isGeez, etMonths, etWeekdaysShort, tomorrowLabel),
      });
    }
    return jsonEncode(entries);
  }

  /// Upcoming events starting at [fromDay]: today's events (no label), or if
  /// none, roll forward and label items "Tomorrow"/short date. Capped at 4.
  static List<Map<String, dynamic>> _agendaFrom(
      List<NotificationPayload> events,
      DateTime fromDay,
      bool isGeez,
      List<String> etMonths,
      List<String> etWeekdaysShort,
      String tomorrowLabel) {
    const maxItems = 4;
    final items = <Map<String, dynamic>>[];
    for (int delta = 0; delta <= _windowDays && items.length < maxItems; delta++) {
      final day = fromDay.add(Duration(days: delta));
      final dayEvents = _eventsForGcDay(events, day);
      if (dayEvents.isEmpty) continue;
      final label = delta == 0
          ? ''
          : (delta == 1
              ? tomorrowLabel
              : _shortEtLabel(day, isGeez, etMonths, etWeekdaysShort));
      for (final e in dayEvents) {
        if (items.length >= maxItems) break;
        items.add({
          'title': e.title ?? '',
          'detail': e.body ?? '',
          'colorHex': _colorHexForTag(e.eventTagOption),
          'dateLabel': label,
          'time': _clock(e.scheduledDateTime),
        });
      }
    }
    return items;
  }

  static String _shortEtLabel(DateTime day, bool isGeez, List<String> etMonths,
      List<String> etWeekdaysShort) {
    final wd = (etWeekdaysShort.length == 7 &&
            etWeekdaysShort[day.weekday - 1].isNotEmpty)
        ? etWeekdaysShort[day.weekday - 1]
        : MonthGlobals.gcWeekNamesShort[day.weekday - 1];
    final et = MonthModel.toEc(year: day.year, month: day.month, day: day.day);
    if (et?.month == null || et?.day == null) return wd;
    final mi = (et!.month! - 1).clamp(0, 12);
    final mn = (etMonths.length > mi && etMonths[mi].isNotEmpty)
        ? etMonths[mi]
        : (MonthGlobals.etMonthsLong[mi] ?? '');
    return '$wd, $mn ${_num(et.day!, isGeez, isDay: true)}';
  }

  static String _clock(DateTime? t) {
    if (t == null) return '';
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    int h12 = t.hour % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  /// 6-digit RGB hex for an event's category color (national → gray fallback).
  static String _colorHexForTag(EventTagOption? tag) {
    final list = Globals.categoryColorList;
    final idx = tag?.index ?? 0;
    final color = (idx >= 0 && idx < list.length) ? list[idx] : list.last;
    return (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  }

  static String _fmtGc(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Ethiopic numeral for a day (1-based) or year (offset from 1900), honoring
  /// the Geez/Arabic setting.
  static String _num(int value, bool isGeez, {required bool isDay}) {
    if (!isGeez) return '$value';
    if (isDay) {
      return (value >= 1 && value <= GeezNumbers.geezNumbers.length)
          ? GeezNumbers.geezNumbers[value - 1]
          : '$value';
    }
    final idx = value - 1900;
    return (idx >= 0 && idx < GeezNumbers.geezYears.length)
        ? GeezNumbers.geezYears[idx]
        : '$value';
  }

  /// Today's holiday name (if any) + the nearest upcoming holiday and its day
  /// delta, computed in Gregorian space (holidays carry a GC date).
  static Map<String, dynamic> _holidayContextForGc(
      DateTime day, List<FixedNationalEventsDetail> holidays) {
    final d0 = DateTime(day.year, day.month, day.day);
    String name = '', nextName = '';
    int nextDays = 0;
    for (final h in holidays) {
      final g = h.gcDate!;
      final gd = DateTime(g.year, g.month, g.day);
      if (gd == d0 && name.isEmpty) {
        name = h.name ?? '';
      }
      if (gd.isAfter(d0) && nextName.isEmpty) {
        nextName = h.name ?? '';
        nextDays = gd.difference(d0).inDays;
      }
    }
    return {'name': name, 'nextName': nextName, 'nextDays': nextDays};
  }

  /// A given GC day's user events (one-time on that date, plus daily and
  /// matching-weekday weekly recurrences that have started), sorted by time.
  static List<NotificationPayload> _eventsForGcDay(
      List<NotificationPayload> events, DateTime day) {
    final d0 = DateTime(day.year, day.month, day.day);
    final list = <NotificationPayload>[];
    for (final e in events) {
      if (e.visible == 'false') continue;
      final s = e.scheduledDateTime;
      bool match;
      switch (e.repeatOption) {
        case NotificationRepeatOption.daily:
          match = s != null && !d0.isBefore(DateTime(s.year, s.month, s.day));
          break;
        case NotificationRepeatOption.weekly:
          match = s != null &&
              s.weekday == day.weekday &&
              !d0.isBefore(DateTime(s.year, s.month, s.day));
          break;
        default:
          match = e.gY == day.year && e.gM == day.month && e.gD == day.day;
      }
      if (match) list.add(e);
    }
    list.sort((a, b) {
      final ta = a.scheduledDateTime, tb = b.scheduledDateTime;
      if (ta == null || tb == null) return 0;
      return (ta.hour * 60 + ta.minute).compareTo(tb.hour * 60 + tb.minute);
    });
    return list;
  }

  static int _countEventsForGc(List<NotificationPayload> events, DateTime day) =>
      _eventsForGcDay(events, day).length;

  /// Register a one-off task that fires ~1 min after the next local midnight,
  /// then reschedules itself. Workmanager respects Doze, so it will not wake a
  /// sleeping device — it runs once the device is next awake past midnight.
  static Future<void> scheduleMidnightRefresh() async {
    final now = DateTime.now();
    final nextMidnight =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final delay =
        nextMidnight.add(const Duration(minutes: 1)).difference(now);
    await Workmanager().registerOneOffTask(
      _midnightTaskUnique,
      midnightTaskName,
      initialDelay: delay.isNegative ? const Duration(minutes: 1) : delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  // ── String builders (isolate-safe) ─────────────────────────────────────────

  static String _buildEtDateString(DateTime now, SharedPreferences prefs) {
    final LocalDate? et =
        MonthModel.toEc(year: now.year, month: now.month, day: now.day);
    if (et == null || et.year == null || et.month == null || et.day == null) {
      // Never blank — fall back to the readable Gregorian string.
      return _buildGcDateString(now);
    }

    final etMonths = _decodeList(prefs.getString(_prefEtMonths));
    final etWeekdays = _decodeList(prefs.getString(_prefEtWeekdays));
    final isGeez = (prefs.getString(_prefNumberFormat) ?? 'ግዕዝ') != 'Eng';

    // Weekday: lists are 0=Mon..6=Sun; DateTime.weekday is 1=Mon..7=Sun.
    final weekdayName = (etWeekdays.length == 7 && etWeekdays[now.weekday - 1].isNotEmpty)
        ? etWeekdays[now.weekday - 1]
        : MonthGlobals.gcWeekNamesLong[now.weekday - 1];

    final monthIdx = (et.month! - 1).clamp(0, 12);
    final monthName = (etMonths.length > monthIdx && etMonths[monthIdx].isNotEmpty)
        ? etMonths[monthIdx]
        : (MonthGlobals.etMonthsLong[monthIdx] ?? '');

    final dayStr =
        (isGeez && et.day! >= 1 && et.day! <= GeezNumbers.geezNumbers.length)
            ? GeezNumbers.geezNumbers[et.day! - 1]
            : '${et.day}';
    final yearIdx = et.year! - 1900;
    final yearStr =
        (isGeez && yearIdx >= 0 && yearIdx < GeezNumbers.geezYears.length)
            ? GeezNumbers.geezYears[yearIdx]
            : '${et.year}';

    return '$weekdayName, $monthName $dayStr, $yearStr';
  }

  static String _buildGcDateString(DateTime now) {
    final weekday = MonthGlobals.gcWeekNamesLong[now.weekday - 1];
    final month = MonthGlobals.gcMonthsLong[now.month - 1];
    return '$weekday, $month ${now.day}, ${now.year}';
  }

  static List<String> _decodeList(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      return (jsonDecode(json) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }
}
