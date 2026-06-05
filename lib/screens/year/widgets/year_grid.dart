import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/main.dart';
import 'package:event_calendar_v2/screens/home/home_page.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class YearGrid extends StatefulWidget {
  const YearGrid({super.key, this.year, this.needFirstAnimation});
  final int? year;
  final bool? needFirstAnimation;

  @override
  State<YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<YearGrid> {
  Row? daysHeaderShort;
  late TableRow weekDayShortHeader;
  List<int?> monthsStartDayIndex = List.generate(13, (index) => null);
  bool? isYearLeap;
  late int pagumeLength;
  late double deviceHeight;
  late double cardWidth;
  late double cardHeight;
  late bool isGeezNumbers;

  List<GridView> months = [];

  @override
  void didUpdateWidget(YearGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    getFirstMonthDayStartIndex();
    pagumeLength = MonthModel.isLeapYear(widget.year) ? 6 : 5;
  }

  initDayHeadersShort() {
    String weekStartDay = Utility.getWeekStartDay();
    List<FittedBox> daysList = List.generate(
      7,
      (index) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
              weekStartDay == 'Mon'
                  ? MonthGlobals.etDayHeaderFirstCharacter[index]!
                  : MonthGlobals.etDayHeaderFirstCharacterSundayFirst[index]!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10))),
    );
    weekDayShortHeader = TableRow(children: daysList);
  }

  getFirstMonthDayStartIndex() {
    LocalDate gcDate = MonthModel.toGc(year: widget.year!, month: 1, day: 1)!;
    DateTime gcDateTime = new DateTime(gcDate.year!, gcDate.month!, gcDate.day!);
    print("Meskerem 1 ${gcDateTime.weekday.toString()}");
    initMonthsStartDay(gcDateTime);
  }

  initMonthsStartDay(DateTime gcDateTime) {
    int yearStartDay = gcDateTime.weekday;
    int monthStartDay = yearStartDay - 1;

    for (int i = 0; i < 13; i++) {
      if (i > 0) monthStartDay += 2;
      if (monthStartDay > 6) monthStartDay -= 7;
      String weekStartDay = Utility.getWeekStartDay();
      if (weekStartDay == 'Mon') {
        monthsStartDayIndex[i] = monthStartDay;
      } else {
        monthsStartDayIndex[i] = monthStartDay + 1;
      }
    }
    print("MONTHS START DAYS OF YEAR :$monthsStartDayIndex");
  }

  generateMonthTable(month) {
    List<TableRow> rows = [];
    rows.add(weekDayShortHeader);
    int? monthStartIndex = monthsStartDayIndex[month];
    int monthLength = month < 12 ? 30 : pagumeLength;
    int day = 0;
    int gridLength = monthsStartDayIndex[month]! + monthLength;
    String weekStartDay = Utility.getWeekStartDay();

    List<int> days = List.generate(42, (index) {
      if (index >= monthStartIndex! && day < monthLength) {
        day++;
        return day;
      }
      return 0;
    });

    int index = 0;
    int rowLength = gridLength ~/ 7;
    for (int i = 0; i <= rowLength; i++) {
      List<Container> weekDays = [];
      for (int j = i; j < i + 7; j++) {
        bool isSunday = false;
        if (weekStartDay == 'Mon') {
          isSunday = index % 7 == 6;
        } else {
          isSunday = index % 7 == 0;
        }
        weekDays.add(days[index] != 0
            ? Container(
                child: Text(
                "${isGeezNumbers ? GeezNumbers.geezNumbers[days[index] - 1] : days[index]}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w200,
                    color: isSunday ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color),
              ))
            : Container());
        index++;
      }
      rows.add(TableRow(children: weekDays));
    }

    Table monthTable = Table(
      children: rows,
    );
    return monthTable;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double offset = 0.0;
    deviceHeight = MediaQuery.of(context).size.height;
    // if (deviceHeight < 700) offset = -1;
    cardWidth = MediaQuery.of(context).size.width / 4.3;
    cardHeight = MediaQuery.of(context).size.height / (7.5 + offset);
  }

  @override
  Widget build(BuildContext context) {
    double offset = deviceHeight > 700 ? 8 : 12;

    return AnimationLimiter(
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: cardWidth / (cardHeight - 5),
              crossAxisSpacing: 20,
              mainAxisSpacing: offset),
          itemCount: 13,
          itemBuilder: (BuildContext ctx, index) {
            return widget.needFirstAnimation!
                ? AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 700),
                    columnCount: 3,
                    child: FlipAnimation(
                      flipAxis: FlipAxis.y,
                      child: buildMonth(context, index),
                    ),
                  )
                : buildMonth(context, index);
          }),
    );
  }

  Padding buildMonth(BuildContext context, int index) {
    print("Hello there. $deviceHeight");
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 1000),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  animation = CurvedAnimation(curve: Curves.easeIn, parent: animation);
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                pageBuilder: (context, animation, secondaryAnimation) {
                  Globals.selectedIndex = 0;
                  Globals.displayingIndex = 0;
                  MonthGlobals.etShowingMonth = index + 1;
                  MonthGlobals.etShowingYear = widget.year;
                  Globals.yearGridMonthTap = true;

                  ///TODO: Commented
                  // return MixedMenuContainer();

                  ///TODO: Using state management might help here.
                  return const ContainerPage();
                },
              ));
        },
        child: Container(
          child: Column(
            children: [
              Text(
                '${MonthGlobals.etMonthsLong[index]}',
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
              Expanded(child: generateMonthTable(index) /*months[index]*/),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    getFirstMonthDayStartIndex();
    initDayHeadersShort();
    pagumeLength = MonthModel.isLeapYear(widget.year) ? 6 : 5;
  }
}
