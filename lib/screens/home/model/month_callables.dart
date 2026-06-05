import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/model/day_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

mixin MonthCallables {
  List<int> navigation = List.generate(2, (_) => 0);
  late double containerHeight;
  late double cellWidth;
  double? cellHeight;
  List<List<Day>> lst = [];

  bool isStartingMonth = true;

  List<NotificationPayload> eventsList = [];
  bool isEmptyList = false;
  bool isNavigationStart = false;
  bool swipeLeft = false;
  bool isTapFromMonthPicker = false;
  Widget? child;
  late bool isGeezNumbers;

  initToday() {
    DateTime gcDate = DateTime.now();
    MonthGlobals.gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
    MonthGlobals.etNow = MonthModel.toEc(
        year: MonthGlobals.gcNow!.year!, month: MonthGlobals.gcNow!.month!, day: MonthGlobals.gcNow!.day!);

    MonthGlobals.todayIndex = getTodayIndex(gcDate.weekday, MonthGlobals.etNow!.day);
    MonthGlobals.today = MonthGlobals.etNow!.day;
    MonthGlobals.showingMonthStartIndex = MonthGlobals.todayIndex! - (MonthGlobals.today! - 1);
    adjustSundayOffset();
    MonthGlobals.gcShowing = MonthGlobals.gcNow;
    MonthGlobals.etShowing = MonthGlobals.etNow;
    MonthGlobals.currentMonthArray = getTodayMonthSequence();
    MonthGlobals.showingMonthArray = MonthGlobals.currentMonthArray;
    MonthGlobals.etShowingMonth = MonthGlobals.etNow!.month;
    MonthGlobals.etShowingYear = MonthGlobals.etNow!.year;

    MonthGlobals.etNowMonth = MonthGlobals.etNow!.month;
    MonthGlobals.etNowYear = MonthGlobals.etNow!.year;
    Globals.todayIsInitialized = true;
  }

  initMonthMatrix() {
    int ctr = -1;
    MonthGlobals.monthMatrix =
        List.generate(6, (i) => List.generate(7, (j) => ++ctr, growable: false), growable: false);
  }

  Widget monthHeader(BuildContext context) {
    String weekStartDay = Utility.getWeekStartDay();
    Color color = Theme.of(context).primaryColor.withOpacity(0.2);
    TextStyle ts = TextStyle(color: Theme.of(context).primaryColor);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        decoration: BoxDecoration(
            color: color,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 0.5,
              ),
            )),
        child: Table(
          children: [
            weekStartDay == 'Mon'
                ? TableRow(children: [
                    Center(child: Text(AppLocalizations.of(context)!.mon, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.tue, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.wed, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.thu, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.fri, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.sat, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.sun, style: ts))
                  ])
                : TableRow(children: [
                    Center(child: Text(AppLocalizations.of(context)!.sun, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.mon, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.tue, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.wed, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.thu, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.fri, style: ts)),
                    Center(child: Text(AppLocalizations.of(context)!.sat, style: ts)),
                  ])
          ],
        ),
      ),
    );
  }

  setPrevMonthStartWeekDay() {
    if (MonthGlobals.etShowingMonth != 1) {
      ///Navigation backward other than Meskerem->Pagume
      int diff = MonthGlobals.showingMonthStartIndex! - 2;
      if (diff > -1) {
        MonthGlobals.showingMonthStartIndex = diff;
      } else {
        MonthGlobals.showingMonthStartIndex = diff + 7;
      }
    } else {
      ///Navigation backward only Meskerem->Pagume
      int prevPagumeLength = !MonthModel.isLeapYear(MonthGlobals.etShowingYear! - 1) ? 5 : 6;
      int diff = MonthGlobals.showingMonthStartIndex! - prevPagumeLength;
      if (diff < 0) {
        MonthGlobals.showingMonthStartIndex = diff + 7;
      } else {
        MonthGlobals.showingMonthStartIndex = diff;
      }
    }

    ///May not be necessary
    return MonthGlobals.showingMonthStartIndex;
  }

  setNextMonthStartWeekDay() {
    if (MonthGlobals.etShowingMonth != 13) {
      ///Navigation forward other than Pagume->Meskerem
      int diff = MonthGlobals.showingMonthStartIndex! + 2;
      if (diff < 7) {
        MonthGlobals.showingMonthStartIndex = diff;
      } else {
        MonthGlobals.showingMonthStartIndex = diff % 7;
      }
    } else {
      ///Navigation forward from Pagume->Meskerem
      int currentPagumeLength = !MonthModel.isLeapYear(MonthGlobals.etShowingYear) ? 5 : 6;
      int diff = MonthGlobals.showingMonthStartIndex! + currentPagumeLength;
      if (diff > 6) {
        MonthGlobals.showingMonthStartIndex = diff - 7;
      } else {
        MonthGlobals.showingMonthStartIndex = diff;
      }
    }

    ///May not be necessary
    return MonthGlobals.showingMonthStartIndex;
  }

  prevEtMonth() async {
    int startIndex = setPrevMonthStartWeekDay();
    int prevMonth = MonthGlobals.etShowingMonth! - 1;
    if (prevMonth > 0) {
      MonthGlobals.etShowingMonth = prevMonth;
    } else {
      MonthGlobals.etShowingMonth = 13;
      MonthGlobals.etShowingYear = Utility.getZeroOrNumber(MonthGlobals.etShowingYear) - 1;
    }

    LocalDate etDate = LocalDate.date(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, 1);
    LocalDate gcDate = MonthModel.toGc(year: etDate.year!, month: etDate.month!, day: 1)!;
    List<Day> monthArray = await getMonthSequence(startIndex, etDate, gcDate);
    MonthGlobals.showingMonthArray = monthArray;
    return monthArray;
  }

  nextEtMonth() async {
    int startIndex = setNextMonthStartWeekDay();
    int nextMonth = MonthGlobals.etShowingMonth! + 1;
    if (nextMonth < 14) {
      MonthGlobals.etShowingMonth = nextMonth;
    } else {
      MonthGlobals.etShowingMonth = 1;
      MonthGlobals.etShowingYear = Utility.getZeroOrNumber(MonthGlobals.etShowingYear) + 1;
    }
    LocalDate etDate = LocalDate.date(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, 1);
    LocalDate gcDate = MonthModel.toGc(year: etDate.year!, month: etDate.month!, day: 1)!;

    List<Day> monthArray = await getMonthSequence(startIndex, etDate, gcDate);
    MonthGlobals.showingMonthArray = monthArray;
    return monthArray;
  }

  jumpToEtMonth() async {
    LocalDate gcDate = MonthModel.toGc(year: MonthGlobals.etShowingYear!, month: MonthGlobals.etShowingMonth!, day: 1)!;
    DateTime gcDateTime = DateTime(gcDate.year!, gcDate.month!, gcDate.day!);
    int startIndex = MonthGlobals.showingMonthStartIndex = gcDateTime.weekday - 1;
    LocalDate etDate = LocalDate.date(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, 1);
    List<Day> monthArray = await getMonthSequence(startIndex, etDate, gcDate);
    MonthGlobals.showingMonthArray = monthArray;
    return monthArray;
  }

  buildMonthList() {
    for (int i = 0; i < 12; i++) {
      lst.add(nextEtMonth());
    }
  }

  adjustSundayOffset() {
    String weekStartDay = Utility.getWeekStartDay();
    if (weekStartDay == 'Sun') {
      if (MonthGlobals.showingMonthStartIndex! < 6) {
        MonthGlobals.showingMonthStartIndex = Utility.getZeroOrNumber(MonthGlobals.showingMonthStartIndex) + 1;
      } else {
        MonthGlobals.showingMonthStartIndex = 0;
      }
    }
  }

  getTodayIndex(weekDay, day) {
    weekDay--;
    switch (weekDay) {
      ///MONDAY
      case 0:
        {
          if (day == 1) {
            return MonthGlobals.monthMatrix[0][0];
          } else if (day <= 8) {
            return MonthGlobals.monthMatrix[1][0];
          } else if (day <= 15) {
            return MonthGlobals.monthMatrix[2][0];
          } else if (day <= 22) {
            return MonthGlobals.monthMatrix[3][0];
          } else if (day <= 29) {
            return MonthGlobals.monthMatrix[4][0];
          } else if (day == 30) {
            return MonthGlobals.monthMatrix[5][0];
          }
        }
        break;

      ///TUESDAY
      case 1:
        {
          if (day <= 2) {
            return MonthGlobals.monthMatrix[0][1];
          } else if (day <= 9) {
            return MonthGlobals.monthMatrix[1][1];
          } else if (day <= 16) {
            return MonthGlobals.monthMatrix[2][1];
          } else if (day <= 23) {
            return MonthGlobals.monthMatrix[3][1];
          } else if (day <= 30) {
            return MonthGlobals.monthMatrix[4][1];
          }
        }
        break;

      ///WEDNESDAY
      case 2:
        {
          if (day <= 3) {
            return MonthGlobals.monthMatrix[0][2];
          } else if (day <= 10) {
            return MonthGlobals.monthMatrix[1][2];
          } else if (day <= 17) {
            return MonthGlobals.monthMatrix[2][2];
          } else if (day <= 24) {
            return MonthGlobals.monthMatrix[3][2];
          } else if (day <= 30) {
            return MonthGlobals.monthMatrix[4][2];
          }
        }
        break;

      ///THURSDAY
      case 3:
        {
          if (day <= 4) {
            return MonthGlobals.monthMatrix[0][3];
          } else if (day <= 11) {
            return MonthGlobals.monthMatrix[1][3];
          } else if (day <= 18) {
            return MonthGlobals.monthMatrix[2][3];
          } else if (day <= 25) {
            return MonthGlobals.monthMatrix[3][3];
          } else if (day <= 30) {
            return MonthGlobals.monthMatrix[4][3];
          }
        }
        break;

      ///FRIDAY
      case 4:
        {
          if (day <= 5) {
            return MonthGlobals.monthMatrix[0][4];
          } else if (day <= 12) {
            return MonthGlobals.monthMatrix[1][4];
          } else if (day <= 19) {
            return MonthGlobals.monthMatrix[2][4];
          } else if (day <= 26) {
            return MonthGlobals.monthMatrix[3][4];
          } else if (day <= 30) {
            return MonthGlobals.monthMatrix[4][4];
          }
        }
        break;

      ///SATURDAY
      case 5:
        {
          if (day <= 6) {
            return MonthGlobals.monthMatrix[0][5];
          } else if (day <= 13) {
            return MonthGlobals.monthMatrix[1][5];
          } else if (day <= 20) {
            return MonthGlobals.monthMatrix[2][5];
          } else if (day <= 27) {
            return MonthGlobals.monthMatrix[3][5];
          } else if (day <= 30) {
            return MonthGlobals.monthMatrix[4][5];
          }
        }
        break;

      ///SUNDAY
      case 6:
        {
          if (day <= 7) {
            return MonthGlobals.monthMatrix[0][6];
          } else if (day <= 14) {
            return MonthGlobals.monthMatrix[1][6];
          } else if (day <= 21) {
            return MonthGlobals.monthMatrix[2][6];
          } else if (day <= 28) {
            return MonthGlobals.monthMatrix[3][6];
          } else if (day <= 30) {
            return MonthGlobals.monthMatrix[4][6];
          }
        }
        break;
    }
  }

  getShowingEtMonthLength() {
    int dayLength;
    if (MonthGlobals.etShowingMonth! < 13) {
      dayLength = 30;
    } else {
      if (!MonthModel.isLeapYear(MonthGlobals.etShowingYear)) {
        dayLength = 5;
      } else {
        dayLength = 6;
      }
    }
    return dayLength;
  }

  getEtMonthLength(year, month) {
    int dayLength;
    if (month < 13) {
      dayLength = 30;
    } else {
      if (!MonthModel.isLeapYear(year)) {
        dayLength = 5;
      } else {
        dayLength = 6;
      }
    }
    return dayLength;
  }

  getMonthSequence(startIndex, LocalDate etDate, LocalDate gcDate) async {
    if (eventsList.isEmpty) isEmptyList = true;

    List<Day> monthArray = List.generate(42, (_) => Day());
    int index = startIndex;

    ///From etDay to 30th of current month
    for (int day = etDate.day!; day <= 30; day++, index++) {
      monthArray[index].etDay = day;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///Start of next month days
    for (int day = 1; index < monthArray.length; day++, index++) {
      monthArray[index].etDay = day;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///From etDay to first day of current month
    for (int? day = etDate.day! - 1, i = startIndex - 1; day! >= 1; day--, i--) {
      monthArray[i!].etDay = day;
      monthArray[i].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///End of previous month days
    for (int day = 30, i = startIndex - etDate.day; i >= 0; i--, day--) {
      if (MonthGlobals.etShowingMonth! > 1) {
        monthArray[i].etDay = day;
        monthArray[i].geezDay = GeezNumbers.geezNumbers[day - 1];
      } else {
        monthArray[i].geezDay = "0";
      }
    }

    getGcMonthSequence(startIndex, etDate, gcDate, monthArray);

    return monthArray;
  }

  getGcMonthSequence(startIndex, LocalDate etDate, LocalDate gcDate, List<Day> monthArray) {
    bool isGcMonthEndsForward = gcDate.day! - etDate.day! > 0 ? true : false;

    int monthEnd = isGcMonthEndsForward
        ? MonthModel.getDaysInGcMonth(gcDate.month! - 1, gcDate.year)
        : MonthModel.getDaysInGcMonth(gcDate.month! - 1, gcDate.year);

    if (isGcMonthEndsForward) {
      int gcDay = Utility.getZeroOrNumber(gcDate.day);

      ///Days from starting to the first index cell
      for (int day = gcDay, i = startIndex; i /*!*/ >= 0; i--, day--) {
        monthArray[i].gcDay = day;
      }

      int idx = startIndex + 1;

      ///Days from next of starting day of the month to end of the same month
      for (int day = gcDate.day! + 1; day <= monthEnd; day++, idx++) {
        monthArray[idx].gcDay = day;
      }

      for (int day = 1; idx < monthArray.length; idx++, day++) {
        monthArray[idx].gcDay = day;
      }
    }
  }

  getShowingMonthSequence() {
    List<Day> monthArray = List.generate(42, (_) => Day());
    int index = MonthGlobals.showingMonthStartIndex!;

    LocalDate etDate = LocalDate.date(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, 1);
    LocalDate gcDate = MonthModel.toGc(year: MonthGlobals.etShowingYear!, month: MonthGlobals.etShowingMonth!, day: 1)!;

    int etDayLength = getShowingEtMonthLength();

    ///From etDay to 30th of current month
    for (int day = etDate.day!; day <= etDayLength; day++, index++) {
      monthArray[index].etDay = day;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///Start of next month days
    for (int day = 1; index < monthArray.length; day++, index++) {
      monthArray[index].etDay = day;

      if (day == 31) day = 1;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
      if (etDate.month == 12 && index > 34 && day > getEtMonthLength(etDate.year, etDate.month! + 1)) {
        day = 1;
        monthArray[index].etDay = day;
        monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
      }

      if (etDate.month == 13 && day < 31) {
        // day=1;
        monthArray[index].etDay = day;
        monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
      }
    }

    ///From etDay to first day of current month
    for (int day = etDate.day! - 1, i = MonthGlobals.showingMonthStartIndex! - 1; day >= 1; day--, i--) {
      monthArray[i].etDay = day;
      monthArray[i].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///End of previous month days
    for (int day = 30, i = MonthGlobals.showingMonthStartIndex! - etDate.day!; i >= 0; i--, day--) {
      if (MonthGlobals.etShowingMonth! > 1) {
        monthArray[i].etDay = day;
        monthArray[i].geezDay = GeezNumbers.geezNumbers[day - 1];
      } else {
        monthArray[i].geezDay = "0";
      }
    }
    getGcMonthSequence(MonthGlobals.showingMonthStartIndex, etDate, gcDate, monthArray);
    return monthArray;
  }

  getTodayMonthSequence() {
    List<Day> monthArray = List.generate(42, (_) => Day());
    int index = MonthGlobals.todayIndex!;

    MonthGlobals.etShowingMonth = MonthGlobals.etNow!.month;
    MonthGlobals.etShowingYear = MonthGlobals.etNow!.year;
    int etMonthLength = getShowingEtMonthLength();

    ///From etDay to 30th of current month
    for (int day = MonthGlobals.etNow!.day!; day <= etMonthLength; day++, index++) {
      monthArray[index].etDay = day;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///Start of next month days
    for (int day = 1; index < monthArray.length; day++, index++) {
      monthArray[index].etDay = day;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///From etDay to first day of current month
    for (int day = MonthGlobals.etNow!.day! - 1, i = MonthGlobals.todayIndex! - 1; day >= 1; day--, i--) {
      monthArray[i].etDay = day;
      monthArray[i].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///End of previous month days
    for (int day = 30, i = MonthGlobals.todayIndex! - MonthGlobals.etNow!.day!; i >= 0; i--, day--) {
      monthArray[i].etDay = day;
      monthArray[i].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    getGcMonthSequence(MonthGlobals.todayIndex, MonthGlobals.etNow!, MonthGlobals.gcNow!, monthArray);

    return monthArray;
  }
}
