# Plan — Stylish Modern Bottom Navigation

**Branch:** enhancement/stylish-modern-bottom-navigation_14
**Issue:** #14
**Date:** 2026-06-21

## Goal
Replace the basic standard `BottomNavigationBar` in the event-calendar-v3 mobile application with a stylish, modern docked bottom navigation bar (Instagram-style) tailored specifically for Android and iOS devices, ensuring the month grid automatically fits the remaining screen area without scrolling.

## Approach
- Created a docked bottom navigation bar in `lib/menu/bottom_navigation.dart` that spans full-width without margins.
- Designed platform-specific UIs:
  - **iOS**: Uses a translucent glassmorphic blur with `BackdropFilter`, a thin top divider, and outline/filled icon transitions with a springy bounce scale animation.
  - **Android**: Uses a solid Material 3 styled bar with modern box shadows and an animated pill background indicator behind the selected icon.
  - Both respect safe areas via inner `SafeArea` padding.
- Set `extendBody: false` on the main page Scaffold in `lib/main.dart` to dock the bottom navigation bar and allocate the remaining vertical area for screen content.
- Wrapped `SingleMonthContainer` in a `LayoutBuilder` to dynamically calculate cell heights mathematically so that the 6-row month grid fits the parent container constraints exactly.
- Added `NeverScrollableScrollPhysics` to the month GridView to prevent any scrolling.

## Changes
- `lib/menu/bottom_navigation.dart` — Custom docked bottom navigation bar widget utilizing platform-specific UI designs, translucent blur for iOS, and pill/scale active animations.
- `lib/main.dart` — Set Scaffold's `extendBody` to `false` to dock the navigation bar.
- `lib/screens/home/widgets/single_month_container.dart` — Wrapped build in `LayoutBuilder` to compute exact `cellHeight` and `cellWidth` dynamically based on constraints, updated screen size checks, and set GridView to non-scrollable.
