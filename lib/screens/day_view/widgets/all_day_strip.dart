import 'package:event_calendar_v2/screens/day_view/models/day_event.dart';
import 'package:flutter/material.dart';

/// Horizontal strip for all-day events, shown above the timeline.
/// Currently renders a minimal placeholder; ready to display chips when
/// all-day events are introduced.
class AllDayStrip extends StatelessWidget {
  final List<DayEvent> events;

  const AllDayStrip({super.key, this.events = const []});

  @override
  Widget build(BuildContext context) {
    final allDay = events.where((e) => e.isAllDay).toList();
    if (allDay.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: allDay.map((e) => _chip(e, theme)).toList(),
      ),
    );
  }

  Widget _chip(DayEvent event, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: event.color.withValues(alpha: 0.4)),
      ),
      child: Text(
        event.title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: event.color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
