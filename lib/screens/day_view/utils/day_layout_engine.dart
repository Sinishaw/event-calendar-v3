import 'package:event_calendar_v2/screens/day_view/models/day_event.dart';
import 'package:event_calendar_v2/screens/day_view/utils/timeline_utils.dart';

/// Result of the layout engine for one event.
class DayEventLayout {
  final DayEvent event;
  final double top;
  final double height;
  final int columnIndex;
  final int totalColumns;

  const DayEventLayout({
    required this.event,
    required this.top,
    required this.height,
    required this.columnIndex,
    required this.totalColumns,
  });
}

/// Assigns column positions to overlapping events (Google Calendar style).
/// Extensible: swap the overlap strategy by replacing [compute].
class DayLayoutEngine {
  DayLayoutEngine._();

  static List<DayEventLayout> compute(List<DayEvent> events) {
    if (events.isEmpty) return [];

    final sorted = [...events]..sort((a, b) => a.startTime.compareTo(b.startTime));
    final results = <DayEventLayout>[];

    // Build overlap groups: events that share any time overlap form a group.
    final groups = <List<DayEvent>>[];
    for (final event in sorted) {
      bool placed = false;
      for (final group in groups) {
        if (group.any((e) => _overlaps(e, event))) {
          group.add(event);
          placed = true;
          break;
        }
      }
      if (!placed) groups.add([event]);
    }

    for (final group in groups) {
      // Assign each event to the first column where it doesn't overlap.
      final columns = <List<DayEvent>>[];
      for (final event in group) {
        bool placed = false;
        for (final col in columns) {
          if (!col.any((e) => _overlaps(e, event))) {
            col.add(event);
            placed = true;
            break;
          }
        }
        if (!placed) columns.add([event]);
      }

      final totalColumns = columns.length;
      for (int ci = 0; ci < columns.length; ci++) {
        for (final event in columns[ci]) {
          final top = TimelineUtils.timeToY(event.startTime);
          // timeToY uses hour+minute only; endTime past midnight wraps to a Y
          // near 0 which is less than top → treat as end-of-day instead.
          final rawBottom = TimelineUtils.timeToY(event.endTime);
          final bottom =
              rawBottom > top ? rawBottom.clamp(top, TimelineUtils.totalHeight) : TimelineUtils.totalHeight;
          final maxH = (TimelineUtils.totalHeight - top).clamp(1.0, TimelineUtils.totalHeight);
          final height = (bottom - top).clamp(TimelineUtils.minuteHeight * 15, maxH);
          results.add(DayEventLayout(
            event: event,
            top: top,
            height: height,
            columnIndex: ci,
            totalColumns: totalColumns,
          ));
        }
      }
    }

    return results;
  }

  static bool _overlaps(DayEvent a, DayEvent b) =>
      a.startTime.isBefore(b.endTime) && b.startTime.isBefore(a.endTime);
}
