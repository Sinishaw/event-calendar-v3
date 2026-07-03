import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Navigation header showing the current day with prev/next controls.
/// Emits a new date via [onDateChanged] — works for day view today,
/// can drive a week view header in the future with the same widget.
class DayNavHeader extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const DayNavHeader({
    super.key,
    required this.date,
    required this.onDateChanged,
  });

  String _etDayName(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case DateTime.monday: return l10n.monday;
      case DateTime.tuesday: return l10n.tuesday;
      case DateTime.wednesday: return l10n.wednesday;
      case DateTime.thursday: return l10n.thursday;
      case DateTime.friday: return l10n.friday;
      case DateTime.saturday: return l10n.saturday;
      case DateTime.sunday: return l10n.sunday;
      default: return '';
    }
  }

  String _etDateString(DateTime gcDate, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayName = _etDayName(gcDate.weekday, l10n);
    final et = MonthModel.toEc(year: gcDate.year, month: gcDate.month, day: gcDate.day);
    if (et == null || et.month == null || et.day == null || et.year == null) {
      return '$dayName ${MonthGlobals.gcMonthsShort[(gcDate.month - 1).clamp(0, 11)]} ${gcDate.day}, ${gcDate.year}';
    }
    final monthName = MonthGlobals.etMonthsLong[(et.month! - 1).clamp(0, 12)] ?? '';
    return '$dayName $monthName ${et.day}, ${et.year}';
  }

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () =>
                onDateChanged(date.subtract(const Duration(days: 1))),
            color: theme.colorScheme.secondary,
          ),
          GestureDetector(
            onTap: () => onDateChanged(DateTime.now()),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, MMM d, y', 'en').format(date),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.65),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _etDateString(date, context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    if (_isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () =>
                onDateChanged(date.add(const Duration(days: 1))),
            color: theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
