import 'package:event_calendar_v2/screens/day_view/models/day_event.dart';
import 'package:event_calendar_v2/screens/day_view/utils/day_layout_engine.dart';
import 'package:event_calendar_v2/screens/day_view/utils/timeline_utils.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/current_time_indicator.dart';
import 'package:event_calendar_v2/screens/day_view/widgets/day_event_block.dart';
import 'package:flutter/material.dart';

class DayTimeline extends StatefulWidget {
  final DateTime date;
  final List<DayEvent> events;
  final ValueChanged<DateTime>? onTimeLongPressed;
  final ScrollController? scrollController;
  final double bottomPadding;

  const DayTimeline({
    super.key,
    required this.date,
    required this.events,
    this.onTimeLongPressed,
    this.scrollController,
    this.bottomPadding = 24.0,
  });

  @override
  State<DayTimeline> createState() => _DayTimelineState();
}

class _DayTimelineState extends State<DayTimeline> {
  static const double _labelWidth = 52.0;
  static const double _gutter = 8.0;

  bool get _isToday {
    final now = DateTime.now();
    return widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;
  }

  void _handleLongPress(double localY) {
    if (widget.onTimeLongPressed == null) return;
    final scrollOffset = widget.scrollController?.offset ?? 0.0;
    final y = localY + scrollOffset;
    final time = TimelineUtils.yToTime(y, widget.date);
    widget.onTimeLongPressed!(time);
  }

  @override
  Widget build(BuildContext context) {
    final layouts = DayLayoutEngine.compute(widget.events);

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: SizedBox(
        height: TimelineUtils.totalHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed-width hour labels
            SizedBox(
              width: _labelWidth,
              height: TimelineUtils.totalHeight,
              child: _HourLabels(),
            ),
            // Timeline: LayoutBuilder gives the real available width
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPressStart: (d) => _handleLongPress(d.localPosition.dy),
                    child: SizedBox(
                      width: width,
                      height: TimelineUtils.totalHeight,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // Grid lines
                          CustomPaint(
                            size: Size(width, TimelineUtils.totalHeight),
                            painter: _GridPainter(context: context),
                          ),
                          // Event blocks
                          ...layouts.map((layout) {
                            final colWidth = width / layout.totalColumns;
                            final blockWidth = (colWidth - 2).clamp(8.0, width);
                            // Ensure max >= min: top may be near totalHeight
                            final maxH = (TimelineUtils.totalHeight - layout.top).clamp(1.0, TimelineUtils.totalHeight);
                            final blockH = layout.height.clamp(1.0, maxH);
                            return Positioned(
                              top: layout.top,
                              left: layout.columnIndex * colWidth,
                              width: blockWidth,
                              height: blockH,
                              child: DayEventBlock(
                                event: layout.event,
                                width: blockWidth,
                                height: blockH,
                              ),
                            );
                          }),
                          // Current time indicator
                          CurrentTimeIndicator(isToday: _isToday),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: _gutter),
          ],
        ),
      ),
    );
  }
}

class _HourLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
    return SizedBox(
      height: TimelineUtils.totalHeight,
      child: Stack(
        children: List.generate(
          TimelineUtils.endHour - TimelineUtils.startHour,
          (i) {
            final hour = TimelineUtils.startHour + i;
            if (hour == 0) return const SizedBox.shrink();
            final y = i * TimelineUtils.hourHeight;
            return Positioned(
              top: y - 8,
              right: 6,
              child: Text(
                hour < 10 ? '0$hour:00' : '$hour:00',
                style: TextStyle(fontSize: 10, color: color),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final BuildContext context;

  _GridPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final hourPaint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    final halfPaint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= TimelineUtils.endHour - TimelineUtils.startHour; i++) {
      final y = i * TimelineUtils.hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hourPaint);
      if (i < TimelineUtils.endHour - TimelineUtils.startHour) {
        final halfY = y + TimelineUtils.hourHeight / 2;
        canvas.drawLine(
            Offset(0, halfY), Offset(size.width, halfY), halfPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
