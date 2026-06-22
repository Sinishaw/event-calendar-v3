import 'dart:ui';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/converter/age_calculator_dialog.dart';
import 'package:event_calendar_v2/screens/converter/input_based_converter_dialog.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  int? yearGc;
  int? monthGc;
  int? dayGc;
  String? monthNameGc;
  String? weekDayGc;

  int? yearEt;
  int? monthEt;
  int? dayEt;
  String? monthNameEt;
  String? weekDayEt;
  late bool isGeezNumbers;

  FixedExtentScrollController? _yearScrollController;
  FixedExtentScrollController? _monthScrollController;
  FixedExtentScrollController? _dayScrollController;
  FixedExtentScrollController? _scrollController;

  CalendarType? calendarType;
  bool _isProgrammaticScroll = false;

  final TextStyle _textStyle = const TextStyle(fontSize: 15);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(AppLocalizations.of(context)!.dateConverter)),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          /// Use the full available height. If the content overflows on very
          /// small devices, SingleChildScrollView lets the user scroll.
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: _buildBody(theme, isDark),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    bool isToday = isScrollIndicatesToday();
    final primaryColor = theme.primaryColor;

    return Column(
      children: [
        /// ── Section 1: Calendar Toggle ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: _buildSegmentedToggle(theme, isDark),
        ),

        /// ── Section 2: Scroll Wheel Picker ──
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// Glassmorphic selection indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                /// The three scroll wheels
                Row(children: [
                  Expanded(
                    flex: 1,
                    child: getScrollable(ScrollableType.day),
                  ),
                  Expanded(
                    flex: 2,
                    child: getScrollable(ScrollableType.month),
                  ),
                  Expanded(
                    flex: 1,
                    child: getScrollable(ScrollableType.year),
                  ),
                ]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 4),

        /// ── Section 3: Action Buttons ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _buildActionButtons(theme, isToday),
        ),

        const SizedBox(height: 4),

        /// ── Section 4: Result Panel ──
        _buildResultPanel(theme, isDark),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SEGMENTED TOGGLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSegmentedToggle(ThemeData theme, bool isDark) {
    final isGregorian = calendarType == CalendarType.Gregorian;
    final primaryColor = theme.primaryColor;
    final pillBg = isDark
        ? Colors.white.withOpacity(0.08)
        : primaryColor.withOpacity(0.08);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          /// "From - Gregorian" toggle
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (calendarType == CalendarType.Gregorian) return;
                setState(() {
                  _isProgrammaticScroll = true;
                  calendarType = CalendarType.Gregorian;
                  initToday();
                });
                await scrollToInitialDay();
                if (mounted) {
                  setState(() {
                    _isProgrammaticScroll = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isGregorian ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isGregorian
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'From - Gregorian',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isGregorian
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// "From - Ethiopian" toggle
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (calendarType == CalendarType.Ethiopian) return;
                setState(() {
                  _isProgrammaticScroll = true;
                  calendarType = CalendarType.Ethiopian;
                  initToday();
                });
                await scrollToInitialDay();
                if (mounted) {
                  setState(() {
                    _isProgrammaticScroll = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: !isGregorian ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: !isGregorian
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.fromEthiopia,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !isGregorian
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildActionButtons(ThemeData theme, bool isToday) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /// Today button
        _buildPillButton(
          icon: Icons.today_rounded,
          label: AppLocalizations.of(context)!.today,
          theme: theme,
          isDark: isDark,
          isDisabled: isToday,
          onTap: () async {
            setState(() {
              _isProgrammaticScroll = true;
              initToday();
            });
            await scrollToInitialDay();
            setState(() {
              _isProgrammaticScroll = false;
            });
          },
        ),

        /// Age button
        _buildPillButton(
          icon: Icons.calculate_outlined,
          label: AppLocalizations.of(context)!.age,
          theme: theme,
          isDark: isDark,
          isDisabled: isToday,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AgeCalculatorDialog(
                  calendarType: calendarType,
                  etDate: LocalDate.date(yearEt, monthEt, dayEt),
                  gcDate: LocalDate.date(yearGc, monthGc, dayGc),
                );
              },
            );
          },
        ),

        /// Input button
        _buildPillButton(
          icon: Icons.edit_rounded,
          label: AppLocalizations.of(context)!.input,
          theme: theme,
          isDark: isDark,
          isDisabled: false,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                if (calendarType == CalendarType.Ethiopian) {
                  return InputBasedConverterDialog(
                    calendarType: calendarType,
                    day: dayEt,
                    month: monthEt,
                    year: yearEt,
                    conversionResultUpdaterCallback: conversionResultUpdaterCallback,
                  );
                } else {
                  return InputBasedConverterDialog(
                    calendarType: calendarType,
                    day: dayGc,
                    month: monthGc,
                    year: yearGc,
                    conversionResultUpdaterCallback: conversionResultUpdaterCallback,
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required bool isDark,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    final primaryColor = theme.primaryColor;
    final bgColor = isDisabled
        ? (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.08))
        : (isDark ? primaryColor.withOpacity(0.15) : primaryColor.withOpacity(0.1));
    final fgColor = isDisabled
        ? theme.textTheme.bodyLarge!.color!.withOpacity(0.25)
        : theme.textTheme.bodyLarge!.color;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isDisabled ? null : onTap,
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  RESULT PANEL — Creative Separation
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildResultPanel(ThemeData theme, bool isDark) {
    final primaryColor = theme.primaryColor;

    /// Build the Ethiopian date string (same logic as original)
    String etConverted;
    if (yearEt! >= 1900) {
      etConverted =
          '$weekDayEt  $monthNameEt ${isGeezNumbers ? GeezNumbers.geezNumbers[dayEt! - 1] : dayEt}, ${isGeezNumbers ? GeezNumbers.geezYears[yearEt! - 1900] : yearEt}';
    } else {
      etConverted =
          '$weekDayEt  $monthNameEt ${isGeezNumbers ? GeezNumbers.geezNumbers[dayEt! - 1] : dayEt}, ${isGeezNumbers ? GeezNumbers.geezYears18s[(yearEt! - 1900).abs()] : yearEt}';
    }
    String gcConverted = '$weekDayGc $monthNameGc $dayGc, $yearGc';

    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : primaryColor.withOpacity(0.04),
          border: Border.all(
            color: primaryColor.withOpacity(isDark ? 0.12 : 0.08),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ── Ethiopian Date ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.brightness_5_rounded,
                        size: 14,
                        color: primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.ethiopian,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.45),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      etConverted,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ── Soft gradient horizontal divider ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.0),
                      primaryColor.withOpacity(0.25),
                      primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            /// ── Gregorian Date ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public_rounded,
                        size: 14,
                        color: primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gregorian',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.45),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      gcConverted,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  INIT & STATE (unchanged logic)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    _yearScrollController = FixedExtentScrollController();
    _monthScrollController = FixedExtentScrollController();
    _dayScrollController = FixedExtentScrollController();
    initToday();
    calendarType = CalendarType.Gregorian;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          _isProgrammaticScroll = true;
        });
      }
      await scrollToInitialDay();
      if (mounted) {
        setState(() {
          _isProgrammaticScroll = false;
        });
      }
    });
  }

  initToday() {
    DateTime gcDate = DateTime.now();
    yearGc = gcDate.year;
    monthGc = gcDate.month - 1;
    dayGc = gcDate.day;
    monthNameGc = MonthGlobals.gcMonthsLong[monthGc!];
    weekDayGc = MonthGlobals.gcWeekNamesLong[gcDate.weekday - 1];

    LocalDate gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
    LocalDate etNow = MonthModel.toEc(year: gcNow.year!, month: gcNow.month!, day: gcNow.day!)!;
    yearEt = etNow.year;
    monthEt = etNow.month;
    dayEt = etNow.day;
    monthNameEt = MonthGlobals.etMonthsLong[monthEt! - 1];
    weekDayEt = MonthGlobals.etWeekNamesLong[gcDate.weekday - 1];

    print("ET DAY: $monthNameEt $dayEt, $yearEt");
  }

  Future<void> scrollToInitialDay() async {
    if (calendarType == CalendarType.Ethiopian) {
      ///If conversion is from Ethiopian to Gregorian
      await Future.wait([
        _yearScrollController!.animateToItem(yearEt! - 1900,
            duration: const Duration(milliseconds: 400), curve: Curves.easeInOutBack),
        _monthScrollController!.animateToItem(monthEt! - 1,
            duration: const Duration(milliseconds: 400), curve: Curves.ease),
        _dayScrollController!.animateToItem(dayEt! - 1,
            duration: const Duration(milliseconds: 400), curve: Curves.linear),
      ]);
    } else if (calendarType == CalendarType.Gregorian) {
      ///If conversion is from Gregorian to Ethiopian
      await Future.wait([
        _yearScrollController!.animateToItem(yearGc! - 1900,
            duration: const Duration(milliseconds: 400), curve: Curves.easeInOutBack),
        _monthScrollController!.animateToItem(monthGc!,
            duration: const Duration(milliseconds: 400), curve: Curves.ease),
        _dayScrollController!.animateToItem(dayGc! - 1,
            duration: const Duration(milliseconds: 400), curve: Curves.linear),
      ]);
    }
  }

  syncGcDayChange(ScrollableType scrollableType, int value) {
    print("Sync GC");
    switch (scrollableType) {
      case ScrollableType.year:
        {
          yearGc = value + 1900;
        }
        break;
      case ScrollableType.month:
        {
          monthGc = value + 1;
          monthNameGc = MonthGlobals.gcMonthsLong[value];
        }
        break;
      case ScrollableType.day:
        {
          dayGc = value + 1;
        }
        break;
    }

    LocalDate etDate = MonthModel.toEc(year: yearGc!, month: monthGc!, day: dayGc!)!;
    yearEt = etDate.year;
    monthEt = etDate.month;
    dayEt = etDate.day;
    monthNameEt = MonthGlobals.etMonthsLong[monthEt! - 1];

    DateTime gcDate = DateTime(yearGc!, monthGc!, dayGc!);
    weekDayEt = MonthGlobals.etWeekNamesLong[gcDate.weekday - 1];
    weekDayGc = MonthGlobals.gcWeekNamesLong[gcDate.weekday - 1];
  }

  syncEtDayChange(ScrollableType scrollableType, int value) {
    debugPrint("-------------------- Sync ET");
    switch (scrollableType) {
      case ScrollableType.year:
        {
          yearEt = value + 1900;
        }
        break;
      case ScrollableType.month:
        {
          monthEt = value + 1;
          monthNameEt = MonthGlobals.etMonthsLong[value];
        }
        break;
      case ScrollableType.day:
        {
          dayEt = value + 1;
        }
        break;
    }

    LocalDate localGcDate = MonthModel.toGc(year: yearEt!, month: monthEt!, day: dayEt!)!;
    DateTime gcDate = DateTime(localGcDate.year!, localGcDate.month!, localGcDate.day!);
    yearGc = gcDate.year;
    monthGc = gcDate.month;
    dayGc = gcDate.day;
    monthNameGc = MonthGlobals.gcMonthsLong[monthGc! - 1];
    weekDayEt = MonthGlobals.etWeekNamesLong[gcDate.weekday - 1];
    weekDayGc = MonthGlobals.gcWeekNamesLong[gcDate.weekday - 1];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SCROLL WHEEL BUILDERS (logic unchanged, visuals refined)
  // ═══════════════════════════════════════════════════════════════════════════

  getScrollableList(ScrollableType scrollableType) {
    List<Widget> scrollableList;
    late int daysInMonth;

    if (calendarType == CalendarType.Gregorian) {
      if (monthGc == 0) monthGc = 12;
      daysInMonth = MonthModel.getDaysInGcMonth(monthGc! - 1, yearGc);
    } else if (calendarType == CalendarType.Ethiopian) {
      if (monthEt! < 13) {
        daysInMonth = 30;
      } else {
        daysInMonth = !MonthModel.isLeapYear(yearEt) ? 5 : 6;
      }
    } else {}

    if (scrollableType == ScrollableType.year) {
      scrollableList = List<Widget>.generate(
        151,
        (index) => Align(
            alignment: Alignment.center,
            child: Text(
                isGeezNumbers && calendarType == CalendarType.Ethiopian
                    ? "${GeezNumbers.geezYears[index]}"
                    : "${index + 1900}",
                style: _textStyle)),
      );
      _scrollController = _yearScrollController;
    } else if (scrollableType == ScrollableType.month) {
      scrollableList = List<Widget>.generate(
        calendarType == CalendarType.Ethiopian ? 13 : 12,
        (index) => Align(
            alignment: Alignment.center,
            child: Text(
                '${calendarType == CalendarType.Ethiopian ? MonthGlobals.etMonthsLong[index] : MonthGlobals.gcMonthsLong[index]}',
                style: _textStyle)),
      );
      _scrollController = _monthScrollController;
    } else {
      scrollableList = List<Widget>.generate(
        daysInMonth,
        (index) {
          return Align(
              alignment: Alignment.center,
              child: Text(
                  isGeezNumbers && calendarType == CalendarType.Ethiopian
                      ? "${GeezNumbers.geezNumbers[index]}"
                      : "${index + 1}",
                  style: _textStyle));
        },
      );
      _scrollController = _dayScrollController;
    }
    return scrollableList;
  }

  adjustMonthLengthDifferenceWhileScrolling(ScrollableType scrollableType) {
    ///Adjustment for pagume due to its days size difference
    if (calendarType == CalendarType.Ethiopian && scrollableType == ScrollableType.month && monthEt == 13) {
      int pagumeLength = !MonthModel.isLeapYear(yearEt) ? 5 : 6;
      if (dayEt! > pagumeLength) {
        dayEt = pagumeLength - 1;
        print("Pagume logic");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dayScrollController!.jumpToItem(dayEt!);
        });
      }
    }

    ///Adjustment for gregorian days due to different sizes
    if (calendarType == CalendarType.Gregorian) {
      if (monthGc == 0) monthGc = 12;
      int monthLength = MonthModel.getDaysInGcMonth(monthGc! - 1, yearGc);
      debugPrint("-------------------- Month Length: $monthLength");
      if (dayGc! > monthLength) {
        dayGc = monthLength - 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dayScrollController!.jumpToItem(dayGc!);
        });
      }
    }
  }

  getScrollable(ScrollableType scrollableType) {
    double itemExtent = 52.0;
    double offAxisFraction = 0.5;
    bool useMagnifier = true;
    double magnification = 1.15;
    double diameterRatio = 2.0;
    double squeeze = 1.2;
    double perspective = 0.006;
    double overAndUnderCenterOpacity = 0.3;
    adjustMonthLengthDifferenceWhileScrolling(scrollableType);
    List<Widget> scrollableList = getScrollableList(scrollableType);
    return ListWheelScrollView.useDelegate(
      itemExtent: itemExtent,
      useMagnifier: useMagnifier,
      magnification: magnification,
      offAxisFraction: offAxisFraction,
      diameterRatio: diameterRatio,
      squeeze: squeeze,
      perspective: perspective,
      overAndUnderCenterOpacity: overAndUnderCenterOpacity,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildLoopingListDelegate(
        children: scrollableList,
      ),
      controller: _scrollController,
      onSelectedItemChanged: (value) {
        if (_isProgrammaticScroll) return;
        setState(() {
          calendarType == CalendarType.Ethiopian
              ? syncEtDayChange(scrollableType, value)
              : syncGcDayChange(scrollableType, value);
        });
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CALLBACK & HELPERS (unchanged)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> conversionResultUpdaterCallback(
      int etDay, int etMonth, int etYear, int gcDay, int gcMonth, int gcYear, CalendarType type) async {
    try {
      bool isDateValid = true;
      try {
        isDateValid = Utility.isDateValidAndSupported(
            calendarType: CalendarType.Ethiopian, year: etYear, month: etMonth, day: etDay);
        if (!isDateValid) throw Exception();
        isDateValid = Utility.isDateValidAndSupported(
            calendarType: CalendarType.Gregorian, year: gcYear, month: gcMonth, day: gcDay);
        if (!isDateValid) throw Exception();
      } catch (e) {
        debugPrint(e.toString());

        ///TODO: Commented
        Globals.showSnack(
          context: context,
          type: SnackMessageType.error,

          ///TODO: Get message from language config file
          message: "Please enter a valid date.",
        );
        return;
      }
      setState(() {
        _isProgrammaticScroll = true;
        dayEt = etDay;
        monthEt = etMonth;
        yearEt = etYear;
        dayGc = gcDay;
        monthGc = gcMonth;
        yearGc = gcYear;
        calendarType = type;
      });
      await scrollToInitialDay();
      if (mounted) {
        setState(() {
          _isProgrammaticScroll = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  isScrollIndicatesToday() {
    if (dayEt == MonthGlobals.etNow!.day &&
        monthEt == MonthGlobals.etNow!.month &&
        yearEt == MonthGlobals.etNow!.year) {
      return true;
    }
    return false;
  }
}
