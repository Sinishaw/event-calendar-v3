// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously
import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/company/company_content.dart';
import 'package:event_calendar_v2/screens/events/models/fixed_national_events_detail.dart';
import 'package:event_calendar_v2/screens/events/models/holiday_and_national_events.dart';
import 'package:event_calendar_v2/screens/events/models/notification_payload.dart';
import 'package:event_calendar_v2/screens/events/widgets/national_day_article_page.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/model/day_model.dart';
import 'package:event_calendar_v2/screens/home/model/month_callables.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/screens/plans/user_event_page.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import 'month_picker_dialog.dart';
import 'task_and_event_dialog.dart';

List<int> navigation = List.generate(2, (_) => 0);
late double containerHeight;
late double cellWidth;
double? cellHeight;
List<List<Day>> lst = [];

bool isStartingMonth = true;

// List<NotificationPayload> eventsList = [];
bool isEmptyList = false;

class SingleMonthContainer extends StatefulWidget {
  const SingleMonthContainer({super.key, this.monthNavigationListenerCallback, this.companyChangedListenerCallback});
  final Function? monthNavigationListenerCallback;
  final Function? companyChangedListenerCallback;
  @override
  State<SingleMonthContainer> createState() => _SingleMonthContainerState();
}

class _SingleMonthContainerState extends State<SingleMonthContainer> with MonthCallables {
  // bool isNavigationStart = false;
  // bool swipeLeft = false;
  // bool isTapFromMonthPicker = false;
  // Widget? child;
  int _count = 0;
  // late bool isGeezNumbers;

  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    _context = context;

    ///TODO: Take these initialization to a global level, where the app starts for the first time
    initMonthMatrix();
    if (!Globals.todayIsInitialized) initToday();
    if (Globals.yearGridMonthTap) {
      jumpToEtMonth();
      adjustSundayOffset();
      debugPrint("-------------------- Adjusting Sunday Offset: ${MonthGlobals.showingMonthStartIndex}");
      Globals.yearGridMonthTap = false;
    }

    debugPrint("-------------------- YEAR INIT: ${MonthGlobals.showingMonthStartIndex}");
    debugPrint("-------------------- MONTH INIT: ${MonthGlobals.showingMonthStartIndex}");
    debugPrint("-------------------- TODAY INDEX INIT: ${MonthGlobals.showingMonthStartIndex}");
    debugPrint("-------------------- SHOWING MONTH START INDEX INIT: ${MonthGlobals.showingMonthStartIndex}");

    // Globals.initMonthsImage();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ///Notify parent to change month image
      widget.monthNavigationListenerCallback!();
      child = getMonthGrid(cellHeight, cellWidth, getShowingMonthSequence(), _context);
      containerHeight = MediaQuery.of(context).size.height;

      Utility.showTopicSubscriptionListDialog(_context, dismissible: false);
      Utility.showServiceProviderExpiryNoticeDialog(_context, dismissible: false);
      Utility.showTermsDialog(_context);

      ///TODO: Commented
      // _initQuickStartOptions(_context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    containerHeight = MediaQuery.of(context).size.height;
    cellWidth = MediaQuery.of(context).size.width / 2.8;
    cellHeight = containerHeight / 8.2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 0, child: headerNavigation()),
        Expanded(flex: 0, child: monthHeader(context)),
        Expanded(
          flex: 1,
          child: FutureBuilder(
            future: getMonthEvents(context),
            builder: (context, snapshot) => Stack(
              children: [
                swipeMonthSwitcher(context),
                DraggableScrollableSheet(
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
                  maxChildSize: 1,
                  builder: (BuildContext context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                              width: 0.5,
                            ),
                          )),
                      child: ListView.builder(
                        itemCount: eventsList.length,
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          return index > 0
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).dialogBackgroundColor.withOpacity(0.9),
                                  ),
                                  child: eventsList[index].title != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: _eventImportancePicker(context, eventsList[index]))
                                      : const ListTile(
                                          title: Text(""),
                                        ))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    FaIcon(
                                      // Icons.drag_handle,
                                      FontAwesomeIcons.angleUp,
                                      size: containerHeight > 700 ? 30 : 25,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).dialogBackgroundColor.withOpacity(0.9),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20),
                                        ),
                                      ),
                                      child: eventsList[index].title != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: _eventImportancePicker(context, eventsList[index]))
                                          : const ListTile(
                                              title: Text(""),
                                            ),
                                    ),
                                  ],
                                );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget getMonthGrid(cellHeight, cellWidth, List<Day> monthArray, BuildContext context) {
    ///Based on week start day (Mon or Sun), add 1 offset if day start by Sun or zero
    String weekStartDay = Utility.getWeekStartDay();
    int todayOffset = 0;

    debugPrint("------ Today's Index: ${MonthGlobals.showingMonthStartIndex}");

    ///Adjusting for sunday if weekday starts @ Sunday or else
    if (weekStartDay == 'Sun') {
      if (MonthGlobals.showingMonthStartIndex != 0) {
        todayOffset = 1;
      } else {
        todayOffset = -6;
      }
    } else {
      todayOffset = 0;
    }

    int monthContainerOffsetFix = containerHeight > 800 ? 2 : 5;
    cellHeight -= monthContainerOffsetFix;
    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: cellWidth / cellHeight,
      mainAxisSpacing: containerHeight < 700 ? 1 : 3,
      crossAxisSpacing: 1.0,
      children: List.generate(42, (index) {
        bool isSunday = false;
        if (weekStartDay == 'Mon') {
          isSunday = index % 7 == 6 ? true : false;
        } else {
          isSunday = index % 7 == 0 ? true : false;
        }
        bool isToday = (MonthGlobals.etShowingYear == MonthGlobals.etNowYear &&
            MonthGlobals.etShowingMonth == MonthGlobals.etNowMonth &&
            index == MonthGlobals.todayIndex! + todayOffset);
        Color? cellColor;

        int monthLength = MonthGlobals.etShowingMonth! < 13
            ? 30
            : MonthModel.isLeapYear(MonthGlobals.etShowingYear)
                ? 6
                : 5;

        bool isPrevMonthDays = index < MonthGlobals.showingMonthStartIndex! ? true : false;
        bool isNextMonthDays = index > MonthGlobals.showingMonthStartIndex! + (monthLength - 1) ? true : false;
        bool isPrevOrNextMonthDays = isPrevMonthDays || isNextMonthDays;
        double etDayFontSize = isGeezNumbers ? 18 : 20;

        if (!isSunday && !isToday) {
          cellColor = Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(isGeezNumbers ? 0.8 : 1.0);
        } else if (isSunday) {
          cellColor = Colors.redAccent;
        }
        if (isPrevOrNextMonthDays && !isSunday) {
          ///Prev and Next month days color except Meskerem Prev days (Which are empty by default)
          cellColor = (MonthGlobals.etShowingMonth! > 1 || isNextMonthDays) ? Colors.grey : Colors.transparent;
        } else if (isPrevOrNextMonthDays && isSunday) {
          cellColor = Colors.redAccent.withOpacity(0.3);
        }

        Color eventIndicatorColor = Colors.transparent;
        bool hasEvent = false;

        ///Event indicator color
        if (!isPrevOrNextMonthDays) {
          for (var item in eventsList) {
            if (item.eD == monthArray[index].etDay && item.repeatOption != NotificationRepeatOption.weekly) {
              hasEvent = true;
              if (!isNextMonthDays) {
                eventIndicatorColor = Theme.of(context).primaryColor;
              }
              break;
            } else if (item.eD == monthArray[index].etDay && item.repeatOption == NotificationRepeatOption.weekly) {
              /// Weekly notification shows only on the day they are scheduled to prevent view distruption
              hasEvent = true;
              if (MonthGlobals.etShowingMonth! == item.eM! + 1 && MonthGlobals.etShowingYear! == item.eY) {
                if (!isNextMonthDays) {
                  eventIndicatorColor = Theme.of(context).colorScheme.secondary;
                }
                break;
              }
            }
          }
        }

        ///Month grid cells which have on click effect except Pagume and Meskerem special cases
        bool clickable = (MonthGlobals.etShowingMonth! < 13 ||
            (MonthGlobals.etShowingMonth == 13 && index < MonthGlobals.showingMonthStartIndex! + monthLength + 30));

        return InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () {
            ///Meskerem is included to prevent on tap on previous days
            if (!clickable || (MonthGlobals.etShowingMonth == 1 && isPrevMonthDays)) return;
            if (index < MonthGlobals.showingMonthStartIndex!) {
              isTapFromMonthPicker = true;
              prevEtMonth();
              _count++;
              setState(() {
                child = getMonthGrid(cellHeight, cellWidth, getShowingMonthSequence(), context);
              });
            } else if (index > MonthGlobals.showingMonthStartIndex! + (monthLength - 1)) {
              isTapFromMonthPicker = true;
              nextEtMonth();
              _count++;
              setState(() {
                child = getMonthGrid(cellHeight, cellWidth, getShowingMonthSequence(), context);
              });
            }
            showDialog(
              context: context,
              builder: (_) => ShowDayTaskAndEventsDialog(
                  etDay: monthArray[index].etDay,
                  gcDay: monthArray[index].gcDay,
                  dayIndex: index,
                  userEvents: null,
                  fetchLatestEventsCallback: fetchLatestEventsCallback),
            );
          },
          child: clickable
              ? Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2),
                  child: Container(
                    decoration: BoxDecoration(
                        color: isToday ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.transparent,
                        borderRadius: const BorderRadius.all(Radius.circular(30.0))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            verticalDirection: VerticalDirection.down,
                            children: [
                              monthArray[index].geezDay != "0"
                                  ? Text(isGeezNumbers ? monthArray[index].geezDay! : "${monthArray[index].etDay}",
                                      style: TextStyle(
                                          fontSize: etDayFontSize,
                                          fontWeight: isSunday ? FontWeight.w300 : FontWeight.w200,
                                          color: cellColor))
                                  : Image.asset("assets/images/adey.png", height: 20, width: 20),
                              Text("${monthArray[index].gcDay}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: isSunday ? 12 : 12,
                                      fontStyle: FontStyle.italic,
                                      color: cellColor)),
                            ],
                          ),
                          hasEvent
                              ? Container(
                                  height: 2,
                                  width: 30,
                                  color: eventIndicatorColor,
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
        );
      }),
    );
  }

  AnimatedSwitcher animationSwitcherHeader(BuildContext context, String text, Color color) {
    TextStyle ts = TextStyle(
      fontSize: 20,
      color: color,
    );
    bool isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    Row header = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${MonthGlobals.etMonthsLong[MonthGlobals.etShowingMonth! - 1]} | ${isGeezNumbers ? GeezNumbers.geezYears[MonthGlobals.etShowingYear! - 1900] : MonthGlobals.etShowingYear}",
          style: ts,
        ),
      ],
    );

    TextButton headerButton = TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => MonthPickerDialog(
              month: MonthGlobals.etShowingMonth,
              monthPickedCallback: monthPickedCallback,
              monthNavigationListenerCallback: widget.monthNavigationListenerCallback,
            ),
          );
        },
        key: UniqueKey(),
        child: Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: header,
        ));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.slowMiddle,
      switchOutCurve: Curves.easeInExpo,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: headerButton,
    );
  }

  AnimatedSwitcher swipeMonthSwitcher(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          if (isTapFromMonthPicker) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          }
          final inAnimation = Tween<Offset>(
                  begin: swipeLeft ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0), end: const Offset(0.0, 0.0))
              .animate(animation);
          final outAnimation = Tween<Offset>(
                  begin: swipeLeft ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
              .animate(animation);
          print("COUNT: $_count");
          if (child.key == ValueKey(_count)) {
            return SlideTransition(
              position: inAnimation,
              child: Center(child: child),
            );
          } else {
            return SlideTransition(
              position: outAnimation,
              child: Center(child: child),
            );
          }
        },
        child: simpleGestureDetector(context));
  }

  SimpleGestureDetector simpleGestureDetector(BuildContext context) {
    return SimpleGestureDetector(
      key: ValueKey<int>(_count),
      onHorizontalSwipe: (direction) {
        isTapFromMonthPicker = false;
        setState(() {
          _count++;
          if (direction == SwipeDirection.left) {
            isNavigationStart = true;
            swipeLeft = true;
            debugPrint("------ Swipe Left");
            nextEtMonth();
          } else {
            isNavigationStart = true;
            swipeLeft = false;
            debugPrint("------ Swipe Right");
            prevEtMonth();
          }

          ///Notify parent to change month image
          widget.monthNavigationListenerCallback!();
        });
      },
      swipeConfig: const SimpleSwipeConfig(
        verticalThreshold: 20.0,
        horizontalThreshold: 20.0,
        swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
      ),
      child: getMonthGrid(cellHeight, cellWidth, getShowingMonthSequence(), context),
    );
  }

  Container headerNavigation() {
    Color c = Theme.of(context).primaryColor;
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: c),
            onPressed: () {
              setState(() {
                isNavigationStart = true;
                prevEtMonth();

                ///Notify parent to change month image
                widget.monthNavigationListenerCallback!();
              });
            },
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: animationSwitcherHeader(
                    context,
                    "${MonthGlobals.etMonthsLong[MonthGlobals.etShowingMonth! - 1]} | ${MonthGlobals.etShowingYear}",
                    c),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: c,
            ),
            onPressed: () async {
              setState(() {
                isNavigationStart = true;
                nextEtMonth();

                ///Notify parent to change month image
                widget.monthNavigationListenerCallback!();
              });
            },
          )
        ],
      ),
    );
  }

  monthPickedCallback(int month) {
    isNavigationStart = true;
    isTapFromMonthPicker = true;
    MonthGlobals.etShowingMonth = month;
    _count++;
    jumpToEtMonth();
    setState(() {
      adjustSundayOffset();
      child = getMonthGrid(cellHeight, cellWidth, getShowingMonthSequence(), context);
    });
  }

  _getEventDateTimeDetail(NotificationPayload payload) {
    String timeDetail = "";
    String dateDetail = "";

    String weekDay = "${MonthGlobals.etWeekNamesLong[payload.weekday! - 1]}";
    dateDetail =
        "${MonthGlobals.etMonthsLong[payload.eM!]} ${isGeezNumbers ? GeezNumbers.geezNumbers[payload.eD! - 1] : payload.eD}, ${isGeezNumbers ? GeezNumbers.geezYears[payload.eY! - 1900] : payload.eY}";

    ///Time is not included in national days
    if (payload.eventTagOption != EventTagOption.national) {
      timeDetail = Globals.getEtTimeDetails(payload.scheduledDateTime);
    }

    String formattedDate = "$weekDay $dateDetail $timeDetail";
    return formattedDate;
  }

  _eventImportancePicker(BuildContext context, NotificationPayload payload) {
    if (isEmptyList) {
      return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.perm_device_information, color: Theme.of(context).primaryColor),
            Text("${payload.title}", style: TextStyle(color: Theme.of(context).primaryColor)),
          ],
        ),
      );
    }

    ///Topic and Company content presented differently in the month than other listed local notifications
    if (payload.topic != null &&
        payload.topic!.isNotEmpty &&
        (payload.topic != "personal" && payload.topic != "national")) {
      return _companyAndTopicContentBuilder(context, payload);
    }

    return _nationalAndPersonalContentBuilder(context, payload);
  }

  _companyAndTopicContentBuilder(BuildContext context, NotificationPayload payload) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: payload.icon != null && payload.icon!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: payload.icon!,
                      height: 50,
                      width: 50,
                      // fit: BoxFit.contain,
                      placeholder: (context, url) => ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: Container(
                          child: const Center(child: Text("...")),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    )
                  : Container(),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      payload.title!,
                      maxLines: 1,
                      style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize),
                    ),
                  ),
                  Text(
                    payload.body!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontStyle: FontStyle.italic),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_getEventDateTimeDetail(payload)}",
                          style: TextStyle(fontSize: Globals.deviceHeight! > 700 ? 10 : 8),
                          softWrap: true,
                        ),
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (payload.contentSource == ContentSource.CompanyEvent ||
                                    payload.contentSource == ContentSource.TopicEvent) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        // FirebaseLogger.logGlobalScreenView(LogScreen.NationalDayArticles.index);
                                        // FirebaseLogger.logCompanyScreenView(LogScreen.NationalDayArticles.index);
                                        return const CompanyContentPage(
                                            // nationalDayRef: payload.,
                                            // eventDetail: eventsDetail,
                                            );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                // payload.topic,
                                "more...",
                                style: TextStyle(
                                    fontSize: Globals.deviceHeight! > 700 ? 12 : 10,
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _nationalAndPersonalContentBuilder(BuildContext context, NotificationPayload payload) {
    return Container(
      color: payload.eventTagOption == EventTagOption.national
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Globals.categoryColorList[payload.eventTagOption!.index].withOpacity(0.1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: payload.eventTagOption == EventTagOption.national
                  ? Icon(
                      Icons.celebration,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.label_important,
                          size: 40.0,
                          color: Globals.categoryColorList[payload.eventTagOption!.index],
                        ),
                        const Icon(Icons.notifications),
                        // Icon(
                        //   payload.scheduleOption != NotificationScheduleOption.noNotification
                        //       ? Icons.notifications
                        //       : Icons.notifications_off,
                        //   size: 12.0,
                        //   // color: Globals.categoryColorList[payload.eventTagOption.index],
                        // ),
                      ],
                    ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payload.title!,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "${_getEventDateTimeDetail(payload)}",
                            style: TextStyle(fontSize: Globals.deviceHeight! > 700 ? 10 : 8),
                            softWrap: true,
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: InkWell(
                              onTap: () {
                                if (payload.contentSource == ContentSource.UserTask) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserEventPage(
                                          selectedEtDate: LocalDate.date(payload.eY, payload.eM! + 1, payload.eD),
                                          fetchLatestEventsCallback: fetchLatestEventsCallback,
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        FirebaseLogger.logGlobalScreenView(LogScreen.NationalDayArticles.index);
                                        FirebaseLogger.logCompanyScreenView(LogScreen.NationalDayArticles.index);
                                        return NationalDayArticlePage(
                                          nationalDayRef: payload.body,
                                          // eventDetail: eventsDetail,
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.read_more,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getMonthEvents(BuildContext context) async {
    int emptyListLength;
    if (Globals.deviceHeight! < 500) {
      emptyListLength = 2;
    } else if (Globals.deviceHeight! < 700) {
      emptyListLength = 3;
    } else if (Globals.deviceHeight! < 900) {
      emptyListLength = 4;
    } else {
      emptyListLength = 5;
    }

    ///Get both personal and national events
    await getTasksAndHolidaysList(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth);
    eventsList = eventsList.where((element) => element.visible != "false").toList();
    if (eventsList.isEmpty) {
      isEmptyList = true;
      for (int i = 0; i < emptyListLength; i++) {
        eventsList.add(NotificationPayload(title: i != 1 ? null : AppLocalizations.of(context)!.noEventIsFound));
      }
    } else {
      isEmptyList = false;
      int emptyItemCount = emptyListLength - eventsList.length;
      for (int i = 0; i < emptyItemCount; i++) {
        eventsList.add(NotificationPayload(title: null));
      }
    }
  }

  Future<void> getTasksAndHolidaysList(int? year, int? month) async {
    eventsList = await NotificationService().getMonthNotifications(year, month);
    addNationalEvents(eventsList, year, month);
    if (eventsList.isEmpty) {
      isEmptyList = true;
    } else {
      isEmptyList = false;
    }
    debugPrint("------ Event List Length:${eventsList.length}");
    // return eventsList;
  }

  addNationalEvents(List<NotificationPayload> list, year, month) {
    debugPrint("------ Listing Monthly Holidays...:${MonthGlobals.etShowingYear}--${MonthGlobals.etShowingMonth}");
    List<FixedNationalEventsDetail> monthlyHolidays = [];
    monthlyHolidays
        .addAll(getMonthlyHolidaysInYear(year: MonthGlobals.etShowingYear!, month: MonthGlobals.etShowingMonth));

    for (var element in monthlyHolidays) {
      list.add(NotificationPayload(
          title: element.name,
          createdDateTime: element.gcDate,
          weekday: element.gcDate!.weekday,
          eventTagOption: EventTagOption.national,
          repeatOption: NotificationRepeatOption.national,
          // body: "ብሔራዊ ቀን",
          ///Use body to hold reference to the national day and later can be used to
          ///redirect to list of contents of the day
          body: element.nationalDayRef,
          eD: element.ecLocalDate!.day,
          eM: element.ecLocalDate!.month! - 1,
          eY: element.ecLocalDate!.year,
          contentSource: ContentSource.NationalEvent,
          topic: "national",
          age: 3));
    }
  }

  List<FixedNationalEventsDetail> getMonthlyHolidaysInYear({required int year, int? month}) {
    return HolidayAndNationalEvents.getMonthlyHolidays(year, month);
  }

  ///Refreshes slide national and user events after a user adds new event
  Function? fetchLatestEventsCallback() {
    jumpToEtMonth();
    setState(() {
      adjustSundayOffset();
    });

    return null;
  }
}
