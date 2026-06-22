import 'package:flutter/material.dart';

class TabViewItem extends StatelessWidget {
  const TabViewItem({super.key, required this.innerText, required this.isSelected});

  final Text innerText;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor
            : (isDark ? Colors.white.withOpacity(0.06) : primaryColor.withOpacity(0.06)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isSelected
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
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          child: innerText,
        ),
      ),
    );
  }
}
