// ignore_for_file: avoid_unnecessary_containers

import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${isGeezNumbers ? GeezNumbers.geezYears[_year! - 1900] : _year} - ${AppLocalizations.of(context)!.nationalDays} ",
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) {
              final holiday = holidayList[index];
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final cardBg = theme.cardColor;

              // Determine Category Color
              Color categoryColor;
              switch (holiday.holidayType) {
                case HolidayType.christian:
                  categoryColor = theme.primaryColor;
                  break;
                case HolidayType.muslim:
                  categoryColor = Colors.green;
                  break;
                case HolidayType.federal:
                  categoryColor = theme.colorScheme.secondary;
                  break;
                default:
                  categoryColor = Colors.blueGrey;
              }

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12, left: 14, right: 14),
                      decoration: BoxDecoration(
                        color: cardBg.withOpacity(isDark ? 0.35 : 0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.15),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Circular Category Badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: holiday.holidayType != HolidayType.federal
                                  ? holiday.holidayType != HolidayType.others
                                      ? FaIcon(
                                          holiday.holidayType == HolidayType.christian
                                              ? FontAwesomeIcons.cross
                                              : FontAwesomeIcons.moon,
                                          size: 16.0,
                                          color: categoryColor,
                                        )
                                      : Image.asset("assets/images/adey.png", width: 20, height: 20)
                                  : Image.asset("assets/images/flag_3d.png", width: 18, height: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Content Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  holiday.name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                // Stacked Dates
                                Text(
                                  "${MonthGlobals.etWeekNamesLong[holiday.ecLocalDate!.weekDay! - 1]} | "
                                  "${MonthGlobals.etMonthsLong[holiday.ecLocalDate!.month! - 1]} | "
                                  "${isGeezNumbers ? GeezNumbers.geezNumbers[holiday.ecLocalDate!.day! - 1] : holiday.ecLocalDate!.day}",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "${MonthGlobals.gcWeekNamesShort[holiday.ecLocalDate!.weekDay! - 1]} | "
                                  "${MonthGlobals.gcMonthsShort[holiday.gcLocalDate!.month! - 1]} | "
                                  "${holiday.gcLocalDate!.day}",
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontStyle: FontStyle.italic,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Circular Chevron Navigation Icon
                          GestureDetector(
                            onTap: () => _openDetailPage(context, holiday),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
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
