// ignore_for_file: avoid_unnecessary_containers

import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/screens/home/month_globals.dart';
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
  TabController? _tabController;
  FixedExtentScrollController? _hourScrollController;
  FixedExtentScrollController? _minuteScrollController;
  FixedExtentScrollController? _periodScrollController;
  FixedExtentScrollController? _scrollController;

  CalendarType? calendarType;

  int? hour, etHour, gcHour;

  final double _itemExtent = 75.0;
  final double _offAxisFraction = 0;
  final bool _useMagnifier = true;
  final double _magnification = 1;
  final double _diameterRatio = 2;
  final double _squeeze = 1.5;
  final double _perspective = 0.009;
  final double _overAndUnderCenterOpacity = 0.4;
  final TextStyle _textStyle = const TextStyle(fontSize: 20);

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

    ///Init Tab
    _initTab();

    ///Init Animation
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeOutSine);
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

  _initTab() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController!.addListener(() {
      if (_tabController!.index == 0) {
        calendarType = CalendarType.Ethiopian;
      } else {
        calendarType = CalendarType.Gregorian;
      }
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
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        child: Row(children: [
          Expanded(
            flex: 1,
            child: _getScrollable(TimeScrollerType.hour),
          ),
          Text(":", style: _textStyle),
          Expanded(
            flex: 1,
            child: _getScrollable(TimeScrollerType.minute),
          ),
          Expanded(
            flex: calendarType == CalendarType.Ethiopian ? 2 : 1,
            child: _getScrollable(TimeScrollerType.period),
          )
        ]),
      ),
    );
  }

  _getScrollable(TimeScrollerType scrollableType) {
    List<Widget> scrollableList = _getScrollableList(scrollableType);
    return Container(
      child: ListWheelScrollView.useDelegate(
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
        controller: _scrollController,
        onSelectedItemChanged: (value) {
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
        },
      ),
    );
  }

  _getScrollableList(TimeScrollerType scrollableType) {
    List<Widget> scrollableList;
    late int listLength, offset;

    if (scrollableType == TimeScrollerType.hour) {
      listLength = 12;
      offset = 1;
      _scrollController = _hourScrollController;
    } else if (scrollableType == TimeScrollerType.minute) {
      listLength = 60;
      offset = 0;
      _scrollController = _minuteScrollController;
    } else if (scrollableType == TimeScrollerType.period) {
      listLength = 2;
      _scrollController = _periodScrollController;
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
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: height / 2.4,
              width: width / 1.6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      tabs: [
                        Tab(icon: Text("${AppLocalizations.of(context)!.ethiopian}")),
                        const Tab(icon: Text("Gregorian")),
                      ],
                      controller: _tabController,
                      onTap: (value) {
                        debugPrint("------ Tapped value: $value");
                        if (value == 0) {
                          calendarType = CalendarType.Ethiopian;
                        } else {
                          calendarType = CalendarType.Gregorian;
                        }
                        _scrollToIncomingTime();
                      },
                    ),
                    title: Center(child: Text("${AppLocalizations.of(context)!.pickATime}")),
                    automaticallyImplyLeading: false,
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      Center(child: Builder(
                        builder: (context) {
                          calendarType = CalendarType.Ethiopian;
                          return _getScrollableDatePicker();
                        },
                      )),
                      Center(child: Builder(
                        builder: (context) {
                          calendarType = CalendarType.Gregorian;
                          return _getScrollableDatePicker();
                        },
                      )),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      if (isInitializeForceHourToScroll) {
                        _selectedEtTime.hour = Utility.getZeroOrNumber(_selectedEtTime.hour) + 1;
                        _selectedGcTime.hour = Utility.getZeroOrNumber(_selectedGcTime.hour) + 1;
                      }
                      _set24HourFormatSelection();
                      widget.timeSetterCallback(_selectedEtTime, _selectedGcTime, _selectedGcTime24);
                      Navigator.pop(context);
                    },
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    child: const Icon(
                      Icons.check,
                    ),
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
                ),
              ),
            ),
          ],
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
