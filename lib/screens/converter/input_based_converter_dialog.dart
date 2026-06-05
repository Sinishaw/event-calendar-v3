import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputBasedConverterDialog extends StatefulWidget {
  const InputBasedConverterDialog(
      {Key? key,
      this.day,
      this.month,
      this.year,
      this.calendarType = CalendarType.Ethiopian,
      this.conversionResultUpdaterCallback})
      : super(key: key);
  final CalendarType? calendarType;
  final int? day, month, year;
  final Function? conversionResultUpdaterCallback;

  @override
  State<InputBasedConverterDialog> createState() => _InputBasedConverterDialogState();
}

class _InputBasedConverterDialogState extends State<InputBasedConverterDialog> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  final _dayTextController = TextEditingController();
  final _monthTextController = TextEditingController();
  final _yearTextController = TextEditingController();

  CalendarType? calendarType;
  int? _day, _month, _year;

  LocalDate? _dateConverted;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine);
    controller.addListener(() {});
    controller.forward();
    calendarType = widget.calendarType;
    _day = widget.day;
    _month = widget.month;
    _year = widget.year;

    _dayTextController.text = "$_day";
    _monthTextController.text = "$_month";
    _yearTextController.text = "$_year";
  }

  _getConversionOptions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: calendarType == CalendarType.Ethiopian
                  ? null
                  : () {
                      setState(() {
                        try {
                          _day = int.parse(_dayTextController.text);
                          _month = int.parse(_monthTextController.text);
                          _year = int.parse(_yearTextController.text);
                          _convertInputDate(calendarType);
                          calendarType = CalendarType.Ethiopian;
                        } catch (e) {
                          Globals.showSnack(
                            context: context,
                            type: SnackMessageType.error,

                            ///TODO: Get message from language config file
                            message: "Please enter a valid date.",
                          );
                          print(e);
                        }
                      });
                    },
              child: Card(
                elevation: calendarType == CalendarType.Gregorian ? 10 : 0,
                shadowColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Center(child: Text("${AppLocalizations.of(context)!.fromEthiopia}")),
                ),
              ),
            ),
          ),
          // VerticalDivider(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child:
                calendarType == CalendarType.Gregorian ? const Icon(Icons.arrow_back) : const Icon(Icons.arrow_forward),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: calendarType == CalendarType.Gregorian
                  ? null
                  : () {
                      setState(() {
                        try {
                          _day = int.parse(_dayTextController.text);
                          _month = int.parse(_monthTextController.text);
                          _year = int.parse(_yearTextController.text);
                          _convertInputDate(calendarType);
                          calendarType = CalendarType.Gregorian;
                        } catch (e) {
                          print(e);
                          Globals.showSnack(
                            context: context,
                            type: SnackMessageType.error,

                            ///TODO: Get message from language config file
                            message: "Please enter a valid date.",
                          );
                        }
                      });
                    },
              child: Card(
                elevation: calendarType == CalendarType.Ethiopian ? 5 : 0,
                shadowColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: const Center(child: Text("From Gregorian")),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getInputRow() {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(calendarType == CalendarType.Ethiopian ? "${AppLocalizations.of(context)!.date}" : "Day"),
                TextField(
                  controller: _dayTextController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    // hintText: widget.calendarType == CalendarType.Ethiopian ? "ቀን" : "Day",
                    suffixIcon: IconButton(
                      onPressed: () => _dayTextController.clear(),
                      icon: const Icon(
                        Icons.clear,
                        size: 16,
                      ),
                    ),
                  ),
                  // onChanged: (value) => eventTitle = value,
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(calendarType == CalendarType.Ethiopian ? "${AppLocalizations.of(context)!.month}" : "Month"),
                TextField(
                  controller: _monthTextController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    // hintText: widget.calendarType == CalendarType.Ethiopian ? "ወር" : "Month",
                    suffixIcon: IconButton(
                      onPressed: () => _monthTextController.clear(),
                      icon: const Icon(
                        Icons.clear,
                        size: 16,
                      ),
                    ),
                  ),
                  // onChanged: (value) => eventTitle = value,
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(calendarType == CalendarType.Ethiopian ? "${AppLocalizations.of(context)!.year}" : "Year"),
                TextField(
                  controller: _yearTextController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    // hintText: widget.calendarType == CalendarType.Ethiopian ? "ዓመት" : "Year",
                    suffixIcon: IconButton(
                      onPressed: () => _yearTextController.clear(),
                      icon: const Icon(
                        Icons.clear,
                        size: 16,
                      ),
                    ),
                  ),
                  // onChanged: (value) => eventTitle = value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _convertInputDate(CalendarType? calendarType) {
    try {
      int year = int.tryParse(_yearTextController.text)!;
      int? month = int.tryParse(_monthTextController.text);
      int? day = int.tryParse(_dayTextController.text);

      bool isDateInputValid =
          Utility.isDateValidAndSupported(calendarType: calendarType, year: year, month: month, day: day);
      if (!isDateInputValid) {
        Globals.showSnack(
          context: context,
          type: SnackMessageType.error,

          ///TODO: Get message from language config file
          message: "Please enter a valid date.",
        );
        return false;
      }

      if (calendarType == CalendarType.Ethiopian) {
        _dateConverted = MonthModel.toGc(
            year: int.tryParse(_yearTextController.text)!,
            month: int.tryParse(_monthTextController.text)!,
            day: int.tryParse(_dayTextController.text)!);

        print("Initial Date: ${_dayTextController.text} ${_monthTextController.text} ${_yearTextController.text}");
        _dayTextController.text = "${_dateConverted!.day}";
        _monthTextController.text = "${_dateConverted!.month}";
        _yearTextController.text = "${_dateConverted!.year}";
        print("GC Equivalent: ${_dateConverted!.day} ${_dateConverted!.month} ${_dateConverted!.year}");
      } else {
        _dateConverted = MonthModel.toEc(
            year: int.tryParse(_yearTextController.text)!,
            month: int.tryParse(_monthTextController.text)!,
            day: int.tryParse(_dayTextController.text)!);

        _dayTextController.text = "${_dateConverted!.day}";
        _monthTextController.text = "${_dateConverted!.month}";
        _yearTextController.text = "${_dateConverted!.year}";

        print("Initial Date: $_day $_month $_year");
        print("ET Equivalent: ${_dateConverted!.day} ${_dateConverted!.month} ${_dateConverted!.year}");
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  _validateInputDate(CalendarType calendarType) {
    try {
      int year = int.tryParse(_yearTextController.text)!;
      int? month = int.tryParse(_monthTextController.text);
      int? day = int.tryParse(_dayTextController.text);

      if (year < 1900 || year > 2050) return false;

      if (calendarType == CalendarType.Ethiopian) {
        if (day! < 1 || day > 30) return false;
        if (month! < 1 || month > 13) return false;
        if (month == 13) {
          int pagume = MonthModel.isLeapYear(year) ? 6 : 5;
          if (day > pagume) return false;
        }
      } else {
        if (day! < 1 || day > 31) return false;
        int monthLength = MonthModel.getDaysInGcMonth(month, year);
        if (day > monthLength) return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // height: Globals.deviceHeight / 3,
                width: Globals.deviceWidth,
                decoration: ShapeDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                child: Column(children: [
                  _getConversionOptions(),
                  const Divider(),
                  _getInputRow(),
                  const Divider(),
                  Center(
                    child: TextButton(
                      child: Text(calendarType == CalendarType.Ethiopian
                          ? "${AppLocalizations.of(context)!.convertAndReturn}"
                          : "Convert & Back"),
                      onPressed: () {
                        setState(() {
                          try {
                            _day = int.tryParse(_dayTextController.text);
                            _month = int.tryParse(_monthTextController.text);
                            _year = int.tryParse(_yearTextController.text);

                            debugPrint("------ Calendar Type: $calendarType}");
                            _convertInputDate(calendarType);

                            if (calendarType == CalendarType.Gregorian) {
                              int? eD = int.tryParse(_dayTextController.text);
                              int? eM = int.tryParse(_monthTextController.text);
                              int? eY = int.tryParse(_yearTextController.text);
                              if (eD == null ||
                                  eM == null ||
                                  eY == null ||
                                  _day == null ||
                                  _month == null ||
                                  _year == null) {
                                print("I am wrong.");
                                Navigator.of(context).pop();
                                throw Exception();
                              }
                              widget.conversionResultUpdaterCallback!(
                                // int.tryParse(_dayTextController.text),
                                // int.tryParse(_monthTextController.text),
                                // int.tryParse(_yearTextController.text),
                                eD,
                                eM,
                                eY,
                                _day,
                                _month,
                                _year,
                                CalendarType.Ethiopian,
                              );
                              calendarType = CalendarType.Ethiopian;
                            } else {
                              widget.conversionResultUpdaterCallback!(
                                  _day,
                                  _month,
                                  _year,
                                  int.tryParse(_dayTextController.text),
                                  int.tryParse(_monthTextController.text)! - 1,
                                  int.tryParse(_yearTextController.text),
                                  CalendarType.Gregorian);
                              calendarType = CalendarType.Gregorian;
                            }
                            Navigator.of(context).pop();
                          } catch (e) {
                            print(e);
                            Globals.showSnack(
                              context: context,
                              type: SnackMessageType.error,

                              ///TODO: Get message from language config file
                              message: "Please enter a valid date.",
                            );
                          }
                        });
                      },
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
