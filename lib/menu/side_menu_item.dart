import 'package:flutter/material.dart';

import '../common/globals.dart';

class SideMenuItem extends StatelessWidget {
  final IconData? icon;
  final String text;
  final GestureTapCallback? onTap;
  const SideMenuItem({super.key, this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color? iconsColor = Theme.of(context).primaryColor;
    return SizedBox(
      height: (Globals.deviceHeight! - 230) / 11,
      child: ListTile(
        title: Row(
          children: <Widget>[
            Icon(
              icon,
              color: iconsColor,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(text),
            )
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
