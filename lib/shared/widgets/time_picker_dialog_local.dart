// ignore_for_file: avoid_unnecessary_containers

import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_time_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class TimePickerDialogLocal extends StatefulWidget {
  const TimePickerDialogLocal({super.key, required this.timeSetterCallback, this.initialGcTime});

  final LocalTime? initialGcTime;
  final Function timeSetterCallback;

  @override
  State<TimePickerDialogLocal> createState() => _TimePickerDialogLocalState();
}

class _TimePickerDialogLocalState extends State<TimePickerDialogLocal> with TickerProviderStateMixin {
  late LocalTime _selectedEtTime, _selectedGcTime, _selectedGcTime24;
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late double width, height;
  FixedExtentScrollController? _hourScrollController;
  FixedExtentScrollController? _minuteScrollController;
  FixedExtentScrollController? _periodScrollController;

  CalendarType? calendarType;

  int? hour, etHour, gcHour;

  final double _itemExtent = 38.0;
  final double _offAxisFraction = 0;
  final bool _useMagnifier = true;
  final double _magnification = 1.15;
  final double _diameterRatio = 2.0;
  final double _squeeze = 1.3;
  final double _perspective = 0.007;
  final double _overAndUnderCenterOpacity = 0.35;
  final TextStyle _textStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  ///All hours added one offset when user selected time, but if hour did not scroll during initialization
  ///user selection hour will be off by one. This flag will protect user from this special use case.
  bool isInitializeForceHourToScroll = false;

  _initHours() {
    hour = widget.initialGcTime!.hour;

    ///Init Et hour
    if (hour! < 7) {
      etHour = hour! + 6;
    } else if (hour! < 19) {
      etHour = hour! - 6;
    } else {
      etHour = hour! - 18;
    }

    ///Init Gc hour
    gcHour = hour! > 12 ? hour! - 12 : hour;

    ///Init objects to hold selected value while user scrolling
    _selectedEtTime = LocalTime.hourMinute12(etHour, widget.initialGcTime!.minute, widget.initialGcTime!.period);
    _selectedGcTime = LocalTime.hourMinute12(gcHour, widget.initialGcTime!.minute, widget.initialGcTime!.period);
    _selectedGcTime24 = LocalTime.hourMinute12(hour, widget.initialGcTime!.minute, widget.initialGcTime!.period);
  }

  _init() {
    ///First open tab will be Ethiopian
    calendarType = CalendarType.Ethiopian;

    ///Get Et & Gc 12 hour time equivalent from 24 hour Gc format
    _initHours();

    ///Init Animation
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    scaleAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeOutBack);
    animationController.forward();

    ///Init Scroller
    _hourScrollController = FixedExtentScrollController();
    _minuteScrollController = FixedExtentScrollController();
    _periodScrollController = FixedExtentScrollController();

    ///Animate Calendar to Incoming time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIncomingTime();
    });
  }

  _scrollToIncomingTime() {
    int animationDuration = 200;
    Curve animation = Curves.linear;
    int hour = calendarType == CalendarType.Ethiopian ? etHour! : gcHour!;
    _hourScrollController!
        .animateToItem(hour - 1, duration: Duration(milliseconds: animationDuration), curve: animation);
    _minuteScrollController!.animateToItem(widget.initialGcTime!.minute!,
        duration: Duration(milliseconds: animationDuration), curve: animation);
    _periodScrollController!.animateToItem(widget.initialGcTime!.period!.index,
        duration: Duration(milliseconds: animationDuration), curve: animation);
  }

  _getScrollableDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Expanded(
          flex: 1,
          child: _getScrollable(TimeScrollerType.hour),
        ),
        Text(":", style: _textStyle.copyWith(color: Theme.of(context).primaryColor)),
        Expanded(
          flex: 1,
          child: _getScrollable(TimeScrollerType.minute),
        ),
        Expanded(
          flex: calendarType == CalendarType.Ethiopian ? 2 : 1,
          child: _getScrollable(TimeScrollerType.period),
        )
      ]),
    );
  }

  _getScrollable(TimeScrollerType scrollableType) {
    List<Widget> scrollableList = _getScrollableList(scrollableType);
    FixedExtentScrollController? controller;
    if (scrollableType == TimeScrollerType.hour) {
      controller = _hourScrollController;
    } else if (scrollableType == TimeScrollerType.minute) {
      controller = _minuteScrollController;
    } else {
      controller = _periodScrollController;
    }

    return ListWheelScrollView.useDelegate(
      itemExtent: _itemExtent,
      useMagnifier: _useMagnifier,
      magnification: _magnification,
      offAxisFraction: _offAxisFraction,
      diameterRatio: _diameterRatio,
      squeeze: _squeeze,
      perspective: _perspective,
      overAndUnderCenterOpacity: _overAndUnderCenterOpacity,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: scrollableType != TimeScrollerType.period
          ? ListWheelChildLoopingListDelegate(
              children: scrollableList,
            )
          : ListWheelChildListDelegate(
              children: scrollableList,
            ),
      controller: controller,
      onSelectedItemChanged: (value) {
        setState(() {
          if (scrollableType == TimeScrollerType.hour) {
            isInitializeForceHourToScroll = true;
            if (calendarType == CalendarType.Ethiopian) {
              _selectedEtTime.hour = value;
              _selectedGcTime.hour = value < 6 ? value + 6 : value - 6;
            } else if (calendarType == CalendarType.Gregorian) {
              _selectedGcTime.hour = value;
              _selectedEtTime.hour = value < 6 ? value + 6 : value - 6;
            }
          } else if (scrollableType == TimeScrollerType.minute) {
            _selectedEtTime.minute = value;
            _selectedGcTime.minute = value;
          } else if (scrollableType == TimeScrollerType.period) {
            _selectedGcTime.period = value == 0 ? TimePeriod.AM : TimePeriod.PM;
            _selectedEtTime.period = value == 0 ? TimePeriod.AM : TimePeriod.PM;
          }
        });
      },
    );
  }

  _getScrollableList(TimeScrollerType scrollableType) {
    List<Widget> scrollableList;
    late int listLength, offset;

    if (scrollableType == TimeScrollerType.hour) {
      listLength = 12;
      offset = 1;
    } else if (scrollableType == TimeScrollerType.minute) {
      listLength = 60;
      offset = 0;
    } else if (scrollableType == TimeScrollerType.period) {
      listLength = 2;
      scrollableList = List<Widget>.generate(
          2,
          (index) => Align(
                alignment: Alignment.center,
                child: Text(
                  calendarType == CalendarType.Gregorian
                      ? MonthGlobals.timePeriodGc[index]
                      : MonthGlobals.timePeriodEt[index],
                  style: _textStyle,
                ),
              ));
      return scrollableList;
    }

    scrollableList = List<Widget>.generate(
      listLength,
      (index) => Align(
          alignment: Alignment.center,
          child: Text((index + offset) > 9 ? "${index + offset}" : "0${index + offset}", style: _textStyle)),
    );
    return scrollableList;
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    _hourScrollController?.dispose();
    _minuteScrollController?.dispose();
    _periodScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = theme.dialogBackgroundColor;

    double dialogOpacity = 1.0;
    try {
      if (Globals.setting.menuBackgroundOpacity != 0) {
        dialogOpacity = Globals.setting.menuBackgroundOpacity;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final isEthiopian = calendarType == CalendarType.Ethiopian;
    final pillBg = isDark
        ? Colors.white.withOpacity(0.08)
        : primaryColor.withOpacity(0.08);

    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 300,
              maxHeight: height * 0.4,
            ),
            decoration: BoxDecoration(
              color: cardBg.withOpacity(dialogOpacity),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: primaryColor.withOpacity(0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    AppLocalizations.of(context)!.pickATime,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),

                /// Custom Toggle TABS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (calendarType == CalendarType.Ethiopian) return;
                              setState(() {
                                calendarType = CalendarType.Ethiopian;
                                _scrollToIncomingTime();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isEthiopian ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(19),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.ethiopian,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isEthiopian ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (calendarType == CalendarType.Gregorian) return;
                              setState(() {
                                calendarType = CalendarType.Gregorian;
                                _scrollToIncomingTime();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !isEthiopian ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(19),
                              ),
                              child: Center(
                                child: Text(
                                  "Gregorian",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: !isEthiopian ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: primaryColor.withOpacity(0.12),
                    height: 1,
                  ),
                ),

                /// Scroll wheels picker
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Selection Highlight Overlay
                        Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        _getScrollableDatePicker(),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: primaryColor.withOpacity(0.12),
                    height: 1,
                  ),
                ),

                /// Confirm button
                 Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isInitializeForceHourToScroll) {
                            _selectedEtTime.hour = Utility.getZeroOrNumber(_selectedEtTime.hour) + 1;
                            _selectedGcTime.hour = Utility.getZeroOrNumber(_selectedGcTime.hour) + 1;
                          }
                          _set24HourFormatSelection();
                          widget.timeSetterCallback(_selectedEtTime, _selectedGcTime, _selectedGcTime24);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.check_rounded, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _set24HourFormatSelection() {
    _selectedGcTime24.minute = _selectedGcTime.minute;
    if (_selectedGcTime.period == TimePeriod.AM ||
        (_selectedGcTime.period == TimePeriod.PM && _selectedGcTime.hour == 12)) {
      _selectedGcTime24.hour = _selectedGcTime.hour;
    } else {
      _selectedGcTime24.hour = _selectedGcTime.hour! + 12;
    }
  }
}
