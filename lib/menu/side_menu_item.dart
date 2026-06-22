import 'package:flutter/material.dart';

class SideMenuItem extends StatelessWidget {
  final IconData? icon;
  final String text;
  final GestureTapCallback? onTap;
  final bool isSelected;

  const SideMenuItem({
    super.key,
    this.icon,
    required this.text,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: isSelected ? primaryColor : theme.iconTheme.color?.withOpacity(0.65) ?? Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? primaryColor : theme.textTheme.bodyLarge?.color?.withOpacity(0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

