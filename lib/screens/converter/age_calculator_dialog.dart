import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class AgeCalculatorDialog extends StatefulWidget {
  const AgeCalculatorDialog({
    super.key,
    this.etDate,
    this.gcDate,
    this.calendarType = CalendarType.Ethiopian,
  });
  final CalendarType? calendarType;
  final LocalDate? etDate, gcDate;
  @override
  State<AgeCalculatorDialog> createState() => _AgeCalculatorDialogState();
}

class _AgeCalculatorDialogState extends State<AgeCalculatorDialog> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  CalendarType? calendarType;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine);
    controller.addListener(() {});
    controller.forward();
    calendarType = widget.calendarType;
    debugPrint("Age Et... ${widget.etDate!.day}:${widget.etDate!.month}:${widget.etDate!.year}");
    debugPrint("Age Gc... ${widget.gcDate!.day}:${widget.gcDate!.month}:${widget.gcDate!.year}");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    double size = Globals.deviceWidth! * 0.55;

    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              /// Outer glow ring
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 3,
              ),
              /// Subtle inner shadow for depth
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.dialogBackgroundColor,
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Utility.showTimeDifference(
                context: context,
                gcDate: widget.gcDate!,
                etDate: widget.etDate!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
