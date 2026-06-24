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
  int _refreshKey = 0;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    LocalDate etSelectedDate = LocalDate.date(MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, widget.etDay);
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.6,
              width: MediaQuery.of(context).size.width / 1.18,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.18),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // ── Gradient Header ──────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primary.withValues(alpha: isDark ? 0.55 : 0.18),
                                primary.withValues(alpha: isDark ? 0.28 : 0.06),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ET date block
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isGeezNumbers
                                        ? GeezNumbers.geezNumbers[widget.etDay! - 1]
                                        : "${widget.etDay! > 9 ? widget.etDay : "0${widget.etDay}"}",
                                    style: TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      color: primary,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // Weekday + Month chip row
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: primary.withValues(alpha: 0.35),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          weekDay ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: primary,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${MonthGlobals.etMonthsLong[MonthGlobals.etShowingMonth! - 1]}, ${isGeezNumbers ? GeezNumbers.geezYears[MonthGlobals.etShowingYear! - 1900] : MonthGlobals.etShowingYear}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: onSurface.withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // GC date block
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.gcDay! > 9 ? "${widget.gcDay}" : "0${widget.gcDay}",
                                    style: TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      color: onSurface.withValues(alpha: 0.65),
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${MonthGlobals.gcMonthsShort[gcDate!.month! - 1]} ${gcDate!.year}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: onSurface.withValues(alpha: 0.55),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: onSurface.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: onSurface.withValues(alpha: 0.2),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          weekDayGc ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: onSurface.withValues(alpha: 0.65),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Thin accent divider ──────────────────────────────
                        Container(
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primary.withValues(alpha: 0.6),
                                primary.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),

                        // ── Event list ───────────────────────────────────────
                        Expanded(
                          child: DailyUserEventList(
                            key: ValueKey(_refreshKey),
                            selectedEtDate: etSelectedDate,
                            onEventsChanged: () {
                              if (mounted) setState(() => _refreshKey++);
                              if (widget.fetchLatestEventsCallback != null) {
                                widget.fetchLatestEventsCallback!();
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    // Docked floating add button (curved rectangle style)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            final selectedEtDate = LocalDate.date(
                                MonthGlobals.etShowingYear, MonthGlobals.etShowingMonth, widget.etDay);
                            await Navigator.push(
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
                            if (mounted) setState(() => _refreshKey++);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 24,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
