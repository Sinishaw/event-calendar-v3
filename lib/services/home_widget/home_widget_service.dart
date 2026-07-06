import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Central place for all Android home-screen widget logic.
///
/// Today it drives the date widget (full Ethiopian date on top, full Gregorian
/// date below). A future event-list widget adds its own provider + methods here
/// without disturbing this one.
///
/// Localized Ethiopian month/weekday names come from [MonthGlobals], which is
/// only populated while the app runs (it needs a BuildContext). So when the app
/// is in the foreground we snapshot those names + the number-format preference
/// into SharedPreferences ([cacheLocalizedNames]); the background midnight task
/// ([updateDateWidget]) then rebuilds the strings from that cache using only
/// isolate-safe pieces ([MonthModel.toEc], [GeezNumbers], static English lists).
class HomeWidgetService {
  HomeWidgetService._();

  /// Android provider class (relative + fully-qualified forms for home_widget).
  static const String androidProvider = 'DateWidgetProvider';
  static const String qualifiedAndroidProvider =
      'com.example.event_calendar_v2.DateWidgetProvider';

  /// Keys read by `DateWidgetProvider.kt` via home_widget's SharedPreferences.
  static const String _keyDateEt = 'date_et';
  static const String _keyDateGc = 'date_gc';

  /// Cache keys so the background isolate can rebuild strings without a context.
  static const String _prefEtMonths = 'hw_et_months';
  static const String _prefEtWeekdays = 'hw_et_weekdays';
  static const String _prefNumberFormat = 'hw_number_format';

  /// Workmanager one-off task that fires just after local midnight.
  static const String midnightTaskName = 'dateWidgetRefresh';
  static const String _midnightTaskUnique = 'date_widget_midnight_refresh';

  /// Convenience refresh for in-app changes (number format, language): snapshot
  /// the current localized names, rebuild the widget, and (re)schedule midnight.
  /// Android-only; a no-op elsewhere and never throws.
  ///
  /// For a language change, call this from a post-frame callback so the new
  /// localized names in [MonthGlobals] are in place before they're cached.
  static Future<void> refreshNow() async {
    if (!Platform.isAndroid) return;
    try {
      await cacheLocalizedNames();
      await updateDateWidget();
      await scheduleMidnightRefresh();
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
    await HomeWidget.updateWidget(
      androidName: androidProvider,
      qualifiedAndroidName: qualifiedAndroidProvider,
    );
  }

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
