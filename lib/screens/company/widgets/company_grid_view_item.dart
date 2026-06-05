import 'package:flutter/material.dart';

class CompanyGridViewItem extends StatelessWidget {
  const CompanyGridViewItem({super.key, required this.iconData, required this.isSelected});
  final Container iconData;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 10 : 0,
      shadowColor: Colors.blue,
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        fillColor: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
        onPressed: null,
        child: iconData,
      ),
    );
  }
}
