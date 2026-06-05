import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/plans/user_event_page.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/plans/widgets/daily_user_event_list.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class ShowDayTaskAndEventsDialog extends StatefulWidget {
  const ShowDayTaskAndEventsDialog(
      {super.key, this.etDay, this.gcDay, this.dayIndex, this.userEvents, this.fetchLatestEventsCallback});

  final int? etDay;
  final int? gcDay;
  final int? dayIndex;
  final List<String>? userEvents;
  final Function? fetchLatestEventsCallback;

  @override
  State<ShowDayTaskAndEventsDialog> createState() => _ShowDayTaskAndEventsDialogState();
}

class _ShowDayTaskAndEventsDialogState extends State<ShowDayTaskAndEventsDialog> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  String? weekDay;
  String? weekDayGc;
  late bool isGeezNumbers;
  LocalDate? gcDate;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine);
    controller.addListener(() {});
    controller.forward();
    String? weekStartDay = Globals.prefs!.getString(Constants.WeekStartDay);
    int dayOffset = 0;
    if (weekStartDay != null && weekStartDay == 'Sun') {
      dayOffset = -1;
    }
    weekDay = MonthGlobals.etWeekNamesLong[(widget.dayIndex! + dayOffset) % 7];
    weekDayGc = MonthGlobals.gcWeekNamesShort[(widget.dayIndex! + dayOffset) % 7];

    gcDate =
        MonthModel.toGc(year: MonthGlobals.etShowingYear!, month: MonthGlobals.etShowingMonth!, day: widget.etDay!);
  }

  callback() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    LocalDate etSelectedDate = LocalDate.date(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, widget.etDay);
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.6,
              width: MediaQuery.of(context).size.width / 1.3,
              decoration: ShapeDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
              child: Column(children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isGeezNumbers
                                              ? GeezNumbers.geezNumbers[widget.etDay! - 1]
                                              : "${widget.etDay! > 9 ? widget.etDay : "0${widget.etDay}"}",
                                          style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor),
                                        ),
                                        Text(
                                          " $weekDay - ${MonthGlobals.etMonthsLong[MonthGlobals.etShowingMonth! - 1]} ${isGeezNumbers ? GeezNumbers.geezNumbers[widget.etDay! - 1] : widget.etDay}, ${isGeezNumbers ? GeezNumbers.geezYears[MonthGlobals.etShowingYear! - 1900] : MonthGlobals.etShowingYear}",
                                          style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${widget.gcDay}",
                                            style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor)),
                                        Text(
                                          " $weekDayGc - ${MonthGlobals.gcMonthsShort[gcDate!.month! - 1]} ${gcDate!.day}, ${gcDate!.year}",
                                          style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      Expanded(
                        flex: 1,
                        child: DailyUserEventList(selectedEtDate: etSelectedDate),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Card(
                        elevation: 0,
                        child: InkWell(
                            onTap: () {
                              LocalDate selectedEtDate =
                                  LocalDate.date(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, widget.etDay);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    FirebaseLogger.logGlobalScreenView(4);
                                    FirebaseLogger.logCompanyScreenView(4);
                                    return UserEventPage(
                                        title: "User Events",
                                        selectedEtDate: selectedEtDate,
                                        fetchLatestEventsCallback: widget.fetchLatestEventsCallback);
                                  },
                                ),
                              );
                            },
                            child: Icon(Icons.add_circle, size: 48, color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
