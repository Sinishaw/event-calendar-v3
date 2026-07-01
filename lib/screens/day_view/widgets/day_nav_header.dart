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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          GestureDetector(
            onTap: () => onDateChanged(DateTime.now()),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE').format(date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _isToday
                        ? primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM d, y').format(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _isToday
                            ? primary
                            : theme.colorScheme.onSurface,
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
