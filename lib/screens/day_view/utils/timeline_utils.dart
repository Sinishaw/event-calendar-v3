/// Coordinate and time math for the day timeline.
/// All pixel calculations flow through here so changing hourHeight
/// automatically propagates everywhere.
class TimelineUtils {
  TimelineUtils._();

  static const double hourHeight = 64.0;
  static const double minuteHeight = hourHeight / 60.0;
  static const int startHour = 0;
  static const int endHour = 24;
  static const double totalHeight = (endHour - startHour) * hourHeight;

  /// Converts a DateTime to a Y offset in the timeline.
  static double timeToY(DateTime time) {
    final minutes = (time.hour - startHour) * 60 + time.minute;
    return minutes * minuteHeight;
  }

  /// Converts a Y offset to a DateTime on [date], rounded to [snapMinutes].
  static DateTime yToTime(double y, DateTime date, {int snapMinutes = 15}) {
    final rawMinutes = (y / minuteHeight).round();
    final snapped = (rawMinutes / snapMinutes).round() * snapMinutes;
    final totalMinutes = snapped.clamp(0, (endHour - startHour) * 60 - snapMinutes);
    final hour = startHour + totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Formats a DateTime as "HH:MM" (24-hour).
  static String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Formats a DateTime as "h:MM AM/PM".
  static String formatTime12(DateTime dt) {
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Y offset for the current time within today.
  static double currentTimeY() => timeToY(DateTime.now());

  /// Scroll offset to center the current hour on screen, given viewport height.
  static double scrollOffsetForCurrentTime(double viewportHeight) {
    final y = currentTimeY();
    return (y - viewportHeight / 2).clamp(0.0, totalHeight);
  }
}
