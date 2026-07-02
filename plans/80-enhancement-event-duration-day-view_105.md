# Plan — Day View UX Improvements (Long-press Edit, Divider, Nav Colors, Recurring Events)

**Branch:** enhancement/event-duration-day-view_105
**Issue:** #105
**Date:** 2026-07-02

## Goal
Four day view UX improvements: open edit form on event long-press, thin secondary-color divider under the date header, secondary-color nav arrows, and correct display of daily/weekly recurring events on all applicable days.

## Changes

### Long-press event → edit form
- `DayEvent` — added `payload` field and `overrideStartTime` named param to factory so the original `NotificationPayload` travels with every event
- `DayEventBlock` — added `onLongPress` callback; tiny blocks (height < 14) now also wrapped in `GestureDetector`
- `DayTimeline` — added `onEventLongPressed` callback, wired to each block
- `DayViewPage._onEventLongPressed` — pushes `UserEventPage(eventToEdit: event.payload)`, refreshes on return
- `UserEventPage._onDayViewEventLongPressed` — same push + refresh for the embedded tab

### Divider
- Changed `Divider(height: 1)` → `Divider(height: 1, thickness: 0.5, color: theme.colorScheme.secondary)` in both `DayViewPage` and `UserEventPage._buildDayViewContent`

### Nav button colors
- `DayNavHeader` chevron buttons: changed from `onSurface.withValues(alpha: 0.7)` to `colorScheme.secondary`

### Recurring events
- Both `_loadEvents` (DayViewPage) and `_loadDayViewEvents` (UserEventPage) now:
  - Filter `visible == 'false'` ghost advance-alert notifications
  - Match `daily` events on every day ≥ the original scheduled date, constructing `startTime` on the viewed date
  - Match `weekly` events on the same weekday ≥ the original scheduled date
  - Pass `overrideStartTime` so the block appears at the correct Y position on the timeline

## Files Touched
- `lib/screens/day_view/models/day_event.dart`
- `lib/screens/day_view/widgets/day_event_block.dart`
- `lib/screens/day_view/widgets/day_timeline.dart`
- `lib/screens/day_view/widgets/day_nav_header.dart`
- `lib/screens/day_view/day_view_page.dart`
- `lib/screens/plans/user_event_page.dart`
