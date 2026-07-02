# Plan — Day View: Swipe Left/Right to Change Day

**Branch:** feature/day-view_101
**Issue:** #101
**Date:** 2026-07-02

## Goal
Allow the user to swipe left/right on the day view timeline to navigate to the
next or previous day, mirroring the gesture used in Google Calendar.

## Approach
Wrap the day view content Column in a `GestureDetector` using `onHorizontalDragEnd`.
The vertical `SingleChildScrollView` inside `DayTimeline` handles vertical drags via
its own gesture recognizer; Flutter's gesture arena cleanly separates vertical scroll
from horizontal swipe so there is no conflict.

Velocity threshold of 200 px/s distinguishes intentional swipes from incidental
horizontal movement during a vertical scroll.

- Swipe left (negative velocity) → next day
- Swipe right (positive velocity) → previous day

Applied to both the embedded view (`UserEventPage._buildDayViewContent`) and the
standalone `DayViewPage`.

## Changes
- `lib/screens/plans/user_event_page.dart` — add `_onDaySwipe`, wrap `_buildDayViewContent` Column in `GestureDetector`
- `lib/screens/day_view/day_view_page.dart` — add `_onSwipe`, wrap body `SafeArea > Column` in `GestureDetector`
