# Plan — Drag/Swipe Year Grid Navigation

**Branch:** enhancement/drag-to-switch-years_20
**Issue:** #20
**Date:** 2026-06-22

## Goal
Implement a smooth, continuous year-to-year calendar drag transition for the year grid view, replacing the instant year swap that previously occurred on swipe gestures.

## Approach
- Replaced the simple horizontal swipe gesture detector (`SimpleGestureDetector`) and `AnimatedSwitcher` in `YearPage` with a `PageView.builder`.
- Parameterized the year pages to support the range 1900 to 2050 (index 0 to 150), wrapping around if the page index goes out of bounds.
- Synchronized the app bar navigation arrows and the Year Picker dialog callback to control PageView page transitions using the `PageController` (`animateToPage`/`jumpToPage`).

## Changes
- `lib/screens/year/year_page.dart` — Replaced SimpleGestureDetector/AnimatedSwitcher with PageView.builder, added PageController state management, and cleaned up gesture-related fields.
- `lib/screens/year/widgets/year_grid.dart` — Cleaned up unused home_page.dart import and unnecessary new keyword.
