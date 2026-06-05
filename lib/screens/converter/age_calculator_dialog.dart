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
    double size = Globals.deviceWidth! * 0.55;
    return Center(
      child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
              height: size,
              width: size,
              decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size))),
              // width: Globals.deviceWidth/1.2,
              child: Padding(
                padding: const EdgeInsets.all(0.5),
                child: Container(
                    decoration: ShapeDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size))),
                    child:
                        Utility.showTimeDifference(context: context, gcDate: widget.gcDate!, etDate: widget.etDate!)),
              ))),
    );
  }
}
