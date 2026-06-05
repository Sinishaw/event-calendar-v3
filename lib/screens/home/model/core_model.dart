import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';

class MonthModel {
  static LocalDate? toEc({required int year, required int month, required int day}) {
    if (year < 1900 || month < 1 || day < 1) return null;
    month--;
    int? convertedDay, convertedMonth, convertedYear;
    LocalDate convertedDate;
    int ecLeapEffect = isLeapYear(year - 9) ? 1 : 0; //Checks current -1 year
    int ecLeapEffect2 = isLeapYear(year - 8) ? 1 : 0; //Checks the current year
    if (month == 0) //jan
    {
      convertedYear = year - 8;
      if (day <= (8 + ecLeapEffect)) {
        convertedMonth = month + 4; //tahissas
        convertedDay = (day + 22 - ecLeapEffect);
      } else {
        convertedMonth = month + 5; //thir
        if (ecLeapEffect == 1) {
          convertedDay = day - 9;
        } else {
          convertedDay = day - 8;
        }
      }
    } else if (month == 1) //feb
    {
      convertedYear = year - 8;
      if (day <= (7 + ecLeapEffect)) {
        convertedMonth = month + 4; //thir
        convertedDay = (day + 23 - ecLeapEffect);
      } else {
        //this else statement doesn't need to consider GC Leap year, since it doesn't make any difference on conversion
        convertedMonth = month + 5; //yekatit
        if (ecLeapEffect == 1) {
          convertedDay = day - 8;
        } else {
          //1ce in 4 year feb leap it self and be 29 rather 28 in this else statement
          convertedDay = day - 7;
        }
      }
    } else if (month == 2) //mar
    {
      //both ec and gc leapeffects returns one here so either feb 29 or 28 it ends with ec 21 and march starts from 22
      //so in this case the ec leap effect affects no more month before this end of year, since it is rejected by gc leap effect
      convertedYear = year - 8;
      if (day <= 9) {
        convertedMonth = month + 4; //yekatit
        convertedDay = (day + 21);
      } else {
        convertedMonth = month + 5; //megabit
        convertedDay = day - 9;
      }
    } else if (month == 3) //apr
    {
      convertedYear = year - 8;
      if (day <= 8) {
        convertedMonth = month + 4; //megabit
        convertedDay = (day + 22);
      } else {
        convertedMonth = month + 5; //miyaziya
        convertedDay = day - 8;
      }
    } else if (month == 4) //may
    {
      convertedYear = year - 8;
      if (day <= 8) {
        convertedMonth = month + 4; //miyaziya
        convertedDay = (day + 22);
      } else {
        convertedMonth = month + 5; //ginbot
        convertedDay = day - 8;
      }
    } else if (month == 5) //jun
    {
      convertedYear = year - 8;
      if (day <= 7) {
        convertedMonth = month + 4; //ginbot
        convertedDay = (day + 23);
      } else {
        convertedMonth = month + 5; //sene
        convertedDay = day - 7;
      }
    } else if (month == 6) //jul
    {
      convertedYear = year - 8;
      if (day <= 7) {
        convertedMonth = month + 4; //sene
        convertedDay = (day + 23);
      } else {
        convertedMonth = month + 5; //hamle
        convertedDay = day - 7;
      }
    } else if (month == 7) //aug
    {
      convertedYear = year - 8;
      if (day <= 6) {
        convertedMonth = month + 4; //hamle
        convertedDay = (day + 24);
      } else {
        convertedMonth = month + 5; //nehasse
        convertedDay = day - 6;
      }
    } else if (month == 8) //sep
    {
      if (day <= 5) {
        convertedYear = year - 8;
        convertedMonth = month + 4; //nehasse
        convertedDay = (day + 25);
      } else if (day >= 6 && day <= (10 + ecLeapEffect2)) {
        convertedYear = year - 8;
        convertedMonth = month + 5; //Puagme
        convertedDay = day - 5;
      } else {
        convertedYear = year - 7;
        convertedMonth = month - 7; //Meskerem
        if (ecLeapEffect2 == 1) {
          convertedDay = day - 11;
        } else {
          convertedDay = day - 10;
        }
      }
    } else if (month == 9) //oct
    {
      convertedYear =
          year - 7; // and consider that there is no gc leap arround this month so it will continue until it gets it.
      if (day <= (10 + ecLeapEffect2)) {
        convertedMonth = month - 8; //meskerem
        if (ecLeapEffect2 == 1) {
          convertedDay = day + 19;
        } else {
          convertedDay = day + 20;
        }
      } else {
        convertedMonth = month - 7; //tikimt
        if (ecLeapEffect2 == 1) {
          convertedDay = day - 11;
        } else {
          convertedDay = day - 10;
        }
      }
    } else if (month == 10) //nov
    {
      convertedYear =
          year - 7; // and consider that there is no gc leap arround this month so it will continue until it gets it.
      if (day <= (9 + ecLeapEffect2)) {
        convertedMonth = month - 8; //tikimt
        if (ecLeapEffect2 == 1) {
          convertedDay = day + 20;
        } else {
          convertedDay = day + 21;
        }
      } else {
        convertedMonth = month - 7; //hidar
        if (ecLeapEffect2 == 1) {
          convertedDay = day - 10;
        } else {
          convertedDay = day - 9;
        }
      }
    } else if (month == 11) //dec
    {
      convertedYear =
          year - 7; // and consider that there is no gc leap arround this month so it will continue until it gets it.
      if (day <= (9 + ecLeapEffect2)) {
        convertedMonth = month - 8; //hidar
        if (ecLeapEffect2 == 1) {
          convertedDay = day + 20;
        } else {
          convertedDay = day + 21;
        }
      } else {
        convertedMonth = month - 7; //tahissas
        if (ecLeapEffect2 == 1) {
          convertedDay = day - 10;
        } else {
          convertedDay = day - 9;
        }
      }
    }
    convertedDate = LocalDate.date(convertedYear, convertedMonth, convertedDay);
    return convertedDate;
  }

  static LocalDate? toGc({required int year, required int month, required int day}) {
    if (year < 1900 || month < 1 || day < 0) return null;
    month--;
    int? convertedDay, convertedMonth, convertedYear;
    int leapEffect = isLeapYear(year - 1) ? 1 : 0;
    int gcLeapEffect;
    LocalDate convertedDate;

    if (month == 0) //if Meskerem
    {
      convertedYear = year + 7;
      if (day <= (20 - leapEffect)) {
        convertedMonth = month + 9; //sep
        convertedDay = day + 10 + leapEffect;
      } else {
        convertedMonth = month + 10; //oct
        if (leapEffect == 1) {
          convertedDay = day - 19;
        } else {
          convertedDay = day - 20;
        }
      }
    } else if (month == 1) //if Tikimt
    {
      convertedYear = year + 7;
      if (day <= (21 - leapEffect)) {
        convertedMonth = month + 9; //oct
        convertedDay = day + 10 + leapEffect;
      } else {
        convertedMonth = month + 10; //nov
        if (leapEffect == 1) {
          convertedDay = day - 20;
        } else {
          convertedDay = day - 21;
        }
      }
    } else if (month == 2) //if Hidar
    {
      convertedYear = year + 7;
      if (day <= (21 - leapEffect)) {
        convertedMonth = month + 9; //nov
        convertedDay = day + 9 + leapEffect;
      } else {
        convertedMonth = month + 10; //dec
        if (leapEffect == 1) {
          convertedDay = day - 20;
        } else {
          convertedDay = day - 21;
        }
      }
    } else if (month == 3) //if Tahissas
    {
      if (day <= (22 - leapEffect)) {
        convertedYear = year + 7; //year is ready to switch
        convertedMonth = month + 9; //dec
        convertedDay = day + 9 + leapEffect;
      } else {
        convertedYear = year + 8; //year is switched
        convertedMonth = month - 2; //JAN /*HAPPY NEW YEAR*/
        if (leapEffect == 1) {
          convertedDay = day - 21;
        } else {
          convertedDay = day - 22;
        }
      }
    } else if (month == 4) //if Thir
    {
      convertedYear = year + 8;
      if (day <= (23 - leapEffect)) {
        convertedMonth = month - 3; //jan
        convertedDay = day + 8 + leapEffect;
      } else {
        convertedMonth = month - 2; //feb /*April the fool*/
        if (leapEffect == 1) {
          convertedDay = day - 22;
        } else {
          convertedDay = day - 23;
        }
      }
    } else if (month == 5) //if Yekatit
    {
      convertedYear = year + 8;
      gcLeapEffect = isGcYearLeap(convertedYear) ? 1 : 0;
      if (day <= ((21 + gcLeapEffect) - leapEffect)) {
        convertedMonth = month - 3; //feb
        convertedDay = day + 7 + leapEffect;
      } else {
        convertedMonth = month - 2; //mar
        if (leapEffect == 1) {
          convertedDay = day - (20 + gcLeapEffect);
        } else {
          convertedDay = day - (21 + gcLeapEffect);
        }
      }
    } else if (month == 6) //if Megabit
    {
      convertedYear = year + 8;
      if (day <= 22) {
        convertedMonth = month - 3; //mar
        convertedDay = day + 9;
      } else {
        convertedMonth = month - 2; //apr
        convertedDay = day - 22;
      }
    } else if (month == 7) //if Miyazia
    {
      convertedYear = year + 8;
      if (day <= 22) {
        convertedMonth = month - 3; //apr
        convertedDay = day + 8;
      } else {
        convertedMonth = month - 2; //may
        convertedDay = day - 22;
      }
    } else if (month == 8) //if Ginbot
    {
      convertedYear = year + 8;
      if (day <= 23) {
        convertedMonth = month - 3; //may
        convertedDay = day + 8;
      } else {
        convertedMonth = month - 2; //jun
        convertedDay = day - 23;
      }
    } else if (month == 9) //if Sene
    {
      convertedYear = year + 8;
      if (day <= 23) {
        convertedMonth = month - 3; //jun
        convertedDay = day + 7;
      } else {
        convertedMonth = month - 2; //jul
        convertedDay = day - 23;
      }
    } else if (month == 10) //if Hamle
    {
      convertedYear = year + 8;
      if (day <= 24) {
        convertedMonth = month - 3; //jul
        convertedDay = day + 7;
      } else {
        convertedMonth = month - 2; //aug
        convertedDay = day - 24;
      }
    } else if (month == 11) //if Nehasse
    {
      convertedYear = year + 8;
      if (day <= 25) {
        convertedMonth = month - 3; //aug
        convertedDay = day + 6;
      } else {
        convertedMonth = month - 2; //sep
        convertedDay = day - 25;
      }
    } else if (month == 12) //if Puagme /*Ethiopian's alone month*/
    {
      convertedYear = year + 8;
      convertedMonth = month - 3; //sep
      convertedDay = day + 5;
    }
    convertedDate = LocalDate.date(convertedYear, convertedMonth, convertedDay);
    return convertedDate;
  }

  static isLeapYear(year) {
    if ((year + 1) % 4 == 0) return true;
    return false;
  }

  static isGcYearLeap(year) {
    if (year % 4 == 0) {
      if (year % 100 != 0) {
        return true;
      } else if (year % 400 == 0) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  static getDaysInGcMonth(month, year) {
    final List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month != GcMonth.February.index) {
      return daysInMonth[month];
    } else {
      if (!isGcYearLeap(year)) return 28;
      return 29;
    }
  }
}
