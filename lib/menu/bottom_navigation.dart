import 'dart:ui';
import 'package:flutter/material.dart';

import '../common/globals.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, required this.callback});
  final Function callback;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List<IconData> _inactiveIcons = [
    Icons.today_outlined,
    Icons.grid_view_outlined,
    Icons.change_circle_outlined,
    Icons.feed_outlined,
    Icons.menu_rounded,
  ];

  final List<IconData> _activeIcons = [
    Icons.today,
    Icons.grid_view,
    Icons.change_circle,
    Icons.feed,
    Icons.menu_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color backgroundColor = Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).cardColor;

    if (isIos) {
      // iOS tab bar styling (translucent blur, docked, thin divider, outline/fill active state)
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.85),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_activeIcons.length, (index) {
                    final bool isSelected = Globals.selectedIndex == index;
                    return IosNavItem(
                      icon: isSelected ? _activeIcons[index] : _inactiveIcons[index],
                      isSelected: isSelected,
                      activeColor: secondaryColor,
                      inactiveColor: primaryColor.withOpacity(0.5),
                      onTap: () {
                        widget.callback(index);
                        setState(() {});
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Android bottom bar styling (solid background, docked, elevation, M3 indicator)
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_activeIcons.length, (index) {
                final bool isSelected = Globals.selectedIndex == index;
                return AndroidNavItem(
                  icon: isSelected ? _activeIcons[index] : _inactiveIcons[index],
                  isSelected: isSelected,
                  activeColor: secondaryColor,
                  inactiveColor: primaryColor.withOpacity(0.6),
                  onTap: () {
                    widget.callback(index);
                    setState(() {});
                  },
                );
              }),
            ),
          ),
        ),
      );
    }
  }
}

class IosNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const IosNavItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          child: AnimatedScale(
            scale: isSelected ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(
              icon,
              size: 26,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

class AndroidNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const AndroidNavItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
