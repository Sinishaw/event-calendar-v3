// ignore_for_file: sized_box_for_whitespace
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

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
  late ScrollController _scrollController;
  late double height, width;
  late int _selectedYear;
  late bool isGeezNumbers;

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;
    _selectedYear = widget.year ?? MonthGlobals.etNowYear!;

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    controller.fling();

    // Calculate initial scroll offset to center the selected year
    final int index = _selectedYear - 1900;
    final int row = index ~/ 3;
    final double rowHeight = 60.0; // itemHeight + spacing
    final double initialOffset = (row * rowHeight) - (240.0 / 2.0) + (52.0 / 2.0);
    _scrollController = ScrollController(initialScrollOffset: initialOffset.clamp(0.0, double.infinity));
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 320,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primary.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary.withValues(alpha: isDark ? 0.35 : 0.12),
                        primary.withValues(alpha: isDark ? 0.15 : 0.04),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.year,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Year Grid list
                Container(
                  height: 240,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 151, // 1900 to 2050
                    itemBuilder: (context, index) {
                      final yearValue = 1900 + index;
                      final isSelected = yearValue == _selectedYear;
                      final isTodayYear = yearValue == MonthGlobals.etNow!.year;

                      final pillBg = isSelected
                          ? primary
                          : (theme.brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : primary.withValues(alpha: 0.04));

                      final yearText = isGeezNumbers
                          ? (yearValue >= 1900 && yearValue - 1900 < GeezNumbers.geezYears.length
                              ? GeezNumbers.geezYears[yearValue - 1900]
                              : "$yearValue")
                          : "$yearValue";

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedYear = yearValue;
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
                                  : (isTodayYear ? primary : primary.withValues(alpha: 0.12)),
                              width: isTodayYear ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.3),
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
                                    : (isTodayYear ? primary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Footer Action buttons
                Container(
                  color: onSurface.withValues(alpha: 0.02),
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                              ),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: theme.dividerColor,
                      ),
                      // Confirm Button
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.callback!(_selectedYear);
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.select,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
