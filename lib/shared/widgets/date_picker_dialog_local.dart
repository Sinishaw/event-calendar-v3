// ignore_for_file: avoid_unnecessary_containers

import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class DatePickerDialogLocal extends StatefulWidget {
  const DatePickerDialogLocal({super.key, required this.callback, this.selectedEtDate, this.selectedGcDate});
  final Function callback;
  final LocalDate? selectedEtDate;
  final LocalDate? selectedGcDate;

  @override
  State<DatePickerDialogLocal> createState() => _DatePickerDialogLocalState();
}

class _DatePickerDialogLocalState extends State<DatePickerDialogLocal> with TickerProviderStateMixin {
  //region FIELDS
  final TextStyle _textStyle = const TextStyle(fontSize: 15);

  final double _itemExtent = 75.0;
  final double _offAxisFraction = -0.3;
  final bool _useMagnifier = true;
  final double _magnification = 1;
  final double _diameterRatio = 2;
  final double _squeeze = 1.7;
  final double _perspective = 0.009;
  final double _overAndUnderCenterOpacity = 0.4;

  int? yearGc;
  int? monthGc;
  int? dayGc;
  String? monthNameGc;
  String? weekDayGc;

  int? yearEt;
  int? monthEt;
  int? dayEt;
  String? monthNameEt;
  String? weekDayEt;

  int? weekDay;

  FixedExtentScrollController? _yearScrollController;
  FixedExtentScrollController? _monthScrollController;
  FixedExtentScrollController? _dayScrollController;
  FixedExtentScrollController? _scrollController;

  CalendarType? calendarType;
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  TabController? _tabController;
  Widget? etScroll, gcScroll;
  double width = 0, height = 0;

//endregion
  late bool isGeezNumbers;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeOutSine);
    animationController.forward();

    _yearScrollController = FixedExtentScrollController();
    _monthScrollController = FixedExtentScrollController();
    _dayScrollController = FixedExtentScrollController();
    calendarType = CalendarType.Ethiopian;
    initTab();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    super.initState();
  }

  initTab() {
    initToday();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToInitialDay();
    });

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _tabController!.addListener(() {
      setState(() {
        if (_tabController!.index == 0) {
          calendarType = CalendarType.Ethiopian;
        } else {
          calendarType = CalendarType.Gregorian;
        }
        initToday();
        scrollToInitialDay();
      });
    });
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
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
                borderRadius: BorderRadius.circular(30.0),
                child: Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      tabs: [
                        Tab(icon: Text(AppLocalizations.of(context)!.ethiopian)),
                        Tab(icon: Text("Gregorian")),
                      ],
                      controller: _tabController,
                    ),
                    title: Center(child: Text(AppLocalizations.of(context)!.pickADate)),
                    automaticallyImplyLeading: false,
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: [getScrollableDatePicker(), getScrollableDatePicker()],
                  ),
                  floatingActionButton: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      widget.callback(LocalDate.detailed(yearEt, monthEt, dayEt, weekDay),
                          LocalDate.detailed(yearGc, monthGc, dayGc, weekDay));
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

  initToday() {
    // DateTime gcDate = new DateTime.now();
    DateTime gcDate =
        DateTime(widget.selectedGcDate!.year!, widget.selectedGcDate!.month!, widget.selectedGcDate!.day!);
    yearGc = gcDate.year;
    // yearGc = widget.selectedGcDate.year;
    monthGc = gcDate.month - 1;
    // monthGc = widget.selectedGcDate.month;
    dayGc = gcDate.day;
    // dayGc = widget.selectedGcDate.day;
    monthNameGc = MonthGlobals.gcMonthsLong[monthGc!];

    weekDay = gcDate.weekday;

    // DateTime gcDate = new DateTime(yearGc, monthGc,dayGc);
    weekDayGc = MonthGlobals.gcWeekNamesLong[gcDate.weekday - 1];

    LocalDate gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
    LocalDate etNow = MonthModel.toEc(year: gcNow.year!, month: gcNow.month!, day: gcNow.day!)!;

    yearEt = etNow.year;
    monthEt = etNow.month;
    dayEt = etNow.day;
    monthNameEt = MonthGlobals.etMonthsLong[monthEt! - 1];
    weekDayEt = MonthGlobals.etWeekNamesLong[gcDate.weekday - 1];
  }

  scrollToInitialDay() {
    int animationDuration = 200;
    Curve animation = Curves.linear;
    if (calendarType == CalendarType.Ethiopian) {
      ///If conversion is from Ethiopian to Gregorian
      _yearScrollController!
          .animateToItem(yearEt! - 1900, duration: Duration(milliseconds: animationDuration), curve: animation);
      _monthScrollController!
          .animateToItem(monthEt! - 1, duration: Duration(milliseconds: animationDuration), curve: animation);
      _dayScrollController!
          .animateToItem(dayEt! - 1, duration: Duration(milliseconds: animationDuration), curve: animation);
    } else if (calendarType == CalendarType.Gregorian) {
      ///If conversion is from Gregorian to Ethiopian
      _yearScrollController!
          .animateToItem(yearGc! - 1900, duration: Duration(milliseconds: animationDuration), curve: animation);
      _monthScrollController!
          .animateToItem(monthGc!, duration: Duration(milliseconds: animationDuration), curve: animation);
      _dayScrollController!
          .animateToItem(dayGc! - 1, duration: Duration(milliseconds: animationDuration), curve: animation);
    }
  }

  getScrollableDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        child: Row(children: [
          Expanded(
            flex: 1,
            child: getScrollable(ScrollableType.day),
          ),
          Expanded(
            flex: 2,
            child: getScrollable(ScrollableType.month),
          ),
          Expanded(
            flex: 1,
            child: getScrollable(ScrollableType.year),
          )
        ]),
      ),
    );
  }

  getScrollableList(ScrollableType scrollableType) {
    List<Widget> scrollableList;
    late int daysInMonth;

    if (calendarType == CalendarType.Gregorian) {
      if (monthGc == 0) monthGc = 12;
      daysInMonth = MonthModel.getDaysInGcMonth(monthGc! - 1, yearGc);
    } else if (calendarType == CalendarType.Ethiopian) {
      if (monthEt! < 13) {
        daysInMonth = 30;
      } else {
        daysInMonth = !MonthModel.isLeapYear(yearEt) ? 5 : 6;
      }
    } else {}

    if (scrollableType == ScrollableType.year) {
      scrollableList = List<Widget>.generate(
        151,
        (index) => Align(
            alignment: Alignment.center,
            child: Text(
                isGeezNumbers && calendarType == CalendarType.Ethiopian
                    ? GeezNumbers.geezYears[index]
                    : '${index + 1900}',
                style: _textStyle)),
      );
      _scrollController = _yearScrollController;
    } else if (scrollableType == ScrollableType.month) {
      scrollableList = List<Widget>.generate(
        calendarType == CalendarType.Ethiopian ? 13 : 12,
        (index) => Align(
            alignment: Alignment.center,
            child: Text(
                '${calendarType == CalendarType.Ethiopian ? MonthGlobals.etMonthsLong[index] : MonthGlobals.gcMonthsLong[index]}',
                style: _textStyle)),
      );
      _scrollController = _monthScrollController;
    } else {
      scrollableList = List<Widget>.generate(
        daysInMonth,
        (index) {
          // print("INDEX:: $index");
          return Align(
              alignment: Alignment.center,
              child: Text(
                  isGeezNumbers && calendarType == CalendarType.Ethiopian
                      ? GeezNumbers.geezNumbers[index]
                      : '${index + 1}',
                  style: _textStyle));
        },
      );
      _scrollController = _dayScrollController;
    }
    return scrollableList;
  }

  adjustMonthLengthDifferenceWhileScrolling(ScrollableType scrollableType) {
    ///Adjustment for pagume due to its days size difference
    if (calendarType == CalendarType.Ethiopian && scrollableType == ScrollableType.month && monthEt == 13) {
      int pagumeLength = !MonthModel.isLeapYear(yearEt) ? 5 : 6;
      if (dayEt! > pagumeLength) {
        dayEt = pagumeLength - 1;
        _dayScrollController!.jumpToItem(dayEt!);
      }
    }

    ///Adjustment for gregorian days due to different sizes
    if (calendarType == CalendarType.Gregorian) {
      if (monthGc == 0) monthGc = 12;
      int monthLength = MonthModel.getDaysInGcMonth(monthGc! - 1, yearGc);
      if (dayGc! > monthLength) {
        dayGc = monthLength - 1;
        _dayScrollController!.jumpToItem(dayGc!);
      }
    }
  }

  getScrollable(ScrollableType scrollableType) {
    adjustMonthLengthDifferenceWhileScrolling(scrollableType);
    List<Widget> scrollableList = getScrollableList(scrollableType);
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
        childDelegate: ListWheelChildLoopingListDelegate(
          children: scrollableList,
        ),
        controller: _scrollController,
        onSelectedItemChanged: (value) {
          setState(() {
            calendarType == CalendarType.Ethiopian
                ? syncEtDayChange(scrollableType, value)
                : syncGcDayChange(scrollableType, value);
          });
        },
      ),
    );
  }

  syncGcDayChange(ScrollableType scrollableType, int value) {
    print("Sync GC");
    switch (scrollableType) {
      case ScrollableType.year:
        {
          yearGc = value + 1900;
        }
        break;
      case ScrollableType.month:
        {
          monthGc = value + 1;
          monthNameGc = MonthGlobals.gcMonthsLong[value];
        }
        break;
      case ScrollableType.day:
        {
          dayGc = value + 1;
        }
        break;
    }

    LocalDate etDate = MonthModel.toEc(year: yearGc!, month: monthGc!, day: dayGc!)!;
    yearEt = etDate.year;
    monthEt = etDate.month;
    dayEt = etDate.day;
    monthNameEt = MonthGlobals.etMonthsLong[monthEt! - 1];

    DateTime gcDate = DateTime(yearGc!, monthGc!, dayGc!);
    weekDayEt = MonthGlobals.etWeekNamesLong[gcDate.weekday - 1];
    weekDayGc = MonthGlobals.gcWeekNamesLong[gcDate.weekday - 1];
    weekDay = gcDate.weekday;
  }

  syncEtDayChange(ScrollableType scrollableType, int value) {
    print("Sync ET");
    switch (scrollableType) {
      case ScrollableType.year:
        {
          yearEt = value + 1900;
        }
        break;
      case ScrollableType.month:
        {
          monthEt = value + 1;
          monthNameEt = MonthGlobals.etMonthsLong[value];
        }
        break;
      case ScrollableType.day:
        {
          dayEt = value + 1;
        }
        break;
    }

    LocalDate localGcDate = MonthModel.toGc(year: yearEt!, month: monthEt!, day: dayEt!)!;
    DateTime gcDate = DateTime(localGcDate.year!, localGcDate.month!, localGcDate.day!);
    yearGc = gcDate.year;
    monthGc = gcDate.month;
    dayGc = gcDate.day;
    monthNameGc = MonthGlobals.gcMonthsLong[monthGc! - 1];
    weekDayEt = MonthGlobals.etWeekNamesLong[gcDate.weekday - 1];
    weekDayGc = MonthGlobals.gcWeekNamesLong[gcDate.weekday - 1];
    weekDay = gcDate.weekday;
  }
}
