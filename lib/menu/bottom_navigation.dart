import 'package:flutter/material.dart';

import '../common/globals.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, required this.callback});
  final Function callback;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: BottomNavigationBar(
        showSelectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: Globals.deviceHeight! > 700 ? 28 : 24,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Theme.of(context).primaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FittedBox(fit: BoxFit.contain, child: Icon(Icons.home, size: 30)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FittedBox(fit: BoxFit.contain, child: Icon(Icons.grid_view_sharp)),
            label: 'Year',
          ),
          BottomNavigationBarItem(
            icon: FittedBox(fit: BoxFit.contain, child: Icon(Icons.transform_rounded)),
            label: 'Converter',
          ),
          BottomNavigationBarItem(
            icon: FittedBox(fit: BoxFit.contain, child: Icon(Icons.note)),
            label: 'Archives',
          ),
          BottomNavigationBarItem(
            icon: FittedBox(fit: BoxFit.contain, child: Icon(Icons.menu)),
            label: 'More',
          ),
        ],
        currentIndex: Globals.selectedIndex,
        onTap: (value) => widget.callback(value),
      ),
    );
  }
}
