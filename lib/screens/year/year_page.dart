import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import 'widgets/year_grid.dart';
import 'widgets/year_picker_dialog.dart';

class YearPage extends StatefulWidget {
  static const String routeName = '/year';
  const YearPage({super.key, this.title, this.monthNavigationListenerCallback});
  final String? title;
  final Function? monthNavigationListenerCallback;

  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  int? _year;
  bool swipeLeft = false, isNavigationStart = false;
  int _count = 0;
  late bool isGeezNumbers;

  initCurrentYear() {
    DateTime gcDate = DateTime.now();
    LocalDate gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
    LocalDate? etNow = MonthModel.toEc(year: gcNow.year!, month: gcNow.month!, day: gcNow.day!);
    setState(() {
      _year = etNow!.year;
    });
  }

  updateYearCallback(int year) {
    _year = year;
    setState(() {});
  }

  AnimatedSwitcher swipeMonthSwitcher(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final inAnimation = Tween<Offset>(
                  begin: swipeLeft ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0), end: const Offset(0.0, 0.0))
              .animate(animation);
          final outAnimation = Tween<Offset>(
                  begin: swipeLeft ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
              .animate(animation);

          debugPrint("COUNT: $_count");
          if (child.key == ValueKey(_count)) {
            return SlideTransition(
              position: inAnimation,
              child: child,
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
          setState(() {
            _count++;
            if (direction == SwipeDirection.left) {
              isNavigationStart = true;
              swipeLeft = true;
              _year = Utility.getZeroOrNumber(_year) + 1;
              debugPrint("LEFT");
            } else {
              isNavigationStart = true;
              swipeLeft = false;
              debugPrint("RIGHT");
              _year = Utility.getZeroOrNumber(_year) - 1;
            }
          });
        },
        swipeConfig: const SimpleSwipeConfig(
          verticalThreshold: 20.0,
          horizontalThreshold: 20.0,
          swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
        ),
        child: YearGrid(year: _year, needFirstAnimation: _year == MonthGlobals.etShowingYear));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        title: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => YearPickerDialog(year: _year, callback: updateYearCallback),
              );
              debugPrint("You have tapped year : $_year");
            },
            child: Center(child: Text("${isGeezNumbers ? GeezNumbers.geezYears[_year! - 1900] : _year}"))),
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
      body: Center(
        child: Column(
          children: [
            Expanded(flex: 1, child: swipeMonthSwitcher(context)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    initCurrentYear();
  }
}
