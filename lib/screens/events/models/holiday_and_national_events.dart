import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:flutter/material.dart';

import 'fixed_national_events_detail.dart';

class HolidayAndNationalEvents {
  static List<FixedNationalEventsDetail> getAllYearlyHolidays(int year) {
    List<FixedNationalEventsDetail> allNationalAndHolidayLists = [];

    List<FixedNationalEventsDetail> christianNoneFixedHolidays = _etEasterCalculation(year);
    List<FixedNationalEventsDetail> ethiopianFixedHolidays = _getFixedEthiopianHoliday(year);
    List<FixedNationalEventsDetail> lunarHolidays = _getLunarHoliday(year);

    allNationalAndHolidayLists.addAll(christianNoneFixedHolidays);
    allNationalAndHolidayLists.addAll(ethiopianFixedHolidays);

    ///prior 1990 EC, Luar holidays not showing due to creating none accurate day marks
    if (year > 1990) {
      allNationalAndHolidayLists.addAll(lunarHolidays);
    }
    allNationalAndHolidayLists.sort((a, b) => a.gcDate!.compareTo(b.gcDate!));

    return allNationalAndHolidayLists;
  }

  static List<FixedNationalEventsDetail> getMonthlyHolidays(int year, int? month) {
    List<FixedNationalEventsDetail> allYearlyList = [];
    allYearlyList = getAllYearlyHolidays(year);

    List<FixedNationalEventsDetail> monthlyNationalEvents = [];

    if (allYearlyList.isNotEmpty) {
      monthlyNationalEvents.addAll(allYearlyList.where((element) => element.ecLocalDate!.month == month));
    }
    if (monthlyNationalEvents.isNotEmpty) {
      monthlyNationalEvents.sort((a, b) => a.gcDate!.compareTo(b.gcDate!));
    }
    return monthlyNationalEvents;
  }

  static List<FixedNationalEventsDetail> getDailHolidays(int year, int? month, day) {
    List<FixedNationalEventsDetail> allMonthlyList = [];
    allMonthlyList = getMonthlyHolidays(year, month);

    List<FixedNationalEventsDetail> dayNationalEvents = [];

    if (allMonthlyList.isNotEmpty) {
      dayNationalEvents.addAll(allMonthlyList.where((element) => element.ecLocalDate!.day == day));
    }
    if (dayNationalEvents.isNotEmpty) dayNationalEvents.sort((a, b) => a.gcDate!.compareTo(b.gcDate!));

    return dayNationalEvents;
  }

  static List<FixedNationalEventsDetail> _etEasterCalculation(int year) {
    List<FixedNationalEventsDetail> list = [];

    int wenber, ameteAlem, medeb, mitkDay, tewsak, bealeMitkMonth, neneweStartsAt, mebajaHammer;
    int sikletDay, tinsaeDay;
    ameteAlem = (year + 5500);
    medeb = ameteAlem % 19;

    if (medeb == 0) medeb = 19;

    wenber = medeb - 1;

    mitkDay = (wenber * 19) % 30;
    if (mitkDay > 14) {
      bealeMitkMonth = 1; //meskerem
    } else {
      bealeMitkMonth = 2; //tikimt
    }

    ///TODO: If mitk day is zero, then adjust to 18
    // if (mitkDay == 0) mitkDay = ???;

    LocalDate mitkGcLocal = MonthModel.toGc(year: year, month: bealeMitkMonth, day: mitkDay)!;
    DateTime mitkGcDate = DateTime(mitkGcLocal.year!, mitkGcLocal.month!, mitkGcLocal.day!);

    switch (WeekDays.values[mitkGcDate.weekday]) {
      case WeekDays.saturday:
        {
          tewsak = 8;
          break;
        }
      case WeekDays.sunday:
        {
          tewsak = 7;
          break;
        }
      case WeekDays.monday:
        {
          tewsak = 6;
          break;
        }
      case WeekDays.tuesday:
        {
          tewsak = 5;
          break;
        }
      case WeekDays.wednesday:
        {
          tewsak = 4;
          break;
        }
      case WeekDays.thursday:
        {
          tewsak = 3;
          break;
        }
      default:
        {
          tewsak = 2;
          break;
        }
    }
    mebajaHammer = tewsak + mitkDay; // nenewe starting day
    if (bealeMitkMonth == 1) {
      if (mebajaHammer <= 30) {
        neneweStartsAt = 4; //tir
      } else {
        mebajaHammer = mebajaHammer - 30;
        neneweStartsAt = 5; //yekatit
      }
    } else {
      neneweStartsAt = 5; //yekatit
    }
    int sikletMonth = neneweStartsAt + 2;
    int esterMonth = neneweStartsAt + 2;

    sikletDay = mebajaHammer + 7;
    tinsaeDay = mebajaHammer + 9;
    if (sikletDay > 30) {
      sikletDay = sikletDay - 30;
      sikletMonth = sikletMonth + 1;
    }
    if (tinsaeDay > 30) {
      tinsaeDay = tinsaeDay - 30;
      esterMonth = esterMonth + 1;
    }

    list = getChristianNonFixedHolidayList(year, sikletMonth, sikletDay, esterMonth, tinsaeDay);
    return list;
  }

  static getChristianNonFixedHolidayList(year, sikletMonth, sikletDay, fasikaMonth, fasikaDay) {
    List<FixedNationalEventsDetail> list = [];
    HolidayType type = HolidayType.christian;
    sikletMonth += 1;
    fasikaMonth += 1;

    ///Siklet
    FixedNationalEventsDetail sk = _getHolidayDetail(year, sikletMonth, sikletDay, EthiopianFixedHoliday.siklet, type);

    ///Fasika
    FixedNationalEventsDetail fs = _getHolidayDetail(year, fasikaMonth, fasikaDay, EthiopianFixedHoliday.fasika, type);

    ///Genna
    int gennaDay = !MonthModel.isLeapYear(year - 1) ? 29 : 28;
    int gennaMonth = 4;
    FixedNationalEventsDetail gn = _getHolidayDetail(year, gennaMonth, gennaDay, EthiopianFixedHoliday.genna, type);

    list.addAll([sk, fs, gn]);
    debugPrint("------ Easter holiday list count: ${list.length}");
    return list;
  }

  static _getFixedEthiopianHoliday(year) {
    List<FixedNationalEventsDetail> list = [];
    HolidayType cristianType = HolidayType.christian;
    HolidayType federalType = HolidayType.federal;
    HolidayType specialType = HolidayType.others;

    ///New Year
    int nyM = 1;
    int nyD = 1;
    FixedNationalEventsDetail ny = _getHolidayDetail(year, nyM, nyD, EthiopianFixedHoliday.newYear, specialType);

    ///Meskel
    int msM = 1;
    int msD = 17;
    FixedNationalEventsDetail ms = _getHolidayDetail(year, msM, msD, EthiopianFixedHoliday.meskel, cristianType);

    ///Timket
    int tmM = 5;
    int tmD = 11;
    FixedNationalEventsDetail tm = _getHolidayDetail(year, tmM, tmD, EthiopianFixedHoliday.timket, cristianType);

    ///Adwa
    int adM = 6;
    int adD = 23;

    FixedNationalEventsDetail ad = _getHolidayDetail(year, adM, adD, EthiopianFixedHoliday.adwa, federalType);

    ///Arbegnoch
    int arM = 8;
    int arD = 27;

    FixedNationalEventsDetail ar = _getHolidayDetail(year, arM, arD, EthiopianFixedHoliday.arbegnoch, federalType);

    ///Labaderoch
    int lbM = 8;
    int lbD = 23;

    FixedNationalEventsDetail lb = _getHolidayDetail(year, lbM, lbD, EthiopianFixedHoliday.labaderoch, federalType);

    ///Ginbot 20
    int gnM = 9;
    int gnD = 20;

    FixedNationalEventsDetail gn = _getHolidayDetail(year, gnM, gnD, EthiopianFixedHoliday.ginbot20, federalType);

    list.addAll([ny, ms, tm, ad, ar, lb]);
    if (year > 1982) list.add(gn);
    return list;
  }

  static _getLunarHoliday(year) {
    List<FixedNationalEventsDetail> list = [];
    FixedNationalEventsDetail ft = _lunarHolyDayDetail(year, EthiopianFixedHoliday.eidAlFitur);
    FixedNationalEventsDetail mw = _lunarHolyDayDetail(year, EthiopianFixedHoliday.mewlid);
    FixedNationalEventsDetail ad = _lunarHolyDayDetail(year, EthiopianFixedHoliday.eidAlAdha);

    list.addAll([ft, mw, ad]);
    return list;
  }

  static FixedNationalEventsDetail _lunarHolyDayDetail(int selectedYear, EthiopianFixedHoliday holiday) {
    int daysInAMonth, dayCount = 0, pagumeValue;
    double lunarLeap = 0;
    String holyDay = "";
    FixedNationalEventsDetail lunarHolidayDetail = FixedNationalEventsDetail();
    int dayDiff = 0, initialYear = 0;
    if (holiday == EthiopianFixedHoliday.mewlid) {
      initialYear = 1988;
      dayDiff = 321;
    } else if (holiday == EthiopianFixedHoliday.eidAlFitur) {
      initialYear = 1989;
      dayDiff = 151;
    } else if (holiday == EthiopianFixedHoliday.eidAlAdha) {
      initialYear = 1991;
      dayDiff = 199;
    }
    for (int year = initialYear; year <= 2050; year++) {
      pagumeValue = MonthModel.isLeapYear(year) ? 6 : 5;

      for (int month = 0; month < 13; month++) {
        if (month == 12) {
          daysInAMonth = pagumeValue;
        } else {
          daysInAMonth = 30;
        }
        for (int day = 1; day <= daysInAMonth; day++) {
          dayCount++;

          if ((dayCount - dayDiff) % 354 == 0) {
            if (/*Math.floor*/ (lunarLeap + 0.37).floor() > lunarLeap) day++;
            lunarLeap = lunarLeap + 0.37;
            if (year == selectedYear) {
              holyDay = "$day / ${month + 1} / $year";
              lunarHolidayDetail = _getHolidayDetail(year, month + 1, day, holiday, HolidayType.muslim);
            }
          }
        }
      }
    }
    return lunarHolidayDetail;
  }

  static FixedNationalEventsDetail _getHolidayDetail(
      year, month, day, EthiopianFixedHoliday holiday, HolidayType type) {
    String holidayRef = holiday.toString().split('.').last;

    LocalDate gcLocalDate = MonthModel.toGc(year: year, month: month, day: day)!;
    DateTime gcDate = DateTime(gcLocalDate.year!, gcLocalDate.month!, gcLocalDate.day!);
    LocalDate etLocalDate = LocalDate.detailed(year, month, day, gcDate.weekday);

    FixedNationalEventsDetail holidayDetail = FixedNationalEventsDetail(
        nationalDayRef: holidayRef,
        name: Globals.ethiopianFixedHolidays[holiday.index],
        description: Globals.ethiopianFixedHolidaysDescription[holiday.index],
        gcDate: gcDate,
        gcLocalDate: gcLocalDate,
        ecLocalDate: etLocalDate,
        holidayType: type,
        imageLocation: "" //get it from some dynamic place based on holiday type
        );
    return holidayDetail;
  }
}
