import 'package:event_calendar_v2/screens/day_view/models/day_event.dart';
import 'package:event_calendar_v2/screens/day_view/utils/timeline_utils.dart';
import 'package:flutter/material.dart';

/// A single event card rendered on the timeline.
/// Tap handler is a no-op for now; wire [onTap] to open event detail.
class DayEventBlock extends StatelessWidget {
  final DayEvent event;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DayEventBlock({
    super.key,
    required this.event,
    required this.width,
    required this.height,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = event.color;

    // Tiny block: just a colored bar, no text at all
    if (height < 14) {
      return GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.45 : 0.35),
            borderRadius: BorderRadius.circular(3),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
        ),
      );
    }

    // Use rendered height to decide layout density — not event duration,
    // which wraps past midnight and stays at 60 min for truncated blocks.
    final isShort = height < 36;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.28 : 0.18),
          borderRadius: BorderRadius.circular(6),
          border: Border(
            left: BorderSide(color: color, width: 3),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 6,
          vertical: isShort ? 2 : 4,
        ),
        child: isShort
            ? _shortContent(color)
            : _fullContent(color),
      ),
    );
  }

  Widget _shortContent(Color color) {
    return Text(
      event.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _fullContent(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${TimelineUtils.formatTime12(event.startTime)} – '
          '${TimelineUtils.formatTime12(event.endTime)}',
          style: TextStyle(
            fontSize: 10,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
