import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

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
  late bool isGeezNumbers;
  late PageController _pageController;

  int getSystemCurrentYear() {
    DateTime gcDate = DateTime.now();
    LocalDate gcNow = LocalDate.detailed(gcDate.year, gcDate.month, gcDate.day, gcDate.weekday);
    LocalDate? etNow = MonthModel.toEc(year: gcNow.year!, month: gcNow.month!, day: gcNow.day!);
    return etNow?.year ?? 2015;
  }

  updateYearCallback(int year) {
    _year = year;
    _pageController.jumpToPage(year - 1900);
    setState(() {});
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
            int currentPage = _pageController.page?.round() ?? (_year! - 1900);
            int targetPage = currentPage - 1;
            if (targetPage < 0) {
              _pageController.jumpToPage(150);
            } else {
              _pageController.animateToPage(
                targetPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
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
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${isGeezNumbers ? GeezNumbers.geezYears[_year! - 1900] : _year} ",
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: 'Next',
            onPressed: () {
              int currentPage = _pageController.page?.round() ?? (_year! - 1900);
              int targetPage = currentPage + 1;
              if (targetPage > 150) {
                _pageController.jumpToPage(0);
              } else {
                _pageController.animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 151,
                onPageChanged: (page) {
                  setState(() {
                    _year = 1900 + page;
                  });
                },
                itemBuilder: (context, index) {
                  final yearForPage = 1900 + index;
                  return YearGrid(
                    key: ValueKey<int>(yearForPage),
                    year: yearForPage,
                    needFirstAnimation: yearForPage == MonthGlobals.etShowingYear,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    _year = getSystemCurrentYear();
    _pageController = PageController(initialPage: _year! - 1900);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

