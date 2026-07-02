# Plan — Day View: Swipe Left/Right with Drag-and-Follow Animation

**Branch:** feature/day-view_101
**Issue:** #103
**Date:** 2026-07-02

## Goal
Allow the user to drag and swipe left/right on the day view timeline to navigate between days, with a natural drag-and-follow animation identical to Google Calendar.

## Approach
Replace the `GestureDetector(onHorizontalDragEnd: ...)` wrapper (plan 77) with a `PageView.builder` around `DayTimeline`. The previous approach failed because `SingleChildScrollView` inside `DayTimeline` captures all touch events before the outer `GestureDetector` sees them.

`PageView` solves this cleanly: Flutter routes horizontal gestures to the `PageView` and vertical gestures to the `SingleChildScrollView` inside each page — no conflict, no velocity threshold hack, and built-in drag-and-follow animation with snap.

Key decisions:
- `initialPage: 500` — gives 500 days of navigation in each direction before hitting the boundary
- `_baseDate` anchors page-to-date arithmetic: `page 500 = baseDate`, `page 501 = baseDate + 1d`, etc.
- Per-page `ScrollController` map — a single shared controller would attach to multiple `DayTimeline` widgets during the swipe animation and throw a "controller attached to multiple widgets" error
- `DayNavHeader` arrow taps call `_pageController.animateToPage(...)` so arrows also animate rather than jumping
- `_onPageChanged` fires when a page settles, updates `_currentDate`/`_dayViewDate`, and loads events

## Changes
- `lib/screens/plans/user_event_page.dart` — replace `_dayScrollController` + `GestureDetector._onDaySwipe` with `PageController`, per-page `ScrollController` map, `PageView.builder` in `_buildDayViewContent`, `_onDayPageChanged`
- `lib/screens/day_view/day_view_page.dart` — replace `_scrollController` + `GestureDetector._onSwipe` with `PageController`, per-page `ScrollController` map, `PageView.builder` in `build`, `_onPageChanged`
