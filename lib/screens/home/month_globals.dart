import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

import 'model/day_model.dart';
import '../../shared/models/local_date_model.dart';

class MonthGlobals {
  ///Month grid matrix, must be initialized once in app session
  static late var monthMatrix;
  static int? todayIndex;
  static int? today;
  static int? showingMonthStartIndex;
  static List<Day>? currentMonthArray;
  static List<Day>? showingMonthArray;
  static int? etNowDay, etNowMonth, etNowYear, gcNowDay, gcNowMonth, gcNowYear, etShowingMonth, etShowingYear;
  static LocalDate? etNow;
  static LocalDate? gcNow;
  static LocalDate? etShowing;
  static LocalDate? gcShowing;

  ///Initialize build context when app starts once
  static BuildContext? context;

  static List<String?> etMonthsLong = [
    AppLocalizations.of(context!)!.september,
    AppLocalizations.of(context!)!.october,
    AppLocalizations.of(context!)!.november,
    AppLocalizations.of(context!)!.december,
    AppLocalizations.of(context!)!.january,
    AppLocalizations.of(context!)!.february,
    AppLocalizations.of(context!)!.march,
    AppLocalizations.of(context!)!.april,
    AppLocalizations.of(context!)!.may,
    AppLocalizations.of(context!)!.june,
    AppLocalizations.of(context!)!.july,
    AppLocalizations.of(context!)!.august,
    AppLocalizations.of(context!)!.pagume,
  ];

  static List<String?> etMonthsShort = [
    AppLocalizations.of(context!)!.sep,
    AppLocalizations.of(context!)!.oct,
    AppLocalizations.of(context!)!.nov,
    AppLocalizations.of(context!)!.dec,
    AppLocalizations.of(context!)!.jan,
    AppLocalizations.of(context!)!.feb,
    AppLocalizations.of(context!)!.mar,
    AppLocalizations.of(context!)!.apr,
    AppLocalizations.of(context!)!.mayShort,
    AppLocalizations.of(context!)!.jun,
    AppLocalizations.of(context!)!.jul,
    AppLocalizations.of(context!)!.aug,
    AppLocalizations.of(context!)!.pag,
  ];

  static List<String> gcMonthsLong = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static List<String> gcMonthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static List<String?> etDayHeaderFirstCharacter = [
    AppLocalizations.of(context!)!.mn,
    AppLocalizations.of(context!)!.tu,
    AppLocalizations.of(context!)!.wd,
    AppLocalizations.of(context!)!.th,
    AppLocalizations.of(context!)!.fr,
    AppLocalizations.of(context!)!.st,
    AppLocalizations.of(context!)!.sn,
  ];

  static List<String?> etDayHeaderFirstCharacterSundayFirst = [
    AppLocalizations.of(context!)!.sn,
    AppLocalizations.of(context!)!.mn,
    AppLocalizations.of(context!)!.tu,
    AppLocalizations.of(context!)!.wd,
    AppLocalizations.of(context!)!.th,
    AppLocalizations.of(context!)!.fr,
    AppLocalizations.of(context!)!.st,
  ];

  static List<String?> etWeekNamesLong = [
    AppLocalizations.of(context!)!.monday,
    AppLocalizations.of(context!)!.tuesday,
    AppLocalizations.of(context!)!.wednesday,
    AppLocalizations.of(context!)!.thursday,
    AppLocalizations.of(context!)!.friday,
    AppLocalizations.of(context!)!.saturday,
    AppLocalizations.of(context!)!.sunday,
  ];

  static List<String?> etWeekNamesShort = [
    AppLocalizations.of(context!)!.mon,
    AppLocalizations.of(context!)!.tue,
    AppLocalizations.of(context!)!.wed,
    AppLocalizations.of(context!)!.thu,
    AppLocalizations.of(context!)!.fri,
    AppLocalizations.of(context!)!.sat,
    AppLocalizations.of(context!)!.sun,
  ];

  static List<String> timePeriodEt = [AppLocalizations.of(context!)!.morning, AppLocalizations.of(context!)!.afternoon];

  static void reinitializeGlobalsWithSelectedLanguage(BuildContext ctx) {
    context = ctx;

    etMonthsLong = [
      AppLocalizations.of(context!)!.september,
      AppLocalizations.of(context!)!.october,
      AppLocalizations.of(context!)!.november,
      AppLocalizations.of(context!)!.december,
      AppLocalizations.of(context!)!.january,
      AppLocalizations.of(context!)!.february,
      AppLocalizations.of(context!)!.march,
      AppLocalizations.of(context!)!.april,
      AppLocalizations.of(context!)!.may,
      AppLocalizations.of(context!)!.june,
      AppLocalizations.of(context!)!.july,
      AppLocalizations.of(context!)!.august,
      AppLocalizations.of(context!)!.pagume,
    ];

    etMonthsShort = [
      AppLocalizations.of(context!)!.sep,
      AppLocalizations.of(context!)!.oct,
      AppLocalizations.of(context!)!.nov,
      AppLocalizations.of(context!)!.dec,
      AppLocalizations.of(context!)!.jan,
      AppLocalizations.of(context!)!.feb,
      AppLocalizations.of(context!)!.mar,
      AppLocalizations.of(context!)!.apr,
      AppLocalizations.of(context!)!.mayShort,
      AppLocalizations.of(context!)!.jun,
      AppLocalizations.of(context!)!.jul,
      AppLocalizations.of(context!)!.aug,
      AppLocalizations.of(context!)!.pag,
    ];

    etDayHeaderFirstCharacter = [
      AppLocalizations.of(context!)!.mn,
      AppLocalizations.of(context!)!.tu,
      AppLocalizations.of(context!)!.wd,
      AppLocalizations.of(context!)!.th,
      AppLocalizations.of(context!)!.fr,
      AppLocalizations.of(context!)!.st,
      AppLocalizations.of(context!)!.sn,
    ];

    etDayHeaderFirstCharacterSundayFirst = [
      AppLocalizations.of(context!)!.sn,
      AppLocalizations.of(context!)!.mn,
      AppLocalizations.of(context!)!.tu,
      AppLocalizations.of(context!)!.wd,
      AppLocalizations.of(context!)!.th,
      AppLocalizations.of(context!)!.fr,
      AppLocalizations.of(context!)!.st,
    ];

    etWeekNamesLong = [
      AppLocalizations.of(context!)!.monday,
      AppLocalizations.of(context!)!.tuesday,
      AppLocalizations.of(context!)!.wednesday,
      AppLocalizations.of(context!)!.thursday,
      AppLocalizations.of(context!)!.friday,
      AppLocalizations.of(context!)!.saturday,
      AppLocalizations.of(context!)!.sunday,
    ];

    etWeekNamesShort = [
      AppLocalizations.of(context!)!.mon,
      AppLocalizations.of(context!)!.tue,
      AppLocalizations.of(context!)!.wed,
      AppLocalizations.of(context!)!.thu,
      AppLocalizations.of(context!)!.fri,
      AppLocalizations.of(context!)!.sat,
      AppLocalizations.of(context!)!.sun,
    ];

    timePeriodEt = [AppLocalizations.of(context!)!.morning, AppLocalizations.of(context!)!.afternoon];
  }

  static List<String> gcWeekNamesLong = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  static List<String> gcWeekNamesShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  static List<String> timePeriodGc = ["AM", "PM"];

  static String getCurrentDateEt([separator, format]) {
    return "${etMonthsLong[etNow!.month! - 1]} ${etNow!.day}, ${etNow!.year}";
  }

  static String getCurrentDateGc([separator, format]) {
    return "${etMonthsLong[gcNow!.month! - 1]} ${gcNow!.day}, ${gcNow!.year}";
  }

  static String getCurrentTimeEtOld() {
    DateTime now = DateTime.now();
    String amPm = now.hour >= 12 ? "PM" : "AM";
    debugPrint("------ ~~$amPm");

    return "${now.hour < 10 ? "0${now.hour}" : now.hour} : ${now.minute > 9 ? now.minute : "0${now.minute}"} : $amPm";
  }

  static String getCurrentTimeEt(DateTime now) {
    bool isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    int gcHour = now.hour;
    int etHour;
    if (gcHour < 7) {
      etHour = gcHour + 6;
    } else if (gcHour < 19) {
      etHour = gcHour - 6;
    } else {
      etHour = gcHour - 18;
    }
    String amPm = now.hour < 12 ? timePeriodEt.first : timePeriodEt.last;

    String result;
    if (isGeezNumbers) {
      result = "${GeezNumbers.geezNumbers[etHour - 1]} : ${GeezNumbers.geezNumbers[now.minute - 1]} : $amPm";
    } else {
      result = "${etHour < 10 ? "0$etHour" : etHour} : ${now.minute > 9 ? now.minute : "0${now.minute}"} : $amPm";
    }
    return result;
  }

  static String getCurrentTimeGc(DateTime now) {
    String amPm = now.hour < 12 ? "AM" : "PM";
    int hour = now.hour > 12 ? now.hour - 12 : now.hour;
    String hourString = hour < 10 ? "0$hour" : "$hour";
    return "$hourString : ${now.minute > 9 ? now.minute : "0${now.minute}"} : $amPm";
  }
}
