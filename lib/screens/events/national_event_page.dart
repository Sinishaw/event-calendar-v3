// ignore_for_file: avoid_unnecessary_containers

import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/events/models/holiday_and_national_events.dart';
import 'package:event_calendar_v2/screens/events/widgets/national_day_article_page.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/screens/year/widgets/year_picker_dialog.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'models/fixed_national_events_detail.dart';

class NationalEventsPage extends StatefulWidget {
  static const String routeName = '/national_events';
  const NationalEventsPage({super.key});

  @override
  State<NationalEventsPage> createState() => _NationalEventsPageState();
}

class _NationalEventsPageState extends State<NationalEventsPage> {
  int? _year = MonthGlobals.etNowYear;
  late bool isGeezNumbers;

  List<FixedNationalEventsDetail> _getAllHolidaysInYear({required int year}) {
    return HolidayAndNationalEvents.getAllYearlyHolidays(year);
  }

  _openDetailPage(BuildContext context, FixedNationalEventsDetail eventsDetail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          FirebaseLogger.logGlobalScreenView(LogScreen.NationalDayArticles.index);
          FirebaseLogger.logCompanyScreenView(LogScreen.NationalDayArticles.index);
          return NationalDayArticlePage(
            nationalDayRef: eventsDetail.nationalDayRef,
            holidayName: eventsDetail.name,
          );
        },
      ),
    );
  }

  updateYearCallback(int year) {
    _year = year;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<FixedNationalEventsDetail> holidayList = _getAllHolidaysInYear(year: _year!);
    Color color = Theme.of(context).primaryColor;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Prev',
            onPressed: () {
              _year = Utility.getZeroOrNumber(_year) - 1;
              if (_year! < 1900) {
                _year = 2050;
              }
              setState(() {});
            },
          ),
          title: Center(
              child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => YearPickerDialog(year: _year, callback: updateYearCallback),
                    );
                    debugPrint("------ You have tapped year : $_year");
                  },
                  child: Text(
                      "${isGeezNumbers ? GeezNumbers.geezYears[_year! - 1900] : _year} - ${AppLocalizations.of(context)!.nationalDays} "))),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: 'Next',
              onPressed: () {
                _year = Utility.getZeroOrNumber(_year) + 1;
                if (_year! > 2050) {
                  _year = 1900;
                }
                setState(() {});
              },
            ),
          ],
        ),
        body: AnimationLimiter(
          child: ListView.builder(
            itemCount: holidayList.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: SlideAnimation(
                    child: Card(
                      elevation: 0,
                      color: Colors.transparent,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Builder(
                                builder: (context) {
                                  return Opacity(
                                    opacity: 0.7,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: holidayList[index].holidayType != HolidayType.federal
                                            ? holidayList[index].holidayType != HolidayType.others
                                                ? FaIcon(
                                                    holidayList[index].holidayType == HolidayType.christian
                                                        ? FontAwesomeIcons.cross
                                                        : holidayList[index].holidayType == HolidayType.muslim
                                                            ? FontAwesomeIcons.moon
                                                            : FontAwesomeIcons.starOfDavid,
                                                    size: 20.0,
                                                    color: Theme.of(context).primaryColor)
                                                : Image.asset("assets/images/adey.png", width: 24, height: 24)
                                            : Image.asset("assets/images/flag_3d.png", width: 20, height: 20),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      holidayList[index].name!,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${MonthGlobals.etWeekNamesLong[holidayList[index].ecLocalDate!.weekDay! - 1]} | "
                                        "${MonthGlobals.etMonthsLong[holidayList[index].ecLocalDate!.month! - 1]} | "
                                        "${isGeezNumbers ? GeezNumbers.geezNumbers[holidayList[index].ecLocalDate!.day! - 1] : holidayList[index].ecLocalDate!.day}",
                                        style: TextStyle(
                                          fontSize: Globals.deviceHeight! > 700 ? 12 : 10,
                                        ),
                                      ),
                                      Text(
                                        "${MonthGlobals.gcWeekNamesShort[holidayList[index].ecLocalDate!.weekDay! - 1]} | "
                                        "${MonthGlobals.gcMonthsShort[holidayList[index].gcLocalDate!.month! - 1]} | "
                                        "${holidayList[index].gcLocalDate!.day}",
                                        style: TextStyle(
                                          fontSize: Globals.deviceHeight! > 700 ? 12 : 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                splashRadius: 60,
                                icon: Icon(Icons.read_more, color: Theme.of(context).colorScheme.secondary),
                                onPressed: () {
                                  _openDetailPage(context, holidayList[index]);
                                },
                              ),
                              onLongPress: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                debugPrint("------ Long pressed");
                              },
                            ),
                            Divider(
                              color: color,
                              thickness: 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
  }
}
