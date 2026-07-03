# Plan — Form UX: Duration Dialog, Day Sync, Nav Colors

**Branch:** enhancement/event-duration-day-view_105
**Issue:** #107
**Date:** 2026-07-03

## Goal
Three UX fixes on the event form and day view:
1. Duration picker → dialog (matching Importance Tag pattern) so both cards are equal height.
2. Day view navigation syncs the form's selected date.
3. Day view date title always uses `colorScheme.secondary` (matches bottom nav active color).

## Approach

### Duration dialog
Created `lib/screens/plans/widgets/duration_picker.dart` modeled exactly on
`EventCategoryPicker`. Uses `primaryColor` for highlights (not per-item color).
Options: 15 min / 30 min / 1 hr / 2 hr / 3 hr. Animated scale dialog, same
dimensions as all other pickers. `_durationPicker()` in `user_event_page.dart`
replaced with a compact GestureDetector card (same structure as
`_notificationSchedulePicker`). Added `getSelectedDurationCallBack` + `_durationLabel`
helper. Both Duration and Importance Tag cards are now structurally identical → same height.

### Day sync
`_onDayPageChanged` now additionally calls `MonthModel.toEc()` (already imported via
`core_model.dart`) to convert the new GC date to ET, then updates `selectedGcDate` and
`_selectedEtDate` inside `setState`. The tab date badge and form date picker reflect the
navigated day immediately.

### Nav header color
`DayNavHeader` date title (day name + date text) changed from conditional
`primary`/`onSurface` to always `colorScheme.secondary` (day name at 0.75 alpha, date at
full). Chevrons were already `secondary`. The "Today" badge retains `primary`.

## Changes
- `lib/screens/plans/widgets/duration_picker.dart` — new dialog widget
- `lib/screens/plans/user_event_page.dart` — `_durationPicker()`, `getSelectedDurationCallBack`, `_durationLabel`, `_onDayPageChanged`, import
- `lib/screens/day_view/widgets/day_nav_header.dart` — date title colors
