import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:flutter/material.dart';

class DurationPicker extends StatefulWidget {
  const DurationPicker({super.key, this.selectedOption, this.callback});
  final int? selectedOption;
  final Function? callback;

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> with TickerProviderStateMixin {
  static const _durations = [15, 30, 60, 120, 180];
  static const _labels = ['15 min', '30 min', '1 hr', '2 hr', '3 hr'];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _animationController.forward();
    final idx = _durations.indexOf(widget.selectedOption ?? 60);
    _selectedIndex = idx >= 0 ? idx : 2;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 320,
              maxHeight: MediaQuery.of(context).size.height * 0.50,
            ),
            decoration: BoxDecoration(
              color: cardBg.withOpacity(dialogOpacity),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    AppLocalizations.of(context)!.duration,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: primaryColor.withOpacity(0.12),
                    height: 1,
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _durations.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedIndex = index);
                            widget.callback!(_durations[index]);
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.10)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : primaryColor.withOpacity(0.12),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timelapse_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? primaryColor
                                      : primaryColor.withOpacity(0.45),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    _labels[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected
                                          ? primaryColor
                                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
