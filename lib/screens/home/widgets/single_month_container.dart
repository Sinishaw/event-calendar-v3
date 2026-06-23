// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously
import 'dart:ui';
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

  // late bool isGeezNumbers;

  late BuildContext _context;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    _context = context;
    _pageController = PageController(initialPage: 600);

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
      child = getMonthGrid(cellHeight, cellWidth, getShowingMonthSequence(), _context, year: MonthGlobals.etShowingYear!, month: MonthGlobals.etShowingMonth!);
      containerHeight = MediaQuery.of(context).size.height;

      Utility.showTopicSubscriptionListDialog(_context, dismissible: false);
      Utility.showServiceProviderExpiryNoticeDialog(_context, dismissible: false);
      Utility.showTermsDialog(_context);

      ///TODO: Commented
      // _initQuickStartOptions(_context);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  LocalDate _getMonthYearForPage(int page) {
    int diff = page - 600;
    int nowYear = MonthGlobals.etNow!.year!;
    int nowMonth = MonthGlobals.etNow!.month!;
    // Offset by 10,000 years to prevent negative values in division/modulo
    int totalMonths = ((nowYear + 10000) * 13) + (nowMonth - 1) + diff;
    int targetYear = (totalMonths ~/ 13) - 10000;
    int targetMonth = (totalMonths % 13) + 1;
    return LocalDate.date(targetYear, targetMonth, 1);
  }

  List<Day> _getMonthSequenceFor(int year, int month) {
    List<Day> monthArray = List.generate(42, (_) => Day());
    
    LocalDate gcDate = MonthModel.toGc(year: year, month: month, day: 1)!;
    DateTime gcDateTime = DateTime(gcDate.year!, gcDate.month!, gcDate.day!);
    int startIndex = gcDateTime.weekday - 1;
    
    // Adjust Sunday Offset
    String weekStartDay = Utility.getWeekStartDay();
    if (weekStartDay == 'Sun') {
      if (startIndex < 6) {
        startIndex = startIndex + 1;
      } else {
        startIndex = 0;
      }
    }
    
    int index = startIndex;
    int etDayLength = month < 13
        ? 30
        : MonthModel.isLeapYear(year)
            ? 6
            : 5;

    ///From 1st to end of current month
    for (int day = 1; day <= etDayLength; day++, index++) {
      monthArray[index].etDay = day;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
    }

    ///Start of next month days
    for (int day = 1; index < monthArray.length; day++, index++) {
      monthArray[index].etDay = day;
      if (day == 31) day = 1;
      monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
      
      int nextMonth = month + 1;
      int nextYear = year;
      if (nextMonth > 13) {
        nextMonth = 1;
        nextYear = year + 1;
      }
      int nextMonthLength = nextMonth < 13
          ? 30
          : MonthModel.isLeapYear(nextYear)
              ? 6
              : 5;
              
      if (month == 12 && index > 34 && day > nextMonthLength) {
        day = 1;
        monthArray[index].etDay = day;
        monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
      }

      if (month == 13 && day < 31) {
        monthArray[index].etDay = day;
        monthArray[index].geezDay = GeezNumbers.geezNumbers[day - 1];
      }
    }

    ///End of previous month days
    int prevMonth = month - 1;
    int prevYear = year;
    if (prevMonth == 0) {
      prevMonth = 13;
      prevYear = year - 1;
    }
    int prevMonthLength = prevMonth < 13
        ? 30
        : MonthModel.isLeapYear(prevYear)
            ? 6
            : 5;

    for (int day = prevMonthLength, i = startIndex - 1; i >= 0; i--, day--) {
      if (month > 1) {
        monthArray[i].etDay = day;
        monthArray[i].geezDay = GeezNumbers.geezNumbers[day - 1];
      } else {
        monthArray[i].geezDay = "0";
      }
    }

    getGcMonthSequence(startIndex, LocalDate.date(year, month, 1), gcDate, monthArray);
    return monthArray;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        containerHeight = constraints.maxHeight;
        cellWidth = constraints.maxWidth / 7.0;

        final double screenHeight = MediaQuery.of(context).size.height;
        final double spacing = screenHeight < 700 ? 1.0 : 3.0;
        final double offsetFix = screenHeight > 800 ? 2.0 : 5.0;

        // available height for month grid is containerHeight - navigationHeader (50) - monthHeader (27)
        final double availableGridHeight = containerHeight - 50.0 - 27.0;

        // cellHeight before offsetFix subtraction
        cellHeight = (availableGridHeight + (6 * offsetFix) - (5 * spacing)) / 6.0;

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
                      initialChildSize: 0.06,
                      minChildSize: 0.06,
                      maxChildSize: 0.95,
                      builder: (BuildContext context, scrollController) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        final double opacity = Globals.setting.menuBackgroundOpacity ?? 0.95;
                        final Color dialogBg = theme.dialogBackgroundColor;

                        Widget sheetContent = Container(
                          decoration: BoxDecoration(
                            color: dialogBg.withOpacity(opacity),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                            border: Border(
                              top: BorderSide(
                                color: theme.primaryColor.withOpacity(0.12),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: eventsList.length + 1,
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Persistent Drag Handle Pill as index 0 of the scrollable list
                                return Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 2, bottom: 10),
                                    width: 44,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(2.5),
                                    ),
                                  ),
                                );
                              }

                              final payload = eventsList[index - 1];
                              if (payload.title == null) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _eventImportancePicker(context, payload),
                              );
                            },
                          ),
                        );

                        if (opacity < 1.0) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: sheetContent,
                            ),
                          );
                        }
                        return sheetContent;
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Color _getHolidayColor(BuildContext context) {
    try {
      final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final String? hexValue = isDarkMode
          ? Globals.setting.holidayColorDark
          : Globals.setting.holidayColorLight;
      if (hexValue != null && hexValue.isNotEmpty) {
        String cleanHex = hexValue.replaceAll('#', '');
        if (cleanHex.length == 6) {
          cleanHex = 'FF$cleanHex';
        }
        final int? colorInt = int.tryParse(cleanHex, radix: 16);
        if (colorInt != null) {
          return Color(colorInt);
        }
      }
    } catch (e) {
      debugPrint("------ Error reading holidayColor from Globals.setting: $e");
    }
    return Colors.redAccent;
  }

  Widget getMonthGrid(cellHeight, cellWidth, List<Day> monthArray, BuildContext context, {required int year, required int month}) {
    ///Based on week start day (Mon or Sun), add 1 offset if day start by Sun or zero
    String weekStartDay = Utility.getWeekStartDay();
    int todayOffset = 0;

    // Calculate activeStartIndex for this specific month/year
    LocalDate tempGcDate = MonthModel.toGc(year: year, month: month, day: 1)!;
    DateTime tempGcDateTime = DateTime(tempGcDate.year!, tempGcDate.month!, tempGcDate.day!);
    int activeStartIndex = tempGcDateTime.weekday - 1;
    if (weekStartDay == 'Sun') {
      if (activeStartIndex < 6) {
        activeStartIndex = activeStartIndex + 1;
      } else {
        activeStartIndex = 0;
      }
    }

    ///Adjusting for sunday if weekday starts @ Sunday or else
    if (weekStartDay == 'Sun') {
      if (activeStartIndex != 0) {
        todayOffset = 1;
      } else {
        todayOffset = -6;
      }
    } else {
      todayOffset = 0;
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    double monthContainerOffsetFix = screenHeight > 800 ? 2.0 : 5.0;
    cellHeight -= monthContainerOffsetFix;

    final Color holidayColor = _getHolidayColor(context);

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: cellWidth / cellHeight,
      mainAxisSpacing: screenHeight < 700 ? 1 : 3,
      crossAxisSpacing: 1.0,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(42, (index) {
        bool isSunday = false;
        if (weekStartDay == 'Mon') {
          isSunday = index % 7 == 6 ? true : false;
        } else {
          isSunday = index % 7 == 0 ? true : false;
        }
        bool isToday = (year == MonthGlobals.etNowYear &&
            month == MonthGlobals.etNowMonth &&
            index == MonthGlobals.todayIndex! + todayOffset);
        Color? cellColor;

        int monthLength = month < 13
            ? 30
            : MonthModel.isLeapYear(year)
                ? 6
                : 5;

        bool isPrevMonthDays = index < activeStartIndex ? true : false;
        bool isNextMonthDays = index > activeStartIndex + (monthLength - 1) ? true : false;
        bool isPrevOrNextMonthDays = isPrevMonthDays || isNextMonthDays;
        double etDayFontSize = isGeezNumbers ? 16 : 18;

        FontWeight fontWeight;
        FontWeight gcFontWeight;
        if (isPrevOrNextMonthDays) {
          fontWeight = FontWeight.w300;
          gcFontWeight = FontWeight.w300;
          if (isSunday) {
            cellColor = holidayColor.withOpacity(0.4);
          } else {
            cellColor = (month > 1 || isNextMonthDays) ? Colors.grey.withOpacity(0.5) : Colors.transparent;
          }
        } else {
          fontWeight = FontWeight.w700; // Bold Ethiopian day
          gcFontWeight = FontWeight.w400; // Regular Gregorian day
          if (isSunday) {
            cellColor = holidayColor;
          } else if (isToday) {
            cellColor = Theme.of(context).colorScheme.secondary;
          } else {
            cellColor = Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(isGeezNumbers ? 0.85 : 1.0);
          }
        }

        Color eventIndicatorColor = Colors.transparent;
        bool hasEvent = false;

        ///Event indicator color
        if (!isPrevOrNextMonthDays) {
          for (var item in eventsList) {
            if (item.eD == monthArray[index].etDay && item.repeatOption != NotificationRepeatOption.weekly) {
              hasEvent = true;
              if (!isNextMonthDays) {
                eventIndicatorColor = holidayColor;
              }
              break;
            } else if (item.eD == monthArray[index].etDay && item.repeatOption == NotificationRepeatOption.weekly) {
              /// Weekly notification shows only on the day they are scheduled to prevent view distruption
              hasEvent = true;
              if (month == item.eM! + 1 && year == item.eY) {
                if (!isNextMonthDays) {
                  eventIndicatorColor = holidayColor;
                }
                break;
              }
            }
          }
        }

        ///Month grid cells which have on click effect except Pagume and Meskerem special cases
        bool clickable = (month < 13 ||
            (month == 13 && index < activeStartIndex + monthLength + 30));

        return InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () {
            ///Meskerem is included to prevent on tap on previous days
            if (!clickable || (month == 1 && isPrevMonthDays)) return;
            if (index < activeStartIndex) {
              isTapFromMonthPicker = false;
              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else if (index > activeStartIndex + (monthLength - 1)) {
              isTapFromMonthPicker = false;
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                        color: isToday
                            ? Theme.of(context).colorScheme.secondary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: const BorderRadius.all(Radius.circular(12.0))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              monthArray[index].geezDay != "0"
                                  ? Text(isGeezNumbers ? monthArray[index].geezDay! : "${monthArray[index].etDay}",
                                      style: TextStyle(
                                          fontSize: etDayFontSize,
                                          fontWeight: fontWeight,
                                          color: cellColor))
                                  : Image.asset("assets/images/adey.png", height: 20, width: 20),
                              const SizedBox(width: 4),
                              Text("${monthArray[index].gcDay}",
                                  style: TextStyle(
                                      fontWeight: gcFontWeight,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: isPrevOrNextMonthDays
                                          ? cellColor.withOpacity(0.6)
                                          : cellColor.withOpacity(0.55))),
                            ],
                          ),
                          hasEvent
                              ? Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: eventIndicatorColor,
                                  ),
                                )
                              : const SizedBox(height: 8),
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

  Widget swipeMonthSwitcher(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        isTapFromMonthPicker = false;
        final date = _getMonthYearForPage(page);
        setState(() {
          MonthGlobals.etShowingYear = date.year;
          MonthGlobals.etShowingMonth = date.month;

          // Adjust showingMonthStartIndex for globals
          LocalDate gcDate = MonthModel.toGc(year: date.year!, month: date.month!, day: 1)!;
          DateTime gcDateTime = DateTime(gcDate.year!, gcDate.month!, gcDate.day!);
          MonthGlobals.showingMonthStartIndex = gcDateTime.weekday - 1;
          adjustSundayOffset();

          widget.monthNavigationListenerCallback!();
        });
      },
      itemBuilder: (context, index) {
        final date = _getMonthYearForPage(index);
        final monthArray = _getMonthSequenceFor(date.year!, date.month!);
        return getMonthGrid(cellHeight, cellWidth, monthArray, context, year: date.year!, month: date.month!);
      },
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
              isTapFromMonthPicker = false;
              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
            onPressed: () {
              isTapFromMonthPicker = false;
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
    jumpToEtMonth();
    adjustSundayOffset();

    int diff = (MonthGlobals.etShowingYear! - MonthGlobals.etNow!.year!) * 13 + (MonthGlobals.etShowingMonth! - MonthGlobals.etNow!.month!);
    int targetPage = 600 + diff;
    _pageController.jumpToPage(targetPage);

    setState(() {});
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
      final theme = Theme.of(context);
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, color: theme.primaryColor.withOpacity(0.7), size: 20),
            const SizedBox(width: 8),
            Text(
              "${payload.title}",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = theme.cardColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg.withOpacity(isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image / Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 38,
              height: 38,
              color: primaryColor.withOpacity(0.08),
              child: payload.icon != null && payload.icon!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: payload.icon!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image_not_supported_rounded, color: primaryColor, size: 18),
                    )
                  : Icon(Icons.business_rounded, color: primaryColor, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payload.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (payload.body != null && payload.body!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    payload.body!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.45),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getEventDateTimeDetail(payload),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Trailing Chevron Icon
          GestureDetector(
            onTap: () {
              if (payload.contentSource == ContentSource.CompanyEvent ||
                  payload.contentSource == ContentSource.TopicEvent) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CompanyContentPage();
                    },
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(5),
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
    );
  }

  _nationalAndPersonalContentBuilder(BuildContext context, NotificationPayload payload) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardColor;

    final Color categoryColor = payload.eventTagOption == EventTagOption.national
        ? theme.primaryColor
        : Globals.categoryColorList[payload.eventTagOption!.index];

    return Container(
      decoration: BoxDecoration(
        color: cardBg.withOpacity(isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              payload.eventTagOption == EventTagOption.national
                  ? Icons.celebration_rounded
                  : Icons.label_important_rounded,
              color: categoryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payload.title!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (payload.body != null && payload.body!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    payload.body!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                // DateTime Row
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.45),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getEventDateTimeDetail(payload),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Trailing Chevron Icon
          GestureDetector(
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
                        holidayName: payload.title,
                      );
                    },
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(5),
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
