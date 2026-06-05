// ignore_for_file: avoid_unnecessary_containers

import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/converter/age_calculator_dialog.dart';
import 'package:event_calendar_v2/screens/converter/input_based_converter_dialog.dart';
import 'package:event_calendar_v2/screens/converter/tab_view_item.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
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
  late bool isGeezNumbers;

  FixedExtentScrollController? _yearScrollController;
  FixedExtentScrollController? _monthScrollController;
  FixedExtentScrollController? _dayScrollController;
  FixedExtentScrollController? _scrollController;

  CalendarType? calendarType;

  final List<Text> conversionOptions = [
    const Text("From - Gregorian"),
    Text(AppLocalizations.of(MonthGlobals.context!)!.fromEthiopia),
  ];

  List<Text> selectedConversion = [];
  final TextStyle _textStyle = const TextStyle(fontSize: 15);

  @override
  Widget build(BuildContext context) {
    ///Adjusting screen size for iOS scroll hidden (tested on pro max 14)
    double height = MediaQuery.of(context).size.height;
    double screenDiff = height > 900 ? 3.8 : 2.5;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(AppLocalizations.of(context)!.dateConverter)),
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: height - (AppBar().preferredSize.height * screenDiff),
          child: getScrollableDatePicker(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    _yearScrollController = FixedExtentScrollController();
    _monthScrollController = FixedExtentScrollController();
    _dayScrollController = FixedExtentScrollController();
    initToday();
    calendarType = CalendarType.Gregorian;
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToInitialDay());
    selectedConversion.add(conversionOptions[0]);
  }

  initToday() {
    DateTime gcDate = DateTime.now();
    yearGc = gcDate.year;
    monthGc = gcDate.month - 1;
    dayGc = gcDate.day;
    monthNameGc = MonthGlobals.gcMonthsLong[monthGc!];
    weekDayGc = MonthGlobals.gcWeekNamesLong[gcDate.weekday - 1];

    LocalDate gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
    LocalDate etNow = MonthModel.toEc(year: gcNow.year!, month: gcNow.month!, day: gcNow.day!)!;
    yearEt = etNow.year;
    monthEt = etNow.month;
    dayEt = etNow.day;
    monthNameEt = MonthGlobals.etMonthsLong[monthEt! - 1];
    weekDayEt = MonthGlobals.etWeekNamesLong[gcDate.weekday - 1];

    print("ET DAY: $monthNameEt $dayEt, $yearEt");
  }

  scrollToInitialDay() {
    if (calendarType == CalendarType.Ethiopian) {
      ///If conversion is from Ethiopian to Gregorian
      _yearScrollController!
          .animateToItem(yearEt! - 1900, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutBack);
      _monthScrollController!
          .animateToItem(monthEt! - 1, duration: const Duration(milliseconds: 400), curve: Curves.ease);
      _dayScrollController!
          .animateToItem(dayEt! - 1, duration: const Duration(milliseconds: 400), curve: Curves.linear);
    } else if (calendarType == CalendarType.Gregorian) {
      ///If conversion is from Gregorian to Ethiopian
      _yearScrollController!
          .animateToItem(yearGc! - 1900, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutBack);
      _monthScrollController!.animateToItem(monthGc!, duration: const Duration(milliseconds: 400), curve: Curves.ease);
      _dayScrollController!
          .animateToItem(dayGc! - 1, duration: const Duration(milliseconds: 400), curve: Curves.linear);
    }
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
  }

  syncEtDayChange(ScrollableType scrollableType, int value) {
    debugPrint("-------------------- Sync ET");
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
  }

  getScrollableDatePicker() {
    bool isToday = isScrollIndicatesToday();
    // Color shadowColor = isToday ? Theme.of(context).buttonColor : Theme.of(context).primaryColor;
    Color? buttonTextColor = isToday
        ? Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3)
        : Theme.of(context).textTheme.bodyLarge!.color;
    TextStyle ts = TextStyle(color: buttonTextColor);

    return Column(
      children: [
        Expanded(child: getConversionOption()),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    height: 30,
                    width: Globals.deviceWidth),
                Container(
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
              ],
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Card(
                  elevation: isToday ? 0 : 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Icon(
                        Icons.today,
                        color: buttonTextColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(AppLocalizations.of(context)!.today, style: ts),
                      )
                    ]),
                  ),
                ),
                onTap: () {
                  setState(() {
                    ///Returning to current day(today) creates inconsistency and the following if...else
                    ///block try to refresh the whole content by switching scrolls and fix in work-arround
                    selectedConversion.clear();
                    if (calendarType == CalendarType.Ethiopian) {
                      calendarType = CalendarType.Gregorian;
                      selectedConversion.add(conversionOptions[0]);
                    } else {
                      calendarType = CalendarType.Ethiopian;
                      selectedConversion.add(conversionOptions[1]);
                    }

                    initToday();
                    scrollToInitialDay();

                    print("GC DAY: $monthGc $monthNameGc $dayGc, $yearGc");
                    print("ET DAY: $monthNameEt $dayEt, $yearEt");
                    // initToday(); // selectedConversion.add(conversionOptions[0]);
                  });
                  // WidgetsBinding.instance.addPostFrameCallback((_) => scrollToInitialDay());
                },
              ),
              GestureDetector(
                onTap: !isToday
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AgeCalculatorDialog(
                              calendarType: calendarType,
                              etDate: LocalDate.date(yearEt, monthEt, dayEt),
                              gcDate: LocalDate.date(yearGc, monthGc, dayGc),
                            );
                          },
                        );
                      }
                    : null,
                child: Card(
                  elevation: isToday ? 0 : 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: buttonTextColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          AppLocalizations.of(context)!.age,
                          style: ts,
                        ),
                      )
                    ]),
                  ),
                ),
              ),
              GestureDetector(
                child: Card(
                  elevation: 3,
                  shadowColor: Theme.of(context).textTheme.bodyLarge!.color,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      const Icon(Icons.edit),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(AppLocalizations.of(context)!.input),
                      )
                    ]),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      if (calendarType == CalendarType.Ethiopian) {
                        return InputBasedConverterDialog(
                          calendarType: calendarType,
                          day: dayEt,
                          month: monthEt,
                          year: yearEt,
                          conversionResultUpdaterCallback: conversionResultUpdaterCallback,
                        );
                      } else {
                        return InputBasedConverterDialog(
                          calendarType: calendarType,
                          day: dayGc,
                          month: monthGc,
                          year: yearGc,
                          conversionResultUpdaterCallback: conversionResultUpdaterCallback,
                        );
                      }
                    },
                    // builder: (_) => InputBasedConverterDialog(calendarType: calendarType,),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${AppLocalizations.of(context)!.ethiopian} : ",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: Builder(
                            builder: (context) {
                              String converted;
                              if (yearEt! >= 1900) {
                                converted =
                                    '  $weekDayEt  $monthNameEt ${isGeezNumbers ? GeezNumbers.geezNumbers[dayEt! - 1] : dayEt}, ${isGeezNumbers ? GeezNumbers.geezYears[yearEt! - 1900] : yearEt}';
                              } else {
                                converted =
                                    '  $weekDayEt  $monthNameEt ${isGeezNumbers ? GeezNumbers.geezNumbers[dayEt! - 1] : dayEt}, ${isGeezNumbers ? GeezNumbers.geezYears18s[(yearEt! - 1900).abs()] : yearEt}';
                              }
                              return Text(converted);
                            },
                          )),
                    )
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Expanded(
                        flex: 1,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Gregorian : ",
                              textAlign: TextAlign.right,
                            ))),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '  $weekDayGc $monthNameGc $dayGc, $yearGc',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
                    ? "${GeezNumbers.geezYears[index]}"
                    : "${index + 1900}",
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
                      ? "${GeezNumbers.geezNumbers[index]}"
                      : "${index + 1}",
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
        print("Pagume logic");
        _dayScrollController!.jumpToItem(dayEt!);
      }
    }

    ///Adjustment for gregorian days due to different sizes
    if (calendarType == CalendarType.Gregorian) {
      if (monthGc == 0) monthGc = 12;
      int monthLength = MonthModel.getDaysInGcMonth(monthGc! - 1, yearGc);
      debugPrint("-------------------- Month Length: $monthLength");
      if (dayGc! > monthLength) {
        dayGc = monthLength - 1;
        _dayScrollController!.jumpToItem(dayGc!);
      }
    }
  }

  getScrollable(ScrollableType scrollableType) {
    double itemExtent = 75.0;
    double offAxisFraction = 0.5;
    bool useMagnifier = true;
    double magnification = 1.0;
    double diameterRatio = 2.5;
    double squeeze = 1.4;
    double perspective = 0.008;
    double overAndUnderCenterOpacity = 0.4;
    adjustMonthLengthDifferenceWhileScrolling(scrollableType);
    List<Widget> scrollableList = getScrollableList(scrollableType);
    return Container(
      child: ListWheelScrollView.useDelegate(
        itemExtent: itemExtent,
        useMagnifier: useMagnifier,
        magnification: magnification,
        offAxisFraction: offAxisFraction,
        diameterRatio: diameterRatio,
        squeeze: squeeze,
        perspective: perspective,
        overAndUnderCenterOpacity: overAndUnderCenterOpacity,
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

  getConversionOption() {
    return Container(
      child: GridView.count(
        childAspectRatio: 3.5,
        crossAxisCount: 2,
        children: conversionOptions.map((conversionOption) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedConversion.clear();
                selectedConversion.add(conversionOption);
                if (conversionOption.data!.toLowerCase() == "from - gregorian") {
                  calendarType = CalendarType.Gregorian;
                } else {
                  calendarType = CalendarType.Ethiopian;
                }
                initToday();
                scrollToInitialDay();
              });
            },
            child: TabViewItem(innerText: conversionOption, isSelected: selectedConversion.contains(conversionOption)),
          );
        }).toList(),
      ),
    );
  }

  conversionResultUpdaterCallback(
      int etDay, int etMonth, int etYear, int gcDay, int gcMonth, int gcYear, CalendarType type) {
    try {
      bool isDateValid = true;
      try {
        isDateValid = Utility.isDateValidAndSupported(
            calendarType: CalendarType.Ethiopian, year: etYear, month: etMonth, day: etDay);
        if (!isDateValid) throw Exception();
        isDateValid = Utility.isDateValidAndSupported(
            calendarType: CalendarType.Gregorian, year: gcYear, month: gcMonth, day: gcDay);
        if (!isDateValid) throw Exception();
      } catch (e) {
        debugPrint(e.toString());

        ///TODO: Commented
        Globals.showSnack(
          context: context,
          type: SnackMessageType.error,

          ///TODO: Get message from language config file
          message: "Please enter a valid date.",
        );
        return;
      }
      setState(() {
        try {
          dayEt = etDay;
          monthEt = etMonth;
          yearEt = etYear;
          dayGc = gcDay;
          monthGc = gcMonth;
          yearGc = gcYear;
          calendarType = type;
          selectedConversion.clear();
          if (calendarType == CalendarType.Ethiopian) {
            selectedConversion.add(conversionOptions[1]);
          } else {
            selectedConversion.add(conversionOptions[0]);
          }
          scrollToInitialDay();
          // WidgetsBinding.instance.addPostFrameCallback((_) => scrollToInitialDay());
        } catch (e) {
          debugPrint(e.toString());
          return;
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  isScrollIndicatesToday() {
    if (dayEt == MonthGlobals.etNow!.day &&
        monthEt == MonthGlobals.etNow!.month &&
        yearEt == MonthGlobals.etNow!.year) {
      return true;
    }
    return false;
  }
}
