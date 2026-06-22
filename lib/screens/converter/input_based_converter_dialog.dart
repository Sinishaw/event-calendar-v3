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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Container(
      margin: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: theme.dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: Globals.deviceWidth,
                    child: Column(children: [
                      _buildConversionToggle(theme, isDark, primaryColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: primaryColor.withOpacity(0.12),
                          height: 1,
                        ),
                      ),
                      _buildInputRow(theme, isDark, primaryColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: primaryColor.withOpacity(0.12),
                          height: 1,
                        ),
                      ),
                      _buildConvertButton(theme, primaryColor),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversionToggle(ThemeData theme, bool isDark, Color primaryColor) {
    final isFromEthiopian = calendarType == CalendarType.Ethiopian;
    final pillBg = isDark
        ? Colors.white.withOpacity(0.08)
        : primaryColor.withOpacity(0.08);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            /// "From Ethiopian" pill
            Expanded(
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
                              message: "Please enter a valid date.",
                            );
                            print(e);
                          }
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isFromEthiopian ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: isFromEthiopian
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
                      "${AppLocalizations.of(context)!.fromEthiopia}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFromEthiopian
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Swap direction icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.swap_horiz_rounded,
                size: 18,
                color: primaryColor.withOpacity(0.5),
              ),
            ),

            /// "From Gregorian" pill
            Expanded(
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
                              message: "Please enter a valid date.",
                            );
                          }
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: !isFromEthiopian ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: !isFromEthiopian
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
                      "From Gregorian",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: !isFromEthiopian
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
      ),
    );
  }

  Widget _buildInputRow(ThemeData theme, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildInputField(
              label: calendarType == CalendarType.Ethiopian
                  ? "${AppLocalizations.of(context)!.date}"
                  : "Day",
              controller: _dayTextController,
              maxLength: 2,
              theme: theme,
              isDark: isDark,
              primaryColor: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _buildInputField(
              label: calendarType == CalendarType.Ethiopian
                  ? "${AppLocalizations.of(context)!.month}"
                  : "Month",
              controller: _monthTextController,
              maxLength: 2,
              theme: theme,
              isDark: isDark,
              primaryColor: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _buildInputField(
              label: calendarType == CalendarType.Ethiopian
                  ? "${AppLocalizations.of(context)!.year}"
                  : "Year",
              controller: _yearTextController,
              maxLength: 4,
              theme: theme,
              isDark: isDark,
              primaryColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required int maxLength,
    required ThemeData theme,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(maxLength),
          ],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.06)
                : primaryColor.withOpacity(0.04),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () => controller.clear(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.clear_rounded,
                size: 16,
                color: primaryColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConvertButton(ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 2,
            shadowColor: primaryColor.withOpacity(0.4),
          ),
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
                  message: "Please enter a valid date.",
                );
              }
            });
          },
          child: Text(
            calendarType == CalendarType.Ethiopian
                ? "${AppLocalizations.of(context)!.convertAndReturn}"
                : "Convert & Back",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CONVERSION LOGIC (unchanged)
  // ═══════════════════════════════════════════════════════════════════════════

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
}
