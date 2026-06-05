import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({super.key, this.month, this.monthPickedCallback, this.monthNavigationListenerCallback});

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

  final List<Text> _months = [];

  ///TODO: Commented
  // AppTheme? _appTheme;
  late double _dialogOpacity;
  Color? _themeColor;
  late bool isGeezNumbers;
  final List<Text> _selectedMonth = [];

  _init() {
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine);
    controller.addListener(() {});
    controller.fling();
    for (int i = 0; i < 13; i++) {
      _months.add(Text(MonthGlobals.etMonthsLong[i]!));
    }
    _selectedMonth.add(_months[widget.month! - 1]);
  }

  _getEtTodayFormatted() {
    Color? tc = Theme.of(context).textTheme.bodyLarge!.color;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
          "${AppLocalizations.of(context)!.today} ${MonthGlobals.etWeekNamesLong[MonthGlobals.gcNow!.weekDay! - 1]} "
          "${MonthGlobals.etMonthsLong[MonthGlobals.etNow!.month! - 1]} "
          "${isGeezNumbers ? GeezNumbers.geezNumbers[MonthGlobals.etNow!.day! - 1] : MonthGlobals.etNow!.day}, ${isGeezNumbers ? GeezNumbers.geezYears[MonthGlobals.etNow!.year! - 1900] : MonthGlobals.etNow!.year}",
          style: TextStyle(color: tc)),
    );
  }

  _getGcTodayFormatted() {
    Color? tc = Theme.of(context).textTheme.bodyLarge!.color;
    return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "Today: ${MonthGlobals.gcWeekNamesShort[MonthGlobals.gcNow!.weekDay! - 1]} "
          "${MonthGlobals.gcMonthsShort[MonthGlobals.gcNow!.month! - 1]} "
          "${MonthGlobals.gcNow!.day}, ${MonthGlobals.gcNow!.year}",
          style: TextStyle(color: tc),
        ));
  }

  @override
  Widget build(BuildContext context) {
    ///TODO: Commented
    // _appTheme = Globals.getAppTheme();
    // _dialogOpacity = _appTheme == AppTheme.dark ? 0.8 : 0.6;
    _dialogOpacity = 0.8;
    _themeColor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Container(
                width: width / 1.2,
                decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor.withOpacity(_dialogOpacity),
                    border: Border.all(color: _themeColor!, width: 0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                child: Center(
                    child: Text(
                  "${isGeezNumbers ? GeezNumbers.geezYears[MonthGlobals.etShowingYear! - 1900] : MonthGlobals.etShowingYear}",
                  style: TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 40, color: Theme.of(context).colorScheme.secondary),
                )),
              ),
            ),
            Container(
              height: height / 3,
              width: width / 1.2,
              decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor.withOpacity(_dialogOpacity),
                  border: Border.all(color: _themeColor!, width: 0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0))),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: height > 800 ? 1.3 : 1.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemCount: 13,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _selectedMonth.clear();
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedMonth.add(_months[index]);
                            widget.monthPickedCallback!(index + 1);
                            widget.monthNavigationListenerCallback!();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: _selectedMonth.contains(_months[index])
                                  ? _themeColor
                                  : Theme.of(context).dialogBackgroundColor.withOpacity(_dialogOpacity),
                              border: Border.all(
                                  color: index != MonthGlobals.etNowMonth! - 1
                                      ? Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5)
                                      : _themeColor!,
                                  width: 0.5),
                              borderRadius: const BorderRadius.all(Radius.circular(10.0))),
                          child: FittedBox(fit: BoxFit.scaleDown, child: Text(MonthGlobals.etMonthsLong[index]!)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: 3),
              width: width / 1.2,
              decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor.withOpacity(_dialogOpacity),
                  border: Border.all(color: _themeColor!, width: 0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0))),
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.transparent),
                onPressed: () {
                  MonthGlobals.etShowingYear = MonthGlobals.etNow!.year;
                  widget.monthPickedCallback!(MonthGlobals.etNow!.month);
                  widget.monthNavigationListenerCallback!();
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Expanded(flex: 1, child: _getEtTodayFormatted()),
                    Icon(Icons.touch_app, color: _themeColor),
                    Expanded(flex: 1, child: _getGcTodayFormatted())
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
