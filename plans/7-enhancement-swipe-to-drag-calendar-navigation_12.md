# Plan — Implement Swipe-to-Drag Calendar Month Navigation

**Branch:** enhancement/swipe-to-drag-calendar-navigation_12
**Issue:** #12
**Date:** 2026-06-21

## Goal
Implement a smooth, continuous month-to-month calendar drag transition (similar to Google Calendar) instead of the instant month swap that occurs on swipe gestures.

## Approach
- Replaced the simple horizontal swipe gesture detector (`SimpleGestureDetector`) with a `PageView.builder`.
- Parameterized the day sequence calculation and month grid rendering to calculate start indices, month lengths, and day lists dynamically per-month, removing reliance on shared mutable global variables.
- Integrated the existing header navigation arrows and the month picker to trigger page transitions via the `PageController` (`animateToPage`/`jumpToPage`), keeping all navigation methods synchronized.

## Changes
- `lib/screens/home/widgets/single_month_container.dart` — Replaced `SimpleGestureDetector` and `AnimatedSwitcher` with `PageView.builder`, added `PageController` lifecycle management, and parameterized calendar day grid drawing.
