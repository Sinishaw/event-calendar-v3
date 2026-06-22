import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({
    super.key,
    this.month,
    this.monthPickedCallback,
    this.monthNavigationListenerCallback,
  });

  final int? month;
  final Function? monthPickedCallback;
  final Function? monthNavigationListenerCallback;

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late double height, width;

  late int _localShowingYear;
  late bool _isYearView;
  late bool isGeezNumbers;
  int _slideDirection = 1; // 1 for next (slide left), -1 for prev (slide right)

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _init() {
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    controller.fling();

    _localShowingYear = MonthGlobals.etShowingYear!;
    _isYearView = false;
  }

  _navigateNext() {
    setState(() {
      _slideDirection = 1;
      if (_isYearView) {
        _localShowingYear += 12;
        if (_localShowingYear > 2045) _localShowingYear = 2045;
      } else {
        _localShowingYear += 1;
        if (_localShowingYear > 2050) _localShowingYear = 2050;
      }
    });
  }

  _navigatePrevious() {
    setState(() {
      _slideDirection = -1;
      if (_isYearView) {
        _localShowingYear -= 12;
        if (_localShowingYear < 1905) _localShowingYear = 1905;
      } else {
        _localShowingYear -= 1;
        if (_localShowingYear < 1900) _localShowingYear = 1900;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = theme.dialogBackgroundColor;

    double dialogOpacity = 1.0;
    try {
      if (Globals.setting.menuBackgroundOpacity != 0) {
        dialogOpacity = Globals.setting.menuBackgroundOpacity;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 360,
            maxHeight: height * 0.70, // Safety limit
          ),
          decoration: BoxDecoration(
            color: cardBg.withOpacity(dialogOpacity), // Transparency from RemoteConfig settings
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withOpacity(0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height dynamically
            children: [
              _buildHeader(theme, primaryColor),
              _buildDivider(primaryColor),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    _navigatePrevious();
                  } else if (details.primaryVelocity! < 0) {
                    _navigateNext();
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final isMonth = child.key.toString().contains('month');
                    final isEntering = isMonth
                        ? child.key == ValueKey('month_$_localShowingYear')
                        : child.key == ValueKey('year_${_localShowingYear - (_localShowingYear - 1900) % 12}');

                    final beginOffset = isEntering
                        ? Offset(_slideDirection.toDouble(), 0.0)
                        : Offset(-_slideDirection.toDouble(), 0.0);

                    return ClipRect(
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: beginOffset,
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _isYearView
                      ? _buildYearGrid(theme, primaryColor)
                      : _buildMonthGrid(theme, primaryColor),
                ),
              ),
              _buildDivider(primaryColor),
              _buildFooter(theme, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color primaryColor) {
    int startYear = _localShowingYear - (_localShowingYear - 1900) % 12;
    if (startYear < 1900) startYear = 1900;
    
    String headerText = _isYearView
        ? (isGeezNumbers
            ? "${GeezNumbers.geezYears[startYear - 1900]} - ${GeezNumbers.geezYears[startYear + 11 - 1900]}"
            : "$startYear - ${startYear + 11}")
        : (isGeezNumbers
            ? GeezNumbers.geezYears[_localShowingYear - 1900]
            : "$_localShowingYear");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _navigatePrevious,
            icon: Icon(Icons.chevron_left_rounded, color: primaryColor),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _isYearView = !_isYearView;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    headerText,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isYearView ? "Tap for Month View" : "Tap for Year View",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isYearView ? Icons.calendar_today_rounded : Icons.edit_calendar_rounded,
                        size: 10,
                        color: primaryColor.withOpacity(0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _navigateNext,
            icon: Icon(Icons.chevron_right_rounded, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: primaryColor.withOpacity(0.12),
        height: 1,
      ),
    );
  }

  Widget _buildMonthGrid(ThemeData theme, Color primaryColor) {
    final etNow = MonthGlobals.etNow!;
    final isShowingYearCurrent = _localShowingYear == MonthGlobals.etShowingYear;

    return Padding(
      key: ValueKey('month_$_localShowingYear'),
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true, // Self-size vertically
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.35,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 13,
        itemBuilder: (context, index) {
          final monthIndex = index + 1;
          final isSelected = isShowingYearCurrent && monthIndex == widget.month;
          final isTodayMonth = monthIndex == etNow.month && _localShowingYear == etNow.year;

          final pillBg = isSelected
              ? primaryColor
              : (theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.06)
                  : primaryColor.withOpacity(0.04));

          return InkWell(
            onTap: () {
              setState(() {
                MonthGlobals.etShowingYear = _localShowingYear;
                widget.monthPickedCallback!(monthIndex);
                widget.monthNavigationListenerCallback!();
              });
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isTodayMonth ? primaryColor : primaryColor.withOpacity(0.12)),
                  width: isTodayMonth ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      MonthGlobals.etMonthsLong[index]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isTodayMonth ? primaryColor : theme.textTheme.bodyMedium?.color?.withOpacity(0.85)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearGrid(ThemeData theme, Color primaryColor) {
    int startYear = _localShowingYear - (_localShowingYear - 1900) % 12;
    if (startYear < 1900) startYear = 1900;
    if (startYear > 2039) startYear = 2039;

    return Padding(
      key: ValueKey('year_$startYear'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true, // Self-size vertically
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.8, // Elegant aspect ratio
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final yearValue = startYear + index;
          final isSelected = yearValue == _localShowingYear;
          final isTodayYear = yearValue == MonthGlobals.etNow!.year;

          final pillBg = isSelected
              ? primaryColor
              : (theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.06)
                  : primaryColor.withOpacity(0.04));

          final yearText = isGeezNumbers
              ? (yearValue >= 1900 && yearValue - 1900 < GeezNumbers.geezYears.length
                  ? GeezNumbers.geezYears[yearValue - 1900]
                  : "$yearValue")
              : "$yearValue";

          return InkWell(
            onTap: () {
              setState(() {
                _localShowingYear = yearValue;
                _isYearView = false;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isTodayYear ? primaryColor : primaryColor.withOpacity(0.12)),
                  width: isTodayYear ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  yearText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isTodayYear ? primaryColor : theme.textTheme.bodyMedium?.color?.withOpacity(0.85)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: InkWell(
        onTap: () {
          setState(() {
            MonthGlobals.etShowingYear = MonthGlobals.etNow!.year;
            widget.monthPickedCallback!(MonthGlobals.etNow!.month);
            widget.monthNavigationListenerCallback!();
          });
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(theme.brightness == Brightness.dark ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.18),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.today_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getEtTodayString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _getGcTodayString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right_rounded, size: 16, color: primaryColor.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  String _getEtTodayString() {
    final etNow = MonthGlobals.etNow!;
    final dayStr = isGeezNumbers ? GeezNumbers.geezNumbers[etNow.day! - 1] : "${etNow.day}";
    final yearStr = isGeezNumbers ? GeezNumbers.geezYears[etNow.year! - 1900] : "${etNow.year}";
    final weekDayStr = MonthGlobals.etWeekNamesLong[MonthGlobals.gcNow!.weekDay! - 1];
    final monthStr = MonthGlobals.etMonthsLong[etNow.month! - 1];

    return "${AppLocalizations.of(context)!.today}: $weekDayStr, $monthStr $dayStr, $yearStr";
  }

  String _getGcTodayString() {
    final gcNow = MonthGlobals.gcNow!;
    final weekDayStr = MonthGlobals.gcWeekNamesShort[gcNow.weekDay! - 1];
    final monthStr = MonthGlobals.gcMonthsShort[gcNow.month! - 1];

    return "Gregorian: $weekDayStr, $monthStr ${gcNow.day}, ${gcNow.year}";
  }
}
