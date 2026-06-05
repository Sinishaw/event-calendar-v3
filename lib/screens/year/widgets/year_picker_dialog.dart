// ignore_for_file: sized_box_for_whitespace
import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YearPickerDialog extends StatefulWidget {
  const YearPickerDialog({super.key, this.year, this.callback});
  final int? year;
  final Function? callback;

  @override
  State<YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<YearPickerDialog> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late double height, width;
  final _titleTextController = TextEditingController();

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

  _init() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine);
    controller.addListener(() {});
    controller.fling();
  }

  _handleException(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        ///TODO: Change hard coded text from language config
        content: Text("Year must be between 1900-2050"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: width / 1.1,
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleTextController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            hintText:
                                "${AppLocalizations.of(context)!.year} (${AppLocalizations.of(context)!.ethiopian})",
                            suffixIcon: IconButton(
                              onPressed: () => _titleTextController.clear(),
                              icon: const Icon(Icons.clear),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.check,
                            size: 32,
                          ),
                          onPressed: () {
                            debugPrint("Update year and set state to refresh");
                            try {
                              int selectedYear = int.parse(_titleTextController.text);
                              if (selectedYear < 1900 || selectedYear > 2050) {
                                _handleException(context);
                                return;
                              }
                            } catch (e) {
                              _handleException(context);
                            }

                            widget.callback!(int.parse(_titleTextController.text));
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
