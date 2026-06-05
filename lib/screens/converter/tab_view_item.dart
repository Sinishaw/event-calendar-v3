import 'package:flutter/material.dart';

class TabViewItem extends StatelessWidget {
  const TabViewItem({super.key, required this.innerText, required this.isSelected});

  final Text innerText;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    Color clr = Theme.of(context).primaryColor;
    return Card(
      shadowColor: clr,
      elevation: isSelected ? 5 : 0,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? clr.withOpacity(0.7) : clr.withOpacity(0.07),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Center(child: innerText),
      ),
    );
  }
}
