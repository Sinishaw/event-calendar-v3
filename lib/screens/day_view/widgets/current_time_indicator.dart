import 'dart:async';
import 'package:event_calendar_v2/screens/day_view/utils/timeline_utils.dart';
import 'package:flutter/material.dart';

/// Animated red line indicating the current time on the timeline.
/// Auto-repositions every minute.
class CurrentTimeIndicator extends StatefulWidget {
  final bool isToday;

  const CurrentTimeIndicator({super.key, required this.isToday});

  @override
  State<CurrentTimeIndicator> createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<CurrentTimeIndicator> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isToday) return const SizedBox.shrink();

    final y = TimelineUtils.currentTimeY();
    const dotSize = 10.0;

    return Positioned(
      top: y - dotSize / 2,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
