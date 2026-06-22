import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatePickerDialogLocal extends StatefulWidget {
  const DatePickerDialogLocal({super.key, required this.callback, this.selectedEtDate, this.selectedGcDate});
  final Function callback;
  final LocalDate? selectedEtDate;
  final LocalDate? selectedGcDate;

  @override
  State<DatePickerDialogLocal> createState() => _DatePickerDialogLocalState();
}

class _DatePickerDialogLocalState extends State<DatePickerDialogLocal> with TickerProviderStateMixin {
  final TextStyle _textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

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

  double width = 0, height = 0;
  late bool isGeezNumbers;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    scaleAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeOutBack);
    animationController.forward();

    _yearScrollController = FixedExtentScrollController();
    _monthScrollController = FixedExtentScrollController();
    _dayScrollController = FixedExtentScrollController();
    calendarType = CalendarType.Ethiopian;
    initToday();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToInitialDay();
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    _yearScrollController?.dispose();
    _monthScrollController?.dispose();
    _dayScrollController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
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
              maxWidth: 340,
              maxHeight: height * 0.46,
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
                    AppLocalizations.of(context)!.pickADate,
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
                                initToday();
                                scrollToInitialDay();
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
                                initToday();
                                scrollToInitialDay();
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
                        getScrollableDatePicker(),
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
                          widget.callback(
                            LocalDate.detailed(yearEt, monthEt, dayEt, weekDay),
                            LocalDate.detailed(yearGc, monthGc, dayGc, weekDay),
                          );
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

  initToday() {
    DateTime gcDate =
        DateTime(widget.selectedGcDate!.year!, widget.selectedGcDate!.month!, widget.selectedGcDate!.day!);
    yearGc = gcDate.year;
    monthGc = gcDate.month - 1;
    dayGc = gcDate.day;
    monthNameGc = MonthGlobals.gcMonthsLong[monthGc!];
    weekDay = gcDate.weekday;
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
      _yearScrollController!
          .animateToItem(yearEt! - 1900, duration: Duration(milliseconds: animationDuration), curve: animation);
      _monthScrollController!
          .animateToItem(monthEt! - 1, duration: Duration(milliseconds: animationDuration), curve: animation);
      _dayScrollController!
          .animateToItem(dayEt! - 1, duration: Duration(milliseconds: animationDuration), curve: animation);
    } else if (calendarType == CalendarType.Gregorian) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
    if (calendarType == CalendarType.Ethiopian && scrollableType == ScrollableType.month && monthEt == 13) {
      int pagumeLength = !MonthModel.isLeapYear(yearEt) ? 5 : 6;
      if (dayEt! > pagumeLength) {
        dayEt = pagumeLength - 1;
        _dayScrollController!.jumpToItem(dayEt!);
      }
    }

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
    return ListWheelScrollView.useDelegate(
      itemExtent: 38,
      useMagnifier: true,
      magnification: 1.15,
      offAxisFraction: -0.2,
      diameterRatio: 2.0,
      squeeze: 1.3,
      perspective: 0.007,
      overAndUnderCenterOpacity: 0.35,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildLoopingListDelegate(
        children: scrollableList,
      ),
      controller: _scrollController,
      onSelectedItemChanged: (value) {
        HapticFeedback.selectionClick();
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          SystemSound.play(SystemSoundType.click);
        }
        setState(() {
          calendarType == CalendarType.Ethiopian
              ? syncEtDayChange(scrollableType, value)
              : syncGcDayChange(scrollableType, value);
        });
      },
    );
  }

  syncGcDayChange(ScrollableType scrollableType, int value) {
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
